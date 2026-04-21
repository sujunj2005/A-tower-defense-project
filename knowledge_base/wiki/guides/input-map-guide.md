# 输入映射实战指南

> **适用版本**: Godot 4.x  
> **来源**: [08B_InputMap.md](../base/input-system/08B_InputMap.md)  
> **最后更新**: 2026-04-07

---

## 📖 概述

InputMap 是 Godot 的输入映射系统，允许将物理按键（键盘、鼠标、手柄）映射到**抽象动作**。这是实现跨平台兼容和可配置控制的核心机制。

**使用 InputMap 的优势**:
- ✅ **跨平台兼容**: 同一动作可绑定不同平台的按键
- ✅ **可重配置**: 玩家可以自定义按键
- ✅ **解耦**: 代码不依赖具体按键
- ✅ **多键绑定**: 一个动作可绑定多个按键

---

## 🎮 事件驱动 vs 状态轮询

### 两种输入检查方式

| 方式 | 方法 | 适用场景 | 示例 |
|------|------|----------|------|
| **事件驱动** | `_input()` / `_unhandled_input()` | 按键瞬间触发 | 跳跃、攻击、暂停 |
| **状态轮询** | `Input.is_action_*()` | 持续检测 | 移动、瞄准、加速 |

### 事件驱动示例

```gdscript
# 事件驱动 - 跳跃（只在按下瞬间触发）
func _unhandled_input(event):
    if event.is_action_pressed("jump"):
        jump()
    
    if event.is_action_pressed("attack"):
        attack()
```

**特点**:
- 只在按键按下/释放的瞬间触发
- 适合一次性动作
- 在 `_unhandled_input()` 回调中处理

### 状态轮询示例

```gdscript
# 状态轮询 - 移动（每帧检测）
func _physics_process(delta):
    var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = direction * speed
    
    if Input.is_action_pressed("sprint"):
        velocity *= 2.0  # 按住加速
```

**特点**:
- 每帧检测按键状态
- 适合持续性动作
- 在 `_physics_process()` 或 `_process()` 中处理

---

## ⚙️ 定义输入动作

### 在编辑器中定义

1. **项目 → 项目设置 → 输入映射**
2. 点击 **"+"** 添加新动作
3. 输入动作名称（如 `"jump"`, `"attack"`, `"move_right"`）
4. 点击动作右侧的 **"+"** 添加按键绑定
5. 按下要绑定的按键（支持键盘、鼠标、手柄）

### 常用内置动作

Godot 提供以下内置 UI 动作：

| 动作 | 说明 | 默认按键 |
|------|------|----------|
| `ui_accept` | 确认 | Enter/Space/A |
| `ui_cancel` | 取消 | Escape/B |
| `ui_left` | 左方向 | Left Arrow |
| `ui_right` | 右方向 | Right Arrow |
| `ui_up` | 上方向 | Up Arrow |
| `ui_down` | 下方向 | Down Arrow |
| `ui_select` | 选择 | Space/Enter |
| `ui_page_up` | 向上翻页 | Page Up |
| `ui_page_down` | 向下翻页 | Page Down |

---

## 🔍 检查输入状态

### is_action_pressed()

按下时返回 true（按住期间每帧都返回）：

```gdscript
func _physics_process(delta):
    if Input.is_action_pressed("move_right"):
        position.x += speed * delta
    
    # 按住期间持续返回 true
    if Input.is_action_pressed("charge_attack"):
        charge_power += delta
```

### is_action_just_pressed()

按下瞬间返回 true（仅一次）：

```gdscript
func _unhandled_input(event):
    if Input.is_action_just_pressed("jump"):
        # 只在按下的那一帧返回 true
        velocity.y = jump_strength
    
    if Input.is_action_just_pressed("reload"):
        reload_weapon()
```

### is_action_just_released()

释放瞬间返回 true：

