# 音频流播放指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 12B_Audio_Streams.md](../../base/audio-system/12B_Audio_Streams.md)  
> **重要性**: 🔴 必读 - 音频播放完整指南

---

## 📋 概述

本指南涵盖 Godot 中音频流的导入、配置和播放方法，适用于背景音乐、音效、语音等各种音频场景。

---

## 🎯 音频节点

### 1. AudioStreamPlayer（2D）

用于 2D 空间音频，音量不随距离衰减。

```gdscript
# 播放音效
$AudioStreamPlayer.stream = preload("res://audio/sfx/jump.ogg")
$AudioStreamPlayer.play()

# 停止播放
$AudioStreamPlayer.stop()

# 检查播放状态
if $AudioStreamPlayer.playing:
    print("正在播放")
```

### 2. AudioStreamPlayer2D

用于 2D 空间音频，音量随距离衰减。

```gdscript
# 设置最大距离
$AudioStreamPlayer2D.max_distance = 500

# 设置衰减
$AudioStreamPlayer2D.attenuation = 1.0
```

### 3. AudioStreamPlayer3D

用于 3D 空间音频，支持立体声定位。

---

## 🔧 实战技巧

### 1. 音效池

```gdscript
# 音效管理器
class_name SoundManager
extends Node

var sfx_pool: Array[AudioStreamPlayer] = []

func _ready():
    # 创建音效池
    for i in range(8):
        var player = AudioStreamPlayer.new()
        add_child(player)
        sfx_pool.append(player)

func play_sfx(stream: AudioStream):
    # 找到空闲的播放器
    for player in sfx_pool:
        if not player.playing:
            player.stream = stream
            player.play()
            return
    
    # 池已满，创建新播放器
    var player = AudioStreamPlayer.new()
    add_child(player)
    player.stream = stream
    player.play()
    sfx_pool.append(player)
```

### 2. 背景音乐淡入淡出

```gdscript
var bgm_volume: float = 0.0

func fade_in(target_volume: float, duration: float):
    var tween = create_tween()
    tween.tween_property(self, "bgm_volume", target_volume, duration)

func fade_out(duration: float):
    var tween = create_tween()
    tween.tween_property(self, "bgm_volume", -80.0, duration)  # -80dB = 静音
```

---

## 🔗 相关资源

### Base 层
- [12B_Audio_Streams.md](../../base/audio-system/12B_Audio_Streams.md) - 音频流详解

### Wiki 层
- [音频总线概念](../concepts/audio-buses-concept.md) - 音频总线基础
- [音频效果器指南](../guides/audio-effects-guide.md) - 音频效果处理

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
