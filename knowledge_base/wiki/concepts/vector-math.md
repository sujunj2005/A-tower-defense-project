# 向量数学概念

> **来源**: [04A_Vector_Math.md](../../base/math-transforms/04A_Vector_Math.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📚 概述

向量是游戏开发中最基础的数学工具，用于表示**相对方向和大小**，与位置无关。向量数学是理解移动、旋转、物理模拟等游戏机制的基础。

---

## 🎯 核心概念

### 1. 坐标系

#### 1.1 2D 坐标系

Godot 使用独特的 2D 坐标系：
- **X 轴**: 向右为正
- **Y 轴**: **向下为正**（与数学课不同）
- **原点**: 在左上角

#### 1.2 向量表示

```gdscript
# 两个向量相同，只是绘制位置不同
var a = Vector2(4, 3)
var b = Vector2(4, 3)
```

> **关键理解**: 向量表示相对方向和大小，不是绝对位置。

---

### 2. 向量操作

#### 2.1 成员访问

```gdscript
var a = Vector2(2, 5)
print(a.x)  # 2
print(a.y)  # 5

# 也可以通过索引访问
print(a[0])  # 2 (x)
print(a[1])  # 5 (y)
```

#### 2.2 向量加法

```gdscript
var a = Vector2(2, 5)
var b = Vector2(3, 1)
var c = a + b  # (5, 6)
```

**几何意义**: 将两个向量的分量分别相加。

#### 2.3 标量乘法

```gdscript
var a = Vector2(2, 5)
var b = a * 2   # (4, 10)
var c = a / 2   # (1, 2.5)
var d = a * -1  # (-2, -5) 反向
```

**几何意义**: 缩放向量的长度，或反向。

#### 2.4 向量减法

```gdscript
# 从 A 指向 B 的向量
var direction = b - a
```

**几何意义**: 得到从点 A 指向点 B 的方向向量。

---

### 3. 单位向量（归一化）

#### 3.1 归一化

将向量长度变为 1，保持方向不变：

```gdscript
var a = Vector2(4, 3)
var normalized = a.normalized()  # (0.8, 0.6)
```

> ⚠️ **踩坑点**: 长度为 0 的向量不能归一化。GDScript 中调用 `normalized()` 会返回原值而不报错。

#### 3.2 获取方向

```gdscript
# 从 A 指向 B 的单位向量
var direction = a.direction_to(b)
```

#### 3.3 获取长度

```gdscript
var a = Vector2(3, 4)
print(a.length())        # 5.0
print(a.length_squared())  # 25.0（无开方，更快）
```

> **性能提示**: `length_squared()` 无需开方运算，在比较距离时更快。

---

### 4. 点积（Dot Product）

#### 4.1 定义

点积返回一个标量：

```gdscript
var a = Vector2(2, 3)
var b = Vector2(4, 1)
var dot = a.dot(b)  # 2*4 + 3*1 = 11
```

#### 4.2 几何意义

对于单位向量，点积等于夹角的余弦值：

| 点积值 | 夹角 | 几何意义 |
|--------|------|---------|
| `dot > 0` | < 90° | 两个向量同向 |
| `dot = 0` | = 90° | 两个向量垂直 |
| `dot < 0` | > 90° | 两个向量反向 |

#### 4.3 判断朝向

```gdscript
# 判断敌人是否面向玩家
var facing = Vector2(1, 0)  # 敌人朝向
var to_player = enemy.direction_to(player)

if facing.dot(to_player) > 0:
    print("敌人面向玩家")
```

**应用场景**:
- 视野检测（敌人能否看到玩家）
- 光线追踪（判断光线与表面角度）
- 投影计算

---

### 5. 叉积（Cross Product）

#### 5.1 3D 叉积

返回垂直于两个输入向量的新向量：

```gdscript
var a = Vector3(1, 0, 0)
var b = Vector3(0, 1, 0)
var c = a.cross(b)  # (0, 0, 1)
```

> ⚠️ **踩坑点**: 叉积顺序很重要，`a.cross(b)` 和 `b.cross(a)` 结果相反。

#### 5.2 2D 叉积模拟

2D 叉积返回标量（Z 分量）：

```gdscript
var a = Vector2(1, 0)
var b = Vector2(0, 1)
var cross = a.cross(b)  # 1（逆时针）
var cross2 = b.cross(a)  # -1（顺时针）
```

#### 5.3 计算法向量

```gdscript
func get_triangle_normal(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
    var side1 = b - a
    var side2 = c - a
    return side1.cross(side2).normalized()
```

**应用场景**:
- 计算表面法线（光照计算）
- 判断点在直线的哪一侧
- 3D 物理碰撞检测

---

### 6. 反射（Reflection）

#### 6.1 使用 bounce()

```gdscript
var collision = move_and_collide(velocity * delta)
if collision:
    velocity = velocity.bounce(collision.get_normal())
```

#### 6.2 使用 reflect()

```gdscript
# reflect 需要手动处理
var reflected = velocity.reflect(normal)
```

**应用场景**:
- 小球反弹
- 光线反射
- 镜面反射效果

---

## 🔧 实用应用

### 1. 移动

```gdscript
# 位置 + 速度 * 时间 = 新位置
position += velocity * delta
```

### 2. 指向目标

```gdscript
# 从坦克指向机器人的向量
var direction = tank_position.direction_to(robot_position)
```

### 3. 距离计算

```gdscript
var distance = a.distance_to(b)
var distance_squared = a.distance_squared_to(b)  # 更快，无需开方
```

### 4. 插值

```gdscript
# 线性插值
var result = a.lerp(b, 0.5)  # 中点

# 球面插值（3D）
var result = a.slerp(b, 0.5)
```

---

## 📊 核心公式总结

| 操作 | 公式 | 说明 |
|------|------|------|
| 向量加法 | `c = a + b` | 分量相加 |
| 标量乘法 | `b = a * scalar` | 缩放长度 |
| 向量减法 | `direction = b - a` | 从 A 指向 B |
| 归一化 | `normalized = a / a.length()` | 长度变 1 |
| 点积 | `dot = a.x*b.x + a.y*b.y` | 判断朝向 |
| 叉积 (2D) | `cross = a.x*b.y - a.y*b.x` | 判断顺/逆时针 |
| 距离 | `distance = (b - a).length()` | 两点间距离 |

---

## 🔗 相关链接

### Base 层来源
- [04A_Vector_Math.md](../../base/math-transforms/04A_Vector_Math.md) - 完整原始文档

### Wiki 层相关
- [矩阵与变换概念](./matrices-transforms.md) - 理解变换矩阵
- [插值运算指南](../guides/interpolation-guide.md) - 向量插值应用

### 外部资源
- [Godot 官方向量数学教程](https://docs.godotengine.org/en/stable/tutorials/math/vector_math.html)

---

## 📝 学习建议

### 初学者
1. 理解向量的基本概念（方向 + 大小）
2. 掌握向量加减法和标量乘法
3. 学会使用 `normalized()` 获取单位向量
4. 理解点积的几何意义

### 进阶学习
1. 掌握叉积在 3D 中的应用
2. 学会使用点积判断朝向和视野
3. 理解反射向量的计算
4. 应用到实际游戏开发中（移动、碰撞、AI）

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**许可**: MIT
