# 功能标签实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 18B_Feature_Tags.md](../../base/export-and-platforms/18B_Feature_Tags.md)  
> **重要性**: 🟡 推荐 - 平台特定功能管理

---

## 📋 概述

功能标签（Feature Tags）用于标识不同平台或配置的特定功能。通过功能标签，可以为不同平台定制游戏功能。

---

## 🎯 核心概念

### 1. 功能标签定义

功能标签是字符串标识符，用于标记特定功能：
- `mobile`: 移动平台功能
- `desktop`: 桌面平台功能
- `debug`: 调试功能
- `low_end`: 低端设备功能

### 2. 条件编译

```gdscript
# 检查功能标签
if OS.has_feature("mobile"):
    setup_mobile_controls()
elif OS.has_feature("desktop"):
    setup_keyboard_controls()

# 自定义功能标签
# 在导出预设中添加功能标签
# 然后在代码中检查
if OS.has_feature("low_end"):
    set_graphics_quality(LOW)
else:
    set_graphics_quality(HIGH)
```

---

## 🔧 实战技巧

### 1. 平台适配

```gdscript
func setup_platform():
    if OS.has_feature("mobile"):
        # 移动平台
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
        enable_touch_controls()
        reduce_texture_quality()
    
    elif OS.has_feature("web"):
        # Web 平台
        enable_web_audio()
        setup_web_save()
    
    else:
        # 桌面平台
        enable_keyboard_controls()
        enable_high_quality_graphics()
```

### 2. 性能分级

```gdscript
enum GraphicsQuality { LOW, MEDIUM, HIGH }

func determine_graphics_quality() -> GraphicsQuality:
    if OS.has_feature("low_end"):
        return GraphicsQuality.LOW
    elif OS.has_feature("mobile"):
        return GraphicsQuality.MEDIUM
    else:
        return GraphicsQuality.HIGH
```

### 3. 功能开关

```gdscript
# 功能配置
var features = {
    "shadows": not OS.has_feature("low_end"),
    "particles": OS.has_feature("desktop"),
    "post_processing": OS.has_feature("high_end"),
    "touch_controls": OS.has_feature("mobile")
}

func _ready():
    if features["shadows"]:
        enable_shadows()
    
    if features["particles"]:
        enable_particles()
```

---

## 🔗 相关资源

### Base 层
- [18B_Feature_Tags.md](../../base/export-and-platforms/18B_Feature_Tags.md) - 功能标签详解

### Wiki 层
- [项目导出指南](../guides/exporting-projects-guide.md) - 多平台导出

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
