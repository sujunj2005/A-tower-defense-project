# 标准材质实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 13D_Standard_Material_3D.md](../../base/3d-development/13D_Standard_Material_3D.md)  
> **重要性**: 🟡 推荐 - 3D 材质系统完整教程

---

## 📋 概述

StandardMaterial3D 是 Godot 中最强大的材质系统，支持 PBR（基于物理的渲染）工作流。

---

## 🎯 核心参数

### 1. 反照率（Albedo）

基础颜色和纹理。

```gdscript
var material = StandardMaterial3D.new()
material.albedo_color = Color(0.8, 0.2, 0.2)  # 红色
material.albedo_texture = preload("res://textures/brick.png")
```

### 2. 法线（Normal）

模拟表面细节。

```gdscript
material.normal_enabled = true
material.normal_texture = preload("res://textures/brick_normal.png")
```

### 3. 粗糙度（Roughness）

表面光滑程度（0=镜面，1=漫反射）。

```gdscript
material.roughness = 0.5  # 中等粗糙
material.roughness_texture = preload("res://textures/roughness.png")
```

### 4. 金属度（Metallic）

金属质感（0=非金属，1=纯金属）。

```gdscript
material.metallic = 0.8  # 接近金属
```

---

## 🔧 实战技巧

### 1. PBR 工作流

```
材质通道:
1. Albedo (基础色)
2. Normal (法线)
3. Roughness (粗糙度)
4. Metallic (金属度)
5. AO (环境光遮蔽)
```

### 2. 双面材质

```gdscript
material.cull_mode = StandardMaterial3D.CULL_DISABLED  # 禁用背面剔除
```

---

## 🔗 相关资源

### Base 层
- [13D_Standard_Material_3D.md](../../base/3d-development/13D_Standard_Material_3D.md) - 标准材质详解

### Wiki 层
- [3D 灯光指南](../guides/3d-lights-guide.md) - 灯光与材质交互

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
