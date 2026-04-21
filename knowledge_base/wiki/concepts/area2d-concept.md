# Area2D 核心概念

> **来源**: [06F_Area2D.md](../../base/physics-system/06F_Area2D.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

Area2D 定义一个 2D 空间区域，用于**检测重叠**和**影响物理属性**，适用于拾取物品、子弹检测、敌人感知范围等场景。

---

## 🎯 核心功能

### 1. 重叠检测

检测其他 CollisionObject2D 节点的**重叠、进入、退出**。

### 2. 区域影响

**覆盖本地物理属性**（重力、阻尼等），创建特殊物理区域。

---

## 🎮 适用场景

| 场景 | 说明 | 信号/属性 |
|------|------|----------|
| **拾取物品** | 金币、道具等非实体物体 | body_entered |
| **子弹/投射物** | 击中造成伤害但不需要物理反弹 | area_entered |
| **敌人检测范围** | 定义"发现"玩家的半径 | body_entered/body_exited |
| **安全摄像头** | 玩家进入时激活 | body_entered |
| **区域重力** | 创建特殊重力区域 | space_override |
| **减速区域** | 创建阻尼区域 | linear_damp/angular_damp |

---

## ⚙️ 基本属性

### 检测属性

| 属性 | 说明 | 默认值 |
|------|------|--------|
| `Monitoring` | 是否启用检测 | true |
| `Monitorable` | 是否可被其他区域检测 | true |
| `Collision Layer/Mask` | 碰撞层和掩码 | 第 1 层 |

### 物理覆盖属性

| 属性 | 说明 |
|------|------|
| `Gravity` | 重力强度 |
| `Gravity Direction` | 重力方向（无需归一化） |
| `Linear Damp` | 线性阻尼（每秒损失的速度） |
| `Angular Damp` | 角度阻尼（每秒损失的旋转速度） |
| `Space Override` | 覆盖模式 |
| `Priority` | 优先级（高优先级先处理） |

### Space Override 模式

| 模式 | 说明 |
|------|------|
| **Combine** | 将值加到已计算的值上 |
| **Replace** | 替换物理属性，忽略低优先级区域 |
| **Combine-Replace** | 加值并忽略低优先级区域 |
| **Replace-Combine** | 替换当前值但继续计算其他区域 |

> ⚠️ **踩坑点**: 多个 Area2D 重叠时按 Priority 顺序处理，高优先级先处理。

---

## 📡 信号系统

### 信号列表

| 信号 | 触发条件 | 参数 |
|------|----------|------|
| `body_entered(body)` | 物理体进入区域 | Node2D |
| `body_exited(body)` | 物理体离开区域 | Node2D |
| `area_entered(area)` | 另一区域进入 | Area2D |
| `area_exited(area)` | 另一区域离开 | Area2D |

### 选择信号

- 如果玩家是 **CharacterBody2D/RigidBody2D** → 使用 `body_entered`
- 如果玩家是另一个 **Area2D** → 使用 `area_entered`

---

## 💡 实战示例

### 1. 拾取金币

```gdscript
extends Area2D

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.is_in_group("player"):
        # 播放音效
        $AudioStreamPlayer.play()
        
        # 增加分数
        GameManager.add_score(10)
        
        # 消失
        queue_free()
```

### 2. 敌人检测范围

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

### 3. 子弹伤害检测

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

## 🌍 区域影响示例

### 1. 点重力（吸引器）

```gdscript
func _ready():
    # 启用物理覆盖
    space_override = Area2D.SPACE_OVERRIDE_COMBINE
    
    # 设置点重力
    gravity_point = true
    gravity_point_center = Vector2(0, 0)  # 相对于 Area2D 的位置
    gravity = 1000
```

### 2. 阻尼区域（减速区域）

```gdscript
func _ready():
    # 替换物理属性
    space_override = Area2D.SPACE_OVERRIDE_REPLACE
    
    # 设置阻尼
    linear_damp = 5.0   # 快速停止移动
    angular_damp = 10.0 # 快速停止旋转
```

### 3. 区域重力覆盖

```gdscript
func _ready():
    # 组合模式（叠加到世界重力）
    space_override = Area2D.SPACE_OVERRIDE_COMBINE
    gravity = 500
    gravity_direction = Vector2.DOWN
    priority = 1  # 优先级
```

---

## ⚠️ 常见踩坑

### 1. 忘记启用 Monitoring

```gdscript
# ❌ 错误：信号不会触发
monitoring = false

# ✅ 正确：确保启用检测
monitoring = true
```

### 2. 碰撞层配置错误

```gdscript
# ❌ 错误：Area2D 和玩家不在同一检测层
# Area2D: layer=1, mask=0
# Player: layer=2, mask=0

# ✅ 正确：确保互相检测
# Area2D: layer=1, mask=2 (检测玩家层)
# Player: layer=2, mask=1 (检测 Area2D 层)
```

### 3. 多个 Area2D 优先级混乱

```gdscript
# ✅ 正确：设置优先级
area1.priority = 1
area2.priority = 2  # 高优先级先处理
```

---

## 🔗 相关概念

### 物理系统基础

- [物理系统介绍](physics-intro.md) - 碰撞对象类型、碰撞层与掩码
- [CharacterBody2D 概念](characterbody2d-concept.md) - 角色物体详解
- [刚体概念](rigidbody2d-concept.md) - 刚体详解

### 实战指南

- [射线投射指南](../guides/raycasting-guide.md) - 射线检测应用

### Base 层来源

- [06F_Area2D.md](../../base/physics-system/06F_Area2D.md) - 完整原始文档

---

## 📊 核心知识点总结

| 知识点 | 重要性 | 说明 |
|--------|--------|------|
| 信号系统 | 🔴 必读 | body_entered/body_exited/area_entered/area_exited |
| Space Override | 🔴 必读 | Combine/Replace 模式 |
| 碰撞层配置 | 🔴 必读 | 确保 Area2D 和玩家互相检测 |
| 优先级 | 🟡 推荐 | priority 属性决定处理顺序 |
| 区域影响 | 🟡 推荐 | 重力/阻尼/音频总线覆盖 |

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.6
