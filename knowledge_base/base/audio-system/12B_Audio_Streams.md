# 音频流系统 (Audio Streams)

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/audio/audio_streams.rst

---

## 一、简介

声音通过 **AudioStreamPlayer** 节点发送到音频总线（Audio Bus）。Godot 提供多种 AudioStreamPlayer 变体，每种适用于不同场景。

---

## 二、AudioStream 类型

### 2.1 AudioStream（抽象基类）

AudioStream 是发出声音的抽象对象。最常见的是从文件系统加载。

**支持的格式**详见 [导入音频样本文档](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_audio_samples.html)

**特殊类型：AudioStreamRandomizer**

每次播放时从列表中随机选择一个 AudioStream，并应用随机的音高和音量变化：

```gdscript
var randomizer = AudioStreamRandomizer.new()
randomizer.audio_stream_pool = [
    preload("res://footstep_1.ogg"),
    preload("res://footstep_2.ogg"),
    preload("res://footstep_3.ogg"),
]
randomizer.random_pitch = 1.0  # 音高变化范围
randomizer.random_volume_offset_db = 2.0  # 音量变化范围

$AudioStreamPlayer.stream = randomizer
$AudioStreamPlayer.play()
```

> **适用场景**：脚步声、枪声、击打声等需要变化的声音

---

## 三、AudioStreamPlayer 节点类型

### 3.1 AudioStreamPlayer（标准）

![AudioStreamPlayer](img/audio_stream_player.webp)

- **非位置性**：无立体声定位
- **适用场景**：背景音乐、UI音效、全局音效
- **总线选择**：可播放到任意总线
- **5.1 声道支持**：可发送到立体声混音或前置扬声器

#### Playback Type（实验性功能）

| 模式 | 平台 | 说明 |
|------|------|------|
| **Stream** | 大多数平台 | 流式传输（默认） |
| **Sample** | Web平台 | 使用 Web Audio API 样本 |

> **注意**：Web平台默认使用 Sample模式以避免单线程导出时的音频问题。修改需谨慎。

---

### 3.2 AudioStreamPlayer2D（2D位置音频）

![AudioStreamPlayer2D](img/audio_stream_2d.webp)

- **位置感知**：根据屏幕位置自动调整声道平衡
- **左边缘** → 声音偏左
- **右边缘** → 声音偏右

**关键属性：**

| 属性 | 说明 |
|------|------|
| `max_distance` | 最大 audible 距离 |
| `attenuation` | 衰减模型（Inverse/Linear/Disabled） |
| `bus` | 输出总线 |
| `pitch_scale` | 音高缩放（1.0=正常） |

#### Area2D 重定向

Area2D 可将包含的 AudioStreamPlayer2D 的声音重定向到特定总线：

```gdscript
# 创建不同混响区域
func _on_Area2D_body_entered(body):
    $AudioStreamPlayer2D.bus = "Reverb_Cave"  # 进入洞穴区域
```

---

### 3.3 AudioStreamPlayer3D（3D位置音频）

![AudioStreamPlayer3D](img/audio_stream_3d.webp)

- **完整3D空间音频**
- 支持 stereo / 5.1 / 7.1 输出（取决于音频设置）
- 类似 AudioStreamPlayer2D，Area3D 可重定向到特定总线

**比2D版本多出的高级特性：**

#### Reverb Buses（混响总线）

> **警告**：Web平台在 Sample模式下不支持此功能

Godot 允许3D音频流进入特定 Area3D 时，将干声和湿声分别发送到不同总线：

```
设置步骤：
1. 在 Area3D 中启用 Reverb Bus 功能
2. 配置 Uniformity 参数（模拟仓库等空间）
3. 在对应的 Reverb Bus 上添加 Reverb 效果器
```

**Uniformity 参数**：
- 有些房间反射声音更均匀（如仓库）
- 即使声源很远，整个房间都能听到混响
- 调整此参数模拟该效果

#### Doppler Effect（多普勒效应）

> **警告**：Web平台在 Sample模式下不支持

模拟现实中声音源移动时的频率变化：

- **靠近** → 音调升高
- **远离** → 音调降低

**关键属性：**

| 属性 | 说明 |
|------|------|
| `doppler_tracking` | 追踪模式（None/Physics Velocity/Character Body） |
| `max_db` | 最大音量（dB） |

