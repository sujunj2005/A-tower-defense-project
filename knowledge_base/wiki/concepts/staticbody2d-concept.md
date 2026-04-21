# StaticBody2D/StaticBody3D 概念

> **适用版本**: Godot 4.x  
> **知识领域**: 物理系统  
> **前置知识**: [物理系统介绍](./physics-intro.md)、[碰撞检测方案对比](../comparisons/collision-detection-comparison.md)

---

## 📋 概述

**StaticBody2D/StaticBody3D** 是用于创建**静态碰撞体**的物理节点，适用于不会移动的障碍物、平台、墙壁等。

### 核心特点

- ✅ **零性能开销**: 不会参与物理模拟计算
- ✅ **提供碰撞**: 其他物理体会与其碰撞
- ✅ **静态最优**: 适合地形、建筑、固定平台
- ❌ **不能移动**: 移动会破坏物理缓存（应使用 Kinematic 或 Animated）

---

## 🎯 适用场景

### StaticBody2D/3D 典型用途

| 场景 | 说明 | 示例 |
|------|------|------|
| **地形碰撞** | 提供地面、墙壁碰撞 | 平台、悬崖、墙壁 |
| **固定障碍物** | 不可移动的障碍 | 柱子、箱子（不移动） |
| **触发区域边界** | 定义 Area 的边界 | 房间边界、关卡边界 |
| **UI 碰撞** | 2D UI 中的碰撞检测 | 按钮边界、拖拽区域 |

### 与其他物理体对比

| 物理体类型 | 移动方式 | 物理模拟 | 性能 | 适用场景 |
|-----------|---------|---------|------|---------|
| **StaticBody** | ❌ 不能移动 | ❌ 无 | ⭐⭐⭐⭐⭐ | 地形、墙壁 |
| **CharacterBody** | ✅ 代码控制 | ❌ 无 | ⭐⭐⭐⭐ | 玩家、NPC |
| **RigidBody** | ✅ 物理驱动 | ✅ 有 | ⭐⭐⭐ | 抛射物、可移动物体 |
| **Area** | ✅ 代码控制 | ❌ 无（仅检测） | ⭐⭐⭐⭐ | 触发器、拾取物 |

---

## 🛠️ 基本使用

### 2D StaticBody2D

```gdscript
# 场景结构
StaticBody2D
├── Sprite2D (外观)
└── CollisionShape2D (碰撞形状)

# 代码示例（可选 - StaticBody 通常不需要脚本）
extends StaticBody2D

# 如果需要检测碰撞
func _on_body_entered(body: Node2D):
    if body.is_in_group("player"):
        print("玩家进入了静态体区域")
```

### 3D StaticBody3D

```gdscript
# 场景结构
StaticBody3D
├── MeshInstance3D (外观)
└── CollisionShape3D (碰撞形状)

# 碰撞形状选择
# - BoxShape3D: 立方体（最常用）
# - SphereShape3D: 球体
# - CapsuleShape3D: 胶囊体
# - ConvexPolygonShape3D: 凸多边形
# - ConcavePolygonShape3D: 凹多边形（仅静态）
```

---

## ⚠️ 重要注意事项

### 1. StaticBody 不能移动

**错误做法**:
```gdscript
# ❌ 不要在 _process 或 _physics_process 中移动 StaticBody
func _physics_process(delta):
    position += Vector2(1, 0) * delta  # ❌ 会破坏物理缓存！
```

**正确做法**:
```gdscript
# ✅ 方案 1: 使用 CharacterBody2D 代替
extends CharacterBody2D

func _physics_process(delta):
    velocity = Vector2(1, 0) * speed
    move_and_slide()

# ✅ 方案 2: 使用 AnimationPlayer 移动（会更新物理缓存）
# 在动画中设置位置关键帧

# ✅ 方案 3: 使用 Tween（会更新物理缓存）
var tween = create_tween()
tween.tween_property($StaticBody2D, "position", 
    target_position, duration)
```

### 2. 碰撞形状选择

**性能优先级**（从高到低）:
```
CircleShape2D/SphereShape3D  >  BoxShape2D/BoxShape3D  >  
CapsuleShape2D/CapsuleShape3D  >  ConvexPolygonShape  >  
ConcavePolygonShape (仅静态！)
```

**StaticBody 专用优化**:
- ✅ 可以使用 **ConcavePolygonShape**（凹多边形）
- ✅ 适合复杂静态地形
- ❌ 不能用于动态物体（会穿透！）

### 3. 移动平台实现

**错误**: 直接移动 StaticBody
```gdscript
# ❌ 不要这样做
position.y = sin(Time.get_ticks_msec() / 1000.0) * 50.0
```

**正确**: 使用 CharacterBody 或 AnimatedStaticBody
```gdscript
# ✅ 方案 1: CharacterBody2D
extends CharacterBody2D

func _physics_process(delta):
    velocity.y = sin(Time.get_ticks_msec() / 1000.0) * 100.0
    move_and_slide()

# ✅ 方案 2: AnimationPlayer
# 在动画中设置位置关键帧，Godot 会自动处理物理

# ✅ 方案 3: 使用专门的移动平台节点
# Godot 4.x 提供了更好的移动平台解决方案
```

---

## 🔧 高级用法

### 1. 动态启用/禁用碰撞

```gdscript
# 暂时禁用碰撞（如门打开）
$CollisionShape2D.disabled = true

# 重新启用
$CollisionShape2D.disabled = false

# 性能提示：禁用碰撞比删除节点更高效
```

### 2. 多层碰撞配置

```gdscript
# 设置碰撞层和掩码
collision_layer = 0b0001  # 第 1 层（地形）
collision_mask = 0b0000   # 不检测任何层（静态体不需要检测）

# 如果需要检测特定层（如玩家）
collision_mask = 0b0010  # 检测第 2 层（玩家）
```

### 3. 复杂静态地形

```gdscript
# 使用多个子碰撞体
StaticBody2D
├── Sprite2D
├── CollisionShape2D_Floor (地面)
├── CollisionShape2D_Wall_Left (左墙)
├── CollisionShape2D_Wall_Right (右墙)
└── CollisionShape2D_Platform (平台)

# 优点：比单个复杂碰撞体性能更好
# 缺点：配置稍复杂
```

---

## 📊 性能优化

### StaticBody 优化建议

| 优化方向 | 具体措施 | 性能提升 |
|---------|---------|---------|
| **简单形状** | 优先使用 Box/Circle | ⭐⭐⭐⭐⭐ |
| **复合碰撞体** | 多个简单形状组合 | ⭐⭐⭐⭐ |
| **禁用监控** | 不需要检测时设置 `monitorable = false` | ⭐⭐⭐ |
| **减少数量** | 合并相邻的 StaticBody | ⭐⭐⭐ |
| **使用 TileMap** | 大场景使用 TileMap 代替多个 StaticBody | ⭐⭐⭐⭐⭐ |

---

## 🔗 相关资源

### Base 层来源
- [物理系统介绍](../../base/physics-system/06A_Physics_Introduction.md)
- [碰撞形状](../../base/physics-system/06G_RayCasting.md)

### Wiki 层相关
- [物理系统介绍](./physics-intro.md)
- [CharacterBody2D 概念](./characterbody2d-concept.md)
- [RigidBody2D 概念](./rigidbody2d-concept.md)
- [Area2D 概念](./area2d-concept.md)
- [碰撞检测方案对比](../comparisons/collision-detection-comparison.md)
- [玩家实体设计](../entities/player.md)
- [敌人实体设计](../entities/enemy.md)

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
