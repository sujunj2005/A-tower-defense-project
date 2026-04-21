# 视差滚动指南

> **来源**: [05H_Parallax.md](../../base/2d-development/05H_Parallax.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本指南介绍 Godot 4.x 的视差滚动系统，使用 Parallax2D 节点创建多层背景深度效果。

---

## 🎬 简介

**Parallax（视差滚动）** 是一种通过让不同纹理以不同速度相对于相机移动来模拟深度的效果。Godot 提供 `Parallax2D` 节点来实现此效果。

> ✅ **推荐**: 使用 `Parallax2D` 而非旧的 `ParallaxLayer` 和 `ParallaxBackground` 节点。

> 💡 **Godot 4.x（4.6+）新特性**
> 
> **Parallax2D 节点** 是 Godot 4.3 引入的新节点，相比旧的 ParallaxLayer 系统有以下改进：
> - **简化层级**: 不再需要 ParallaxBackground 和 ParallaxLayer 嵌套
> - **独立控制**: 每个 Parallax2D 节点独立控制滚动
> - **scroll_scale**: 直接设置滚动倍率，更直观
> - **repeat_size**: 支持无限重复，无需代码处理
> - **性能优化**: 更好的渲染性能
> 
> **迁移指南**: Godot 4.0-4.2 用户仍可使用 ParallaxLayer，但建议升级到 4.3+ 以获得更好的性能和易用性。

---

## ⚙️ 基本设置

### 开始使用

将需要独立滚动的节点作为各自 `Parallax2D` 节点的子节点。确保纹理的左上角位于 `(0, 0)` 交叉点处。

### Scroll Scale（滚动缩放）

`scroll_scale` 属性是视差效果的**核心**，作为滚动速度倍率：

| 值 | 效果 |
|------|------|
| **1** | 与相机同速 |
| **< 1** | 更慢，看起来更远（0=完全静止） |
| **> 1** | 更快，看起来更近 |

**典型多层视差配置示例**:

```gdscript
# 五层视差的典型 scroll_scale 值
var layers = {
    "Forest": Vector2(0.7, 1),      # 最近
    "Hills": Vector2(0.5, 1),
    "Lower Clouds": Vector2(0.3, 1),
    "Higher Clouds": Vector2(0.2, 1),
    "Sky": Vector2(0.1, 1)           # 最远
}
```

---

## 🔄 无限重复效果

### Repeat Size

`repeat_size` 属性让节点在相机滚动设定值时自动前向或后向 snap 位置，产生无限循环错觉。

### 常见问题：尺寸不当

**问题**: 纹理小于视口时，无限重复效果无法正常工作。

**解决方案（4 种）**:

#### 方案 1: 缩小视口
```
Project Settings > Display > Window
- 调整 Viewport Width/Height 匹配背景尺寸
```

#### 方案 2: 缩放 Parallax2D
```gdscript
$Parallax2D.scale = Vector2(2, 2)  # 放大以覆盖屏幕
```

#### 方案 3: 缩放子节点
```gdscript
$Sprite2D.scale = Vector2(2, 2)
```

> ⚠️ **踩坑点**: `repeat_size` 和 `region_rect` 不考虑缩放，必须基于缩放后的值调整。

#### 方案 4: 重复纹理
```gdscript
$Sprite2D.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
$Sprite2D.region_enabled = true
$Sprite2D.region_rect = Rect2(0, 0, texture_size * 2, texture_size * 2)
```

### 常见问题：位置错误

**错误做法**: 将所有纹理居中到 `(0, 0)`

**正确做法**:
- 无限重复画布从 `(0, 0)` 开始向右下扩展
- 确保所有纹理位于"无限重复画布"内
- 纹理左上角应在 `(0, 0)` 或正坐标区域

---

## 📍 Scroll Offset（滚动偏移）

如果视差纹理工作正常但希望从不同起点开始：

```gdscript
# 对于 288x208 的图像，从中间开始
$Parallax2D.scroll_offset = Vector2(-144, 0)  # 或 (144, 0)
```

---

## 🔁 Repeat Times（重复次数）

### 使用场景

当相机缩小（zoom < 1）时，默认设置的纹理可能不够大。此时可使用 `repeat_times`：

```gdscript
# 设置为 3（前后各多一个重复）
$Parallax2D.repeat_times = 3
```

> **注意**: 如果设置了 y 方向的 `repeat_size`，会自动在上下方向也添加重复。

---

## 🎮 分屏游戏中的视差

### 问题

多个相机共享视差效果时，纹理无法同时出现在两个位置。

### 解决方案

使用 **visibility_layer** 和 **canvas_cull_mask** 配合：

```gdscript
# 步骤 1：所有视差节点保持默认 visibility_layer = 1

# 步骤 2：第一个 SubViewport
$sub_viewport_1.canvas_cull_mask = 1 | 2  # 显示层 1 和 2

# 步骤 3：第二个 SubViewport
$sub_viewport_2.canvas_cull_mask = 1 | 3  # 显示层 1 和 3

# 步骤 4：第一个 SubViewport 的视差父节点
$parallax_parent_1.visibility_layer = 2

# 步骤 5：第二个 SubViewport 的视差父节点
$parallax_parent_2.visibility_layer = 3
```

**原理**: 当 CanvasItem 的 `visibility_layer` 不匹配 SubViewport 的 `canvas_cull_mask` 时，该节点及其子节点将被隐藏。

---

## 🎨 完整示例代码

```gdscript
extends Node2D

func _ready():
    setup_parallax()

func setup_parallax():
    # 创建五层视差背景
    var layer_configs = [
        {"name": "Sky", "scale": Vector2(0.1, 1), "z_index": -5},
        {"name": "Clouds_Far", "scale": Vector2(0.2, 1), "z_index": -4},
        {"name": "Clouds_Near", "scale": Vector2(0.3, 1), "z_index": -3},
        {"name": "Hills", "scale": Vector2(0.5, 1), "z_index": -2},
        {"name": "Forest", "scale": Vector2(0.7, 1), "z_index": -1},
    ]

    for config in layer_configs:
        var parallax = Parallax2D.new()
        parallax.name = config["name"]
        parallax.scroll_scale = config["scale"]
        parallax.z_index = config["z_index"]

        # 添加精灵子节点
        var sprite = Sprite2D.new()
        sprite.texture = load("res://assets/%s.png" % config["name"])
        parallax.add_child(sprite)

        # 配置无限重复
        var texture_size = sprite.texture.get_size()
        parallax.repeat_size = texture_size

        add_child(parallax)

# 动态调整视差速度
func set_parallax_speed(layer_name: String, speed_multiplier: float):
    var node = get_node_or_null(layer_name)
    if node and node is Parallax2D:
        node.scroll_scale.x *= speed_multiplier
```

---

## ⚠️ 常见踩坑

### 踩坑 1: 纹理定位错误

**问题**: 视差背景不滚动或滚动异常

**解决方案**:
- 确保纹理左上角在 (0, 0)
- 检查 scroll_scale 设置是否合理

### 踩坑 2: 无限重复不生效

**问题**: 背景滚动时出现空白区域

**解决方案**:
- 确保 repeat_size ≥ 视口尺寸
- 缩放后重新计算 repeat_size

### 踩坑 3: 性能问题

**问题**: 多层视差导致性能下降

**解决方案**:
- 减少视差层数
- 使用 z_index 优化渲染顺序
- 避免大面积光源影响视差

---

## 🔗 相关链接

### 前置知识
- [2D 变换概念](../concepts/2d-transforms.md) - Canvas 变换
- [2D 开发介绍](../concepts/2d-development-intro.md) - Node2D 基础

### 后续学习
- [2D 灯光和阴影概念](../concepts/2d-lights-shadows.md) - 配合光照
- [TileMap 概念](../concepts/tilemaps-concept.md) - 多层地图

### Base 层来源
- [05H_Parallax.md](../../base/2d-development/05H_Parallax.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
