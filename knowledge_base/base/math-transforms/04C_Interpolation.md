# Godot 4.x 插值运算

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/math/interpolation.rst

---

## 目录

1. [插值概述](#1-插值概述)
2. [向量插值](#2-向量插值)
3. [变换插值](#3-变换插值)
4. [平滑移动](#4-平滑移动)
5. [帧率无关插值](#5-帧率无关插值)

---

## 1. 插值概述

### 1.1 基本概念

插值用于在两个值之间平滑过渡。使用参数 `t` 表示中间状态：

- `t = 0`：状态 A
- `t = 1`：状态 B
- `0 < t < 1`：中间状态

### 1.2 线性插值公式

```
interpolation = A * (1 - t) + B * t
// 简化为：
interpolation = A + (B - A) * t
```

这种以恒定速度变换的插值称为**线性插值**（Linear Interpolation，简称 lerp）。

---

## 2. 向量插值

### 2.1 lerp()

Vector2 和 Vector3 提供 `lerp()` 方法：

```gdscript
var t = 0.0

func _physics_process(delta):
    t += delta * 0.4
    $Sprite2D.position = $A.position.lerp($B.position, t)
```

### 2.2 cubic_interpolate()

三次插值，使用贝塞尔风格：

```gdscript
var result = a.cubic_interpolate(b, pre_a, post_b, t)
```

---

## 3. 变换插值

### 3.1 interpolate_with()

Transform3D 可以整体插值：

```gdscript
var t = 0.0

func _physics_process(delta):
    t += delta
    $Monkey.transform = $Position1.transform.interpolate_with($Position2.transform, t)
```

> **踩坑点**：变换插值要求两个变换具有统一缩放，或至少相同的非统一缩放。

---

## 4. 平滑移动

### 4.1 基本平滑跟随

使用 lerp 实现平滑跟随目标：

```gdscript
const FOLLOW_SPEED = 4.0

func _physics_process(delta):
    var mouse_pos = get_local_mouse_position()
    $Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, delta * FOLLOW_SPEED)
```

### 4.2 应用场景

- 相机平滑跟随
- 盟友跟随玩家
- UI 元素动画

---

## 5. 帧率无关插值

### 5.1 问题

上述 lerp 公式是帧率相关的，因为 `weight` 参数表示剩余差异的百分比，而非绝对变化量。

### 5.2 解决方案

使用指数衰减公式实现帧率无关：

```gdscript
const FOLLOW_SPEED = 4.0

func _process(delta):
    var mouse_pos = get_local_mouse_position()
    var weight = 1 - exp(-FOLLOW_SPEED * delta)
    $Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, weight)
```

### 5.3 公式推导

```
weight = 1 - exp(-speed * delta)
```

这个公式确保：
- 在 60 FPS 下运行 1 秒后，物体移动到目标的约 98%
- 在 30 FPS 下运行 1 秒后，结果相同

> **踩坑点**：在 `_physics_process()` 中使用简单 lerp 通常没问题，因为物理帧率是固定的。但在 `_process()` 中应使用帧率无关公式。

---

## 6. 其他插值方法

### 6.1 smoothstep()

平滑阶跃插值：

```gdscript
var t = smoothstep(0.0, 1.0, x)  # 缓入缓出
```

### 6.2 ease()

缓动函数：

```gdscript
var t = ease(x, 2.0)  # 各种缓动曲线
```

### 6.3 slerp()

球面线性插值（用于 3D 旋转）：

```gdscript
var result = a.slerp(b, t)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/math/interpolation.rst`
