# 逻辑组织偏好指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 16C_Logic_Preferences.md](../../base/best-practices/16C_Logic_Preferences.md)  
> **重要性**: 🟡 推荐 - 代码组织最佳实践

---

## 📋 概述

良好的代码组织结构可以提高可读性、可维护性和复用性。本指南介绍 Godot 项目的逻辑组织最佳实践。

---

## 🎯 核心原则

### 1. 单一职责

每个脚本只负责一个功能领域：
```gdscript
# ✅ 正确：PlayerHealth.gd 只处理生命值
extends Node

var health: int = 100

func take_damage(amount: int):
    health = max(0, health - amount)

func heal(amount: int):
    health += amount
```

### 2. 信号驱动

使用信号解耦模块：
```gdscript
# 玩家脚本
signal health_changed(new_value)
signal died

func take_damage(amount: int):
    health.take_damage(amount)
    health_changed.emit(health.health)
    
    if health.health == 0:
        died.emit()
```

### 3. 组件化

将功能拆分为独立组件：
```
Player
├─ Health (Node) - 生命值管理
├─ Movement (Node) - 移动控制
├─ Combat (Node) - 战斗系统
└─ Inventory (Node) - 背包系统
```

---

## 🔧 实战技巧

### 1. 状态模式

```gdscript
class_name PlayerState
extends Node

func enter():
    pass

func exit():
    pass

func update(delta: float):
    pass

class IdleState extends PlayerState:
    func enter():
        print("进入待机状态")
    
    func update(delta: float):
        if Input.is_action_pressed("move"):
            transition.emit("walk")

class WalkState extends PlayerState:
    func update(delta: float):
        if not Input.is_action_pressed("move"):
            transition.emit("idle")
```

### 2. 依赖注入

```gdscript
# ❌ 错误：硬编码依赖
func _ready():
    var audio = get_node("/root/AudioManager")

# ✅ 正确：依赖注入
@export var audio_manager: AudioManager

func _ready():
    if audio_manager:
        audio_manager.play_sound("jump")
```

---

## 🔗 相关资源

### Base 层
- [16C_Logic_Preferences.md](../../base/best-practices/16C_Logic_Preferences.md) - 逻辑组织详解

### Wiki 层
- [场景组织指南](../guides/scene-organization-guide.md) - 场景组织最佳实践

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
