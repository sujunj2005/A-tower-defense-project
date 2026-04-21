# 投射物实体设计

> **适用版本**: Godot 4.x  
> **实体类型**: 游戏对象  
> **前置知识**: GDScript 基础、物理系统、碰撞检测

---

## 🎯 投射物核心设计

### 1. 投射物分类

#### 1.1 按运动方式分类
| 类型 | 特点 | 适用场景 | 实现难度 |
|------|------|---------|---------|
| **直线投射物** | 匀速/加速直线飞行 | 子弹、箭矢、火球 | ⭐ |
| **抛物线投射物** | 受重力影响曲线飞行 | 炮弹、投石、手雷 | ⭐⭐ |
| **追踪投射物** | 自动追踪目标 | 导弹、魔法飞弹 | ⭐⭐⭐ |
| **弹射投射物** | 碰撞后反弹 | 弹球、 ricochet 子弹 | ⭐⭐⭐ |
| **分裂投射物** | 飞行中分裂成多个 | 散弹、分裂导弹 | ⭐⭐⭐⭐ |

#### 1.2 按伤害类型分类
| 类型 | 伤害方式 | 适用场景 |
|------|---------|---------|
| **瞬间伤害** | 碰撞立即造成伤害 | 子弹、箭矢 |
| **持续伤害** | 碰撞后持续灼烧 | 火焰瓶、酸液 |
| **范围伤害** | 爆炸造成 AOE 伤害 | 火箭筒、手雷 |
| **穿透伤害** | 穿透多个敌人 | 狙击弹、激光 |

---

## 2. 基础投射物架构

### 2.1 场景结构
```
Projectile (Area2D/CharacterBody2D)
├── Sprite2D (外观)
├── CollisionShape2D (碰撞形状)
├── Trail (GPUParticles2D - 拖尾效果)
└── HitEffect (GPUParticles2D - 命中效果，隐藏)
```

### 2.2 基础脚本模板
```gdscript
class_name Projectile
extends Area2D

# === 导出参数 ===
@export_group("Damage")
@export var damage: int = 10
@export var damage_type: DamageType = DamageType.PHYSICAL

@export_group("Movement")
@export var speed: float = 500.0
@export var lifetime: float = 3.0
@export var gravity: float = 0.0

@export_group("Penetration")
@export var pierce_count: int = 0
@export var can_penetrate_walls: bool = false

# === 内部变量 ===
var direction: Vector2 = Vector2.RIGHT
var current_pierce_count: int = 0
var hit_targets: Array = []

# === 信号 ===
signal hit_enemy(enemy)
signal hit_wall(position)
signal expired(position)

# === 节点引用 ===
@onready var trail: GPUParticles2D = $Trail
@onready var hit_effect: GPUParticles2D = $HitEffect

# === 生命周期 ===
func _ready():
    # 设置自动销毁
    if lifetime > 0:
        var timer = get_tree().create_timer(lifetime)
        timer.timeout.connect(_on_lifetime_expired)
    
    # 连接碰撞信号
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _physics_process(delta):
    # 应用重力
    if gravity != 0:
        direction.y += gravity * delta
        direction = direction.normalized()
    
    # 移动投射物
    position += direction * speed * delta
    
    # 旋转朝向运动方向
    if direction != Vector2.ZERO:
        rotation = direction.angle()

# === 初始化方法 ===
func initialize(dir: Vector2, owner_id: int = -1):
    direction = dir.normalized()
    # 记录所有者，避免伤害自己
    set_meta("owner_id", owner_id)

# === 碰撞处理 ===
func _on_body_entered(body: Node2D):
    # 检查是否穿透
    if current_pierce_count < pierce_count:
        current_pierce_count += 1
        return
    
    # 检查碰撞目标类型
    if body.is_in_group("enemies"):
        _handle_enemy_hit(body)
    elif body.is_in_group("players"):
        # 检查是否是所有者
        if body.get_meta("entity_id") != get_meta("owner_id"):
            _handle_enemy_hit(body)
    elif body is StaticBody2D and can_penetrate_walls:
        # 穿透墙壁
        pass
    else:
        # 普通墙壁碰撞
        _handle_wall_hit(body)

func _on_area_entered(area: Area2D):
    # 处理区域碰撞（如触发器）
    if area.is_in_group("triggers"):
        _handle_trigger(area)

# === 伤害处理 ===
func _handle_enemy_hit(enemy: Node2D):
    # 避免重复伤害同一目标
    if enemy in hit_targets:
        return
    hit_targets.append(enemy)
    
    # 造成伤害
    if enemy.has_method("take_damage"):
        enemy.take_damage(damage, damage_type)
    
    # 发射信号
    hit_enemy.emit(enemy)
    
    # 播放命中效果
    _spawn_hit_effect(enemy.global_position)
    
    # 销毁投射物（除非穿透）
    if current_pierce_count >= pierce_count:
        _destroy()

func _handle_wall_hit(wall: Node2D):
    hit_wall.emit(wall.global_position)
    _spawn_hit_effect(wall.global_position)
    _destroy()

func _handle_trigger(trigger: Area2D):
    # 触发器逻辑（如引爆、激活机关）
    if trigger.has_method("activate"):
        trigger.activate()

# === 效果处理 ===
func _spawn_hit_effect(position: Vector2):
    if hit_effect:
        var effect = hit_effect.duplicate()
        get_tree().current_scene.add_child(effect)
        effect.global_position = position
        effect.emitting = true
        
        # 自动销毁
        var timer = effect.get_tree().create_timer(1.0)
        timer.timeout.connect(effect.queue_free)

# === 销毁逻辑 ===
func _on_lifetime_expired():
    expired.emit(global_position)
    _destroy()

func _destroy():
    # 停止粒子效果
    if trail:
        trail.emitting = false
    
    # 延迟销毁以播放效果
    await get_tree().create_timer(0.1).timeout
    queue_free()

# === 枚举类型 ===
enum DamageType {
    PHYSICAL,
    FIRE,
    ICE,
    LIGHTNING,
    POISON
}
```

