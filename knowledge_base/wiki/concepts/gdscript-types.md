# GDScript 类型系统摘要

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01B_Types_and_Variables.md](../../base/gdscript-reference/01B_Types_and_Variables.md)

---

## 📚 概述

GDScript 支持动态类型和静态类型。理解内置类型、值类型 vs 引用类型的差异对于编写高效代码至关重要。

---

## 🎯 核心内容

### 1. 值类型 vs 引用类型

#### 值类型（栈分配，传递时复制）
- 基本类型：`int`, `float`, `bool`, `String`
- 向量类型：`Vector2`, `Vector3`, `Transform2D` 等
- `Color`, `RID`

```gdscript
var a = 5
var b = a
b = 10
print(a)  # 5（未改变）
```

#### 引用类型（传递时共享引用）
- `Object` 及其子类
- `Array`, `Dictionary`
- Packed Arrays

```gdscript
var arr1 = [1, 2, 3]
var arr2 = arr1
arr2[0] = 99
print(arr1)  # [99, 2, 3]（改变了）
```

### 2. 基本类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `null` | 空值，只能赋值给 Object 类型 | `var node: Node = null` |
| `bool` | 布尔值（true/false） | `var is_active: bool = true` |
| `int` | 64 位有符号整数 | `var a: int = 42` |
| `float` | 64 位双精度浮点数 | `var b: float = 3.14` |
| `String` | Unicode 字符串 | `var s = "Hello"` |
| `StringName` | 不可变字符串，比较极快 | `var name: StringName = &"player"` |
| `NodePath` | 预解析的节点路径 | `var path: NodePath = ^"Sprite2D"` |

### 3. 向量类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `Vector2` / `Vector2i` | 2D 向量/整数向量 | `var v2 = Vector2(1.0, 2.0)` |
| `Vector3` / `Vector3i` | 3D 向量/整数向量 | `var v3 = Vector3(1.0, 2.0, 3.0)` |
| `Rect2` | 2D 矩形 | `var rect = Rect2(Vector2(0, 0), Vector2(100, 50))` |
| `Transform2D` | 2D 变换矩阵 | `var t = Transform2D.IDENTITY.rotated(PI / 4)` |
| `Plane` | 3D 平面 | - |
| `Quaternion` | 四元数旋转 | - |
| `Basis` | 3×3 矩阵 | - |
| `Transform3D` | 3D 变换 | - |

### 4. 容器类型

#### Array（动态数组）
```gdscript
var arr = []
arr = [1, 2, 3]
arr.append(4)
arr[0] = "Hi"
print(arr[-1])  # 最后一个元素
```

#### 类型数组
```gdscript
var ints: Array[int] = [1, 2, 3]
var nodes: Array[Node] = []

# ⚠️ 踩坑点：类型数组不能直接赋值
var a: Array[Node2D] = [Node2D.new()]
var b: Array[Node] = []
# b = a  # 错误！
b.assign(a)  # 正确：复制内容
```

#### Packed Arrays（紧凑数组，性能更好）
| 类型 | 说明 |
|------|------|
| `PackedByteArray` | 字节数组 |
| `PackedInt32Array` / `PackedInt64Array` | 整数数组 |
| `PackedFloat32Array` / `PackedFloat64Array` | 浮点数组 |
| `PackedStringArray` | 字符串数组 |
| `PackedVector2Array` / `PackedVector3Array` | 向量数组 |
| `PackedColorArray` | 颜色数组 |

#### Dictionary（字典）
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

### 5. 变量定义

```gdscript
var a           # 默认为 null
var b = 5       # 推断类型
var c: int      # 显式类型
var d: int = 5  # 显式类型 + 初始值
var e := 5      # 类型推断（推荐）
```

#### 初始化顺序
1. 根据静态类型设置默认值
2. 按脚本中从上到下的顺序赋值
3. 调用 `_init()`
4. 导出值赋值
5. `@onready` 变量初始化
6. 调用 `_ready()`

> **⚠️ 踩坑点**: 变量初始化顺序很重要，确保依赖的变量先定义。

#### 静态变量
```gdscript
class_name Person

static var max_id = 0

var id
var name

func _init(p_name):
    max_id += 1
    id = max_id
    name = p_name

# ⚠️ 踩坑点：@export 和 @onready 不能应用于静态变量
```

### 6. 常量

```gdscript
const A = 5
const B = Vector2(20, 20)
const C = 10 + 20  # 常量表达式
const D = sin(20)  # 内置函数可在常量表达式中使用

# ⚠️ 踩坑点：常量不可修改
const A = 5
A = 10  # 错误！

# ⚠️ 踩坑点：常量必须由常量表达式初始化
var x = 5
const B = x  # 错误！非常量表达式
```

### 7. 枚举

#### 匿名枚举
```gdscript
enum {TILE_BRICK, TILE_FLOOR, TILE_SPIKE, TILE_TELEPORT}
# 等价于：
# const TILE_BRICK = 0
# const TILE_FLOOR = 1
# ...
```

#### 命名枚举
```gdscript
enum State {STATE_IDLE, STATE_JUMP = 5, STATE_SHOOT}
# 等价于：
# const State = {STATE_IDLE = 0, STATE_JUMP = 5, STATE_SHOOT = 6}

print(State.STATE_JUMP)  # 5
print(State.keys())      # ["STATE_IDLE", "STATE_JUMP", "STATE_SHOOT"]
print(State.values())    # [0, 5, 6]
```

> **⚠️ 踩坑点**: 命名枚举的键不是全局常量，必须通过枚举名访问（`State.STATE_IDLE`）。

### 8. 类型转换

#### 使用 as
```gdscript
var my_node = $Sprite2D as Node2D  # 成功
var my_node2 = $Button as Node2D   # 返回 null（类型不匹配）

# ⚠️ 踩坑点：as 转换失败时返回 null，可能导致后续代码出错
```

#### 使用 is 检查（更安全）
```gdscript
func process(node: Node):
    if node is Sprite2D:
        var sprite: Sprite2D = node
        sprite.texture = load("res://icon.png")
```

---

## 🔗 相关页面

### Base 层来源
- [01B_Types_and_Variables.md](../../base/gdscript-reference/01B_Types_and_Variables.md) - 完整类型和变量文档

### Wiki 层相关
- [GDScript 基础语法](./gdscript-basics.md) - 基础语法
- [GDScript 函数](./gdscript-functions.md) - 函数定义
- [GDScript 静态类型指南](../../wiki/guides/gdscript-static-typing.md) - 类型注解

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
