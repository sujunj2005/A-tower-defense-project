# 音频效果 (Audio Effects)

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/audio/audio_effects.rst

---

## 一、简介

Godot 包含多种**音频效果器**，可添加到音频总线上以改变通过该总线的所有声音。

> **新手入门必学效果**：Equalizer & Filter、Limiter、Delay & Reverb  
> **提示**：AudioSample 不支持这些效果

---

## 二、效果器列表与详解

### 2.1 Amplify（放大器）

改变声音音量。

⚠️ **警告**：设置过高会导致**数字削波**（clipping），产生刺耳的爆裂声。

**解决方案**：
- 使用 Hard Limiter 或 Compressor 防止削波
- 或故意使用 Distortion（Clip模式）在0dB以下削波

---

### 2.2 BandLimitFilter（带限滤波器）

**作用**：衰减截止频率处的频率，允许其他频率通过。

**对比**：
- 比 Notch Filter 弱
- 与 BandPassFilter 相反

**用途**：为其他声音在截止频率处腾出空间。

---

### 2.3 BandPassFilter（带通滤波器）

**作用**：允许截止频率附近的频率通过，衰减其他频率。

**对比**：
- 与 BandLimitFilter 和 NotchFilter 相反

**用途**：
- 模拟老式电话线或扩音器的声音
- 调制 cutoff 可模拟哇音吉他踏板效果（如 Jimi Hendrix 的《Voodoo Child》）

---

### 2.4 Capture（捕获）

**作用**：将音频总线的音频样本复制到内部环形缓冲区。

**用途**：
- 从麦克风捕获数据
- 网络实时传输音频
- 存储实时音频数据用于回放
- 创建实时音频可视化（示波器）

**特点**：不改变原始音频

---

### 2.5 Chorus（合唱）

**作用**：
1. 复制信号并轻微改变每个副本的时间和音高
2. 通过 LFO（低频振荡器）调制
3. 将所有"人声"（voices）混合回原信号

**效果**：听起来像来自多个声源的声音。

**现实世界对应**：钢琴、合唱团、乐器合奏。

**用途**：
- 加宽单声道音频
- 让数字声音更自然/更有模拟质感

---

### 2.6 Compressor（压缩器）

**作用**：当输入信号幅度超过阈值时，自动衰减（"duck"）音量。衰减量与超过程度成正比。

**Ratio 参数**：控制衰减程度。

**主要用途**：降低动态范围（很响和很安静的部分），使信号更适合混音。

**典型应用场景**：

| 场景 | 用法 |
|------|------|
| **主输出保护** | Master总线上压缩，再接Limiter，使Limiter更温和 |
| **语音处理** | 确保语音尽可能均匀 |
| **侧链（Sidechain）** | 用另一个音频总线的音量来触发压缩，常用于游戏混音中"duck"音乐或音效 |
| **增强瞬态** | 使用较慢的Attack时间，让响亮部分先通过再压缩，强调打击感 |

> **如果目标只是防止信号超过某个幅度**，Hard Limiter 可能是更好的选择。但压缩器 + 限幅器仍是良好实践。

---

### 2.7 Delay（延迟）

**作用**：复制信号并多次重复，每次重复之间有短时间间隔（tap）。Tap音量随时间衰减。

**效果**：回声效果。

**用途**：模拟峡谷或大房间的声学空间（声音从表面反弹后延迟到达听者）。

**与 Reverb 对比**：
- Delay：清晰的重复回声
- Reverb：更自然、模糊的反射声

**组合使用**：Delay + Reverb 可创造非常自然的声学环境

---

### 2.8 Distortion（失真）

**作用**：以改变波形的方式修改音量，产生"刺耳"和"明亮"的声音。

**失真类型**：

| 类型 | 效果 |
|------|------|
| **Clip** | 钳位音量，声音刺耳 |
| **Overdrive** | 吉他失真踏板或扩音器效果 |
| **Lo-fi** | 降低比特深度，模拟老式扬声器 |

**共同特点**：都会向原始声音增加高频成分，帮助其在混音中更突出。

> ⚠️ **警告**：小心失真量，过度会产生非常刺耳的声音

---

### 2.9 Equalizer（均衡器）

**作用**：对不同频段进行增益或衰减。

**常见用法**：
- 提升低频增加震撼感
- 衰减问题频率（如60Hz嗡嗡声）
- 为人声或其他乐器"腾出空间"

---

### 2.10 Filter（滤波器）

Godot提供多种滤波器类型：

| 类型 | 作用 |
|------|------|
| **HighPassFilter** | 通过高频，衰减低频（去除隆隆声） |
| **LowPassFilter** | 通过低频，衰减高频（使声音沉闷） |
| **BandLimitFilter** | 衰减截止频率处 |
| **BandPassFilter** | 仅通过截止频率附近 |
| **NotchFilter** | 仅衰减非常窄的频率范围（去除特定噪声） |
| **AllpassFilter** | 不衰减任何频率，但改变相位关系 |
| **CombFilter** | 基于时间的滤波，产生金属质感 |

---

### 2.11 Hard Limiter（硬限幅器）

**作用**：严格防止信号超过设定的幅度上限。

**特点**：
- 比 Compressor 更激进
- 适合作为最终的安全网
- 通常放在 Master 总线的最后

**建议**：先用 Compressor 压缩动态范围，再用 Limiter 作为最后的保护。

---

### 2.12 LowPassFilter（低通滤波器）

**作用**：衰减高频，让声音变闷。

