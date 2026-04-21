# GDScript 基础语法

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst

---

## 目录

1. [语言概述](#1-语言概述)
2. [标识符](#2-标识符)
3. [关键字](#3-关键字)
4. [操作符](#4-操作符)
5. [字面量](#5-字面量)
6. [注释](#6-注释)
7. [代码区域](#7-代码区域)
8. [行延续](#8-行延续)

---

## 1. 语言概述

GDScript 是 Godot 专用的高级、面向对象、命令式、渐进式类型编程语言。

**特点**：
- 使用缩进语法（类似 Python）
- 与 Godot 引擎紧密集成
- 完全独立于 Python

### 1.1 基本示例

```gdscript
# 注释以 # 开头
# 文件即类

@icon("res://path/to/icon.svg")  # 可选：编辑器图标
class_name MyClass               # 可选：类名
extends BaseClass                # 继承

# 成员变量
var a = 5
var s = "Hello"
var arr = [1, 2, 3]
var dict = {"key": "value", 2: 3}

# 常量
const ANSWER = 42

# 枚举
enum {UNIT_NEUTRAL, UNIT_ENEMY, UNIT_ALLY}
enum Named {THING_1, THING_2, ANOTHER_THING = -1}

# 函数
func some_function(param1, param2, param3 = 123):
    if param1 < 5:
        print(param1)
    return param1 + 3

# 构造函数
func _init():
    print("Constructed!")
```

---

## 2. 标识符

### 2.1 命名规则

- 包含字母（a-z, A-Z）、数字（0-9）和下划线（_）
- 不能以数字开头
- 大小写敏感（`foo` 和 `FOO` 不同）
- 支持 Unicode 字符（UAX#31）
- 不允许混淆字符和 emoji

```gdscript
var valid_name = 1
var ValidName = 2
var _private = 3
var 变量名 = 4  # 支持 Unicode

# 无效标识符
# var 123abc = 5    # 以数字开头
# var my-var = 6    # 包含连字符
```

---

## 3. 关键字

### 3.1 完整关键字列表

| 关键字 | 说明 |
|--------|------|
| `if` / `elif` / `else` | 条件语句 |
| `for` | for 循环 |
| `while` | while 循环 |
| `match` | 模式匹配 |
| `when` | match 语句中的模式守卫 |
| `break` | 退出循环 |
| `continue` | 跳到下一次循环迭代 |
| `pass` | 空语句占位符 |
| `return` | 从函数返回值 |
| `class` | 定义内部类 |
| `class_name` | 定义全局类名 |
| `extends` | 继承类 |
| `is` | 类型检查 |
| `in` | 包含检查 / for 循环迭代 |
| `as` | 类型转换 |
| `self` | 当前实例引用 |
| `super` | 调用父类方法 |
| `signal` | 定义信号 |
| `func` | 定义函数 |
| `static` | 定义静态函数或变量 |
| `const` | 定义常量 |
| `enum` | 定义枚举 |
| `var` | 定义变量 |
| `breakpoint` | 调试断点 |
| `preload` | 预加载资源 |
| `await` | 等待信号或协程 |
| `assert` | 断言条件 |
| `void` | 表示函数无返回值 |

### 3.2 内置常量

| 关键字 | 说明 |
|--------|------|
| `PI` | 圆周率 π |
| `TAU` | τ = 2π |
| `INF` | 无穷大 |
| `NAN` | 非数字 |

---

## 4. 操作符

### 4.1 操作符优先级（从高到低）

| 操作符 | 说明 |
|--------|------|
| `()` | 分组 |
| `x[index]` | 下标访问 |
| `x.attribute` | 属性访问 |
| `foo()` | 函数调用 |
| `await x` | 等待 |
| `x is Node` / `x is not Node` | 类型检查 |
| `x ** y` | 幂运算 |
| `~x` | 按位取反 |
| `+x` / `-x` | 正/负 |
| `*` `/` `%` | 乘/除/取余 |
| `+` `-` | 加/减 |
| `<<` `>>` | 位移 |
| `&` | 按位与 |
| `^` | 按位异或 |
| `\|` | 按位或 |
| `==` `!=` `<` `>` `<=` `>=` | 比较 |
| `in` / `not in` | 包含检查 |
| `not` / `!` | 逻辑非 |
| `and` / `&&` | 逻辑与 |
| `or` / `\|\|` | 逻辑或 |
| `if else` | 三元运算符 |
| `as` | 类型转换 |
| `=` `+=` `-=` 等 | 赋值 |

### 4.2 操作符注意事项

```gdscript
# 整数除法
var a = 5 / 2      # 结果为 2，不是 2.5
var b = 5.0 / 2    # 结果为 2.5
var c = float(5) / 2  # 结果为 2.5

# 取余运算
var d = 7 % 3      # 结果为 1
# 浮点数取余使用 fmod()
var e = fmod(7.5, 2.5)  # 结果为 2.5

# 幂运算（左结合）
var f = 2 ** 2 ** 3   # 等价于 (2 ** 2) ** 3 = 64
var g = 2 ** (2 ** 3) # 等价于 2 ** 8 = 256
```

> **踩坑点**：`/` 对于两个整数执行整数除法。需要浮点结果时，至少一个操作数应为浮点数。

---

## 5. 字面量

### 5.1 基本字面量

| 示例 | 说明 |
|------|------|
| `null` | 空值 |
| `false`, `true` | 布尔值 |
| `45` | 十进制整数 |
| `0x8f51` | 十六进制整数 |
| `0b101010` | 二进制整数 |
| `3.14`, `58.1e-10` | 浮点数 |
| `"Hello"`, `'Hi'` | 字符串 |
| `"""Hello"""` | 多行字符串 |
| `r"Hello"` | 原始字符串 |
| `&"name"` | StringName |
| `^"Node/Label"` | NodePath |

### 5.2 数字分隔符

```gdscript
var a = 12_345_678       # 等于 12345678
var b = 3.141_592_7      # 等于 3.1415927
var c = 0x8080_0000_ffff # 十六进制分隔
var d = 0b11_00_11_00    # 二进制分隔
```

### 5.3 字符串转义序列

| 转义序列 | 说明 |
|----------|------|
| `\n` | 换行 |
| `\t` | 水平制表符 |
| `\r` | 回车 |
| `\\` | 反斜杠 |
| `\"` | 双引号 |
| `\'` | 单引号 |
| `\uXXXX` | UTF-16 Unicode |
| `\UXXXXXX` | UTF-32 Unicode |

### 5.4 特殊语法

```gdscript
# $ 语法糖
$NodePath  # 等价于 get_node("NodePath")

# % 唯一节点语法
%UniqueNode  # 等价于 get_node("%UniqueNode")
```

---

## 6. 注释

### 6.1 普通注释

```gdscript
# 这是单行注释
```

### 6.2 文档注释

```gdscript
## 这是文档注释
## 会显示在脚本文档和检查器中
var value

## 导出变量的文档注释
@export var exported_value
```

### 6.3 高亮关键字

编辑器会高亮注释中的关键字：

- **红色（严重）**：`ALERT`, `ATTENTION`, `CAUTION`, `CRITICAL`, `DANGER`, `SECURITY`
- **黄色（警告）**：`BUG`, `DEPRECATED`, `FIXME`, `HACK`, `TASK`, `TBD`, `TODO`, `WARNING`
- **绿色（注意）**：`INFO`, `NOTE`, `NOTICE`, `TEST`, `TESTING`

```gdscript
# TODO: 待实现功能
# FIXME: 需要修复的问题
# NOTE: 重要说明
```

---

## 7. 代码区域

代码区域可以折叠：

```gdscript
#region 无描述区域
...
#endregion

#region 带描述的区域
func generate_lakes():
    pass

func generate_hills():
    pass
#endregion
```

---

## 8. 行延续

使用反斜杠续行：

```gdscript
var a = 1 + \
    2

var b = 1 + \
    4 + \
    10 + \
    4
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst`
