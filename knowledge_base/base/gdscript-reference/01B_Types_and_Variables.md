# GDScript 类型和变量

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst

---

## 目录

1. [内置类型概述](#1-内置类型概述)
2. [基本类型](#2-基本类型)
3. [向量类型](#3-向量类型)
4. [引擎类型](#4-引擎类型)
5. [容器类型](#5-容器类型)
6. [变量定义](#6-变量定义)
7. [常量](#7-常量)
8. [枚举](#8-枚举)
9. [类型转换](#9-类型转换)

---

## 1. 内置类型概述

### 1.1 值类型 vs 引用类型

**值类型（栈分配，传递时复制）**：
- 基本类型：`int`, `float`, `bool`, `String`
- 向量类型：`Vector2`, `Vector3`, `Transform2D` 等
- `Color`, `RID`

**引用类型（传递时共享引用）**：
- `Object` 及其子类
- `Array`, `Dictionary`
- Packed Arrays

```gdscript
# 值类型 - 复制
var a = 5
var b = a
b = 10
print(a)  # 5（未改变）

# 引用类型 - 共享
var arr1 = [1, 2, 3]
var arr2 = arr1
arr2[0] = 99
print(arr1)  # [99, 2, 3]（改变了）
```

---

## 2. 基本类型

### 2.1 null

空类型，只能赋值给继承自 Object 的类型。

```gdscript
var node: Node = null  # 有效
var num: int = null    # 无效！int 不能为 null
```

### 2.2 bool

布尔值，只能是 `true` 或 `false`。

```gdscript
var is_active: bool = true
var is_valid = false
```

### 2.3 int

64 位有符号整数。

```gdscript
var a: int = 42
var b = -100
var hex = 0xff    # 十六进制
var bin = 0b1010  # 二进制
```

### 2.4 float

64 位双精度浮点数。

```gdscript
var a: float = 3.14
var b = 1.0e-10
var c = 42.0
```

> **踩坑点**：`Vector2`, `Vector3`, `PackedFloat32Array` 内部使用 32 位单精度浮点数。

### 2.5 String

Unicode 字符串。

```gdscript
var s1 = "Hello"
var s2 = 'World'
var multi = """
多行
字符串
"""
var raw = r"C:\path\to\file"  # 原始字符串，不处理转义
```

### 2.6 StringName

不可变字符串，比较速度极快，适合做字典键。

```gdscript
var name: StringName = &"player_name"
```

### 2.7 NodePath

预解析的节点路径。

```gdscript
var path: NodePath = ^"Sprite2D"
```

---

## 3. 向量类型

### 3.1 Vector2 / Vector2i

```gdscript
var v2 = Vector2(1.0, 2.0)
var v2i = Vector2i(1, 2)  # 整数版本，适合网格坐标

print(v2.x, v2.y)  # 访问分量
print(v2[0], v2[1])  # 数组方式访问
```

### 3.2 Vector3 / Vector3i

```gdscript
var v3 = Vector3(1.0, 2.0, 3.0)
var v3i = Vector3i(1, 2, 3)
```

### 3.3 Rect2

2D 矩形。

```gdscript
var rect = Rect2(Vector2(0, 0), Vector2(100, 50))
print(rect.position)  # 位置
print(rect.size)      # 尺寸
print(rect.end)       # position + size
```

### 3.4 Transform2D

3×2 矩阵，用于 2D 变换。

```gdscript
var t = Transform2D.IDENTITY
t = t.rotated(PI / 4)
t = t.scaled(Vector2(2, 2))
```

### 3.5 3D 相关类型

| 类型 | 说明 |
|------|------|
| `Plane` | 3D 平面 |
| `Quaternion` | 四元数旋转 |
| `AABB` | 轴对齐包围盒 |
| `Basis` | 3×3 矩阵（旋转和缩放） |
| `Transform3D` | 3D 变换 |

---

## 4. 引擎类型

### 4.1 Color

颜色，包含 r, g, b, a 分量。

```gdscript
var c = Color(1.0, 0.5, 0.0)  # RGB
var c2 = Color(1.0, 0.5, 0.0, 0.5)  # RGBA
var c3 = Color.RED  # 预定义颜色

# 也可以通过 HSV 访问
print(c.h, c.s, c.v)
```

### 4.2 RID

资源 ID，服务器使用。

```gdscript
var rid = RenderingServer.texture_create()
```

### 4.3 Object

所有非内置类型的基类。

```gdscript
var obj = Object.new()
```

---

## 5. 容器类型

### 5.1 Array

动态数组。

```gdscript
var arr = []
arr = [1, 2, 3]
arr.append(4)
arr[0] = "Hi"
print(arr[-1])  # 最后一个元素
```

### 5.2 类型数组

```gdscript
var ints: Array[int] = [1, 2, 3]
var nodes: Array[Node] = []
var items: Array[Item] = []

# 类型数组不能直接赋值不同类型
var a: Array[Node2D] = [Node2D.new()]
var b: Array[Node] = []
# b = a  # 错误！
b.assign(a)  # 正确：复制内容
```

> **踩坑点**：类型数组之间不能直接赋值，即使类型兼容。使用 `assign()` 方法复制内容。

### 5.3 Packed Arrays

紧凑数组，性能更好，内存更少。

| 类型 | 说明 |
|------|------|
| `PackedByteArray` | 字节数组 |
| `PackedInt32Array` | 32位整数数组 |
| `PackedInt64Array` | 64位整数数组 |
| `PackedFloat32Array` | 32位浮点数组 |
| `PackedFloat64Array` | 64位浮点数组 |
| `PackedStringArray` | 字符串数组 |
| `PackedVector2Array` | Vector2 数组 |
| `PackedVector3Array` | Vector3 数组 |
| `PackedColorArray` | Color 数组 |

```gdscript
var packed = PackedInt32Array([1, 2, 3])
packed.push_back(4)
```

### 5.4 Dictionary

字典（关联数组）。

```gdscript
var d = {
    "name": "Player",
    "level": 5,
    42: "answer"
}

# 两种访问方式
print(d["name"])
print(d.name)  # 仅限字符串键

# Lua 风格语法
var d2 = {
    name = "Enemy",
    health = 100
}

# 类型字典（Godot 4.4+）
var typed_dict: Dictionary[String, int] = {}
```

---

## 6. 变量定义

### 6.1 基本语法

```gdscript
var a           # 默认为 null
var b = 5       # 推断类型
var c: int      # 显式类型
var d: int = 5  # 显式类型 + 初始值
var e := 5      # 类型推断（推荐）
```

### 6.2 初始化顺序

成员变量按以下顺序初始化：

1. 根据静态类型设置默认值（null 或类型默认值）
2. 按脚本中从上到下的顺序赋值
3. 调用 `_init()`
4. 导出值赋值
5. `@onready` 变量初始化
6. 调用 `_ready()`

```gdscript
var a = proxy("a", 1)  # 先初始化
var b = proxy("b", 2)  # 后初始化
var _data = {}         # 必须在 a 之前定义才能在 proxy 中使用

func proxy(key, value):
    _data[key] = value
    return value
```

> **踩坑点**：变量初始化顺序很重要，确保依赖的变量先定义。

### 6.3 静态变量

```gdscript
class_name Person

static var max_id = 0

var id
var name

func _init(p_name):
    max_id += 1
    id = max_id
    name = p_name
```

静态变量属于类，所有实例共享：

```gdscript
var p1 = Person.new("John")
var p2 = Person.new("Jane")
print(Person.max_id)  # 2
print(p1.max_id)      # 2（不推荐这样访问）
```

> **踩坑点**：`@export` 和 `@onready` 不能应用于静态变量。

---

## 7. 常量

### 7.1 基本语法

```gdscript
const A = 5
const B = Vector2(20, 20)
const C = 10 + 20  # 常量表达式
const D = sin(20)  # 内置函数可在常量表达式中使用

# 显式类型
const PI_VALUE: float = 3.14159
```

### 7.2 常量限制

```gdscript
const A = 5
A = 10  # 错误！常量不可修改

var x = 5
const B = x  # 错误！非常量表达式
```

---

## 8. 枚举

### 8.1 匿名枚举

```gdscript
enum {TILE_BRICK, TILE_FLOOR, TILE_SPIKE, TILE_TELEPORT}
# 等价于：
# const TILE_BRICK = 0
# const TILE_FLOOR = 1
# const TILE_SPIKE = 2
# const TILE_TELEPORT = 3
```

### 8.2 命名枚举

```gdscript
enum State {STATE_IDLE, STATE_JUMP = 5, STATE_SHOOT}
# 等价于：
# const State = {STATE_IDLE = 0, STATE_JUMP = 5, STATE_SHOOT = 6}

print(State.STATE_JUMP)  # 5
print(State.keys())      # ["STATE_IDLE", "STATE_JUMP", "STATE_SHOOT"]
print(State.values())    # [0, 5, 6]
```

> **踩坑点**：命名枚举的键不是全局常量，必须通过枚举名访问（`State.STATE_IDLE`）。

---

## 9. 类型转换

### 9.1 使用 as

```gdscript
# 对象类型转换
var my_node = $Sprite2D as Node2D  # 成功
var my_node2 = $Button as Node2D   # 返回 null（类型不匹配）

# 内置类型强制转换
var my_int = "123" as int  # 123
var my_float = 42 as float  # 42.0
```

> **踩坑点**：`as` 转换失败时返回 `null`，可能导致后续代码出错。使用 `is` 检查更安全。

### 9.2 使用 is 检查

```gdscript
func process(node: Node):
    if node is Sprite2D:
        var sprite: Sprite2D = node
        sprite.texture = load("res://icon.png")
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst`