**用途**：
- 模拟墙后的声音
- 水下效果
- 远距离声音
- 老式收音机效果

**参数**：
- `cutoff`：截止频率（Hz）
- `resonance`：共振（增加截止频率处的峰值）
- `db`：衰减量（dB）

---

### 2.13 NotchFilter（陷波滤波器）

**作用**：仅衰减非常窄的频率范围。

**用途**：
- 去除特定的电子噪声（如50/60Hz电源嗡嗡声）
- 去除反馈啸叫频率
- 精确移除不需要的频率而不影响其他频率

---

### 2.14 Panner（声像器）

**作用**：控制立体声声像位置。

**用途**：
- 动态改变声音在立体声场中的位置
- 自动化声像移动效果

---

### 2.15 Phaser（相位器）

**作用**：通过一系列全通滤波器和调制产生"漩涡"般的效果。

**效果**：类似 Flanger 但更微妙，产生太空感或迷幻感。

---

### 2.16 PitchShift（音高变换）

**作用**：改变音高而不改变速度（或反之）。

**用途**：
- 变声效果（怪物、机器人）
- 卡带效果
- 和弦调整

---

### 2.17 Reverb（混响）

**作用**：模拟空间中的声音反射。

**参数**：

| 参数 | 说明 |
|------|------|
| `predelay` | 预延迟（直达声与早期反射之间的时间） |
| `room_size` | 房间大小 |
| `damping` | 高频衰减（模拟吸音材料） |
| `spread` | 立体声宽度 |
| `dry` | 干声比例 |
| `wet` | 湿声比例 |

**预设场景**：

| 场景 | room_size | damping |
|------|-----------|---------|
| 小房间 | 0.3 | 0.5 |
| 大厅 | 0.7 | 0.3 |
| 大教堂 | 0.9 | 0.1 |
| 洞穴 | 1.0 | 0.05 |

---

### 2.18 SpectrumAnalyzer（频谱分析器）

**作用**：显示音频频率分布的可视化。

**用途**：
- 音乐可视化效果
- 调试音频频率问题
- 音乐节奏游戏

---

## 三、常用效果链配置

### 3.1 主输出（Master）

```
Compressor → EQ → Limiter
```

### 3.2 环境音（Ambient）

```
LowPass Filter → Reverb → Delay
```

### 3.3 UI音效

```
EQ（提升中高频）→ Light Compression
```

### 3.4 语音对话

```
Compressor → DeEsser(NotchFilter) → EQ → Limiter
```

### 3.5 战斗/动作音效

```
Distortion(light) → Compressor → EQ
```

---

## 四、代码控制示例

### 4.1 动态切换效果

```gdscript
# 切换到水下效果
func enter_water():
    var bus_index = AudioServer.get_bus_index("Master")
    var effect = AudioServer.get_bus_effect(bus_index, 0)

    if effect is AudioEffectLowPassFilter:
        effect.cutoff = 500.0  # 低通滤波，声音变闷

# 恢复正常
func exit_water():
    var bus_index = AudioServer.get_bus_index("Master")
    var effect = AudioServer.get_bus_effect(bus_index, 0)

    if effect is AudioEffectLowPassFilter:
        effect.cutoff = 20000.0  # 恢复全频段
```

### 4.2 动态创建效果

```gdscript
func add_reverb_to_bus(bus_name: String):
    var bus_idx = AudioServer.get_bus_index(bus_name)
    var reverb = AudioEffectReverb.new()
    reverb.room_size = 0.8
    reverb.wet = 0.5
    AudioServer.add_bus_effect(bus_idx, reverb)
```

### 4.3 音乐淡出+低通组合

```gdscript
func scene_transition():
    var master_bus = AudioServer.get_bus_index("Master")

    # 添加低通滤波
    var lpf = AudioEffectLowPassFilter.new()
    lpf.cutoff = 20000.0  # 开始时不影响
    AudioServer.add_bus_effect(master_bus, lpf)

    # 渐变降低截止频率 + 音量
    var tween = create_tween()
    tween.parallel().tween_property(lpf, "cutoff", 200.0, 2.0)
    tween.parallel().tween_property(AudioServer, "bus_volume_db", -40.0, 2.0)
```

---

## 五、性能注意事项

| 方面 | 建议 |
|------|------|
| **效果数量** | 每个总线尽量 < 8个效果器 |
| **重度效果** | Reverb、Chorus 计算开销大，谨慎使用 |
| **移动平台** | 简化效果链，优先保证核心体验 |
| **动态效果** | 频繁添加/删除效果会有开销，考虑预置多个总线 |
| **采样率** | 低采样率设备上某些高频效果可能异常 |

---

## 六、参考链接

- [AudioEffect 官方基类](https://docs.godotengine.org/en/stable/classes/class_audioeffect.html)
- [AudioEffectReverb](https://docs.godotengine.org/en/stable/classes/class_audioeffectreverb.html)
- [AudioEffectCompressor](https://docs.godotengine.org/en/stable/classes/class_audioeffectcompressor.html)
- [AudioEffectEQ](https://docs.godotengine.org/en/stable/classes/class_audioeffecteq.html)
- [AudioEffectDistortion](https://docs.godotengine.org/en/stable/classes/class_audioeffectdistortion.html)
- [Audio Server 文档](https://docs.godotengine.org/en/stable/classes/class_audio_server.html)
- [音频总线教程](12A_Audio_Buses.md)
- [音频流教程](12B_Audio_Streams.md)
