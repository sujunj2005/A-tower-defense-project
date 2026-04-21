# GDScript 类与继承

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst

---

## 目录

1. [类定义](#1-类定义)
2. [继承](#2-继承)
3. [构造函数](#3-构造函数)
4. [内部类](#4-内部类)
5. [抽象类](#5-抽象类)
6. [属性（Setter/Getter）](#6-属性settergetter)

---

## 1. 类定义

### 1.1 文件即类

每个 GDScript 文件默认是一个类：

```gdscript
# character.gd
extends Node

var health = 5

func print_health():
    print(health)
```

### 1.2 class_name

使用 `class_name` 注册全局类名：

```gdscript
# item.gd
@icon("res://icons/item.png")
class_name Item
extends Node
```

注册后可在任何地方直接使用：

```gdscript
# 其他脚本
var item = Item.new()
```

### 1.3 类作为资源

```gdscript
# 加载类
var MyClass = load("res://my_class.gd")

# 预加载（编译时）
const MyClass = preload("res://my_class.gd")

# 实例化
var instance = MyClass.new()
```

---

## 2. 继承

### 2.1 extends 关键字

```gdscript
# 继承全局类
extends Node

# 继承文件
extends "res://character.gd"

# 继承内部类
extends "res://character.gd".InnerClass
```

### 2.2 默认继承

未指定 `extends` 时，默认继承 `RefCounted`。

### 2.3 super 关键字

调用父类方法：

```gdscript
func some_func(x):
    super(x)  # 调用父类的同名方法

func other_func():
    super.parent_method()  # 调用父类的指定方法
```

### 2.4 is 关键字

检查继承关系：

```gdscript
const Enemy = preload("enemy.gd")

if entity is Enemy:
    entity.apply_damage()
```

> **踩坑点**：不能重写引擎的非虚方法（如 `get_class()`, `queue_free()`）。虚方法（以 `_` 开头）可以重写。

---

## 3. 构造函数

### 3.1 _init

```gdscript
func _init():
    print("Constructed!")
```

### 3.2 调用父类构造函数

```gdscript
# state.gd
var entity = null

func _init(e = null):
    entity = e

# idle.gd
extends "state.gd"

func _init(e = null, m = null):
    super(e)  # 必须调用父类构造函数
    message = m
```

> **踩坑点**：如果父类 `_init` 有参数，子类必须定义 `_init` 并传递参数。

### 3.3 静态构造函数

```gdscript
static var my_static_var = 1

static func _static_init():
    my_static_var = 2
```

静态构造函数在类加载时自动调用。

---

## 4. 内部类

### 4.1 定义

```gdscript
class SomeInnerClass:
    var a = 5

    func print_value():
        print(a)

func _init():
    var c = SomeInnerClass.new()
    c.print_value()
```

### 4.2 访问内部类

```gdscript
# 从外部访问
var inner = OuterClass.InnerClass.new()
```

---

## 5. 抽象类

### 5.1 定义抽象类（Godot 4.5+）

```gdscript
@abstract class Shape:
    @abstract func draw()

class Circle extends Shape:
    func draw():
        print("Drawing a circle")
```

### 5.2 规则

- 抽象类不能直接实例化
- 抽象方法没有实现（只有声明）
- 子类必须实现所有抽象方法，或也声明为抽象类

> **踩坑点**：抽象类不能附加到节点上。

---

## 6. 属性（Setter/Getter）

### 6.1 内联语法

```gdscript
var milliseconds: int = 0
var seconds: int:
    get:
        return milliseconds / 1000
    set(value):
        milliseconds = value * 1000
```

### 6.2 分离语法

```gdscript
var my_prop: get = get_my_prop, set = set_my_prop

func get_my_prop():
    return my_prop

func set_my_prop(value):
    my_prop = value
```

### 6.3 只读属性

```gdscript
var read_only: int:
    get:
        return _internal_value
```

### 6.4 避免无限递归

```gdscript
var my_prop:
    get:
        return my_prop  # 直接访问，不会递归
    set(value):
        my_prop = value  # 直接赋值，不会递归
```

> **踩坑点**：在 setter/getter 中使用变量名会直接访问底层变量，不会递归调用。但调用其他函数时需注意。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst`
