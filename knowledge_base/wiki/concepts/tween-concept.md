# Tween 概念

> **适用版本**: Godot 4.x  
> **知识领域**: 动画与插值  
> **前置知识**: [GDScript 基础](./gdscript-basics.md)、[插值指南](../guides/interpolation-guide.md)

---

## 📋 概述

**Tween** 是 Godot 的插值系统，用于在一段时间内平滑地改变属性值。适用于动画、过渡、平滑移动等场景。

### 核心特点

- ✅ **声明式 API**: 链式调用，代码简洁
- ✅ **类型安全**: 支持 Vector2/3、Color、float、int 等类型
- ✅ **缓动函数**: 内置 30+ 种缓动效果
- ✅ **回调支持**: 可连接完成/步骤回调
- ✅ **可组合**: 支持并行/串行/嵌套

---

## 🎯 适用场景

### Tween 典型用途

| 场景 | 用途 | 示例 |
|------|------|------|
| **UI 动画** | 按钮悬停、面板滑入 | `tween_property(button, "modulate", hover_color, 0.2)` |
| **平滑移动** | 角色/物体移动 | `tween_property(player, "position", target_pos, 1.0)` |
| **淡入淡出** | 透明度变化 | `tween_property(sprite, "modulate:a", 0, 0.5)` |
| **缩放动画** | UI/物体缩放 | `tween_property(control, "scale", Vector2(1.2, 1.2), 0.3)` |
| **旋转动画** | 平滑旋转 | `tween_property(enemy, "rotation", target_angle, 0.5)` |
| **颜色过渡** | 颜色渐变 | `tween_property(light, "color", Color.RED, 2.0)` |
| **摄像机过渡** | 平滑切换 | `tween_property(camera, "zoom", target_zoom, 1.0)` |

---

## 🛠️ 基本用法

### 1. 创建 Tween

```gdscript
# 方法 1: 使用 create_tween()（推荐）
var tween = create_tween()
tween.tween_property($Sprite2D, "position", Vector2(100, 100), 1.0)

# 方法 2: 使用 Tween.new()
var tween = Tween.new()
add_child(tween)
tween.tween_property($Sprite2D, "position", Vector2(100, 100), 1.0)
```

### 2. 属性插值

```gdscript
# 基础用法
var tween = create_tween()
tween.tween_property($Sprite2D, "position", target_position, 1.0)

# 链式调用
tween
    .tween_property($Sprite2D, "position", Vector2(100, 0), 0.5)
    .tween_property($Sprite2D, "rotation", deg_to_rad(360), 0.5)
    .tween_property($Sprite2D, "scale", Vector2(2, 2), 0.5)
```

### 3. 缓动函数（Easing）

```gdscript
var tween = create_tween()
tween.set_ease(Tween.EASE_IN_OUT)  # 缓入缓出
tween.set_trans(Tween.TRANS_SINE)  # 正弦曲线

# 常用缓动类型
# TRANS_LINEAR   - 线性
# TRANS_SINE     - 正弦（平滑）
# TRANS_QUINT    - 5 次方（快速）
# TRANS_QUAD     - 2 次方（中等）
# TRANS_CUBIC    - 3 次方（标准）
# TRANS_CIRC     - 圆形（先快后慢/先慢后快）
# TRANS_BOUNCE   - 弹跳效果
# TRANS_ELASTIC  - 弹性效果

# 缓动方向
# EASE_IN    - 缓入（慢→快）
# EASE_OUT   - 缓出（快→慢）
# EASE_IN_OUT - 缓入缓出（慢→快→慢）
```

### 4. 回调函数

```gdscript
var tween = create_tween()

# 在插值前执行
tween.tween_callback(func(): print("开始移动"))

# 属性插值
tween.tween_property($Sprite2D, "position", Vector2(100, 100), 1.0)

# 在插值后执行
tween.tween_callback(func(): print("移动完成"))

# 延迟执行
tween.tween_interval(0.5)  # 等待 0.5 秒
tween.tween_callback(func(): print("延迟完成"))
```

---

## 🔧 高级用法

### 1. 并行与串行

```gdscript
var tween = create_tween()

# 串行（默认）- 按顺序执行
tween
    .tween_property($Sprite2D, "position", Vector2(100, 0), 0.5)
    .tween_property($Sprite2D, "rotation", deg_to_rad(180), 0.5)
    .tween_property($Sprite2D, "scale", Vector2(2, 2), 0.5)

# 并行 - 同时执行
var tween_parallel = create_tween().set_parallel(true)
tween_parallel
    .tween_property($Sprite2D, "position", Vector2(100, 0), 0.5)
    .tween_property($Sprite2D, "rotation", deg_to_rad(180), 0.5)
    .tween_property($Sprite2D, "scale", Vector2(2, 2), 0.5)

# 混合使用
var tween = create_tween()
# 第一步：移动
tween.tween_property($Sprite2D, "position", Vector2(100, 0), 0.5)

# 第二步：旋转 + 缩放（并行）
var parallel = tween.create_chained_tween().set_parallel(true)
parallel
    .tween_property($Sprite2D, "rotation", deg_to_rad(180), 0.5)
    .tween_property($Sprite2D, "scale", Vector2(2, 2), 0.5)
```

