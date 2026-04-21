# Godot 4.x 调试工具

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/debug/overview_of_debugging_tools.rst

---

## 目录

1. [调试概述](#1-调试概述)
2. [调试器面板](#2-调试器面板)
3. [断点](#3-断点)
4. [打印调试](#4-打印调试)
5. [性能分析器](#5-性能分析器)

---

## 1. 调试概述

### 1.1 调试工具

Godot 提供多种调试工具：

- 调试器面板
- 断点系统
- 性能分析器
- 控制台输出

---

## 2. 调试器面板

### 2.1 变量监视

在调试器面板中查看：

- 局部变量
- 成员变量
- 全局变量

### 2.2 调用栈

显示当前调用栈：

- 函数名称
- 文件位置
- 行号

### 2.3 远程调试

在运行时检查场景树：

- 节点结构
- 节点属性
- 实时更新

---

## 3. 断点

### 3.1 设置断点

- 在编辑器中点击行号左侧
- 使用 `breakpoint` 关键字

```gdscript
func _ready():
    breakpoint  # 代码断点
    print("这行不会执行直到继续")
```

### 3.2 条件断点

右键断点设置条件：

```gdscript
# 条件表达式
health < 10
enemy_count > 5
```

### 3.3 断点操作

| 操作 | 快捷键 |
|------|--------|
| 继续 | F8 |
| 单步跳过 | F10 |
| 单步进入 | F11 |
| 单步跳出 | Shift+F11 |

---

## 4. 打印调试

### 4.1 print()

```gdscript
print("Hello")
print("Value: ", value)
prints("a", "b", "c")  # 空格分隔
printt("a", "b", "c")  # Tab 分隔
```

### 4.2 push_error() / push_warning()

```gdscript
push_error("严重错误")
push_warning("警告信息")
```

### 4.3 assert()

```gdscript
assert(health > 0, "生命值必须大于 0")
```

> **踩坑点**：`assert` 只在调试构建中执行，发布版本会被忽略。

### 4.4 输出格式化

```gdscript
print("位置：%v" % position)  # 向量
print("数值：%.2f" % 3.14159)  # 保留两位小数
```

---

## 5. 性能分析器

### 5.1 打开分析器

调试器 → Profiler

### 5.2 分析内容

| 视图 | 说明 |
|------|------|
| Time | 函数执行时间 |
| Memory | 内存使用 |
| Physics | 物理性能 |
| Physics 2D | 2D 物理性能 |

### 5.3 使用分析器

1. 开始录制
2. 运行游戏
3. 停止录制
4. 分析结果

---

## 6. 可视化调试

### 6.1 绘制调试图形

```gdscript
func _draw():
    draw_line(Vector2(0, 0), Vector2(100, 100), Color.RED, 2)
    draw_circle(Vector2(50, 50), 20, Color.BLUE)
```

### 6.2 3D 调试绘制

```gdscript
func _process(_delta):
    DebugDraw3D.draw_line(Vector3(0, 0, 0), Vector3(0, 10, 0), Color.RED)
    DebugDraw3D.draw_sphere(Vector3(0, 5, 0), 1, Color.BLUE)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/debug/overview_of_debugging_tools.rst`
