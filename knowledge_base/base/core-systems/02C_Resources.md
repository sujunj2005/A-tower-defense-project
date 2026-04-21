# Godot 4.x 资源系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/resources.rst

---

## 目录

1. [资源概述](#1-资源概述)
2. [外部与内置资源](#2-外部与内置资源)
3. [加载资源](#3-加载资源)
4. [创建自定义资源](#4-创建自定义资源)
5. [释放资源](#5-释放资源)

---

## 1. 资源概述

### 1.1 Node vs Resource

| 类型 | 作用 |
|------|------|
| **Node** | 提供功能：绘制精灵、物理模拟、UI 排列等 |
| **Resource** | 数据容器：存储数据供节点使用 |

### 1.2 常见资源类型

- `Texture` / `Texture2D`
- `Script`
- `Mesh`
- `Animation`
- `AudioStream`
- `Font`
- `Translation`

### 1.3 资源共享

引擎加载资源时**只加载一次**：

```gdscript
# 多次加载同一资源，返回同一实例
var tex1 = load("res://icon.png")
var tex2 = load("res://icon.png")
# tex1 == tex2（同一对象）
```

---

## 2. 外部与内置资源

### 2.1 外部资源

保存在磁盘上的独立文件：

```
res://robi.png  # 外部资源
```

### 2.2 内置资源

保存在 `.tscn` 或 `.scn` 文件内部：

- 清空资源路径后保存场景，资源变为内置
- 多个场景实例共享同一内置资源

---

## 3. 加载资源

### 3.1 load()

运行时加载：

```gdscript
func _ready():
    var imported_resource = load("res://robi.png")
    $sprite.texture = imported_resource
```

### 3.2 preload()

编译时加载（更快）：

```gdscript
func _ready():
    var imported_resource = preload("res://robi.png")
    $sprite.texture = imported_resource
```

> **踩坑点**：`preload()` 需要常量字符串路径，不能使用变量。

### 3.3 加载场景

场景是 `PackedScene` 资源：

```gdscript
func _on_shoot():
    var bullet = preload("res://bullet.tscn").instantiate()
    add_child(bullet)
```

---

## 4. 创建自定义资源

### 4.1 定义资源脚本

```gdscript
# bot_stats.gd
class_name BotStats
extends Resource

@export var health: int
@export var sub_resource: Resource
@export var strings: PackedStringArray

func _init(p_health = 0, p_sub_resource = null, p_strings = []):
    health = p_health
    sub_resource = p_sub_resource
    strings = p_strings
```

### 4.2 使用自定义资源

```gdscript
# bot.gd
extends CharacterBody3D

@export var stats: Resource

func _ready():
    if stats:
        stats.health = 10
        print(stats.health)
```

### 4.3 资源优势

- 可定义常量、方法、信号
- 自动序列化/反序列化
- Inspector 内置支持
- 可保存为文本格式（*.tres）便于版本控制

> **踩坑点**：资源文件存储脚本的路径。内部类（`class` 关键字）不能正确序列化自定义属性。

---

## 5. 释放资源

资源不再使用时自动释放：

```gdscript
# 节点释放时，其拥有的资源也被释放
node.queue_free()
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/resources.rst`
