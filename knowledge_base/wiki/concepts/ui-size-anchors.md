# UI 尺寸和锚点概念

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [07B_Size_and_Anchors_Detailed.md](../base/ui-system/07B_Size_and_Anchors_Detailed.md)

---

## 📋 概述

**锚点**（Anchors）和**偏移**（Offsets）是 Godot Control 节点用于控制相对于父容器位置和尺寸的系统。它们适合简单的多分辨率处理，是 UI 系统的基础。

**核心作用**:
- 控件相对于父容器边缘定位
- 控件随父容器大小自动调整
- 实现响应式 UI 布局

---

## 🎯 锚点概述

### 问题背景

- 不同设备分辨率、纵横比差异大
- 控件需要相对于屏幕边缘定位
- 一些控件需要跟随底部、顶部或边缘

### 解决方案

使用**锚点偏移**（anchor offsets）控制控件相对于父容器的位置。

---

## 📐 偏移与锚点

### 1. 偏移（Offset）

每个控件有四个偏移值：
- `offset_left` - 左偏移
- `offset_right` - 右偏移
- `offset_top` - 上偏移
- `offset_bottom` - 下偏移

**默认情况**: 这些是相对于父控件左上角的像素距离。

### 2. 锚点（Anchor）

每个偏移都有对应的锚点：
- `anchor_left`（0.0 = 左边，1.0 = 右边）
- `anchor_right`
- `anchor_top`（0.0 = 顶部，1.0 = 底部）
- `anchor_bottom`

### 3. 锚点工作原理

```
anchor = 0.0  → 相对于父控件左/上边缘
anchor = 0.5  → 相对于父控件中心
anchor = 1.0  → 相对于父控件右/下边缘
```

### 4. 锚点不同值的效果

#### 所有锚点 = 0.0（默认）

- 偏移相对于左上角
- 控件不随父控件大小改变

```gdscript
# 默认情况
anchor_left = 0.0
anchor_right = 0.0
anchor_top = 0.0
anchor_bottom = 0.0
# 控件固定在左上角，不响应父控件大小变化
```

#### 水平锚点 = 1.0

- 偏移相对于右边缘
- 控件跟随右边缘

```gdscript
# 固定在右上角
anchor_left = 1.0
anchor_right = 1.0
anchor_top = 0.0
anchor_bottom = 0.0
# 控件跟随父控件右边缘
```

#### 锚点值不同时

- 控件大小随父控件改变
- 例如：左锚点 0，右锚点 1 → 控件宽度随父控件

```gdscript
# 全宽控件
anchor_left = 0.0
anchor_right = 1.0
anchor_top = 0.0
anchor_bottom = 0.0
# 控件宽度 = 父控件宽度 + offset_right - offset_left
```

---

## 🎨 锚点预设

### 使用编辑器

选择控件后，在 Inspector 中点击 Anchor 按钮，选择预设。

### 常用预设

| 预设 | 效果 | 锚点配置 |
|------|------|----------|
| **Top Left** | 固定在左上角 | Left=0, Right=0, Top=0, Bottom=0 |
| **Top Right** | 固定在右上角 | Left=1, Right=1, Top=0, Bottom=0 |
| **Bottom Left** | 固定在左下角 | Left=0, Right=0, Top=1, Bottom=1 |
| **Bottom Right** | 固定在右下角 | Left=1, Right=1, Top=1, Bottom=1 |
| **Center** | 居中 | Left=0.5, Right=0.5, Top=0.5, Bottom=0.5 |
| **Left Wide** | 左侧全高 | Left=0, Right=0, Top=0, Bottom=1 |
| **Right Wide** | 右侧全高 | Left=1, Right=1, Top=0, Bottom=1 |
| **Bottom Wide** | 底部全宽 | Left=0, Right=1, Top=1, Bottom=1 |
| **Top Wide** | 顶部全宽 | Left=0, Right=1, Top=0, Bottom=0 |
| **Full Rect** | 填满父控件 | Left=0, Right=1, Top=0, Bottom=1 |

