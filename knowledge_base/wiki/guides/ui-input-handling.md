# UI 输入处理指南

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [07D_UI_Input_Handling.md](../base/ui-system/07D_UI_Input_Handling.md)

---

## 📋 概述

本指南详细介绍 Godot 4.x Control 节点的输入处理机制，包括 `_gui_input` 回调、鼠标过滤、焦点控制和通知系统。

**核心特点**:
- Control 节点有专门的输入处理方法 `_gui_input`
- 只在特定条件下触发（鼠标在上方/按钮按下/有焦点）
- 支持鼠标、键盘和手柄输入

---

## 🎯 _gui_input 回调

### 触发条件

`_gui_input` 在以下情况触发：
1. 鼠标指针在控件上方
2. 按钮在控件上按下（控件捕获输入直到释放）
3. 控件有键盘/手柄焦点

### 基本用法

```gdscript
extends Control

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("左键点击")
            accept_event()  # 停止传播
```

### accept_event()

调用后事件不会继续传播：

```gdscript
func _gui_input(event):
    if event.is_action_pressed("ui_accept"):
        accept_event()
        do_something()
```

> **提示**: 如果不调用 `accept_event()`，事件会继续向上传播给父控件。

### 键盘输入处理

```gdscript
func _gui_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ENTER:
            print("Enter 键按下")
            accept_event()
```

---

## 🖱️ 鼠标过滤

### mouse_filter 属性

| 值 | 常量 | 说明 |
|----|------|------|
| `0` | `MOUSE_FILTER_STOP` | 接收事件并停止传播 |
| `1` | `MOUSE_FILTER_PASS` | 接收事件但继续传播 |
| `2` | `MOUSE_FILTER_IGNORE` | 不接收事件，穿透 |

### 使用场景

#### 1. 点击穿透（忽略鼠标事件）

```gdscript
# 让鼠标事件穿透控件，传递给下层
mouse_filter = Control.MOUSE_FILTER_IGNORE
```

**适用场景**: 半透明提示框、装饰性 UI 元素

#### 2. 接收但不阻止传播

```gdscript
# 接收事件但允许下层控件也接收
mouse_filter = Control.MOUSE_FILTER_PASS
```

**适用场景**: 需要同时处理多个重叠控件的点击

#### 3. 接收并阻止传播（默认）

```gdscript
# 默认行为，接收并停止事件传播
mouse_filter = Control.MOUSE_FILTER_STOP
```

**适用场景**: 按钮、面板等需要独占输入的控件

---

## 🎯 焦点控制

### focus_mode 属性

| 值 | 常量 | 说明 |
|----|------|------|
| `0` | `FOCUS_NONE` | 无法获得焦点 |
| `1` | `FOCUS_CLICK` | 点击获得焦点 |
| `2` | `FOCUS_ALL` | 点击或 Tab 获得焦点 |

### 设置焦点

```gdscript
# 允许 Tab 聚焦
focus_mode = Control.FOCUS_ALL

# 手动获取焦点
grab_focus()

# 释放焦点
release_focus()
```

### 焦点导航

```gdscript
# 设置焦点邻居（方向键导航）
focus_neighbor_left = neighbor_path
focus_neighbor_right = neighbor_path
focus_neighbor_top = neighbor_path
focus_neighbor_bottom = neighbor_path

# 设置下一个/上一个焦点（Tab 键导航）
focus_next = next_path
focus_previous = prev_path
```

### 焦点导航示例

```gdscript
# 设置表单字段的焦点顺序
@onready var name_input = $VBoxContainer/NameInput
@onready var email_input = $VBoxContainer/EmailInput
@onready var submit_button = $VBoxContainer/SubmitButton

func _ready():
    # 设置 Tab 顺序
    name_input.focus_next = email_input.get_path()
    email_input.focus_next = submit_button.get_path()
    submit_button.focus_previous = email_input.get_path()
    
    # 设置方向键导航
    name_input.focus_neighbor_right = email_input.get_path()
    email_input.focus_neighbor_left = name_input.get_path()
```

