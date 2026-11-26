# P1：PanelContainer 默认透明导致文字可读性差

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04-27 |
| **分类** | UI/样式 |
| **严重程度** | 🟡 中 |
| **涉及文件** | `scripts/ui/event_ui.gd` `_show_consequence_popup()` |
| **知识库关联** | [UI 开发模式](../best-practices/UI%20开发模式.md) |

---

## 现象

选项奖励弹框（后果展示弹窗）的背景呈半透明状态，导致叠加在下层 UI 元素上时文字几乎无法辨认，可读性极差。

用户点击选项后，弹出的奖励展示面板背景透出下层内容，文字与背景混在一起。

## 根因

Godot 4.x 的 `PanelContainer` 节点在未显式设置自定义 `StyleBox` 时，使用引擎默认主题（Theme）中的 `panel` 样式。该默认 StyleBox 的 `bg_color` 可能存在 alpha 通道非 1.0 的情况，导致面板背景半透明。

代码中仅创建了 `PanelContainer` 实例，未调用 `add_theme_stylebox_override("panel", ...)` 设置自定义样式。

## 修复

在 `_show_consequence_popup()` 函数中，为动态创建的 `PanelContainer` 显式设置不透明的 `StyleBoxFlat`：

```gdscript
func _show_consequence_popup(option: OptionData) -> void:
    # ... 其他代码 ...
    var panel := PanelContainer.new()
    var style_box := StyleBoxFlat.new()
    style_box.bg_color = Color(0.08, 0.08, 0.14, 1.0)  # alpha = 1.0，完全不透明
    style_box.set_corner_radius_all(16)
    style_box.border_width_left = 2
    style_box.border_color = Color(0.3, 0.3, 0.45, 1.0)
    panel.add_theme_stylebox_override("panel", style_box)
    # ... 继续构建 UI ...
```

**关键点**：`bg_color` 的 alpha 通道必须设为 `1.0`。

## 预防

1. **所有动态创建的 `PanelContainer` 必须显式设置 `StyleBoxFlat`**，不得依赖默认主题
2. `bg_color.a` 必须设为 `1.0`（完全不透明）
3. 同时设置合适的圆角（`set_corner_radius_all`）和边框，确保视觉一致性
4. 代码审查时将此作为必检项

---

*记录时间：2026-04-27*