---

## 3. 特殊投射物实现

### 3.1 抛物线投射物
```gdscript
class_name ArcProjectile
extends Projectile

@export var initial_velocity: float = 800.0
@export var launch_angle: float = 45.0  # 角度制

var velocity_vector: Vector2

func initialize(dir: Vector2, owner_id: int = -1):
    super.initialize(dir, owner_id)
    
    # 计算初始速度向量
    var angle_rad = deg_to_rad(launch_angle)
    velocity_vector = Vector2(
        cos(angle_rad) * initial_velocity,
        -sin(angle_rad) * initial_velocity  # Godot Y 轴向下
    ).rotated(dir.angle())

func _physics_process(delta):
    # 应用重力
    velocity_vector.y += gravity * delta
    
    # 更新位置
    position += velocity_vector * delta
    
    # 旋转朝向速度方向
    if velocity_vector != Vector2.ZERO:
        rotation = velocity_vector.angle()
```

### 3.2 追踪投射物
```gdscript
class_name HomingProjectile
extends Projectile

@export var turn_speed: float = 5.0
@export var lock_on_range: float = 200.0
@export var target_layer: int = 2  # 敌人在第 2 层

var current_target: Node2D = null

func _physics_process(delta):
    # 搜索目标
    if current_target == null or not is_instance_valid(current_target):
        current_target = _find_nearest_target()
    
    # 追踪目标
    if current_target and is_instance_valid(current_target):
        var to_target = (current_target.global_position - global_position).normalized()
        # 平滑转向
        direction = direction.lerp(to_target, turn_speed * delta)
    
    # 移动
    position += direction * speed * delta
    rotation = direction.angle()

func _find_nearest_target() -> Node2D:
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    query.collision_mask = target_layer
    query.transform = Transform2D(0, global_position)
    query.shape = CircleShape2D.new()
    query.shape.radius = lock_on_range
    
    var results = space_state.intersect_shape(query)
    
    var nearest = null
    var nearest_distance = INF
    
    for result in results:
        var collider = result.collider
        var distance = global_position.distance_to(collider.global_position)
        
        if distance < nearest_distance:
            nearest = collider
            nearest_distance = distance
    
    return nearest
```

