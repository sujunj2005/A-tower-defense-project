# Godot 大型项目避坑最佳实践速查

> **版本说明**：📙 **精简速查版 (v1.0)** - 快速查阅最佳实践要点  
> **完整版本**：需要详细示例？查看 [详细实践版](../code-standards/20C_Godot_Best_Practices_Quick_Reference.md)  
> **适用版本**: Godot 4.x  
> **文档目标**: 快速查找、易于理解、便于应用

---

## 📋 快速索引

| 问题 | 严重程度 | 解决方案 | 章节 |
|------|---------|---------|------|
| 负向缩放翻转 | 🔴 致命 | 使用 `Sprite2D.flip_h` | [第 2 节](#2-负向缩放翻转) |
| Position vs Offset | 🟠 高 | 视觉用 Offset，逻辑用 Position | [第 3 节](#3-position-vs-offset) |
| preload 滥用 | 🟠 高 | 延迟加载 + 资源池化 | [第 4 节](#4-preload-内存管理) |
| 屏幕外性能浪费 | 🟡 中 | VisibleOnScreenNotifier2D | [第 5 节](#5-屏幕外优化) |
| 分辨率设置不当 | 🟡 中 | 640×360 + 整数缩放 | [第 6 节](#6-分辨率与缩放) |
| 缺少静态类型 | 🟡 中 | 渐进式类型化 | [第 7 节](#7-静态类型) |
| .tres 文件注释 | 🔴 严重 | 禁止行内注释 | [第 11 节](#11-tres-文件注释) |

---

## 1. 核心原则

### 1.1 视觉层 ≠ 逻辑层

**核心思想**：Godot 的节点树结构分离了视觉表现和游戏逻辑。

**应用示例**：
- 视觉调整：使用 `Offset`、`flip_h`
- 逻辑移动：使用 `Position`、`Transform`

### 1.2 理解引用计数

**核心思想**：Godot 的资源管理基于引用计数，引用链决定内存生命周期。

**应用示例**：
- 全局脚本 preload → 永久占用内存
- 场景内 preload → 场景卸载时释放

### 1.3 类型系统是朋友

**核心思想**：静态类型提升代码质量、性能和开发效率。

**性能提升**：
- 方法调用：10-15%
- 算术运算：8-12%
- 错误检测：编译时发现

---

## 2. 负向缩放翻转

### ⚠️ 问题

```gdscript
# ❌ 错误：破坏物理系统
scale.x = -1
```

**后果**：
- 碰撞法线方向翻转
- 射线检测结果失真
- 子节点位置镜像

### ✅ 解决方案

**方案 1：使用 flip_h（推荐）**
```gdscript
$Sprite2D.flip_h = true
```

**方案 2：手动调整物理节点**
```gdscript
func face_left():
    $Sprite2D.flip_h = true
    $CollisionShape2D.position.x = -abs($CollisionShape2D.position.x)
```

**方案 3：使用 Transform**
```gdscript
transform.x = Vector2(-1.0, 0.0)  # 代替 scale.x = -1
```

---

## 3. Position vs Offset

### ⚠️ 问题

```gdscript
# ❌ 错误：Position 影响子节点
$Sprite2D.position.x = 10  # 影响所有子节点
```

### ✅ 解决方案

```gdscript
# ✅ 正确：视觉用 Offset
$Sprite2D.offset.x = 10  # 仅影响绘制

# ✅ 正确：逻辑用 Position
position.x = new_x  # 节点实际位置
```

---

## 4. preload 内存管理

### ⚠️ 问题

```gdscript
# ❌ 错误：全局脚本 preload 大型资源
const ENEMY_SCENE = preload("res://enemies/enemy.tscn")
```

### ✅ 解决方案

**方案 1：延迟加载**
```gdscript
var EnemyScene: PackedScene

func _ready():
    EnemyScene = load("res://enemies/enemy.tscn")
```

**方案 2：资源池**
```gdscript
class_name ResourcePool
var cache: Dictionary = {}

func get_resource(path: String) -> Resource:
    if not cache.has(path):
        cache[path] = load(path)
    return cache[path]
```

---

## 5. 屏幕外优化

### ⚠️ 问题

屏幕外的对象仍在更新和渲染，浪费性能。

### ✅ 解决方案

```gdscript
# 使用 VisibleOnScreenNotifier2D
func _on_visible_on_screen_notifier_2d_screen_exited():
    set_process(false)
    set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_entered():
    set_process(true)
    set_physics_process(true)
```

---

## 6. 分辨率与缩放

### ✅ 推荐设置

```gdscript
# 项目设置 → Display → Window
Size: 640×360
Stretch:
  Mode: canvas
  Aspect: expand
  Integer Scale: On
```

**优点**：
- 像素完美
- 性能优化
- 自动适配各种分辨率

---

## 7. 静态类型

### ✅ 渐进式类型化

```gdscript
# 基础类型
var health: int = 100
var speed: float = 5.0
var is_alive: bool = true

# 复杂类型
var player: CharacterBody2D
var enemies: Array[Enemy]
var inventory: Dictionary

# 函数签名
func take_damage(amount: int) -> void:
    health -= amount
```

---

## 8. 对象池

### ✅ 实现示例

```gdscript
class_name ObjectPool
extends Node

var pool: Array[Node] = []
var scene: PackedScene

func _init(scene_to_pool: PackedScene, size: int):
    scene = scene_to_pool
    for i in range(size):
        var instance = scene.instantiate()
        instance.visible = false
        add_child(instance)
        pool.append(instance)

func get_instance() -> Node:
    for instance in pool:
        if not instance.visible:
            instance.visible = true
            return instance
    
    var instance = scene.instantiate()
    add_child(instance)
    pool.append(instance)
    return instance

func return_instance(instance: Node):
    instance.visible = false
```

---

## 9. 场景切换

### ✅ 正确方式

```gdscript
func change_scene(new_scene_path: String):
    var old_scene = get_tree().current_scene
    old_scene.queue_free()
    get_tree().change_scene_to_file(new_scene_path)
```

---

## 10. 调试技巧

### ✅ 实用工具

```gdscript
# 性能监控
print("FPS: ", Performance.get_monitor(Performance.FPS))

# 内存监控
print("Memory: ", Performance.get_monitor(Performance.MEMORY_STATIC))

# 对象计数
print("Objects: ", Performance.get_monitor(Performance.OBJECT_COUNT))

# 断点调试
breakpoint
```

---

## 11. .tres 文件注释

### ⚠️ 问题

```tres
# ❌ 错误：行内注释破坏格式
[resource]
name = "Test"  # 这行注释会破坏文件
```

### ✅ 解决方案

```tres
# ✅ 正确：注释单独一行
[resource]
name = "Test"
```

---

## 📚 参考资源

- [Godot 官方文档](https://docs.godotengine.org/)
- [GitHub Issue #78613](https://github.com/godotengine/godot/issues/78613)
- [Godot 物理故障排除](https://docs.godotengine.org/en/4.5/tutorials/physics/troubleshooting_physics_issues.html)

---

**最后更新**: 2026-04-03  
**作者**: Knowledge Base Administrator  
**版本**: 1.0
