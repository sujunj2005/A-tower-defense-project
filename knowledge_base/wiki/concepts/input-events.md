# 输入事件核心概念

> **适用版本**: Godot 4.x  
> **来源**: [08A_InputEvent.md](../base/input-system/08A_InputEvent.md)  
> **最后更新**: 2026-04-07

---

## 📖 概述

Godot 使用 `InputEvent` 类型处理所有输入，包括键盘、鼠标、手柄、触摸等。输入事件通过节点树传播，每个节点都有机会处理事件。

**核心优势**:
- 统一的输入处理机制
- 灵活的事件传播和拦截
- 支持多种输入设备
- 可与 InputMap 配合实现抽象动作

---

## 🎯 输入事件流程

### 事件传播顺序

输入事件按照以下顺序在节点树中传播：

```
用户输入 → DisplayServer → Window → Viewport
    ↓
1. _input() - 所有节点首先接收
    ↓
2. Control._gui_input() - GUI 控件接收
    ↓
3. _shortcut_input() - 快捷键处理
    ↓
4. _unhandled_key_input() - 未处理的键盘输入
    ↓
5. _unhandled_input() - 未处理的输入（游戏逻辑推荐）
```

### 传播流程图

```
用户输入
    ↓
DisplayServer
    ↓
Window
    ↓
Viewport
    ↓
┌─────────────────────────────────────────┐
│ _input() → GUI → _shortcut_input() →   │
│ _unhandled_key_input() → _unhandled_input() │
└─────────────────────────────────────────┘
```

### 停止传播

```gdscript
func _input(event):
    if event.is_action("ui_accept"):
        get_viewport().set_input_as_handled()
        # 事件不会继续传播到后续回调
```

---

## 🔧 InputEvent 类型

### 事件类型表

| 事件类型 | 说明 | 常用场景 |
|----------|------|----------|
| `InputEvent` | 基类 | 所有输入事件的父类 |
| `InputEventKey` | 键盘事件 | 按键按下/释放 |
| `InputEventMouseButton` | 鼠标点击 | 左键/右键/中键点击 |
| `InputEventMouseMotion` | 鼠标移动 | 鼠标位置变化 |
| `InputEventJoypadMotion` | 手柄摇杆 | 摇杆移动/扳机 |
| `InputEventJoypadButton` | 手柄按钮 | 手柄按键按下 |
| `InputEventScreenTouch` | 触摸按下 | 触摸屏点击 |
| `InputEventScreenDrag` | 触摸拖动 | 触摸屏拖动 |
| `InputEventMagnifyGesture` | 缩放手势 | 双指缩放 |
| `InputEventPanGesture` | 平移手势 | 双指平移 |
| `InputEventMIDI` | MIDI 输入 | 音乐设备输入 |
| `InputEventShortcut` | 快捷键 | 快捷键触发 |
| `InputEventAction` | 动作事件 | InputMap 动作 |

### 键盘事件示例

```gdscript
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_SPACE:
            print("空格键按下")
        
        # 检查修饰键
        if event.shift_pressed:
            print("Shift 被按下")
        
        if event.ctrl_pressed:
            print("Ctrl 被按下")
```

### 鼠标事件示例

```gdscript
func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("左键点击位置：", event.position)
    
    if event is InputEventMouseMotion:
        print("鼠标移动：", event.relative)
        print("鼠标绝对位置：", event.position)
```

### 手柄事件示例

```gdscript
func _unhandled_input(event):
    if event is InputEventJoypadButton:
        if event.pressed and event.button_index == JOY_BUTTON_A:
            print("A 键按下")
    
    if event is InputEventJoypadMotion:
        if event.axis == JOY_AXIS_LEFT_X:
            print("左摇杆 X：", event.axis_value)
```

---

## 📡 输入回调

### _input

最先接收所有输入事件，在 GUI 之前处理：

```gdscript
func _input(event):
    # 在 GUI 之前处理
    # 适合全局快捷键、截图等
    pass
```

**适用场景**:
- 全局快捷键（截图、暂停）
- 需要在 GUI 之前拦截的输入
- 调试输入

### _unhandled_input

GUI 未处理的事件，适合游戏逻辑：

