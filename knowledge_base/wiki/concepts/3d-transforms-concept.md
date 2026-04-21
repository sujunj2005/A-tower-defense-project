# 3D 变换核心概念

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 14B_3D_Transforms.md](../../base/3d-development/14B_3D_Transforms.md)  
> **重要性**: 🔴 必读 - 3D 数学基础

---

## 📋 概述

Transform3D 是 3D 开发的核心概念，用于表示物体的位置、旋转和缩放。理解变换对于 3D 编程至关重要。

---

## 🎯 核心概念

### 1. Transform3D 结构

```gdscript
var transform = Transform3D(
    basis,      # Basis - 旋转和缩放
    origin      # Vector3 - 位置
)
```

### 2. Basis（基）

Basis 由三个向量组成，表示局部坐标系的三个轴：
- **x**: 右方向
- **y**: 上方向
- **z**: 前方向

### 3. 常用操作

```gdscript
# 创建变换
var t = Transform3D()
t.origin = Vector3(10, 0, 5)  # 设置位置

# 旋转
t = t.rotated(Vector3.UP, deg_to_rad(45))  # 绕 Y 轴旋转 45 度

# 缩放
t = t.scaled(Vector3(2, 2, 2))  # 放大 2 倍

# 变换点
var world_pos = t * Vector3(0, 0, 0)  # 将局部坐标转换为世界坐标

# 逆变换
var local_pos = t.affine_inverse() * world_pos
```

---

## 🔧 实战技巧

### 1. 朝向目标

```gdscript
func look_at_target(target: Vector3):
    var new_transform = global_transform.looking_at(target, Vector3.UP)
    global_transform = new_transform
```

### 2. 跟随目标

```gdscript
func follow_target(target: Node3D, offset: Vector3):
    global_position = target.global_position + offset
```

---

## 🔗 相关资源

### Base 层
- [14B_3D_Transforms.md](../../base/3d-development/14B_3D_Transforms.md) - 3D 变换详解

### Wiki 层
- [3D 开发入门](../concepts/3d-intro.md) - 3D 基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
