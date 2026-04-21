# Godot 4.x 输入事件处理

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/inputs/inputevent.rst

---

## 目录

1. [输入事件概述](#1-输入事件概述)
2. [输入事件流程](#2-输入事件流程)
3. [InputEvent 类型](#3-inputevent-类型)
4. [输入回调](#4-输入回调)
5. [输入动作](#5-输入动作)

---

## 1. 输入事件概述

Godot 使用 `InputEvent` 类型处理所有输入，包括键盘、鼠标、手柄、触摸等。

### 1.1 基本用法

```gdscript
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            get_tree().quit()
```

### 1.2 使用 InputMap

```gdscript
func _process(delta):
    if Input.is_action_pressed("ui_right"):
        # 向右移动
```

---

## 2. 输入事件流程

### 2.1 事件传播顺序

1. **_input**：所有节点首先接收
2. **Control._gui_input**：GUI 控件接收
3. **_shortcut_input**：快捷键处理
4. **_unhandled_key_input**：未处理的键盘输入
5. **_unhandled_input**：未处理的输入（游戏逻辑推荐）

### 2.2 事件传播图

```
用户输入 → DisplayServer → Window → Viewport
    ↓
_input() → GUI → _shortcut_input() → _unhandled_key_input() → _unhandled_input()
```

### 2.3 停止传播

```gdscript
func _input(event):
    if event.is_action("ui_accept"):
        get_viewport().set_input_as_handled()
        # 事件不会继续传播
```

---

## 3. InputEvent 类型

### 3.1 事件类型表

| 事件类型 | 说明 |
|----------|------|
| `InputEvent` | 基类 |
| `InputEventKey` | 键盘事件 |
| `InputEventMouseButton` | 鼠标点击 |
| `InputEventMouseMotion` | 鼠标移动 |
| `InputEventJoypadMotion` | 手柄摇杆 |
| `InputEventJoypadButton` | 手柄按钮 |
| `InputEventScreenTouch` | 触摸按下 |
| `InputEventScreenDrag` | 触摸拖动 |
| `InputEventMagnifyGesture` | 缩放手势 |
| `InputEventPanGesture` | 平移手势 |
| `InputEventMIDI` | MIDI 输入 |
| `InputEventShortcut` | 快捷键 |
| `InputEventAction` | 动作事件 |

### 3.2 键盘事件

```gdscript
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_SPACE:
            print("空格键按下")
        
        # 检查修饰键
        if event.shift_pressed:
            print("Shift 被按下")
```

### 3.3 鼠标事件

```gdscript
func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("左键点击位置：", event.position)
    
    if event is InputEventMouseMotion:
        print("鼠标移动：", event.relative)
```

### 3.4 手柄事件

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

## 4. 输入回调

### 4.1 _input

最先接收所有输入事件：

```gdscript
func _input(event):
    # 在 GUI 之前处理
    pass
```

### 4.2 _unhandled_input

GUI 未处理的事件，适合游戏逻辑：

```gdscript
func _unhandled_input(event):
    # 游戏输入逻辑
    if event.is_action_pressed("attack"):
        attack()
```

### 4.3 _shortcut_input

处理快捷键：

```gdscript
func _shortcut_input(event):
    if event.is_action_pressed("save"):
        save_game()
        get_viewport().set_input_as_handled()
```

### 4.4 回调选择建议

| 回调 | 用途 |
|------|------|
| `_input` | 需要在 GUI 之前处理的输入 |
| `_gui_input` | UI 控件的输入 |
| `_shortcut_input` | 全局快捷键 |
| `_unhandled_input` | 游戏逻辑输入（推荐） |

---

## 5. 输入动作

### 5.1 定义动作

在 **项目设置 → 输入映射** 中定义动作。

### 5.2 检查动作

```gdscript
# 按下瞬间
if Input.is_action_just_pressed("jump"):
    jump()

# 按住状态
if Input.is_action_pressed("move_right"):
    velocity.x += speed

# 释放瞬间
if Input.is_action_just_released("shoot"):
    release_arrow()
```

### 5.3 获取动作强度

```gdscript
# 用于手柄模拟摇杆
var strength = Input.get_action_strength("move_right")
velocity.x = strength * speed
```

### 5.4 获取向量

```gdscript
# 获取方向向量
var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
velocity = direction * speed
```

### 5.5 程序生成输入事件

```gdscript
var ev = InputEventAction.new()
ev.action = "jump"
ev.pressed = true
Input.parse_input_event(ev)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/inputs/inputevent.rst`
