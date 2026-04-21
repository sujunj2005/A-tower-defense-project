# 自定义 2D 绘制指南

> **来源**: [05I_Custom_Drawing_2D.md](../../base/2d-development/05I_Custom_Drawing_2D.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本指南介绍 Godot 4.x 中的自定义 2D 绘制功能，使用 `_draw()` 函数绘制现有节点无法实现的形状和效果。

---

## 🎨 自定义绘制概述

### 使用场景

- 绘制现有节点无法实现的形状（拖尾效果、特殊动画多边形）
- 绘制大量简单对象（网格、棋盘），避免大量节点的内存开销
- 制作自定义 UI 控件

### 适用节点

任何继承自 CanvasItem 的节点都可以自定义绘制：
- Node2D
- Control

---

## 🖌️ _draw 函数

### 重写 _draw()

```gdscript
extends Node2D

func _draw():
    pass  # 你的绘制命令在这里
```

### 注意事项

`_draw()` 函数只调用一次，然后缓存绘制结果。后续调用不会重新执行。

---

## 📐 绘制命令

### 基本形状

```gdscript
func _draw():
    # 绘制线条
    draw_line(Vector2(0, 0), Vector2(100, 100), Color.RED, 2.0)
    
    # 绘制矩形
    draw_rect(Rect2(10, 10, 50, 30), Color.BLUE)
    
    # 绘制填充矩形
    draw_rect_filled(Rect2(70, 10, 50, 30), Color.GREEN)
    
    # 绘制圆
    draw_circle(Vector2(200, 50), 20, Color.YELLOW)
    
    # 绘制弧线
    draw_arc(Vector2(300, 50), 25, 0, TAU, 32, Color.ORANGE)
```

### 纹理绘制

```gdscript
func _draw():
    var texture: Texture2D = preload("res://icon.png")
    draw_texture(texture, Vector2(0, 0))
    draw_texture_rect(texture, Rect2(50, 0, 32, 32))
```

### 多边形

```gdscript
func _draw():
    var points = PackedVector2Array([
        Vector2(0, 0),
        Vector2(50, 0),
        Vector2(25, 40)
    ])
    draw_polygon(points, Color.CYAN)
    draw_colored_polygon(points, Color.RED)
```

### 文字绘制

```gdscript
func _draw():
    var font = load("res://fonts/MyFont.ttf")
    draw_string(font, Vector2(10, 50), "Hello World", HORIZONTAL_ALIGNMENT_LEFT, 16, Color.WHITE)
```

---

## 🔄 重绘机制

### 触发重绘

当变量改变时需要重新绘制：

```gdscript
extends Node2D

@export var texture: Texture2D:
    set(value):
        texture = value
        queue_redraw()  # 触发重绘

func _draw():
    draw_texture(texture, Vector2())
```

### queue_redraw()

调用后会在下一帧触发新的 `_draw()` 调用。

---

## 🎨 常见示例

### 绘制生命条

```gdscript
var health := 100:
    set(value):
        health = value
        queue_redraw()

var max_health := 100

func _draw():
    var bar_width = 80
    var bar_height = 8
    var ratio = float(health) / max_health
    
    # 背景
    draw_rect(Rect2(-bar_width/2, -bar_height/2, bar_width, bar_height), Color.DARK_GRAY)
    # 血量
    draw_rect(Rect2(-bar_width/2, -bar_height/2, bar_width * ratio, bar_height), Color.RED)
```

### 绘制调试信息

```gdscript
func _draw():
    draw_line(Vector2(-10, 0), Vector2(10, 0), Color.GREEN)
    draw_line(Vector2(0, -10), Vector2(0, 10), Color.GREEN)
    draw_circle(Vector2.ZERO, 3, Color.YELLOW)
```

### 绘制轨迹

```gdscript
var trail_points: Array[Vector2] = []

func add_point(point: Vector2):
    trail_points.append(point)
    if trail_points.size() > 20:
        trail_points.pop_front()
    queue_redraw()

func _draw():
    for i in range(trail_points.size() - 1):
        var alpha = float(i) / trail_points.size()
        draw_line(trail_points[i], trail_points[i+1], Color(1, 1, 1, alpha), 2.0)
```

### 绘制网格

```gdscript
@export var grid_size = 32
@export var grid_width = 20
@export var grid_height = 15

func _draw():
    # 绘制垂直线
    for x in range(grid_width + 1):
        var x_pos = x * grid_size
        draw_line(Vector2(x_pos, 0), Vector2(x_pos, grid_height * grid_size), Color.GRAY, 1.0)
    
    # 绘制水平线
    for y in range(grid_height + 1):
        var y_pos = y * grid_size
        draw_line(Vector2(0, y_pos), Vector2(grid_width * grid_size, y_pos), Color.GRAY, 1.0)
```

### 绘制棋盘

```gdscript
@export var cell_size = 40
@export var board_size = 8

func _draw():
    for x in range(board_size):
        for y in range(board_size):
            var is_white = (x + y) % 2 == 0
            var color = Color.WHITE if is_white else Color.BLACK
            var rect = Rect2(x * cell_size, y * cell_size, cell_size, cell_size)
            draw_rect(rect, color)
```

---

## ⚡ 性能优化

### 优化建议

1. **避免频繁重绘**
   - 只在必要时调用 `queue_redraw()`
   - 考虑使用 `update()` 而非每帧重绘

2. **减少绘制调用**
   - 合并多个绘制命令
   - 使用 `draw_primitive()` 绘制复杂形状

3. **使用缓存**
   - 对于静态内容，预先渲染到 Texture
   - 使用 `ViewportTexture` 缓存复杂绘制

### 使用 draw_primitive()

```gdscript
func _draw():
    # 创建顶点数组
    var vertices = PackedVector2Array([
        Vector2(0, 0),
        Vector2(50, 0),
        Vector2(25, 40)
    ])
    
    # 创建颜色数组
    var colors = PackedColorArray([
        Color.RED,
        Color.GREEN,
        Color.BLUE
    ])
    
    # 创建 UV 数组（可选）
    var uvs = PackedVector2Array([
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(0.5, 1)
    ])
    
    # 绘制三角形
    draw_primitive(vertices, colors, uvs)
```

---

## ⚠️ 常见踩坑

### 踩坑 1: _draw() 不执行

**可能原因**:
1. 节点被隐藏（visible = false）
2. 节点被禁用（set_process(false)）
3. 没有正确重写 _draw() 函数

**检查清单**:
- [ ] 节点 visible = true
- [ ] 节点已启用
- [ ] 函数签名正确：`func _draw():`

### 踩坑 2: 绘制内容不更新

**问题**: 变量改变后绘制内容没有更新

**解决方案**:
```gdscript
# 确保在 setter 中调用 queue_redraw()
@export var value: float:
    set(val):
        value = val
        queue_redraw()  # 触发重绘
```

### 踩坑 3: 性能问题

**问题**: 频繁调用 queue_redraw() 导致性能下降

**解决方案**:
1. 减少 queue_redraw() 调用频率
2. 使用定时器限制重绘频率
3. 对于动画，考虑使用 AnimationPlayer

---

## 🔗 相关链接

### 前置知识
- [2D 开发介绍](../concepts/2d-development-intro.md) - CanvasItem 基础
- [2D 变换概念](../concepts/2d-transforms.md) - 坐标系统

### 后续学习
- [Sprite 动画指南](sprite-animation-guide.md) - 结合动画
- [2D 粒子系统指南](particles-2d-guide.md) - 粒子效果

### Base 层来源
- [05I_Custom_Drawing_2D.md](../../base/2d-development/05I_Custom_Drawing_2D.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
