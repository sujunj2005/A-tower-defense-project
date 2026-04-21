# UI 容器概念

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [07A_Containers_Detailed.md](../base/ui-system/07A_Containers_Detailed.md)

---

## 📋 概述

**UI 容器**（Container）是 Godot 4.x 中用于复杂 UI 布局的强大工具。与锚点系统相比，容器更适合处理复杂 UI（如 RPG、聊天、模拟经营、工具类应用）。

**核心特点**:
- 子 Control 节点放弃自己的定位能力
- 容器控制子节点的位置
- 容器调整大小时自动重新排列子节点
- 手动修改子节点位置会被容器覆盖

---

## 🎯 尺寸选项

容器的子节点可以通过以下尺寸选项控制布局行为：

### 1. Fill（填充）

确保控件填充容器内的指定区域，默认启用。

### 2. Expand（扩展）

尝试使用尽可能多的空间：
- 不扩展的控件被推到一边
- 扩展控件之间按 **Stretch Ratio** 分配空间

### 3. Shrink 模式（收缩模式）

| 模式 | 说明 |
|------|------|
| **Shrink Begin** | 扩展时靠左/上 |
| **Shrink Center** | 扩展时居中 |
| **Shrink End** | 扩展时靠右/下 |

### 4. Stretch Ratio（拉伸比例）

扩展控件之间的空间分配比例：
- 比例为 2 的控件占用比例为 1 的两倍空间

```gdscript
# 代码设置示例
size_flags_horizontal = Control.SIZE_EXPAND_FILL
size_flags_stretch_ratio = 2.0
```

---

## 📦 容器类型详解

### 1. BoxContainer

**HBoxContainer** 和 **VBoxContainer**

水平或垂直排列子控件：

```
[HBoxContainer]
  [Button1] [Button2] [Button3]

[VBoxContainer]
  [Button1]
  [Button2]
  [Button3]
```

**代码创建**:
```gdscript
var hbox = HBoxContainer.new()
var btn1 = Button.new()
btn1.text = "Button 1"
hbox.add_child(btn1)
add_child(hbox)
```

### 2. GridContainer

网格布局排列子控件，必须指定列数：

```
[GridContainer] (columns = 3)
  [Btn1] [Btn2] [Btn3]
  [Btn4] [Btn5] [Btn6]
```

```gdscript
var grid = GridContainer.new()
grid.columns = 3
add_child(grid)
```

### 3. MarginContainer

子控件扩展到边界，添加内边距：

```
[MarginContainer]
  [内容区域]
  ↑ 边距
```

> **踩坑点**: 边距是 Theme 值，需要在 Theme Overrides → Constants 中设置。

### 4. TabContainer

子控件堆叠显示，通过标签切换：

```
[TabContainer]
  [Tab1 内容] (隐藏)
  [Tab2 内容] (显示)
  [Tab3 内容] (隐藏)
```

标签标题默认使用节点名称。

### 5. SplitContainer

**HSplitContainer** 和 **VSplitContainer**

子控件之间有可拖动的分隔条：

```
[HSplitContainer]
  [LeftPanel] | [RightPanel]
            ↑ 可拖动
```

### 6. PanelContainer

绘制 StyleBox 背景，子控件覆盖整个区域：

```
[PanelContainer]
  [背景]
  [子控件]
```

### 7. ScrollContainer

接受单个子节点，超出时显示滚动条：

```
[ScrollContainer]
  [VBoxContainer]
    [Item1]
    [Item2]
    ...
```

```gdscript
var scroll = ScrollContainer.new()
scroll.custom_minimum_size = Vector2(200, 300)
var vbox = VBoxContainer.new()
scroll.add_child(vbox)
add_child(scroll)
```

### 8. AspectRatioContainer

保持子控件比例：

```gdscript
var container = AspectRatioContainer.new()
container.ratio = 16.0 / 9.0  # 16:9 比例
container.stretch_mode = AspectRatioContainer.STRETCH_MODE_KEEP
```

### 9. FlowContainer

**HFlowContainer** 和 **VFlowContainer**

空间不足时自动换行：

```
[HFlowContainer]
  [Btn1] [Btn2] [Btn3]
  [Btn4] [Btn5]
  ↑ 自动换行
```

### 10. CenterContainer

子控件居中显示：

