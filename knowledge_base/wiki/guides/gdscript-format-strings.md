# GDScript 格式化字符串指南

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01G_Format_Strings.md](../../base/gdscript-reference/01G_Format_Strings.md)

---

## 📚 概述

GDScript 提供三种字符串格式化方式：格式化字符串（推荐）、String.format() 方法和字符串拼接。本指南详细介绍格式化字符串的语法和最佳实践。

---

## 🎯 核心内容

### 1. 三种格式化方式对比

```gdscript
# 1. 格式化字符串（推荐）
var string = "I have %s cats." % "3"

# 2. String.format() 方法
var string = "I have {0} cats.".format([3])

# 3. 字符串拼接
var string = "I have " + str(3) + " cats."
```

### 2. 格式化字符串基本用法

#### 单个占位符
```gdscript
var format_string = "We're waiting for %s."
var actual_string = format_string % "Godot"
print(actual_string)  # "We're waiting for Godot."
```

#### 多个占位符
```gdscript
var format_string = "%s was reluctant to learn %s, but now he enjoys it."
var actual_string = format_string % ["Estragon", "GDScript"]
print(actual_string)  # "Estragon was reluctant to learn GDScript, but now he enjoys it."
```

### 3. 格式说明符

| 说明符 | 说明 | 示例 |
|--------|------|------|
| `%s` | 简单转换为字符串 | `"Hello %s" % "World"` |
| `%c` | 单个 Unicode 字符 | `"%c" % 65` → "A" |
| `%d` | 十进制整数 | `"%d" % 3.7` → "3" |
| `%o` | 八进制整数 | `"%o" % 10` → "12" |
| `%x` | 十六进制（小写） | `"%x" % 255` → "ff" |
| `%X` | 十六进制（大写） | `"%X" % 255` → "FF" |
| `%f` | 十进制浮点数 | `"%f" % 3.14` → "3.140000" |
| `%v` | 向量 | `"%v" % Vector2(1, 2)` → "(1.000000, 2.000000)" |

#### 示例
```gdscript
# 字符串
print("Hello %s" % "World")  # Hello World

# 整数
print("Score: %d" % 100)     # Score: 100
print("Hex: %x" % 255)       # Hex: ff

# 浮点数
print("Pi: %f" % PI)         # Pi: 3.141593

# 向量
print("Pos: %v" % Vector2(10, 20))  # Pos: (10.000000, 20.000000)
```

### 4. 填充与精度

#### 填充宽度
```gdscript
# 右对齐，填充空格
print("%10d" % 12345)   # "     12345"

# 右对齐，填充零
print("%010d" % 12345)  # "0000012345"

# 左对齐
print("%-10d" % 12345)  # "12345     "
```

#### 精度控制
```gdscript
# 零小数位
print("%.0f" % 3.14159)    # "3"

# 指定小数位
print("%.2f" % 3.14159)    # "3.14"

# 宽度 + 精度
print("%10.3f" % 10000.5555)  # " 10000.556"
```

#### 显示正号
```gdscript
print("%+d" % 42)   # "+42"
print("%+d" % -42)  # "-42"
```

### 5. 动态填充

使用 `*` 从参数获取填充或精度值：
```gdscript
var format_string = "%*.*f"
# 宽度 7，精度 3，值 8.8888
print(format_string % [7, 3, 8.8888])  # "  8.889"

# 动态填充零
print("%0*d" % [2, 3])  # "03"
```

### 6. 转义百分号

使用 `%%` 表示字面百分号：
```gdscript
var health = 56
print("Remaining health: %d%%" % health)  # "Remaining health: 56%"
```

### 7. String.format() 方法

#### 基本用法
```gdscript
# 字典方式
var s = "Hi, {name} v{version}!".format({"name": "Godette", "version": "3.0"})

# 数组索引方式
var s = "Hi, {0} v{1}!".format(["Godette", "3.0"])

# 无索引方式
var s = "Hi, {} v{}!".format(["Godette", "3.0"], "{}")
```

#### 自定义占位符
```gdscript
# 中缀（默认）
"Hi, {0} v{1}".format(["Godette", "3.0"], "{_}")

# 后缀
"Hi, 0% v1%".format(["Godette", "3.0"], "_%")

# 前缀
"Hi, %0 v%1".format(["Godette", "3.0"], "%_")
```

#### 结合格式化字符串
```gdscript
# format() 不支持数字格式化，可以结合使用
var s = "Hi, {0} v{version}".format({
    0: "Godette",
    version: "%0.2f" % 3.114
})
# "Hi, Godette v3.11"
```

---

## ✅ 最佳实践

1. **优先使用格式化字符串** - 语法简洁，性能好
2. **使用 String.format() 处理复杂模板** - 字典方式更清晰
3. **避免字符串拼接** - 性能差，代码可读性低
4. **使用精度控制格式化浮点数** - 避免显示过长小数
5. **使用动态填充对齐输出** - 提高日志可读性

---

## 🔗 相关页面

### Base 层来源
- [01G_Format_Strings.md](../../base/gdscript-reference/01G_Format_Strings.md) - 完整格式化字符串文档

### Wiki 层相关
- [GDScript 基础语法](./gdscript-basics.md) - 基础语法
- [GDScript 代码规范](./gdscript-standards.md) - 代码风格

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
