# 碰撞检测方案对比分析

> **适用版本**: Godot 4.x  
> **对比主题**: 碰撞检测技术方案  
> **前置知识**: 物理系统基础、2D/3D 节点

---

## 📊 碰撞检测方案总览

| 方案 | 精度 | 性能 | 复杂度 | 适用场景 |
|------|------|------|--------|---------|
| **矩形碰撞 (Rect2)** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | 平台跳跃、UI 碰撞 |
| **圆形碰撞 (Circle)** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | 简单角色、投射物 |
| **胶囊碰撞 (Capsule)** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | 人形角色、生物 |
| **凸多边形 (Convex)** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | 复杂形状、动态物体 |
| **凹多边形 (Concave)** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | 静态地形、关卡 |
| **射线检测 (RayCast)** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | 视线检测、地面检测 |
| **区域检测 (Area)** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | 触发区域、拾取物 |

---

## 1. 矩形碰撞 (RectangleShape2D/BoxShape3D)

### 1.1 基本用法
```gdscript
# 2D 矩形碰撞
var collision_shape = CollisionShape2D.new()
var shape = RectangleShape2D.new()
shape.size = Vector2(32, 64)  # 宽 32，高 64
collision_shape.shape = shape

# 3D 盒形碰撞
var collision_shape = CollisionShape3D.new()
var shape = BoxShape3D.new()
shape.size = Vector3(1, 2, 1)  # 宽 1m，高 2m，深 1m
collision_shape.shape = shape
```

### 1.2 优点
- ✅ **性能最佳**: 最简单的碰撞检测
- ✅ **配置简单**: 只需设置尺寸
- ✅ **稳定可靠**: 不易出现穿透问题

### 1.3 缺点
- ❌ **精度低**: 无法精确匹配不规则形状
- ❌ **角落问题**: 旋转后碰撞体积变大

### 1.4 适用场景
- 平台跳跃游戏（角色、平台）
- UI 元素碰撞
- 简单的箱子、障碍物
- 性能敏感的场景

### 1.5 不适用场景
- 圆形角色（球、滚石）
- 人形角色（需要更精确的碰撞）
- 旋转频繁的物体

**参考**:
- [物理系统介绍](../concepts/physics-intro.md)

---

## 2. 圆形碰撞 (CircleShape2D/SphereShape3D)

### 2.1 基本用法
```gdscript
# 2D 圆形碰撞
var collision_shape = CollisionShape2D.new()
var shape = CircleShape2D.new()
shape.radius = 16.0  # 半径 16 像素

# 3D 球形碰撞
var collision_shape = CollisionShape3D.new()
var shape = SphereShape3D.new()
shape.radius = 0.5  # 半径 0.5 米
```

### 2.2 优点
- ✅ **性能优秀**: 仅计算距离
- ✅ **无方向性**: 旋转不影响碰撞
- ✅ **平滑滚动**: 适合滚动物体

### 2.3 缺点
- ❌ **精度一般**: 无法表示非圆形物体
- ❌ **角落问题**: 无法精确匹配方形物体

### 2.4 适用场景
- 球体、滚石、弹珠
- 简单的角色碰撞（俯视角）
- 投射物（子弹、火球）
- 拾取物（金币、道具）

### 2.5 不适用场景
- 人形角色
- 方形物体
- 需要精确碰撞的场景

**参考**:
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md)

---

## 3. 胶囊碰撞 (CapsuleShape2D/CapsuleShape3D)

### 3.1 基本用法
```gdscript
# 2D 胶囊碰撞
var collision_shape = CollisionShape2D.new()
var shape = CapsuleShape2D.new()
shape.radius = 16.0
shape.height = 48.0  # 圆柱部分高度

# 3D 胶囊碰撞
var collision_shape = CollisionShape3D.new()
var shape = CapsuleShape3D.new()
shape.radius = 0.3
shape.height = 1.6  # 圆柱部分高度（不含半球）
```

### 3.2 优点
- ✅ **精度较高**: 适合人形角色
- ✅ **性能良好**: 比凸多边形更高效
- ✅ **平滑移动**: 圆角避免卡顿

### 3.3 缺点
- ❌ **方向限制**: 只能沿一个方向
- ❌ **配置复杂**: 需要调整半径和高度

### 3.4 适用场景
- 人形角色（玩家、NPC）
- 生物角色（动物、怪物）
- 需要精确碰撞的角色

### 3.5 不适用场景
- 非人形物体
- 旋转频繁的物体
- 扁平物体

