# 攻击系统设计

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - Tower Defense Case Study](../base/practical-experiences/case-studies/14_Tower_Defense_Case_Study.md)  
> **重要性**: ⭐⭐⭐ 核心系统设计

---

## 📋 简介

本文档详细介绍塔防游戏中的攻击系统架构设计，包括近战攻击、远程攻击、AOE 伤害等多种攻击方式的实现方案。

---

## 🎯 系统架构

### 继承体系

```
Node2D (角色基类)
└── characters/
    ├── base_character.gd      # 角色基类
    ├── tower.gd               # 防御塔
    └── attack/
        ├── base_attacker.gd   # 攻击基类
        ├── melee_attacker.gd  # 近战攻击
        └── range_attacker.gd  # 远程攻击
```

### 核心组件

攻击系统由以下组件构成：

1. **攻击者 (Attacker)** - 发起攻击的实体
2. **攻击目标 (Target)** - 被攻击的实体
3. **攻击方式 (Attack Type)** - 近战/远程/AOE
4. **伤害计算 (Damage Calculation)** - 伤害值计算逻辑
5. **攻击动画 (Attack Animation)** - 攻击视觉效果

---

## ⚔️ 攻击类型

### 1. 近战攻击 (Melee Attack)

**特点：**
- 无索敌范围，攻击固定范围内的所有敌人
- 同时伤害范围内所有目标（AOE）
- 需要攻击动画

**实现要点：**

```gdscript
# melee_attacker.gd
extends Node2D

@export var attack_range: float = 50.0
@export var damage: float = 10.0
@export var attack_interval: float = 1.0

var attack_timer: float = 0.0

func _physics_process(delta: float) -> void:
    attack_timer += delta
    
    if attack_timer >= attack_interval:
        attack_timer = 0.0
        perform_melee_attack()

func perform_melee_attack() -> void:
    # 获取范围内所有敌人
    var enemies = get_enemies_in_range()
    
    # 对所有敌人同时造成伤害
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.take_damage(damage)
    
    # 播放攻击动画
    play_attack_animation()

func get_enemies_in_range() -> Array:
    var result: Array = []
    var space_state = get_world_2d().direct_space_state
    
    # 使用射线检测或区域检测
    var query = PhysicsShapeQueryParameters2D.new()
    query.shape = CircleShape2D.new()
    query.shape.radius = attack_range
    query.transform = global_transform
    query.collision_mask = 1  # 敌人碰撞层
    
    var collisions = space_state.intersect_shape(query)
    for collision in collisions:
        var collider = collision.get("collider")
        if collider.is_in_group("enemies"):
            result.append(collider)
    
    return result
```

**攻击动画：**
```gdscript
func play_attack_animation() -> void:
    # 简单的攻击动画：缩放效果
    var tween = create_tween()
    tween.tween_property($Sprite2D, "scale", Vector2(1.5, 1.5), 0.1)
    tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)
```

### 2. 远程攻击 (Range Attack)

**特点：**
- 有索敌范围
- 发射投射物（Projectile）
- 需要瞄准和弹道计算

**实现要点：**

```gdscript
# range_attacker.gd
extends Node2D

@export var attack_range: float = 200.0
@export var damage: float = 15.0
@export var attack_interval: float = 0.5
@export var projectile_scene: PackedScene

var target: Node2D = null
var attack_timer: float = 0.0

func _physics_process(delta: float) -> void:
    attack_timer += delta
    
    # 寻找目标
    if target == null or not is_instance_valid(target):
        target = find_target()
    
    # 攻击目标
    if target and attack_timer >= attack_interval:
        attack_timer = 0.0
        shoot_projectile()

func find_target() -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemies")
    var closest: Node2D = null
    var closest_distance: float = INF
    
    for enemy in enemies:
        if is_instance_valid(enemy):
            var distance = global_position.distance_to(enemy.global_position)
            if distance <= attack_range and distance < closest_distance:
                closest = enemy
                closest_distance = distance
    
    return closest

func shoot_projectile() -> void:
    if projectile_scene == null:
        return
    
    var projectile = projectile_scene.instantiate()
    get_parent().add_child(projectile)
    projectile.setup(global_position, target, damage)
```

### 3. AOE 攻击 (Area of Effect)

**特点：**
- 范围伤害
- 可能持续伤害（DOT）
- 需要特殊效果

**实现要点：**

