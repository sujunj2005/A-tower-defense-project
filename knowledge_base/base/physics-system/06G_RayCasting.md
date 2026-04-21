# Godot 4.x 射线检测

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/physics/ray-casting.rst

---

## 目录

1. [射线检测概述](#1-射线检测概述)
2. [访问物理空间](#2-访问物理空间)
3. [射线查询](#3-射线查询)
4. [形状查询](#4-形状查询)
5. [RayCast2D/RayCast3D 节点](#5-raycast2draycast3d-节点)

---

## 1. 射线检测概述

### 1.1 什么是射线检测

在游戏开发中，最常见的任务之一是发射射线（或自定义形状对象）并检查它击中了什么。这使得复杂的行为、AI 等能够发生。

### 1.2 两种方式

- **RayCast2D/RayCast3D 节点**：简单，每帧返回结果
- **直接查询物理空间**：更灵活，可自定义查询参数

---

## 2. 访问物理空间

### 2.1 空间概念

在物理世界中，Godot 将所有底层碰撞和物理信息存储在一个*空间*中。

### 2.2 获取 2D 空间

```gdscript
func _physics_process(delta):
    var space_rid = get_world_2d().space
    var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
```

或更直接：

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
```

### 2.3 获取 3D 空间

```gdscript
func _physics_process(delta):
    var space_state = get_world_3d().direct_space_state
```

### 2.4 安全访问

> **踩坑点**：默认情况下，Godot 物理与游戏逻辑在同一线程中运行，但可以设置为在单独的线程中运行以提高效率。因此，访问空间的唯一安全时间是在 `_physics_process()` 回调期间。在此函数之外访问它可能会由于空间被*锁定*而导致错误。

---

## 3. 射线查询

### 3.1 基础射线查询

执行 2D 射线查询：

```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
    # 使用全局坐标，不是节点的局部坐标
    var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50, 100))
    var result = space_state.intersect_ray(query)
```

### 3.2 检查结果

```gdscript
if result:
    print("击中位置：", result.position)
    print("碰撞法线：", result.normal)
    print("碰撞物体：", result.collider)
```

### 3.3 结果字典内容

| 键 | 说明 |
|----|------|
| `position` | 碰撞点（世界空间） |
| `normal` | 碰撞法线（世界空间） |
| `collider` | 碰撞的物体 |
| `collider_id` | 碰撞物体的 ObjectID |
| `rid` | 碰撞形状的 RID |
| `shape` | 碰撞形状的索引 |
| `metadata` | 形状的元数据 |

### 3.4 3D 射线查询

```gdscript
func _physics_process(delta):
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(Vector3(0, 0, 0), Vector3(0, 5, 10))
    var result = space_state.intersect_ray(query)
```

### 3.5 排除碰撞体

```gdscript
var query = PhysicsRayQueryParameters2D.create(start, end)
query.exclude = [self]  # 排除自身
var result = space_state.intersect_ray(query)
```

### 3.6 碰撞层掩码

```gdscript
var query = PhysicsRayQueryParameters2D.create(start, end)
query.collision_mask = 1  # 只检测第 1 层
var result = space_state.intersect_ray(query)
```

---

## 4. 形状查询

### 4.1 相交点查询

```gdscript
var query = PhysicsPointQueryParameters2D.create()
query.position = Vector2(50, 50)
query.collision_mask = 1
var results = space_state.intersect_point(query, 32)
```

### 4.2 形状相交查询

```gdscript
var shape = CircleShape2D.new()
shape.radius = 32

var query = PhysicsShapeQueryParameters2D.create()
query.shape = shape
query.transform = Transform2D.IDENTITY.translated(Vector2(50, 50))
query.collision_mask = 1
var results = space_state.intersect_shape(query, 32)
```

### 4.3 获取最近碰撞体

```gdscript
query.collide_with_areas = false
query.collide_with_bodies = true
```

---

## 5. RayCast2D/RayCast3D 节点

### 5.1 基本用法

对于简单的射线检测，使用节点更方便：

```gdscript
extends RayCast2D

func _process(delta):
    if is_colliding():
        print("击中了：", get_collider())
        print("位置：", get_collision_point())
    else:
        print("未击中")
```

### 5.2 配置属性

```gdscript
func _ready():
    target_position = Vector2(100, 0)  # 相对于父节点
    enabled = true
    exclude_parent = true  # 排除父节点
    collision_mask = 1  # 碰撞层掩码
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/physics/ray-casting.rst`