---

## 🔔 通知系统

### 常用通知

```gdscript
func _notification(what):
    match what:
        NOTIFICATION_MOUSE_ENTER:
            print("鼠标进入")
        NOTIFICATION_MOUSE_EXIT:
            print("鼠标离开")
        NOTIFICATION_FOCUS_ENTER:
            print("获得焦点")
        NOTIFICATION_FOCUS_EXIT:
            print("失去焦点")
```

### 完整通知列表

| 通知 | 常量 | 说明 |
|------|------|------|
| `NOTIFICATION_MOUSE_ENTER` | 40 | 鼠标进入控件 |
| `NOTIFICATION_MOUSE_EXIT` | 41 | 鼠标离开控件 |
| `NOTIFICATION_FOCUS_ENTER` | 42 | 获得焦点 |
| `NOTIFICATION_FOCUS_EXIT` | 43 | 失去焦点 |
| `NOTIFICATION_THEME_CHANGED` | 0 | 主题改变 |
| `NOTIFICATION_VISIBILITY_CHANGED` | 23 | 可见性改变 |
| `NOTIFICATION_RESIZED` | 90 | 尺寸改变 |
| `NOTIFICATION_MODAL_CLOSE` | 44 | 模态窗口关闭 |

### 实际应用示例

```gdscript
extends Control

func _notification(what):
    match what:
        NOTIFICATION_MOUSE_ENTER:
            # 鼠标悬停高亮
            modulate = Color(1.2, 1.2, 1.2)
        NOTIFICATION_MOUSE_EXIT:
            # 恢复原色
            modulate = Color.WHITE
        NOTIFICATION_FOCUS_ENTER:
            # 获得焦点时显示边框
            add_theme_stylebox_override("panel", focused_style)
        NOTIFICATION_FOCUS_EXIT:
            # 失去焦点时移除边框
            remove_theme_stylebox_override("panel")
```

---

## 📊 实战示例

### 1. 可点击按钮（自定义行为）

```gdscript
extends Control

signal clicked

var hover_color = Color(0.9, 0.9, 0.9)
var normal_color = Color.WHITE

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            clicked.emit()
            accept_event()

func _notification(what):
    if what == NOTIFICATION_MOUSE_ENTER:
        modulate = hover_color
    elif what == NOTIFICATION_MOUSE_EXIT:
        modulate = normal_color
```

### 2. 键盘快捷键处理

```gdscript
extends Control

func _gui_input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ESCAPE:
                on_escape_pressed()
                accept_event()
            KEY_ENTER, KEY_KP_ENTER:
                on_enter_pressed()
                accept_event()
            KEY_TAB:
                on_tab_pressed()
                # 不 accept，让焦点系统处理

func on_escape_pressed():
    print("Escape 键按下")

func on_enter_pressed():
    print("Enter 键按下")
```

### 3. 焦点管理（表单验证）

```gdscript
extends LineEdit

func _notification(what):
    if what == NOTIFICATION_FOCUS_EXIT:
        # 失去焦点时验证输入
        if not validate_input():
            release_focus()
            grab_focus()  # 重新获取焦点，要求修正

func validate_input():
    if text.is_empty():
        push_error("输入不能为空")
        return false
    return true
```

### 4. 拖拽区域

```gdscript
extends Control

signal drag_started
signal drag_ended
var is_dragging = false

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                is_dragging = true
                drag_started.emit()
                accept_event()
            else:
                is_dragging = false
                drag_ended.emit()
                accept_event()
    elif event is InputEventMouseMotion and is_dragging:
        # 处理拖拽移动
        handle_drag(event.relative)
        accept_event()

func handle_drag(relative: Vector2):
    position += relative
```

---

## 🎯 最佳实践

### 1. 事件处理原则

