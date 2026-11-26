# UI 系统基础

Godot 4.x 的 UI 系统基于 Control 节点，提供完整的布局、主题和事件处理。

## 1. Control 节点

```gdscript
# 锚点与偏移（自动布局）
control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
# 常用预设：CENTER、FULL_RECT、TOP_WIDE、BOTTOM_WIDE 等

# 大小设置
control.custom_minimum_size = Vector2(200, 100)
control.size_flags_horizontal = Control.SIZE_FILL
```

## 2. 常用容器

```gdscript
# VBoxContainer — 垂直排列子节点
var vbox := VBoxContainer.new()
vbox.add_theme_constant_override("separation", 12)

# HBoxContainer — 水平排列
var hbox := HBoxContainer.new()

# PanelContainer — 带背景面板
var panel := PanelContainer.new()
# 重要：默认主题可能带透明度，需显式设置 StyleBoxFlat
var style_box := StyleBoxFlat.new()
style_box.bg_color = Color(0.1, 0.1, 0.15, 1.0)  # alpha 必须 1.0
style_box.set_corner_radius_all(12)
panel.add_theme_stylebox_override("panel", style_box)

# MarginContainer — 边距容器
var margin := MarginContainer.new()
margin.add_theme_constant_override("margin_left", 20)
```

## 3. 常用控件

```gdscript
# Label
var label := Label.new()
label.text = "Hello World"
label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

# Button
var button := Button.new()
button.text = "确认"
button.pressed.connect(_on_button_pressed)

# ColorRect — 纯色背景
var bg := ColorRect.new()
bg.color = Color(0.06, 0.06, 0.1, 1.0)
bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

# 滚动容器
var scroll := ScrollContainer.new()
scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
```

## 4. 动态创建 UI

```gdscript
# 动态创建完整的 UI 结构
func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.06, 0.06, 0.1, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var panel := PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    panel.offset_left = -300
    panel.offset_right = 300
    add_child(panel)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12)
    panel.add_child(vbox)
```

## 5. 主题系统

```gdscript
# 控件级别的主题覆盖
button.add_theme_color_override("font_color", Color.RED)
button.add_theme_font_size_override("font_size", 18)

# StyleBox 类型
StyleBoxFlat    # 纯色/渐变背景，支持圆角、边框
StyleBoxTexture # 纹理背景
StyleBoxLine    # 线型边框
```

## 6. 翻译文本

```gdscript
# 翻译函数
label.text = tr("WELCOME_MESSAGE")
# 带参数的翻译
label.text = tr("GOLD_FORMAT") % [gold_amount]
```

## 重要注意事项

- **PanelContainer 默认透明度**：Godot 默认主题的 panel StyleBox 可能有透明度，动态创建时必须显式设置 `StyleBoxFlat` 且 `bg_color.a = 1.0`
- **锚点设置顺序**：先设置 anchor preset，再调整偏移量
- **add_child 后设置属性**：部分属性在加入场景树后才能生效

## 参考来源

- Godot 4.x 官方文档：Control / UI system
- 项目 `scripts/ui/event_ui.gd` — 动态 UI 构建实例
