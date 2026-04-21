# Godot 4.x UI 尺寸与锚点详解

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/ui/size_and_anchors.rst

---

## 目录

1. [锚点概述](#1-锚点概述)
2. [偏移与锚点](#2-偏移与锚点)
3. [锚点预设](#3-锚点预设)
4. [居中控件](#4-居中控件)
5. [锚点 vs 容器](#5-锚点-vs-容器)

---

## 1. 锚点概述

### 1.1 问题背景

- 不同设备分辨率、纵横比差异大
- 控件需要相对于屏幕边缘定位
- 一些控件需要跟随底部、顶部或边缘

### 1.2 解决方案

使用**锚点偏移**（anchor offsets）控制控件相对于父容器的位置。

---

## 2. 偏移与锚点

### 2.1 偏移（Offset）

每个控件有四个偏移：
- `offset_left`
- `offset_right`
- `offset_top`
- `offset_bottom`

默认情况下，这些是相对于父控件左上角的像素距离。

### 2.2 锚点（Anchor）

每个偏移都有对应的锚点：
- `anchor_left`（0.0 = 左边，1.0 = 右边）
- `anchor_right`
- `anchor_top`（0.0 = 顶部，1.0 = 底部）
- `anchor_bottom`

### 2.3 锚点工作原理

```
anchor = 0.0  → 相对于父控件左/上边缘
anchor = 0.5  → 相对于父控件中心
anchor = 1.0  → 相对于父控件右/下边缘
```

### 2.4 锚点不同值的效果

**所有锚点 = 0.0（默认）**
- 偏移相对于左上角
- 控件不随父控件大小改变

**水平锚点 = 1.0**
- 偏移相对于右边缘
- 控件跟随右边缘

**锚点值不同时**
- 控件大小随父控件改变
- 例如：左锚点 0，右锚点 1 → 控件宽度随父控件

---

## 3. 锚点预设

### 3.1 使用编辑器

选择控件后，在 Inspector 中点击 Anchor 按钮，选择预设。

### 3.2 常用预设

| 预设 | 效果 |
|------|------|
| **Top Left** | 固定在左上角 |
| **Top Right** | 固定在右上角 |
| **Bottom Left** | 固定在左下角 |
| **Bottom Right** | 固定在右下角 |
| **Center** | 居中 |
| **Left Wide** | 左侧全高 |
| **Right Wide** | 右侧全高 |
| **Bottom Wide** | 底部全宽 |
| **Top Wide** | 顶部全宽 |
| **Full Rect** | 填满父控件 |

### 3.3 代码设置预设

```gdscript
func _ready():
    # 设置锚点预设
    anchors_preset = Control.PRESET_TOP_LEFT
    anchors_preset = Control.PRESET_CENTER
    anchors_preset = Control.PRESET_FULL_RECT
    
    # 或手动设置锚点
    anchor_left = 0.5
    anchor_right = 0.5
    anchor_top = 0.5
    anchor_bottom = 0.5
```

---

## 4. 居中控件

### 4.1 方法一：使用锚点预设

1. 选择控件
2. 设置 Anchor Preset → Center

### 4.2 方法二：代码设置

```gdscript
func center_control(control: Control):
    control.anchor_left = 0.5
    control.anchor_right = 0.5
    control.anchor_top = 0.5
    control.anchor_bottom = 0.5
    
    # 调整偏移使控件居中
    var size = control.size
    control.offset_left = -size.x / 2
    control.offset_right = size.x / 2
    control.offset_top = -size.y / 2
    control.offset_bottom = size.y / 2
```

### 4.3 方法三：使用 CenterContainer

```
[CenterContainer]
  [YourControl]
```

---

## 5. 锚点 vs 容器

| 特性 | 锚点 | 容器 |
|------|------|------|
| 复杂度 | 简单 | 较复杂 |
| 灵活性 | 有限 | 高 |
| 适用场景 | 简单 HUD | 复杂 UI |
| 学习曲线 | 低 | 中 |

### 5.1 使用建议

- **简单 UI**：使用锚点
- **复杂 UI**：使用容器
- **混合使用**：容器内使用锚点

---

## 6. 常见布局场景

### 6.1 HUD 固定在角落

```
生命值条：Top Left
金币显示：Top Right
虚拟摇杆：Bottom Left
暂停按钮：Top Right（偏移调整位置）
```

### 6.2 响应式背景

```gdscript
func _ready():
    anchors_preset = Control.PRESET_FULL_RECT
    offset_left = 0
    offset_right = 0
    offset_top = 0
    offset_bottom = 0
```

### 6.3 进度条跟随底部

```gdscript
func _ready():
    anchor_left = 0
    anchor_right = 1
    anchor_top = 1
    anchor_bottom = 1
    offset_top = -30  # 高度 30 像素
    offset_bottom = -10  # 距底部 10 像素
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/ui/size_and_anchors.rst`