```
[CenterContainer]
      [子控件]
      ↑ 居中
```

---

## 🔗 嵌套容器

### 复杂布局示例

```
[MarginContainer]
  [VBoxContainer]
    [Label] "标题"
    [HSplitContainer]
      [VBoxContainer]
        [Label] "左侧"
        [ScrollContainer]
          [VBoxContainer]
            [Item1]
            [Item2]
      [VBoxContainer]
        [Label] "右侧"
        [Button] "操作"
```

### 常见布局模式

#### 1. 顶部标题 + 内容

```
[VBoxContainer]
  [Label] "标题"
  [PanelContainer]
    [内容]
```

#### 2. 侧边栏 + 主内容

```
[HSplitContainer]
  [VBoxContainer]  # 侧边栏
    [Button]
    [Button]
  [VBoxContainer]  # 主内容
    [内容]
```

#### 3. 底部按钮栏

```
[VBoxContainer]
  [内容] size_flags_vertical = SIZE_EXPAND_FILL
  [HBoxContainer]
    [Spacer] size_flags_horizontal = SIZE_EXPAND_FILL
    [Button] "取消"
    [Button] "确定"
```

---

## 💻 代码创建容器示例

```gdscript
func _ready():
    # 创建主容器
    var vbox = VBoxContainer.new()
    vbox.anchors_preset = Control.PRESET_FULL_RECT
    add_child(vbox)
    
    # 添加标题
    var title = Label.new()
    title.text = "设置"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)
    
    # 添加分隔线
    var hsep = HSeparator.new()
    vbox.add_child(hsep)
    
    # 添加按钮行
    var hbox = HBoxContainer.new()
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_child(hbox)
    
    var btn_ok = Button.new()
    btn_ok.text = "确定"
    hbox.add_child(btn_ok)
    
    var btn_cancel = Button.new()
    btn_cancel.text = "取消"
    hbox.add_child(btn_cancel)
```

---

## 📊 容器对比表格

| 容器类型 | 用途 | 关键属性 |
|----------|------|----------|
| **HBoxContainer** | 水平排列 | alignment |
| **VBoxContainer** | 垂直排列 | alignment |
| **GridContainer** | 网格布局 | columns |
| **MarginContainer** | 内边距 | theme_override_constants/margins_* |
| **TabContainer** | 标签页切换 | tabs_visible |
| **HSplitContainer** | 水平可拖动分隔 | split_offset |
| **VSplitContainer** | 垂直可拖动分隔 | split_offset |
| **PanelContainer** | 背景面板 | - |
| **ScrollContainer** | 滚动容器 | scroll_horizontal, scroll_vertical |
| **AspectRatioContainer** | 保持比例 | ratio, stretch_mode |
| **HFlowContainer** | 水平自动换行 | - |
| **VFlowContainer** | 垂直自动换行 | - |
| **CenterContainer** | 居中对齐 | - |

---

## 🎯 使用建议

### 何时使用容器

- ✅ 复杂 UI 布局（多区域、多层次）
- ✅ 需要响应式调整大小
- ✅ 需要自动排列子节点
- ✅ 需要可拖动分隔的区域

### 何时使用锚点

- ✅ 简单 UI 布局
- ✅ 固定在屏幕角落的 HUD 元素
- ✅ 简单的全宽/全高背景

### 混合使用

- 容器内部可以使用锚点
- 锚点适合简单布局，容器适合复杂布局
- 推荐：外层用锚点定位，内层用容器布局

---

## ⚠️ 常见踩坑

1. **手动设置子节点位置被覆盖**
   - 原因：容器会控制子节点位置
   - 解决：不要手动设置容器子节点的位置

2. **MarginContainer 边距不生效**
   - 原因：边距是 Theme 值
   - 解决：在 Theme Overrides → Constants 中设置

3. **容器不显示子节点**
   - 原因：子节点没有设置正确的尺寸标志
   - 解决：检查 Expand 和 Fill 设置

---

## 🔗 相关链接

- **Base 层来源**: [07A_Containers_Detailed.md](../base/ui-system/07A_Containers_Detailed.md)
- **相关概念**: [UI 尺寸和锚点概念](./ui-size-anchors.md)
- **相关指南**: [UI 输入处理指南](../guides/ui-input-handling.md)

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.7