**参考**:
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md)

---

## 4. 凸多边形碰撞 (ConvexPolygonShape2D/3D)

### 4.1 基本用法
```gdscript
# 2D 凸多边形碰撞
var collision_shape = CollisionShape2D.new()
var shape = ConvexPolygonShape2D.new()
shape.points = PackedVector2Array([
    Vector2(-16, -32),
    Vector2(16, -32),
    Vector2(0, 32)
])  # 三角形

# 3D 凸多边形碰撞（从网格生成）
var collision_shape = CollisionShape3D.new()
var mesh = $MeshInstance3D.mesh
var shape = mesh.create_convex_shape()
collision_shape.shape = shape
```

### 4.2 优点
- ✅ **精度高**: 可以精确匹配复杂形状
- ✅ **动态支持**: 适合移动的复杂物体
- ✅ **自动生成**: 可从网格生成

### 4.3 缺点
- ❌ **性能较低**: 顶点越多越慢
- ❌ **凸性限制**: 必须是凸多边形（无凹陷）
- ❌ **内存占用**: 顶点数据存储

### 4.4 适用场景
- 复杂形状的动态物体
- 需要精确碰撞的道具
- 不规则形状的敌人
- 车辆、飞行器

### 4.5 不适用场景
- 简单形状（优先使用矩形/圆形）
- 凹多边形物体（有凹陷）
- 性能敏感的场景

**参考**:
- [物理系统介绍](../concepts/physics-intro.md)

---

## 5. 凹多边形碰撞 (ConcavePolygonShape2D/3D)

### 5.1 基本用法
```gdscript
# 2D 凹多边形碰撞
var collision_shape = CollisionShape2D.new()
var shape = ConcavePolygonShape2D.new()
shape.segments = PackedVector2Array([
    Vector2(-32, -32),
    Vector2(32, -32),
    Vector2(32, 0),
    Vector2(0, 32),
    Vector2(-32, 0)
])  # 五边形（可能凹陷）

# 3D 凹多边形（从网格生成）
var collision_shape = CollisionShape3D.new()
var mesh = $StaticBody3D/MeshInstance3D.mesh
var shape = mesh.create_trimesh_shape()
collision_shape.shape = shape
```

### 5.2 优点
- ✅ **精度最高**: 完全匹配网格形状
- ✅ **支持凹陷**: 可以表示复杂凹陷形状
- ✅ **静态完美**: 适合静态地形

### 5.3 缺点
- ❌ **性能最差**: 大量三角形检测
- ❌ **仅限静态**: 不适合移动物体（可能穿透）
- ❌ **内存占用**: 大量三角形数据

### 5.4 适用场景
- 静态地形（山脉、洞穴）
- 复杂关卡结构
- 不会移动的装饰物
- 精确碰撞的静态道具

### 5.5 不适用场景
- **动态物体**（可能穿透！）
- 简单形状（性能浪费）
- 性能敏感的场景

**参考**:
- [物理系统介绍](../concepts/physics-intro.md)

---

## 6. 射线检测 (RayCast2D/3D)

### 6.1 基本用法
```gdscript
# 2D 射线检测
var raycast = RayCast2D.new()
raycast.target_position = Vector2(0, 100)  # 向下 100 像素
raycast.collision_mask = 0b001  # 检测层 1
add_child(raycast)

# 检查是否碰撞
if raycast.is_colliding():
    var collider = raycast.get_collider()
    var collision_point = raycast.get_collision_point()
    print("碰撞到：", collider.name, " 位置：", collision_point)

# 3D 射线检测（代码方式）
var space_state = get_world_3d().direct_space_state
var query = PhysicsRayQueryParameters3D.create(
    from = Vector3(0, 0, 0),
    to = Vector3(0, -10, 0),
    collision_mask = 0b001
)
var result = space_state.intersect_ray(query)

if result:
    print("碰撞到：", result.collider.name)
```

### 6.2 优点
- ✅ **性能优秀**: 单一线条检测
- ✅ **精度高**: 精确的碰撞点和法线
- ✅ **灵活**: 可以检测任意方向

### 6.3 缺点
- ❌ **单点检测**: 只能检测一条线
- ❌ **需要代码**: 配置相对复杂

### 6.4 适用场景
- 视线检测（敌人是否能看到玩家）
- 地面检测（角色是否在地面）
- 射击检测（子弹命中）
- 距离测量

