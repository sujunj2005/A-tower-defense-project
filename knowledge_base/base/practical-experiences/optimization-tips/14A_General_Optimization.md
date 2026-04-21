# Godot 4.x 性能优化指南

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/performance/general_optimization.rst

---

> 📖 **性能优化三部曲（本系列共3篇，层级关系如下）：**
>
> ```
> [14A] 本文档 ◄── 入门层：优化方法论 + 测量 + 问题分类 + 技术索引
>    │
>    ├──► [14B_CPU_Optimization.md] ◄── 实战层：CPU/脚本瓶颈的详细诊断与修复
>    │       （Profiler使用、脚本优化、物理优化、GC调优）
>    │
>    └──► [14C_GPU_Optimization.md] ◄── 实战层：GPU/渲染瓶颈的详细诊断与修复
>            （Draw Call、Instancing、LOD、灯光、着色器、后期处理、FSR）
>
> 推荐阅读顺序：14A → 遇到问题 → 根据瓶颈类型选择 14B 或 14C
> ```

---

## 目录

1. [优化概述](#1-优化概述)
2. [测量性能](#2-测量性能)
3. [性能问题类型](#3-性能问题类型)
4. [优化原则](#4-优化原则)
5. [常用优化技术](#5-常用优化技术)

---

## 1. 优化概述

### 1.1 两种优化途径

- **工作更快**：优化代码效率
- **工作更聪明**：使用技巧欺骗玩家

### 1.2 烟雾与镜子

游戏开发中，让玩家相信世界比实际更复杂是常见技巧。好的程序员应该学习这些"魔术"技巧。

---

## 2. 测量性能

### 2.1 测量方法概览

| 方法 | 适用场景 | 详细文档 |
|------|----------|----------|
| **计时器** | 精确测量代码段耗时 | 本节下方示例 |
| **Godot Profiler** | 内置分析，查看函数调用 | 📖 [17B_Profiler](17B_Debug_and_Testing/17B_Profiler.md) |
| **外部 CPU Profiler** | 深度 CPU 分析（VeryL、Instruments） | 第三方工具 |
| **GPU Profiler** | GPU 瓶颈诊断（Nsight、Radeon Profiler） | 📖 [14C_GPU_Optimization](14C_GPU_Optimization.md) |
| **帧率检查** | 快速判断是否达标 | `Engine.get_frames_per_second()` |

### 2.2 快速性能检查

```gdscript
# 简单 FPS 监控
func _process(_delta):
    if Engine.get_frames_per_second() < 55:
        $FPSLabel.add_theme_color_override("font_color", Color.RED)
    else:
        $FPSLabel.add_theme_color_override("font_color", Color.GREEN)
    $FPSLabel.text = "FPS: %d" % Engine.get_frames_per_second()
```

> **踩坑点**：不同硬件的性能特征可能不同。建议在多种设备上测量，特别是移动设备。
> 📖 **详细 Profiler 使用教程见 [17B_Profiler](17B_Debug_and_Testing/17B_Profiler.md) 和 [14B_CPU_Optimization](14B_CPU_Optimization.md)**

---

## 3. 性能问题类型

### 3.1 持续慢速

每帧都发生的慢速过程，导致持续低帧率。

**症状**：FPS 持续低于目标值

### 3.2 间歇性卡顿

间歇性过程导致"卡顿"。

**症状**：FPS 突然下降然后恢复

### 3.3 加载慢速

非游戏过程中的慢速，如关卡加载。

**症状**：加载时间长

---

## 4. 优化原则

### 4.1 Donald Knuth 名言

> 过早优化是万恶之源。97% 的时间我们应该忘记小的效率问题。

### 4.2 优化流程

1. **测量**：找到瓶颈
2. **分析**：理解问题
3. **优化**：解决问题
4. **验证**：测量改进

### 4.3 侦探工作

#### 假设测试

```gdscript
# 假设：精灵数量影响性能
# 测试：添加/移除精灵，测量性能
```

#### 二分搜索

1. 注释掉一半代码
2. 测量性能
3. 确定问题在哪一半
4. 重复直到找到问题

---

## 5. 常用优化技术（概要索引）

> 📖 **各项技术的详细实现和代码示例请查阅对应专题文档：**

### 5.1 脚本逻辑优化 → [14B_CPU_Optimization](14B_CPU_Optimization.md)

| 技术 | 一句话说明 | 收益 |
|------|-----------|------|
| **对象池** | 预创建对象复用，避免频繁 new/queue_free | ⚡⚡⚡ 消除GC峰值 |
| **缓存节点引用** | `@onready` 替代每帧 `get_node()` | ⚡⚡ 减少树查找 |
| **类型化数组** | `Array[Enemy]` 替代 `Array` | ⚡⚡ 减少类型检查 |
| **减少每帧计算** | 用信号/定时器替代 `_process` 中的高频检测 | ⚡⚡⚡ 降低CPU占用 |
| **空间划分** | 四叉树/网格管理大量实体 | ⚡⚡⚡ O(log n) 查找 |

### 5.2 渲染优化 → [14C_GPU_Optimization](14C_GPU_Optimization.md)

| 技术 | 一句话说明 | 收益 |
|------|-----------|------|
| **减少 Draw Call** | GPU Instancing / 合并图集 / 静态合批 | ⚡⚡⚡ 显著降低CPU-GPU开销 |
| **LOD 细节层次** | 远距离使用低模/隐藏 | ⚡⚡⚡ 减少顶点处理 |
| **遮挡剔除** | OccluderInstance3D + BVH | ⚡⚡ 跳过不可见物体 |
| **灯光精简** | ≤2-3个实时光源投射阴影 | ⚡⚡⚡ 阴影是最大性能杀手 |
| **透明度优化** | Alpha Scissor > Alpha Blend | ⚡⚡ 减少过度绘制 |
| **分辨率缩放** | 动态缩放 / FSR 超分辨率 | ⚡⚡⚡ 按需平衡画质性能 |
| **后期处理精简** | 禁用不必要的 DOF/MotionBlur/SSR | ⚡⚡ 后处理非常昂贵 |

### 5.3 快速决策流程

```
遇到性能问题？
│
├─ FPS 持续低？→ 用 Profiler 定位瓶颈（📖 17B_Profiler）
│   ├─ 脚本/物理/AI 占比高？→ 查 CPU 优化（📖 14B_CPU）
│   └─ GPU/渲染占比高？     → 查 GPU 优化（📖 14C_GPU）
│
├─ 间歇性卡顿？→ 检查 GC / 资源加载 / 大循环
│
└─ 加载慢？      → 后台加载（📖 15D_Background_Loading）+ 压缩纹理
```

---

## 6. CPU vs GPU 瓶颈

### 6.1 CPU 瓶颈

- 大量脚本逻辑
- 物理计算
- AI 处理

### 6.2 GPU 瓶颈

- 过多绘制调用
- 复杂着色器
- 高分辨率纹理

### 6.3 判断方法

- 降低分辨率：如果 FPS 提高，则是 GPU 瓶颈
- 禁用脚本：如果 FPS 提高，则是 CPU 瓶颈

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/performance/general_optimization.rst`
