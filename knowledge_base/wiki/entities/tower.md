# 防御塔实体设计

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [14_Tower_Defense_Case_Study.md](../../base/practical-experiences/case-studies/14_Tower_Defense_Case_Study.md)

---

## 📖 实体概述

防御塔是塔防游戏的核心实体，负责检测敌人、攻击敌人、升级强化等功能。

---

## 📋 目录

1. [继承体系](#1-继承体系)
2. [核心组件](#2-核心组件)
3. [数据结构](#3-数据结构)
4. [行为逻辑](#4-行为逻辑)
5. [配置系统](#5-配置系统)

---

## 1. 继承体系

```
BaseCharacter (Node2D) ← 角色基类
    └── Tower (防御塔)
        ├── BaseAttacker (Node) ← 攻击组件
        │   ├── MeleeAttacker (近战攻击)
        │   └── RangeAttacker (远程攻击)
        └── BaseUnderAttacked (Node) ← 受击组件
```

---

## 2. 核心组件

### 2.1 塔基类（Tower）

```gdscript
class_name Tower
extends BaseCharacter

@export_group("TowerInfo")
@export var tower_id: int
@export var tower_type: String
@export var can_upgrade: bool = true

@export_group("BuildInfo")
@export var build_cost: int = 100
@export var sell_value: int = 50

# 组件引用
@export_node_path var attack_node_path
@export_node_path var attacked_node_path

var attack_component: BaseAttacker
var attacked_component: BaseUnderAttacked
```

### 2.2 攻击组件（BaseAttacker）

```gdscript
class_name BaseAttacker
extends Node

@export_group("Attack")
@export var is_range: bool = true
@export var range: int = 200
@export var attack_speed: float = 1.0

@export_subgroup("AttributeFirepower")
@export var normal: int = 10
@export var fire: int = 0
@export var water: int = 0
@export var wind: int = 0
@export var light: int = 0
@export var dark: int = 0

var current_target: Node2D = null
var attack_timer: float = 0.0
```

### 2.3 远程攻击实现

```gdscript
class_name RangeAttacker
extends BaseAttacker

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0

func attack(target: Node2D):
    if not is_instance_valid(target):
        return
    
    if projectile_scene:
        var proj = projectile_scene.instantiate()
        get_parent().add_child(proj)
        proj.initialize(get_parent().global_position, target)
```

---

## 3. 数据结构

### 3.1 塔配置数据

```gdscript
# TowerConfig 资源类
class_name TowerConfig
extends Resource

@export var tower_id: String
@export var tower_name: String
@export var description: String
@export var cost: int
@export var damage: int
@export var range: int
@export var attack_speed: float
@export var projectile: ProjectileConfig
@export var upgrade_path: Array[String]
```

### 3.2 塔实例数据

```gdscript
# 运行时塔数据
var tower_data := {
    "tower_id": 0,
    "tower_type": "archer",
    "tower_durability": 100,
    "level": 1,
    "exp": 0,
    "build_time": 0,
    "last_attack_time": 0.0
}
```

---

## 4. 行为逻辑

### 4.1 索敌逻辑

```gdscript
func find_target() -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemies")
    var closest_enemy: Node2D = null
    var min_distance = INF
    
    for enemy in enemies:
        if not enemy.is_alive:
            continue
        
        var dist = global_position.distance_to(enemy.global_position)
        if dist <= range and dist < min_distance:
            min_distance = dist
            closest_enemy = enemy
    
    return closest_enemy
```

### 4.2 攻击循环

```gdscript
func _process(delta):
    if not current_target or not is_instance_valid(current_target):
        current_target = find_target()
        return
    
    attack_timer += delta
    if attack_timer >= attack_speed:
        attack_timer = 0.0
        attack(current_target)
```

### 4.3 升级逻辑

```gdscript
func upgrade() -> bool:
    if not can_upgrade or level >= max_level:
        return false
    
    level += 1
    damage = int(damage * 1.2)
    range = int(range * 1.1)
    attack_speed = attack_speed * 0.9
    
    update_visual()
    return true
```

---

## 5. 配置系统

### 5.1 塔类型枚举

```gdscript
enum TowerType {
    ARCHER = 0,     # 弓箭塔 - 单体物理伤害
    MAGIC = 1,      # 魔法塔 - AOE 魔法伤害
    CANNON = 2,     # 炮塔 - 高伤害慢攻速
    SUPPORT = 3     # 辅助塔 -  buff/debuff
}
```

### 5.2 攻击类型

```gdscript
enum AttackType {
    PHYSICAL = 0,   # 物理伤害
    FIRE = 1,       # 火属性伤害
    WATER = 2,      # 水属性伤害
    WIND = 3,       # 风属性伤害
    LIGHT = 4,      # 光属性伤害
    DARK = 5        # 暗属性伤害
}
```

### 5.3 建造类型匹配

```gdscript
# 塔坑支持的建造类型
var support_type: Array[String] = ["curb", "foundation"]

# 塔的基础类型
var foundation_type: String = "curb"  # 或 "foundation"

# 类型匹配检查
func can_build_on(pit_type: String) -> bool:
    return pit_type in support_type
```

---

## 🔗 相关文档

### 实体页面

- [敌人实体设计](./enemy.md) - 敌人实体详细设计
- [投射物设计](./projectile.md) - 投射物实体设计

### 概念页面

- [攻击系统设计](../concepts/attack-system.md) - 攻击系统完整架构
- [GDScript 代码规范](../concepts/gdscript-standards.md) - 代码规范标准

### 指南页面

- [塔防游戏架构设计](../guides/tower-defense-architecture.md) - 塔防游戏完整架构

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator
