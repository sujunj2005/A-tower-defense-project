# Godot 4.x CharacterBody2D 详解

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/physics/using_character_body_2d.rst

---

## 目录

1. [角色物体概述](#1-角色物体概述)
2. [移动与碰撞](#2-移动与碰撞)
3. [move_and_collide](#3-move_and_collide)
4. [move_and_slide](#4-move_and_slide)
5. [检测碰撞](#5-检测碰撞)
6. [平台角色示例](#6-平台角色示例)

---

## 1. 角色物体概述

### 1.1 什么是 CharacterBody2D

CharacterBody2D 用于实现通过代码控制的角色：

- 检测与其他物体的碰撞
- 不受物理引擎属性影响（重力、摩擦等）
- 需要编写代码控制行为
- 提供精确的移动控制

> **踩坑点**：CharacterBody2D 可以受重力和其他力影响，但必须在代码中计算移动。物理引擎不会自动移动它。

---

## 2. 移动与碰撞

### 2.1 不要直接设置 position

```gdscript
# 错误：直接设置位置会跳过碰撞检测
position += velocity * delta

# 正确：使用移动方法
move_and_slide()
```

### 2.2 在 _physics_process 中处理

```gdscript
func _physics_process(delta):
    # 物理相关代码放在这里
    velocity.y += gravity * delta
    move_and_slide()
```

---

## 3. move_and_collide

### 3.1 基本用法

```gdscript
var collision = move_and_collide(velocity * delta)
if collision:
    print("碰撞了：", collision.get_collider().name)
```

### 3.2 返回值

返回 `KinematicCollision2D` 对象，包含：

| 属性/方法 | 说明 |
|-----------|------|
| `get_collider()` | 碰撞的物体 |
| `get_normal()` | 碰撞法线 |
| `get_position()` | 碰撞点 |
| `get_remainder()` | 剩余移动距离 |

### 3.3 适用场景

- 需要自定义碰撞响应
- 子弹反弹
- 简单碰撞检测

---

## 4. move_and_slide

### 4.1 基本用法

```gdscript
func _physics_process(delta):
    velocity.y += gravity * delta
    move_and_slide()
```

### 4.2 重要属性

| 属性 | 默认值 | 说明 |
|------|--------|------|
| `velocity` | Vector2(0, 0) | 速度向量（像素/秒） |
| `motion_mode` | GROUNDED | 移动模式（地面/浮动） |
| `up_direction` | Vector2(0, -1) | 定义"上方"的方向 |
| `floor_stop_on_slope` | true | 在斜坡上停止滑动 |
| `floor_max_angle` | 0.785 rad (45°) | 最大地面角度 |
| `wall_min_slide_angle` | 0.262 rad (15°) | 最小滑行角度 |

### 4.3 移动模式

```gdscript
# 横版平台游戏
motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
up_direction = Vector2.UP  # (0, -1)

# 俯视角游戏
motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
```

### 4.4 地面检测

```gdscript
if is_on_floor():
    # 在地面上
    pass

if is_on_wall():
    # 碰到墙壁
    pass

if is_on_ceiling():
    # 碰到天花板
    pass
```

> **踩坑点**：`move_and_slide()` 会自动修改 `velocity` 变量。碰撞后速度会被重新计算。

---

## 5. 检测碰撞

### 5.1 move_and_slide 碰撞检测

```gdscript
move_and_slide()
for i in get_slide_collision_count():
    var collision = get_slide_collision(i)
    print("碰撞了：", collision.get_collider().name)
```

### 5.2 get_slide_collision

```gdscript
var collision = get_slide_collision(0)  # 获取第一个碰撞
var normal = collision.get_normal()     # 碰撞法线
var collider = collision.get_collider() # 碰撞物体
```

---

## 6. 平台角色示例

### 6.1 基本平台角色

```gdscript
extends CharacterBody2D

var speed = 300.0
var jump_speed = -400.0

func _physics_process(delta):
    # 添加重力
    velocity.y += get_gravity() * delta
    
    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_speed
    
    # 水平移动
    var direction = Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * speed
    
    move_and_slide()
```

### 6.2 反弹子弹

```gdscript
extends CharacterBody2D

var speed = 750

func start(_position, _direction):
    rotation = _direction
    position = _position
    velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
    var collision = move_and_collide(velocity * delta)
    if collision:
        velocity = velocity.bounce(collision.get_normal())
        if collision.get_collider().has_method("hit"):
            collision.get_collider().hit()
```

### 6.3 俯视角移动

```gdscript
extends CharacterBody2D

var speed = 300

func _physics_process(delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * speed
    move_and_slide()
```

---

## 7. move_and_collide vs move_and_slide

| 特性 | move_and_collide | move_and_slide |
|------|------------------|----------------|
| 碰撞响应 | 无（需手动处理） | 自动滑动 |
| 复杂度 | 较低 | 较高 |
| 灵活性 | 高 | 中 |
| 适用场景 | 自定义响应、子弹反弹 | 平台游戏、俯视角游戏 |

### 7.1 等价代码

```gdscript
# move_and_collide 实现 move_and_slide 效果
var collision = move_and_collide(velocity * delta)
if collision:
    velocity = velocity.slide(collision.get_normal())

# 等价于
move_and_slide()
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/physics/using_character_body_2d.rst`
