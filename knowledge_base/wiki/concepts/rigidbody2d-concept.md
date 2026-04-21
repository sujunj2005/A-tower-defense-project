# RigidBody2D 核心概念

> **来源**: [06E_RigidBody.md](../../base/physics-system/06E_RigidBody.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

RigidBody2D 是由**物理引擎直接控制**的物体，用于模拟真实物理对象的行为，如抛射物、箱子、球等。

---

## 🎯 核心特点

### RigidBody2D vs CharacterBody2D

| 特性 | RigidBody2D | CharacterBody2D |
|------|-------------|-----------------|
| **运动控制** | 物理引擎控制 | 代码控制 |
| **碰撞响应** | 自动处理 | 手动处理 |
| **重力** | 自动应用 | 手动计算 |
| **力的应用** | 支持施加力/冲量 | 不支持 |
| **适用场景** | 抛射物、箱子、球 | 玩家角色、NPC |

### 物理材质（PhysicsMaterial）

需要添加 PhysicsMaterial 来调整摩擦力和弹性：

```gdscript
@export var material: PhysicsMaterial

func _ready():
    material.friction = 0.8      # 摩擦系数（0-1）
    material.bounce = 0.5        # 弹性系数（0-1）
    material.absorbent = false   # 是否吸收能量
    material.rough = false       # 是否粗糙
```

---

## ⚙️ 控制刚体

### _integrate_forces - 正确的控制方式

使用 `_integrate_forces()` 回调控制刚体，这是**唯一安全**的控制方式：

```gdscript
extends RigidBody2D

var thrust: float = 250.0
var torque: float = 20000.0

func _integrate_forces(state: PhysicsDirectBodyState2D):
    # 施加力（推进器）
    if Input.is_action_pressed("ui_up"):
        state.apply_force(thrust * transform.y.rotated(rotation))
    else:
        state.apply_force(Vector2.ZERO)
    
    # 施加扭矩（旋转）
    var rotation_dir = Input.get_axis("ui_left", "ui_right")
    state.apply_torque(rotation_dir * torque)
```

> ⚠️ **踩坑点**: 不要每帧调用 `look_at()` 或 `global_position` 来设置位置！这会破坏物理模拟。

### 可用操作（在 _integrate_forces 中）

| 操作 | 方法 | 说明 |
|------|------|------|
| 施加力 | `state.apply_force(force, position)` | 在指定位置施加力 |
| 施加冲量 | `state.apply_impulse(impulse, position)` | 立即改变速度（不考虑质量） |
| 设置速度 | `state.linear_velocity = velocity` | 直接设置线性速度 |
| 设置角速度 | `state.angular_velocity = angular_vel` | 直接设置旋转速度 |
| 设置变换 | `state.transform = new_transform` | 直接设置位置旋转 |

---

## 🚀 常用操作

### 施加力

```gdscript
func _integrate_forces(state):
    # 在中心施加力
    state.apply_force(thrust * direction)
    
    # 在偏移位置施加力（产生扭矩）
    var offset = Vector2(0, 10)
    state.apply_force(thrust * direction, offset)
```

### 施加冲量

```gdscript
func _integrate_forces(state):
    # 跳跃冲量（立即改变速度）
    if Input.is_action_just_pressed("jump"):
        state.apply_impulse(Vector2.UP * jump_impulse)
```

### 设置速度

```gdscript
func _integrate_forces(state):
    # 直接设置线性速度
    state.linear_velocity = velocity * speed
    
    # 直接设置角速度
    state.angular_velocity = rotation_speed
```

---

## 🎯 特殊实现：Look Follow

### 问题

不能每帧调用 `look_at()` 来跟随目标，会破坏物理模拟。

### 解决方案：自定义 look_follow

```gdscript
extends RigidBody2D

var speed: float = 0.1

func look_follow(state: PhysicsDirectBodyState2D, 
                 current_transform: Transform2D, 
                 target_position: Vector2) -> void:
    var forward_local_axis := Vector2.RIGHT
    var forward_dir := (current_transform.basis * forward_local_axis).normalized()
    var target_dir := (target_position - current_transform.origin).normalized()
    var local_speed := clampf(speed, 0.0, acos(forward_dir.dot(target_dir)))
    
    if forward_dir.dot(target_dir) > 1e-4:
        state.angular_velocity = (local_speed * forward_dir.cross(target_dir)) / state.step

func _integrate_forces(state):
    var target_pos = $TargetNode.global_position
    look_follow(state, global_transform, target_pos)
```

> ⚠️ **踩坑点**: 此方法使用 `angular_velocity` 旋转物体，与物理引擎兼容。

---

## 😴 睡眠机制

刚体静止一段时间后会进入睡眠状态，节省性能。

```gdscript
# 禁止睡眠（需要持续模拟时）
can_sleep = false

# 检查是否睡眠
if sleeping:
    print("刚体正在睡眠")
```

---

## 📊 接触报告

### 启用接触报告

```gdscript
func _ready():
    # 设置最大报告接触数
    max_contacts_reported = 4
    
    # 启用接触监控
    contact_monitor = true
    
    # 连接信号
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    print("碰撞了：", body.name)
```

---

## ⚠️ 常见踩坑

### 1. 不要直接设置 position

```gdscript
# ❌ 错误：每帧调用会破坏物理模拟
func _process(delta):
    look_at(target.position)
    global_position = target_position

# ✅ 正确：使用 _integrate_forces
func _integrate_forces(state):
    # 使用力/冲量/速度控制
    state.apply_force(force)
```

### 2. 初始化位置

```gdscript
# ✅ 正确：只在 _ready 中设置一次
func _ready():
    global_position = spawn_position
    look_at(target.global_position)
```

---

## 🔗 相关概念

### 物理系统基础

- [物理系统介绍](physics-intro.md) - 碰撞对象类型、碰撞层与掩码
- [CharacterBody2D 概念](characterbody2d-concept.md) - 角色物体详解

### 实战指南

- [射线投射指南](../guides/raycasting-guide.md) - 射线检测应用

### Base 层来源

- [06E_RigidBody.md](../../base/physics-system/06E_RigidBody.md) - 完整原始文档

---

## 📊 核心知识点总结

| 知识点 | 重要性 | 说明 |
|--------|--------|------|
| _integrate_forces | 🔴 必读 | 控制刚体的唯一安全方式 |
| 施加力/冲量 | 🔴 必读 | apply_force()/apply_impulse() |
| 物理材质 | 🟡 推荐 | PhysicsMaterial 摩擦/弹性 |
| 睡眠机制 | 🟢 参考 | can_sleep 属性 |
| Look Follow | 🟡 推荐 | 自定义旋转实现 |

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.6
