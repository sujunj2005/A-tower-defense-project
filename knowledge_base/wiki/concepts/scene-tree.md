# 场景树（Scene Tree）

> **最后更新**: 2026-04-07  
> **来源**: [02B_Scene_Tree.md](../../base/core-systems/02B_Scene_Tree.md)  
> **适用版本**: Godot 4.x

---

## 📚 概念概述

**场景树（Scene Tree）** 是 Godot 引擎的核心组织结构，所有节点都以树形结构组织。

---

## 🌳 核心概念

### 1. MainLoop

Godot 启动流程：
1. `OS` 类首先运行
2. 加载驱动、服务器、脚本语言、场景系统
3. `OS` 需要一个 `MainLoop` 来运行

### 2. SceneTree

`SceneTree` 是 Godot 提供的主循环实现，**自动创建**：

```gdscript
# 获取场景树
var tree = get_tree()
```

**特点**:
- 包含根 `Viewport`
- 包含分组信息
- 提供全局状态功能（暂停、退出等）

---

## 🏗️ 树结构

### 根视口（Root Viewport）

```gdscript
# 两种方式获取根视口
var root = get_tree().root
var root = get_node("/root")
```

**特点**:
- 始终位于场景树顶部
- 包含主视口
- 自动创建，用户无需创建
- 所有节点都是其子节点

### 进入场景树

当节点连接到根视口时，成为场景树的一部分：

```gdscript
# 节点进入场景树时调用
func _enter_tree():
    pass

# 所有子节点准备好后调用
func _ready():
    pass

# 节点离开场景树时调用
func _exit_tree():
    pass
```

**活动状态**:
进入场景树后，节点可以：
- 处理输入
- 显示 2D/3D 内容
- 接收通知
- 播放声音

---

## ⚙️ 处理顺序

### 从上到下顺序（前序遍历）

大多数操作按**从上到下**顺序：

```gdscript
# 父节点的 _process 先于子节点
func _process(delta):
    pass
```

### _ready 顺序（后序遍历）

`_ready()` 是例外，使用**后序遍历**：

- 子节点的 `_ready()` 先调用
- 父节点的 `_ready()` 后调用

```gdscript
# 父节点可以安全访问已准备好的子节点
func _ready():
    print($Child.name)  # 子节点已准备好
```

### 处理优先级

```gdscript
# 使用 process_priority 控制顺序
process_priority = -1  # 更早处理
process_priority = 1   # 更晚处理
```

---

## 🔄 场景切换

### 基本切换

```gdscript
func _my_level_was_completed():
    get_tree().change_scene_to_file("res://levels/level2.tscn")
```

### 使用 PackedScene

```gdscript
var next_scene = preload("res://levels/level2.tscn")

func _my_level_was_completed():
    get_tree().change_scene_to_packed(next_scene)
```

---

## ⚠️ 踩坑点

### 场景切换崩溃风险

> **踩坑点**：不要在信号回调中直接删除当前场景，可能导致崩溃。使用 `call_deferred()` 延迟执行。

**错误示例**:
```gdscript
# 危险！可能崩溃
func _on_button_pressed():
    get_tree().change_scene_to_file("res://next.tscn")
```

**正确做法**:
```gdscript
# 使用 call_deferred 延迟执行
func _on_button_pressed():
    _deferred_goto_scene.call_deferred("res://next.tscn")
```

---

## 🔗 相关概念

- [节点操作指南](../guides/node-operations-guide.md) - 如何获取和操作节点
- [单例模式](./autoload-singletons.md) - 实现跨场景全局状态
- [资源系统](./resources-system.md) - 数据容器和资源共享

---

## 📖 来源引用

本文档内容基于 Base 层原始文档整理：
- **来源**: [02B_Scene_Tree.md](../../base/core-systems/02B_Scene_Tree.md)
- **原始来源**: `godot-docs-master/tutorials/scripting/scene_tree.rst`

---

**维护者**: Knowledge Base Administrator  
**文档版本**: 1.0
