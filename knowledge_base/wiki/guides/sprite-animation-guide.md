# Sprite 动画指南

> **来源**: [05D_Sprite_Animation.md](../../base/2d-development/05D_Sprite_Animation.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本指南介绍 Godot 4.x 中实现 2D 精灵动画的两种主要方式：AnimatedSprite2D 和 AnimationPlayer + Sprite2D。

---

## 🎬 精灵动画概述

### 动画资源格式

通常有两种方式提供动画素材：
- **独立图片**: 每帧一张图片
- **Sprite Sheet**: 单张图片包含所有帧

### 两种实现方式对比

| 方式 | 节点 | 适用场景 |
|------|------|----------|
| **AnimatedSprite2D** | 简单、快速 | 角色移动动画、简单动画 |
| **AnimationPlayer + Sprite2D** | 复杂、灵活 | 需要混合多个属性、复杂动画序列 |

---

## 🖼️ AnimatedSprite2D 方式

### 设置步骤

1. **创建节点树**
   - 根节点可以是 CharacterBody2D/Area2D/RigidBody2D
   - 添加 AnimatedSprite2D 作为子节点

2. **创建 SpriteFrames 资源**
   - 选择 AnimatedSprite2D 节点
   - 在 SpriteFrames 属性中点击 "New SpriteFrames"

3. **添加动画帧**
   - 从文件系统拖拽帧图片到 SpriteFrames 面板
   - 修改动画名称（如从 "default" 改为 "run"）
   - 调整 Speed (FPS)（如设为 10）

4. **添加多段动画**
   - 点击 "Add Animation" 按钮
   - 创建 idle（待机）、run（奔跑）、jump（跳跃）、attack（攻击）等动画

### 代码控制

```gdscript
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

func _process(_delta):
    if Input.is_action_pressed("ui_right"):
        animated_sprite.play("run")
        # 可选：设置播放方向
        animated_sprite.flip_h = false
    else:
        animated_sprite.stop()
        # 或切换到其他动画
        animated_sprite.play("idle")

# 检查当前动画
if animated_sprite.animation == "run":
    pass
```

### 常用方法

| 方法 | 说明 |
|------|------|
| `play(anim)` | 播放指定动画 |
| `stop()` | 停止动画 |
| `pause()` | 暂停动画 |
| `is_playing()` | 是否正在播放 |
| `get_animation()` | 获取当前动画名 |

---

## 🎭 AnimationPlayer + Sprite2D 方式

### 设置步骤

1. **添加节点**
   - 添加 Sprite2D 节点
   - 添加 AnimationPlayer 节点作为子节点

2. **创建动画**
   - 选择 AnimationPlayer 节点
   - 点击 "Animation" 标签页
   - 点击 "New" 创建新动画

3. **设置关键帧**
   - 在时间轴上选择位置
   - 修改 Sprite2D 的 Texture 和 Frame 属性
   - 点击属性旁边的钥匙图标添加关键帧

4. **Sprite Sheet 配置**
   ```gdscript
   # Sprite2D 节点属性
   h_frames = 6    # 水平帧数
   v_frames = 1    # 垂直帧数
   frame = 0       # 当前帧
   ```

### 代码控制

```gdscript
@onready var animation_player = $AnimationPlayer

func play_run():
    animation_player.play("run")

func stop_animation():
    animation_player.stop()

func blend_to_idle():
    animation_player.play("idle", -1, 2.0)  # 2 秒过渡

# 连接信号
func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
    if anim_name == "attack":
        animation_player.play("idle")
```

### 常用方法

| 方法 | 说明 |
|------|------|
| `play(anim)` | 播放指定动画 |
| `stop()` | 停止动画 |
| `pause()` | 暂停动画 |
| `is_playing()` | 是否正在播放 |
| `get_current_animation()` | 获取当前动画名 |
| `seek(position)` | 跳转到指定时间 |
| `advance(delta)` | 前进指定时间 |

---

## 🎨 高级技巧

### 动画混合

使用 AnimationPlayer 实现动画混合：

```gdscript
# 在两个动画之间平滑过渡
animation_player.play("idle", -1, 1.5)  # 1.5 秒过渡

# 使用 AnimationTree 实现更复杂的混合
```

### 使用 AnimationTree

```gdscript
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _process(delta):
    var velocity = velocity
    if velocity.length() > 0:
        state_machine.travel("run")
    else:
        state_machine.travel("idle")
```

### 帧事件

在动画中触发事件：

```gdscript
# 在 AnimationPlayer 中添加 call 轨道
# 在特定帧调用函数

func on_footstep():
    # 播放脚步声
    $FootstepSound.play()

func on_attack():
    # 触发攻击判定
    check_hit()
```

### 程序化动画

```gdscript
# 动态创建动画
func create_animation():
    var animation = Animation.new()
    var sprite = $Sprite2D
    
    # 添加帧
    for i in range(10):
        animation.track_insert(0)
        animation.track_set_type(0, Animation.TYPE_VALUE)
        animation.track_set_path(0, "texture")
        
        var frame_texture = load("res://assets/frame_%d.png" % i)
        animation.track_insert_key(0, i * 0.1, frame_texture)
    
    $AnimationPlayer.add_animation("custom", animation)
```

---

## ⚠️ 常见踩坑

### 踩坑 1: 动画不播放

**可能原因**:
1. AnimatedSprite2D 没有设置 SpriteFrames 资源
2. 动画名称拼写错误
3. 动画长度为 0

**检查清单**:
- [ ] SpriteFrames 资源已创建并赋值
- [ ] 动画名称正确
- [ ] 动画有帧数据

### 踩坑 2: 动画循环问题

**问题**: 动画播放一次后停止

**解决方案**:
```gdscript
# 设置动画循环
animated_sprite.animation = "run"
animated_sprite.autoplay = "run"  # 自动播放

# 或在 SpriteFrames 中设置 loop 选项
```

### 踩坑 3: 性能问题

**问题**: 大量 AnimatedSprite2D 导致性能下降

**解决方案**:
1. 使用 GPU 粒子替代部分动画
2. 合并 Sprite Sheet 减少 Draw Call
3. 使用对象池管理动画节点
4. 降低远处角色的动画 FPS

---

## 🔗 相关链接

### 前置知识
- [2D 开发介绍](../concepts/2d-development-intro.md) - Sprite2D 基础
- [2D 移动指南](2d-movement-guide.md) - 配合移动动画
- [AnimationPlayer 概念](../concepts/animation-player.md) - 动画播放器详解

### 后续学习
- [2D 粒子系统指南](particles-2d-guide.md) - 特效动画
- [自定义 2D 绘制指南](custom-drawing-2d-guide.md) - 程序化动画

### Base 层来源
- [05D_Sprite_Animation.md](../../base/2d-development/05D_Sprite_Animation.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