### 2. 方法插值

```gdscript
# 插值方法参数
var tween = create_tween()
tween.tween_method(
    func(value): $Sprite2D.modulate.a = value,  # 接收插值的方法
    1.0,  # 起始值
    0.0,  # 结束值
    0.5   # 持续时间
)

# 适用于无法直接 tween_property 的情况
```

### 3. 循环与重复

```gdscript
var tween = create_tween().set_loops()  # 无限循环
tween
    .tween_property($Sprite2D, "position", Vector2(100, 0), 0.5)
    .tween_property($Sprite2D, "position", Vector2(0, 0), 0.5)

# 指定循环次数
var tween = create_tween().set_loops(3)  # 循环 3 次

# 倒带（反向播放）
var tween = create_tween()
tween.tween_property($Sprite2D, "position", Vector2(100, 0), 0.5)
tween.tween_callback(tween.reverse)  # 反向播放
```

### 4. 停止与控制

```gdscript
var tween = create_tween()
tween.tween_property($Sprite2D, "position", Vector2(100, 0), 1.0)

# 暂停
tween.paused = true

# 恢复
tween.paused = false

# 停止
tween.stop()

# 杀死（立即结束）
tween.kill()

# 检查状态
if tween.is_running():
    print("Tween 正在运行")

if tween.is_valid():
    print("Tween 有效")
```

---

## 📊 实战示例

### 1. UI 按钮悬停效果

```gdscript
func _on_button_mouse_entered():
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property($Button, "scale", Vector2(1.1, 1.1), 0.2)

func _on_button_mouse_exited():
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property($Button, "scale", Vector2(1, 1), 0.2)
```

### 2. 淡入淡出过渡

```gdscript
func fade_out(duration: float = 0.5):
    var tween = create_tween()
    tween.tween_property($ColorRect, "modulate:a", 1.0, duration)

func fade_in(duration: float = 0.5):
    var tween = create_tween()
    tween.tween_property($ColorRect, "modulate:a", 0.0, duration)

# 场景切换
func transition_to_scene(scene_path: String):
    await fade_out(0.5)
    get_tree().change_scene_to_file(scene_path)
    await fade_in(0.5)
```

### 3. 平滑摄像机跟随

```gdscript
func follow_target(target: Node2D):
    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property($Camera2D, "position", target.global_position, 0.5)
```

### 4. 弹跳动画

```gdscript
func bounce_animation(node: Node2D):
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BOUNCE)
    
    # 向上弹跳
    tween.tween_property(node, "position:y", node.position.y - 50, 0.3)
    # 落回原位
    tween.tween_property(node, "position:y", node.position.y, 0.3)
```

### 5. 连击数字弹出

```gdscript
func show_combo_text(combo_count: int):
    var text = $ComboText
    text.text = "COMBO x%d" % combo_count
    text.modulate.a = 1.0
    text.scale = Vector2(1.5, 1.5)
    
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    
    # 弹出
    tween.tween_property(text, "scale", Vector2(1, 1), 0.3)
    # 淡出
    tween.tween_property(text, "modulate:a", 0, 0.3)
    # 隐藏
    tween.tween_callback(func(): text.visible = false)
```

---

## ⚠️ 常见问题

### 1. Tween 不生效

**问题**: Tween 创建后没有效果

**解决方案**:
```gdscript
# ❌ 错误：Tween 没有添加到场景树
var tween = Tween.new()
tween.tween_property($Sprite2D, "position", Vector2(100, 100), 1.0)

# ✅ 正确：使用 create_tween() 或手动添加
var tween = create_tween()  # 自动添加到当前节点
# 或者
var tween = Tween.new()
add_child(tween)  # 手动添加到场景树
```

### 2. Tween 被垃圾回收

**问题**: Tween 中途停止

**解决方案**:
```gdscript
# ❌ 错误：局部变量可能被垃圾回收
func start_animation():
    var tween = create_tween()
    tween.tween_property($Sprite2D, "position", target, 1.0)
    # 函数结束后 tween 可能被回收

# ✅ 正确：使用成员变量
var my_tween: Tween

func start_animation():
    my_tween = create_tween()
    my_tween.tween_property($Sprite2D, "position", target, 1.0)
```

### 3. Tween 累积

**问题**: 多次触发导致动画累积

**解决方案**:
```gdscript
var my_tween: Tween

func start_animation():
    # 先杀死旧的 Tween
    if my_tween and my_tween.is_valid():
        my_tween.kill()
    
    # 创建新的 Tween
    my_tween = create_tween()
    my_tween.tween_property($Sprite2D, "position", target, 1.0)
```

---

## 🔗 相关资源

### Base 层来源
- [插值系统](../../base/animation-system/) - 动画系统基础

### Wiki 层相关
- [插值指南](../guides/interpolation-guide.md) - 插值完整教程
- [Bezier 曲线指南](../guides/bezier-curves-guide.md) - 高级插值
- [UI 输入处理指南](../guides/ui-input-handling.md) - UI 动画
- [玩家实体设计](../entities/player.md) - 平滑移动
- [投射物实体设计](../entities/projectile.md) - 效果动画

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
