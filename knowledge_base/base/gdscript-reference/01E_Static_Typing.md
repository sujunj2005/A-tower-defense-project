# GDScript Godot 4.x 静态类型系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/gdscript/static_typing.rst

---

## 目录

1. [静态类型概述](#1-静态类型概述)
2. [类型注解语法](#2-类型注解语法)
3. [可用类型提示](#3-可用类型提示)
4. [函数返回类型](#4-函数返回类型)
5. [类型数组与字典](#5-类型数组与字典)
6. [类型转换](#6-类型转换)
7. [安全行](#7-安全行)
8. [常见不安全操作](#8-常见不安全操作)

---

## 1. 静态类型概述

### 1.1 优势

静态类型在 GDScript 中提供以下好处：
- **错误检测**：编译时发现更多错误，无需运行代码
- **代码补全**：编辑器能提供更精确的自动完成
- **性能提升**：使用优化的操作码，未来计划 JIT/AOT 编译
- **自文档化**：类型提示让代码更易理解

### 1.2 动态 vs 静态对比

```gdscript
# 动态类型
var damage = 10.5
func sum(a, b):
    return a + b

# 静态类型
var damage: float = 10.5
func sum(a: float, b: float) -> float:
    return a + b

# 类型推断（推荐）
var damage := 10.5
func sum(a := 0.0, b := 0.0) -> float:
    return a + b
```

> **踩坑点**：`:=` 推断类型后，变量类型固定，不能赋其他类型的值。

---

## 2. 类型注解语法

### 2.1 变量类型注解

```gdscript
# 显式类型
var health: int = 100
var speed: float = 5.5
var name: String = "Player"
var position: Vector2 = Vector2.ZERO

# 类型推断
var health := 100        # 推断为 int
var speed := 5.5         # 推断为 float
var name := "Player"     # 推断为 String
```

### 2.2 常量类型注解

```gdscript
# 常量自动推断类型，但可以显式声明
const MOVE_SPEED: float = 50.0
const MAX_HEALTH: int = 100

# 类型数组需要显式声明
const NUMBERS: Array[int] = [1, 2, 3]
```

### 2.3 参数类型注解

```gdscript
func heal(target: Node, amount: int) -> void:
    if target.has_method("heal"):
        target.heal(amount)

func calculate_damage(base: float, multiplier: float = 1.0) -> float:
    return base * multiplier
```

---

## 3. 可用类型提示

### 3.1 完整类型列表

| 类型 | 说明 |
|------|------|
| `Variant` | 任意类型 |
| `void` | 仅用于返回类型，表示无返回值 |
| 内置类型 | `int`, `float`, `bool`, `String`, `Vector2`, `Vector3` 等 |
| 原生类 | `Node`, `Node2D`, `Area2D`, `Camera2D` 等 |
| 全局类 | 使用 `class_name` 注册的自定义类 |
| 内部类 | 脚本内定义的 `class` |
| 枚举 | 全局、原生或自定义命名枚举（实际是 `int`） |

### 3.2 使用自定义类作为类型

```gdscript
# 方法 1：预加载
const Rifle = preload("res://weapons/rifle.gd")
var my_rifle: Rifle

# 方法 2：使用 class_name（推荐）
class_name Rifle
extends Node2D

# 其他脚本中直接使用
var my_rifle: Rifle
```

---

## 4. 函数返回类型

### 4.1 基本语法

使用 `->` 箭头指定返回类型：

```gdscript
func get_health() -> int:
    return health

func is_alive() -> bool:
    return health > 0

# void 表示无返回值
func apply_damage(amount: int) -> void:
    health -= amount
```

### 4.2 协变与逆变

继承方法时遵循里氏替换原则：

```gdscript
# 父类
func get_property(param: Label) -> Node:
    return null

# 子类 - 返回类型可以更具体（协变），参数可以更宽泛（逆变）
func get_property(param: Control) -> Node2D:
    return null
```

---

## 5. 类型数组与字典

### 5.1 类型数组

```gdscript
var scores: Array[int] = [10, 20, 30]
var vehicles: Array[Node] = [$Car, $Plane]

for score in scores:
    print(score * 2)
```

> **踩坑点**：嵌套类型（如 `Array[Array[int]]`）目前不支持。

### 5.2 类型字典

```gdscript
# 类型字典 [键类型, 值类型]
var fruit_costs: Dictionary[String, int] = { "apple": 5, "orange": 10 }
```

---

## 6. 类型转换

### 6.1 使用 as 关键字

```gdscript
var player := body as PlayerController
if not player:
    return
player.damage()
```

> **踩坑点**：`as` 转换失败时返回 `null`，不会报错。

### 6.2 使用 is 关键字（更安全）

```gdscript
if body is not PlayerController:
    push_error("Bug: body is not PlayerController")
    return
```

---

## 7. 安全行

安全行是编辑器功能，用于标识类型安全的代码行：

```gdscript
@onready var timer := $Timer as Timer      # 安全行（绿色）
@onready var node: Node = $Node            # 不安全行
```

> **踩坑点**：安全行不一定代表更好的代码。如果节点类型改变，`as` 会静默返回 `null`，而直接类型声明会立即报错。

---

## 8. 常见不安全操作

### 8.1 类型化全局方法替代

| 动态方法 | 类型化替代 |
|---------|-----------|
| `abs(x)` | `absf(x)`, `absi(x)` |
| `lerp(a, b, t)` | `lerpf(a, b, t)`, `Vector2.lerp()` |
| `clamp(x, min, max)` | `clampf()`, `clampi()` |

### 8.2 UNSAFE_PROPERTY_ACCESS 警告

```gdscript
# 不安全：属性可能不存在
if "some_property" in node_2d:
    node_2d.some_property = 20  # 警告

# 安全：先检查类型
if node_2d is MyScript:
    var my_script: MyScript = node_2d
    my_script.some_property = 20
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/gdscript/static_typing.rst`