**使用示例：**

```gdscript
# 高速移动的物体（如赛车）
$EngineSound.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_VELOCITY

# 角色脚步声（不需要多普勒）
$Footsteps.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_NONE
```

---

## 四、常用操作代码

### 4.1 基本播放控制

```gdscript
# 播放
$AudioStreamPlayer.play()
$AudioStreamPlayer.play(from_position)  # 从指定位置播放

# 停止
$AudioStreamPlayer.stop()

# 暂停/恢复
$AudioStreamPlayer.stream_paused = true
$AudioStreamPlayer.stream_paused = false

# 检查状态
if $AudioStreamPlayer.playing:
    print("正在播放")

# 获取播放位置
var pos = $AudioStreamPlayer.get_playback_position()

# 设置音量（线性）
$AudioStreamPlayer.volume_db = linear_to_db(0.5)  # 50%音量

# 设置音高
$AudioStreamPlayer.pitch_scale = 1.2  # 提高20%
```

### 4.2 淡入淡出效果

```gdscript
func fade_in(duration: float):
    var tween = create_tween()
    tween.tween_property($AudioStreamPlayer, "volume_db", -10.0, duration).from(-80.0)
    $AudioStreamPlayer.play()

func fade_out(duration: float):
    var tween = create_tween()
    tween.tween_property($AudioStreamPlayer, "volume_db", -80.0, duration)
    await tween.finished
    $AudioStreamPlayer.stop()
```

### 4.3 3D音频配置示例

```gdscript
func setup_3d_audio():
    var player = AudioStreamPlayer3D.new()
    player.stream = load("res://sounds/explosion.ogg")
    player.max_distance = 50.0
    player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
    player.bus = "Master"
    player.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_VELOCITY

    add_child(player)
    player.play()
```

### 4.4 音频管理器（单例模式）

```gdscript
# AudioManager.gd (Autoload)
extends Node

var bgm_player: AudioStreamPlayer
var sfx_bus := "SFX"

func _ready():
    bgm_player = AudioStreamPlayer.new()
    bgm_player.bus = "BGM"
    add_child(bgm_player)

func play_bgm(stream: AudioStream, fade_duration: float = 0.0):
    if fade_duration > 0:
        var tween = create_tween()
        tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
        await tween.finished
    bgm_player.stream = stream
    if fade_duration > 0:
        bgm_player.volume_db = -80.0
        var tween = create_tween()
        tween.tween_property(bgm_player, "volume_db", 0.0, fade_duration)
    bgm_player.play()

func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO):
    var player = AudioStreamPlayer2D.new()
    player.stream = stream
    player.bus = sfx_bus
    player.global_position = position
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
```

---

## 五、性能优化建议

| 场景 | 建议 |
|------|------|
| **大量短音效** | 使用 AudioStreamPlayer2D 池，复用节点 |
| **背景音乐** | 使用 OGG/Vorbis 格式（文件小，质量好） |
| **频繁播放的音效** | 使用 AudioStreamRandomizer 避免重复感 |
| **3D游戏** | 合理设置 max_distance 减少计算 |
| **Web导出** | 注意 Playback Type 的兼容性 |
| **移动平台** | 限制同时播放的音频流数量（< 16） |

---

## 六、常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 无声音 | 总线静音或音量过低 | 检查 Audio Bus 面板 |
| 3D无空间感 | max_distance过大或attenuation=Disabled | 调整衰减参数 |
| Web导出音频杂乱 | 单线程+Stream模式 | 改用Sample模式 |
| 音频卡顿 | 同时播放过多音频 | 使用音频池限制数量 |
| 多普勒效应异常 | doppler_tracking设置错误 | 选择正确的追踪模式 |

---

## 七、参考链接

- [AudioStream 官方文档](https://docs.godotengine.org/en/stable/classes/class_audiostream.html)
- [AudioStreamPlayer 官方文档](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html)
- [AudioStreamPlayer2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html)
- [AudioStreamPlayer3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html)
- [AudioStreamRandomizer 官方文档](https://docs.godotengine.org/en/stable/classes/class_audiostreamrandomizer.html)
- [音频总线教程](12A_Audio_Buses.md)
- [音频效果教程](12C_Audio_Effects.md)
