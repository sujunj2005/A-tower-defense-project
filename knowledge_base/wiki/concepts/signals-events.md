# 信号系统核心概念

> **摘要**: Godot 4.x 信号系统的核心概念和机制详解  
> **来源**: [03A_Signals_Detailed.md](../../base/signals-events/03A_Signals_Detailed.md)  
> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+

---

## 📖 概念概述

**信号（Signal）** 是 Godot 引擎的**观察者模式**实现，允许节点之间进行**解耦通信**。

### 核心角色

```
┌─────────────┐                    ┌─────────────┐
│   发布者     │ ─── 信号 ───>     │   订阅者     │
│  (Publisher)│   发射/连接        │  (Subscriber)│
└─────────────┘                    └─────────────┘
```

- **发布者**: 发射信号的节点
- **订阅者**: 接收信号的节点

---

## 🎯 信号的优势

| 优势 | 说明 |
|------|------|
| **解耦** | 节点不需要知道彼此的存在，降低耦合度 |
| **灵活** | 可以动态连接/断开，运行时修改行为 |
| **安全** | 避免直接调用可能为 null 的对象 |

---

## 🔧 信号的三大操作

### 1. 定义信号 (Define)

使用 `signal` 关键字定义信号：

```gdscript
extends Node

# 无参数信号
signal health_changed

# 带参数信号
signal score_changed(new_score)
signal enemy_died(enemy, position)
```

**命名规范**: 使用**过去时**命名信号
- ✅ `signal door_opened` - 正确
- ✅ `signal player_died` - 正确
- ❌ `signal open_door` - 不推荐

### 2. 发射信号 (Emit)

使用 `emit()` 方法发射信号：

```gdscript
var health = 100

func take_damage(amount):
    health -= amount
    health_changed.emit(health)  # 发射带参数信号

func add_score(points):
    score_changed.emit()  # 发射无参数信号
```

**语法**:
```gdscript
# 无参数
my_signal.emit()

# 带参数
my_signal.emit(arg1, arg2)
```

### 3. 连接信号 (Connect)

使用 `connect()` 方法连接信号：

```gdscript
func _ready():
    # 方式 1：使用 Callable（推荐）
    button.pressed.connect(_on_button_pressed)
    
func _on_button_pressed():
    print("按钮被按下")
```

**连接选项**:
```gdscript
# 一次性连接（触发后自动断开）
signal.connect(callable, CONNECT_ONE_SHOT)

# 延迟连接（在空闲时调用）
signal.connect(callable, CONNECT_DEFERRED)

# 引用计数连接
signal.connect(callable, CONNECT_REFERENCE_COUNTED)
```

**绑定额外参数**:
```gdscript
func _ready():
    button.pressed.connect(_on_button_pressed.bind("Button1"))

func _on_button_pressed(button_name):
    print(button_name, " 被按下")
```

---

## 🔌 断开信号

使用 `disconnect()` 方法断开信号连接：

```gdscript
func _ready():
    button.pressed.connect(_on_button_pressed)

func disable_button():
    button.pressed.disconnect(_on_button_pressed)
```

**检查连接状态**:
```gdscript
if button.pressed.is_connected(_on_button_pressed):
    button.pressed.disconnect(_on_button_pressed)
```

---

## ⚙️ await 关键字

### 等待信号

`await` 关键字可以暂停函数执行，等待信号触发：

```gdscript
func _ready():
    await $Timer.timeout
    print("计时器完成")

func wait_for_signal():
    await some_signal
    print("信号已触发")
```

### 协程

```gdscript
func async_operation():
    print("开始操作")
    await get_tree().create_timer(1.0).timeout
    print("1 秒后继续")
    await some_signal
    print("信号后继续")
```

> **⚠️ 踩坑点**: `await` 会暂停当前函数的执行，但**不会阻塞游戏**。其他函数继续正常运行。

---

## 📚 常用内置信号

| 节点 | 信号 | 说明 |
|------|------|------|
| `Button` | `pressed` | 按钮被点击 |
| `Timer` | `timeout` | 计时结束 |
| `Area2D` | `body_entered` | 物体进入 |
| `Area2D` | `body_exited` | 物体离开 |
| `Node` | `ready` | 节点准备完成 |
| `Node` | `tree_entered` | 进入场景树 |
| `Node` | `tree_exited` | 离开场景树 |

**使用示例**:
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

## 🔗 相关概念

- [场景树](./scene-tree.md) - 节点的生命周期和信号触发时机
- [资源系统](./resources-system.md) - 资源加载完成信号
- [单例模式](./autoload-singletons.md) - 全局事件总线实现

---

## 📊 核心概念对比

### 信号通信 vs 直接引用

| 特性 | 直接引用 | 信号通信 |
|------|----------|----------|
| **耦合度** | 高耦合 | 低耦合 |
| **灵活性** | 低 | 高 |
| **安全性** | 依赖对象存在 | 不依赖对象 |
| **可测试性** | 难测试 | 易测试 |
| **维护成本** | 高 | 低 |

---

## 🎯 关键要点总结

1. **信号是观察者模式**: 发布/订阅模式实现
2. **三大操作**: 定义 (signal) → 发射 (emit) → 连接 (connect)
3. **命名规范**: 使用过去时（opened, died, changed）
4. **解耦优势**: 节点间不需要知道彼此存在
5. **await 支持**: 可以用 await 等待信号，实现协程
6. **内置信号**: Godot 节点提供丰富的内置信号

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
