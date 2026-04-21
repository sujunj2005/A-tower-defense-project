# Godot 4.x 3D 光照与阴影

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/3d/lighting_and_shadows.rst

---

## 目录

1. [3D 光照概述](#1-3d-光照概述)
2. [光源类型](#2-光源类型)
3. [阴影设置](#3-阴影设置)
4. [光照技巧](#4-光照技巧)

---

## 1. 3D 光照概述

### 1.1 PBR 渲染

Godot 使用基于物理的渲染（PBR），意味着材质会以现实的方式对光做出反应。

### 1.2 光照工作流程

```
场景 → 光源 → 材质 → 相机 → 屏幕像素
```

---

## 2. 光源类型

| 节点 | 用途 |
|------|------|
| `DirectionalLight3D` | 太阳光、月光（平行光） |
| `OmniLight3D` | 点光源（灯泡） |
| `SpotLight3D` | 聚光灯（手电筒） |

### 2.1 DirectionalLight3D

- 无限远的光源
- 所有光线平行
- 用于模拟太阳/月亮
- 可产生方向性阴影

### 2.2 OmniLight3D

- 从一点向所有方向发光
- 有衰减范围
- 用于模拟灯泡、火把

### 2.3 SpotLight3D

- 带锥形范围的光源
- 有角度限制
- 用于模拟手电筒、舞台灯光

---

## 3. 阴影设置

### 3.1 阴影属性

| 属性 | 说明 |
|------|------|
| `Shadow Enabled` | 是否启用阴影 |
| `Shadow Bias` | 阴影偏移（防止阴影 acne） |
| `Normal Bias` | 法线偏移 |
| `Shadow Blur` | 柔化边缘 |

### 3.2 性能注意

> **踩坑点**：阴影是 GPU 密集型功能。每增加一个带阴影的光源都会显著影响性能。

### 3.3 DirectionalLight3D 阴影模式

| 模式 | 说明 |
|------|------|
| **Orthogonal** | 正交投影（默认） |
| **PSSM 2 Splits** | 两级级联阴影贴图 |
| **PSSM 4 Splits** | 四级级联阴影贴图（质量更高） |

---

## 4. 光照技巧

### 4.1 环境光

```gdscript
# 在 WorldEnvironment 中设置环境光
environment.background_color = Color(0.2, 0.2, 0.3)
environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
environment.ambient_light_color = Color(0.3, 0.3, 0.3)
```

### 4.2 GI（全局照明）

Godot 支持多种 GI 方式：
- **SDFGI**：实时全局照明（推荐）
- **VoxelGI**：体积全局照明
- **LightmapGI**：烘焙光照贴图

### 4.3 光照探针

使用 LightmapGI 时需要放置光照探针来捕获间接光照。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/3d/lighting_and_shadows.rst`
