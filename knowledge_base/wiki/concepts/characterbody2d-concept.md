# CharacterBody2D 核心概念

> **来源**: [06B_CharacterBody2D.md](../../base/physics-system/06B_CharacterBody2D.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

CharacterBody2D 是用于**玩家/NPC 角色控制**的物理体，通过代码控制移动，不受物理引擎驱动，提供精确的移动控制。

---

## 🎯 核心特点

### CharacterBody2D vs RigidBody2D

| 特性 | CharacterBody2D | RigidBody2D |
|------|-----------------|-------------|
| **运动控制** | 代码控制 velocity | 物理引擎控制 |
| **碰撞响应** | 手动处理（move_and_slide） | 自动处理 |
| **重力** | 手动计算（velocity.y += gravity * delta） | 自动应用 |
| **适用场景** | 玩家角色、NPC | 抛射物、箱子、球 |
| **力的应用** | 不支持 | 支持施加力/冲量 |

### 关键属性

| 属性 | 默认值 | 说明 |
|------|--------|------|
| `velocity` | Vector2(0, 0) | 速度向量（像素/秒） |
| `motion_mode` | MOTION_MODE_GROUNDED | 移动模式（地面/浮动） |
| `up_direction` | Vector2(0, -1) | 定义"上方"的方向 |
| `floor_stop_on_slope` | true | 在斜坡上停止滑动 |
| `floor_max_angle` | 0.785 rad (45°) | 最大地面角度 |

---

## 🚀 移动方法

### move_and_slide() - 推荐

最常用的移动方法，自动处理碰撞滑动：

```gdscript
extends CharacterBody2D

var speed = 300.0
var jump_speed = -400.0
var gravity = 980.0

func _physics_process(delta):
    # 添加重力
    velocity.y += gravity * delta
    
    # 跳跃（在地面上才能跳）
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_speed
    
    # 水平移动
    var direction = Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * speed
    
    # 执行移动（自动处理碰撞）
    move_and_slide()
```

### move_and_collide() - 自定义响应

用于需要自定义碰撞响应的场景（如子弹反弹）：

```gdscript
extends CharacterBody2D

var speed = 750

func start(position: Vector2, direction: float):
    rotation = direction
    position = position
    velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
    var collision = move_and_collide(velocity * delta)
    if collision:
        # 反弹效果
        velocity = velocity.bounce(collision.get_normal())
        
        # 触发击中逻辑
        if collision.get_collider().has_method("hit"):
            collision.get_collider().hit()
```

### 两种方法对比

| 特性 | move_and_collide | move_and_slide |
|------|------------------|----------------|
| 碰撞响应 | 无（需手动处理） | 自动滑动 |
| 返回值 | KinematicCollision2D | 无 |
| 复杂度 | 较低 | 较高 |
| 灵活性 | 高 | 中 |
| **适用场景** | 自定义响应、子弹反弹 | 平台游戏、俯视角游戏 |

---

## 🔍 碰撞检测

### 基础检测

```gdscript
# 检测是否在地面上
if is_on_floor():
    print("在地面上")

# 检测是否碰到墙壁
if is_on_wall():
    print("碰到墙壁")

# 检测是否碰到天花板
if is_on_ceiling():
    print("碰到天花板")
```

### 获取碰撞详情

```gdscript
move_and_slide()

# 遍历所有碰撞
for i in get_slide_collision_count():
    var collision = get_slide_collision(i)
    
    # 获取碰撞信息
    var collider = collision.get_collider()
    var normal = collision.get_normal()
    var position = collision.get_position()
    
    print("碰撞了：", collider.name)
    print("碰撞法线：", normal)
```

---

## 🎮 移动模式

### 地面模式（平台游戏）

```gdscript
motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
up_direction = Vector2.UP  # (0, -1)

# 自动处理重力和地面检测
if is_on_floor():
    can_jump = true
```

### 浮动模式（俯视角游戏）

```gdscript
motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

# 俯视角移动示例
func _physics_process(delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * speed
    move_and_slide()
```

---

## ⚠️ 常见踩坑

### 1. 不要直接设置 position

```gdscript
# ❌ 错误：直接设置位置会跳过碰撞检测
position += velocity * delta

# ✅ 正确：使用移动方法
move_and_slide()
```

### 2. 在 _physics_process 中处理

```gdscript
# ❌ 错误：在 _process 中处理物理
func _process(delta):
    velocity.y += gravity * delta
    move_and_slide()

# ✅ 正确：在 _physics_process 中处理
func _physics_process(delta):
    velocity.y += gravity * delta
    move_and_slide()
```

### 3. move_and_slide() 不乘 delta

```gdscript
# ✅ 正确
velocity.y += gravity * delta
move_and_slide()  # 内部已处理 delta

# ❌ 错误
velocity.y += gravity * delta
move_and_slide() * delta  # 不需要再乘 delta
```

---

## 🔗 相关概念

### 物理系统基础

- [物理系统介绍](physics-intro.md) - 碰撞对象类型、碰撞层与掩码
- [刚体概念](rigidbody2d-concept.md) - RigidBody2D 详解

### 实战指南

- [射线投射指南](../guides/raycasting-guide.md) - 射线检测应用

### Base 层来源

- [06B_CharacterBody2D.md](../../base/physics-system/06B_CharacterBody2D.md) - 完整原始文档

### Wiki 层相关

- [物理系统介绍](./physics-intro.md) - 物理系统基础
- [2D 移动指南](../guides/2d-movement-guide.md) - 8 种移动模式实战
- [玩家实体设计](../entities/player.md) - CharacterBody2D 完整实现
- [敌人实体设计](../entities/enemy.md) - NPC 移动控制
- [碰撞检测方案对比](../comparisons/collision-detection-comparison.md) - 碰撞形状选择

---

## 📊 核心知识点总结

| 知识点 | 重要性 | 说明 |
|--------|--------|------|
| move_and_slide() | 🔴 必读 | 最常用的移动方法 |
| move_and_collide() | 🔴 必读 | 自定义碰撞响应 |
| 碰撞检测 | 🔴 必读 | is_on_floor()/is_on_wall()/get_slide_collision() |
| 移动模式 | 🟡 推荐 | GROUNDED vs FLOATING |
| 重力处理 | 🔴 必读 | velocity.y += gravity * delta |

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.6
