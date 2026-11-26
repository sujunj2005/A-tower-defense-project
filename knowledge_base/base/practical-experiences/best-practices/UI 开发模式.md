# UI 开发模式

本项目的 UI 采用代码动态构建为主、场景文件为辅的模式。

## 🔴 强制规范

### 1. PanelContainer 显式样式化

所有动态创建的 `PanelContainer` 必须显式设置 `StyleBoxFlat`，`bg_color.a` 必须设为 `1.0`（完全不透明），不得依赖默认主题。

```gdscript
# 正确写法
var panel := PanelContainer.new()
var style_box := StyleBoxFlat.new()
style_box.bg_color = Color(0.1, 0.1, 0.15, 1.0)   # alpha = 1.0
style_box.set_corner_radius_all(12)
style_box.border_width_left = 2
style_box.border_color = Color(0.3, 0.3, 0.4, 1.0)
panel.add_theme_stylebox_override("panel", style_box)

# 错误写法（依赖默认主题，可能半透明）
var panel := PanelContainer.new()
# 直接使用——背景可能半透明，文字可读性差
```

### 2. 锚点设置顺序

```gdscript
# 正确顺序：先 preset，后调整偏移
panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
panel.offset_left = -300
panel.offset_right = 300

# 错误顺序：先设偏移再 preset，偏移会被覆盖
```

## 🟡 建议规范

### 3. 弹窗 UI 结构模式

```gdscript
# 推荐弹窗结构：ColorRect 背景 → PanelContainer 主面板 → VBoxContainer 内容区
func _build_popup() -> void:
    # 1. 半透明遮罩背景
    var bg := ColorRect.new()
    bg.color = Color(0, 0, 0, 0.5)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    # 2. 主面板（居中，固定宽度）
    var panel := PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    panel.offset_left = -320
    panel.offset_right = 320
    panel.offset_top = -200
    panel.offset_bottom = 200

    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.08, 0.08, 0.12, 1.0)
    style.set_corner_radius_all(16)
    panel.add_theme_stylebox_override("panel", style)
    add_child(panel)

    # 3. 内容区（VBoxContainer）
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 16)
    vbox.offset_left = 24
    vbox.offset_right = -24
    vbox.offset_top = 20
    vbox.offset_bottom = -20
    panel.add_child(vbox)

    # 4. 添加具体内容
    _add_content(vbox)
```

### 4. 按钮样式统一

```gdscript
static func create_styled_button(text_key: String) -> Button:
    var btn := Button.new()
    btn.text = tr(text_key)
    btn.add_theme_color_override("font_color", Color.WHITE)
    btn.add_theme_font_size_override("font_size", 16)
    btn.size_flags_horizontal = Control.SIZE_FILL
    btn.custom_minimum_size = Vector2(0, 44)
    return btn
```

## 参考来源

- 项目 `scripts/ui/event_ui.gd` — `_show_consequence_popup()` 弹窗构建
- 踩坑记录：PanelContainer 默认透明（pitfalls/P1）
