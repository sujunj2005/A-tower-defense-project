# 渲染基础概念

> **来源**: [09A_Rendering_Basics.md](../base/rendering/09A_Rendering_Basics.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

Godot 4.x 提供灵活的渲染系统，支持多种渲染器、分辨率适配和视口管理。本文档整合渲染基础核心概念，帮助快速掌握渲染配置。

---

## 1. 渲染器类型

Godot 4.x 提供三种渲染器，适用于不同平台和性能需求：

| 渲染器 | 说明 | 适用平台 |
|--------|------|----------|
| **Forward+** | 高端 PC 渲染器，支持完整特性 | 桌面平台（Windows/Linux/macOS） |
| **Mobile** | 移动设备优化渲染器 | 移动设备、Web |
| **Compatibility** | 兼容模式，支持老旧硬件 | 低端设备、集成显卡 |

### 1.1 选择渲染器

**路径**: 项目设置 → Application → Rendering → Renderer

- 在创建项目时选择，之后不可更改
- 不同渲染器有不同功能支持和性能特点

---

## 2. 多分辨率支持

### 2.1 基础窗口大小

**路径**: 项目设置 → Display → Window → Width/Height

**核心概念**:
- 设置的是**设计分辨率**，不是显示器分辨率
- Godot 不会自动更改显示器分辨率（避免崩溃后显示器卡在低分辨率）
- 推荐设置为游戏的目标分辨率（如 1920×1080）

### 2.2 运行时修改

```gdscript
func _ready():
    # 运行时修改设计分辨率
    get_tree().root.content_scale_size = Vector2i(1920, 1080)
```

> **踩坑点**: Godot 不会自动更改显示器分辨率，因为这可能导致游戏崩溃后显示器卡在低分辨率。

---

## 3. 拉伸模式（Stretch Mode）

拉伸模式控制如何将基础分辨率适配到屏幕。

### 3.1 Disabled（默认）

- **特点**: 不拉伸
- **行为**: 场景中 1 单位 = 屏幕 1 像素
- **Stretch Aspect**: 设置无效
- **适用场景**: 像素精确控制的游戏

### 3.2 Canvas Items

- **特点**: 2D 元素直接以目标分辨率渲染
- **行为**: 基础分辨率拉伸覆盖整个屏幕
- **3D 效果**: 3D 不受影响
- **缺点**: 可能出现缩放伪影
- **适用场景**: 现代 2D 游戏

```gdscript
func _ready():
    get_tree().root.content_scale_mode = Window.ContentScaleMode.CANVAS_ITEMS
```

### 3.3 Viewport ⭐

- **特点**: 先渲染到基础分辨率，再拉伸到屏幕
- **行为**: 根视口大小设为基础分辨率
- **优势**: 像素完美，无缩放伪影
- **适用场景**: **像素艺术游戏推荐**

```gdscript
func _ready():
    get_tree().root.content_scale_mode = Window.ContentScaleMode.VIEWPORT
```

---

## 4. 拉伸纵横比（Stretch Aspect）

控制如何保持或处理纵横比。

### 4.1 Ignore

- **行为**: 忽略纵横比，拉伸填满整个屏幕
- **缺点**: 可能导致图像变形
- **适用场景**: 不推荐，除非特殊需求

### 4.2 Keep

- **行为**: 保持纵横比，添加黑边（letterbox/pillarbox）
- **优势**: 图像不变形
- **适用场景**: 固定纵横比的游戏、过场动画

### 4.3 Keep Width ⭐

- **行为**: 保持宽度，垂直扩展
- **效果**: 
  - 宽屏时：左右黑边
  - 竖屏时：显示更多内容
- **适用场景**: **GUI/HUD 推荐选项**

### 4.4 Keep Height ⭐

- **行为**: 保持高度，水平扩展
- **效果**:
  - 竖屏时：上下黑边
  - 宽屏时：显示更多内容
- **适用场景**: **横版卷轴游戏推荐**

### 4.5 Expand ⭐⭐⭐

- **行为**: 保持纵横比，根据屏幕比例扩展宽度或高度
- **优势**: 最灵活，充分利用屏幕空间
- **适用场景**: **大多数游戏推荐**

```gdscript
func _ready():
    get_tree().root.content_scale_aspect = Window.ContentScaleAspect.EXPAND
```

---

## 5. 视口（Viewport）

### 5.1 Viewport 节点

视口是绘制世界的容器，可用于：
- 小地图
- 镜子效果
- 分屏多人游戏
- 渲染到纹理

### 5.2 基本用法

```gdscript
@onready var viewport = $SubViewport

func _ready():
    # 获取视口纹理
    var texture = viewport.get_texture()
    # 应用到 Sprite2D
    $Sprite2D.texture = texture
```

### 5.3 视口属性

| 属性 | 说明 |
|------|------|
| `size` | 视口大小（Vector2i） |
| `transparent_bg` | 透明背景 |
| `render_target_update_mode` | 更新模式（Always/Once/Disabled） |
| `canvas_item_default_texture_filter` | 纹理过滤（Linear/Nearest） |

### 5.4 使用场景

#### 小地图
```gdscript
# 创建独立的视口渲染小地图
var minimap_viewport = $MinimapViewport
var minimap_texture = minimap_viewport.get_texture()
$MinimapSprite.texture = minimap_texture
```

#### 镜子效果
```gdscript
# 创建镜像视口
var mirror_viewport = $MirrorViewport
mirror_viewport.size = Vector2i(512, 512)
```

#### 分屏游戏
```gdscript
# 创建两个视口实现分屏
var viewport1 = $Viewport1
var viewport2 = $Viewport2
viewport1.size = Vector2i(960, 1080)  # 左半屏
viewport2.size = Vector2i(960, 1080)  # 右半屏
```

---

## 6. 常见配置推荐

### 6.1 像素艺术游戏

```
基础分辨率：320×180 或 640×360
拉伸模式：viewport
拉伸纵横比：keep 或 expand
缩放模式：integer（项目设置 → Rendering → Texture Filter）
```

**说明**: 低分辨率 + viewport 模式确保像素完美，integer 缩放避免模糊。

### 6.2 现代 2D 游戏

```
基础分辨率：1920×1080
拉伸模式：canvas_items
拉伸纵横比：expand
纹理过滤：linear
```

**说明**: 高分辨率 + canvas_items 模式，适合高清 2D 游戏。

### 6.3 移动游戏

```
基础分辨率：1280×720
拉伸模式：canvas_items
拉伸纵横比：expand
纹理过滤：linear
```

**说明**: 中等分辨率平衡性能和画质，适合移动设备。

---

## 7. 配置对比表

| 游戏类型 | 基础分辨率 | 拉伸模式 | 纵横比 | 纹理过滤 |
|----------|-----------|---------|--------|---------|
| 像素艺术 | 320×180 | Viewport | Keep/Expand | Nearest |
| 现代 2D | 1920×1080 | Canvas Items | Expand | Linear |
| 移动游戏 | 1280×720 | Canvas Items | Expand | Linear |
| GUI/HUD | 1920×1080 | Canvas Items | Keep Width | Linear |
| 横版卷轴 | 1920×1080 | Canvas Items | Keep Height | Linear |

---

## 8. 常见踩坑

### 8.1 拉伸模式选择错误

**问题**: 像素艺术游戏使用 canvas_items 模式导致缩放伪影

**解决方案**: 使用 viewport 模式 + integer 缩放

### 8.2 忘记设置纵横比

**问题**: 在不同比例屏幕上图像变形

**解决方案**: 始终设置 content_scale_aspect 为 expand 或 keep

### 8.3 视口性能问题

**问题**: 过多视口导致性能下降

**解决方案**: 
- 减少视口数量
- 降低视口分辨率
- 使用 render_target_update_mode = Once（静态内容）

### 8.4 运行时修改分辨率失效

**问题**: 修改 content_scale_size 后没有生效

**解决方案**: 确保在 _ready() 或之后调用，不要放在构造函数中

---

## 9. 快速参考

### 9.1 关键 API

```gdscript
# 修改设计分辨率
get_tree().root.content_scale_size = Vector2i(1920, 1080)

# 设置拉伸模式
get_tree().root.content_scale_mode = Window.ContentScaleMode.VIEWPORT

# 设置纵横比
get_tree().root.content_scale_aspect = Window.ContentScaleAspect.EXPAND

# 获取视口纹理
var viewport = $SubViewport
var texture = viewport.get_texture()
```

### 9.2 枚举值

```gdscript
# ContentScaleMode
Window.ContentScaleMode.DISABLED      # 不拉伸
Window.ContentScaleMode.CANVAS_ITEMS  # 2D 拉伸
Window.ContentScaleMode.VIEWPORT      # 视口拉伸

# ContentScaleAspect
Window.ContentScaleAspect.IGNORE      # 忽略纵横比
Window.ContentScaleAspect.KEEP        # 保持纵横比
Window.ContentScaleAspect.KEEP_WIDTH  # 保持宽度
Window.ContentScaleAspect.KEEP_HEIGHT # 保持高度
Window.ContentScaleAspect.EXPAND      # 扩展
```

---

## 🔗 相关链接

- **Base 层来源**: [09A_Rendering_Basics.md](../base/rendering/09A_Rendering_Basics.md)
- **官方文档**: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
- **相关概念**: 
  - [2D 变换概念](./2d-transforms.md)
  - [2D 开发介绍](./2d-development-intro.md)

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
