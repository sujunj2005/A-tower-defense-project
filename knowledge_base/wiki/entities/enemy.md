# 敌人实体设计

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [14_Tower_Defense_Case_Study.md](../../base/practical-experiences/case-studies/14_Tower_Defense_Case_Study.md), [Godot_4x_Resource_File_Comment_Issue.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md)

---

## 📖 实体概述

敌人是塔防游戏中的主要交互对象，沿预定路径移动，被塔攻击，到达终点时扣除玩家生命。

---

## 📋 目录

1. [继承体系](#1-继承体系)
2. [核心组件](#2-核心组件)
3. [数据结构](#3-数据结构)
4. [行为逻辑](#4-行为逻辑)
5. [配置系统](#5-配置系统)
6. [踩坑记录](#6-踩坑记录)

---

## 1. 继承体系

```
Node2D
    └── Enemy (敌人)
        ├── LightArmor (轻甲怪)
        ├── HeavyArmor (重甲怪)
        └── MagicShield (魔抗怪)
```

---

## 2. 核心组件

### 2.1 敌人基类

```gdscript
class_name Enemy
extends Node2D

@export_group("BaseInfo")
@export var enemy_id: String
@export var enemy_name: String
@export var max_health: float = 100.0
@export var speed: float = 50.0

@export_group("Rewards")
@export var gold_drop: int = 10
@export var experience_drop: int = 5

@export_group("Visual")
@export var texture_path: String
@export var scale_factor: float = 2.0

# 运行时状态
var current_health: float
var is_alive: bool = true
var current_waypoint: int = 0
```

### 2.2 重甲怪实现

```gdscript
class_name HeavyArmor
extends Enemy

@export_group("ArmorInfo")
@export var physical_resistance: float = 0.5  # 50% 物理减伤
@export var magic_resistance: float = 0.2     # 20% 魔法减伤

func take_damage(amount: float, damage_type: int) -> void:
    var final_damage = calculate_final_damage(amount, damage_type)
    current_health -= final_damage
    
    if current_health <= 0:
        die()
```

---

## 3. 数据结构

### 3.1 敌人配置数据

```gdscript
# EnemyConfig 资源类
class_name EnemyConfig
extends Resource

@export var enemy_id: String
@export var enemy_name: String
@export var max_health: float
@export var speed: float
@export var gold_drop: int
@export var experience_drop: int
@export var texture_path: String
@export var armor_type: String  # "light", "heavy", "magic"
```

### 3.2 波次配置

```gdscript
# WaveEnemyConfig 资源类
class_name WaveEnemyConfig
extends Resource

@export var enemy_config: EnemyConfig
@export var count: int = 5
@export var spawn_interval: float = 1.0
@export var start_delay: float = 0.0
```

---

## 4. 行为逻辑

### 4.1 路径移动

```gdscript
func _physics_process(delta):
    if not is_alive:
        return
    
    var target = waypoints[current_waypoint]
    var direction = (target - global_position).normalized()
    
    if direction.length() > 0:
        global_position += direction * speed * delta
    
    # 检查是否到达 waypoint
    if global_position.distance_to(target) < 5.0:
        current_waypoint += 1
        if current_waypoint >= waypoints.size():
            reached_end()
```

### 4.2 受击处理

```gdscript
func take_damage(amount: float, damage_type: int = DamageType.NORMAL):
    if not is_alive:
        return
    
    var final_damage = amount
    
    # 根据护甲类型计算伤害
    match armor_type:
        "heavy":
            if damage_type == DamageType.NORMAL:
                final_damage = amount * 0.5  # 50% 减伤
        "magic":
            if damage_type == DamageType.MAGIC:
                final_damage = amount * 0.3  # 70% 减伤
    
    current_health -= final_damage
    
    if current_health <= 0:
        die()
```

### 4.3 死亡处理

```gdscript
func die():
    is_alive = false
    
    # 奖励玩家
    GameStats.add_gold(gold_drop)
    GameStats.add_exp(experience_drop)
    
    # 播放死亡动画
    $AnimationPlayer.play("death")
    await $AnimationPlayer.animation_finished
    
    queue_free()
```

---

## 5. 配置系统

### 5.1 敌人类型枚举

```gdscript
enum EnemyType {
    LIGHT_ARMOR = 0,    # 轻甲怪 - 低血量快速度
    HEAVY_ARMOR = 1,    # 重甲怪 - 高血量慢速度物抗高
    MAGIC_SHIELD = 2    # 魔抗怪 - 魔抗高
}
```

### 5.2 典型配置示例

```gdscript
# 轻甲怪配置
{
    "enemy_id": "light_armor",
    "enemy_name": "轻甲兵",
    "max_health": 50.0,
    "speed": 80.0,
    "gold_drop": 5,
    "experience_drop": 2,
    "texture_path": "res://images/enemies/marble_0_0.png",
    "armor_type": "light"
}

# 重甲怪配置
{
    "enemy_id": "heavy_armor",
    "enemy_name": "重甲兵",
    "max_health": 150.0,
    "speed": 30.0,
    "gold_drop": 20,
    "experience_drop": 50,
    "texture_path": "res://images/enemies/marble_1_0.png",
    "armor_type": "heavy"
}
```

---

## 6. 踩坑记录

### 6.1 资源文件注释问题

**问题**：在 `.tres` 资源文件中，字段值后添加注释会导致该字段无法正确加载。

**错误示例**：
```tres
# ❌ 错误：注释导致字段加载失败
gold_drop = 20  # 高价值目标
experience_drop = 50  # 高经验奖励
texture_path = "res://images/enemies/marble_0_0.png"
```

**正确示例**：
```tres
# ✅ 正确：移除所有行内注释
gold_drop = 20
experience_drop = 50
texture_path = "res://images/enemies/marble_0_0.png"
```

**影响**：
- `texture_path` 变为空字符串 → 怪物纹理不显示
- `experience_drop` 变为默认值 5 → 经验值异常低

**解决方案**：
1. 移除所有 `.tres` 文件中的行内注释
2. 重新保存资源文件（在 Godot 编辑器中）
3. 重启 Godot 编辑器清除缓存

**详细说明**：[Godot_4x_Resource_File_Comment_Issue.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md)

---

## 🔗 相关文档

### 实体页面

- [防御塔设计](./tower.md) - 防御塔实体详细设计
- [投射物设计](./projectile.md) - 投射物实体设计

### 概念页面

- [攻击系统设计](../concepts/attack-system.md) - 攻击系统完整架构

### 指南页面

- [塔防游戏架构设计](../guides/tower-defense-architecture.md) - 塔防游戏完整架构
- [常见踩坑避雷](../guides/common-pitfalls.md) - 23 个常见陷阱及解决方案

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator
