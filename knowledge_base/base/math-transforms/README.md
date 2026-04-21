# Godot 4.x 数学与变换（Base 目录）

## 📚 说明

本目录包含 Godot 4.x 中数学与变换相关的核心文档，作为知识库的基础参考资料。这些文档涵盖了游戏开发中常用的数学知识和变换技术。

## 📦 当前收录

### 数学与变换核心文档

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [04A_Vector_Math.md](./04A_Vector_Math.md) | **向量数学** - 2D/3D 向量操作、点积、叉积、反射 | `vector_math.rst` | 🔴 必读 |
| [04B_Matrices_and_Transforms.md](./04B_Matrices_and_Transforms.md) | **矩阵与变换** - Transform2D/3D、缩放、旋转、平移 | `matrices_and_transforms.rst` | 🔴 必读 |
| [04C_Interpolation.md](./04C_Interpolation.md) | **插值运算** - lerp、平滑移动、帧率无关插值 | `interpolation.rst` | 🔴 必读 |
| [04E_Beziers_and_Curves.md](./04E_Beziers_and_Curves.md) | **贝塞尔曲线** - 二次/三次贝塞尔、Curve2D/3D | `beziers_and_curves.rst` | 🟡 推荐 |
| [04F_Random_Numbers.md](./04F_Random_Numbers.md) | **随机数生成** - PRNG、噪声生成、加密安全随机数 | `random_number_generation.rst` | 🟡 推荐 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/math/)  
**文件数**: 5 份  
**总字数**: ~25,000+

## 🎯 使用建议

### 学习路径

```
1. [向量数学](./04A_Vector_Math.md) - 基础中的基础
   ↓
2. [矩阵与变换](./04B_Matrices_and_Transforms.md) - 理解变换原理
   ↓
3. [插值运算](./04C_Interpolation.md) - 平滑过渡必备
   ↓
4. [贝塞尔曲线](./04E_Beziers_and_Curves.md) - 高级曲线应用
   ↓
5. [随机数生成](./04F_Random_Numbers.md) - 程序化内容生成
```

### 快速查询

- **向量操作** → 查看 [04A_Vector_Math.md](./04A_Vector_Math.md)
- **变换矩阵** → 查看 [04B_Matrices_and_Transforms.md](./04B_Matrices_and_Transforms.md)
- **平滑移动** → 查看 [04C_Interpolation.md](./04C_Interpolation.md)
- **曲线路径** → 查看 [04E_Beziers_and_Curves.md](./04E_Beziers_and_Curves.md)
- **随机化** → 查看 [04F_Random_Numbers.md](./04F_Random_Numbers.md)

## 📝 核心概念

### 1. 向量数学 (Vector Math)

向量是游戏开发中最基础的数学工具，用于表示：
- 方向（单位向量）
- 速度（位置变化率）
- 力（物理模拟）

**关键操作**:
- 加法/减法（组合方向）
- 标量乘法（缩放大小）
- 点积（判断朝向）
- 叉积（计算法向量）
- 归一化（获取单位向量）

### 2. 矩阵与变换 (Matrices and Transforms)

变换矩阵用于描述物体的：
- 位置（origin）
- 旋转（basis）
- 缩放（scale）

**Godot 中的变换**:
- `Transform2D` - 2D 变换（3×3 矩阵）
- `Transform3D` - 3D 变换（4×4 矩阵）

**变换组合**:
```gdscript
# 先缩放，再旋转，最后平移
var t = Transform2D.IDENTITY
t = t.scaled(Vector2(2, 2))
t = t.rotated(PI / 4)
t.origin = Vector2(100, 100)
```

### 3. 插值运算 (Interpolation)

插值用于在两个值之间平滑过渡：
- **线性插值 (lerp)**: `A + (B - A) * t`
- **帧率无关插值**: `1 - exp(-speed * delta)`
- **三次插值**: `cubic_interpolate()`
- **球面插值**: `slerp()` (用于 3D 旋转)

### 4. 贝塞尔曲线 (Béziers and Curves)

贝塞尔曲线用于创建平滑曲线路径：
- **二次贝塞尔**: 3 个点（起点、控制点、终点）
- **三次贝塞尔**: 4 个点（起点、2 个控制点、终点）
- **Godot 内置支持**: `Curve2D`, `Curve3D`, `Path2D`

### 5. 随机数生成 (Random Numbers)

Godot 提供多种随机数生成方式：
- **全局函数**: `randi()`, `randf()`, `randf_range()`
- **RandomNumberGenerator 类**: 多个独立实例
- **噪声生成**: `FastNoiseLite`
- **加密安全**: `PCK` 包装器

## 🔗 相关资源

### Wiki 层映射

基于本 Base 层文档，已创建以下 Wiki 页面：

#### 概念页面 (concepts/)
- [向量数学概念](../../wiki/concepts/vector-math.md) - 来自 04A_Vector_Math.md
- [矩阵与变换概念](../../wiki/concepts/matrices-transforms.md) - 来自 04B_Matrices_and_Transforms.md

#### 指南页面 (guides/)
- [插值运算指南](../../wiki/guides/interpolation-guide.md) - 来自 04C_Interpolation.md
- [贝塞尔曲线指南](../../wiki/guides/bezier-curves-guide.md) - 来自 04E_Beziers_and_Curves.md
- [随机数生成指南](../../wiki/guides/random-numbers-guide.md) - 来自 04F_Random_Numbers.md

### 外部资源

- **Godot 官方文档**: https://docs.godotengine.org/
- **向量数学教程**: https://docs.godotengine.org/en/stable/tutorials/math/vector_math.html
- **矩阵与变换**: https://docs.godotengine.org/en/stable/tutorials/math/matrices_and_transforms.html
- **插值运算**: https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html
- **贝塞尔曲线**: https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html
- **随机数生成**: https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html

## 📊 统计信息

| 分类 | 文档数 | 字数估算 | 重要性 |
|------|--------|---------|--------|
| 向量数学 | 1 | ~5,000+ | 🔴 必读 |
| 矩阵与变换 | 1 | ~5,000+ | 🔴 必读 |
| 插值运算 | 1 | ~3,000+ | 🔴 必读 |
| 贝塞尔曲线 | 1 | ~4,000+ | 🟡 推荐 |
| 随机数生成 | 1 | ~8,000+ | 🟡 推荐 |
| **总计** | **5** | **~25,000+** | - |

## 📝 更新策略

- 定期从官方 godot-docs master 分支同步
- 稳定版本发布时更新
- 与项目使用的 Godot 版本保持同步

---

**最后更新**: 2026-04-07  
**文档版本**: Godot 4.x (master)  
**维护者**: Knowledge Base Administrator
