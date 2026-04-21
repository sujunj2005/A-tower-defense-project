# Godot 4.x Area2D 使用指南

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/physics/using_area_2d.rst

---

## 目录

1. [Area2D 概述](#1-area2d-概述)
2. [Area 属性](#2-area-属性)
3. [重叠检测](#3-重叠检测)
4. [区域影响](#4-区域影响)

---

## 1. Area2D 概述

### 1.1 什么是 Area2D

Area2D 定义一个 2D 空间区域，可以：
- 检测其他 CollisionObject2D 节点的**重叠、进入、退出**
- **覆盖本地物理属性**（重力、阻尼等）

### 1.2 适用场景

| 场景 | 说明 |
|------|------|
| 拾取物品 | 金币、道具等非实体物体 |
| 子弹/投射物 | 击中造成伤害但不需要物理反弹 |
| 敌人检测范围 | 定义"发现"玩家的半径 |
| 安全摄像头 | 玩家进入时激活 |

---

## 2. Area 属性

### 2.1 基本属性

| 属性 | 说明 |
|------|------|
| `Monitoring` | 是否启用检测 |
| `Monitorable` | 是否可被其他区域检测 |
| `Collision Layer/Mask` | 碰撞层和掩码 |
| `Audio Bus` | 区域内音频总线覆盖 |

### 2.2 物理覆盖属性

| 属性 | 说明 |
|------|------|
| `Gravity` | 重力强度 |
| `Gravity Direction` | 重力方向（无需归一化） |
| `Linear Damp` | 线性阻尼（每秒损失的速度） |
| `Angular Damp` | 角度阻尼（每秒损失的旋转速度） |
| `Space Override` | 覆盖模式 |
| `Priority` | 优先级（高优先级先处理） |

### 2.3 Space Override 模式

| 模式 | 说明 |
|------|------|
| **Combine** | 将值加到已计算的值上 |
| **Replace** | 替换物理属性，忽略低优先级区域 |
| **Combine-Replace** | 加值并忽略低优先级区域 |
| **Replace-Combine** | 替换当前值但继续计算其他区域 |

> **踩坑点**：多个 Area2D 重叠时按 Priority 顺序处理，高优先级先处理。

---

## 3. 重叠检测

### 3.1 信号列表

| 信号 | 触发条件 |
|------|----------|
| `body_entered(body)` | 物理体进入区域 |
| `body_exited(body)` | 物理体离开区域 |
| `area_entered(area)` | 另一区域进入 |
| `area_exited(area)` | 另一区域离开 |

### 3.2 选择信号

- 如果玩家是 **CharacterBody2D/RigidBody2D** → 使用 `body_entered`
- 如果玩家是另一个 **Area2D** → 使用 `area_entered`

### 3.3 示例：拾取金币

```gdscript
extends Area2D

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.is_in_group("player"):
        queue_free()  # 被拾取后消失
```

### 3.4 示例：敌人检测范围

```gdscript
extends Area2D

@onready var enemy = $EnemyBody

func _ready():
    body_entered.connect(_on_player_detected)
    body_exited.connect(_on_player_lost)

func _on_player_detected(player):
    if player.is_in_group("player"):
        enemy.start_chasing()

func _on_player_lost(player):
    if player.is_in_group("player"):
        enemy.stop_chasing()
```

### 3.5 示例：子弹伤害检测

```gdscript
extends Area2D

var damage: int = 10
var speed: float = 500.0

func _physics_process(delta):
    position += transform.x * speed * delta

func _on_bullet_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(damage)
    queue_free()
```

---

## 4. 区域影响

### 4.1 启用物理覆盖

默认情况下 Area2D 不影响物理。需要设置 Space Override：

```gdscript
space_override = Area2D.SPACE_OVERRIDE_COMBINE
gravity = 200
gravity_direction = Vector2.DOWN
```

### 4.2 点重力

创建"吸引器"效果：

```gdscript
space_override = Area2D.SPACE_OVERRIDE_COMBINE
gravity_point = true
gravity_point_center = Vector2(0, 0)  # 相对于 Area2D 的位置
gravity = 1000
```

### 4.3 阻尼区域

创建减速区域：

```gdscript
space_override = Area2D.SPACE_OVERRIDE_REPLACE
linear_damp = 5.0  # 快速停止移动
angular_damp = 10.0  # 快速停止旋转
```

### 4.4 音频总线覆盖

```gdscript
audio_bus_name = "ReverbBus"
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/physics/using_area_2d.rst`
