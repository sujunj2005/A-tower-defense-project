# Godot 4.x 3D 开发基础

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/3d/introduction_to_3d.rst

---

## 目录

1. [3D 概述](#1-3d-概述)
2. [3D 坐标系](#2-3d-坐标系)
3. [3D 节点](#3-3d-节点)
4. [3D 变换](#4-3d-变换)
5. [相机](#5-相机)

---

## 1. 3D 概述

### 1.1 3D vs 2D

| 特性 | 2D | 3D |
|------|----|----|
| 坐标 | Vector2 | Vector3 |
| 深度 | 无 | Z 轴 |
| 相机 | Camera2D | Camera3D |
| 灯光 | Light2D | Light3D |

### 1.2 3D 工作区

- 切换到 3D 视图
- 使用鼠标右键旋转视角
- 使用 WASD 飞行导航

---

## 2. 3D 坐标系

### 2.1 左手坐标系

Godot 使用左手坐标系：

| 轴 | 方向 |
|----|------|
| X 轴 | 右为正 |
| Y 轴 | 上为正 |
| Z 轴 | 前为正（屏幕外） |

### 2.2 坐标系类型

| 类型 | 说明 |
|------|------|
| 全局坐标系 | 世界空间 |
| 局部坐标系 | 相对于父节点 |

---

## 3. 3D 节点

### 3.1 Node3D

所有 3D 节点的基类：

```gdscript
extends Node3D

func _ready():
    position = Vector3(0, 5, 0)
    rotation_degrees = Vector3(0, 45, 0)
    scale = Vector3(2, 2, 2)
```

### 3.2 常用 3D 节点

| 节点 | 说明 |
|------|------|
| `Node3D` | 3D 空物体 |
| `MeshInstance3D` | 网格实例 |
| `Camera3D` | 3D 相机 |
| `Light3D` | 3D 灯光 |
| `CharacterBody3D` | 3D 角色物体 |
| `RigidBody3D` | 3D 刚体 |
| `Area3D` | 3D 区域 |

---

## 4. 3D 变换

### 4.1 Transform3D

```gdscript
var t = Transform3D.IDENTITY
t.origin = Vector3(0, 5, 0)
t.basis = Basis.from_euler(Vector3(0, PI/4, 0))
transform = t
```

### 4.2 旋转表示

| 表示 | 说明 |
|------|------|
| 欧拉角 | 直观但有万向节死锁 |
| 四元数 | 无死锁，适合插值 |
| Basis | 3×3 矩阵 |

```gdscript
# 欧拉角
rotation_degrees = Vector3(0, 45, 0)

# 四元数
quaternion = Quaternion.from_euler(Vector3(0, PI/4, 0))

# Basis
basis = Basis.from_euler(Vector3(0, PI/4, 0))
```

> **踩坑点**：3D 旋转避免使用欧拉角，使用四元数或 Basis 更安全。

---

## 5. 相机

### 5.1 Camera3D 设置

```gdscript
@onready var camera = $Camera3D

func _ready():
    camera.fov = 75  # 视野角度
    camera.near = 0.1  # 近裁剪面
    camera.far = 1000  # 远裁剪面
```

### 5.2 相机跟随

```gdscript
extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 5, 10)

func _process(_delta):
    if target:
        global_position = target.global_position + offset
        look_at(target.global_position)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/3d/introduction_to_3d.rst`
