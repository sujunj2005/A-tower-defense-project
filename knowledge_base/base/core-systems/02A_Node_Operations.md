# Godot 4.x 节点操作与场景实例化

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/nodes_and_scene_instances.rst

---

## 目录

1. [获取节点](#1-获取节点)
2. [节点路径](#2-节点路径)
3. [创建节点](#3-创建节点)
4. [删除节点](#4-删除节点)
5. [实例化场景](#5-实例化场景)
6. [场景唯一节点](#6-场景唯一节点)

---

## 1. 获取节点

### 1.1 使用 get_node()

```gdscript
var sprite2d
var camera2d

func _ready():
    sprite2d = get_node("Sprite2D")
    camera2d = get_node("Camera2D")
```

> **踩坑点**：`get_node()` 使用节点名称而非类型。节点重命名后需要更新代码。

### 1.2 使用 $ 语法糖

```gdscript
@onready var sprite2d = $Sprite2D
@onready var camera2d = $Camera2D
```

### 1.3 使用 @onready

`@onready` 在 `_ready()` 之前初始化变量：

```gdscript
@onready var sprite2d = get_node("Sprite2D")

# 等价于：
var sprite2d

func _ready():
    sprite2d = get_node("Sprite2D")
```

### 1.4 安全获取节点

```gdscript
# 可能返回 null
var sprite = get_node_or_null("Sprite2D")
if sprite:
    sprite.visible = true

# 检查节点是否存在
if has_node("Sprite2D"):
    var s = get_node("Sprite2D")
```

---

## 2. 节点路径

### 2.1 相对路径

```gdscript
# 直接子节点
get_node("Sprite2D")

# 嵌套子节点
get_node("ShieldBar/AnimationPlayer")

# 深层嵌套
get_node("UI/Menu/Buttons/StartButton")
```

### 2.2 父节点路径

```gdscript
# 获取父节点
get_node("..")

# 获取父节点的其他子节点
get_node("../SiblingNode")
```

> **踩坑点**：使用 `..` 会破坏封装，不推荐。考虑使用信号或 Autoload。

### 2.3 绝对路径

```gdscript
# 从根节点开始
get_node("/root/Main/Player")

# 使用 get_tree()
get_tree().root.get_node("Main/Player")
```

---

## 3. 创建节点

### 3.1 动态创建节点

```gdscript
func _ready():
    var sprite = Sprite2D.new()
    add_child(sprite)
```

### 3.2 创建并配置节点

```gdscript
func spawn_enemy(position: Vector2) -> void:
    var enemy = CharacterBody2D.new()
    enemy.position = position
    enemy.name = "Enemy_%d" % randi()
    add_child(enemy)
```

---

## 4. 删除节点

### 4.1 queue_free()

安全删除节点，在当前帧结束后释放：

```gdscript
sprite.queue_free()  # 延迟删除
```

### 4.2 free()

立即删除节点（不推荐）：

```gdscript
sprite.free()  # 立即删除，危险！
```

> **踩坑点**：`free()` 立即删除节点，之后任何引用都会变成 null 或导致崩溃。除非确定安全，否则使用 `queue_free()`。

### 4.3 删除所有子节点

```gdscript
func clear_children() -> void:
    for child in get_children():
        child.queue_free()
```

### 4.4 删除前检查

```gdscript
func safe_remove(node: Node) -> void:
    if is_instance_valid(node) and not node.is_queued_for_deletion():
        node.queue_free()
```

---

## 5. 实例化场景

### 5.1 两步实例化

```gdscript
# 1. 加载场景
var scene = load("res://enemy.tscn")

# 2. 实例化
var instance = scene.instantiate()
add_child(instance)
```

### 5.2 使用 preload

`preload` 在编译时加载，比 `load` 更快：

```gdscript
var bullet_scene = preload("res://bullet.tscn")

func shoot() -> void:
    var bullet = bullet_scene.instantiate()
    add_child(bullet)
```

### 5.3 实例化到特定位置

```gdscript
var enemy_scene = preload("res://enemy.tscn")

func spawn_enemy(spawn_pos: Vector2) -> Node2D:
    var enemy = enemy_scene.instantiate()
    enemy.position = spawn_pos
    add_child(enemy)
    return enemy
```

### 5.4 实例化到其他节点

```gdscript
func shoot() -> void:
    var bullet = bullet_scene.instantiate()
    # 添加到父节点而非自身
    get_parent().add_child(bullet)
    bullet.global_position = global_position
```

---

## 6. 场景唯一节点

### 6.1 创建场景唯一节点

在场景树中右键节点 → **Access as Unique Name**，或重命名时添加 `%` 前缀。

### 6.2 使用场景唯一节点

```gdscript
# 使用 get_node
get_node("%RedButton").text = "Hello"

# 使用 % 语法糖
%RedButton.text = "Hello"
```

### 6.3 同场景限制

场景唯一节点只能被同一场景内的节点获取：

```gdscript
# Player 场景脚本
get_node("%Eyes")  # 返回 Eyes 节点
get_node("%Hilt")  # 返回 null（Hilt 在子场景中）

# Sword 场景脚本
get_node("%Eyes")  # 返回 null（Eyes 在父场景中）
get_node("%Hilt")  # 返回 Hilt 节点
```

### 6.4 跨场景访问

```gdscript
# 从 Player 访问 Sword 场景中的 Hilt
get_node("Hand/Sword").get_node("%Hilt")
get_node("Hand/Sword/%Hilt")  # 简写

# 如果 Sword 也是唯一节点
get_node("%Sword/%Hilt")
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/nodes_and_scene_instances.rst`
- 来源文件：`godot-docs-master/tutorials/scripting/scene_unique_nodes.rst`