```gdscript
func _unhandled_input(event):
    # 游戏输入逻辑
    if event.is_action_pressed("attack"):
        attack()
    
    if event.is_action_pressed("jump"):
        jump()
```

**适用场景**:
- 游戏角色控制
- 战斗系统输入
- 相机控制

### _shortcut_input

处理快捷键：

```gdscript
func _shortcut_input(event):
    if event.is_action_pressed("save"):
        save_game()
        get_viewport().set_input_as_handled()
```

**适用场景**:
- 编辑器快捷键
- 快速保存/加载
- UI 快捷键

### _gui_input

UI 控件的输入处理：

```gdscript
func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("控件被点击")
```

**适用场景**:
- 按钮点击
- 拖放操作
- UI 交互

### 回调选择建议

| 回调 | 用途 | 推荐度 |
|------|------|--------|
| `_input` | 需要在 GUI 之前处理的输入 | 🟡 特殊场景 |
| `_gui_input` | UI 控件的输入 | 🟢 UI 专用 |
| `_shortcut_input` | 全局快捷键 | 🟡 快捷键 |
| `_unhandled_input` | 游戏逻辑输入 | 🔴 **推荐** |

---

## 🎮 输入动作

### 定义动作

在 **项目设置 → 输入映射** 中定义动作：

1. 打开项目设置
2. 切换到"输入映射"标签
3. 点击"+"添加新动作
4. 输入动作名称（如"jump"、"attack"）
5. 点击动作右侧的"+"添加按键绑定

### 检查动作状态

```gdscript
# 按下瞬间（仅一次）
if Input.is_action_just_pressed("jump"):
    jump()

# 按住状态（每帧返回 true）
if Input.is_action_pressed("move_right"):
    velocity.x += speed

# 释放瞬间（仅一次）
if Input.is_action_just_released("shoot"):
    release_arrow()
```

### 获取动作强度

```gdscript
# 用于手柄模拟摇杆（返回 0.0 到 1.0）
var strength = Input.get_action_strength("move_right")
velocity.x = strength * speed
```

### 获取方向向量

```gdscript
# 获取方向向量（自动归一化）
var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
velocity = direction * speed
```

### 程序生成输入事件

```gdscript
# 模拟按键按下
var ev = InputEventAction.new()
ev.action = "jump"
ev.pressed = true
Input.parse_input_event(ev)
```

---

## ⚠️ 常见踩坑

### 1. 在错误的回调中处理输入

**错误示例**:
```gdscript
# 在 _process 中检查事件（错误）
func _process(delta):
    if event is InputEventKey:  # event 未定义
        pass
```

**正确示例**:
```gdscript
# 在 _unhandled_input 中处理
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_SPACE:
            jump()
```

### 2. 忘记停止传播

```gdscript
# 需要拦截事件时
func _input(event):
    if event.is_action("ui_accept"):
        get_viewport().set_input_as_handled()  # 阻止继续传播
```

### 3. 混淆 is_action_pressed 和 is_action_just_pressed

```gdscript
# 错误：跳跃只在按下瞬间触发
func _physics_process(delta):
    if Input.is_action_just_pressed("jump"):  # 只在按下的帧触发
        velocity.y = jump_strength  # 但这里每帧都调用

# 正确：
func _unhandled_input(event):
    if event.is_action_just_pressed("jump"):
        velocity.y = jump_strength
```

---

## 🔗 相关概念

- **InputMap**: [input-map-guide.md](../wiki/guides/input-map-guide.md) - 输入映射指南
- **信号系统**: [signals-events.md](../wiki/concepts/signals-events.md) - 信号核心概念
- **UI 输入处理**: [ui-input-handling.md](../wiki/guides/ui-input-handling.md) - UI 输入实战

---

## 📚 参考资料

- **Base 层来源**: [08A_InputEvent.md](../base/input-system/08A_InputEvent.md)
- **Godot 官方文档**: [InputEvent 类参考](https://docs.godotengine.org/en/stable/classes/class_inputevent.html)
- **Godot 官方文档**: [Input 类参考](https://docs.godotengine.org/en/stable/classes/class_input.html)

---

**维护者**: Knowledge Base Administrator  
**页面版本**: 1.0
