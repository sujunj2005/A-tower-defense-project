# 场景组织最佳实践

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 16A_Scene_Organization.md](../../base/best-practices/16A_Scene_Organization.md)  
> **重要性**: 🔴 必读 - 大型项目管理规范

---

## 📋 概述

良好的场景组织结构是项目可维护性的关键。本指南介绍 Godot 项目的场景组织最佳实践。

---

## 🎯 核心原则

### 1. 单一职责原则

每个场景只负责一个功能：
- **Player**: 只处理玩家逻辑
- **Enemy**: 只处理敌人逻辑
- **UI**: 只处理界面逻辑

### 2. 组合优于继承

使用节点组合而不是深度继承：
```
❌ 错误：深度继承
Node → Entity → Character → Player → Hero

✅ 正确：组件组合
Player (CharacterBody2D)
├─ Health (Node)
├─ Inventory (Node)
├─ Dialogue (Node)
└─ QuestTracker (Node)
```

### 3. 场景复用

创建可复用的预制体：
- **UI 组件**: 按钮、面板、对话框
- **游戏对象**: 宝箱、门、开关
- **特效**: 粒子、动画

---

## 🔧 实战技巧

### 1. 信号解耦

```gdscript
# 使用信号减少直接依赖
# 玩家死亡时通知游戏管理器
signal player_died

func take_damage(amount):
    health -= amount
    if health <= 0:
        emit_signal("player_died")

# 游戏管理器监听信号
$Player.player_died.connect(_on_player_died)
```

### 2. 自动加载管理

```gdscript
# GameManager.gd (Autoload)
extends Node

var current_scene: Node

func _ready():
    var root = get_tree().root
    current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(scene_path: String):
    current_scene.queue_free()
    current_scene = load(scene_path).instantiate()
    get_tree().root.add_child(current_scene)
```

---

## 🔗 相关资源

### Base 层
- [16A_Scene_Organization.md](../../base/best-practices/16A_Scene_Organization.md) - 场景组织详解
- [16B_Data_Preferences.md](../../base/best-practices/16B_Data_Preferences.md) - 数据结构偏好
- [16C_Logic_Preferences.md](../../base/best-practices/16C_Logic_Preferences.md) - 逻辑组织偏好

### Wiki 层
- [数据结构偏好指南](../guides/data-preferences-guide.md) - 数据管理最佳实践
- [逻辑组织偏好指南](../guides/logic-preferences-guide.md) - 代码组织最佳实践

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
