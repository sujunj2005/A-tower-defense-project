# Godot 4.x 2D 精灵动画

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/2d_sprite_animation.rst

---

## 目录

1. [精灵动画概述](#1-精灵动画概述)
2. [AnimatedSprite2D 方式](#2-animatedsprite2d-方式)
3. [AnimationPlayer + Sprite2D 方式](#3-animationplayer--sprite2d-方式)
4. [代码控制动画](#4-代码控制动画)

---

## 1. 精灵动画概述

### 1.1 动画资源格式

通常有两种方式提供动画素材：
- **独立图片**：每帧一张图片
- **Sprite Sheet**：单张图片包含所有帧

### 1.2 两种实现方式

| 方式 | 节点 | 适用场景 |
|------|------|----------|
| AnimatedSprite2D | 简单、快速 | 角色移动动画 |
| AnimationPlayer + Sprite2D | 复杂、灵活 | 需要混合多个属性 |

---

## 2. AnimatedSprite2D 方式

### 2.1 设置步骤

1. 创建节点树（根节点可以是 CharacterBody2D/Area2D/RigidBody2D）
2. 选择 `AnimatedSprite2D` 节点
3. 在 SpriteFrames 属性中点击 "New SpriteFrames"
4. 从文件系统拖拽帧图片到 SpriteFrames 面板
5. 修改动画名称（如从 "default" 改为 "run"）
6. 调整 Speed (FPS)（如设为 10）

### 2.2 添加多段动画

点击 "Add Animation" 按钮可添加新动画：
- idle（待机）
- run（奔跑）
- jump（跳跃）
- attack（攻击）

---

## 3. AnimationPlayer + Sprite2D 方式

### 3.1 设置步骤

1. 添加 Sprite2D 节点
2. 添加 AnimationPlayer 节点
3. 在 AnimationPlayer 中创建动画
4. 关键帧设置 Sprite2D 的 Texture 和 Frame 属性
5. 使用 HFrames/VFrames 切割 Sprite Sheet

### 3.2 Sprite Sheet 配置

```gdscript
# Sprite2D 节点属性
h_frames = 6    # 水平帧数
v_frames = 1    # 垂直帧数
frame = 0       # 当前帧
```

---

## 4. 代码控制动画

### 4.1 AnimatedSprite2D 控制

```gdscript
extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

func _process(_delta):
    if Input.is_action_pressed("ui_right"):
        _animated_sprite.play("run")
        # 可选：设置播放方向
        _animated_sprite.flip_h = false
    else:
        _animated_sprite.stop()
        # 或切换到其他动画
        _animated_sprite.play("idle")

# 检查当前动画
if _animated_sprite.animation == "run":
    pass
```

### 4.2 AnimationPlayer 控制

```gdscript
@onready var animation_player = $AnimationPlayer

func play_run():
    animation_player.play("run")

func stop_animation():
    animation_player.stop()

func blend_to_idle():
    animation_player.play("idle", -1, 2.0)  # 2秒过渡

# 连接信号
func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
    if anim_name == "attack":
        animation_player.play("idle")
```

### 4.3 常用方法

| 方法 | 说明 |
|------|------|
| `play(anim)` | 播放指定动画 |
| `stop()` | 停止动画 |
| `pause()` | 暂停动画 |
| `is_playing()` | 是否正在播放 |
| `get_animation()` | 获取当前动画名 |

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/2d/2d_sprite_animation.rst`
