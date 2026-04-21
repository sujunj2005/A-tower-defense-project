# 2D 动画制作实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 11A_Animation_Player.md](../../base/animation-system/11A_Animation_Player.md), [11C_2D_Skeletons.md](../../base/animation-system/11C_2D_Skeletons.md)  
> **重要性**: 🔴 必读 - 2D 动画制作完整流程

---

## 📋 概述

本指南涵盖 2D 动画制作的完整流程，从基础的关键帧动画到高级的骨骼动画。适用于角色动画、UI 动画、特效动画等各种场景。

---

## 🎯 动画类型选择

### 1. 关键帧动画（AnimationPlayer）

**适用场景**：
- UI 动画（淡入淡出、移动）
- 简单的 Sprite 动画
- 属性动画（颜色、缩放、旋转）
- 程序化动画

**优势**：
- 精确控制每个关键帧
- 可以动画化任何属性
- 支持事件触发

### 2. 帧动画（AnimatedSprite2D）

**适用场景**：
- 像素角色动画
- 简单特效（爆炸、烟雾）
- 导入的精灵表

**优势**：
- 简单易用
- 适合逐帧动画
- 资源管理方便

### 3. 骨骼动画（Skeleton2D）

**适用场景**：
- 复杂角色动画
- 需要 IK（反向运动学）
- 动态换装系统

**优势**：
- 动画复用性高
- 支持 IK/FK
- 程序化控制

---

## 🔧 制作流程

### 流程 1：关键帧动画

**步骤 1：准备场景**
```
角色节点结构：
Character (Node2D)
├─ Sprite2D
├─ AnimationPlayer
└─ CollisionShape2D
```

**步骤 2：创建动画**
1. 选择 AnimationPlayer
2. 点击 "Animation" → "New"
3. 命名动画（如 "idle"）
4. 设置 FPS（推荐 12 或 60）

**步骤 3：录制关键帧**
1. 点击录制按钮（红点）
2. 移动时间线到 0:00
3. 设置初始姿势
4. 移动到下一帧（如 0:05）
5. 修改属性（位置、旋转等）
6. 自动创建关键帧

**步骤 4：调整插值**
```gdscript
# 在动画资源中设置插值模式
# 线性插值：匀速运动
track_set_interpolation(track_idx, Animation.INTERPOLATION_LINEAR)

# 三次插值：平滑加减速
track_set_interpolation(track_idx, Animation.INTERPOLATION_CUBIC)

# 常数插值：阶梯变化（帧动画）
track_set_interpolation(track_idx, Animation.INTERPOLATION_CONSTANT)
```

### 流程 2：帧动画（AnimatedSprite2D）

**步骤 1：准备精灵表**
- 确保所有帧大小一致
- 使用统一的间距
- 导出为 PNG 序列或精灵表

**步骤 2：创建 SpriteFrames 资源**
1. 选择 AnimatedSprite2D
2. 点击 "SpriteFrames" 面板
3. 新建动画（如 "walk"）
4. 拖入帧图片

**步骤 3：配置动画**
```gdscript
# 设置帧率
$AnimatedSprite2D.sprite_frames.set_animation_speed("walk", 12)

# 设置循环
$AnimatedSprite2D.sprite_frames.set_animation_loop("walk", true)

# 播放动画
$AnimatedSprite2D.play("walk")

# 停止在特定帧
$AnimatedSprite2D.stop()
$AnimatedSprite2D.frame = 5
```

### 流程 3：骨骼动画

**步骤 1：创建骨骼链**
```
Character (Node2D)
├─ Skeleton2D
│  ├─ Bone2D (根骨骼)
│  │  └─ Bone2D (上臂)
│  │     └─ Bone2D (前臂)
│  │        └─ Bone2D (手)
├─ Sprite2D (使用骨骼绑定)
└─ AnimationPlayer
```

**步骤 2：绑定骨骼到 Sprite**
1. 选择 Skeleton2D
2. 点击 "骨骼" 工作区
3. 创建骨骼链
4. 使用 "创建顶点" 工具绘制蒙皮
5. 使用 "绘制权重" 工具调整权重

**步骤 3：创建动画**
```gdscript
# 骨骼动画使用 AnimationPlayer
# 轨道路径示例：
"Skeleton2D:Bones/Bone2D:position"
"Skeleton2D:Bones/Bone2D:rotation"
"Skeleton2D:Bones/Bone2D:scale"
```

