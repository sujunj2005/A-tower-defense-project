# 场景组织最佳实践

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/best_practices/scene_organization.rst

---

## 一、核心原则

### 1.1 设计无依赖场景

**黄金法则**：**如果可能，设计场景时不应该有任何外部依赖。**

场景应包含其所需的一切。这遵循 OOP 原则：
- **单一职责**：保持类专注、目的单一
- **松耦合**：减少对代码库其他部分的依赖
- **高复用性**：对象体积小，易于维护和重用

### 1.2 问题背景

开发者常遇到的问题：
1. 创建第一个场景并填满内容
2. 感觉应该拆分，将部分保存为独立场景
3. **硬引用失效**：之前依赖的节点路径找不到目标
4. **信号连接断裂**：编辑器中建立的连接在实例化后断开

**根本原因**：子场景需要了解太多关于其使用环境的细节。

---

## 二、依赖注入模式

当场景必须与外部上下文交互时，使用**依赖注入（Dependency Injection）**：

> 高层API提供低层API的依赖项  
> 为什么？因为依赖外部环境的类会意外触发bug和意外行为

### 方法1：信号连接（推荐用于"响应"行为）

```gdscene
# 父节点 - 连接信号
$Child.signal_name.connect(_on_child_signal)

func _on_child_signal():
    print("子节点发出了信号")

# 子节点 - 发射信号
signal skill_activated
signal item_collected
signal entered

func some_action():
    skill_activated.emit()  # 触发父节点指定的行为
```

**信号命名约定**：使用过去式动词（entered, activated, collected）

### 方法2：调用方法（用于"启动"行为）

```gdscene
# 父节点 - 设置方法名
$Child.method_name = "do_something"

# 子节点 - 调用父节点指定的方法
@export var method_name: String = ""

func execute():
    if method_name != "" and has_method(method_name):
        call(method_name)  # 调用父节点指定的方法（子节点必须拥有此方法）
```

### 方法3：Callable 属性（更安全）

```gdscene
# 父节点 - 设置回调
$Child.callback = _my_custom_callback

func _my_custom_callback(data):
    print("回调被调用: ", data)

# 子节点 - 使用 Callable
@export var callback: Callable

func trigger():
    callback.call("some_data")  # 不需要知道方法的所属者
```

---

## 三、场景设计模式

### 3.1 组合模式（Composition）

将复杂实体分解为可复用的组件：

```
Player (CharacterBody2D)
├── Sprite2D (视觉)
├── CollisionShape2D (碰撞)
├── HealthComponent (血量逻辑)
├── InventoryComponent (背包逻辑)
└── InputComponent (输入处理)

Enemy (CharacterBody2D)
├── Sprite2D (不同的纹理)
├── CollisionShape2D (不同的形状)
├── HealthComponent (✅ 复用！)
├── AIComponent (AI逻辑，替代InputComponent)
└── LootDropComponent (掉落逻辑)
```

### 3.2 工厂模式（Factory）

动态创建实体：

```gdscene
# EntityFactory.gd
class_name EntityFactory

enum EntityType { PLAYER, ENEMY, NPC, PICKUP }

static func create(type: EntityType, position: Vector2) -> Node:
    match type:
        EntityType.PLAYER:
            return _create_player(position)
        EntityType.ENEMY:
            return _create_enemy(position)
        EntityType.PICKUP:
            return _create_pickup(position)
        _:
            push_error("未知实体类型: " + str(type))
            return null

static func _create_player(pos: Vector2) -> CharacterBody2D:
    var player = preload("res://scenes/player.tscn").instantiate()
    player.global_position = pos
    return player
```

### 3.3 状态机模式（State Machine）

管理复杂行为：

```gdscene
# StateMachine.gd
extends Node
class_name StateMachine

enum State { IDLE, RUN, JUMP, ATTACK, HURT, DIE }
var current_state: State = State.IDLE
var state_changed: Signal

func change_state(new_state: State):
    if new_state == current_state:
        return

    _exit_state(current_state)
    current_state = new_state
    _enter_state(current_state)
    state_changed.emit(current_state)

func _enter_state(state: State):
    match state:
        State.IDLE: $AnimationPlayer.play("idle")
        State.RUN: $AnimationPlayer.play("run")
        State.JUMP: $AnimationPlayer.play("jump")
        # ...

func _process(delta):
    match current_state:
        State.IDLE: _process_idle(delta)
        State.RUN: _process_run(delta)
        # ...
```

详见 [常见模式文档](20B_Common_Patterns.md)

---

## 四、节点选择指南

### 4.1 根节点选择

| 场景类型 | 推荐根节点 | 原因 |
|----------|-----------|------|
| **玩家角色** | `CharacterBody2D/3D` | 需要物理移动+碰撞 |
| **物理对象** | `RigidBody2D/3D` | 物理引擎控制 |
| **静态物体** | `StaticBody2D/3D` | 不动的碰撞体 |
| **UI界面** | `Control` | UI布局系统 |
| **纯逻辑** | `Node` | 无需渲染或物理 |
| **2D精灵** | `Node2D` 或 `AnimatedSprite2D` | 简单2D元素 |
| **3D物体** | `Node3D` | 3D变换支持 |

### 4.2 避免过度嵌套

