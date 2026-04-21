# Godot 4.x 音频系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/audio/audio_buses.rst

---

## 目录

1. [音频系统概述](#1-音频系统概述)
2. [分贝刻度](#2-分贝刻度)
3. [音频总线](#3-音频总线)
4. [添加效果](#4-添加效果)
5. [音频播放节点](#5-音频播放节点)

---

## 1. 音频系统概述

### 1.1 设计目标

Godot 的音频引擎专为游戏设计，在性能和音质之间取得最佳平衡。

### 1.2 主要特性

- 任意数量的音频总线
- 每个总线可添加多个效果处理器
- 灵活的路由系统

---

## 2. 分贝刻度

### 2.1 基本概念

Godot 使用分贝（dB）刻度，符合音频专业标准：

- 分贝是**相对刻度**，表示功率比
- 每 **6 dB**，振幅翻倍或减半
- **0 dB** 是数字音频系统的最大振幅
- **-60 dB 到 -80 dB** 被认为听不见

### 2.2 常用分贝值

| dB 值 | 振幅比例 |
|-------|----------|
| 0 dB | 100%（最大） |
| -6 dB | 50% |
| -12 dB | 25% |
| -18 dB | 12.5% |
| -20 dB | 10% |
| -40 dB | 1% |

> **踩坑点**：分贝刻度无法表示真正的零（静音）。使用线性音量时，0.0 才是静音。

### 2.3 分贝与线性转换

```gdscript
# 线性转分贝
var db = linear_to_db(0.5)  # 约 -6 dB

# 分贝转线性
var linear = db_to_linear(-6)  # 约 0.5
```

---

## 3. 音频总线

### 3.1 什么是音频总线

音频总线（Audio Bus）是音频数据传输和处理的通道：

- 可以修改音频数据
- 可以重新路由音频
- 有 VU 表显示信号幅度

### 3.2 Master 总线

- 最左侧的总线
- 输出到扬声器
- 确保混音不超过 0 dB

### 3.3 路由规则

- 音频从右向左流动
- 避免无限循环
- 每个非 Master 总线可指定目标总线

```
[Bus 2] → [Bus 1] → [Master] → 扬声器
```

### 3.4 通过总线播放音频

```gdscript
@onready var audio_player = $AudioStreamPlayer

func _ready():
    audio_player.bus = "SFX"  # 指定总线
    audio_player.play()
```

---

## 4. 添加效果

### 4.1 效果类型

| 效果 | 说明 |
|------|------|
| `Amplify` | 放大音量 |
| `BandLimitFilter` | 带限滤波器 |
| `BandPassFilter` | 带通滤波器 |
| `Capture` | 音频捕获 |
| `Chorus` | 合唱效果 |
| `Compressor` | 压缩器 |
| `Delay` | 延迟效果 |
| `Distortion` | 失真效果 |
| `EQ` | 均衡器 |
| `HardLimiter` | 硬限制器 |
| `HighPassFilter` | 高通滤波器 |
| `LowPassFilter` | 低通滤波器 |
| `NotchFilter` | 陷波滤波器 |
| `Panner` | 声像控制 |
| `Phaser` | 相位效果 |
| `PitchShift` | 变调 |
| `Reverb` | 混响 |
| `SpectrumAnalyzer` | 频谱分析 |
| `StereoEnhance` | 立体声增强 |

### 4.2 代码添加效果

```gdscript
var bus_idx = AudioServer.get_bus_index("SFX")
var reverb = AudioEffectReverb.new()
reverb.room_size = 0.8
reverb.damping = 0.5
AudioServer.add_bus_effect(bus_idx, reverb)
```

### 4.3 自动禁用

当总线静默几秒后，Godot 自动禁用它（包括所有效果）以节省性能。

---

## 5. 音频播放节点

### 5.1 AudioStreamPlayer

用于播放非位置音频（背景音乐、UI 音效）：

```gdscript
@onready var music_player = $AudioStreamPlayer

func _ready():
    music_player.stream = preload("res://music.ogg")
    music_player.volume_db = -10  # 降低 10 dB
    music_player.play()
```

### 5.2 AudioStreamPlayer2D

用于 2D 位置音频：

```gdscript
@onready var sfx = $AudioStreamPlayer2D

func play_explosion():
    sfx.stream = preload("res://explosion.wav")
    sfx.volume_db = -5
    sfx.play()
```

### 5.3 AudioStreamPlayer3D

用于 3D 位置音频：

```gdscript
@onready var footstep = $AudioStreamPlayer3D

func _physics_process(_delta):
    if is_moving and not footstep.playing:
        footstep.play()
```

### 5.4 节点对比

| 节点 | 用途 | 特点 |
|------|------|------|
| `AudioStreamPlayer` | BGM、UI 音效 | 无位置 |
| `AudioStreamPlayer2D` | 2D 音效 | 跟随 2D 位置 |
| `AudioStreamPlayer3D` | 3D 音效 | 跟随 3D 位置，支持衰减 |

---

## 6. 代码控制音频

### 6.1 播放控制

```gdscript
# 播放
audio_player.play()

# 停止
audio_player.stop()

# 暂停（通过设置 stream_paused）
audio_player.stream_paused = true

# 检查是否正在播放
if audio_player.playing:
    pass
```

### 6.2 音量控制

```gdscript
# 分贝音量
audio_player.volume_db = -10

# 线性音量（0.0 - 1.0）
var linear_volume = 0.5
audio_player.volume_db = linear_to_db(linear_volume)
```

### 6.3 淡入淡出

```gdscript
var tween: Tween

func fade_in(duration: float):
    audio_player.volume_db = -60
    audio_player.play()
    tween = create_tween()
    tween.tween_property(audio_player, "volume_db", 0.0, duration)

func fade_out(duration: float):
    tween = create_tween()
    tween.tween_property(audio_player, "volume_db", -60.0, duration)
    tween.tween_callback(audio_player.stop)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/audio/audio_buses.rst`