```gdscript
# aoe_attack.gd
extends Area2D

@export var damage: float = 20.0
@export var duration: float = 3.0
@export var tick_damage_interval: float = 0.5

var damage_timer: float = 0.0
var lifetime: float = 0.0

func _physics_process(delta: float) -> void:
    lifetime += delta
    damage_timer += delta
    
    # 持续伤害
    if damage_timer >= tick_damage_interval:
        damage_timer = 0.0
        deal_aoe_damage()
    
    # 生命周期结束
    if lifetime >= duration:
        queue_free()

func deal_aoe_damage() -> void:
    var bodies = get_overlapping_bodies()
    for body in bodies:
        if body.is_in_group("enemies"):
            body.take_damage(damage)
```

---

## 🎯 受击系统

### 受击基类

```gdscript
# base_under_attacked.gd
extends Node2D

@export var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(new_health: float)
signal died()

func take_damage(amount: float) -> void:
    current_health = max(0.0, current_health - amount)
    health_changed.emit(current_health)
    
    if current_health <= 0:
        die()

func die() -> void:
    died.emit()
    queue_free()

# 被击动画
func play_hit_animation() -> void:
    var tween = create_tween()
    tween.tween_property($Sprite2D, "modulate", Color.RED, 0.1)
    tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
```

---

## 📊 性能优化

### 1. 对象池

避免频繁创建/销毁投射物：

```gdscript
# projectile_pool.gd
extends Node2D

@export var projectile_scene: PackedScene
@export var initial_pool_size: int = 20

var pool: Array = []

func _ready() -> void:
    for i in range(initial_pool_size):
        var projectile = projectile_scene.instantiate()
        projectile.set_process(false)
        add_child(projectile)
        pool.append(projectile)

func get_projectile() -> Node2D:
    for projectile in pool:
        if not projectile.is_inside_tree():
            projectile.set_process(true)
            return projectile
    
    # 池耗尽，创建新的
    var projectile = projectile_scene.instantiate()
    add_child(projectile)
    pool.append(projectile)
    return projectile

func return_projectile(projectile: Node2D) -> void:
    projectile.set_process(false)
    projectile.visible = false
```

### 2. 空间划分

使用四叉树或网格管理大量实体：

```gdscript
# 简单的网格空间划分
class_name GridSpatialPartition

var cell_size: float = 100.0
var grid: Dictionary = {}

func add_entity(entity: Node2D) -> void:
    var cell = get_cell(entity.global_position)
    if not grid.has(cell):
        grid[cell] = []
    grid[cell].append(entity)

func get_entities_in_range(position: Vector2, range: float) -> Array:
    var result: Array = []
    var center_cell = get_cell(position)
    
    # 检查周围 9 个格子
    for x in range(-1, 2):
        for y in range(-1, 2):
            var cell = Vector2i(center_cell.x + x, center_cell.y + y)
            if grid.has(cell):
                for entity in grid[cell]:
                    if entity.global_position.distance_to(position) <= range:
                        result.append(entity)
    
    return result

func get_cell(position: Vector2) -> Vector2i:
    return Vector2i(
        floor(position.x / cell_size),
        floor(position.y / cell_size)
    )
```

---

## 🔧 配置系统

### 攻击配置

```gdscript
# tower_attack_config.gd
class_name TowerAttackConfig
extends Resource

@export_group("Attack")
@export var damage: float = 10.0
@export var attack_range: float = 100.0
@export var attack_interval: float = 1.0
@export var attack_type: AttackType = AttackType.MELEE

@export_group("Projectile")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 200.0

enum AttackType {
    MELEE,      # 近战
    RANGE,      # 远程
    AOE,        # 范围
    DOT         # 持续伤害
}
```

---

## 📚 相关资源

### Base 层资料来源
- [Tower Defense Case Study](../base/practical-experiences/case-studies/14_Tower_Defense_Case_Study.md) - 完整塔防案例

### Wiki 层相关页面
- [GDScript 代码规范](./gdscript-standards.md)
- [常见踩坑避雷](../guides/common-pitfalls.md)
- [性能优化实战](../guides/performance-optimization-guide.md)
- [投射物实体设计](../entities/projectile.md) - 投射物完整实现
- [防御塔设计](../entities/tower.md) - 塔的攻击逻辑
- [敌人实体设计](../entities/enemy.md) - 受伤处理
- [近战 vs 远程攻击对比](../comparisons/melee-vs-range-attack.md) - 攻击方案对比

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源**: tower_defense 项目实战经验
