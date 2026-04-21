# Base 层 - UI 系统

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.x  
> **文档来源**: Godot 官方文档

---

## 📂 目录说明

本目录包含 Godot 4.x UI 系统的原始信息源文档，是 Wiki 层 UI 相关页面的事实来源。

---

## 📄 文档列表

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [07A_Containers_Detailed.md](./07A_Containers_Detailed.md) | **UI 容器详解** - 容器概述/尺寸选项/容器类型/嵌套容器 | `gui_containers.rst` | 🔴 必读 |
| [07B_Size_and_Anchors_Detailed.md](./07B_Size_and_Anchors_Detailed.md) | **尺寸与锚点详解** - 锚点概述/偏移与锚点/锚点预设/居中控件 | `size_and_anchors.rst` | 🔴 必读 |
| [07D_UI_Input_Handling.md](./07D_UI_Input_Handling.md) | **UI 输入处理** - _gui_input 回调/鼠标过滤/焦点控制/通知 | `gui_input_handling.rst` | 🔴 必读 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/ui/)  
**文档数**: 3 份  
**总字数**: ~20,000+

---

## 📋 核心内容概览

### 07A - UI 容器详解

**核心主题**: Godot 容器系统的完整指南

**主要内容**:
- 容器概述（为什么使用容器/容器行为）
- 尺寸选项（Fill/Expand/Shrink 模式/Stretch Ratio）
- 容器类型详解：
  - BoxContainer（HBoxContainer/VBoxContainer）
  - GridContainer
  - MarginContainer
  - TabContainer
  - SplitContainer
  - PanelContainer
  - ScrollContainer
  - AspectRatioContainer
  - FlowContainer
  - CenterContainer
- 嵌套容器与复杂布局
- 代码创建容器示例

**Wiki 映射**:
- 概念页面：[ui-containers.md](../../wiki/concepts/ui-containers.md)

---

### 07B - 尺寸与锚点详解

**核心主题**: 锚点系统和尺寸控制的完整指南

**主要内容**:
- 锚点概述（问题背景/解决方案）
- 偏移与锚点（Offset 四值/Anchor 四值/工作原理）
- 锚点预设（Top Left/Center/Full Rect 等）
- 居中控件的三种方法
- 锚点 vs 容器对比
- 常见布局场景（HUD/响应式背景/进度条）

**Wiki 映射**:
- 概念页面：[ui-size-anchors.md](../../wiki/concepts/ui-size-anchors.md)

---

### 07D - UI 输入处理

**核心主题**: Control 节点的输入处理机制

**主要内容**:
- _gui_input 回调（触发条件/基本用法/accept_event）
- 鼠标过滤（mouse_filter 三模式）
- 焦点控制（focus_mode 属性/焦点导航）
- 通知系统（NOTIFICATION_MOUSE_ENTER/EXIT 等）
- 键盘输入处理

**Wiki 映射**:
- 指南页面：[ui-input-handling.md](../../wiki/guides/ui-input-handling.md)

---

## 🔗 与 Wiki 层的映射关系

| Base 层文档 | Wiki 概念页面 | Wiki 指南页面 |
|------------|--------------|--------------|
| 07A_Containers_Detailed.md | [ui-containers.md](../../wiki/concepts/ui-containers.md) | - |
| 07B_Size_and_Anchors_Detailed.md | [ui-size-anchors.md](../../wiki/concepts/ui-size-anchors.md) | - |
| 07D_UI_Input_Handling.md | - | [ui-input-handling.md](../../wiki/guides/ui-input-handling.md) |

---

## 📊 统计信息

| 项目 | 数量 |
|------|------|
| 文档总数 | 3 份 |
| 预估总字数 | ~20,000+ |
| Wiki 映射页面 | 3 页（2 概念 + 1 指南） |
| 来源文件 | `gui_containers.rst`, `size_and_anchors.rst`, `gui_input_handling.rst` |

---

## 🎯 使用建议

### 推荐阅读顺序

1. **先学锚点**: 从 [07B_Size_and_Anchors_Detailed.md](./07B_Size_and_Anchors_Detailed.md) 开始，理解基础的锚点系统
2. **再学容器**: 阅读 [07A_Containers_Detailed.md](./07A_Containers_Detailed.md)，掌握复杂 UI 布局
3. **最后输入**: 学习 [07D_UI_Input_Handling.md](./07D_UI_Input_Handling.md)，了解 UI 交互

### 与 Wiki 层配合使用

- **快速查阅**: 使用 Wiki 层的概念页面快速了解核心概念
- **深入学习**: 回到 Base 层文档查看详细示例和代码
- **交叉引用**: Wiki 页面会标注 Base 层来源，方便追溯

---

## 🔄 更新策略

- **Base 层文档**: 保持原始来源的完整性，不修改内容
- **Wiki 层页面**: 基于 Base 层文档生成摘要和整合
- **一致性维护**: 当 Base 层更新时，Wiki 层需要同步更新

---

## 📝 版本历史

- **2026-04-07**: 初始创建，整合 07_UI_System 文件夹的 3 份文档

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.7
