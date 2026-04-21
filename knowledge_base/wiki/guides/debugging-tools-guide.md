# 调试工具实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 17A_Debugging_Tools.md](../../base/debug-and-testing/17A_Debugging_Tools.md)  
> **重要性**: 🔴 必读 - 调试工具完整教程

---

## 📋 概述

Godot 提供了强大的调试工具集，包括调试器、日志、可视化器等。掌握这些工具可以大幅提高开发效率。

---

## 🎯 核心工具

### 1. 调试器面板

**断点调试**：
- 点击行号左侧设置断点
- F10: 单步执行
- F11: 跳入函数
- Ctrl+F11: 跳出函数
- F5: 继续执行

**监视窗口**：
- 添加变量监视
- 查看变量值变化
- 条件断点

### 2. 远程场景树

```gdscript
# 查看运行时的场景树
# 调试器 → 远程
# 可以查看和修改节点属性
```

### 3. 日志输出

```gdscript
# 标准输出
print("普通日志")

# 带颜色的输出
print_rich("[color=red]错误[/color]")
print_rich("[color=green]成功[/color]")

# 警告和错误
push_warning("警告信息")
push_error("错误信息")

# 断言
assert(health >= 0, "生命值不能为负")
```

---

## 🔧 实战技巧

### 1. 条件日志

```gdscript
# 只在调试模式输出
var DEBUG = true

func debug_log(message: String):
    if DEBUG:
        print("[DEBUG] ", message)

# 或使用引擎调试模式
func _ready():
    if OS.is_debug_build():
        print("运行在调试模式")
```

### 2. 性能分析日志

```gdscript
# 测量代码执行时间
func _process(delta):
    var start = Time.get_ticks_usec()
    
    # 要测量的代码
    complex_calculation()
    
    var elapsed = Time.get_ticks_usec() - start
    print("执行时间：%d 微秒" % elapsed)
```

### 3. 可视化调试

```gdscript
# 绘制调试图形
func _draw():
    # 绘制碰撞箱
    draw_rect($CollisionShape2D.get_rect(), Color.red, false)
    
    # 绘制路径
    draw_line(position, target_position, Color.green, 2)
    
    # 绘制文本
    draw_string(SystemFont.new(), Vector2.ZERO, "HP: %d" % health)
```

---

## 🔗 相关资源

### Base 层
- [17A_Debugging_Tools.md](../../base/debug-and-testing/17A_Debugging_Tools.md) - 调试工具详解
- [17B_Profiler.md](../../base/debug-and-testing/17B_Profiler.md) - 性能分析器

### Wiki 层
- [性能分析器指南](../guides/profiler-guide.md) - 性能优化

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