```gdscript
func _unhandled_input(event):
    if Input.is_action_just_released("attack"):
        # 释放时触发动作
        release_arrow()
    
    if Input.is_action_just_released("charge_attack"):
        # 释放蓄力攻击
        perform_charged_attack(charge_power)
        charge_power = 0
```

> ⚠️ **踩坑点**: `is_action_pressed` 在按住期间每帧都返回 true。如果需要只执行一次，使用 `is_action_just_pressed`。

---

## 📊 获取输入值

### get_action_strength()

获取动作强度（0.0 到 1.0）：

```gdscript
# 用于手柄模拟按键（如扳机键）
var strength = Input.get_action_strength("accelerate")
velocity.z = strength * max_speed

# 键盘按键通常返回 0.0 或 1.0
```

### get_vector()

获取方向向量（自动归一化）：

```gdscript
# 获取 2D 方向向量
var direction = Input.get_vector(
    "move_left",   # 左
    "move_right",  # 右
    "move_up",     # 上
    "move_down"    # 下
)
velocity = direction * speed
```

> ✅ **优势**: `get_vector()` 自动处理对角线移动的归一化，对角线速度不会更快。

### get_axis()

获取单个轴的值（-1, 0, 或 1）：

```gdscript
# 获取水平轴（返回 -1、0、或 1）
var horizontal = Input.get_axis("move_left", "move_right")
# -1: 左，0: 无，1: 右

# 获取垂直轴
var vertical = Input.get_axis("move_up", "move_down")
# -1: 上，0: 无，1: 下
```

---

## 🎯 常见输入示例

### 键盘输入

```gdscript
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            get_tree().quit()
        
        if event.pressed:
            match event.keycode:
                KEY_A:
                    move_left()
                KEY_D:
                    move_right()
                KEY_W:
                    move_up()
                KEY_S:
                    move_down()
                KEY_SPACE:
                    jump()
```

### 鼠标输入

```gdscript
func _unhandled_input(event):
    # 鼠标点击
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            shoot()
        
        if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            aim()
    
    # 鼠标移动
    if event is InputEventMouseMotion:
        aim_at(event.position)
        print("鼠标位置：", event.position)
        print("相对移动：", event.relative)
```

### 手柄输入

```gdscript
func _unhandled_input(event):
    # 手柄按钮
    if event is InputEventJoypadButton:
        if event.button_index == JOY_BUTTON_A and event.pressed:
            jump()
        
        if event.button_index == JOY_BUTTON_X and event.pressed:
            attack()
    
    # 手柄摇杆
    if event is InputEventJoypadMotion:
        if event.axis == JOY_AXIS_LEFT_X:
            horizontal_input = event.axis_value
            print("左摇杆 X：", event.axis_value)
        
        if event.axis == JOY_AXIS_LEFT_Y:
            vertical_input = -event.axis_value  # Y 轴需要反转
            print("左摇杆 Y：", event.axis_value)
```

### 触摸输入

```gdscript
func _unhandled_input(event):
    # 触摸按下
    if event is InputEventScreenTouch:
        if event.pressed:
            handle_touch(event.position)
            print("触摸位置：", event.position)
    
    # 触摸拖动
    if event is InputEventScreenDrag:
        handle_drag(event.position, event.relative)
        print("拖动位置：", event.position)
        print("拖动距离：", event.relative)
```

---

## 🖱️ 自定义光标

### 隐藏默认光标

```gdscript
func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
```

### 设置自定义光标

```gdscript
func _ready():
    var cursor_image = load("res://images/cursor.png")
    var hotspot = Vector2(16, 16)  # 点击点位置（ hotspot 是光标图片的热点坐标）
    Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, hotspot)
```

### 光标模式

