# GDScript 基础语法摘要

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01A_Basics.md](../../base/gdscript-reference/01A_Basics.md)

---

## 📚 概述

GDScript 是 Godot 专用的高级、面向对象、命令式、渐进式类型编程语言。使用缩进语法（类似 Python），与 Godot 引擎紧密集成。

---

## 🎯 核心内容

### 1. 标识符命名规则

- 包含字母（a-z, A-Z）、数字（0-9）和下划线（_）
- **不能以数字开头**
- 大小写敏感
- 支持 Unicode 字符（UAX#31）

```gdscript
var valid_name = 1
var ValidName = 2
var _private = 3
var 变量名 = 4  # 支持 Unicode

# 无效标识符
# var 123abc = 5    # 以数字开头
# var my-var = 6    # 包含连字符
```

### 2. 关键字

#### 流程控制
| 关键字 | 说明 |
|--------|------|
| `if` / `elif` / `else` | 条件语句 |
| `for` | for 循环 |
| `while` | while 循环 |
| `match` | 模式匹配 |
| `break` / `continue` | 循环控制 |

#### 类和函数
| 关键字 | 说明 |
|--------|------|
| `class` / `class_name` | 类定义 |
| `extends` | 继承 |
| `func` | 函数定义 |
| `static` | 静态修饰 |
| `signal` | 信号定义 |

#### 变量和类型
| 关键字 | 说明 |
|--------|------|
| `var` | 变量定义 |
| `const` | 常量定义 |
| `enum` | 枚举定义 |
| `is` / `as` | 类型检查/转换 |

#### 其他
| 关键字 | 说明 |
|--------|------|
| `return` | 返回值 |
| `await` | 等待信号/协程 |
| `assert` | 断言 |
| `preload` | 预加载 |

### 3. 操作符优先级（从高到低）

```
1. ()                    # 分组
2. x[index], x.attribute # 下标/属性访问
3. foo()                 # 函数调用
4. await x               # 等待
5. x is Node             # 类型检查
6. x ** y                # 幂运算
7. ~x, +x, -x            # 按位取反/正负
8. *, /, %               # 乘/除/取余
9. +, -                  # 加/减
10. <<, >>               # 位移
11. &, ^, |              # 按位运算
12. ==, !=, <, >, <=, >= # 比较
13. in / not in          # 包含检查
14. not, !               # 逻辑非
15. and, &&              # 逻辑与
16. or, ||               # 逻辑或
17. if else              # 三元运算符
18. as                   # 类型转换
19. =, +=, -=, ...       # 赋值
```

> **⚠️ 踩坑点**: `/` 对于两个整数执行整数除法。需要浮点结果时，至少一个操作数应为浮点数。

```gdscript
var a = 5 / 2      # 结果为 2，不是 2.5
var b = 5.0 / 2    # 结果为 2.5
```

### 4. 字面量

| 示例 | 说明 |
|------|------|
| `null` | 空值 |
| `false`, `true` | 布尔值 |
| `45`, `0x8f51`, `0b101010` | 整数（十进制/十六进制/二进制） |
| `3.14`, `58.1e-10` | 浮点数 |
| `"Hello"`, `'Hi'` | 字符串 |
| `"""Hello"""` | 多行字符串 |
| `r"Hello"` | 原始字符串（不处理转义） |
| `&"name"` | StringName |
| `^"Node/Label"` | NodePath |

### 5. 特殊语法糖

```gdscript
# $ 语法 - 获取节点
$NodePath  # 等价于 get_node("NodePath")

# % 语法 - 获取唯一节点
%UniqueNode  # 等价于 get_node("%UniqueNode")
```

### 6. 注释

```gdscript
# 普通注释

## 文档注释（显示在编辑器中）
@export var value

# 高亮关键字（以下为注释语法示例，非实际待办项）
# TODO: 待实现功能
# FIXME: 需要修复的问题
# NOTE: 重要说明
# WARNING: 警告信息
```

---

## 🔗 相关页面

### Base 层来源
- [01A_Basics.md](../../base/gdscript-reference/01A_Basics.md) - 完整基础语法文档

### Wiki 层相关
- [GDScript 类型系统](./gdscript-types.md) - 类型和变量
- [GDScript 函数](./gdscript-functions.md) - 函数定义
- [GDScript 类和继承](./gdscript-classes.md) - 面向对象编程

### 其他参考
- [GDScript 代码规范](./gdscript-standards.md) - 代码风格指南
- [GDScript 静态类型](../../wiki/guides/gdscript-static-typing.md) - 类型注解

---

## 📊 快速参考表

### 三元运算符
```gdscript
var result = condition ? value_if_true : value_if_false
```

### 行延续
```gdscript
var a = 1 + \
    2 + \
    3
```

### 代码区域折叠
```gdscript
#region 区域名称
# 可折叠的代码
#endregion
```

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