### 3.3 弹射投射物
```gdscript
class_name BouncingProjectile
extends Projectile

@export var max_bounces: int = 3
@export var bounce_damping: float = 0.8
@export var bounce_sound: AudioStream

var bounce_count: int = 0
var last_bounce_time: float = 0

func _on_body_entered(body: Node2D):
    # 检查是否可以弹射
    if bounce_count < max_bounces and body is StaticBody2D:
        _handle_bounce(body)
    else:
        _handle_wall_hit(body)

func _handle_bounce(wall: StaticBody2D):
    bounce_count += 1
    
    # 计算反射向量
    var collision_normal = _get_collision_normal(wall)
    direction = direction.bounce(collision_normal)
    
    # 应用阻尼
    speed *= bounce_damping
    
    # 播放弹射效果
    _spawn_bounce_effect(global_position)
    
    if bounce_sound:
        AudioServer.play_stream(bounce_sound)
    
    # 对接触的敌人造成伤害
    var enemies = _get_enemies_in_radius(50.0)
    for enemy in enemies:
        _handle_enemy_hit(enemy)

func _get_collision_normal(wall: StaticBody2D) -> Vector2:
    # 简化：假设墙壁是水平的或垂直的
    if wall.get_node_or_null("CollisionShape2D"):
        var shape = wall.get_node("CollisionShape2D").shape
        if shape is RectangleShape2D:
            # 根据相对位置判断法线
            var local_pos = wall.get_local_mouse_position()
            if abs(local_pos.x) > abs(local_pos.y):
                return Vector2.RIGHT * sign(local_pos.x)
            else:
                return Vector2.DOWN * sign(local_pos.y)
    
    return Vector2.UP  # 默认

func _get_enemies_in_radius(radius: float) -> Array:
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    query.collision_mask = 2  # 敌人层
    query.shape = CircleShape2D.new()
    query.shape.radius = radius
    query.transform = Transform2D(0, global_position)
    
    var results = space_state.intersect_shape(query)
    var enemies = []
    
    for result in results:
        var collider = result.collider
        if collider.is_in_group("enemies"):
            enemies.append(collider)
    
    return enemies
```

### 3.4 分裂投射物
```gdscript
class_name SplittingProjectile
extends Projectile

@export var split_count: int = 3
@export var split_angle: float = 30.0
@export var split_delay: float = 0.5
@export var child_scene: PackedScene

var has_split: bool = false

func _on_lifetime_expired():
    if not has_split and split_count > 0:
        _split()
    else:
        super._on_lifetime_expired()

func _split():
    has_split = true
    
    # 停止当前投射物
    set_physics_process(false)
    visible = false
    $CollisionShape2D.disabled = true
    
    # 创建分裂投射物
    var base_angle = direction.angle()
    var start_angle = base_angle - deg_to_rad(split_angle) * (split_count - 1) / 2
    
    for i in range(split_count):
        if child_scene:
            var child = child_scene.instantiate()
            get_tree().current_scene.add_child(child)
            child.global_position = global_position
            
            # 计算分裂角度
            var angle = start_angle + deg_to_rad(split_angle) * i
            var child_dir = Vector2(cos(angle), sin(angle))
            
            # 初始化子投射物
            if child.has_method("initialize"):
                child.initialize(child_dir, get_meta("owner_id"))
            
            # 继承伤害
            if "damage" in child:
                child.damage = damage / split_count
    
    # 延迟销毁父投射物
    await get_tree().create_timer(split_delay).timeout
    queue_free()
```

---

## 4. 投射物优化

### 4.1 对象池管理
```gdscript
class_name ProjectilePool
extends Node

@export var projectile_scene: PackedScene
@export var initial_size: int = 20
@export var max_size: int = 100

var pool: Array[Projectile] = []
var active_projectiles: Array[Projectile] = []

func _ready():
    # 预创建投射物
    for i in range(initial_size):
        var projectile = projectile_scene.instantiate()
        projectile.set_process(false)
        projectile.visible = false
        add_child(projectile)
        pool.append(projectile)

func spawn(position: Vector2, direction: Vector2, owner_id: int = -1) -> Projectile:
    var projectile: Projectile
    
    # 从池中获取
    if pool.size() > 0:
        projectile = pool.pop_back()
    else:
        # 池为空，创建新的
        if active_projectiles.size() < max_size:
            projectile = projectile_scene.instantiate()
            add_child(projectile)
        else:
            push_warning("投射物池已满！")
            return null
    
    # 激活投射物
    projectile.global_position = position
    projectile.visible = true
    projectile.set_process(true)
    
    if projectile.has_method("initialize"):
        projectile.initialize(direction, owner_id)
    
    # 连接到销毁信号
    if not projectile.hit_enemy.is_connected(_on_projectile_destroyed.bind(projectile)):
        projectile.hit_enemy.connect(_on_projectile_destroyed.bind(projectile))
    if not projectile.hit_wall.is_connected(_on_projectile_destroyed.bind(projectile)):
        projectile.hit_wall.connect(_on_projectile_destroyed.bind(projectile))
    if not projectile.expired.is_connected(_on_projectile_destroyed.bind(projectile)):
        projectile.expired.connect(_on_projectile_destroyed.bind(projectile))
    
    active_projectiles.append(projectile)
    return projectile

func _on_projectile_destroyed(_data, projectile: Projectile):
    # 回收到池中
    active_projectiles.erase(projectile)
    
    projectile.set_process(false)
    projectile.visible = false
    projectile.position = Vector2(-1000, -1000)  # 移到视野外
    
    pool.append(projectile)

func get_active_count() -> int:
    return active_projectiles.size()

func get_pool_size() -> int:
    return pool.size()
```

