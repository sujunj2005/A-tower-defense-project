# 物理系统核心概念

> **来源**: [06A_Physics_Introduction.md](../../base/physics-system/06A_Physics_Introduction.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

Godot 物理系统提供四种碰撞对象，都继承自 `CollisionObject2D`，用于实现碰撞检测、物理模拟和区域影响等功能。

---

## 🎯 碰撞对象类型

### 四种碰撞对象对比

| 类型 | 说明 | 用途 | 控制方式 |
|------|------|------|----------|
| **Area2D** | 检测和影响 | 检测重叠、修改物理属性 | 信号触发 |
| **StaticBody2D** | 静态物体 | 墙壁、平台、传送带 | 静态/常量速度 |
| **RigidBody2D** | 刚体 | 受物理引擎控制的物体 | 施加力/冲量 |
| **CharacterBody2D** | 角色物体 | 玩家控制的角色 | 代码控制移动 |

### 选择建议

| 场景 | 推荐类型 |
|------|----------|
| 玩家/NPC 角色 | CharacterBody2D |
| 墙壁/平台 | StaticBody2D |
| 可推动的箱子 | RigidBody2D |
| 拾取物品/检测区域 | Area2D |
| 子弹/投射物 | Area2D 或 RigidBody2D |

---

## 🔷 碰撞形状

### 添加碰撞形状

每个物理物体需要一个或多个 `Shape2D` 子节点：

- **CollisionShape2D**: 基本形状（矩形、圆形、胶囊形等）
- **CollisionPolygon2D**: 多边形形状

> ⚠️ **踩坑点**: 碰撞形状的 Scale 必须保持 (1, 1)。调整大小时使用形状的属性，不要使用 Node2D 的缩放。

### 常见形状类型

| 形状 | 说明 | 适用场景 |
|------|------|----------|
| `RectangleShape2D` | 矩形 | 平台、箱子 |
| `CircleShape2D` | 圆形 | 球、硬币 |
| `CapsuleShape2D` | 胶囊形 | 角色身体 |
| `SegmentShape2D` | 线段 | 边界、斜坡 |
| `SeparationRayShape2D` | 分离射线 | 角色地面检测 |
| `WorldBoundaryShape2D` | 无限平面 | 世界边界 |

---

## 🎭 碰撞层与掩码

### 核心概念

- **collision_layer**: 物体所在的层（"我在哪里"）
- **collision_mask**: 物体检测的层（"我检测谁"）

每个物体有 32 个物理层可用，使用位运算进行配置。

### 示例配置

| 节点 | Layer | Mask | 说明 |
|------|-------|------|------|
| Player | player (0b0001) | walls, enemies, coins (0b1101) | 玩家在第 1 层，检测墙、敌人、金币 |
| Enemy | enemies (0b0010) | walls, player (0b1001) | 敌人在第 2 层，检测墙和玩家 |
| Coin | coins (0b0100) | player (0b0001) | 金币在第 3 层，只检测玩家 |
| Wall | walls (0b1000) | （无需检测） | 墙壁在第 4 层，不检测其他 |

### 代码设置方式

```gdscript
# 方式 1：直接设置位掩码
collision_layer = 0b0001  # 第 1 层
collision_mask = 0b1101   # 检测 1, 3, 4 层

# 方式 2：使用便捷方法
set_collision_layer_value(1, true)   # 设置第 1 层
set_collision_mask_value(3, true)    # 检测第 3 层

# 方式 3：导出为位标志（编辑器可视化配置）
@export_flags_2d_physics var collision_layers: int
```

---

## ⚙️ 物理处理回调

### _physics_process

物理引擎以固定速率运行（默认 60Hz），使用 `_physics_process` 回调：

```gdscript
func _physics_process(delta):
    # 物理相关代码放在这里
    velocity.y += gravity * delta
    move_and_slide()
```

> ⚠️ **踩坑点**: 物理代码必须放在 `_physics_process` 中，而不是 `_process`。否则会导致物理行为不稳定。

### delta 处理

```gdscript
# 正确：速度计算需要乘以 delta
velocity.y += gravity * delta

# move_and_slide() 内部已处理 delta，不需要再乘
move_and_slide()
```

---

## 🔗 相关概念

### 详细文档

- [CharacterBody2D 概念](characterbody2d-concept.md) - 角色物体详解
- [刚体概念](rigidbody2d-concept.md) - 刚体物理详解
- [Area2D 概念](area2d-concept.md) - 区域检测详解

### 实战指南

- [射线投射指南](../guides/raycasting-guide.md) - 射线检测实战
- [2D 移动指南](../guides/2d-movement-guide.md) - CharacterBody2D 移动实战
- [碰撞检测方案对比](../comparisons/collision-detection-comparison.md) - 碰撞形状选择指南
- [投射物实体设计](../entities/projectile.md) - 投射物物理实现
- [玩家实体设计](../entities/player.md) - 玩家角色控制

### Base 层来源

- [06A_Physics_Introduction.md](../../base/physics-system/06A_Physics_Introduction.md) - 完整原始文档

---

## 📊 核心知识点总结

| 知识点 | 重要性 | 说明 |
|--------|--------|------|
| 四种碰撞对象 | 🔴 必读 | Area2D/StaticBody2D/RigidBody2D/CharacterBody2D |
| 碰撞层与掩码 | 🔴 必读 | 32 层位运算配置 |
| 物理回调 | 🔴 必读 | _physics_process vs _process |
| 碰撞形状 | 🔴 必读 | Shape2D 子节点、Scale 限制 |
| 代码设置 | 🟡 推荐 | set_collision_layer_value() 等方法 |

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.6
