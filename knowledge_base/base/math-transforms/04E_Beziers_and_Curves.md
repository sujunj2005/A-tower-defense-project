# Godot 4.x 贝塞尔曲线

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/math/beziers_and_curves.rst

---

## 目录

1. [贝塞尔曲线概述](#1-贝塞尔曲线概述)
2. [二次贝塞尔](#2-二次贝塞尔)
3. [三次贝塞尔](#3-三次贝塞尔)
4. [实际应用](#4-实际应用)
5. [曲线和路径](#5-曲线和路径)

---

## 1. 贝塞尔曲线概述

### 1.1 什么是贝塞尔曲线

贝塞尔曲线是自然几何形状的数学近似。我们使用它们以尽可能少的信息表示曲线，并且具有很高的灵活性。

贝塞尔曲线依赖于插值，将多个步骤组合在一起以创建平滑曲线。

---

## 2. 二次贝塞尔

### 2.1 三个点

二次贝塞尔需要三个点：
- `p0`：起点
- `p1`：控制点
- `p2`：终点

### 2.2 实现代码

```gdscript
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    var r = q0.lerp(q1, t)
    return r
```

### 2.3 工作原理

1. 首先在两点之间插值，得到 `q0` 和 `q1`
2. 然后在 `q0` 和 `q1` 之间插值，得到最终点 `r`

---

## 3. 三次贝塞尔

### 3.1 四个点

三次贝塞尔需要四个点：
- `p0`：起点
- `p1`：第一个控制点
- `p2`：第二个控制点
- `p3`：终点

### 3.2 实现代码

```gdscript
func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    var q2 = p2.lerp(p3, t)
    var r0 = q0.lerp(q1, t)
    var r1 = q1.lerp(q2, t)
    var s = r0.lerp(r1, t)
    return s
```

---

## 4. 实际应用

### 4.1 绘制贝塞尔曲线

```gdscript
func _draw():
    var p0 = Vector2(0, 0)
    var p1 = Vector2(100, 50)
    var p2 = Vector2(200, 0)
    
    var points = []
    for t in range(0, 101):
        var tt = t / 100.0
        var point = _quadratic_bezier(p0, p1, p2, tt)
        points.append(point)
    
    draw_polyline(points, Color.RED, 2)
```

### 4.2 沿曲线移动

```gdscript
var t = 0.0
var speed = 0.5

func _process(delta):
    t += delta * speed
    if t > 1.0:
        t = 0.0
    
    var pos = _cubic_bezier(p0, p1, p2, p3, t)
    $Character.position = pos
```

### 4.3 缓动函数

```gdscript
func ease_in(t: float) -> float:
    return t * t

func ease_out(t: float) -> float:
    return 1.0 - (1.0 - t) * (1.0 - t)

func ease_in_out(t: float) -> float:
    return t * t * (3.0 - 2.0 * t)

# 使用缓动函数
var eased_t = ease_in_out(t)
var pos = _cubic_bezier(p0, p1, p2, p3, eased_t)
```

---

## 5. 曲线和路径

### 5.1 Curve2D

Godot 提供 `Curve2D` 资源来处理贝塞尔曲线：

```gdscript
var curve = Curve2D.new()
curve.add_point(Vector2(0, 0))
curve.add_point(Vector2(50, 50), Vector2(-20, 0), Vector2(20, 0))
curve.add_point(Vector2(100, 0))

# 采样曲线上的点
var pos = curve.sample_baked(0.5)  # 参数 0-1
```

### 5.2 Curve3D

```gdscript
var curve = Curve3D.new()
curve.add_point(Vector3(0, 0, 0))
curve.add_point(Vector3(50, 50, 0))
curve.add_point(Vector3(100, 0, 0))
```

### 5.3 Path2D 和 PathFollow2D

```gdscript
@onready var path = $Path2D
@onready var follow = $Path2D/PathFollow2D

func _process(delta):
    follow.progress += delta * 100
    if follow.progress > path.curve.get_baked_length():
        follow.progress = 0
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/math/beziers_and_curves.rst`
