# Godot 4.x 2D 光照与阴影

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/2d_lights_and_shadows.rst

---

## 目录

1. [光照系统概述](#1-光照系统概述)
2. [所需节点](#2-所需节点)
3. [PointLight2D 点光源](#3-pointlight2d-点光源)
4. [DirectionalLight2D 平行光](#4-directionallight2d-平行光)
5. [阴影配置](#5-阴影配置)

---

## 1. 光照系统概述

### 1.1 默认行为

默认情况下，2D 场景**无光照和阴影**，渲染速度快但视觉效果平淡。

### 1.2 启用效果

启用 2D 光照后可以显著增强场景的深度感。

---

## 2. 所需节点

| 节点 | 用途 |
|------|------|
| `CanvasModulate` | 使场景变暗，作为基础环境色 |
| `PointLight2D` | 全向/聚光灯光 |
| `DirectionalLight2D` | 太阳光/月光 |
| `LightOccluder2D` | 阴影投射体 |
| `Sprite2D` / `TileMapLayer` | 接收光照的节点 |

> **踩坑点**：背景颜色**不接收**任何光照。如果需要背景被照亮，需添加 Sprite2D 作为背景表示。

---

## 3. PointLight2D 点光源

### 3.1 常用场景

火把、火焰、投射物等。

### 3.2 重要属性

| 属性 | 说明 |
|------|------|
| `Texture` | 光源纹理（决定大小） |
| `Offset` | 纹理偏移（不移动阴影） |
| `Texture Scale` | 光源大小倍数 |
| `Height` | 虚拟高度（影响法线贴图） |
| `Color` | 光源颜色 |
| `Energy` | 光源强度 |

### 3.3 性能注意

> **踩坑点**：更大的光源会影响更多像素，性能成本更高。增加光源大小时请考虑性能。

### 3.4 混合模式

| 模式 | 效果 |
|------|------|
| **Add** (默认) | 叠加模式 |
| **Mix** | 混合模式 |
| **Subtract** | 减去模式 |

---

## 4. DirectionalLight2D 平行光

### 4.1 用途

模拟太阳光或月光。

### 4.2 特点

- 所有物体产生相同方向的阴影
- 适合模拟全局光源

---

## 5. 阴影配置

### 5.1 LightOccluder2D

告诉着色器场景的哪些部分投射阴影：

```gdscript
@onready var occluder = $LightOccluder2D

func _ready():
    occluder.occluder_light_mask = 1  # 只对第 1 个光源生效
```

### 5.2 TileMapLayer 中的阴影

TileMapLayer 可以直接包含遮光数据。

### 5.3 阴影方向

阴影方向基于 PointLight2D 的中心位置计算。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/2d/2d_lights_and_shadows.rst`