| 模式 | 常量 | 说明 | 适用场景 |
|------|------|------|----------|
| 可见 | `MOUSE_MODE_VISIBLE` | 可见且可捕获 | 默认模式、UI 界面 |
| 隐藏 | `MOUSE_MODE_HIDDEN` | 隐藏但可捕获 | FPS 游戏、第一人称 |
| 捕获 | `MOUSE_MODE_CAPTURED` | 隐藏并锁定在窗口内 | FPS 游戏、相机控制 |
| 约束 | `MOUSE_MODE_CONFINED` | 可见但约束在窗口内 | RTS 游戏、策略游戏 |

### 模式切换示例

```gdscript
func _unhandled_input(event):
    if event.is_action_pressed("toggle_mouse_mode"):
        match Input.get_mouse_mode():
            Input.MOUSE_MODE_VISIBLE:
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            Input.MOUSE_MODE_CAPTURED:
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
```

---

## ⚠️ 常见踩坑

### 1. 忘记在项目设置中定义动作

**错误**: 直接在代码中使用未定义的动作
```gdscript
# 错误：动作 "jump" 未在项目设置中定义
if Input.is_action_just_pressed("jump"):
    jump()
```

**解决**: 先在项目设置 → 输入映射中添加动作

### 2. 在 _process 中使用事件驱动

**错误**:
```gdscript
# 错误：在 _process 中无法接收事件
func _process(delta):
    if event.is_action_pressed("jump"):  # event 未定义
        jump()
```

**正确**:
```gdscript
# 正确：在 _unhandled_input 中处理事件
func _unhandled_input(event):
    if event.is_action_pressed("jump"):
        jump()
```

### 3. get_vector 参数顺序错误

**错误**:
```gdscript
# 错误：参数顺序混乱
var direction = Input.get_vector("move_up", "move_down", "move_left", "move_right")
```

**正确**:
```gdscript
# 正确：left, right, up, down
var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
```

### 4. 手柄 Y 轴未反转

**错误**:
```gdscript
# 错误：手柄 Y 轴方向反了
var vertical = Input.get_axis("move_up", "move_down")
```

**正确**:
```gdscript
# 正确：手柄 Y 轴需要反转
var vertical = -Input.get_action_strength("move_down") + Input.get_action_strength("move_up")
```

---

## 🎮 实战示例

### 2D 角色控制器

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_strength: float = -400.0

var gravity: float = 980.0

func _physics_process(delta):
    # 应用重力
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # 获取输入方向
    var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # 水平移动
    if direction:
        velocity.x = direction.x * speed
    
    # 跳跃（事件驱动）
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_strength
    
    move_and_slide()
```

### 相机控制器（FPS）

```gdscript
extends Node3D

@export var mouse_sensitivity: float = 0.003
@export var camera_rotation: Vector3 = Vector3.ZERO

var yaw = 0.0
var pitch = 0.0

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    # 鼠标移动（状态轮询）
    if event is InputEventMouseMotion:
        yaw -= event.relative.x * mouse_sensitivity
        pitch -= event.relative.y * mouse_sensitivity
        
        # 限制垂直视角
        pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
        
        # 应用旋转
        rotation_degrees.y = rad_to_deg(yaw)
        $Camera3D.rotation_degrees.x = rad_to_deg(pitch)
    
    # 鼠标点击
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            shoot()
```

---

## 🔗 相关概念

- **输入事件**: [input-events.md](../wiki/concepts/input-events.md) - 输入事件核心概念
- **UI 输入处理**: [ui-input-handling.md](../wiki/guides/ui-input-handling.md) - UI 输入实战
- **2D 移动**: [2d-movement-guide.md](../wiki/guides/2d-movement-guide.md) - 2D 移动实现

---

## 📚 参考资料

- **Base 层来源**: [08B_InputMap.md](../base/input-system/08B_InputMap.md)
- **Godot 官方文档**: [Input 类参考](https://docs.godotengine.org/en/stable/classes/class_input.html)
- **Godot 官方文档**: [InputMap 类参考](https://docs.godotengine.org/en/stable/classes/class_inputmap.html)

---

**维护者**: Knowledge Base Administrator  
**页面版本**: 1.0
