# 近战攻击 vs 远程攻击对比分析

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [14_Tower_Defense_Case_Study.md](../../base/practical-experiences/case-studies/14_Tower_Defense_Case_Study.md), [attack-system.md](../concepts/attack-system.md)

---

## 📖 对比概述

本文档详细对比近战攻击和远程攻击两种攻击方式的实现差异、性能特点、适用场景。

---

## 📋 目录

1. [核心差异总览](#1-核心差异总览)
2. [实现方式对比](#2-实现方式对比)
3. [性能特点对比](#3-性能特点对比)
4. [适用场景分析](#4-适用场景分析)
5. [代码实现示例](#5-代码实现示例)

---

## 1. 核心差异总览

| 对比维度 | 近战攻击 (Melee) | 远程攻击 (Range) |
|---------|-----------------|-----------------|
| **攻击距离** | 0-50 像素（贴身） | 50-500 像素（可配置） |
| **攻击频率** | 高（0.5-1.0 秒/次） | 中（1.0-2.0 秒/次） |
| **单次伤害** | 低（5-15） | 高（20-50） |
| **实现复杂度** | 简单（碰撞检测） | 中等（投射物管理） |
| **性能开销** | 低 | 中（投射物对象池） |
| **命中判定** | 瞬间命中 | 投射物飞行时间 |
| **视觉效果** | 简单（动画） | 复杂（投射物 + 命中特效） |

---

## 2. 实现方式对比

### 2.1 近战攻击实现

```gdscript
class_name MeleeAttacker
extends BaseAttacker

@export var melee_range: float = 50.0
@export var attack_animation: AnimationPlayer

func attack(target: Node2D):
    if not is_in_range(target):
        return false
    
    # 播放攻击动画
    if attack_animation:
        attack_animation.play("attack")
    
    # 立即造成伤害
    target.take_damage(damage, damage_type)
    return true

func is_in_range(target: Node2D) -> bool:
    var dist = get_parent().global_position.distance_to(target.global_position)
    return dist <= melee_range
```

**特点**：
- ✅ 实现简单，代码量少
- ✅ 性能开销低，无额外对象
- ✅ 命中判定即时，无延迟
- ❌ 攻击距离短，需要贴近敌人
- ❌ 视觉效果单一

---

### 2.2 远程攻击实现

```gdscript
class_name RangeAttacker
extends BaseAttacker

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0
@export var range: int = 200

func attack(target: Node2D):
    if not is_in_range(target):
        return false
    
    if projectile_scene:
        # 实例化投射物
        var proj = projectile_scene.instantiate()
        get_parent().add_child(proj)
        
        # 初始化投射物
        proj.initialize(
            get_parent().global_position,
            target,
            projectile_speed,
            damage,
            damage_type
        )
    return true

func is_in_range(target: Node2D) -> bool:
    var dist = get_parent().global_position.distance_to(target.global_position)
    return dist <= range
```

**特点**：
- ✅ 攻击距离远，安全性高
- ✅ 视觉效果丰富（投射物飞行）
- ✅ 可实现弹道、追踪等高级效果
- ❌ 实现复杂度高，需要管理投射物
- ❌ 性能开销较大（对象池优化）
- ❌ 命中有延迟（投射物飞行时间）

---

## 3. 性能特点对比

### 3.1 CPU 开销

| 操作 | 近战攻击 | 远程攻击 |
|------|---------|---------|
| 距离检测 | ⚡ 低（每帧） | ⚡ 低（每帧） |
| 碰撞检测 | ⚡ 低（Area2D） | ⚡⚡ 中（投射物碰撞） |
| 对象创建 | ✅ 无 | 🐢 高（需对象池） |
| 对象销毁 | ✅ 无 | ⚡ 中（queue_free） |

### 3.2 内存占用

| 类型 | 近战攻击 | 远程攻击 |
|------|---------|---------|
| 脚本内存 | ~1KB | ~2KB |
| 运行时对象 | 仅攻击者 | 攻击者 + 投射物 × N |
| 纹理内存 | ~100KB（动画） | ~500KB（投射物图集） |

### 3.3 优化建议

#### 近战攻击优化

```gdscript
# ✅ 使用 Area2D 进行碰撞检测
@onready var attack_area: Area2D = $AttackArea

func _on_attack_area_body_entered(body):
    if body is Enemy:
        body.take_damage(damage, damage_type)
```

#### 远程攻击优化

```gdscript
# ✅ 使用对象池管理投射物
var projectile_pool: Array[Node] = []

func get_projectile():
    for proj in projectile_pool:
        if not proj.visible:
            return proj
    return create_new_projectile()

func return_projectile(proj: Node):
    proj.visible = false
    projectile_pool.append(proj)
```

---

## 4. 适用场景分析

### 4.1 近战攻击适用场景

| 场景 | 原因 | 示例 |
|------|------|------|
| **低成本塔防** | 性能开销低，适合移动端 | 休闲塔防小游戏 |
| **高攻速塔** | 攻击频率高，单次伤害低 | 剑塔、刺塔 |
| **阻挡型塔** | 需要敌人贴近才能攻击 | 兵营、障碍物 |
| **AOE 近战** | 周围一圈伤害 | 震荡塔、闪电链 |

### 4.2 远程攻击适用场景

| 场景 | 原因 | 示例 |
|------|------|------|
| **标准塔防** | 经典塔防体验 | 弓箭塔、炮塔 |
| **高伤害塔** | 单次伤害高，攻击频率低 | 狙击塔、导弹塔 |
| **特殊弹道** | 需要抛物线、追踪等效果 | 抛石机、制导导弹 |
| **视觉优先** | 重视视觉效果 | 魔法塔、激光塔 |

---

## 5. 代码实现示例

### 5.1 完整近战攻击示例

```gdscript
class_name MeleeTower
extends Tower

@export var melee_range: float = 50.0
@export var attack_speed: float = 0.8
@export var damage: int = 15

@onready var attack_area: Area2D = $AttackArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var attack_timer: float = 0.0
var current_target: Enemy = null

func _process(delta):
    if not current_target or not is_instance_valid(current_target):
        current_target = find_target()
        return
    
    if not is_in_range(current_target):
        current_target = null
        return
    
    attack_timer += delta
    if attack_timer >= attack_speed:
        attack_timer = 0.0
        perform_attack()

func perform_attack():
    # 播放攻击动画
    if animation_player:
        animation_player.play("attack")
    
    # 对范围内所有敌人造成伤害
    for body in attack_area.get_overlapping_bodies():
        if body is Enemy:
            body.take_damage(damage, DamageType.NORMAL)

func is_in_range(target: Enemy) -> bool:
    var dist = global_position.distance_to(target.global_position)
    return dist <= melee_range
```

### 5.2 完整远程攻击示例

```gdscript
class_name RangeTower
extends Tower

@export var range: int = 200
@export var attack_speed: float = 1.5
@export var damage: int = 30
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var attack_timer: float = 0.0
var current_target: Enemy = null
var projectile_pool: Array[Node] = []

func _process(delta):
    if not current_target or not is_instance_valid(current_target):
        current_target = find_target()
        return
    
    if not is_in_range(current_target):
        current_target = null
        return
    
    attack_timer += delta
    if attack_timer >= attack_speed:
        attack_timer = 0.0
        perform_attack()

func perform_attack():
    # 播放攻击动画
    if animation_player:
        animation_player.play("shoot")
    
    # 从对象池获取投射物
    var proj = get_projectile()
    proj.initialize(
        global_position,
        current_target,
        projectile_speed,
        damage
    )

func get_projectile() -> Node:
    for proj in projectile_pool:
        if not proj.visible:
            proj.visible = true
            return proj
    
    # 对象池中没有可用投射物，创建新的
    if projectile_scene:
        var new_proj = projectile_scene.instantiate()
        add_child(new_proj)
        projectile_pool.append(new_proj)
        return new_proj
    
    return null

func is_in_range(target: Enemy) -> bool:
    var dist = global_position.distance_to(target.global_position)
    return dist <= range
```

---

## 🔗 相关文档

### 概念页面

- [攻击系统设计](../concepts/attack-system.md) - 攻击系统完整架构
- [GDScript 代码规范](../concepts/gdscript-standards.md) - 代码规范标准

### 实体页面

- [防御塔设计](../entities/tower.md) - 防御塔实体详细设计
- [敌人实体设计](../entities/enemy.md) - 敌人实体详细设计

### 指南页面

- [塔防游戏架构设计](../guides/tower-defense-architecture.md) - 塔防游戏完整架构
- [性能优化实战指南](../guides/performance-optimization-guide.md) - CPU/GPU 优化实战

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator
