# 信号系统最佳实践指南

> **摘要**: Godot 4.x 信号系统的最佳实践、设计模式和常见陷阱  
> **来源**: [03A_Signals_Detailed.md](../../base/signals-events/03A_Signals_Detailed.md)  
> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+

---

## 🎯 核心原则

### 1. 解耦优先原则

**问题**: 直接引用父节点导致高耦合

```gdscript
# ❌ 不推荐：直接使用 get_parent()
extends Sprite2D

var Bullet = preload("res://bullet.tscn")

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        var bullet = Bullet.instantiate()
        get_parent().add_child(bullet)  # 耦合！
```

**问题**:
- 无法独立测试 Player 场景
- 父节点结构变化会导致崩溃
- 代码复用困难

**解决方案**: 使用信号解耦

```gdscript
# ✅ 推荐：使用信号
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

---

## 📋 命名规范

### 信号命名

**使用过去时态**命名信号，表示动作已完成：

```gdscript
# ✅ 正确
signal door_opened
signal player_died
signal health_changed
signal item_collected

# ❌ 不推荐
signal open_door
signal die_player
signal change_health
signal collect_item
```

### 信号处理函数命名

**使用 `_on_` 前缀** + 节点名 + 信号名：

```gdscript
func _on_button_pressed():
    pass

func _on_timer_timeout():
    pass

func _on_area_body_entered(body):
    pass
```

---

## 🔧 连接策略

### 1. 优先使用 Callable 连接

```gdscript
# ✅ 推荐：使用 Callable
func _ready():
    button.pressed.connect(_on_button_pressed)

# ❌ 不推荐：使用字符串（Godot 3.x 风格）
func _ready():
    connect("pressed", self, "_on_button_pressed")
```

### 2. 选择合适的连接选项

```gdscript
# 一次性连接 - 适用于成就系统、一次性事件
signal.connect(_on_achievement_unlocked, CONNECT_ONE_SHOT)

# 延迟连接 - 适用于需要在空闲时处理的事件
signal.connect(_on_heavy_computation, CONNECT_DEFERRED)

# 普通连接 - 默认选择
signal.connect(_on_normal_event)
```

### 3. 使用 bind() 传递额外参数

```gdscript
# 场景：多个按钮共享同一个处理函数
func _ready():
    $Button1.pressed.connect(_on_button_clicked.bind("Button1"))
    $Button2.pressed.connect(_on_button_clicked.bind("Button2"))
    $Button3.pressed.connect(_on_button_clicked.bind("Button3"))

func _on_button_clicked(button_name):
    print(button_name, " 被点击")
```

---

## 🛡️ 安全检查

### 1. 断开前检查连接状态

```gdscript
# ✅ 推荐：先检查再断开
if button.pressed.is_connected(_on_button_pressed):
    button.pressed.disconnect(_on_button_pressed)

# ❌ 不推荐：直接断开可能抛出异常
button.pressed.disconnect(_on_button_pressed)  # 未连接时会报错
```

### 2. 使用弱引用避免内存泄漏

```gdscript
# 场景：长时间存在的对象监听短生命周期对象
func _ready():
    # 使用 weak_ref 避免循环引用
    var weak_ref = weakref(some_object)
    some_object.some_signal.connect(_on_signal, CONNECT_REFERENCE_COUNTED)
```

---

## 🎨 设计模式应用

### 1. 全局事件总线

使用 Autoload 单例实现全局事件系统：

```gdscript
# global_events.gd (Autoload)
extends Node

# 定义全局事件
signal player_died
signal level_completed
signal game_paused
signal score_changed(new_score)

# 使用方法
# 在任何脚本中：
func _ready():
    GlobalEvents.player_died.connect(_on_player_died)
    GlobalEvents.score_changed.connect(_on_score_changed)
```

### 2. 状态机模式

```gdscript
# 状态机中的信号使用
extends Node

signal state_changed(old_state, new_state)

