# Godot 4.x 常用代码模式

> 适用版本：Godot 4.x | 来源：知识库整合

---

## 目录

1. [单例模式](#1-单例模式)
2. [状态机模式](#2-状态机模式)
3. [观察者/信号模式](#3-观察者信号模式)
4. [对象池模式](#4-对象池模式)
5. [工厂模式](#5-工厂模式)

---

## 1. 单例模式

### Autoload 单例
```gdscript
# global.gd (Autoload)
extends Node

static var instance: Node = null
var score: int = 0

func _ready():
    instance = self

static func add_score(points: int):
    instance.score += points
```

### 使用
```gdscript
Global.add_score(100)
print(Global.score)
```

---

## 2. 状态机模式

### 基础状态机
```gdscript
enum State { IDLE, RUN, JUMP, ATTACK }

var current_state: State = State.IDLE

func change_state(new_state: State):
    exit_state(current_state)
    current_state = new_state
    enter_state(current_state)

func enter_state(state: State):
    match state:
        State.IDLE: $AnimationPlayer.play("idle")
        State.RUN: $AnimationPlayer.play("run")
        State.JUMP: $AnimationPlayer.play("jump")
        State.ATTACK: $AnimationPlayer.play("attack")

func _physics_process(delta):
    match current_state:
        State.IDLE: handle_idle(delta)
        State.RUN: handle_run(delta)
        State.JUMP: handle_jump(delta)
        State.ATTACK: handle_attack(delta)
```

---

## 3. 观察者/信号模式

### 解耦通信
```gdscript
# emitter.gd
signal health_changed(new_health: int)
signal died

var health: int = 100:
    set(value):
        health = value
        health_changed.emit(health)
        if health <= 0:
            died.emit()

# observer.gd
func _ready():
    player.health_changed.connect(_on_health_changed)
    player.died.connect(_on_player_died)

func _on_health_changed(value: int):
    update_health_bar(value)

func _on_player_died():
    show_game_over()
```

---

## 4. 对象池模式

### 子弹对象池
```gdscript
class_name BulletPool extends Node

@export var bullet_scene: PackedScene
@export var pool_size: int = 20

var available: Array[Node] = []
var in_use: Array[Node] = []

func _ready():
    for i in pool_size:
        var bullet = bullet_scene.instantiate()
        bullet.visible = false
        add_child(bullet)
        available.append(bullet)

func get_bullet() -> Node:
    if available.size() > 0:
        var bullet = available.pop_back()
        in_use.append(bullet)
        return bullet
    return null

func return_bullet(bullet: Node):
    bullet.visible = false
    in_use.erase(bullet)
    available.append(bullet)
```

---

## 5. 工厂模式

### 场景工厂
```gdscript
class_name EnemyFactory extends RefCounted

enum EnemyType { GOBLIN, SKELETON, DRAGON }

const ENEMY_SCENES = {
    EnemyType.GOBLIN: preload("res://enemies/goblin.tscn"),
    EnemyType.SKELETON: preload("res://enemies/skeleton.tscn"),
    EnemyType.DRAGON: preload("res://enemies/dragon.tscn"),
}

static func create(type: EnemyType) -> Node:
    if type in ENEMY_SCENES:
        return ENEMY_SCENES[type].instantiate()
    push_error("Unknown enemy type: %s" % type)
    return null
```

### 使用
```gdscript
var goblin = EnemyFactory.create(EnemyFactory.EnemyType.GOBLIN)
add_child(goblin)
```

---

## 更多模式

| 模式 | 适用场景 |
|------|----------|
| **组件模式** | 将功能拆分为独立脚本 |
| **命令模式** | 撤销/重做系统 |
| **策略模式** | 不同 AI 行为 |
| **装饰器模式** | 动态添加能力 |
| **MVC 模式** | 数据-视图分离 |

---
*此文档为常用设计模式的 Godot 实现参考。*
