# Godot 4.x 2D 粒子系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/particle_systems_2d.rst

---

## 目录

1. [粒子系统概述](#1-粒子系统概述)
2. [粒子节点](#2-粒子节点)
3. [ParticleProcessMaterial](#3-particleprocessmaterial)
4. [粒子参数](#4-粒子参数)
5. [动画 Flipbook](#5-动画-flipbook)

---

## 1. 粒子系统概述

### 1.1 什么是粒子系统

粒子系统用于模拟复杂的物理效果，例如：
- 火花
- 火焰
- 魔法粒子
- 烟雾
- 薄雾

### 1.2 基本原理

粒子以固定间隔发射，具有固定寿命。在其寿命期间，每个粒子都具有相同的基本行为。使每个粒子与众不同并提供更有机外观的是与每个参数相关的"随机性"。

---

## 2. 粒子节点

### 2.1 两种粒子节点

Godot 提供两种不同的 2D 粒子节点：

| 节点 | 说明 | 适用场景 |
|------|------|----------|
| `GPUParticles2D` | GPU 驱动，更高级，性能更好 | 大量粒子（数千个），现代设备 |
| `CPUParticles2D` | CPU 驱动，功能相近 | 低端设备或 GPU 瓶颈情况 |

> **踩坑点**：未来没有计划向 CPUParticles2D 添加新功能，尽管将接受添加 GPUParticles2D 中已有功能的 Pull Request。因此建议使用 GPUParticles2D，除非有明确理由不使用。

### 2.2 节点转换

可以在两种粒子节点之间转换：

```
CPUParticles2D → GPUParticles2D：选择节点 → 2D 工作区 → 工具栏 → CPUParticles2D > Convert to GPUParticles2D
```

> **踩坑点**：GPUParticles2D 转换为 CPUParticles2D 是可能的，但如果使用仅 GPU 功能，可能会出现问题。

---

## 3. ParticleProcessMaterial

### 3.1 添加材质

GPUParticles2D 需要一个 ParticleProcessMaterial 才能工作。在 Inspector 面板中：

1. 转到 "Process Material"
2. 点击 "Material" 旁的框
3. 从下拉菜单中选择 "New ParticleProcessMaterial"

### 3.2 基本效果

添加后，GPUParticles2D 节点应该开始向下发射白点。

---

## 4. 粒子参数

### 4.1 时间参数

#### Lifetime（寿命）

每个粒子保持活动的时间（秒）。当寿命结束时，会创建一个新粒子来替换它。

```gdscript
# 0.5 秒寿命
material.lifetime = 0.5
```

### 4.2 发射参数

#### Emission Shape（发射形状）

| 形状 | 说明 |
|------|------|
| Point | 从点发射 |
| Sphere | 从球体发射 |
| Box | 从盒子发射 |
| Points | 从自定义点发射 |
| Directed Points | 有方向的点发射 |

#### Emission Rate（发射率）

每秒发射的粒子数：

```gdscript
material.emission_rate = 50  # 每秒 50 个粒子
```

### 4.3 运动参数

#### Initial Velocity（初始速度）

粒子初始速度：

```gdscript
material.initial_velocity_min = 100
material.initial_velocity_max = 200
```

#### Gravity（重力）

重力加速度：

```gdscript
material.gravity = Vector2(0, 98)  # 向下
```

#### Air Resistance（空气阻力）

空气阻力系数：

```gdscript
material.damping = 0.5
```

### 4.4 外观参数

#### Scale（缩放）

粒子大小：

```gdscript
material.scale_min = 0.5
material.scale_max = 1.5
```

#### Color（颜色）

粒子颜色：

```gdscript
material.color = Color(1, 0, 0)  # 红色
material.color_ramp = preload("res://color_ramp.tres")  # 颜色渐变
```

---

## 5. 动画 Flipbook

### 5.1 什么是 Flipbook

粒子系统可以使用单个纹理或动画 Flipbook。Flipbook 是包含多个动画帧的纹理，可以播放或在发射时随机选择。

### 5.2 使用 Flipbook

使用动画 Flipbook 与单个纹理相比需要额外配置：

1. 在 GPUParticles2D（或 CPUParticles2D）节点的 Material 部分创建一个新的 CanvasItemMaterial
2. 在这个 CanvasItemMaterial 中，启用 Particle Animation，并将 H Frames 和 V Frames 设置为 Flipbook 纹理中的列数和行数

```gdscript
# 配置 Flipbook
var canvas_material = CanvasItemMaterial.new()
canvas_material.particle_animation_h_frames = 5
canvas_material.particle_animation_v_frames = 7
```

> **踩坑点**：如果 Flipbook 纹理有黑色背景而不是透明背景，还需要将混合模式设置为 Add 而不是 Mix 以正确显示。或者，可以在图像编辑器中修改纹理以具有透明背景。

---

## 6. 代码控制粒子

### 6.1 播放/停止

```gdscript
@onready var particles = $GPUParticles2D

func play_particles():
    particles.emitting = true

func stop_particles():
    particles.emitting = false
    particles.one_shot = true  # 一次性播放
```

### 6.2 修改参数

```gdscript
func set_emission_rate(rate: float):
    particles.process_material.emission_rate = rate

func set_color(color: Color):
    particles.process_material.color = color
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/2d/particle_systems_2d.rst`
