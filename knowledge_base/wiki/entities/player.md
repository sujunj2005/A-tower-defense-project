# 玩家实体设计

> **适用版本**: Godot 4.x  
> **实体类型**: 可控角色  
> **前置知识**: GDScript 基础、输入系统、物理系统、状态机

---

## 🎯 玩家实体核心设计

### 1. 玩家实体架构

#### 1.1 场景结构（2D 平台跳跃）
```
Player (CharacterBody2D)
├── Sprite2D (外观)
├── CollisionShape2D (碰撞形状)
├── Camera2D (摄像机)
├── RayCast2D (地面检测)
├── RayCast2D_Wall (墙壁检测)
├── HurtBox (受伤区域 - Area2D)
└── AnimationPlayer (动画播放)
```

#### 1.2 场景结构（3D 第三人称）
```
Player (CharacterBody3D)
├── MeshInstance3D (外观)
├── CollisionShape3D (碰撞形状)
├── Camera3D (摄像机)
├── RayCast3D (地面检测)
├── HurtBox (受伤区域 - Area3D)
└── AnimationPlayer (动画播放)
```

---

## 2. 基础玩家控制器

### 2.1 2D 平台跳跃控制器
```gdscript
class_name PlayerController2D
extends CharacterBody2D

# === 信号 ===
signal health_changed(new_health, old_health)
signal died()
signal jumped()
signal landed()
signal state_changed(new_state, old_state)

# === 导出参数 - 移动 ===
@export_group("Movement")
@export var walk_speed: float = 200.0
@export var run_speed: float = 350.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0
@export var air_acceleration: float = 400.0
@export var air_friction: float = 200.0

# === 导出参数 - 跳跃 ===
@export_group("Jump")
@export var jump_velocity: float = -400.0
@export var jump_hold_time: float = 0.2
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.15

# === 导出参数 - 生命值 ===
@export_group("Health")
@export var max_health: int = 100
@export var invincibility_duration: float = 1.5

# === 内部变量 ===
var current_health: int
var is_grounded: bool = false
var is_jumping: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_invincible: bool = false
var invincibility_timer: float = 0.0

# 状态
enum State {
    IDLE,
    WALK,
    JUMP,
    FALL,
    HURT,
    DEAD
}
var current_state: State = State.IDLE

# === 节点引用 ===
@onready var sprite: Sprite2D = $Sprite2D
@onready var ground_ray: RayCast2D = $RayCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: Area2D = $HurtBox
@onready var camera: Camera2D = $Camera2D

# === 生命周期 ===
func _ready():
    current_health = max_health
    
    # 连接信号
    hurt_box.body_entered.connect(_on_hurt_box_body_entered)
    
    # 设置摄像机跟随
    if camera:
        camera.make_current()

func _physics_process(delta):
    # 更新计时器
    _update_timers(delta)
    
    # 地面检测
    _check_ground()
    
    # 处理输入
    var input_dir = _handle_input()
    
    # 应用移动
    _apply_movement(input_dir, delta)
    
    # 应用重力
    _apply_gravity(delta)
    
    # 处理跳跃
    _handle_jump()
    
    # 移动角色
    move_and_slide()
    
    # 更新状态
    _update_state()
    
    # 更新动画
    _update_animation()

# === 输入处理 ===
func _handle_input() -> Vector2:
    var input_dir = Vector2.ZERO
    
    input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    
    # 奔跑
    if Input.is_action_pressed("run"):
        current_speed = run_speed
    else:
        current_speed = walk_speed
    
    return input_dir

func _handle_jump():
    # 跳跃缓冲
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time
    
    # 消耗缓冲
    if jump_buffer_timer > 0:
        jump_buffer_timer -= get_physics_process_delta_time()
    
    # 执行跳跃（土狼时间 + 缓冲）
    if (is_grounded or coyote_timer > 0) and jump_buffer_timer > 0:
        velocity.y = jump_velocity
        is_jumping = true
        coyote_timer = 0
        jump_buffer_timer = 0
        jumped.emit()

# === 移动物理 ===
func _apply_movement(input_dir: Vector2, delta: float):
    var current_acceleration = acceleration if is_grounded else air_acceleration
    var current_friction = friction if is_grounded else air_friction
    
    if input_dir.x != 0:
        velocity.x = move_toward(velocity.x, input_dir.x * current_speed, current_acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, current_friction * delta)
    
    # 翻转精灵
    if input_dir.x != 0:
        sprite.flip_h = input_dir.x < 0

func _apply_gravity(delta: float):
    if not is_grounded:
        velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

# === 地面检测 ===
func _check_ground():
    is_grounded = ground_ray.is_colliding()
    
    if is_grounded:
        coyote_timer = coyote_time
        if is_jumping:
            is_jumping = false
            landed.emit()
    else:
        coyote_timer -= get_physics_process_delta_time()

# === 计时器更新 ===
func _update_timers(delta: float):
    if is_invincible:
        invincibility_timer -= delta
        if invincibility_timer <= 0:
            is_invincible = false
    
    # 闪烁效果
    if is_invincible and sprite:
        sprite.visible = fmod(invincibility_timer, 0.1) < 0.05

# === 受伤处理 ===
func _on_hurt_box_body_entered(body: Node2D):
    if body.is_in_group("enemies") and not is_invincible:
        take_damage(body.get("damage", 10))

func take_damage(amount: int, damage_type: int = 0, is_critical: bool = false):
    if is_invincible or current_health <= 0:
        return
    
    var old_health = current_health
    current_health = max(0, current_health - amount)
    
    health_changed.emit(current_health, old_health)
    
    if current_health <= 0:
        _die()
    else:
        _start_invincibility()

func _start_invincibility():
    is_invincible = true
    invincibility_timer = invincibility_duration

func _die():
    current_state = State.DEAD
    died.emit()
    # 播放死亡动画
    if animation_player:
        animation_player.play("death")
    # 禁用碰撞
    set_collision_layer_value(1, false)
    set_collision_mask_value(1, false)

# === 状态更新 ===
func _update_state():
    var old_state = current_state
    
    if current_state == State.DEAD:
        return
    
    if not is_grounded:
        if velocity.y < 0:
            current_state = State.JUMP
        else:
            current_state = State.FALL
    else:
        if abs(velocity.x) < 10:
            current_state = State.IDLE
        else:
            current_state = State.WALK
    
    if current_state != old_state:
        state_changed.emit(current_state, old_state)

# === 动画更新 ===
func _update_animation():
    if not animation_player:
        return
    
    var animation = ""
    
    match current_state:
        State.IDLE:
            animation = "idle"
        State.WALK:
            animation = "walk"
        State.JUMP:
            animation = "jump"
        State.FALL:
            animation = "fall"
        State.DEAD:
            animation = "death"
        State.HURT:
            animation = "hurt"
    
    if animation and animation_player.current_animation != animation:
        animation_player.play(animation)

# === 公共方法 ===
func heal(amount: int):
    current_health = min(max_health, current_health + amount)
    health_changed.emit(current_health, current_health - amount)

func reset():
    current_health = max_health
    is_invincible = false
    current_state = State.IDLE
    velocity = Vector2.ZERO
    set_collision_layer_value(1, true)
    set_collision_mask_value(1, true)
```

