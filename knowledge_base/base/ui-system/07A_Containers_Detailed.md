# Godot 4.x UI 容器系统详解

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/ui/gui_containers.rst

---

## 目录

1. [容器概述](#1-容器概述)
2. [尺寸选项](#2-尺寸选项)
3. [容器类型](#3-容器类型)
4. [嵌套容器](#4-嵌套容器)

---

## 1. 容器概述

### 1.1 为什么使用容器

锚点适合简单的多分辨率处理，但对于复杂 UI（RPG、聊天、模拟经营、工具类应用），容器更强大。

### 1.2 容器行为

- 子 Control 节点放弃自己的定位能力
- 容器控制子节点的位置
- 手动修改子节点位置会被覆盖
- 容器调整大小时自动重新排列子节点

---

## 2. 尺寸选项

### 2.1 Fill

确保控件填充容器内的指定区域。默认启用。

### 2.2 Expand

尝试使用尽可能多的空间：
- 不扩展的控件被推到一边
- 扩展控件之间按 Stretch Ratio 分配空间

### 2.3 Shrink 模式

| 模式 | 说明 |
|------|------|
| **Shrink Begin** | 扩展时靠左/上 |
| **Shrink Center** | 扩展时居中 |
| **Shrink End** | 扩展时靠右/下 |

### 2.4 Stretch Ratio

扩展控件之间的空间分配比例：
- 比例为 2 的控件占用比例为 1 的两倍空间

```gdscript
# 代码设置
size_flags_horizontal = Control.SIZE_EXPAND_FILL
size_flags_stretch_ratio = 2.0
```

---

## 3. 容器类型

### 3.1 BoxContainer

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

```gdscript
# 代码创建
var hbox = HBoxContainer.new()
var btn1 = Button.new()
btn1.text = "Button 1"
hbox.add_child(btn1)
add_child(hbox)
```

### 3.2 GridContainer

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

### 3.3 MarginContainer

子控件扩展到边界，添加内边距：

```
[MarginContainer]
  [内容区域]
  ↑ 边距
```

> **踩坑点**：边距是 Theme 值，需要在 Theme Overrides → Constants 中设置。

### 3.4 TabContainer

子控件堆叠显示，通过标签切换：

```
[TabContainer]
  [Tab1内容] (隐藏)
  [Tab2内容] (显示)
  [Tab3内容] (隐藏)
```

标签标题默认使用节点名称。

### 3.5 SplitContainer

**HSplitContainer** 和 **VSplitContainer**

子控件之间有可拖动的分隔条：

```
[HSplitContainer]
  [LeftPanel] | [RightPanel]
            ↑ 可拖动
```

### 3.6 PanelContainer

绘制 StyleBox 背景，子控件覆盖整个区域：

```
[PanelContainer]
  [背景]
  [子控件]
```

### 3.7 ScrollContainer

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

### 3.8 AspectRatioContainer

保持子控件比例：

```gdscript
var container = AspectRatioContainer.new()
container.ratio = 16.0 / 9.0  # 16:9 比例
container.stretch_mode = AspectRatioContainer.STRETCH_MODE_KEEP
```

### 3.9 FlowContainer

**HFlowContainer** 和 **VFlowContainer**

空间不足时自动换行：

```
[HFlowContainer]
  [Btn1] [Btn2] [Btn3]
  [Btn4] [Btn5]
  ↑ 自动换行
```

### 3.10 CenterContainer

子控件居中显示：

```
[CenterContainer]
      [子控件]
      ↑ 居中
```

---

## 4. 嵌套容器

### 4.1 复杂布局示例

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

### 4.2 常见布局模式

#### 顶部标题 + 内容

```
[VBoxContainer]
  [Label] "标题"
  [PanelContainer]
    [内容]
```

#### 侧边栏 + 主内容

```
[HSplitContainer]
  [VBoxContainer]  # 侧边栏
    [Button]
    [Button]
  [VBoxContainer]  # 主内容
    [内容]
```

#### 底部按钮栏

```
[VBoxContainer]
  [内容] size_flags_vertical = SIZE_EXPAND_FILL
  [HBoxContainer]
    [Spacer] size_flags_horizontal = SIZE_EXPAND_FILL
    [Button] "取消"
    [Button] "确定"
```

---

## 5. 代码创建容器

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

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/ui/gui_containers.rst`
