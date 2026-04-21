# GDScript 常用模式指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 19B_Common_Patterns.md](../../base/quick-reference/19B_Common_Patterns.md)  
> **重要性**: 🟡 推荐 - 常用设计模式

---

## 📋 概述

本指南收集了 Godot 开发中的常用设计模式和最佳实践，帮助编写更优雅、可维护的代码。

---

## 🎯 常用模式

### 1. 单例模式（Autoload）

```gdscript
# GameManager.gd (自动加载)
extends Node

var score: int = 0
var player_name: String = ""

func add_score(points: int):
    score += points

func reset_game():
    score = 0
    player_name = ""

# 使用
GameManager.add_score(100)
```

### 2. 状态模式

```gdscript
# 状态基类
class_name State
extends Node

signal transition_requested(new_state: String)

func enter():
    pass

func exit():
    pass

func update(delta: float):
    pass

# 具体状态
class IdleState extends State:
    func enter():
        print("进入待机状态")
    
    func update(delta: float):
        if Input.is_action_pressed("move"):
            transition_requested.emit("walk")

# 状态机
class_name StateMachine
extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.transition_requested.connect(_on_transition)
    
    if initial_state:
        initial_state.enter()
        current_state = initial_state

func _process(delta):
    if current_state:
        current_state.update(delta)

func _on_transition(new_state: String):
    if states.has(new_state):
        current_state.exit()
        current_state = states[new_state]
        current_state.enter()
```

### 3. 观察者模式（信号）

```gdscript
# 被观察者
class_name Health
extends Node

signal health_changed(new_value: int)
signal died

var health: int = 100

func take_damage(amount: int):
    health = max(0, health - amount)
    health_changed.emit(health)
    
    if health == 0:
        died.emit()

# 观察者
func _ready():
    $Health.health_changed.connect(_on_health_changed)
    $Health.died.connect(_on_player_died)

func _on_health_changed(new_value: int):
    update_ui(new_value)

func _on_player_died():
    game_over()
```

### 4. 对象池模式

```gdscript
class_name ObjectPool
extends Node

var pool: Array[Node] = []
var scene: PackedScene

func _init(scene_to_pool: PackedScene, size: int):
    scene = scene_to_pool
    for i in range(size):
        var instance = scene.instantiate()
        instance.visible = false
        add_child(instance)
        pool.append(instance)

func get_instance() -> Node:
    for instance in pool:
        if not instance.visible:
            instance.visible = true
            return instance
    
    # 池已满，创建新实例
    var instance = scene.instantiate()
    add_child(instance)
    pool.append(instance)
    return instance

func return_instance(instance: Node):
    instance.visible = false
```

### 5. 组件模式

```gdscript
# 组件基类
class_name Component
extends Node

func _ready():
    pass

func _process(delta):
    pass

# 具体组件
class_name HealthComponent
extends Component

var health: int = 100

func take_damage(amount: int):
    health -= amount

# 使用组件的实体
class_name Player
extends CharacterBody2D

@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent

func _process(delta):
    health._process(delta)
    movement._process(delta)
```

---

## 🔗 相关资源

### Base 层
- [19B_Common_Patterns.md](../../base/quick-reference/19B_Common_Patterns.md) - 常用模式详解

### Wiki 层
- [GDScript 速查表](../guides/gdscript-cheatsheet.md) - 语法速查
- [常用 API 参考](../guides/api-commonly-used.md) - API 速查

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
