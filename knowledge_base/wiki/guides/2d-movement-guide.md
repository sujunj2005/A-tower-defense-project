# 2D 移动指南

> **来源**: [05B_2D_Movement.md](../../base/2d-development/05B_2D_Movement.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本指南介绍 Godot 4.x 中实现 2D 移动的四种主要模式，包括代码实现、适用场景和注意事项。

---

## 🎮 8 方向移动

### 适用场景

- RPG 游戏
- 塔防游戏
- 俯视角射击游戏
- 冒险游戏

### 基本实现

```gdscript
extends CharacterBody2D

@export var speed = 400

func get_input():
    var input_direction = Input.get_vector("left", "right", "up", "down")
    velocity = input_direction * speed

func _physics_process(delta):
    get_input()
    move_and_slide()
```

### Input.get_vector()

`get_vector()` 自动处理对角线移动的归一化：

```gdscript
# 返回长度为 1 的方向向量
var direction = Input.get_vector("left", "right", "up", "down")
# 对角线移动速度不会更快
velocity = direction * speed
```

### 输入映射设置

在 `Project Settings > Input Map` 中设置：
- `left`: A 或 Left Arrow
- `right`: D 或 Right Arrow
- `up`: W 或 Up Arrow
- `down`: S 或 Down Arrow

---

## 🔄 旋转 + 移动（键盘控制）

### 适用场景

- 太空射击游戏
- 赛车游戏
- 坦克类游戏
- 飞机射击游戏

### 基本实现

```gdscript
extends CharacterBody2D

@export var speed = 400
@export var rotation_speed = 1.5

var rotation_direction = 0

func get_input():
    rotation_direction = Input.get_axis("left", "right")
    velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
    get_input()
    rotation += rotation_direction * rotation_speed * delta
    move_and_slide()
```

### transform.x

`transform.x` 指向节点的"前方"方向：

```gdscript
# transform.x 指向右方（节点的前方）
velocity = transform.x * Input.get_axis("down", "up") * speed
```

> ⚠️ **踩坑点**: Godot 4.x 中 `transform.x` 指向右方。如果精灵默认朝上，需要调整精灵旋转或使用 `-transform.y`。

### 精灵朝向调整

如果精灵默认朝上而不是朝右：

```gdscript
# 方法 1: 在编辑器中旋转精灵 90 度
# 方法 2: 在代码中调整
velocity = -transform.y * Input.get_axis("down", "up") * speed
```

---

## 🖱️ 旋转 + 移动（鼠标控制）

### 适用场景

- 俯视角射击游戏
- 塔防游戏的玩家角色
- 需要精确瞄准的游戏
- 双摇杆射击游戏

### 基本实现

```gdscript
extends CharacterBody2D

@export var speed = 400

func get_input():
    look_at(get_global_mouse_position())
    velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
    get_input()
    move_and_slide()
```

### look_at()

`look_at()` 使节点指向目标位置：

```gdscript
look_at(get_global_mouse_position())

# 等价于：
rotation = get_global_mouse_position().angle_to_point(position)
```

### 限制旋转角度

如果需要限制旋转角度（如只能旋转±45 度）：

```gdscript
func limit_rotation(target_angle: float, limit: float):
    var current = rotation
    var diff = target_angle - current
    
    # 规范化到 -PI 到 PI
    while diff > PI:
        diff -= TAU
    while diff < -PI:
        diff += TAU
    
    # 限制角度
    diff = clamp(diff, -limit, limit)
    rotation = current + diff
```

---

## 🎯 点击移动

### 适用场景

- RTS 游戏
- 回合制策略游戏
- 点击冒险游戏
- 简化操作的手游

### 基本实现

```gdscript
extends CharacterBody2D

@export var speed = 400

var target = position

func _input(event):
    if event.is_action_pressed("click"):
        target = get_global_mouse_position()

func _physics_process(delta):
    velocity = position.direction_to(target) * speed
    if position.distance_to(target) > 10:
        move_and_slide()
```

### 距离检查

```gdscript
# 防止到达目标后抖动
if position.distance_to(target) > 10:
    move_and_slide()
```

> ⚠️ **踩坑点**: 不做距离检查会导致角色到达目标后"抖动"，因为每帧都会稍微超过目标位置然后尝试返回。

### 平滑停止

使用插值实现平滑停止：

```gdscript
func _physics_process(delta):
    var distance = position.distance_to(target)
    
    if distance > 10:
        # 计算方向
        var direction = position.direction_to(target)
        
        # 使用 lerp 平滑减速
        var speed_factor = min(distance / 100.0, 1.0)
        velocity = direction * speed * speed_factor
        
        move_and_slide()
    else:
        velocity = Vector2.ZERO
```

---

## 📊 移动模式对比

| 模式 | 适用场景 | 输入方式 | 特点 |
|------|---------|---------|------|
| **8 方向** | RPG、塔防、俯视角射击 | WASD/方向键 | 直观、易控制 |
| **旋转 + 键盘** | 太空射击、赛车 | 左右旋转 + 前进 | 惯性、真实感 |
| **旋转 + 鼠标** | 俯视角射击、塔防角色 | 鼠标瞄准+WASD | 精确瞄准 |
| **点击移动** | RTS、回合制 | 鼠标点击 | 简单操作 |

### 选择建议

- **RPG/冒险游戏**: 8 方向移动
- **太空射击**: 旋转 + 键盘
- **俯视角射击**: 旋转 + 鼠标
- **RTS/策略**: 点击移动
- **塔防（玩家角色）**: 旋转 + 鼠标或点击移动

---

## 🛠️ 高级技巧

### 添加加速度

```gdscript
extends CharacterBody2D

@export var max_speed = 400
@export var acceleration = 800
@export var friction = 600

func get_input():
    var input_direction = Input.get_vector("left", "right", "up", "down")
    
    if input_direction:
        velocity = velocity.move_toward(input_direction * max_speed, acceleration * get_physics_process_delta_time())
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * get_physics_process_delta_time())

func _physics_process(delta):
    get_input()
    move_and_slide()
```

### 添加冲刺功能

```gdscript
extends CharacterBody2D

@export var speed = 400
@export var dash_speed = 800
@export var dash_duration = 0.2
@export var dash_cooldown = 1.0

var can_dash = true
var is_dashing = false

func get_input():
    var input_direction = Input.get_vector("left", "right", "up", "down")
    
    if Input.is_action_just_pressed("dash") and can_dash and input_direction:
        start_dash(input_direction)
    
    if is_dashing:
        velocity = velocity.move_toward(input_direction * dash_speed, 5000 * get_physics_process_delta_time())
    else:
        velocity = velocity.move_toward(input_direction * speed, 800 * get_physics_process_delta_time())

func start_dash(direction):
    is_dashing = true
    can_dash = false
    velocity = direction * dash_speed
    
    await get_tree().create_timer(dash_duration).timeout
    is_dashing = false
    
    await get_tree().create_timer(dash_cooldown).timeout
    can_dash = true

func _physics_process(delta):
    get_input()
    move_and_slide()
```

### 添加斜坡滑动

```gdscript
extends CharacterBody2D

@export var speed = 400
@export var slope_slide_factor = 0.5

func get_input():
    var input_direction = Input.get_vector("left", "right", "up", "down")
    velocity = input_direction * speed
    
    # 添加斜坡滑动
    if is_on_floor():
        var floor_normal = get_floor_normal()
        var slide_velocity = Vector2(-floor_normal.x, -floor_normal.y) * speed * slope_slide_factor
        velocity += slide_velocity

func _physics_process(delta):
    get_input()
    move_and_slide()
```

---

## ⚠️ 常见踩坑

### 踩坑 1: 对角线移动更快

**问题**: 使用 `Input.get_axis()` 分别获取 X 和 Y 轴时，对角线移动速度更快

**错误代码**:
```gdscript
# ❌ 错误
var x = Input.get_axis("left", "right")
var y = Input.get_axis("up", "down")
velocity = Vector2(x, y) * speed  # 对角线速度是 1.414 倍
```

**解决方案**:
```gdscript
# ✅ 正确
var direction = Input.get_vector("left", "right", "up", "down")
velocity = direction * speed  # 自动归一化
```

### 踩坑 2: 到达目标后抖动

**问题**: 点击移动时角色在目标位置抖动

**解决方案**:
```gdscript
# 添加距离检查
if position.distance_to(target) > 10:
    move_and_slide()
else:
    velocity = Vector2.ZERO
```

### 踩坑 3: 旋转方向错误

**问题**: 精灵朝向不正确

**解决方案**:
```gdscript
# 如果精灵默认朝上而不是朝右
velocity = -transform.y * speed  # 使用 Y 轴而不是 X 轴

# 或者在编辑器中旋转精灵 90 度
```

---

## 🔗 相关链接

### 前置知识
- [2D 开发介绍](../concepts/2d-development-intro.md) - CharacterBody2D 基础
- [2D 变换概念](../concepts/2d-transforms.md) - transform 属性
- [向量数学概念](../concepts/vector-math.md) - 方向计算基础

### 后续学习
- [Sprite 动画指南](sprite-animation-guide.md) - 添加移动动画
- [插值运算指南](../guides/interpolation-guide.md) - 平滑移动

### Base 层来源
- [05B_2D_Movement.md](../../base/2d-development/05B_2D_Movement.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
