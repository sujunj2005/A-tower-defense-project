# 剪裁动画制作指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 11D_Cutout_Animation.md](../../base/animation-system/11D_Cutout_Animation.md)  
> **重要性**: 🟡 推荐 - 2D 角色动画高级技术

---

## 📋 概述

剪裁动画（Cutout Animation）是一种将角色拆分为多个部件，然后通过骨骼或关键帧动画组合的技术。这种方法可以复用动画，支持动态换装，是 2D 游戏角色动画的主流方案。

---

## 🎯 核心概念

### 1. 部件拆分

将角色拆分为独立的可动画部件：
- **头部**: 头、头发、面部特征
- **身体**: 躯干、脖子
- **手臂**: 上臂、前臂、手
- **腿部**: 大腿、小腿、脚
- **装备**: 武器、盔甲、饰品

### 2. 绑定方式

**方式 1：骨骼绑定（推荐）**
```
Skeleton2D
├─ Bone2D (根)
│  ├─ Bone2D (躯干)
│  │  ├─ Bone2D (头)
│  │  ├─ Bone2D (上臂.L)
│  │  │  └─ Bone2D (前臂.L)
│  │  └─ Bone2D (上臂.R)
│  │     └─ Bone2D (前臂.R)
│  └─ Bone2D (大腿)
```

**方式 2：节点层级**
```
Character (Node2D)
├─ Body (Sprite2D)
├─ Head (Sprite2D)
├─ Arm_L (Sprite2D)
└─ Arm_R (Sprite2D)
```

### 3. 蒙皮权重

每个顶点可以受多个骨骼影响，权重决定影响程度。

---

## 🔧 制作流程

### 步骤 1：准备部件

**图片要求**：
- PNG 格式，透明背景
- 所有部件统一分辨率
- 部件中心点对齐关节位置
- 重叠区域足够（避免裂缝）

**示例目录结构**：
```
characters/
└─ hero/
   ├─ body.png
   ├─ head.png
   ├─ arm_upper_l.png
   ├─ arm_lower_l.png
   ├─ arm_upper_r.png
   └─ arm_lower_r.png
```

### 步骤 2：创建骨骼

1. 添加 Skeleton2D 节点
2. 进入 "骨骼" 工作区
3. 使用 "创建骨骼" 工具
4. 从根骨骼开始，逐级创建子骨骼
5. 调整骨骼位置和角度

### 步骤 3：绑定部件

**方法 1：自动绑定**
1. 选择 Skeleton2D
2. 点击 "创建顶点"
3. 在 Sprite 上绘制多边形
4. 自动分配到最近的骨骼

**方法 2：手动绑定**
1. 选择 Sprite2D
2. 添加 Polygon2D 子节点
3. 绘制多边形
4. 在 "顶点" 面板分配权重

### 步骤 4：绘制权重

1. 选择 Skeleton2D
2. 点击 "绘制权重" 工具
3. 选择骨骼
4. 在顶点上绘制权重（红色=100%, 蓝色=0%）

### 步骤 5：创建动画

```gdscript
# 使用 AnimationPlayer 创建动画
# 轨道路径示例：
"Skeleton2D:Bones/Arm_L:rotation"
"Skeleton2D:Bones/Head:position"
```

---

## 🎨 高级技巧

### 1. IK（反向运动学）

```gdscript
# 添加 CCIK3D 或 FABRIK3D 节点
# 用于自动调整骨骼链

# 示例：手臂 IK
var ik: CC IK3D = $Skeleton2D/Arm_L/CCIK3D
ik.target_position = enemy_position  # 手自动伸向敌人
```

### 2. 动态换装

```gdscript
# 运行时切换部件
func change_armor(new_armor_texture: Texture2D):
    $ArmorSprite.texture = new_armor_texture

# 或添加/移除部件
func equip_weapon(weapon_scene: PackedScene):
    if current_weapon:
        current_weapon.queue_free()
    current_weapon = weapon_scene.instantiate()
    $Hand.add_child(current_weapon)
```

### 3. 程序化动画

```gdscript
# 动态调整骨骼
func look_at_target(target: Vector2):
    var head_bone = $Skeleton2D/Bones/Head
    head_bone.look_at(target)

# 呼吸动画
func breathing_animation():
    var breath = sin(Time.get_ticks_msec() / 500.0) * 2.0
    $Skeleton2D/Bones/Chest.position.y = breath
```

---

## ⚠️ 常见踩坑

### 1. 部件裂缝

**问题**：部件连接处出现裂缝

**解决方案**：
- 增加部件重叠区域
- 调整权重平滑过渡
- 使用法线贴图隐藏接缝

### 2. 权重绘制不均

**问题**：动画变形不自然

**解决方案**：
- 使用渐变权重（不要 0/1 跳变）
- 关节处权重平分（如肘部 50%/50%）
- 测试动画时调整权重

### 3. 骨骼顺序错误

**问题**：部件渲染顺序不对

**解决方案**：
- 调整骨骼 Z 索引
- 使用 CanvasLayer 分层渲染
- 手动设置 Sprite 的 z_index

---

## 📊 性能优化

### 1. 减少骨骼数量

只使用必要的骨骼，避免过度细分。

### 2. 合并静态部件

不动画化的部件合并到一个 Sprite。

### 3. LOD 系统

```gdscript
func update_lod(distance: float):
    if distance > 100:
        $Skeleton2D/Bones/Leg_R.visible = false  # 隐藏远端骨骼
    else:
        $Skeleton2D/Bones/Leg_R.visible = true
```

---

## 🔗 相关资源

### Base 层
- [11D_Cutout_Animation.md](../../base/animation-system/11D_Cutout_Animation.md) - 剪裁动画详解
- [11C_2D_Skeletons.md](../../base/animation-system/11C_2D_Skeletons.md) - 2D 骨骼系统

### Wiki 层
- [2D 动画制作指南](../guides/2d-animation-guide.md) - 完整 2D 动画流程
- [AnimationPlayer 概念](../concepts/animation-player.md) - AnimationPlayer 基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
