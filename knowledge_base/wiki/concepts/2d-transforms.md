# 2D 变换概念

> **来源**: [05C_2D_Transforms.md](../../base/2d-development/05C_2D_Transforms.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本文档介绍 Godot 4.x 中的 2D 变换系统，包括坐标变换链、Canvas 变换、视口变换和常用变换函数。

---

## 🔄 变换链

从节点的局部坐标到屏幕坐标，会应用一系列变换：

```
局部坐标 → Canvas 变换 → 视口变换 → 拉伸变换 → 屏幕坐标
```

每个 CanvasItem 节点（Node2D 和 Control）都在一个 Canvas Layer 中，每个图层都有自己的变换。

---

## 🎨 Canvas 变换

### Canvas 图层

每个 CanvasItem 节点都在一个 Canvas Layer 中：

- **默认**: 在图层 0（内置 Canvas）
- **CanvasLayer 节点**: 可以放置在其他图层
- **每个图层**: 都有自己的 `Transform2D`（平移、旋转、缩放）

### 全局 Canvas 变换

视口也有全局 Canvas 变换，这是主变换，影响所有单独的 Canvas Layer 变换。

### Canvas 变换顺序

1. Canvas Layer 变换
2. 全局 Canvas 变换

---

## 🖥️ 视口变换

### 拉伸变换

每个视口都有拉伸变换，用于调整或拉伸屏幕大小。这个变换在内部使用（如多分辨率支持）。

### 输入事件处理

输入事件会乘以这个变换，但不包含上述变换。为了将 InputEvent 坐标转换为本地 CanvasItem 坐标，添加了 `CanvasItem.make_input_local()` 函数。

### 窗口变换

根视口是 Window。为了缩放和定位窗口内容，每个 Window 都包含一个窗口变换。例如，它负责在窗口两侧添加黑条，以便以固定的纵横比显示视口。

---

## 🔧 变换函数

### 变换方向

所有变换**从右向左**：
- 将变换与坐标相乘 → 坐标系更靠左
- 将变换的仿射逆相乘 → 坐标系更靠右

### 全局变换转换

```gdscript
# 从 CanvasItem 调用
# 局部 → 全局 Canvas 坐标
var canvas_pos = get_global_transform() * local_pos

# 全局 Canvas → 局部
var local_pos = get_global_transform().affine_inverse() * canvas_pos
```

### 屏幕坐标转换

要将 CanvasItem 局部坐标转换为屏幕坐标：

```gdscript
var screen_coord = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * local_pos
```

> ⚠️ **踩坑点**: 通常不希望使用屏幕坐标工作。推荐的方法是直接在 Canvas 坐标（`CanvasItem.get_global_transform()`）中工作，以便自动屏幕分辨率调整能够正常工作。

---

## 📝 自定义输入事件

### 发送自定义输入事件

通常需要向游戏提供自定义输入事件：

```gdscript
var local_pos = Vector2(10, 20)  # 相对于 Control/Node2D 的局部坐标
var ie = InputEventMouseButton.new()
ie.button_index = MOUSE_BUTTON_LEFT
ie.position = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * local_pos
Input.parse_input_event(ie)
```

---

## 💡 快速上手（5 分钟掌握核心用法）

### 你需要知道的 3 件事

| 场景 | 做法 | 对应章节 |
|------|------|----------|
| **视差背景** | 用 `Parallax2D` 节点 + `CanvasLayer` | → [视差滚动指南](../guides/parallax-guide.md) |
| **HUD/UI 固定** | 把 UI 放在单独的 `CanvasLayer`（layer 值更高 = 显示更前） | § Canvas 变换 |
| **坐标转换** | 用 `get_global_transform()` / `global_position`，避免手动算屏幕坐标 | § 变换函数 |

### 常用代码速查

```gdscript
# ✅ 获取世界坐标（最常用）
var world_pos = $Sprite2D.global_position

# ✅ 将局部坐标转为世界坐标
var world_pos = get_global_transform() * local_pos

# ✅ 将世界坐标转回局部坐标
var local_pos = get_global_transform().affine_inverse() * world_pos

# ❌ 不要手动处理屏幕坐标！（除非做自定义 InputEvent）
```

### 何时需要深入阅读本文？

- 🔧 需要实现**自定义相机跟随**算法
- 🔧 需要发送**程序化 InputEvent**（如自动化测试）
- 🔧 遇到**多分辨率适配**怪异问题（物体位置偏移）
- 🔧 想理解引擎内部**变换管线**（Canvas→Viewport→Stretch→Screen）

> 💡 **如果以上都不是你的需求，直接跳到 § Canvas 变换 了解 CanvasLayer 用法即可。**

---

## 🎯 实际应用

### CanvasLayer 使用场景

1. **UI 层**: 将 UI 放在高图层，确保始终显示在最前
2. **视差背景**: 使用不同图层的 CanvasLayer 实现视差效果
3. **暂停菜单**: 独立的 CanvasLayer 便于管理

```gdscript
# 创建 UI 层
var ui_layer = CanvasLayer.new()
ui_layer.layer = 10  # 高层级，显示在前
add_child(ui_layer)

# 添加 UI 节点
var hud = load("res://scenes/ui/hud.tscn").instantiate()
ui_layer.add_child(hud)
```

### 坐标转换技巧

```gdscript
# 获取节点的世界位置
func get_node_world_position(node: Node2D) -> Vector2:
    return node.global_position

# 将世界坐标转换为节点局部坐标
func world_to_local(node: Node2D, world_pos: Vector2) -> Vector2:
    return node.get_global_transform().affine_inverse() * world_pos

# 将节点局部坐标转换为世界坐标
func local_to_world(node: Node2D, local_pos: Vector2) -> Vector2:
    return node.get_global_transform() * local_pos
```

---

## ⚠️ 常见踩坑

### 踩坑 1: 手动处理屏幕坐标

**错误做法**:
```gdscript
# ❌ 不要这样做
var screen_pos = get_viewport().get_visible_rect().size / 2
```

**正确做法**:
```gdscript
# ✅ 使用 Canvas 坐标
var canvas_pos = Vector2.ZERO  # Canvas 原点
```

### 踩坑 2: 忽略 CanvasLayer 的影响

**问题**: 子节点的坐标受到 CanvasLayer 变换的影响

**解决方案**:
- 使用 `global_position` 而非 `position`
- 明确知道当前节点在哪个 CanvasLayer 中

---

## 🔗 相关链接

### 前置知识
- [向量数学](vector-math.md) - 理解向量操作
- [2D 开发介绍](2d-development-intro.md) - 2D 工作区基础

### 后续学习
- [视差滚动指南](../guides/parallax-guide.md) - CanvasLayer 的实际应用
- [2D 移动指南](../guides/2d-movement-guide.md) - 移动中的坐标变换

### Base 层来源
- [05C_2D_Transforms.md](../../base/2d-development/05C_2D_Transforms.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