### 2.2 3D 第三人称控制器
```gdscript
class_name PlayerController3D
extends CharacterBody3D

# === 信号 ===
signal health_changed(new_health, old_health)
signal died()

# === 导出参数 - 移动 ===
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var rotation_speed: float = 10.0

# === 导出参数 - 跳跃 ===
@export_group("Jump")
@export var jump_velocity: float = 5.0
@export var gravity: float = -20.0

# === 导出参数 - 摄像机 ===
@export_group("Camera")
@export var camera_sensitivity: float = 0.003
@export var camera_distance: float = 5.0
@export var camera_height: float = 2.0

# === 生命值 ===
@export_group("Health")
@export var max_health: int = 100

# === 内部变量 ===
var current_health: int
var camera_rotation_x: float = 0.0
var camera_rotation_y: float = 0.0

# === 节点引用 ===
@onready var camera: Camera3D = $Camera3D
@onready var model: Node3D = $Model

func _ready():
    current_health = max_health
    
    # 捕获鼠标
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
    # 摄像机旋转
    if event is InputEventMouseMotion:
        camera_rotation_y -= event.relative.x * camera_sensitivity
        camera_rotation_x -= event.relative.y * camera_sensitivity
        camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
    # 获取输入
    var input_dir = _get_input_direction()
    
    # 计算移动方向（基于摄像机）
    var direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    # 应用重力
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # 处理跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
    
    # 移动
    if direction:
        var target_speed = run_speed if Input.is_action_pressed("run") else walk_speed
        velocity.x = direction.x * target_speed
        velocity.z = direction.z * target_speed
        
        # 旋转角色朝向移动方向
        var target_rotation = atan2(direction.x, direction.z)
        model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, walk_speed)
        velocity.z = move_toward(velocity.z, 0, walk_speed)
    
    move_and_slide()
    
    # 更新摄像机
    _update_camera()

func _get_input_direction() -> Vector3:
    var input_dir = Vector3.ZERO
    
    input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input_dir.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    
    return input_dir

func _update_camera():
    # 设置摄像机位置
    var camera_pos = global_position
    camera_pos.y += camera_height
    camera.position = camera_pos
    
    # 设置摄像机旋转
    camera.rotation.x = camera_rotation_x
    camera.rotation.y = camera_rotation_y
    
    # 射线检测避免穿墙
    _camera_ray_cast()

func _camera_ray_cast():
    var space_state = get_world_3d().direct_space_state
    var from = global_position + Vector3(0, camera_height, 0)
    var to = from - camera.global_transform.basis.z * camera_distance
    
    var query = PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [get_instance_id()]
    
    var result = space_state.intersect_ray(query)
    
    if result:
        var distance = from.distance_to(result.position) - 0.5
        camera.position = from - camera.global_transform.basis.z * distance

func take_damage(amount: int):
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health, current_health - amount)
    
    if current_health <= 0:
        died.emit()
```