```
❌ 过度嵌套（难维护）
Player
└── Body
    └── Torso
        └── Chest
            └── Armor
                └── Sprite2D

✅ 合理扁平化
Player
├── Sprite2D
├── CollisionShape2D
├── HealthComponent
└── InventoryComponent
```

---

## 五、数据通信最佳实践

### 5.1 向下通信（父→子）

```gdscene
# ✅ 推荐：使用属性或方法
$Child.health = 100
$Child.take_damage(20)

# ❌ 避免：直接操作内部状态
$Child.get_node("HealthBar").value = 50
```

### 5.2 向上通信（子→父）

```gdscene
# ✅ 推荐：使用信号
signal died
signal health_changed(new_health)

died.emit()
health_changed.emit(current_health)

# ⚠️ 可接受：通过 Callable 回调
@export var on_action: Callable

func do_something():
    on_action.call()

# ❌ 避免：直接引用父节点 get_parent().method()
```

### 5.3 平级通信（兄弟节点间）

```gdscene
# ✅ 推荐：通过共同父节点中转
# 或使用 Autoload 全局单例

# ✅ 推荐：使用自定义信号
signal item_picked_up(item_data)

# ❌ 避免：get_node("../Sibling").method()
```

---

## 六、资源与场景分离

### 6.1 原则

- **数据** → Resource（可复用数据容器）
- **行为/结构** → Scene（节点树）
- **外观** → Texture/Material/Mesh（资源）

### 6.2 示例

```gdscene
# WeaponData.gd (Resource)
class_name WeaponData extends Resource

@export var name: String
@export var damage: int
@export var fire_rate: float
@export var texture: Texture2D
@export var scene: PackedScene  # 武器的场景实例

# 使用
var sword = WeaponData.new()
sword.name = "Iron Sword"
sword.damage = 25
sword.fire_rate = 0.5
sword.texture = load("res://items/sword.png")
ResourceSaver.save(sword, "res://data/weapons/iron_sword.tres")

# 加载使用
var weapon_data = load("res://data/weapons/iron_sword.tres")
var weapon_instance = weapon_data.scene.instantiate()
add_child(weapon_instance)
```

---

## 七、完整示例：模块化敌人系统

```gdscene
# Enemy.gd (基础脚本)
extends CharacterBody2D
class_name Enemy

signal died(enemy)
signal took_damage(amount, current_hp, max_hp)
signal target_acquired(target)

@export var max_health: int = 100
@export var move_speed: float = 100.0
@export var detection_range: float = 200.0

var current_health: int
var is_alive: bool = true

func _ready():
    current_health = max_health

func take_damage(amount: int):
    if not is_alive:
        return

    current_health -= amount
    took_damage.emit(amount, current_health, max_health)

    if current_health <= 0:
        die()

func die():
    is_alive = false
    died.emit(self)
    queue_free()


# MeleeEnemy.gd (近战敌人)
extends Enemy

@export var attack_damage: int = 10
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0

var can_attack: bool = true


# RangedEnemy.gd (远程敌人)
extends Enemy

@export var bullet_scene: PackedScene
@export var fire_rate: float = 2.0
@export var bullet_speed: float = 300.0

@onready var shoot_timer := Timer.new()

func _ready():
    super._ready()
    shoot_timer.wait_time = fire_rate
    shoot_timer.timeout.connect(_shoot)
    add_child(shoot_timer)
    shoot_timer.start()

func _shoot():
    var direction = global_position.direction_to(target.global_position)
    var bullet = bullet_scene.instantiate()
    bullet.global_position = $Muzzle.global_position
    bullet.linear_velocity = direction * bullet_speed
    get_tree().current_scene.add_child(bullet)


# BossEnemy.gd (Boss敌人)
extends RangedEnemy

@export var phase_2_threshold: int = 50  # 血量低于50%进入二阶段
var current_phase: int = 1

func take_damage(amount: int):
    super.take_damage(amount)

    if current_phase == 1 and current_health <= phase_2_threshold:
        _enter_phase_2()

func _enter_phase_2():
    current_phase = 2
    fire_rate *= 1.5  # 攻击加快
    shoot_timer.wait_time = fire_rate
    # 视觉变化等...
```

---

## 八、场景组织检查清单

| 检查项 | 说明 |
|--------|------|
| ✅ **无硬编码路径** | 不使用绝对节点路径（如 `/root/Main/Player`） |
| ✅ **信号解耦** | 子→父通信使用信号 |
| ✅ **属性暴露** | 需要外部配置的数据用 @export |
| ✅ **职责单一** | 每个场景/脚本只做一件事 |
| ✅ **可独立运行** | 场景不依赖特定父节点结构 |
| ✅ **资源外置** | 数据用 Resource，便于修改和复用 |
| ✅ **命名清晰** | 节点和变量名能表达用途 |
| ✅ **适度扁平** | 避免过深嵌套（建议 ≤ 4层） |

---

## 九、参考链接

- [场景组织官方教程](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)
- [数据偏好](16B_Data_Preferences.md)
- [逻辑偏好](16C_Logic_Preferences.md)
- [Godot 接口设计](https://docs.godotengine.org/en/stable/tutorials/best_practices/godot_interfaces.html)
- [信号详解](03A_Signals_Detailed.md)
- [节点操作](02A_Node_Operations.md)
