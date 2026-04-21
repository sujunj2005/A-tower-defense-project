# 3D 粒子系统实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 14E_Particles_3D.md](../../base/3d-development/14E_Particles_3D.md)  
> **重要性**: 🟡 推荐 - 3D 特效制作

---

## 📋 概述

GPUParticles3D 用于创建各种 3D 粒子特效，如火焰、烟雾、魔法效果等。

---

## 🎯 核心组件

### 1. 粒子系统

```gdscript
# 创建粒子系统
var particles = GPUParticles3D.new()
particles.amount = 100  # 粒子数量
particles.lifetime = 2.0  # 生命周期
particles.emitting = true  # 开始发射
```

### 2. 粒子材质

```gdscript
var material = ParticleProcessMaterial.new()
particles.process_material = material

# 发射设置
material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
material.emission_sphere_radius = 1.0

# 粒子物理
material.gravity = Vector3(0, -9.8, 0)
material.initial_velocity_min = 5.0
material.initial_velocity_max = 10.0
```

---

## 🔧 实战技巧

### 1. 火焰效果

```gdscript
# 向上发射的粒子
material.direction = Vector3(0, 1, 0)
material.spread = 30.0  # 扩散角度

# 颜色渐变
var gradient = Gradient.new()
gradient.colors = [Color.orange, Color.red, Color.transparent]
material.color_gradient = gradient
```

### 2. 爆炸效果

```gdscript
# 向四周发射
material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE

# 爆炸力
material.initial_velocity_min = 20.0
material.initial_velocity_max = 30.0
```

---

## 🔗 相关资源

### Base 层
- [14E_Particles_3D.md](../../base/3d-development/14E_Particles_3D.md) - 3D 粒子系统详解

### Wiki 层
- [3D 开发入门](../concepts/3d-intro.md) - 3D 基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
