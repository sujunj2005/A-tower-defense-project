# Godot 4.x 2D 自定义绘制

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/custom_drawing_in_2d.rst

---

## 目录

1. [自定义绘制概述](#1-自定义绘制概述)
2. [_draw 函数](#2-_draw-函数)
3. [绘制命令](#3-绘制命令)
4. [重绘机制](#4-重绘机制)
5. [常见示例](#5-常见示例)

---

## 1. 自定义绘制概述

### 1.1 使用场景

- 绘制现有节点无法实现的形状（拖尾效果、特殊动画多边形）
- 绘制大量简单对象（网格、棋盘），避免大量节点的内存开销
- 制作自定义 UI 控件

### 1.2 适用节点

任何继承自 CanvasItem 的节点都可以自定义绘制：
- Node2D
- Control

---

## 2. _draw 函数

### 2.1 重写 _draw()

```gdscript
extends Node2D

func _draw():
    pass  # 你的绘制命令在这里
```

### 2.2 注意事项

`_draw()` 函数只调用一次，然后缓存绘制结果。后续调用不会重新执行。

---

## 3. 绘制命令

### 3.1 基本形状

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

### 3.2 纹理绘制

```gdscript
func _draw():
    var texture: Texture2D = preload("res://icon.png")
    draw_texture(texture, Vector2(0, 0))
    draw_texture_rect(texture, Rect2(50, 0, 32, 32))
```

### 3.3 多边形

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

### 3.4 文字绘制

```gdscript
func _draw():
    draw_string(font, Vector2(10, 50), "Hello World", HORIZONTAL_ALIGNMENT_LEFT, 16, Color.WHITE)
```

---

## 4. 重绘机制

### 4.1 触发重绘

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

### 4.2 queue_redraw()

调用后会在下一帧触发新的 `_draw()` 调用。

---

## 5. 常见示例

### 5.1 绘制生命条

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

### 5.2 绘制调试信息

```gdscript
func _draw():
    draw_line(Vector2(-10, 0), Vector2(10, 0), Color.GREEN)
    draw_line(Vector2(0, -10), Vector2(0, 10), Color.GREEN)
    draw_circle(Vector2.ZERO, 3, Color.YELLOW)
```

### 5.3 绘制轨迹

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

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/2d/custom_drawing_in_2d.rst`
