# 射线投射实战指南

> **来源**: [06G_RayCasting.md](../../base/physics-system/06G_RayCasting.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

射线检测（Ray Casting）是游戏开发中最常见的任务之一，用于发射射线并检查击中的物体。适用于 AI 视野、武器瞄准、环境检测等场景。

---

## 🎯 两种实现方式

### 1. RayCast2D/RayCast3D 节点

**优点**: 简单，每帧自动返回结果  
**缺点**: 灵活性较低

### 2. 直接查询物理空间

**优点**: 更灵活，可自定义查询参数  
**缺点**: 代码稍复杂

---

## 🚀 方式一：RayCast2D 节点

### 基本用法

```gdscript
extends RayCast2D

func _process(delta):
    if is_colliding():
        print("击中了：", get_collider())
        print("位置：", get_collision_point())
    else:
        print("未击中")
```

### 配置属性

```gdscript
func _ready():
    target_position = Vector2(100, 0)  # 相对于父节点
    enabled = true
    exclude_parent = true  # 排除父节点
    collision_mask = 1     # 碰撞层掩码
```

### 实战示例：敌人视野检测

```gdscript
extends RayCast2D

@export var detection_distance: float = 100.0
@export var detection_angle: float = 45.0

func _process(delta):
    # 旋转射线检测扇形区域
    var angles = [-detection_angle, 0, detection_angle]
    
    for angle in angles:
        rotation_degrees = angle
        force_raycast_update()
        
        if is_colliding():
            var target = get_collider()
            if target.is_in_group("player"):
                print("发现玩家！")
                return true
    
    return false
```

---

## 🔬 方式二：物理空间查询

### 访问物理空间

```gdscript
func _physics_process(delta):
    # 方式 1：标准方式
    var space_rid = get_world_2d().space
    var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
    
    # 方式 2：更直接（推荐）
    var space_state = get_world_2d().direct_space_state
```

> ⚠️ **踩坑点**: 访问空间的唯一安全时间是在 `_physics_process()` 回调期间。在此函数之外访问可能会由于空间被锁定而导致错误。

### 基础射线查询

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    # 创建射线查询参数
    var query = PhysicsRayQueryParameters2D.create(
        Vector2(0, 0),      # 起点（全局坐标）
        Vector2(50, 100)    # 终点（全局坐标）
    )
    
    # 执行射线检测
    var result = space_state.intersect_ray(query)
    
    # 检查结果
    if result:
        print("击中位置：", result.position)
        print("碰撞法线：", result.normal)
        print("碰撞物体：", result.collider)
```

### 结果字典内容

| 键 | 说明 | 类型 |
|----|------|------|
| `position` | 碰撞点（世界空间） | Vector2 |
| `normal` | 碰撞法线（世界空间） | Vector2 |
| `collider` | 碰撞的物体 | Node2D |
| `collider_id` | 碰撞物体的 ObjectID | int |
| `rid` | 碰撞形状的 RID | RID |
| `shape` | 碰撞形状的索引 | int |
| `metadata` | 形状的元数据 | Variant |

---

## ⚙️ 高级查询

### 排除碰撞体

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    var query = PhysicsRayQueryParameters2D.create(start, end)
    query.exclude = [self]  # 排除自身
    var result = space_state.intersect_ray(query)
```

### 碰撞层掩码

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    var query = PhysicsRayQueryParameters2D.create(start, end)
    query.collision_mask = 1  # 只检测第 1 层
    var result = space_state.intersect_ray(query)
```

### 3D 射线查询

```gdscript
func _physics_process(delta):
    var space_state = get_world_3d().direct_space_state
    
    var query = PhysicsRayQueryParameters3D.create(
        Vector3(0, 0, 0),
        Vector3(0, 5, 10)
    )
    
    var result = space_state.intersect_ray(query)
```

---

## 🔷 形状查询

### 相交点查询

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    var query = PhysicsPointQueryParameters2D.create()
    query.position = Vector2(50, 50)
    query.collision_mask = 1
    
    # 获取该点上的所有碰撞体（最多 32 个）
    var results = space_state.intersect_point(query, 32)
    
    for result in results:
        print("碰撞体：", result.collider)
```

### 形状相交查询

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    # 创建圆形形状
    var shape = CircleShape2D.new()
    shape.radius = 32
    
    # 创建形状查询
    var query = PhysicsShapeQueryParameters2D.create()
    query.shape = shape
    query.transform = Transform2D.IDENTITY.translated(Vector2(50, 50))
    query.collision_mask = 1
    
    # 执行查询
    var results = space_state.intersect_shape(query, 32)
    
    for result in results:
        print("碰撞体：", result.collider)
```

### 获取最近碰撞体

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    var query = PhysicsRayQueryParameters2D.create(start, end)
    query.collide_with_areas = false  # 不检测 Area2D
    query.collide_with_bodies = true  # 检测物理体
    
    var result = space_state.intersect_ray(query)
```

---

## 💡 实战示例

### 1. AI 视野检测

```gdscript
extends CharacterBody2D

@export var detection_distance: float = 200.0
@export var detection_angle: float = 60.0

var player = null

func _physics_process(delta):
    if not player:
        player = get_node_or_null("../../Player")
        return
    
    # 计算到玩家的方向
    var to_player = player.global_position - global_position
    var distance = to_player.length()
    
    # 检查距离
    if distance > detection_distance:
        return
    
    # 检查角度
    var angle = Vector2.RIGHT.angle_to(to_player)
    if abs(angle) > deg_to_rad(detection_angle / 2):
        return
    
    # 射线检测（检查是否有障碍物）
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
        global_position,
        player.global_position
    )
    query.exclude = [self]
    
    var result = space_state.intersect_ray(query)
    
    if not result or result.collider == player:
        print("发现玩家！")
        start_chasing()
```

### 2. 武器瞄准

```gdscript
extends Node2D

@export var damage: int = 10
@export var range: float = 300.0

func shoot(from: Vector2, direction: Vector2):
    var space_state = get_world_2d().direct_space_state
    
    var query = PhysicsRayQueryParameters2D.create(
        from,
        from + direction * range
    )
    query.exclude = [self]
    
    var result = space_state.intersect_ray(query)
    
    if result:
        # 造成伤害
        if result.collider.has_method("take_damage"):
            result.collider.take_damage(damage)
        
        # 生成击中效果
        spawn_hit_effect(result.position, result.normal)
    else:
        # 未击中，生成最大距离的特效
        spawn_hit_effect(from + direction * range, Vector2.UP)
```

### 3. 地面检测（高级）

```gdscript
extends CharacterBody2D

@export var ground_check_distance: float = 10.0

func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    
    # 向下发射射线检测地面
    var query = PhysicsRayQueryParameters2D.create(
        global_position,
        global_position + Vector2.DOWN * ground_check_distance
    )
    query.exclude = [self]
    query.collision_mask = 1  # 只检测地面层
    
    var result = space_state.intersect_ray(query)
    
    if result:
        print("距离地面：", result.position.distance_to(global_position))
```

---

## ⚠️ 常见踩坑

### 1. 在 _process 中访问物理空间

```gdscript
# ❌ 错误：在 _process 中访问
func _process(delta):
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(query)

# ✅ 正确：在 _physics_process 中访问
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(query)
```

### 2. 使用局部坐标而非全局坐标

```gdscript
# ❌ 错误：使用局部坐标
var query = PhysicsRayQueryParameters2D.create(
    Vector2(0, 0),  # 节点的局部坐标
    Vector2(50, 100)
)

# ✅ 正确：使用全局坐标
var query = PhysicsRayQueryParameters2D.create(
    global_position,                    # 起点（全局）
    global_position + Vector2(50, 100)  # 终点（全局）
)
```

### 3. 忘记排除自身

```gdscript
# ❌ 错误：可能检测到自己
var query = PhysicsRayQueryParameters2D.create(start, end)

# ✅ 正确：排除自身
var query = PhysicsRayQueryParameters2D.create(start, end)
query.exclude = [self]
```

---

## 🔗 相关概念

### 物理系统基础

- [物理系统介绍](../concepts/physics-intro.md) - 碰撞层与掩码
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md) - 角色物体
- [Area2D 概念](../concepts/area2d-concept.md) - 区域检测

### Base 层来源

- [06G_RayCasting.md](../../base/physics-system/06G_RayCasting.md) - 完整原始文档

---

## 📊 核心知识点总结

| 知识点 | 重要性 | 说明 |
|--------|--------|------|
| RayCast2D 节点 | 🔴 必读 | 简单射线检测 |
| 物理空间查询 | 🔴 必读 | 灵活查询方式 |
| 射线查询参数 | 🔴 必读 | PhysicsRayQueryParameters2D |
| 碰撞层掩码 | 🔴 必读 | collision_mask 属性 |
| 排除碰撞体 | 🟡 推荐 | exclude 数组 |
| 形状查询 | 🟡 推荐 | intersect_point/intersect_shape |

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.6
