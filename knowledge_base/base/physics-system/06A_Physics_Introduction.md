# Godot 4.x 物理系统概述

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/physics/physics_introduction.rst

---

## 目录

1. [碰撞对象类型](#1-碰撞对象类型)
2. [碰撞形状](#2-碰撞形状)
3. [碰撞层与掩码](#3-碰撞层与掩码)
4. [物理处理回调](#4-物理处理回调)
5. [Area2D](#5-area2d)
6. [StaticBody2D](#6-staticbody2d)
7. [RigidBody2D](#7-rigidbody2d)
8. [CharacterBody2D](#8-characterbody2d)

---

## 1. 碰撞对象类型

Godot 提供四种碰撞对象，都继承自 `CollisionObject2D`：

| 类型 | 说明 | 用途 |
|------|------|------|
| `Area2D` | 检测和影响 | 检测重叠、修改物理属性 |
| `StaticBody2D` | 静态物体 | 墙壁、平台、传送带 |
| `RigidBody2D` | 刚体 | 受物理引擎控制的物体 |
| `CharacterBody2D` | 角色物体 | 玩家控制的角色 |

---

## 2. 碰撞形状

### 2.1 添加碰撞形状

每个物理物体需要一个或多个 `Shape2D` 子节点：

- `CollisionShape2D`：基本形状
- `CollisionPolygon2D`：多边形形状

> **踩坑点**：碰撞形状的 Scale 必须保持 (1, 1)。调整大小时使用形状的属性，不要使用 Node2D 的缩放。

### 2.2 形状类型

| 形状 | 说明 |
|------|------|
| `RectangleShape2D` | 矩形 |
| `CircleShape2D` | 圆形 |
| `CapsuleShape2D` | 胶囊形 |
| `SegmentShape2D` | 线段 |
| `SeparationRayShape2D` | 分离射线（角色专用） |
| `WorldBoundaryShape2D` | 无限平面 |

---

## 3. 碰撞层与掩码

### 3.1 概念

- **collision_layer**：物体所在的层（"我在哪里"）
- **collision_mask**：物体检测的层（"我检测谁"）

每个物体有 32 个物理层可用。

### 3.2 示例配置

| 节点 | Layer | Mask |
|------|-------|------|
| Player | player | walls, enemies, coins |
| Enemy | enemies | walls, player |
| Coin | coins | player |
| Wall | walls | （无需检测） |

### 3.3 代码设置

```gdscript
# 设置层
collision_layer = 0b0001  # 第 1 层
collision_mask = 0b1101   # 检测 1, 3, 4 层

# 使用便捷方法
set_collision_layer_value(1, true)
set_collision_mask_value(3, true)
```

### 3.4 导出位标志

```gdscript
@export_flags_2d_physics var collision_layers: int
```

---

## 4. 物理处理回调

### 4.1 _physics_process

物理引擎以固定速率运行（默认 60Hz），使用 `_physics_process` 回调：

```gdscript
func _physics_process(delta):
    # 物理相关代码放在这里
    velocity.y += gravity * delta
    move_and_slide()
```

> **踩坑点**：物理代码必须放在 `_physics_process` 中，而不是 `_process`。

---

## 5. Area2D

### 5.1 主要用途

- 检测物体进入/退出区域
- 修改区域内的物理属性（重力、阻尼）
- 检测区域重叠

### 5.2 信号

```gdscript
func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    print("物体进入：", body.name)

func _on_body_exited(body):
    print("物体退出：", body.name)
```

### 5.3 区域重力

```gdscript
# 设置区域重力覆盖
gravity_space_override = Area2D.SPACE_OVERRIDE_COMBINE
gravity = 500
gravity_direction = Vector2.DOWN
```

---

## 6. StaticBody2D

### 6.1 特点

- 不受物理引擎移动
- 参与碰撞检测
- 可以给予碰撞物体运动

### 6.2 常量速度

```gdscript
# 传送带效果
constant_linear_velocity = Vector2(100, 0)
constant_angular_velocity = 0
```

### 6.3 使用场景

- 平台（包括移动平台）
- 传送带
- 墙壁和障碍物

---

## 7. RigidBody2D

### 7.1 特点

- 由物理引擎控制运动
- 通过施加力来控制
- 自动处理碰撞响应

### 7.2 使用 _integrate_forces

```gdscript
extends RigidBody2D

var thrust = Vector2(0, -250)
var torque = 20000

func _integrate_forces(state):
    if Input.is_action_pressed("ui_up"):
        state.apply_force(thrust.rotated(rotation))
    else:
        state.apply_force(Vector2())
    
    var rotation_dir = 0
    if Input.is_action_pressed("ui_right"):
        rotation_dir += 1
    if Input.is_action_pressed("ui_left"):
        rotation_dir -= 1
    state.apply_torque(rotation_dir * torque)
```

> **踩坑点**：不要直接修改 RigidBody2D 的 `position` 或 `linear_velocity`。使用 `_integrate_forces` 回调。

### 7.3 睡眠机制

刚体静止一段时间后会进入睡眠状态，节省性能。

```gdscript
# 禁止睡眠
can_sleep = false
```

### 7.4 接触报告

```gdscript
# 启用接触报告
max_contacts_reported = 4
contact_monitor = true

# 通过信号获取接触
body_entered.connect(_on_body_entered)
```

---

## 8. CharacterBody2D

> 📖 **详细文档见 [06B_CharacterBody2D](06B_CharacterBody2D.md)**，此处仅概述核心特点。

CharacterBody2D 是用于玩家/角色控制的物理体：

| 特点 | 说明 |
|------|------|
| **代码控制移动** | 不受物理引擎驱动，通过代码设置 velocity |
| **碰撞检测** | 自动检测碰撞但不响应（需手动处理） |
| **核心方法** | `move_and_slide()` / `move_and_collide()` |
| **回调要求** | 必须在 `_physics_process()` 中使用 |

> **踩坑点**：
> - 不要直接修改 `position`，使用 `velocity` + `move_and_slide()`
> - `move_and_slide()` 内部已处理 delta，`velocity.y += gravity * delta` 但 `move_and_slide()` 不乘 delta

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/physics/physics_introduction.rst`
- 来源文件：`godot-docs-master/tutorials/physics/collision_shapes_2d.rst`
