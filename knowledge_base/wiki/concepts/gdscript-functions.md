# GDScript 函数摘要

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01C_Functions.md](../../base/gdscript-reference/01C_Functions.md)

---

## 📚 概述

函数是 GDScript 代码组织的基本单元。理解函数定义、参数传递、Lambda 函数和静态函数对于编写模块化代码至关重要。

---

## 🎯 核心内容

### 1. 函数定义

#### 基本语法
```gdscript
func my_function(a, b):
    print(a)
    print(b)
    return a + b
```

#### 单行函数
```gdscript
func square(a): return a * a
func hello_world(): print("Hello World")
func empty_function(): pass
```

#### 默认返回值
函数默认返回 `null`：
```gdscript
func no_return():
    pass

var result = no_return()  # result = null
```

### 2. 参数与返回值

#### 默认参数
```gdscript
func my_function(a_required, b_optional = 10, c_optional = 42):
    print(a_required, b_optional, c_optional)

my_function(1)           # 1, 10, 42
my_function(1, 20)       # 1, 20, 42
my_function(1, 20, 100)  # 1, 20, 100
```

#### 类型注解
```gdscript
func my_function(a: int, b: String) -> void:
    print(a, b)

func typed_return() -> int:
    return 42

func infer_types(a := 42, b := "hello"):
    # 类型从默认值推断
    pass
```

#### 返回类型要求
```gdscript
# void 函数
func void_function() -> void:
    return  # 可选，不能返回值

# 非 void 函数必须返回值
func must_return() -> int:
    if condition:
        return 1
    return 0  # 所有分支都必须返回
```

> **⚠️ 踩坑点**: 非 void 函数的所有代码路径都必须有 return 语句，否则编辑器会报错。

### 3. Lambda 函数

#### 基本语法
```gdscript
var lambda = func (x):
    print(x)

lambda.call(42)  # 调用 lambda
```

#### 命名 Lambda
```gdscript
var lambda = func my_lambda(x):
    print(x)
```
命名 lambda 在调试器中显示名称。

#### 类型注解
```gdscript
var lambda := func (x: int) -> void:
    print(x)
```

#### 返回值
```gdscript
var square = func (x): return x ** 2
print(square.call(5))  # 25
```

> **⚠️ 踩坑点**: lambda 函数必须显式使用 `return` 返回值。

#### 捕获变量
```gdscript
var x = 42
var lambda = func ():
    print(x)  # 捕获外部变量

lambda.call()  # 42
```

> **⚠️ 踩坑点**: 局部变量在 lambda 创建时按值捕获一次，之后外部修改不影响 lambda 内的值。

```gdscript
var x = 42
var lambda = func (): print(x)
lambda.call()  # 42
x = "Hello"
lambda.call()  # 仍然是 42，不是 "Hello"
```

### 4. 静态函数

#### 定义
```gdscript
static func sum2(a, b):
    return a + b
```

#### 限制
- 不能访问实例成员变量
- 不能访问 `self`
- 可以访问静态变量

```gdscript
static var counter = 0

static func increment():
    counter += 1  # 可以访问静态变量
```

### 5. 可变参数函数（Godot 4.5+）

#### 基本语法
```gdscript
func my_func(a, b = 0, ...args):
    prints(a, b, args)

my_func(1)             # 1 0 []
my_func(1, 2)          # 1 2 []
my_func(1, 2, 3)       # 1 2 [3]
my_func(1, 2, 3, 4)    # 1 2 [3, 4]
```

#### 类型注解
```gdscript
func sum(...values: Array) -> int:
    var result := 0
    for value in values:
        result += value
    return result
```

> **⚠️ 踩坑点**: 类型数组（如 `Array[int]`）目前不支持作为 rest 参数类型。

### 6. 函数引用（Callable）

#### 获取 Callable
```gdscript
func add1(value: int) -> int:
    return value + 1

func _ready():
    var callable = add1  # 获取函数引用
    print(callable.call(5))  # 6
```

#### 作为参数传递
```gdscript
func map(arr: Array, function: Callable) -> Array:
    var result = []
    for item in arr:
        result.push_back(function.call(item))
    return result

func double(x): return x * 2

func _ready():
    var numbers = [1, 2, 3]
    var doubled = map(numbers, double)
    print(doubled)  # [2, 4, 6]
```

> **⚠️ 踩坑点**: Callable 必须使用 `call()` 方法调用，不能直接用 `()`。

---

## 🔗 相关页面

### Base 层来源
- [01C_Functions.md](../../base/gdscript-reference/01C_Functions.md) - 完整函数文档

### Wiki 层相关
- [GDScript 基础语法](./gdscript-basics.md) - 基础语法
- [GDScript 类型系统](./gdscript-types.md) - 类型和变量
- [GDScript 类和继承](./gdscript-classes.md) - 面向对象编程

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
