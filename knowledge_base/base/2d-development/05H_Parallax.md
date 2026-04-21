# 2D 视差滚动 (Parallax2D)

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/2d_parallax.rst

---

## 一、简介

**Parallax（视差滚动）** 是一种通过让不同纹理以不同速度相对于相机移动来模拟深度的效果。Godot 提供 `Parallax2D` 节点来实现此效果。

> **推荐**：使用 `Parallax2D` 而非旧的 `ParallaxLayer` 和 `ParallaxBackground` 节点。

---

## 二、基本设置

### 2.1 开始使用

将需要独立滚动的节点作为各自 `Parallax2D` 节点的子节点。确保纹理的左上角位于 `(0, 0)` 交叉点处。

### 2.2 Scroll Scale（滚动缩放）

`scroll_scale` 属性是视差效果的**核心**，作为滚动速度倍率：

| 值 | 效果 |
|---|------|
| **1** | 与相机同速 |
| **< 1** | 更慢，看起来更远（0=完全静止） |
| **> 1** | 更快，看起来更近 |

**典型多层视差配置示例：**

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

## 三、无限重复效果

### 3.1 Repeat Size

`repeat_size` 属性让节点在相机滚动设定值时自动前向或后向 snap 位置，产生无限循环错觉。

### 3.2 常见问题：尺寸不当

**问题**：纹理小于视口时，无限重复效果无法正常工作。

**解决方案（4种）：**

#### 方案1：缩小视口
```
Project Settings > Display > Window
- 调整 Viewport Width/Height 匹配背景尺寸
```

#### 方案2：缩放 Parallax2D
```gdscript
$Parallax2D.scale = Vector2(2, 2)  # 放大以覆盖屏幕
```

#### 方案3：缩放子节点
```gdscript
$Sprite2D.scale = Vector2(2, 2)
```

> **踩坑点**：`repeat_size` 和 `region_rect` 不考虑缩放，必须基于缩放后的值调整。

#### 方案4：重复纹理
```gdscript
$Sprite2D.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
$Sprite2D.region_enabled = true
$Sprite2D.region_rect = Rect2(0, 0, texture_size * 2, texture_size * 2)
```

### 3.3 常见问题：位置错误

**错误做法**：将所有纹理居中到 `(0, 0)`

**正确做法**：
- 无限重复画布从 `(0, 0)` 开始向右下扩展
- 确保所有纹理位于"无限重复画布"内
- 纹理左上角应在 `(0, 0)` 或正坐标区域

---

## 四、Scroll Offset（滚动偏移）

如果视差纹理工作正常但希望从不同起点开始：

```gdscript
# 对于 288x208 的图像，从中间开始
$Parallax2D.scroll_offset = Vector2(-144, 0)  # 或 (144, 0)
```

---

## 五、Repeat Times（重复次数）

### 使用场景

当相机缩小（zoom < 1）时，默认设置的纹理可能不够大。此时可使用 `repeat_times`：

```gdscript
# 设置为 3（前后各多一个重复）
$Parallax2D.repeat_times = 3
```

> **注意**：如果设置了 y 方向的 `repeat_size`，会自动在上下方向也添加重复。

### 调整技巧

对于纯水平视差，上下空白区域可通过拉伸天空和草地来解决。

---

## 六、分屏游戏中的视差

### 问题

多个相机共享视差效果时，纹理无法同时出现在两个位置。

### 解决方案

使用 **visibility_layer** 和 **canvas_cull_mask** 配合：

```gdscript
# 步骤1：所有视差节点保持默认 visibility_layer = 1

# 步骤2：第一个 SubViewport
$sub_viewport_1.canvas_cull_mask = 1 | 2  # 显示层1和2

# 步骤3：第二个 SubViewport
$sub_viewport_2.canvas_cull_mask = 1 | 3  # 显示层1和3

# 步骤4：第一个 SubViewport 的视差父节点
$parallax_parent_1.visibility_layer = 2

# 步骤5：第二个 SubViewport 的视差父节点
$parallax_parent_2.visibility_layer = 3
```

**原理**：当 CanvasItem 的 `visibility_layer` 不匹配 SubViewport 的 `canvas_cull_mask` 时，该节点及其子节点将被隐藏。

---

## 七、编辑器预览

### 方法1：使用 CanvasLayer 替代 ParallaxBackground（4.3之前的方法）

### 方法2：使用插件

推荐 KoBeWi 的 **"Parallax2D Preview"** 插件：
- GitHub: https://github.com/KoBeWi/Godot-Parallax2D-Preview
- 提供多种预览模式

---

## 八、完整示例代码

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

## 九、最佳实践总结

| 要点 | 建议 |
|------|------|
| **纹理定位** | 左上角必须在 (0,0) |
| **repeat_size** | ≥ 视口尺寸 |
| **scroll_scale** | 远层用小值（0.1-0.3），近层用大值（0.5-0.9） |
| **缩放处理** | 缩放后需重新计算 repeat_size |
| **分屏支持** | 使用 visibility_layer + canvas_cull_mask |
| **性能** | 大面积光源会影响视差性能 |

---

## 十、参考链接

- [Parallax2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_parallax2d.html)
- [2D transforms 文档](05C_2D_Transforms.md)
- [Camera2D 文档](../05_2D_Development/)
