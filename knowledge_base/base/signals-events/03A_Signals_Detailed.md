# Godot 4.x 信号系统详解

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst, instancing_with_signals.rst

---

## 目录

1. [信号概述](#1-信号概述)
2. [定义信号](#2-定义信号)
3. [发射信号](#3-发射信号)
4. [连接信号](#4-连接信号)
5. [断开信号](#5-断开信号)
6. [带参数的信号](#6-带参数的信号)
7. [信号解耦实践](#7-信号解耦实践)

---

## 1. 信号概述

### 1.1 什么是信号

信号是 Godot 的观察者模式实现，允许节点之间进行解耦通信：

- **发布者**：发射信号的节点
- **订阅者**：接收信号的节点

### 1.2 信号的优势

- 解耦：节点不需要知道彼此的存在
- 灵活：可以动态连接/断开
- 安全：避免直接调用可能为 null 的对象

---

## 2. 定义信号

### 2.1 使用 signal 关键字

```gdscript
extends Node

# 无参数信号
signal health_changed

# 带参数信号
signal score_changed(new_score)
signal enemy_died(enemy, position)
```

### 2.2 信号命名规范

使用过去时命名信号：

```gdscript
signal door_opened      # 正确
signal player_died      # 正确
signal open_door        # 不推荐
```

---

## 3. 发射信号

### 3.1 使用 emit()

```gdscript
signal health_changed(new_health)
signal score_changed

var health = 100

func take_damage(amount):
    health -= amount
    health_changed.emit(health)

func add_score(points):
    score_changed.emit()
```

### 3.2 emit 语法

```gdscript
# 无参数
my_signal.emit()

# 带参数
my_signal.emit(arg1, arg2)
```

---

## 4. 连接信号

### 4.1 在编辑器中连接

1. 选择节点
2. 切换到 Node 面板
3. 双击信号
4. 选择接收节点和方法

### 4.2 在代码中连接

```gdscript
func _ready():
    # 方式 1：使用 Callable
    button.pressed.connect(_on_button_pressed)
    
    # 方式 2：使用字符串（不推荐）
    button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
    print("按钮被按下")
```

### 4.3 连接选项

```gdscript
# 一次性连接（触发后自动断开）
signal.connect(callable, CONNECT_ONE_SHOT)

# 延迟连接（在空闲时调用）
signal.connect(callable, CONNECT_DEFERRED)

# 引用计数连接
signal.connect(callable, CONNECT_REFERENCE_COUNTED)
```

### 4.4 绑定额外参数

```gdscript
func _ready():
    # 绑定额外参数
    button.pressed.connect(_on_button_pressed.bind("Button1"))

func _on_button_pressed(button_name):
    print(button_name, " 被按下")
```

---

## 5. 断开信号

### 5.1 使用 disconnect()

```gdscript
func _ready():
    button.pressed.connect(_on_button_pressed)

func disable_button():
    button.pressed.disconnect(_on_button_pressed)
```

### 5.2 检查连接状态

```gdscript
if button.pressed.is_connected(_on_button_pressed):
    button.pressed.disconnect(_on_button_pressed)
```

---

## 6. 带参数的信号

### 6.1 定义和发射

```gdscript
signal enemy_spawned(enemy_type, position)

func spawn_enemy():
    var enemy = Enemy.new()
    enemy_spawned.emit("goblin", Vector2(100, 200))
```

### 6.2 接收参数

```gdscript
func _ready():
    spawner.enemy_spawned.connect(_on_enemy_spawned)

func _on_enemy_spawned(enemy_type, position):
    print("生成敌人：", enemy_type, " 在 ", position)
```

---

## 7. 信号解耦实践

### 7.1 问题：直接引用父节点

```gdscript
# 不推荐：直接使用 get_parent()
extends Sprite2D

var Bullet = preload("res://bullet.tscn")

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        var bullet = Bullet.instantiate()
        get_parent().add_child(bullet)  # 耦合！
```

**问题**：
- 无法独立测试 Player 场景
- 父节点结构变化会导致崩溃

### 7.2 解决方案：使用信号

```gdscript
# player.gd
extends Sprite2D

signal shoot(bullet, direction, location)

var Bullet = preload("res://bullet.tscn")

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        shoot.emit(Bullet, rotation, position)

# main.gd
extends Node

@onready var player = $Player

func _ready():
    player.shoot.connect(_on_player_shoot)

func _on_player_shoot(bullet, direction, location):
    var spawned = bullet.instantiate()
    add_child(spawned)
    spawned.rotation = direction
    spawned.position = location
```

### 7.3 信号解耦的优势

| 特性 | 直接引用 | 信号解耦 |
|------|----------|----------|
| 独立测试 | ❌ | ✅ |
| 灵活布局 | ❌ | ✅ |
| 代码耦合 | 高 | 低 |
| 维护成本 | 高 | 低 |

---

## 8. 内置信号

### 8.1 常用节点信号

| 节点 | 信号 | 说明 |
|------|------|------|
| `Button` | `pressed` | 按钮被点击 |
| `Timer` | `timeout` | 计时结束 |
| `Area2D` | `body_entered` | 物体进入 |
| `Area2D` | `body_exited` | 物体离开 |
| `Node` | `ready` | 节点准备完成 |
| `Node` | `tree_entered` | 进入场景树 |
| `Node` | `tree_exited` | 离开场景树 |

### 8.2 使用内置信号

```gdscript
func _ready():
    $Button.pressed.connect(_on_button_pressed)
    $Timer.timeout.connect(_on_timer_timeout)
    $Area2D.body_entered.connect(_on_body_entered)

func _on_button_pressed():
    print("按钮点击")

func _on_timer_timeout():
    print("计时结束")

func _on_body_entered(body):
    print("物体进入：", body.name)
```

---

## 9. await 关键字

### 9.1 等待信号

```gdscript
func _ready():
    await $Timer.timeout
    print("计时器完成")

func wait_for_signal():
    await some_signal
    print("信号已触发")
```

### 9.2 协程

```gdscript
func async_operation():
    print("开始操作")
    await get_tree().create_timer(1.0).timeout
    print("1秒后继续")
    await some_signal
    print("信号后继续")
```

> **踩坑点**：`await` 会暂停当前函数的执行，但不会阻塞游戏。其他函数继续正常运行。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst`
- 来源文件：`godot-docs-master/tutorials/scripting/instancing_with_signals.rst`
