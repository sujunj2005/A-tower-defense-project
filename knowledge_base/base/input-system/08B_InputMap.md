# Godot 4.x InputMap 输入映射

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/inputs/input_examples.rst

---

## 目录

1. [InputMap 概述](#1-inputmap-概述)
2. [事件 vs 轮询](#2-事件-vs-轮询)
3. [定义输入动作](#3-定义输入动作)
4. [检查输入状态](#4-检查输入状态)
5. [获取输入值](#5-获取输入值)
6. [常见输入示例](#6-常见输入示例)

---

## 1. InputMap 概述

### 1.1 什么是 InputMap

InputMap 是 Godot 的输入系统，允许将物理按键（键盘、鼠标、手柄）映射到**抽象动作**。

### 1.2 使用 InputMap 的优势

- **跨平台兼容**：同一动作可绑定不同平台的按键
- **可重配置**：玩家可以自定义按键
- **解耦**：代码不依赖具体按键

---

## 2. 事件 vs 轮询

### 2.1 两种方式

| 方式 | 方法 | 适用场景 |
|------|------|----------|
| 事件驱动 | `_input()` / `_unhandled_input()` | 按键瞬间触发（跳跃、攻击） |
| 状态轮询 | `Input.is_action_*()` | 持续检测（移动、瞄准） |

```gdscript
# 事件驱动 - 跳跃
func _input(event):
    if event.is_action_pressed("jump"):
        jump()

# 状态轮询 - 移动
func _physics_process(delta):
    if Input.is_action_pressed("move_right"):
        position.x += speed * delta
```

---

## 3. 定义输入动作

### 3.1 在编辑器中定义

1. **项目 → 项目设置 → 输入映射**
2. 点击 "+" 添加新动作
3. 设置动作名称和绑定按键

### 3.2 常用内置动作

| 动作 | 说明 |
|------|------|
| `ui_accept` | 确认（Enter/Space/A） |
| `ui_cancel` | 取消（Escape/B） |
| `ui_left` | 左方向键 |
| `ui_right` | 右方向键 |
| `ui_up` | 上方向键 |
| `ui_down` | 下方向键 |
| `ui_select` | 选择（Space/Enter） |

---

## 4. 检查输入状态

### 4.1 is_action_pressed()

按下时返回 true：

```gdscript
if Input.is_action_pressed("jump"):
    # 按住期间持续返回 true
    pass
```

### 4.2 is_action_just_pressed()

按下瞬间返回 true（仅一次）：

```gdscript
if Input.is_action_just_pressed("jump"):
    # 只在按下的那一帧返回 true
    jump()
```

### 4.3 is_action_just_released()

释放瞬间返回 true：

```gdscript
if Input.is_action_just_released("attack"):
    release_arrow()
```

> **踩坑点**：`is_action_pressed` 在按住期间每帧都返回 true。如果需要只执行一次，使用 `is_action_just_pressed`。

---

## 5. 获取输入值

### 5.1 get_action_strength()

获取动作强度（0.0 到 1.0）：

```gdscript
var strength = Input.get_action_strength("move_right")
velocity.x = strength * max_speed
```

### 5.2 get_vector()

获取方向向量：

```gdscript
var direction = Input.get_vector(
    "move_left", "move_right", "move_up", "move_down"
)
velocity = direction * speed
```

> **踩坑点**：`get_vector()` 自动处理对角线移动的归一化，对角线速度不会更快。

### 5.3 get_axis()

获取单个轴的值（-1, 0, 或 1）：

```gdscript
var horizontal = Input.get_axis("move_left", "move_right")
# 返回 -1（左）、0（无）、或 1（右）
```

---

## 6. 常见输入示例

### 6.1 键盘输入

```gdscript
func _input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            get_tree().quit()
        
        if event.pressed:
            match event.keycode:
                KEY_A: move_left()
                KEY_D: move_right()
                KEY_W: move_up()
                KEY_S: move_down()
```

### 6.2 鼠标输入

```gdscript
func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            shoot()
    
    if event is InputEventMouseMotion:
        aim_at(event.position)
```

### 6.3 手柄输入

```gdscript
func _input(event):
    if event is InputEventJoypadButton:
        if event.button_index == JOY_BUTTON_A and event.pressed:
            jump()
    
    if event is InputEventJoypadMotion:
        if event.axis == JOY_AXIS_LEFT_X:
            horizontal_input = event.axis_value
```

### 6.4 触摸输入

```gdscript
func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            handle_touch(event.position)
    
    if event is InputEventScreenDrag:
        handle_drag(event.position, event.relative)
```

---

## 7. 自定义光标

### 7.1 隐藏默认光标

```gdscript
func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
```

### 7.2 设置自定义光标

```gdscript
func _ready():
    var cursor_image = load("res://cursor.png")
    var hotspot = Vector2(16, 16)  # 点击点位置
    Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, hotspot)
```

### 7.3 光标模式

| 模式 | 说明 |
|------|------|
| `MOUSE_MODE_VISIBLE` | 可见且可捕获 |
| `MOUSE_MODE_HIDDEN` | 隐藏但可捕获 |
| `MOUSE_MODE_CAPTURED` | 隐藏并锁定在窗口内 |

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/inputs/input_examples.rst`
