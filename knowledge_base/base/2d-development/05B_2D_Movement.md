# Godot 4.x 2D 移动模式

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/2d_movement.rst

---

## 目录

1. [8方向移动](#1-8方向移动)
2. [旋转+移动（键盘控制）](#2-旋转移动键盘控制)
3. [旋转+移动（鼠标控制）](#3-旋转移动鼠标控制)
4. [点击移动](#4-点击移动)
5. [移动模式对比](#5-移动模式对比)

---

## 1. 8方向移动

### 1.1 基本实现

适用于俯视角游戏（RPG、塔防等）。

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

### 1.2 Input.get_vector()

`get_vector()` 自动处理对角线移动的归一化：

```gdscript
# 返回长度为 1 的方向向量
var direction = Input.get_vector("left", "right", "up", "down")
# 对角线移动速度不会更快
velocity = direction * speed
```

---

## 2. 旋转+移动（键盘控制）

### 2.1 基本实现

适用于太空射击、赛车等游戏。

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

### 2.2 transform.x

`transform.x` 指向节点的"前方"方向：

```gdscript
# transform.x 指向右方（节点的前方）
velocity = transform.x * Input.get_axis("down", "up") * speed
```

> **踩坑点**：Godot 4.x 中 `transform.x` 指向右方。如果精灵默认朝上，需要调整精灵旋转或使用 `-transform.y`。

---

## 3. 旋转+移动（鼠标控制）

### 3.1 基本实现

角色始终面向鼠标位置。

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

### 3.2 look_at()

`look_at()` 使节点指向目标位置：

```gdscript
look_at(get_global_mouse_position())

# 等价于：
rotation = get_global_mouse_position().angle_to_point(position)
```

---

## 4. 点击移动

### 4.1 基本实现

点击屏幕位置，角色移动到该位置。

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

### 4.2 距离检查

```gdscript
# 防止到达目标后抖动
if position.distance_to(target) > 10:
    move_and_slide()
```

> **踩坑点**：不做距离检查会导致角色到达目标后"抖动"，因为每帧都会稍微超过目标位置然后尝试返回。

---

## 5. 移动模式对比

| 模式 | 适用场景 | 输入方式 | 特点 |
|------|---------|---------|------|
| 8方向 | RPG、塔防、俯视角射击 | WASD/方向键 | 直观、易控制 |
| 旋转+键盘 | 太空射击、赛车 | 左右旋转+前进 | 惯性、真实感 |
| 旋转+鼠标 | 俯视角射击、塔防角色 | 鼠标瞄准+WASD | 精确瞄准 |
| 点击移动 | RTS、回合制 | 鼠标点击 | 简单操作 |

### 5.1 选择建议

- **RPG/冒险游戏**：8方向移动
- **太空射击**：旋转+键盘
- **俯视角射击**：旋转+鼠标
- **RTS/策略**：点击移动
- **塔防（玩家角色）**：旋转+鼠标或点击移动

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/2d/2d_movement.rst`
