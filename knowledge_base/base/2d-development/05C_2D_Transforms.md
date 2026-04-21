# Godot 4.x 2D 变换与坐标系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/2d_transforms.rst

---

## 目录

1. [⚡ 快速上手](#-快速上手)
2. [2D 变换概述](#1-2d-变换概述)
3. [Canvas 变换](#2-canvas-变换)
4. [视口变换](#3-视口变换)
5. [变换函数](#4-变换函数)
6. [自定义输入事件](#5-自定义输入事件)

---

## ⚡ 快速上手（5分钟掌握核心用法）

> **大多数2D游戏开发者只需要知道以下3件事**，详细原理可按需阅读后续章节。

### 你需要知道的

| 场景 | 做法 | 对应章节 |
|------|------|----------|
| **视差背景** | 用 `CanvasLayer` 节点 + `Parallax2D` | → [05H_Parallax](05H_Parallax.md) |
| **HUD/UI 固定** | 把UI放在单独的 `CanvasLayer`（layer值更高 = 显示更前） | §2 Canvas变换 |
| **坐标转换** | 用 `get_global_transform()` / `global_position`，避免手动算屏幕坐标 | §4 变换函数 |

### 常用代码速查

```gdscene
# ✅ 获取世界坐标（最常用）
var world_pos = $Sprite2D.global_position

# ✅ 将局部坐标转为世界坐标
var world_pos = get_global_transform() * local_pos

# ✅ 将世界坐标转回局部坐标
var local_pos = get_global_transform().affine_inverse() * world_pos

# ❌ 不要手动处理屏幕坐标！（除非做自定义InputEvent）
# 错误做法：手动乘以视口变换矩阵
```

### 何时需要深入阅读本文？

- 🔧 需要实现**自定义相机跟随**算法
- 🔧 需要发送**程序化 InputEvent**（如自动化测试）
- 🔧 遇到**多分辨率适配**怪异问题（物体位置偏移）
- 🔧 想理解引擎内部**变换管线**（Canvas→Viewport→Stretch→Screen）

> 💡 **如果以上都不是你的需求，直接跳到 [§2 Canvas 变换](#2-canvas-变换) 了解 CanvasLayer 用法即可。**

---

## 1. 2D 变换概述

### 1.1 变换链

从节点的局部坐标到屏幕坐标，会应用一系列变换：

```
局部坐标 → Canvas变换 → 视口变换 → 拉伸变换 → 屏幕坐标
```

每个 CanvasItem 节点（Node2D 和 Control）都在一个 Canvas Layer 中，每个图层都有自己的变换。

---

## 2. Canvas 变换

### 2.1 Canvas 图层

每个 CanvasItem 节点都在一个 Canvas Layer 中：

- 默认在图层 0（内置 Canvas）
- 使用 `CanvasLayer` 节点可以放置在其他图层
- 每个图层都有自己的 `Transform2D`（平移、旋转、缩放）

### 2.2 全局 Canvas 变换

视口也有全局 Canvas 变换，这是主变换，影响所有单独的 Canvas Layer 变换。

### 2.3 Canvas 变换顺序

1. Canvas Layer 变换
2. 全局 Canvas 变换

---

## 3. 视口变换

### 3.1 拉伸变换

每个视口都有拉伸变换，用于调整或拉伸屏幕大小。这个变换在内部使用（如多分辨率支持所述），但也可以手动在每个视口上设置。

### 3.2 输入事件处理

输入事件会乘以这个变换，但不包含上述变换。为了将 InputEvent 坐标转换为本地 CanvasItem 坐标，添加了 `CanvasItem.make_input_local()` 函数以方便使用。

### 3.3 窗口变换

根视口是 Window。为了按多分辨率支持中所述缩放和定位窗口内容，每个 Window 都包含一个窗口变换。例如，它负责在窗口两侧添加黑条，以便以固定的纵横比显示视口。

---

## 4. 变换函数

### 4.1 变换方向

所有变换从右向左，这意味着将变换与坐标相乘会导致坐标系更靠左；将变换的仿射逆相乘会导致坐标系更靠右。

### 4.2 全局变换转换

```gdscript
# 从 CanvasItem 调用
# 局部 → 全局 Canvas 坐标
var canvas_pos = get_global_transform() * local_pos
# 全局 Canvas → 局部
var local_pos = get_global_transform().affine_inverse() * canvas_pos
```

### 4.3 屏幕坐标转换

要将 CanvasItem 局部坐标转换为屏幕坐标，只需按以下顺序相乘：

```gdscript
var screen_coord = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * local_pos
```

> **踩坑点**：通常不希望使用屏幕坐标工作。推荐的方法是直接在 Canvas 坐标（`CanvasItem.get_global_transform()`）中工作，以便自动屏幕分辨率调整能够正常工作。

---

## 5. 自定义输入事件

### 5.1 发送自定义输入事件

通常需要向游戏提供自定义输入事件。利用上述知识，要在焦点窗口中正确地执行此操作，必须按以下方式进行：

```gdscript
var local_pos = Vector2(10, 20)  # 相对于 Control/Node2D 的局部坐标
var ie = InputEventMouseButton.new()
ie.button_index = MOUSE_BUTTON_LEFT
ie.position = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * local_pos
Input.parse_input_event(ie)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/2d/2d_transforms.rst`
