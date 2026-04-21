# Godot 4.x 场景树

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/scene_tree.rst

---

## 目录

1. [场景树概述](#1-场景树概述)
2. [根视口](#2-根视口)
3. [进入场景树](#3-进入场景树)
4. [树顺序](#4-树顺序)
5. [切换场景](#5-切换场景)

---

## 1. 场景树概述

### 1.1 MainLoop

Godot 启动时：
1. `OS` 类首先运行
2. 加载驱动、服务器、脚本语言、场景系统
3. `OS` 需要一个 `MainLoop` 来运行

### 1.2 SceneTree

`SceneTree` 是 Godot 提供的主循环实现，自动创建：

- 包含根 `Viewport`
- 包含分组信息
- 提供全局状态功能（暂停、退出等）

```gdscript
# 获取场景树
var tree = get_tree()
```

---

## 2. 根视口

### 2.1 获取根视口

```gdscript
# 两种方式获取根视口
var root = get_tree().root
var root = get_node("/root")
```

### 2.2 根视口特点

- 始终位于场景树顶部
- 包含主视口
- 自动创建，用户无需创建
- 所有节点都是其子节点

---

## 3. 进入场景树

### 3.1 成为活动节点

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

### 3.2 活动状态

进入场景树后，节点可以：
- 处理输入
- 显示 2D/3D 内容
- 接收通知
- 播放声音

离开场景树后，这些能力丧失。

---

## 4. 树顺序

### 4.1 处理顺序

大多数操作按**从上到下**顺序（前序遍历）：

```gdscript
# 父节点的 _process 先于子节点
func _process(delta):
    pass
```

### 4.2 _ready 顺序

`_ready()` 是例外，使用**后序遍历**：

- 子节点的 `_ready()` 先调用
- 父节点的 `_ready()` 后调用

```gdscript
# 父节点可以安全访问已准备好的子节点
func _ready():
    print($Child.name)  # 子节点已准备好
```

### 4.3 处理优先级

```gdscript
# 使用 process_priority 控制顺序
process_priority = -1  # 更早处理
process_priority = 1   # 更晚处理
```

---

## 5. 切换场景

### 5.1 基本切换

```gdscript
func _my_level_was_completed():
    get_tree().change_scene_to_file("res://levels/level2.tscn")
```

### 5.2 使用 PackedScene

```gdscript
var next_scene = preload("res://levels/level2.tscn")

func _my_level_was_completed():
    get_tree().change_scene_to_packed(next_scene)
```

### 5.3 自定义场景切换器

使用 Autoload 实现更复杂的场景切换：

```gdscript
# global.gd
extends Node

var current_scene = null

func _ready():
    var root = get_tree().root
    current_scene = root.get_child(-1)

func goto_scene(path):
    _deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
    current_scene.free()
    var s = ResourceLoader.load(path)
    current_scene = s.instantiate()
    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene
```

> **踩坑点**：不要在信号回调中直接删除当前场景，可能导致崩溃。使用 `call_deferred()` 延迟执行。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/scene_tree.rst`
