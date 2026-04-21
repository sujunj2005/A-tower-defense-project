# Godot 4.x 矩阵与变换

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/math/matrices_and_transforms.rst

---

## 目录

1. [变换矩阵概述](#1-变换矩阵概述)
2. [缩放](#2-缩放)
3. [旋转](#3-旋转)
4. [平移](#4-平移)
5. [组合变换](#5-组合变换)
6. [变换转换](#6-变换转换)
7. [逆变换](#7-逆变换)

---

## 1. 变换矩阵概述

### 1.1 Transform2D 组成

Transform2D 由三部分组成：
- `x`：X 轴基向量（第一列）
- `y`：Y 轴基向量（第二列）
- `origin`：原点位置

### 1.2 单位矩阵

```gdscript
var t = Transform2D.IDENTITY
# x = (1, 0)
# y = (0, 1)
# origin = (0, 0)
```

### 1.3 访问分量

```gdscript
var t = transform
print(t.x)      # X 轴向量
print(t.y)      # Y 轴向量
print(t.origin) # 位置

print(t.x.x)    # X 轴的 X 分量
print(t.x.y)    # X 轴的 Y 分量
```

---

## 2. 缩放

### 2.1 手动缩放

```gdscript
var t = Transform2D.IDENTITY
t.x *= 2  # X 轴放大 2 倍
t.y *= 3  # Y 轴放大 3 倍
transform = t
```

### 2.2 使用 scaled()

```gdscript
transform = transform.scaled(Vector2(2, 3))
```

### 2.3 获取当前缩放

```gdscript
var scale_x = transform.x.length()
var scale_y = transform.y.length()
```

---

## 3. 旋转

### 3.1 手动旋转

```gdscript
var rot = 0.5  # 弧度
var t = Transform2D.IDENTITY
t.x.x = cos(rot)
t.x.y = sin(rot)
t.y.x = -sin(rot)
t.y.y = cos(rot)
transform = t
```

### 3.2 使用 rotated()

```gdscript
transform = transform.rotated(PI / 4)  # 旋转 45°
```

### 3.3 获取当前旋转

```gdscript
var rotation = atan2(transform.x.y, transform.x.x)
```

> **踩坑点**：Godot 使用弧度而非角度。`PI` = 180°，`TAU` = 360°。

---

## 4. 平移

### 4.1 直接设置 origin

```gdscript
transform.origin = Vector2(100, 200)
```

### 4.2 使用 translated()

```gdscript
# 相对于父坐标系平移
transform = transform.translated(Vector2(100, 0))

# 相对于自身坐标系平移
transform = transform.translated_local(Vector2(100, 0))
```

---

## 5. 组合变换

### 5.1 组合顺序

```gdscript
# 先缩放，再旋转，最后平移
var t = Transform2D.IDENTITY
t = t.scaled(Vector2(2, 2))
t = t.rotated(PI / 4)
t.origin = Vector2(100, 100)
transform = t
```

### 5.2 矩阵乘法

```gdscript
# 父变换 * 子变换 = 子的世界变换
var world_transform = parent_transform * child_transform
```

> **踩坑点**：矩阵乘法顺序很重要！`A * B ≠ B * A`

---

## 6. 变换转换

### 6.1 局部坐标转世界坐标

```gdscript
# 局部 (0, 100) 转换为世界坐标
var world_pos = transform * Vector2(0, 100)
```

### 6.2 世界坐标转局部坐标

```gdscript
# 世界坐标转换为局部坐标
var local_pos = Vector2(0, 100) * transform
```

### 6.3 使用 basis_xform

如果已知原点为 (0, 0)，可以跳过平移：

```gdscript
var world_dir = transform.basis_xform(local_dir)
var local_dir = transform.basis_xform_inv(world_dir)
```

---

## 7. 逆变换

### 7.1 获取逆变换

```gdscript
var inverse = transform.affine_inverse()
```

### 7.2 逆变换的应用

```gdscript
# 撤销变换
var t = transform
var ti = t.affine_inverse()
var identity = ti * t  # 单位矩阵
```

---

## 8. 相对自身移动

```gdscript
# 向自身右方移动 100 单位
transform.origin += transform.x * 100

# 向自身前方移动（2D 中 Y 轴向下）
transform.origin += transform.y * 100
```

---

## 9. 3D 变换

### 9.1 Transform3D 结构

```gdscript
var t = Transform3D.IDENTITY
t.basis.x  # X 轴基向量
t.basis.y  # Y 轴基向量
t.basis.z  # Z 轴基向量
t.origin   # 位置
```

### 9.2 3D 旋转表示

3D 旋转可用：
- Basis（3×3 矩阵）
- Quaternion（四元数）

```gdscript
# 欧拉角转 Basis
var basis = Basis.from_euler(Vector3(0, PI/2, 0))

# Basis 转 Quaternion
var quat = basis.get_rotation_quaternion()
```

> **踩坑点**：3D 旋转不要直接使用欧拉角，容易产生万向节死锁。使用 Basis 或 Quaternion。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/math/matrices_and_transforms.rst`
