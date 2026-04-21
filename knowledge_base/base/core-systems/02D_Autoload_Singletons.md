# Godot 4.x 自动加载单例

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/singletons_autoload.rst

---

## 目录

1. [单例概述](#1-单例概述)
2. [创建 Autoload](#2-创建-autoload)
3. [使用 Autoload](#3-使用-autoload)
4. [自定义场景切换器](#4-自定义场景切换器)

---

## 1. 单例概述

### 1.1 为什么需要单例

场景系统无法存储跨场景的信息（如玩家分数、库存）。

解决方案：
- 使用"主场景"加载其他场景 → 无法单独运行子场景
- 存储到磁盘 → 频繁读写效率低
- **Autoload 单例** → 推荐方案

### 1.2 Autoload 特点

- 始终加载，无论当前运行哪个场景
- 可存储全局变量
- 可处理场景切换
- 类似单例模式

---

## 2. 创建 Autoload

### 2.1 步骤

1. 创建脚本（继承自 `Node`）
2. **项目 → 项目设置 → 全局 → 自动加载**
3. 添加脚本，设置名称

### 2.2 设置界面

| 字段 | 说明 |
|------|------|
| 名称 | 节点名称，也是访问名称 |
| 路径 | 脚本或场景路径 |
| 启用 | 是否可直接访问 |

---

## 3. 使用 Autoload

### 3.1 直接访问

```gdscript
# 直接使用名称访问
PlayerVariables.health -= 10
```

### 3.2 通过路径访问

```gdscript
# 通过 /root/名称 访问
get_node("/root/PlayerVariables").health -= 10
```

### 3.3 场景树中的位置

Autoload 节点位于根视口下，其他场景之前：

```
/root
├── PlayerVariables (Autoload)
├── GameManager (Autoload)
└── CurrentScene
```

> **踩坑点**：Autoload 不能使用 `free()` 或 `queue_free()` 删除，否则引擎崩溃。

---

## 4. 自定义场景切换器

### 4.1 创建全局脚本

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

### 4.2 使用场景切换器

```gdscript
# scene_1.gd
func _on_button_pressed():
    Global.goto_scene("res://scene_2.tscn")
```

> **踩坑点**：不要在信号回调中直接删除当前场景，使用 `call_deferred()` 延迟执行。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/singletons_autoload.rst`
