# Godot 4.x UI 输入处理

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/ui/gui_input_handling.rst

---

## 目录

1. [输入处理概述](#1-输入处理概述)
2. [_gui_input 回调](#2-_gui_input-回调)
3. [鼠标过滤](#3-鼠标过滤)
4. [焦点控制](#4-焦点控制)
5. [通知](#5-通知)

---

## 1. 输入处理概述

Control 节点有专门的输入处理方法 `_gui_input`，只在以下情况触发：

- 鼠标指针在控件上方
- 按钮在控件上按下（控件捕获输入直到释放）
- 控件有键盘/手柄焦点

---

## 2. _gui_input 回调

### 2.1 基本用法

```gdscript
extends Control

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("左键点击")
            accept_event()  # 停止传播
```

### 2.2 accept_event()

调用后事件不会继续传播：

```gdscript
func _gui_input(event):
    if event.is_action_pressed("ui_accept"):
        accept_event()
        do_something()
```

### 2.3 键盘输入

```gdscript
func _gui_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ENTER:
            print("Enter 键按下")
            accept_event()
```

---

## 3. 鼠标过滤

### 3.1 mouse_filter 属性

| 值 | 说明 |
|----|------|
| `MOUSE_FILTER_STOP` | 接收事件并停止传播 |
| `MOUSE_FILTER_PASS` | 接收事件但继续传播 |
| `MOUSE_FILTER_IGNORE` | 不接收事件，穿透 |

### 3.2 示例

```gdscript
# 点击穿透
mouse_filter = Control.MOUSE_FILTER_IGNORE

# 接收但不阻止传播
mouse_filter = Control.MOUSE_FILTER_PASS

# 接收并阻止传播
mouse_filter = Control.MOUSE_FILTER_STOP
```

---

## 4. 焦点控制

### 4.1 focus_mode 属性

| 值 | 说明 |
|----|------|
| `FOCUS_NONE` | 无法获得焦点 |
| `FOCUS_CLICK` | 点击获得焦点 |
| `FOCUS_ALL` | 点击或 Tab 获得焦点 |

### 4.2 设置焦点

```gdscript
# 允许 Tab 聚焦
focus_mode = Control.FOCUS_ALL

# 手动获取焦点
grab_focus()

# 释放焦点
release_focus()
```

### 4.3 焦点导航

```gdscript
# 设置焦点邻居
focus_neighbor_left = neighbor_path
focus_neighbor_right = neighbor_path
focus_neighbor_top = neighbor_path
focus_neighbor_bottom = neighbor_path

# 设置下一个/上一个焦点
focus_next = next_path
focus_previous = prev_path
```

---

## 5. 通知

### 5.1 常用通知

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

### 5.2 完整通知列表

| 通知 | 说明 |
|------|------|
| `NOTIFICATION_MOUSE_ENTER` | 鼠标进入控件 |
| `NOTIFICATION_MOUSE_EXIT` | 鼠标离开控件 |
| `NOTIFICATION_FOCUS_ENTER` | 获得焦点 |
| `NOTIFICATION_FOCUS_EXIT` | 失去焦点 |
| `NOTIFICATION_THEME_CHANGED` | 主题改变 |
| `NOTIFICATION_VISIBILITY_CHANGED` | 可见性改变 |
| `NOTIFICATION_RESIZED` | 尺寸改变 |
| `NOTIFICATION_MODAL_CLOSE` | 模态窗口关闭 |

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/ui/gui_input_handling.rst`
