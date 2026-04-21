# 3D 开发入门

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 14A_3D_Intro.md](../../base/3d-development/14A_3D_Intro.md)  
> **重要性**: 🔴 必读 - 3D 开发基础概念

---

## 📋 概述

Godot 4.x 提供了完整的 3D 游戏开发工具链。本指南介绍 3D 开发的核心概念和工作流程。

---

## 🎯 核心概念

### 1. 3D 坐标系

Godot 使用 **左手坐标系**：
- **X 轴**: 右方向（红色）
- **Y 轴**: 上方向（绿色）
- **Z 轴**: 前方向（蓝色）

### 2. 节点结构

```
3D 场景基本结构:
Node3D (根节点)
├─ WorldEnvironment (环境)
├─ DirectionalLight3D (方向光)
├─ Player (CharacterBody3D)
│  ├─ CollisionShape3D
│  └─ MeshInstance3D
└─ Camera3D
```

### 3. 变换（Transform3D）

Transform3D 包含：
- **原点（Origin）**: 位置
- **基（Basis）**: 旋转和缩放

---

## 🔧 快速开始

### 创建 3D 场景

```gdscript
# 第一人称相机控制
extends Camera3D

@export var speed: float = 5.0
@export var sensitivity: float = 0.1

var rotation_helper: Node3D

func _ready():
    rotation_helper = Node3D.new()
    add_child(rotation_helper)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
    if event is InputEventMouseMotion:
        rotation_helper.rotate_y(-event.relative.x * sensitivity)
        rotate_x(-event.relative.y * sensitivity)
        rotation = Vector3(
            clamp(rotation.x, -PI/2, PI/2),
            rotation_helper.rotation.y,
            0
        )

func _process(delta):
    var direction = Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        direction -= transform.basis.z
    if Input.is_action_pressed("move_backward"):
        direction += transform.basis.z
    if Input.is_action_pressed("move_left"):
        direction -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        direction += transform.basis.x
    
    if direction.length() > 0:
        direction = direction.normalized()
    
    position += direction * speed * delta
```

---

## 🔗 相关资源

### Base 层
- [14A_3D_Intro.md](../../base/3d-development/14A_3D_Intro.md) - 3D 入门
- [14B_3D_Transforms.md](../../base/3d-development/14B_3D_Transforms.md) - 3D 变换

### Wiki 层
- [3D 变换概念](../concepts/3d-transforms-concept.md) - Transform3D 详解
- [3D 灯光指南](../guides/3d-lights-guide.md) - 灯光系统
- [标准材质指南](../guides/standard-material-guide.md) - 材质系统

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
