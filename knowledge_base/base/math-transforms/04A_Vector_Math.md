# Godot 4.x 向量数学

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/math/vector_math.rst

---

## 目录

1. [坐标系](#1-坐标系)
2. [向量操作](#2-向量操作)
3. [单位向量](#3-单位向量)
4. [点积](#4-点积)
5. [叉积](#5-叉积)
6. [反射](#6-反射)
7. [实用应用](#7-实用应用)

---

## 1. 坐标系

### 1.1 2D 坐标系

- X 轴向右为正
- Y 轴向下为正（与数学课不同）
- 原点在左上角

### 1.2 向量表示

向量表示相对方向和大小，与位置无关：

```gdscript
# 两个向量相同，只是绘制位置不同
var a = Vector2(4, 3)
var b = Vector2(4, 3)
```

---

## 2. 向量操作

### 2.1 成员访问

```gdscript
var a = Vector2(2, 5)
print(a.x)  # 2
print(a.y)  # 5

# 也可以通过索引访问
print(a[0])  # 2 (x)
print(a[1])  # 5 (y)
```

### 2.2 向量加法

```gdscript
var a = Vector2(2, 5)
var b = Vector2(3, 1)
var c = a + b  # (5, 6)
```

### 2.3 标量乘法

```gdscript
var a = Vector2(2, 5)
var b = a * 2   # (4, 10)
var c = a / 2   # (1, 2.5)
var d = a * -1  # (-2, -5) 反向
```

### 2.4 向量减法

```gdscript
# 从 A 指向 B 的向量
var direction = b - a
```

---

## 3. 单位向量

### 3.1 归一化

将向量长度变为 1，保持方向不变：

```gdscript
var a = Vector2(4, 3)
var normalized = a.normalized()  # (0.8, 0.6)
```

> **踩坑点**：长度为 0 的向量不能归一化。GDScript 中调用 `normalized()` 会返回原值而不报错。

### 3.2 获取方向

```gdscript
# 从 A 指向 B 的单位向量
var direction = a.direction_to(b)
```

### 3.3 获取长度

```gdscript
var a = Vector2(3, 4)
print(a.length())        # 5.0
print(a.length_squared())  # 25.0（无开方，更快）
```

---

## 4. 点积

### 4.1 定义

点积返回一个标量：

```gdscript
var a = Vector2(2, 3)
var b = Vector2(4, 1)
var dot = a.dot(b)  # 2*4 + 3*1 = 11
```

### 4.2 几何意义

对于单位向量，点积等于夹角的余弦值：

- `dot > 0`：夹角 < 90°（同向）
- `dot = 0`：夹角 = 90°（垂直）
- `dot < 0`：夹角 > 90°（反向）

### 4.3 判断朝向

```gdscript
# 判断敌人是否面向玩家
var facing = Vector2(1, 0)  # 敌人朝向
var to_player = enemy.direction_to(player)

if facing.dot(to_player) > 0:
    print("敌人面向玩家")
```

---

## 5. 叉积

### 5.1 3D 叉积

返回垂直于两个输入向量的新向量：

```gdscript
var a = Vector3(1, 0, 0)
var b = Vector3(0, 1, 0)
var c = a.cross(b)  # (0, 0, 1)
```

> **踩坑点**：叉积顺序很重要，`a.cross(b)` 和 `b.cross(a)` 结果相反。

### 5.2 2D 叉积模拟

2D 叉积返回标量（Z 分量）：

```gdscript
var a = Vector2(1, 0)
var b = Vector2(0, 1)
var cross = a.cross(b)  # 1（逆时针）
var cross2 = b.cross(a)  # -1（顺时针）
```

### 5.3 计算法向量

```gdscript
func get_triangle_normal(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
    var side1 = b - a
    var side2 = c - a
    return side1.cross(side2).normalized()
```

---

## 6. 反射

### 6.1 使用 bounce()

```gdscript
var collision = move_and_collide(velocity * delta)
if collision:
    velocity = velocity.bounce(collision.get_normal())
```

### 6.2 使用 reflect()

```gdscript
# reflect 需要手动处理
var reflected = velocity.reflect(normal)
```

---

## 7. 实用应用

### 7.1 移动

```gdscript
# 位置 + 速度 * 时间 = 新位置
position += velocity * delta
```

### 7.2 指向目标

```gdscript
# 从坦克指向机器人的向量
var direction = tank_position.direction_to(robot_position)
```

### 7.3 距离计算

```gdscript
var distance = a.distance_to(b)
var distance_squared = a.distance_squared_to(b)  # 更快，无需开方
```

### 7.4 插值

```gdscript
# 线性插值
var result = a.lerp(b, 0.5)  # 中点

# 球面插值（3D）
var result = a.slerp(b, 0.5)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/math/vector_math.rst`
