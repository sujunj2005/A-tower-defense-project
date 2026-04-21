# 资源系统（Resources）

> **最后更新**: 2026-04-07  
> **来源**: [02C_Resources.md](../../base/core-systems/02C_Resources.md)  
> **适用版本**: Godot 4.x

---

## 📚 概念概述

**资源（Resource）** 是 Godot 中的数据容器，用于存储数据供节点使用。

---

## 🆚 Node vs Resource

| 类型 | 作用 | 示例 |
|------|------|------|
| **Node** | 提供功能 | 绘制精灵、物理模拟、UI 排列 |
| **Resource** | 数据容器 | 纹理、脚本、网格、动画、音频 |

---

## 📦 常见资源类型

- `Texture` / `Texture2D` - 纹理
- `Script` - 脚本
- `Mesh` - 网格
- `Animation` - 动画
- `AudioStream` - 音频流
- `Font` - 字体
- `Translation` - 翻译

---

## 🔄 资源共享

引擎加载资源时**只加载一次**：

```gdscript
# 多次加载同一资源，返回同一实例
var tex1 = load("res://icon.png")
var tex2 = load("res://icon.png")
# tex1 == tex2（同一对象）
```

**优势**:
- 内存效率高
- 自动缓存
- 多处引用安全

---

## 🗂️ 外部与内置资源

### 外部资源

保存在磁盘上的独立文件：

```
res://robi.png  # 外部资源
```

### 内置资源

保存在 `.tscn` 或 `.scn` 文件内部：

- 清空资源路径后保存场景，资源变为内置
- 多个场景实例共享同一内置资源

---

## 📥 加载资源

### load() - 运行时加载

```gdscript
func _ready():
    var imported_resource = load("res://robi.png")
    $sprite.texture = imported_resource
```

### preload() - 编译时加载（更快）

```gdscript
func _ready():
    var imported_resource = preload("res://robi.png")
    $sprite.texture = imported_resource
```

> **踩坑点**：`preload()` 需要常量字符串路径，不能使用变量。

### 加载场景

场景是 `PackedScene` 资源：

```gdscript
func _on_shoot():
    var bullet = preload("res://bullet.tscn").instantiate()
    add_child(bullet)
```

---

## 🛠️ 创建自定义资源

### 定义资源脚本

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

### 使用自定义资源

```gdscript
# bot.gd
extends CharacterBody3D

@export var stats: Resource

func _ready():
    if stats:
        stats.health = 10
        print(stats.health)
```

### 资源优势

- ✅ 可定义常量、方法、信号
- ✅ 自动序列化/反序列化
- ✅ Inspector 内置支持
- ✅ 可保存为文本格式（*.tres）便于版本控制

> **踩坑点**：资源文件存储脚本的路径。内部类（`class` 关键字）不能正确序列化自定义属性。

---

## 🗑️ 释放资源

资源不再使用时自动释放：

```gdscript
# 节点释放时，其拥有的资源也被释放
node.queue_free()
```

---

## 🔗 相关概念

- [节点操作指南](../guides/node-operations-guide.md) - 如何实例化场景资源
- [场景树](./scene-tree.md) - 节点树结构
- [单例模式](./autoload-singletons.md) - 全局资源管理

---

## 📖 来源引用

本文档内容基于 Base 层原始文档整理：
- **来源**: [02C_Resources.md](../../base/core-systems/02C_Resources.md)
- **原始来源**: `godot-docs-master/tutorials/scripting/resources.rst`

---

**维护者**: Knowledge Base Administrator  
**文档版本**: 1.0
