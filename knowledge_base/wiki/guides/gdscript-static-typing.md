# GDScript 静态类型指南

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01E_Static_Typing.md](../../base/gdscript-reference/01E_Static_Typing.md)

---

## 📚 概述

静态类型在 GDScript 中提供错误检测、代码补全、性能提升和自文档化等优势。本指南详细介绍如何使用静态类型系统。

---

## 🎯 核心内容

### 1. 静态类型优势

- **错误检测**: 编译时发现更多错误，无需运行代码
- **代码补全**: 编辑器能提供更精确的自动完成
- **性能提升**: 使用优化的操作码，未来计划 JIT/AOT 编译
- **自文档化**: 类型提示让代码更易理解

### 2. 动态 vs 静态对比

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

> **⚠️ 踩坑点**: `:=` 推断类型后，变量类型固定，不能赋其他类型的值。

### 3. 类型注解语法

#### 变量类型注解
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

#### 常量类型注解
```gdscript
# 常量自动推断类型，但可以显式声明
const MOVE_SPEED: float = 50.0
const MAX_HEALTH: int = 100

# 类型数组需要显式声明
const NUMBERS: Array[int] = [1, 2, 3]
```

#### 参数类型注解
```gdscript
func heal(target: Node, amount: int) -> void:
    if target.has_method("heal"):
        target.heal(amount)

func calculate_damage(base: float, multiplier: float = 1.0) -> float:
    return base * multiplier
```

### 4. 可用类型提示

| 类型 | 说明 |
|------|------|
| `Variant` | 任意类型 |
| `void` | 仅用于返回类型，表示无返回值 |
| 内置类型 | `int`, `float`, `bool`, `String`, `Vector2`, `Vector3` 等 |
| 原生类 | `Node`, `Node2D`, `Area2D`, `Camera2D` 等 |
| 全局类 | 使用 `class_name` 注册的自定义类 |
| 内部类 | 脚本内定义的 `class` |
| 枚举 | 全局、原生或自定义命名枚举（实际是 `int`） |

#### 使用自定义类作为类型
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

### 5. 函数返回类型

#### 基本语法
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

#### 协变与逆变
继承方法时遵循里氏替换原则：
```gdscript
# 父类
func get_property(param: Label) -> Node:
    return null

# 子类 - 返回类型可以更具体（协变），参数可以更宽泛（逆变）
func get_property(param: Control) -> Node2D:
    return null
```

### 6. 类型数组与字典

#### 类型数组
```gdscript
var scores: Array[int] = [10, 20, 30]
var vehicles: Array[Node] = [$Car, $Plane]

for score in scores:
    print(score * 2)
```

> **⚠️ 踩坑点**: 嵌套类型（如 `Array[Array[int]]`）目前不支持。

#### 类型字典
```gdscript
# 类型字典 [键类型, 值类型]
var fruit_costs: Dictionary[String, int] = { "apple": 5, "orange": 10 }
```

### 7. 类型转换

#### 使用 as 关键字

```gdscript
var player := body as PlayerController
if not player:
    return
player.damage()
```

> **⚠️ 踩坑点**: `as` 转换失败时返回 `null`，不会报错。

#### 使用 is 关键字（更安全）

```gdscript
if body is not PlayerController:
    push_error("Bug: body is not PlayerController")
    return
```

#### 使用 as 声明自定义类型 (重要)

**规则**: 对于非 Godot 内置的自定义类类型，必须使用 `as` 关键字进行显式类型声明

**常见场景**:

```gdscript
# ✅ 从节点获取自定义脚本
var tower := $TowerNode as TowerScript
var enemy := get_node("Enemy") as EnemyScript

# ✅ 从信号回调中获取
func _on_area_entered(area: Area2D):
    var projectile := area as ProjectileScript
    if projectile:
        projectile.explode()

# ✅ 从数组中获取自定义对象
var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
for enemy_node in enemies:
    var enemy := enemy_node as EnemyScript
    if enemy:
        enemy.take_damage(10)

# ✅ 从字典中获取
var object_dict: Dictionary = {"tower": $TowerNode}
var tower := object_dict["tower"] as TowerScript
if tower:
    tower.attack()

# ✅ is + as 组合检查
func process_target(target: Node):
    if target is TowerScript:
        var tower := target as TowerScript
        tower.attack()
    else:
        push_error("目标类型错误")

# ❌ 避免：不使用 as，类型不明确
var tower = $TowerNode  # 类型不明确
```

**最佳实践**:
1. **始终使用 as**: 对于自定义类型，始终使用 `as` 显式声明
2. **配合 is 检查**: 关键代码使用 `is` 先检查类型
3. **错误处理**: 转换失败时使用 `push_error` 记录错误
4. **类型注解**: 变量声明时同时使用类型注解和 as
   ```gdscript
   var tower: TowerScript = $TowerNode as TowerScript
   ```

### 8. 安全行

安全行是编辑器功能，用于标识类型安全的代码行：
```gdscript
@onready var timer := $Timer as Timer      # 安全行（绿色）
@onready var node: Node = $Node            # 不安全行
```

> **⚠️ 踩坑点**: 安全行不一定代表更好的代码。如果节点类型改变，`as` 会静默返回 `null`，而直接类型声明会立即报错。

### 9. 常见不安全操作

#### 类型化全局方法替代
| 动态方法 | 类型化替代 |
|---------|-----------|
| `abs(x)` | `absf(x)`, `absi(x)` |
| `lerp(a, b, t)` | `lerpf(a, b, t)`, `Vector2.lerp()` |
| `clamp(x, min, max)` | `clampf()`, `clampi()` |

#### UNSAFE_PROPERTY_ACCESS 警告
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

## ✅ 最佳实践

1. **优先使用类型推断** - 简洁且类型明确
2. **显式声明复杂类型** - 如类型数组、字典
3. **使用 is 检查类型** - 比 as 更安全
4. **函数添加返回类型** - 提高代码可读性
5. **使用类型化全局方法** - 避免类型丢失

---

## 🔗 相关页面

### Base 层来源
- [01E_Static_Typing.md](../../base/gdscript-reference/01E_Static_Typing.md) - 完整静态类型文档

### Wiki 层相关
- [GDScript 基础语法](./gdscript-basics.md) - 基础语法
- [GDScript 类型系统](./gdscript-types.md) - 类型和变量
- [GDScript 代码规范](./gdscript-standards.md) - 代码风格

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