### 4.2 性能优化建议

| 优化方向 | 具体措施 | 性能提升 |
|---------|---------|---------|
| **对象池** | 预创建投射物，避免运行时 instantiate | ⭐⭐⭐⭐⭐ |
| **简化碰撞** | 使用 Area2D + 简单碰撞形状 | ⭐⭐⭐⭐ |
| **减少信号** | 批量处理碰撞，避免频繁信号 | ⭐⭐⭐ |
| **粒子优化** | 使用 GPUParticles2D，限制数量 | ⭐⭐⭐⭐ |
| **距离剔除** | 超出距离立即销毁 | ⭐⭐⭐ |
| **批量更新** | 多投射物共享更新逻辑 | ⭐⭐ |

---

## 5. 实战示例

### 5.1 塔防游戏投射物
```gdscript
# 塔发射的子弹
class_name TowerProjectile
extends Projectile

@export var slow_factor: float = 0.5  # 减速效果
@export var slow_duration: float = 2.0
@export var is_explosive: bool = false
@export var explosion_radius: float = 100.0

func _handle_enemy_hit(enemy: Node2D):
    super._handle_enemy_hit(enemy)
    
    # 应用减速效果
    if slow_factor > 0 and enemy.has_method("apply_slow"):
        enemy.apply_slow(slow_factor, slow_duration)
    
    # 爆炸伤害
    if is_explosive:
        _handle_explosion()

func _handle_explosion():
    # 获取爆炸范围内敌人
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    query.collision_mask = 2  # 敌人层
    query.shape = CircleShape2D.new()
    query.shape.radius = explosion_radius
    query.transform = Transform2D(0, global_position)
    
    var results = space_state.intersect_shape(query)
    
    for result in results:
        var collider = result.collider
        if collider.is_in_group("enemies") and collider.has_method("take_damage"):
            collider.take_damage(damage * 0.5, damage_type)  # 爆炸伤害减半
    
    # 播放爆炸效果
    _spawn_explosion_effect()

func _spawn_explosion_effect():
    var explosion = preload("res://scenes/effects/explosion.tscn").instantiate()
    get_tree().current_scene.add_child(explosion)
    explosion.global_position = global_position
```

### 5.2 玩家武器投射物
```gdscript
# 玩家枪械投射物
class_name PlayerBullet
extends Projectile

@export var is_critical: bool = false
@export var critical_chance: float = 0.2
@export var critical_multiplier: float = 2.0

var final_damage: int

func initialize(dir: Vector2, owner_id: int = -1):
    super.initialize(dir, owner_id)
    
    # 计算暴击伤害
    if is_critical or randf() < critical_chance:
        final_damage = int(damage * critical_multiplier)
    else:
        final_damage = damage

func _handle_enemy_hit(enemy: Node2D):
    # 检查是否是敌人
    if not enemy.is_in_group("enemies"):
        return
    
    # 造成伤害（使用最终伤害）
    if enemy.has_method("take_damage"):
        enemy.take_damage(final_damage, damage_type, is_critical)
    
    hit_enemy.emit(enemy)
    _spawn_hit_effect(enemy.global_position)
    
    if current_pierce_count >= pierce_count:
        _destroy()
```

---

## 🔗 相关资源

### Base 层来源
- [物理系统](../../base/physics-system/) - 碰撞检测基础
- [Area2D](../../base/physics-system/06F_Area2D.md) - 区域检测
- [射线检测](../../base/physics-system/06G_RayCasting.md) - 射线查询

### Wiki 层相关
- [物理系统介绍](../concepts/physics-intro.md) - 物理核心概念
- [Area2D 概念](../concepts/area2d-concept.md) - Area2D 使用
- [碰撞检测方案对比](./collision-detection-comparison.md) - 碰撞方案选择
- [敌人实体设计](./enemy.md) - 敌人受伤处理
- [防御塔设计](./tower.md) - 塔的投射物发射
- [玩家实体设计](./player.md) - 玩家发射的投射物
- [攻击系统设计](../concepts/attack-system.md) - 攻击系统架构
- [2D 粒子系统指南](../guides/particles-2d-guide.md) - 拖尾/命中效果

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