### 6.5 最佳实践
```gdscript
# 多射线检测（扇形视野）
func check_cone_detection(origin: Vector2, direction: Vector2, angle: float, distance: float) -> bool:
    var ray_count = 5
    for i in range(ray_count):
        var ray_angle = remap(i, 0, ray_count - 1, -angle / 2, angle / 2)
        var ray_dir = direction.rotated(ray_angle)
        
        var raycast = RayCast2D.new()
        raycast.target_position = ray_dir * distance
        raycast.position = origin
        add_child(raycast)
        
        if raycast.is_colliding():
            return true
    
    return false
```

**参考**:
- [射线投射指南](../guides/raycasting-guide.md)

---

## 7. 区域检测 (Area2D/3D)

### 7.1 基本用法
```gdscript
# Area2D 区域检测
var area = Area2D.new()
var collision_shape = CollisionShape2D.new()
var shape = CircleShape2D.new()
shape.radius = 50.0
collision_shape.shape = shape
area.add_child(collision_shape)

# 连接信号
area.area_entered.connect(_on_area_entered)
area.body_entered.connect(_on_body_entered)

func _on_area_entered(other_area: Area2D):
    print("区域进入：", other_area.name)

func _on_body_entered(body: Node2D):
    print("物体进入：", body.name)

# 代码检测重叠
var overlaps = area.get_overlapping_bodies()
for body in overlaps:
    print("重叠物体：", body.name)
```

### 7.2 优点
- ✅ **信号驱动**: 自动触发事件
- ✅ **灵活形状**: 可以使用任意碰撞形状
- ✅ **多功能**: 检测区域、施加力

### 7.3 缺点
- ❌ **性能中等**: 需要持续检测重叠
- ❌ **配置复杂**: 需要设置信号回调

### 7.4 适用场景
- 触发区域（传送带、陷阱）
- 拾取物检测（金币、道具）
- 伤害区域（毒气、火焰）
- 物理力场（引力、斥力）

### 7.5 不适用场景
- 精确碰撞检测（使用碰撞体）
- 物理模拟（使用刚体）

**参考**:
- [Area2D 概念](../concepts/area2d-concept.md)

---

## 📊 综合对比

### 8.1 性能对比（从高到低）
```
矩形 > 圆形 > 胶囊 > 射线 > 凸多边形 > 区域 > 凹多边形
```

### 8.2 精度对比（从低到高）
```
矩形 < 圆形 < 胶囊 < 凸多边形 < 凹多边形 ≈ 射线
```

### 8.3 选择决策树
```
┌─────────────────────────────────────────┐
│  需要检测什么？                          │
│    ├─ 触发事件 → Area2D/Area3D          │
│    ├─ 单点检测 → RayCast2D/3D           │
│    └─ 物理碰撞 → 选择碰撞形状            │
│         ├─ 简单形状 → 矩形/圆形          │
│         ├─ 人形角色 → 胶囊               │
│         ├─ 复杂动态 → 凸多边形           │
│         └─ 复杂静态 → 凹多边形           │
└─────────────────────────────────────────┘
```

### 8.4 复合碰撞体示例
```gdscript
# 人形角色复合碰撞体
func create_character_collision():
    var root = CharacterBody2D.new()
    
    # 主体（胶囊）
    var body_shape = CapsuleShape2D.new()
    body_shape.radius = 16
    body_shape.height = 48
    
    var body_collision = CollisionShape2D.new()
    body_collision.shape = body_shape
    body_collision.position = Vector2(0, 24)
    root.add_child(body_collision)
    
    # 脚部（矩形，用于精确地面检测）
    var foot_shape = RectangleShape2D.new()
    foot_shape.size = Vector2(24, 4)
    
    var foot_collision = CollisionShape2D.new()
    foot_collision.shape = foot_shape
    foot_collision.position = Vector2(0, 50)
    root.add_child(foot_collision)
    
    return root
```

---

## 🔗 相关资源

### Base 层来源
- [物理系统介绍](../../base/physics-system/06A_Physics_Introduction.md)
- [CharacterBody2D](../../base/physics-system/06B_CharacterBody2D.md)
- [Area2D](../../base/physics-system/06F_Area2D.md)
- [射线检测](../../base/physics-system/06G_RayCasting.md)

### Wiki 层相关
- [物理系统介绍](../concepts/physics-intro.md)
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md)
- [Area2D 概念](../concepts/area2d-concept.md)
- [射线投射指南](../guides/raycasting-guide.md)

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
