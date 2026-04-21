# 音频系统核心概念

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 12A_Audio_Buses.md](../../base/audio-system/12A_Audio_Buses.md)  
> **重要性**: 🔴 必读 - 音频总线系统基础

---

## 📋 概述

Godot 的音频系统基于总线架构，允许你混合、处理和路由音频信号。理解音频总线是实现专业音效管理的关键。

---

## 🎯 核心概念

### 1. 音频总线（Audio Bus）

音频总线是音频信号的传输通道，类似混音台的轨道。

**默认总线**：
- **Master**: 主输出总线（所有音频最终汇聚于此）
- 可以创建自定义总线（如 BGM、SFX、Voice）

### 2. 音频流（AudioStream）

音频流是实际的音频数据，可以是：
- **AudioStreamMP3**: MP3 格式
- **AudioStreamOggVorbis**: OGG 格式（推荐）
- **AudioStreamWAV**: WAV 格式（无损）

### 3. 音频效果（Audio Effect）

效果器用于处理音频信号，如：
- **EQ（均衡器）**: 调整频率响应
- **Compression（压缩器）**: 动态范围压缩
- **Reverb（混响）**: 空间效果
- **Limiter（限制器）**: 防止削波

---

## 🔧 使用方法

### 配置音频总线

1. 打开 "音频" 面板（底部）
2. 点击 "总线" 标签
3. 添加新总线（+ 按钮）
4. 命名总线（如 "BGM"、"SFX"）
5. 添加效果器

### 代码控制

```gdscript
# 设置总线音量
AudioServer.set_bus_volume_db(0, -10)  # Master 总线，-10dB

# 设置总线静音
AudioServer.set_bus_mute(1, true)  # 静音 BGM 总线

# 设置总线独奏
AudioServer.set_bus_solo(2, true)  # 独奏 SFX 总线

# 获取总线索引
var bgm_index = AudioServer.get_bus_index("BGM")
```

---

## 🔗 相关资源

### Base 层
- [12A_Audio_Buses.md](../../base/audio-system/12A_Audio_Buses.md) - 音频总线详解
- [12B_Audio_Streams.md](../../base/audio-system/12B_Audio_Streams.md) - 音频流指南
- [12C_Audio_Effects.md](../../base/audio-system/12C_Audio_Effects.md) - 音频效果器

### Wiki 层
- [音频系统实战指南](../guides/audio-streams-guide.md) - 音频流播放指南
- [音频效果器指南](../guides/audio-effects-guide.md) - 音频效果处理

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
