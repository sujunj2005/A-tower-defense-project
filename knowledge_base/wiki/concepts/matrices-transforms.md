# 矩阵与变换概念

> **来源**: [04B_Matrices_and_Transforms.md](../../base/math-transforms/04B_Matrices_and_Transforms.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📚 概述

变换矩阵是描述物体在空间中**位置、旋转和缩放**的数学工具。在 Godot 中，变换矩阵用于所有 Node2D 和 Node3D 节点的空间变换。

---

## 🎯 核心概念

### 1. Transform2D 组成

Transform2D 由三部分组成：

```gdscript
var t = transform
print(t.x)      # X 轴基向量（第一列）
print(t.y)      # Y 轴基向量（第二列）
print(t.origin) # 原点位置
```

#### 1.1 单位矩阵

```gdscript
var t = Transform2D.IDENTITY
# x = (1, 0)
# y = (0, 1)
# origin = (0, 0)
```

单位矩阵表示没有任何变换的状态。

#### 1.2 访问分量

```gdscript
var t = transform
print(t.x)      # X 轴向量
print(t.y)      # Y 轴向量
print(t.origin) # 位置

print(t.x.x)    # X 轴的 X 分量
print(t.x.y)    # X 轴的 Y 分量
```

---

### 2. 缩放（Scaling）

#### 2.1 手动缩放

```gdscript
var t = Transform2D.IDENTITY
t.x *= 2  # X 轴放大 2 倍
t.y *= 3  # Y 轴放大 3 倍
transform = t
```

#### 2.2 使用 scaled()

```gdscript
transform = transform.scaled(Vector2(2, 3))
```

#### 2.3 获取当前缩放

```gdscript
var scale_x = transform.x.length()
var scale_y = transform.y.length()
```

> **理解关键**: 基向量的长度就是缩放比例。

---

### 3. 旋转（Rotation）

#### 3.1 手动旋转

```gdscript
var rot = 0.5  # 弧度
var t = Transform2D.IDENTITY
t.x.x = cos(rot)
t.x.y = sin(rot)
t.y.x = -sin(rot)
t.y.y = cos(rot)
transform = t
```

#### 3.2 使用 rotated()

```gdscript
transform = transform.rotated(PI / 4)  # 旋转 45°
```

#### 3.3 获取当前旋转

```gdscript
var rotation = atan2(transform.x.y, transform.x.x)
```

> ⚠️ **踩坑点**: Godot 使用**弧度**而非角度。`PI` = 180°，`TAU` = 360°。

---

### 4. 平移（Translation）

#### 4.1 直接设置 origin

```gdscript
transform.origin = Vector2(100, 200)
```

#### 4.2 使用 translated()

```gdscript
# 相对于父坐标系平移
transform = transform.translated(Vector2(100, 0))

# 相对于自身坐标系平移
transform = transform.translated_local(Vector2(100, 0))
```

**区别**:
- `translated()`: 在世界坐标系中平移
- `translated_local()`: 在局部坐标系中平移（考虑当前旋转）

---

### 5. 组合变换

#### 5.1 组合顺序

```gdscript
# 先缩放，再旋转，最后平移
var t = Transform2D.IDENTITY
t = t.scaled(Vector2(2, 2))
t = t.rotated(PI / 4)
t.origin = Vector2(100, 100)
transform = t
```

> **重要原则**: 变换顺序很重要！通常遵循 **缩放 → 旋转 → 平移** 的顺序。

#### 5.2 矩阵乘法

```gdscript
# 父变换 * 子变换 = 子的世界变换
var world_transform = parent_transform * child_transform
```

> ⚠️ **踩坑点**: 矩阵乘法顺序很重要！`A * B ≠ B * A`

---

### 6. 变换转换

#### 6.1 局部坐标转世界坐标

```gdscript
# 局部 (0, 100) 转换为世界坐标
var world_pos = transform * Vector2(0, 100)
```

#### 6.2 世界坐标转局部坐标

```gdscript
# 世界坐标转换为局部坐标
var local_pos = Vector2(0, 100) * transform
```

#### 6.3 使用 basis_xform

如果已知原点为 (0, 0)，可以跳过平移：

```gdscript
var world_dir = transform.basis_xform(local_dir)
var local_dir = transform.basis_xform_inv(world_dir)
```

**应用场景**:
- 将局部方向转换为世界方向
- 碰撞检测中的坐标转换

---

### 7. 逆变换（Inverse Transform）

#### 7.1 获取逆变换

```gdscript
var inverse = transform.affine_inverse()
```

#### 7.2 逆变换的应用

```gdscript
# 撤销变换
var t = transform
var ti = t.affine_inverse()
var identity = ti * t  # 单位矩阵
```

**应用场景**:
- 将世界坐标转换回局部坐标
- 撤销变换效果
- 相机变换（将世界转换到相机空间）

---

### 8. 相对自身移动

```gdscript
# 向自身右方移动 100 单位
transform.origin += transform.x * 100

# 向自身前方移动（2D 中 Y 轴向下）
transform.origin += transform.y * 100
```

**理解关键**: `transform.x` 和 `transform.y` 是物体自身的坐标轴方向。

---

## 🎮 3D 变换

### 9.1 Transform3D 结构

```gdscript
var t = Transform3D.IDENTITY
t.basis.x  # X 轴基向量
t.basis.y  # Y 轴基向量
t.basis.z  # Z 轴基向量
t.origin   # 位置
```

### 9.2 3D 旋转表示

3D 旋转可用两种方式表示：

#### 9.2.1 Basis（3×3 矩阵）

```gdscript
# 欧拉角转 Basis
var basis = Basis.from_euler(Vector3(0, PI/2, 0))
```

#### 9.2.2 Quaternion（四元数）

```gdscript
# Basis 转 Quaternion
var quat = basis.get_rotation_quaternion()
```

> ⚠️ **踩坑点**: 3D 旋转不要直接使用欧拉角，容易产生**万向节死锁**。使用 Basis 或 Quaternion。

---

## 📊 核心 API 总结

### Transform2D 常用方法

| 方法 | 说明 | 示例 |
|------|------|------|
| `scaled(scale)` | 缩放变换 | `transform.scaled(Vector2(2, 2))` |
| `rotated(angle)` | 旋转变换 | `transform.rotated(PI / 4)` |
| `translated(offset)` | 平移变换（世界坐标） | `transform.translated(Vector2(100, 0))` |
| `translated_local(offset)` | 平移变换（局部坐标） | `transform.translated_local(Vector2(100, 0))` |
| `affine_inverse()` | 逆变换 | `transform.affine_inverse()` |
| `basis_xform(vec)` | 基向量变换（不含平移） | `transform.basis_xform(direction)` |

### 常用属性

| 属性 | 说明 | 类型 |
|------|------|------|
| `x` | X 轴基向量 | Vector2 |
| `y` | Y 轴基向量 | Vector2 |
| `origin` | 原点位置 | Vector2 |

---

## 🔗 相关链接

### Base 层来源
- [04B_Matrices_and_Transforms.md](../../base/math-transforms/04B_Matrices_and_Transforms.md) - 完整原始文档

### Wiki 层相关
- [向量数学概念](./vector-math.md) - 向量基础
- [插值运算指南](../guides/interpolation-guide.md) - 变换插值
- [场景树概念](./scene-tree.md) - 节点变换层级

### 外部资源
- [Godot 官方矩阵与变换教程](https://docs.godotengine.org/en/stable/tutorials/math/matrices_and_transforms.html)

---

## 📝 学习建议

### 初学者
1. 理解 Transform2D 的三个组成部分（x, y, origin）
2. 掌握基本的缩放、旋转、平移操作
3. 理解变换的顺序很重要
4. 学会使用 `translated()` 和 `translated_local()` 的区别

### 进阶学习
1. 理解矩阵乘法的几何意义
2. 掌握坐标转换（局部 ↔ 世界）
3. 学习 3D 变换和四元数
4. 应用到相机控制、角色移动等实际场景

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**许可**: MIT
