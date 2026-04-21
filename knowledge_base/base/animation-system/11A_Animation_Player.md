# Godot 4.x 动画系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/animation/animation_player.rst

---

## 目录

1. [动画系统概述](#1-动画系统概述)
2. [AnimationPlayer 节点](#2-animationplayer-节点)
3. [创建动画](#3-创建动画)
4. [动画轨道](#4-动画轨道)
5. [代码控制动画](#5-代码控制动画)
6. [动画树](#6-动画树)

---

## 1. 动画系统概述

### 1.1 两种动画节点

| 节点 | 用途 |
|------|------|
| `AnimationPlayer` | 播放预定义动画 |
| `AnimationTree` | 复杂动画状态机 |

### 1.2 动画类型

- **属性动画**：修改节点属性（位置、颜色等）
- **精灵动画**：切换精灵帧
- **调用方法**：在特定时间调用函数

---

## 2. AnimationPlayer 节点

### 2.1 基本设置

```gdscript
@onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.play("idle")
```

### 2.2 常用属性

| 属性 | 说明 |
|------|------|
| `autoplay` | 自动播放的动画名 |
| `playback_process_mode` | 处理模式（物理/空闲） |
| `speed_scale` | 播放速度倍率 |

---

## 3. 创建动画

### 3.1 在编辑器中创建

1. 选择 AnimationPlayer 节点
2. 点击 Animation → New
3. 命名动画
4. 添加轨道和关键帧

### 3.2 代码创建动画

```gdscript
func create_animation():
    var anim = Animation.new()
    var track_index = anim.add_track(Animation.TYPE_VALUE)
    anim.track_set_path(track_index, "Sprite2D:position")
    
    # 添加关键帧
    anim.track_insert_key(track_index, 0.0, Vector2(0, 0))
    anim.track_insert_key(track_index, 1.0, Vector2(100, 0))
    
    # 设置动画长度
    anim.length = 1.0
    
    # 添加到 AnimationPlayer
    $AnimationPlayer.get_animation_library("").add_animation("move", anim)
```

---

## 4. 动画轨道

### 4.1 轨道类型

| 类型 | 说明 |
|------|------|
| `TYPE_VALUE` | 属性值动画 |
| `TYPE_TRANSFORM_3D` | 3D 变换 |
| `TYPE_METHOD` | 方法调用 |
| `TYPE_BEZIER` | 贝塞尔曲线 |
| `TYPE_AUDIO` | 音频播放 |
| `TYPE_ANIMATION` | 动画播放（嵌套） |

### 4.2 插值模式

| 模式 | 说明 |
|------|------|
| `INTERPOLATION_NEAREST` | 最近邻 |
| `INTERPOLATION_LINEAR` | 线性 |
| `INTERPOLATION_CUBIC` | 三次样条 |
| `INTERPOLATION_LINEAR_ANGLE` | 线性角度 |
| `INTERPOLATION_CUBIC_ANGLE` | 三次角度 |

### 4.3 循环模式

| 模式 | 说明 |
|------|------|
| `LOOP_NONE` | 不循环 |
| `LOOP_LINEAR` | 线性循环 |
| `LOOP_PINGPONG` | 来回循环 |

---

## 5. 代码控制动画

### 5.1 播放控制

```gdscript
# 播放动画
animation_player.play("walk")

# 停止动画
animation_player.stop()

# 暂停动画
animation_player.pause()

# 从指定位置播放
animation_player.play("walk", -1.0, 1.0, false, 0.5)  # 从 0.5 秒开始

# 反向播放
animation_player.play_backwards("walk")
```

### 5.2 播放参数

```gdscript
# play(name, custom_blend, speed, from_end, start_position)
animation_player.play("walk", -1.0, 2.0)  # 2 倍速播放
```

### 5.3 信号

```gdscript
func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
    print("动画结束：", anim_name)
```

### 5.4 混合动画

```gdscript
# 设置混合时间
animation_player.play("idle")
animation_player.play("walk", 0.5)  # 0.5 秒过渡
```

---

## 6. 动画树（AnimationTree）

> 📖 **详细文档见 [11B_Animation_Tree](11B_Animation_Tree.md)**，此处仅概述与 AnimationPlayer 的关系。

AnimationTree 是用于**复杂动画状态管理**的高级节点：

| 对比项 | AnimationPlayer | AnimationTree |
|--------|----------------|---------------|
| **适用场景** | 简单动画播放/切换 | 状态机、混合树、复杂过渡 |
| **active 属性** | 不需要 | **必须设为 true 才生效** |
| **参数控制** | play()/stop() | `set("parameters/path", value)` |
| **核心节点** | - | StateMachine / BlendTree / BlendSpace |

**快速使用**：
```gdscript
@onready var animation_tree = $AnimationTree

func _ready():
    animation_tree.active = true  # ⚠️ 必须启用！

# 状态机切换
var state_machine = animation_tree.get("parameters/playback")
state_machine.travel("run")

# 设置混合参数
animation_tree.set("parameters/blend_position", velocity.x)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/animation/animation_player.rst`
