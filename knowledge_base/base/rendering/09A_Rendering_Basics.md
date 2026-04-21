# Godot 4.x 渲染系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/rendering/multiple_resolutions.rst

---

## 目录

1. [渲染器概述](#1-渲染器概述)
2. [多分辨率支持](#2-多分辨率支持)
3. [拉伸模式](#3-拉伸模式)
4. [拉伸纵横比](#4-拉伸纵横比)
5. [视口](#5-视口)

---

## 1. 渲染器概述

### 1.1 渲染器类型

Godot 4.x 提供三种渲染器：

| 渲染器 | 说明 | 适用平台 |
|--------|------|----------|
| Forward+ | 高端 PC | 桌面平台 |
| Mobile | 移动设备 | 移动、Web |
| Compatibility | 兼容模式 | 低端设备 |

### 1.2 选择渲染器

在项目设置 → Application → Rendering → Renderer

---

## 2. 多分辨率支持

### 2.1 基础窗口大小

在项目设置 → Display → Window 中设置：

- **Window Width/Height**：设计分辨率
- 这不是切换显示器分辨率，而是"设计尺寸"

### 2.2 运行时修改

```gdscript
func _ready():
    get_tree().root.content_scale_size = Vector2i(1920, 1080)
```

> **踩坑点**：Godot 不会自动更改显示器分辨率，因为这可能导致游戏崩溃后显示器卡在低分辨率。

---

## 3. 拉伸模式

### 3.1 Disabled（默认）

- 不拉伸
- 场景中 1 单位 = 屏幕 1 像素
- Stretch Aspect 设置无效

### 3.2 Canvas Items

- 基础分辨率拉伸覆盖整个屏幕
- 2D 元素直接以目标分辨率渲染
- 3D 不受影响
- 可能出现缩放伪影

### 3.3 Viewport

- 根视口大小设为基础分辨率
- 先渲染到基础分辨率，再拉伸到屏幕
- 像素艺术游戏推荐

```gdscript
func _ready():
    get_tree().root.content_scale_mode = Window.ContentScaleMode.VIEWPORT
```

---

## 4. 拉伸纵横比

### 4.1 Ignore

- 忽略纵横比
- 拉伸填满整个屏幕
- 可能导致变形

### 4.2 Keep

- 保持纵横比
- 黑边（letterbox/pillarbox）
- 适合固定纵横比的游戏

### 4.3 Keep Width

- 保持宽度，垂直扩展
- 宽屏时左右黑边
- 竖屏时显示更多内容
- **GUI/HUD 推荐选项**

### 4.4 Keep Height

- 保持高度，水平扩展
- 竖屏时上下黑边
- 宽屏时显示更多内容
- **横版卷轴游戏推荐**

### 4.5 Expand

- 保持纵横比
- 根据屏幕比例扩展宽度或高度
- **最灵活的选项**

```gdscript
func _ready():
    get_tree().root.content_scale_aspect = Window.ContentScaleAspect.EXPAND
```

---

## 5. 视口

### 5.1 Viewport 节点

视口是绘制世界的容器：

```gdscript
@onready var viewport = $SubViewport

func _ready():
    var texture = viewport.get_texture()
    $Sprite2D.texture = texture
```

### 5.2 视口属性

| 属性 | 说明 |
|------|------|
| `size` | 视口大小 |
| `transparent_bg` | 透明背景 |
| `render_target_update_mode` | 更新模式 |
| `canvas_item_default_texture_filter` | 纹理过滤 |

### 5.3 使用场景

- 小地图
- 镜子效果
- 分屏多人游戏
- 渲染到纹理

---

## 6. 常见配置

### 6.1 像素艺术游戏

```
基础分辨率：320×180 或 640×360
拉伸模式：viewport
拉伸纵横比：keep 或 expand
缩放模式：integer
```

### 6.2 现代 2D 游戏

```
基础分辨率：1920×1080
拉伸模式：canvas_items
拉伸纵横比：expand
```

### 6.3 移动游戏

```
基础分辨率：1280×720
拉伸模式：canvas_items
拉伸纵横比：expand
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/rendering/multiple_resolutions.rst`
