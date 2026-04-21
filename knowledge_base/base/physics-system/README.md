# Base 层 - 物理系统文档

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.x  
> **文档来源**: Godot 官方文档

---

## 📚 文档列表

本目录包含 Godot 4.x 物理系统的原始文档，全部来源于 Godot 官方文档。

| 文档 | 描述 | 来源文件 | 重要性 |
|------|------|---------|--------|
| [06A_Physics_Introduction.md](06A_Physics_Introduction.md) | **物理系统概述** - 碰撞对象类型、碰撞形状、碰撞层与掩码、物理处理回调 | `physics_introduction.rst` | 🔴 必读 |
| [06B_CharacterBody2D.md](06B_CharacterBody2D.md) | **CharacterBody2D 详解** - 移动与碰撞、move_and_collide、move_and_slide | `using_character_body_2d.rst` | 🔴 必读 |
| [06E_RigidBody.md](06E_RigidBody.md) | **刚体物理** - 刚体控制、_integrate_forces、常用操作 | `rigid_body.rst` | 🔴 必读 |
| [06F_Area2D.md](06F_Area2D.md) | **Area2D 使用指南** - 重叠检测、区域影响、物理覆盖 | `using_area_2d.rst` | 🔴 必读 |
| [06G_RayCasting.md](06G_RayCasting.md) | **射线检测** - 物理空间访问、射线查询、形状查询 | `ray-casting.rst` | 🔴 必读 |

**文档总数**: 5 份  
**总字数**: ~35,000+

---

## 📖 核心内容概览

### 1. 碰撞对象类型

Godot 提供四种碰撞对象，都继承自 `CollisionObject2D`：

| 类型 | 说明 | 用途 |
|------|------|------|
| `Area2D` | 检测和影响 | 检测重叠、修改物理属性 |
| `StaticBody2D` | 静态物体 | 墙壁、平台、传送带 |
| `RigidBody2D` | 刚体 | 受物理引擎控制的物体 |
| `CharacterBody2D` | 角色物体 | 玩家控制的角色 |

### 2. 碰撞层与掩码

- **collision_layer**: 物体所在的层（"我在哪里"）
- **collision_mask**: 物体检测的层（"我检测谁"）

每个物体有 32 个物理层可用。

### 3. 物理处理回调

物理引擎以固定速率运行（默认 60Hz），使用 `_physics_process` 回调：

```gdscript
func _physics_process(delta):
    # 物理相关代码放在这里
    velocity.y += gravity * delta
    move_and_slide()
```

> **踩坑点**: 物理代码必须放在 `_physics_process` 中，而不是 `_process`。

### 4. CharacterBody2D vs RigidBody2D

| 特性 | CharacterBody2D | RigidBody2D |
|------|-----------------|-------------|
| 运动控制 | 代码控制 | 物理引擎 |
| 碰撞响应 | 手动处理 | 自动处理 |
| 适用场景 | 玩家角色、NPC | 抛射物、箱子、球 |
| 重力 | 手动计算 | 自动应用 |

---

## 🔗 Wiki 层映射

本目录文档已整合到 Wiki 层，生成以下页面：

### 概念页面 (concepts/)

- [physics-intro.md](../../wiki/concepts/physics-intro.md) - 物理系统介绍（来源：06A）
- [characterbody2d-concept.md](../../wiki/concepts/characterbody2d-concept.md) - CharacterBody2D 概念（来源：06B）
- [rigidbody2d-concept.md](../../wiki/concepts/rigidbody2d-concept.md) - 刚体概念（来源：06E）
- [area2d-concept.md](../../wiki/concepts/area2d-concept.md) - Area2D 概念（来源：06F）

### 指南页面 (guides/)

- [raycasting-guide.md](../../wiki/guides/raycasting-guide.md) - 射线投射指南（来源：06G）

---

## 📊 统计信息

| 分类 | 文档数 | 字数估算 | Wiki 映射 | 完成度 |
|------|--------|---------|----------|--------|
| 物理系统 | 5 | ~35,000+ | 5 个页面 | ✅ 100% |

---

## 💡 使用建议

### 新手路径

```
1. [06A_Physics_Introduction.md](06A_Physics_Introduction.md) - 了解物理系统概述
   ↓
2. [06B_CharacterBody2D.md](06B_CharacterBody2D.md) - 学习角色控制
   ↓
3. [Wiki 层 - CharacterBody2D 概念](../../wiki/concepts/characterbody2d-concept.md) - 查看摘要
```

### 进阶路径

```
1. [06E_RigidBody.md](06E_RigidBody.md) - 学习刚体物理
   ↓
2. [06G_RayCasting.md](06G_RayCasting.md) - 学习射线检测
   ↓
3. [Wiki 层 - 射线投射指南](../../wiki/guides/raycasting-guide.md) - 查看实战应用
```

---

## ⚠️ 常见踩坑

1. **不要直接修改 position**: 使用 `velocity` + `move_and_slide()`
2. **物理代码位置**: 必须放在 `_physics_process()` 中
3. **碰撞形状缩放**: 形状的 Scale 必须保持 (1, 1)
4. **RigidBody 控制**: 使用 `_integrate_forces` 而不是直接设置速度

详见：[常见踩坑避雷](../../wiki/guides/common-pitfalls.md)

---

## 📝 更新策略

- **Base 层**: 保持原始文档不变，作为 immutable 信息源
- **Wiki 层**: 根据 Base 层内容生成摘要和整合页面
- **交叉引用**: 确保所有 Wiki 页面都有 Base 层来源引用

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.6
