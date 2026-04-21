# Godot 4.x RigidBody 使用指南

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/physics/rigid_body.rst

---

## 目录

1. [刚体概述](#1-刚体概述)
2. [控制刚体](#2-控制刚体)
3. [_integrate_forces](#3-_integrate_forces)
4. [常用操作](#4-常用操作)
5. [RigidBody vs CharacterBody](#5-rigidbody-vs-characterbody)

---

## 1. 刚体概述

### 1.1 什么是 RigidBody

RigidBody 是由**物理引擎直接控制**的物体，用于模拟真实物理对象的行为。

### 1.2 特点

- 由物理引擎控制运动和碰撞响应
- 受重力、摩擦力等物理属性影响
- 通过施加力来控制，而非直接设置位置

### 1.3 物理材质

需要添加 PhysicsMaterial 来调整摩擦力和弹性：

```gdscript
@export var material: PhysicsMaterial
material.friction = 0.8      # 摩擦系数
material.bounce = 0.5       # 弹性系数
material.absorbent = false   # 是否吸收能量
material.rough = false       # 是否粗糙
```

---

## 2. 控制刚体

### 2.1 初始化位置

可以一次性使用 Node3D 方法设置初始位置：

```gdscript
func _ready():
    global_position = spawn_position
    look_at(target.global_position)
```

> **踩坑点**：这些方法不能每帧调用！否则会破坏物理模拟。

### 2.2 常见错误示例

```gdscript
# 错误！每帧调用会破坏物理模拟
func _process(delta):
    look_at(target.position)  # ❌ 不要这样做
```

---

## 3. _integrate_forces

### 3.1 正确的控制方式

使用 `_integrate_forces()` 回调控制刚体：

```gdscript
extends RigidBody2D

var thrust: float = 250.0
var torque: float = 20000.0

func _integrate_forces(state):
    if Input.is_action_pressed("ui_up"):
        state.apply_force(thrust * transform.y.rotated(rotation))
    else:
        state.apply_force(Vector2.ZERO)
    
    var rotation_dir = Input.get_axis("ui_left", "ui_right")
    state.apply_torque(rotation_dir * torque)
```

### 3.2 可用操作

在 `_integrate_forces(state)` 中可以：

| 操作 | 方法 |
|------|------|
| 施加力 | `state.apply_force(force, position)` |
| 施加冲量 | `state.apply_impulse(force, position)` |
| 设置速度 | `state.linear_velocity = velocity` |
| 设置角速度 | `state.angular_velocity = angular_vel` |
| 设置变换 | `state.transform = new_transform` |

---

## 4. 常用操作

### 4.1 施加力

```gdscript
# 在中心施加力
state.apply_force(thrust * direction)

# 在偏移位置施加力（产生扭矩）
state.apply_force(thrust * direction, offset)
```

### 4.2 施加冲量

```gdscript
# 立即改变速度（不考虑质量）
state.apply_impulse(jump_impulse)
```

### 4.3 设置速度

```gdscript
# 直接设置线性速度
state.linear_velocity = velocity * speed

# 直接设置角速度
state.angular_velocity = rotation_speed
```

---

## 5. RigidBody vs CharacterBody

| 特性 | RigidBody | CharacterBody |
|------|-----------|---------------|
| 运动控制 | 物理引擎 | 代码控制 |
| 碰撞响应 | 自动处理 | 手动处理 |
| 适用场景 | 抛射物、箱子、球 | 玩家角色、NPC |
| 重力 | 自动应用 | 手动计算 |
| 力的应用 | 支持 | 不支持 |

### 5.1 选择建议

| 场景 | 推荐 |
|------|------|
| 玩家角色 | CharacterBody2D/3D |
| 可推动的箱子 | RigidBody2D/3D |
| 子弹 | Area2D 或 RigidBody |
| 弹跳球 | RigidBody |
| 平台游戏主角 | CharacterBody2D |

---

## 6. "Look At" 实现

### 6.1 问题

不能每帧调用 `look_at()` 来跟随目标。

### 6.2 解决方案：自定义 look_follow

```gdscript
extends RigidBody3D

var speed: float = 0.1

func look_follow(state: PhysicsDirectBodyState3D, 
                 current_transform: Transform3D, 
                 target_position: Vector3) -> void:
    var forward_local_axis := Vector3(1, 0, 0)
    var forward_dir := (current_transform.basis * forward_local_axis).normalized()
    var target_dir := (target_position - current_transform.origin).normalized()
    var local_speed := clampf(speed, 0.0, acos(forward_dir.dot(target_dir)))
    
    if forward_dir.dot(target_dir) > 1e-4:
        state.angular_velocity = (local_speed * forward_dir.cross(target_dir)) / state.step

func _integrate_forces(state):
    var target_pos = $TargetNode.global_transform.origin
    look_follow(state, global_transform, target_pos)
```

> **踩坑点**：此方法使用 `angular_velocity` 旋转物体，与物理引擎兼容。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/physics/rigid_body.rst`