---

## 3. 高级功能实现

### 3.1 状态机模式
```gdscript
# 玩家状态基类
class_name PlayerState
extends RefCounted

var player: PlayerController2D

func enter():
    pass

func exit():
    pass

func update(delta: float):
    pass

func handle_input(event: InputEvent):
    pass

# 空闲状态
class_name PlayerIdleState
extends PlayerState

func update(delta: float):
    var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    
    if input_x != 0:
        player.change_state("walk")
    elif not player.is_grounded:
        player.change_state("fall")
    elif Input.is_action_just_pressed("jump"):
        player.change_state("jump")

# 行走状态
class_name PlayerWalkState
extends PlayerState

func enter():
    pass

func update(delta: float):
    var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    
    if input_x == 0:
        player.change_state("idle")
    elif not player.is_grounded:
        player.change_state("fall")

# 跳跃状态
class_name PlayerJumpState
extends PlayerState

func enter():
    player.velocity.y = player.jump_velocity

func update(delta: float):
    if player.velocity.y >= 0:
        player.change_state("fall")

# 状态机管理器
class_name PlayerStateMachine
extends Node

var states: Dictionary = {}
var current_state: PlayerState
var player: PlayerController2D

func _ready():
    player = get_parent()
    
    # 初始化状态
    states["idle"] = PlayerIdleState.new()
    states["walk"] = PlayerWalkState.new()
    states["jump"] = PlayerJumpState.new()
    states["fall"] = PlayerFallState.new()
    
    # 设置 player 引用
    for state in states.values():
        state.player = player
    
    # 进入初始状态
    change_state("idle")

func _physics_process(delta):
    current_state.update(delta)

func _unhandled_input(event):
    current_state.handle_input(event)

func change_state(new_state_name: String):
    if current_state:
        current_state.exit()
    
    current_state = states[new_state_name]
    current_state.enter()
```

### 3.2 连击系统
```gdscript
# 连击管理器
class_name ComboSystem
extends Node

@export var combo_window: float = 2.0
@export var min_combo_count: int = 3

var combo_count: int = 0
var combo_timer: float = 0.0
var is_in_combo: bool = false

signal combo_started(combo_count)
signal combo_updated(combo_count)
signal combo_ended(combo_count)
signal combo_achieved(rank)

func _physics_process(delta):
    if is_in_combo:
        combo_timer -= delta
        if combo_timer <= 0:
            _end_combo()

func add_hit():
    if not is_in_combo:
        is_in_combo = true
        combo_count = 1
        combo_started.emit(combo_count)
    else:
        combo_count += 1
        combo_updated.emit(combo_count)
    
    combo_timer = combo_window
    
    # 检查连击成就
    if combo_count >= min_combo_count * 5:
        combo_achieved.emit("S")
    elif combo_count >= min_combo_count * 3:
        combo_achieved.emit("A")
    elif combo_count >= min_combo_count:
        combo_achieved.emit("B")

func _end_combo():
    if combo_count >= min_combo_count:
        combo_ended.emit(combo_count)
    
    is_in_combo = false
    combo_count = 0
    combo_timer = 0.0

func get_combo_multiplier() -> float:
    if combo_count < min_combo_count:
        return 1.0
    elif combo_count < min_combo_count * 2:
        return 1.5
    elif combo_count < min_combo_count * 3:
        return 2.0
    else:
        return 3.0
```

