# Base 层 - 输入系统文档

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.x  
> **文档来源**: Godot 官方文档

---

## 📚 文档列表

本目录包含 Godot 4.x 输入系统的原始文档：

| 文档 | 描述 | 来源 | 行数 | 重要性 |
|------|------|------|------|--------|
| [08A_InputEvent.md](./08A_InputEvent.md) | **输入事件详解** - InputEvent 类型、事件传播流程、输入回调、输入动作 | `inputevent.rst` | ~226 行 | 🔴 必读 |
| [08B_InputMap.md](./08B_InputMap.md) | **输入映射详解** - InputMap 概述、事件 vs 轮询、定义输入动作、检查输入状态 | `input_examples.rst` | ~235 行 | 🔴 必读 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/inputs/)  
**大小**: ~15 KB  
**文件数**: 2 份

---

## 📖 核心内容

### 08A_InputEvent.md - 输入事件详解

**核心内容**:
- 输入事件概述（InputEvent 基类、基本用法、InputMap 使用）
- 输入事件流程（传播顺序：_input → _gui_input → _shortcut_input → _unhandled_key_input → _unhandled_input）
- InputEvent 类型（14 种事件类型：键盘、鼠标、手柄、触摸、MIDI 等）
- 输入回调（_input、_unhandled_input、_shortcut_input、_gui_input 的选择）
- 输入动作（定义动作、检查动作状态、获取强度/向量、程序生成事件）

**关键代码示例**:
```gdscript
# 事件驱动 - 跳跃
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            get_tree().quit()

# 停止传播
func _input(event):
    if event.is_action("ui_accept"):
        get_viewport().set_input_as_handled()
```

### 08B_InputMap.md - 输入映射详解

**核心内容**:
- InputMap 概述（什么是 InputMap、使用优势）
- 事件 vs 轮询（事件驱动 vs 状态轮询的适用场景）
- 定义输入动作（编辑器中定义、常用内置动作）
- 检查输入状态（is_action_pressed/just_pressed/just_released）
- 获取输入值（get_action_strength/get_vector/get_axis）
- 常见输入示例（键盘、鼠标、手柄、触摸）
- 自定义光标（隐藏光标、设置自定义光标、光标模式）

**关键代码示例**:
```gdscript
# 状态轮询 - 移动
func _physics_process(delta):
    if Input.is_action_pressed("move_right"):
        position.x += speed * delta

# 获取方向向量
var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
velocity = direction * speed
```

---

## 🔗 Wiki 层映射

本目录的文档已整合到 Wiki 层：

| Base 层文档 | Wiki 概念页面 | Wiki 指南页面 |
|------------|--------------|--------------|
| [08A_InputEvent.md](./08A_InputEvent.md) | [input-events.md](../wiki/concepts/input-events.md) - 输入事件概念 | - |
| [08B_InputMap.md](./08B_InputMap.md) | - | [input-map-guide.md](../wiki/guides/input-map-guide.md) - 输入映射指南 |

---

## 📊 统计信息

| 指标 | 数值 |
|------|------|
| 文档总数 | 2 份 |
| 总字数 | ~12,000+ |
| 代码示例 | 20+ 个 |
| 重要性 | 🔴 必读（游戏输入基础） |

---

## 🎯 使用建议

### 学习路径

```
1. [08A_InputEvent.md](./08A_InputEvent.md) - 理解输入事件传播机制
   ↓
2. [08B_InputMap.md](./08B_InputMap.md) - 学习 InputMap 配置和使用
   ↓
3. [Wiki: input-events.md](../wiki/concepts/input-events.md) - 输入事件概念摘要
   ↓
4. [Wiki: input-map-guide.md](../wiki/guides/input-map-guide.md) - 输入映射实战指南
```

### 实战应用

1. **游戏输入处理**
   - 使用 `_unhandled_input()` 处理游戏逻辑输入
   - 使用 `Input.is_action_*()` 检查输入状态
   - 使用 `Input.get_vector()` 获取移动方向

2. **UI 输入处理**
   - 使用 `_gui_input()` 处理 UI 控件输入
   - 使用 `mouse_filter` 控制鼠标事件传递
   - 使用焦点系统管理键盘导航

3. **跨平台兼容**
   - 使用 InputMap 将不同平台的按键映射到同一动作
   - 使用 `Input.joy_connection_changed` 信号检测手柄连接

---

## ⚠️ 常见踩坑

1. **不要在 _input 中处理游戏逻辑**
   - 应该在 `_unhandled_input()` 中处理，避免被 UI 拦截

2. **is_action_pressed vs is_action_just_pressed**
   - `is_action_pressed` 每帧返回 true（适合持续移动）
   - `is_action_just_pressed` 只在按下瞬间返回 true（适合跳跃/攻击）

3. **忘记设置输入动作**
   - 必须在项目设置中定义输入动作才能使用 `Input.is_action_*()`

4. **在 _process 中检查输入**
   - 应该在 `_physics_process()` 中检查输入，保证帧率一致

---

## 🔗 相关链接

- **Wiki 概念页面**: [input-events.md](../wiki/concepts/input-events.md) - 输入事件核心概念
- **Wiki 指南页面**: [input-map-guide.md](../wiki/guides/input-map-guide.md) - 输入映射实战指南
- **Godot 官方文档**: [Input 类参考](https://docs.godotengine.org/en/stable/classes/class_input.html)
- **Godot 官方文档**: [InputEvent 类参考](https://docs.godotengine.org/en/stable/classes/class_inputevent.html)

---

**维护者**: Knowledge Base Administrator  
**文档版本**: 1.0
