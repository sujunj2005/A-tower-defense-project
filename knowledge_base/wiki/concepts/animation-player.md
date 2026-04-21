# AnimationPlayer 核心概念

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 11A_Animation_Player.md](../../base/animation-system/11A_Animation_Player.md)  
> **重要性**: 🔴 必读 - 动画系统基础

---

## 📋 概述

AnimationPlayer 是 Godot 中最强大的动画工具，可以动画化几乎任何属性。它基于关键帧系统，支持复杂的动画序列和混合。

---

## 🎯 核心概念

### 1. 动画资源（Animation Resource）

AnimationPlayer 存储和管理 Animation 资源，每个资源包含：
- **轨道（Tracks）**: 用于动画化不同属性的时间线
- **关键帧（Keyframes）**: 在特定时间点定义属性值
- **时长（Length）**: 动画的总时长（秒）

### 2. 轨道系统

**支持的轨道类型**：
- **属性轨道**: 动画化节点属性（位置、旋转、缩放等）
- **值轨道**: 动画化自定义值
- **方法调用轨道**: 在特定时间点调用函数
- **贝塞尔曲线轨道**: 使用曲线控制动画
- **音频轨道**: 播放音频流
- **动画轨道**: 控制其他 AnimationPlayer

**轨道路径示例**：
```
"Sprite2D:modulate"          # 颜色调制
"Position2D:position"        # 位置
"AudioStreamPlayer:volume_db" # 音量
```

### 3. 关键帧插值

Godot 支持多种插值模式：
- **线性插值**: 匀速变化
- **三次插值**: 平滑加减速
- **常数插值**: 阶梯式变化（不插值）
- **贝塞尔曲线插值**: 自定义曲线控制

---

## 🔧 使用方法

### 创建动画

**方法 1：使用动画面板**
1. 选择节点并添加 AnimationPlayer
2. 打开底部动画面板
3. 点击 "Animation" → "New"
4. 命名动画（如 "walk"）
5. 点击录制按钮（红点）
6. 移动时间线，修改属性，自动创建关键帧

**方法 2：代码创建**
```gdscript
var anim = Animation.new()
anim.length = 2.0

# 添加位置轨道
var track_idx = anim.add_track(Animation.TYPE_VALUE)
anim.track_set_path(track_idx, "Sprite2D:position")
anim.track_set_interpolation(track_idx, Animation.INTERPOLATION_LINEAR)

# 添加关键帧
anim.track_insert_key(track_idx, 0.0, Vector2(0, 0))
anim.track_insert_key(track_idx, 1.0, Vector2(100, 0))
anim.track_insert_key(track_idx, 2.0, Vector2(0, 0))

# 添加到 AnimationPlayer
$AnimationPlayer.add_animation("move", anim)
```

### 播放动画

```gdscript
# 播放动画
$AnimationPlayer.play("walk")

# 播放并循环
$AnimationPlayer.play("walk", Animation.LOOP_ALL)

# 从指定时间播放
$AnimationPlayer.seek(0.5)
$AnimationPlayer.play("walk")

# 反向播放
$AnimationPlayer.play_backwards("walk")

# 停止动画
$AnimationPlayer.stop()

# 检查是否正在播放
if $AnimationPlayer.is_playing():
    print("动画正在播放")

# 获取当前动画名称
var current_anim = $AnimationPlayer.current_animation
```

### 动画混合

```gdscript
# 设置混合时间
$AnimationPlayer.animation_changed.connect(
    func(): $AnimationPlayer.default_blend_time = 0.3
)

# 播放时自动混合
$AnimationPlayer.play("run")  # 0.3 秒内从当前动画混合到 run
```

---

## 🎨 高级功能

### 1. 动画事件（方法调用轨道）

在特定时间点触发函数：
```gdscript
# 在动画中添加了方法调用轨道
func on_footstep():
    # 播放脚步声
    $FootstepAudio.play()

func on_attack():
    # 造成伤害判定
    deal_damage()
```

### 2. 嵌套动画

使用动画轨道控制其他 AnimationPlayer：
```
AnimationPlayer (主)
├─ 播放 "walk_cycle"
└─ 动画轨道 → 控制 AnimationPlayer (手臂)
    └─ 播放 "arm_swing"
```

### 3. 程序化动画

```gdscript
# 动态修改关键帧
var track_idx = $AnimationPlayer.get_animation("move").find_track(
    "Sprite2D:position"
)
$AnimationPlayer.get_animation("move").track_set_key_value(
    track_idx, 0, Vector2(100, 0)
)

# 动态创建动画
func create_procedural_animation():
    var anim = Animation.new()
    anim.length = 5.0
    # ... 动态生成关键帧
    $AnimationPlayer.add_animation("procedural", anim)
```

---

## ⚠️ 常见踩坑

### 1. 动画不播放

**问题**：调用了 play() 但动画不播放

**原因**：
- 动画长度为 0
- 没有关键帧
- 节点被禁用

**解决方案**：
```gdscript
# 检查动画是否存在
if $AnimationPlayer.has_animation("walk"):
    $AnimationPlayer.play("walk")
else:
    print("动画不存在！")

# 检查动画长度
var anim = $AnimationPlayer.get_animation("walk")
if anim.length > 0:
    $AnimationPlayer.play("walk")
```

### 2. 关键帧不精确

**问题**：关键帧位置不准确

**解决方案**：
- 使用吸附功能（磁铁图标）
- 手动输入时间值
- 使用缩放工具精确调整

### 3. 动画切换生硬

**问题**：动画切换时跳跃明显

**解决方案**：
```gdscript
# 设置混合时间
$AnimationPlayer.default_blend_time = 0.2

# 或使用 fade 参数
$AnimationPlayer.play("run", Animation.LOOP_ALL, 0.2)
```

---

## 📊 性能优化

### 1. 减少轨道数量

只动画化必要的属性，避免过度动画化。

### 2. 使用 LOD 动画

远距离使用简化动画：
```gdscript
func update_animation_lod(distance: float):
    if distance > 50:
        $AnimationPlayer.speed_scale = 0.5  # 降低更新频率
    else:
        $AnimationPlayer.speed_scale = 1.0
```

### 3. 缓存动画引用

```gdscript
# ❌ 错误：每次都查找
func _process(delta):
    $AnimationPlayer.get_animation("walk")

# ✅ 正确：缓存引用
var walk_anim: Animation

func _ready():
    walk_anim = $AnimationPlayer.get_animation("walk")
```

---

## 🔗 相关资源

### Base 层
- [11A_Animation_Player.md](../../base/animation-system/11A_Animation_Player.md) - AnimationPlayer 详解
- [11B_Animation_Tree.md](../../base/animation-system/11B_Animation_Tree.md) - AnimationTree 动画树

### Wiki 层
- [动画制作实战指南](../guides/2d-animation-guide.md) - 2D 动画制作指南
- [Sprite 动画指南](../guides/sprite-animation-guide.md) - Sprite 动画基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
