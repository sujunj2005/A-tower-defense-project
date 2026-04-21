# Godot 4.x 窗口尺寸检测问题

> **问题分类**: 已知限制  
> **影响版本**: Godot 4.x  
> **发现时间**: 2026-04-07  
> **来源**: [10_Other/10A_Known_Issues/Godot_4x_Window_Size_Detection_Issue.md](../../../10_Other/10A_Known_Issues/Godot_4x_Window_Size_Detection_Issue.md)

---

## 📋 问题描述

在 Godot 4.x 中，窗口尺寸检测存在一些问题，可能导致在某些情况下无法正确获取或设置窗口尺寸。

---

## 🎯 问题表现

### 1. 启动时窗口尺寸不正确

```gdscript
func _ready():
    print(DisplayServer.window_get_size())  # 可能与项目设置不符
```

### 2. 全屏模式下尺寸检测失效

```gdscript
func _on_fullscreen_toggled():
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    print(DisplayServer.window_get_size())  # 可能返回错误的尺寸
```

### 3. 多显示器环境尺寸错误

在多显示器环境下，窗口尺寸可能受到 DPI 缩放影响。

---

## 🔧 解决方案

### 方案 1：延迟获取窗口尺寸

```gdscript
func _ready():
    # 等待一帧获取正确的窗口尺寸
    await get_tree().process_frame
    var window_size = DisplayServer.window_get_size()
    print("窗口尺寸：", window_size)
```

### 方案 2：使用视口尺寸

```gdscript
func get_actual_size() -> Vector2i:
    return get_viewport().get_visible_rect().size
```

### 方案 3：手动设置窗口尺寸

```gdscript
func _ready():
    # 强制设置窗口尺寸
    var target_size = Vector2i(1920, 1080)
    DisplayServer.window_set_size(target_size)
    
    # 验证设置
    await get_tree().process_frame
    print("实际尺寸：", DisplayServer.window_get_size())
```

### 方案 4：处理 DPI 缩放

```gdscript
func get_dpi_scaled_size() -> Vector2i:
    var window_size = DisplayServer.window_get_size()
    var scale = DisplayServer.get_screen_scale()
    return window_size * scale
```

---

## ⚠️ 注意事项

### 1. 平台差异

- **Windows**: 通常工作正常
- **Linux**: 可能受 Wayland/X11 影响
- **macOS**: 注意 Retina 显示屏的 DPI 缩放

### 2. 全屏模式

全屏模式下窗口尺寸可能等于显示器分辨率，但不总是可靠。

### 3. 窗口模式切换

切换窗口模式（窗口化↔全屏）后，需要等待一帧才能获取正确尺寸。

---

## 📊 测试建议

### 测试清单

- [ ] 启动时窗口尺寸
- [ ] 切换全屏模式
- [ ] 调整窗口大小
- [ ] 多显示器环境
- [ ] DPI 缩放环境

### 测试代码

```gdscript
extends Node

func _ready():
    print("=== 窗口尺寸测试 ===")
    print("初始尺寸：", DisplayServer.window_get_size())
    print("视口尺寸：", get_viewport().get_visible_rect().size)
    print("屏幕尺寸：", DisplayServer.screen_get_size())
    print("DPI 缩放：", DisplayServer.get_screen_scale())

func _on_window_resized():
    print("窗口已调整：", DisplayServer.window_get_size())
```

---

## 🔗 参考资源

- [Godot 官方文档 - DisplayServer](https://docs.godotengine.org/en/stable/classes/class_displayserver.html)
- [Godot 官方文档 - 视口](https://docs.godotengine.org/en/stable/classes/class_viewport.html)

---

**最后更新**: 2026-04-07  
**作者**: Knowledge Base Administrator  
**版本**: 1.0
