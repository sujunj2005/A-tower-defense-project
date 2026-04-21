# Camera2D 概念

> **适用版本**: Godot 4.x  
> **知识领域**: 2D 摄像机系统  
> **前置知识**: [2D 开发介绍](./2d-development-intro.md)、[节点操作指南](../guides/node-operations-guide.md)

---

## 📋 概述

**Camera2D** 是用于 2D 游戏的摄像机节点，提供跟随、缩放、旋转、屏幕震动等功能。

### 核心特点

- ✅ **自动跟随**: 跟随父节点或指定目标
- ✅ **平滑插值**: 平滑移动和旋转
- ✅ **边界限制**: 限制在关卡范围内
- ✅ **屏幕震动**: 内置震动效果支持
- ✅ **多重摄像机**: 支持分屏和多视图

---

## 🎯 适用场景

### Camera2D 典型用途

| 场景 | 功能 | 配置要点 |
|------|------|---------|
| **平台跳跃** | 跟随玩家 | Position Smoothing、Limit |
| **俯视角射击** | 跟随 + 旋转瞄准 | Rotation Smoothing |
| **解谜游戏** | 固定视角/平滑过渡 | Position Smoothing |
| **Boss 战** | 动态缩放/边界调整 | Zoom、Limit |
| **过场动画** |  scripted 摄像机移动 | Tween/AnimationPlayer |

---

## 🛠️ 基本设置

### 场景结构

```
Player (CharacterBody2D)
└── Camera2D (作为子节点)
```

### 核心属性

#### 1. Follow（跟随）

```gdscript
# Camera2D 自动跟随父节点
# 无需代码，Camera2D 默认跟随其父节点

# 如果需要跟随其他节点
var target: Node2D
camera.make_current()  # 激活摄像机
```

#### 2. Position Smoothing（位置平滑）

```gdscript
# 启用平滑跟随
position_smoothing_enabled = true
position_smoothing_speed = 5.0  # 值越大越快速

# 适用场景：
# - 高速移动游戏（需要快速响应）：8.0-15.0
# - 平台跳跃（中等平滑）：5.0-8.0
# - 解谜游戏（高度平滑）：2.0-5.0
```

#### 3. Rotation Smoothing（旋转平滑）

```gdscript
# 启用旋转平滑
rotation_smoothing_enabled = true
rotation_smoothing_speed = 5.0

# 适用场景：俯视角射击游戏（摄像机跟随玩家瞄准方向）
```

#### 4. Limit（边界限制）

```gdscript
# 设置摄像机边界（像素坐标）
limit_left = 0
limit_top = 0
limit_right = 1920
limit_bottom = 1080

# 或者使用 Rect2
limit_rect = Rect2(0, 0, 1920, 1080)

# 提示：可以在编辑器中拖动 Limit 手柄直观设置
```

#### 5. Zoom（缩放）

```gdscript
# 设置缩放（1=正常，2=放大，0.5=缩小）
zoom = Vector2(2, 2)  # 放大 2 倍

# 动态缩放（如 Boss 战）
var tween = create_tween()
tween.tween_property(camera, "zoom", Vector2(1.5, 1.5), 1.0)
```

---

## 🔧 高级功能

### 1. 屏幕震动（Screen Shake）

```gdscript
# 基础震动
camera.set_screen_shake_strength(10.0)
camera.start_screen_shake()

# 震动指定时长
camera.set_screen_shake_strength(20.0)
camera.start_screen_shake()
await get_tree().create_timer(0.5).timeout
camera.stop_screen_shake()

# 震动衰减（更自然）
func shake_camera(strength: float, duration: float):
    var tween = create_tween()
    camera.set_screen_shake_strength(strength)
    camera.start_screen_shake()
    tween.tween_method(
        func(value): camera.set_screen_shake_strength(value),
        strength,
        0,
        duration
    ).tween_callback(camera.stop_screen_shake)
```

### 2. 多重摄像机（分屏）

```gdscript
# 玩家 1 摄像机
var camera1 = Camera2D.new()
camera1.offset = Vector2(-960, 0)  # 左半屏
camera1.current = true
player1.add_child(camera1)

# 玩家 2 摄像机
var camera2 = Camera2D.new()
camera2.offset = Vector2(960, 0)  # 右半屏
camera2.current = false
player2.add_child(camera2)

# 注意：需要配置 Viewport 支持分屏
```

### 3. 摄像机过渡

```gdscript
# 平滑切换到另一个摄像机
var camera_a: Camera2D
var camera_b: Camera2D

func switch_to_camera_b():
    var tween = create_tween()
    
    # 淡出当前摄像机
    tween.tween_property(camera_a, "modulate:a", 0, 0.5)
    
    # 切换摄像机
    tween.tween_callback(func(): camera_b.current = true)
    
    # 淡入新摄像机
    tween.tween_property(camera_b, "modulate:a", 1, 0.5)
```

### 4. 动态边界调整

```gdscript
# 根据玩家位置动态调整边界
func update_limit(player_pos: Vector2):
    var margin = 500
    limit_left = player_pos.x - margin
    limit_right = player_pos.x + margin
    limit_top = player_pos.y - margin
    limit_bottom = player_pos.y + margin

# 适用于无限滚动关卡或大型开放世界
```

---

## 📊 性能优化

### Camera2D 优化建议

| 优化方向 | 具体措施 | 性能提升 |
|---------|---------|---------|
| **禁用不必要平滑** | 关闭 Position/Rotation Smoothing | ⭐⭐⭐ |
| **限制视口外渲染** | 正确设置 Limit | ⭐⭐⭐⭐ |
| **减少屏幕震动** | 避免频繁/强烈震动 | ⭐⭐ |
| **使用单摄像机** | 避免多重摄像机（除非必要） | ⭐⭐⭐⭐ |

---

## ⚠️ 常见问题

### 1. 摄像机抖动

**问题**: 摄像机跟随玩家时抖动

**解决方案**:
```gdscript
# 启用平滑
position_smoothing_enabled = true
position_smoothing_speed = 5.0

# 或者在 _physics_process 中移动玩家
# 避免在 _process 中移动（会导致帧率相关抖动）
```

### 2. 边界无效

**问题**: Limit 设置后不起作用

**解决方案**:
```gdscript
# 检查是否激活了摄像机
camera.current = true

# 检查 Limit 值是否正确（应该是正数且 right > left, bottom > top）
limit_left = 0
limit_top = 0
limit_right = 1920
limit_bottom = 1080

# 或者使用 limit_rect
limit_rect = Rect2(0, 0, 1920, 1080)
```

### 3. 缩放后 UI 错位

**问题**: 摄像机缩放后 UI 位置不对

**解决方案**:
```gdscript
# UI 应该使用单独的 CanvasLayer，不受摄像机影响
CanvasLayer
└── UI (Control)

# 或者设置 UI 的 anchor 为全屏
$UI.set_anchors_preset(Control.PRESET_FULL_RECT)
```

---

## 🔗 相关资源

### Base 层来源
- [2D 开发](../../base/2d-development/) - 2D 开发基础
- [输入系统](../../base/input-system/) - 玩家输入处理

### Wiki 层相关
- [2D 开发概述](../overviews/2d-game-development-overview.md)
- [2D 移动指南](../guides/2d-movement-guide.md)
- [玩家实体设计](../entities/player.md)
- [塔防游戏架构](../guides/tower-defense-architecture.md)
- [插值指南](../guides/interpolation-guide.md) - Tween 使用

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