- ✅ 只处理自己关心的事件类型
- ✅ 处理后调用 `accept_event()` 阻止传播
- ✅ 不处理的事件不要调用 `accept_event()`
- ✅ 使用 `is_action_pressed()` 而非硬编码按键

### 2. 焦点管理原则

- ✅ 为可交互控件设置 `FOCUS_ALL`
- ✅ 为装饰性控件设置 `FOCUS_NONE`
- ✅ 明确设置焦点导航顺序
- ✅ 在表单验证中合理使用 `grab_focus()`

### 3. 鼠标过滤原则

- ✅ 默认使用 `MOUSE_FILTER_STOP`
- ✅ 需要穿透时使用 `MOUSE_FILTER_IGNORE`
- ✅ 需要多层响应时使用 `MOUSE_FILTER_PASS`

---

## ⚠️ 常见踩坑

### 1. _gui_input 不触发

**问题**: `_gui_input` 回调没有被调用

**原因**:
- 控件没有设置 `mouse_filter = MOUSE_FILTER_STOP`
- 父控件拦截了事件
- 控件被其他控件遮挡

**解决**:
```gdscript
# 确保控件能接收鼠标事件
mouse_filter = Control.MOUSE_FILTER_STOP
# 确保控件可见且可交互
visible = true
disable_mode = Control.DISABLE_MODE_INHERIT
```

### 2. 焦点无法获取

**问题**: `grab_focus()` 调用失败

**原因**:
- `focus_mode` 设置为 `FOCUS_NONE`
- 控件不可见或被禁用

**解决**:
```gdscript
# 设置焦点模式
focus_mode = Control.FOCUS_ALL
# 确保控件可见
visible = true
# 确保控件未被禁用
disable_mode = Control.DISABLE_MODE_INHERIT
# 然后获取焦点
grab_focus()
```

### 3. 事件重复处理

**问题**: 一个事件被多个控件处理

**原因**: 忘记调用 `accept_event()`

**解决**:
```gdscript
func _gui_input(event):
    if event is InputEventMouseButton and event.pressed:
        handle_click()
        accept_event()  # 重要：停止事件传播
```

---

## 🔗 相关链接

- **Base 层来源**: [07D_UI_Input_Handling.md](../base/ui-system/07D_UI_Input_Handling.md)
- **相关概念**: [UI 容器概念](./ui-containers.md)
- **相关概念**: [UI 尺寸和锚点概念](./ui-size-anchors.md)

---

## 📊 快速参考表

### _gui_input 事件类型

| 事件类型 | 检查方式 | 典型用途 |
|----------|---------|---------|
| 鼠标按钮 | `event is InputEventMouseButton` | 点击、双击 |
| 鼠标移动 | `event is InputEventMouseMotion` | 拖拽、悬停 |
| 键盘按下 | `event is InputEventKey and event.pressed` | 快捷键 |
| 键盘释放 | `event is InputEventKey and not event.pressed` | 按键释放 |
| 手柄按钮 | `event is InputEventJoypadButton` | 手柄输入 |
| 动作输入 | `event.is_action_pressed("action_name")` | 映射动作 |

### mouse_filter 对比

| 模式 | 接收事件 | 阻止传播 | 适用场景 |
|------|---------|---------|---------|
| `MOUSE_FILTER_STOP` | ✅ | ✅ | 默认，按钮/面板 |
| `MOUSE_FILTER_PASS` | ✅ | ❌ | 需要多层响应 |
| `MOUSE_FILTER_IGNORE` | ❌ | ❌ | 穿透，装饰元素 |

### focus_mode 对比

| 模式 | 点击获得 | Tab 获得 | 适用场景 |
|------|---------|---------|---------|
| `FOCUS_NONE` | ❌ | ❌ | 装饰性控件 |
| `FOCUS_CLICK` | ✅ | ❌ | 按钮（只需点击） |
| `FOCUS_ALL` | ✅ | ✅ | 输入框/可聚焦控件 |

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.7