### 代码设置预设

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

## 🎯 居中控件

### 方法一：使用锚点预设

1. 选择控件
2. 设置 Anchor Preset → Center

### 方法二：代码设置

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

### 方法三：使用 CenterContainer

```
[CenterContainer]
  [YourControl]
```

> **提示**: CenterContainer 会自动处理居中，无需手动设置锚点。

---

## ⚖️ 锚点 vs 容器

| 特性 | 锚点 | 容器 |
|------|------|------|
| 复杂度 | 简单 | 较复杂 |
| 灵活性 | 有限 | 高 |
| 适用场景 | 简单 HUD | 复杂 UI |
| 学习曲线 | 低 | 中 |
| 自动布局 | ❌ | ✅ |
| 响应式 | ✅ | ✅ |

### 使用建议

- **简单 UI**: 使用锚点
- **复杂 UI**: 使用容器
- **混合使用**: 容器内使用锚点

---

## 📊 常见布局场景

### 1. HUD 固定在角落

```
生命值条：Top Left
金币显示：Top Right
虚拟摇杆：Bottom Left
暂停按钮：Top Right（偏移调整位置）
```

```gdscript
# 生命值条 - 左上角
func _ready():
    anchors_preset = Control.PRESET_TOP_LEFT
    offset_left = 20
    offset_top = 20
```

### 2. 响应式背景

```gdscript
func _ready():
    anchors_preset = Control.PRESET_FULL_RECT
    offset_left = 0
    offset_right = 0
    offset_top = 0
    offset_bottom = 0
```

### 3. 进度条跟随底部

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

## 📊 锚点配置速查表

| 需求 | 锚点配置 | 偏移说明 |
|------|---------|---------|
| **固定在左上角** | Left=0, Right=0, Top=0, Bottom=0 | offset_left/offset_top 控制位置 |
| **固定在右上角** | Left=1, Right=1, Top=0, Bottom=0 | offset_left/offset_top 控制位置 |
| **固定在左下角** | Left=0, Right=0, Top=1, Bottom=1 | offset_left/offset_top 控制位置 |
| **固定在右下角** | Left=1, Right=1, Top=1, Bottom=1 | offset_left/offset_top 控制位置 |
| **居中** | Left=0.5, Right=0.5, Top=0.5, Bottom=0.5 | offset 控制大小和微调 |
| **全宽顶部** | Left=0, Right=1, Top=0, Bottom=0 | offset_top/offset_bottom 控制高度 |
| **全宽底部** | Left=0, Right=1, Top=1, Bottom=1 | offset_top/offset_bottom 控制高度 |
| **全高左侧** | Left=0, Right=0, Top=0, Bottom=1 | offset_left/offset_right 控制宽度 |
| **全高右侧** | Left=1, Right=1, Top=0, Bottom=1 | offset_left/offset_right 控制宽度 |
| **填满父控件** | Left=0, Right=1, Top=0, Bottom=1 | offset 控制边距 |

---

## ⚠️ 常见踩坑

1. **控件不跟随父控件大小变化**
   - 原因：锚点值设置不正确
   - 解决：检查左右/上下锚点是否设置为不同值

2. **控件位置偏移异常**
   - 原因：锚点改变后偏移量的参考点变化
   - 解决：先设置锚点，再调整偏移

3. **居中控件不居中**
   - 原因：偏移量设置错误
   - 解决：offset_left = -size.x / 2, offset_right = size.x / 2

---

## 🔗 相关链接

- **Base 层来源**: [07B_Size_and_Anchors_Detailed.md](../base/ui-system/07B_Size_and_Anchors_Detailed.md)
- **相关概念**: [UI 容器概念](./ui-containers.md)
- **相关指南**: [UI 输入处理指南](../guides/ui-input-handling.md)

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.7