### 3.3 技能系统
```gdscript
# 技能基类
class_name Skill
extends RefCounted

var skill_name: String
var cooldown: float
var current_cooldown: float = 0.0
var is_ready: bool = true

signal ready_changed(is_ready)

func _init(name: String, cd: float):
    skill_name = name
    cooldown = cd

func execute(player: Node2D) -> bool:
    if not is_ready:
        return false
    
    _on_execute(player)
    _start_cooldown()
    return true

func _on_execute(player: Node2D):
    # 子类实现
    pass

func _start_cooldown():
    is_ready = false
    ready_changed.emit(false)
    
    var timer = Timer.new()
    timer.wait_time = cooldown
    timer.one_shot = true
    timer.timeout.connect(_on_cooldown_finished)
    Engine.get_main_loop().root.add_child(timer)
    timer.start()

func _on_cooldown_finished():
    is_ready = true
    ready_changed.emit(true)

# 冲刺技能
class_name DashSkill
extends Skill

@export var dash_distance: float = 100.0
@export var dash_speed: float = 20.0

func _init():
    super._init("Dash", 1.0)

func _on_execute(player: Node2D):
    if player is CharacterBody2D:
        var direction = Vector2.RIGHT
        if player.has_meta("facing"):
            direction = player.get_meta("facing")
        
        var tween = player.create_tween()
        tween.tween_property(player, "position", 
            player.position + direction * dash_distance, 
            dash_distance / dash_speed
        ).set_ease(Tween.EASE_OUT)

# 治疗技能
class_name HealSkill
extends Skill

@export var heal_amount: int = 30

func _init():
    super._init("Heal", 5.0)

func _on_execute(player: Node2D):
    if player.has_method("heal"):
        player.heal(heal_amount)

# 技能管理器
class_name SkillManager
extends Node

var skills: Dictionary = {}

func _ready():
    # 初始化技能
    skills["dash"] = DashSkill.new()
    skills["heal"] = HealSkill.new()

func use_skill(skill_name: String, player: Node2D) -> bool:
    if not skills.has(skill_name):
        return false
    
    return skills[skill_name].execute(player)

func get_skill_cooldown(skill_name: String) -> float:
    if skills.has(skill_name):
        return skills[skill_name].current_cooldown
    return 0.0
```

---

## 4. 玩家数据持久化

### 4.1 玩家数据保存
```gdscript
class_name PlayerData
extends Resource

@export var player_name: String = "Player"
@export var max_health: int = 100
@export var current_health: int = 100
@export var unlocked_skills: Array[String] = []
@export var collected_items: Dictionary = {}
@export var play_time: float = 0.0
@export var level: int = 1
@export var experience: int = 0

func save_to_file(path: String = "user://player_data.save"):
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_var(self)
        file.close()
        return true
    return false

static func load_from_file(path: String = "user://player_data.save") -> PlayerData:
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var data = file.get_var()
        file.close()
        return data
    return null

func add_item(item_id: String, count: int = 1):
    if collected_items.has(item_id):
        collected_items[item_id] += count
    else:
        collected_items[item_id] = count

func remove_item(item_id: String, count: int = 1):
    if collected_items.has(item_id):
        collected_items[item_id] = max(0, collected_items[item_id] - count)
        if collected_items[item_id] == 0:
            collected_items.erase(item_id)

func has_item(item_id: String, count: int = 1) -> bool:
    return collected_items.has(item_id) and collected_items[item_id] >= count
```

---

## 5. 性能优化

### 5.1 优化建议

| 优化方向 | 具体措施 | 性能提升 |
|---------|---------|---------|
| **减少射线检测** | 合并多个射线检测 | ⭐⭐⭐ |
| **动画优化** | 使用 AnimationTree 代替 AnimationPlayer | ⭐⭐⭐⭐ |
| **输入缓冲** | 减少每帧输入检查 | ⭐⭐ |
| **碰撞层优化** | 合理配置碰撞层 | ⭐⭐⭐⭐ |
| **对象池** | 投射物/效果使用对象池 | ⭐⭐⭐⭐⭐ |

---

## 🔗 相关资源

### Base 层来源
- [CharacterBody2D](../../base/physics-system/06B_CharacterBody2D.md) - 角色控制
- [输入事件](../../base/input-system/08A_InputEvent.md) - 输入处理
- [输入映射](../../base/input-system/08B_InputMap.md) - 输入配置

### Wiki 层相关
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md) - 角色核心概念
- [输入事件概念](../concepts/input-events.md) - 输入系统
- [输入映射指南](../guides/input-map-guide.md) - 输入配置实战
- [2D 移动指南](../guides/2d-movement-guide.md) - 移动实现
- [3D 游戏开发概述](../overviews/3d-game-development-overview.md) - 3D 角色移动
- [常见踩坑避雷](../guides/common-pitfalls.md) - 角色控制常见陷阱
- [投射物实体设计](./projectile.md) - 玩家发射的投射物
- [敌人实体设计](./enemy.md) - 玩家的攻击目标

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