enum State { IDLE, RUNNING, JUMPING, ATTACKING }
var current_state = State.IDLE

func change_state(new_state):
    if current_state != new_state:
        var old_state = current_state
        current_state = new_state
        state_changed.emit(old_state, new_state)
```

### 3. 观察者模式

```gdscript
# 被观察者
class Subject:
    signal changed(data)
    
    func notify(data):
        changed.emit(data)

# 观察者
class Observer:
    func _ready():
        var subject = Subject.new()
        subject.changed.connect(_on_subject_changed)
    
    func _on_subject_changed(data):
        print("收到通知：", data)
```

---

## ⚡ 性能优化

### 1. 避免过度使用信号

```gdscript
# ❌ 不推荐：每帧发射信号（性能开销大）
func _process(delta):
    health_changed.emit(health)  # 每帧都发射

# ✅ 推荐：只在变化时发射
var _last_health = 100

func take_damage(amount):
    health -= amount
    if health != _last_health:
        health_changed.emit(health)
        _last_health = health
```

### 2. 使用 CONNECT_DEFERRED 优化密集调用

```gdscript
# 场景：短时间内多次触发信号
func take_damage(amount):
    health -= amount
    # 使用 DEFERRED 合并多次调用
    health_changed.connect(_on_health_changed, CONNECT_DEFERRED)
    health_changed.emit(health)
```

---

## 🐛 常见陷阱

### 1. 信号循环依赖

```gdscript
# ❌ 错误：循环触发
class A:
    signal changed
    func _ready():
        changed.connect(_on_changed)
    func _on_changed():
        changed.emit()  # 无限循环！

# ✅ 正确：添加状态检查
var _changing = false
func _on_changed():
    if _changing:
        return
    _changing = true
    # 处理逻辑
    _changing = false
```

### 2. 忘记断开连接

```gdscript
# ❌ 错误：对象销毁后仍有连接
func _ready():
    GlobalEvents.some_event.connect(_on_event)

# ✅ 正确：在 _exit_tree 断开连接
func _exit_tree():
    GlobalEvents.some_event.disconnect(_on_event)
```

### 3. 信号参数过多

```gdscript
# ❌ 不推荐：参数过多难以维护
signal complex_operation(a, b, c, d, e, f, g)

# ✅ 推荐：使用字典或资源对象
signal complex_operation(data: Dictionary)
# 或
signal complex_operation(config: OperationConfig)
```

---

## 📊 最佳实践检查清单

### 设计阶段
- [ ] 是否真的需要信号？（vs 直接调用）
- [ ] 信号命名是否使用过去时？
- [ ] 信号参数是否合理？（不超过 5 个）

### 实现阶段
- [ ] 是否使用 Callable 连接？
- [ ] 是否需要特殊连接选项？（ONE_SHOT/DEFERRED）
- [ ] 是否需要绑定额外参数？

### 测试阶段
- [ ] 信号是否在适当时机发射？
- [ ] 连接是否正确建立？
- [ ] 是否在对象销毁时断开连接？

### 维护阶段
- [ ] 是否有未使用的信号？
- [ ] 是否有循环依赖风险？
- [ ] 信号性能是否可接受？

---

## 🔗 相关资源

### Wiki 页面
- [信号系统概念](./signals-events.md) - 核心概念和语法
- [场景树](./scene-tree.md) - 节点生命周期
- [单例模式](./autoload-singletons.md) - 全局事件总线

### Base 层文档
- [03A_Signals_Detailed.md](../../base/signals-events/03A_Signals_Detailed.md) - 完整原始文档

---

## 📝 来源引用

本文档内容基于 Base 层原始文档整理：
- **来源**: [03A_Signals_Detailed.md](../../base/signals-events/03A_Signals_Detailed.md)
- **原始来源**: 
  - `godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst`
  - `godot-docs-master/tutorials/scripting/instancing_with_signals.rst`

---

**创建日期**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**Wiki 版本**: 1.0
