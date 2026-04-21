# 音频效果器指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 12C_Audio_Effects.md](../../base/audio-system/12C_Audio_Effects.md)  
> **重要性**: 🟡 推荐 - 音频效果处理实战

---

## 📋 概述

音频效果器用于处理和增强音频信号。Godot 提供了丰富的效果器，从基础的音量调整到高级的频谱分析。

---

## 🎯 常用效果器

### 1. EQ（均衡器）

调整不同频率的音量。

**使用场景**：
- 增强低音（BGM）
- 突出人声（Voice）
- 减少刺耳高频

```gdscript
# 添加 EQ 效果
var eq = AudioEffectEQ21.new()
AudioServer.add_bus_effect(1, eq)  # 添加到 BGM 总线

# 调整频率
eq.set_band_gain(5, 3.0)  # 增强中频
```

### 2. Compression（压缩器）

压缩动态范围，使小声变大，大声变小。

**使用场景**：
- 语音聊天
- 背景音乐
- 动作音效

### 3. Reverb（混响）

添加空间感，模拟不同环境。

**使用场景**：
- 洞穴/大厅
- 水下场景
- 梦境效果

### 4. Limiter（限制器）

防止音频削波（爆音）。

**使用场景**：
- 主输出总线
- 防止音量过大

---

## 🔧 实战技巧

### 1. 动态 BGM 混音

```gdscript
func _on_combat_started():
    # 战斗时降低 BGM 音量，增强低频
    var bgm_index = AudioServer.get_bus_index("BGM")
    AudioServer.set_bus_volume_db(bgm_index, -15)
    
    var sfx_index = AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(sfx_index, -5)
```

### 2. 语音聊天效果链

```
Voice Bus 效果链:
1. HighPassFilter (切除低频噪声)
2. Compression (压缩动态范围)
3. EQ (增强人声频率)
4. Limiter (防止爆音)
```

---

## 🔗 相关资源

### Base 层
- [12C_Audio_Effects.md](../../base/audio-system/12C_Audio_Effects.md) - 音频效果器详解

### Wiki 层
- [音频总线概念](../concepts/audio-buses-concept.md) - 音频总线基础
- [音频流指南](../guides/audio-streams-guide.md) - 音频流播放

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