---

## 🎨 高级技巧

### 1. 动画混合

```gdscript
# 设置混合时间
$AnimationPlayer.default_blend_time = 0.2

# 播放时混合
$AnimationPlayer.play("run")  # 0.2 秒内混合到 run 动画
```

### 2. 动画事件

在方法调用轨道添加事件：
```gdscript
# 动画中调用
func on_footstep():
    $FootstepAudio.play()
    create_dust_effect()

func on_attack_hit():
    deal_damage()
    camera_shake()
```

### 3. 程序化动画

```gdscript
# 动态修改关键帧
func modify_animation():
    var anim = $AnimationPlayer.get_animation("walk")
    var track = anim.find_track("Sprite2D:position")
    
    # 修改第 2 个关键帧
    anim.track_set_key_value(track, 1, Vector2(100, 0))

# 动态创建动画
func create_dynamic_animation():
    var anim = Animation.new()
    anim.length = 1.0
    
    var track = anim.add_track(Animation.TYPE_VALUE)
    anim.track_set_path(track, "Sprite2D:modulate")
    
    anim.track_insert_key(track, 0.0, Color.WHITE)
    anim.track_insert_key(track, 0.5, Color.RED)
    anim.track_insert_key(track, 1.0, Color.WHITE)
    
    $AnimationPlayer.add_animation("flash", anim)
```

### 4. 动画状态机

```gdscript
extends CharacterBody2D

enum State { IDLE, WALK, RUN, JUMP }
var current_state: State = State.IDLE

@onready var anim_player = $AnimationPlayer

func _physics_process(delta):
    var new_state = determine_state()
    
    if new_state != current_state:
        transition_to_state(new_state)
    
    current_state = new_state

func determine_state() -> State:
    if velocity.length() == 0:
        return State.IDLE
    elif velocity.length() < 100:
        return State.WALK
    else:
        return State.RUN

func transition_to_state(new_state: State):
    match new_state:
        State.IDLE:
            anim_player.play("idle")
        State.WALK:
            anim_player.play("walk")
        State.RUN:
            anim_player.play("run")
```

---

## ⚠️ 常见踩坑

### 1. 动画卡顿

**原因**：
- FPS 设置过低
- 关键帧太少
- 插值模式错误

**解决方案**：
- 设置合理 FPS（12-60）
- 增加关键帧密度
- 使用正确的插值模式

### 2. 动画不同步

**问题**：动画和动作不同步

**解决方案**：
```gdscript
# 使用动画事件标记关键时间点
func on_attack_frame():
    # 在攻击命中帧调用
    deal_damage()

# 或使用 seek 精确控制
$AnimationPlayer.seek(0.3)  # 跳转到特定帧
```

### 3. 内存优化

**问题**：动画资源占用过多内存

**解决方案**：
- 复用动画资源
- 使用 AnimationLibrary 组织动画
- 卸载不用的动画

---

## 📊 性能优化

### 1. 减少关键帧数量

只保留必要的关键帧，删除冗余帧。

### 2. 使用 LOD 动画

```gdscript
func update_animation_lod(distance: float):
    if distance > 100:
        $AnimationPlayer.speed_scale = 0.5  # 降低更新频率
    else:
        $AnimationPlayer.speed_scale = 1.0
```

### 3. 缓存动画引用

```gdscript
# ✅ 正确
var idle_anim: Animation = $AnimationPlayer.get_animation("idle")

# ❌ 错误（每次都查找）
func _process(delta):
    $AnimationPlayer.get_animation("idle")
```

---

## 🔗 相关资源

### Base 层
- [11A_Animation_Player.md](../../base/animation-system/11A_Animation_Player.md) - AnimationPlayer 详解
- [11C_2D_Skeletons.md](../../base/animation-system/11C_2D_Skeletons.md) - 2D 骨骼系统
- [11D_Cutout_Animation.md](../../base/animation-system/11D_Cutout_Animation.md) - 剪裁动画

### Wiki 层
- [AnimationPlayer 核心概念](../concepts/animation-player.md) - AnimationPlayer 概念
- [AnimationTree 核心概念](../concepts/animation-tree.md) - AnimationTree 概念
- [Sprite 动画指南](../guides/sprite-animation-guide.md) - AnimatedSprite2D 基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
