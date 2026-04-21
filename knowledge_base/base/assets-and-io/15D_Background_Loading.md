# 后台资源加载 (Background Loading)

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/io/background_loading.rst

---

## 一、为什么需要后台加载？

### 问题：同步加载阻塞线程

标准的 `load()` 或 `ResourceLoader.load()` 会**阻塞当前线程**，导致：
- 切换关卡时画面卡顿
- 游戏期间加载额外资源时短暂无响应
- 用户体验差

### 解决方案：异步加载

使用 `ResourceLoader` 在**后台线程**异步加载资源，主线程保持响应。

---

## 二、ResourceLoader 异步API

### 2.1 三步流程

```
① load_threaded_request()  → 发起加载请求
② load_threaded_get_status() → 检查状态（可选）
③ load_threaded_get()      → 获取已加载的资源
```

### 2.2 API 详解

#### 步骤1：发起请求

```gdscript
ResourceLoader.load_threaded_request(path)
```

**参数：**
- `path`（String）：资源路径（如 `"res://scenes/level_02.tscn"`）
- `type_hint`（可选）：期望的类型（用于验证）
- `use_sub_threads`（bool，默认false）：是否使用子线程（实验性）

#### 步骤2：检查状态

```gdscript
var status = ResourceLoader.load_threaded_get_status(path)
```

**返回值：**

| 状态 | 常量 | 说明 |
|------|------|------|
| 正在加载 | `THREAD_LOAD_IN_PROGRESS` | 后台加载中 |
| 已完成 | `THREAD_LOAD_LOADED` | 加载完成，可以获取 |
| 失败 | `THREAD_LOAD_FAILED` | 加载失败 |
| 未找到 | `THREAD_LOAD_INVALID_RESOURCE` | 路径无效 |

**获取进度：**

```gdscript
var progress = []
var status = ResourceLoader.load_threaded_get_status(path, progress)
if progress.size() > 0:
    var percent = progress[0]  # 0.0 到 1.0
    print("加载进度: %d%%" % (percent * 100))
```

#### 步骤3：获取资源

```gdscript
var resource = ResourceLoader.load_threaded_get(path)
```

> **重要**：调用后有两种情况：
> - ✅ 资源已完成加载 → **立即返回**
> - ❌ 资源仍在加载 → **阻塞等待**（等同于同步load()）

**避免阻塞的方法**：
1. 确保发起请求和获取之间有足够时间间隔
2. 手动检查状态后再获取

---

## 三、完整示例：后台加载敌人场景

### 3.1 场景描述

按钮按下时生成敌人，敌人在 `_ready` 时开始后台加载，按下时实例化。

### 3.2 代码实现

```gdscript
extends Button

const ENEMY_SCENE_PATH: String = "res://Enemy.tscn"

func _ready():
    # 步骤1：发起后台加载请求
    ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
    pressed.connect(_on_button_pressed)

func _on_button_pressed():
    # 步骤3：获取已加载的资源（此时应该已完成）
    var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)

    # 实例化并添加到场景
    var enemy = enemy_scene.instantiate()
    get_tree().current_scene.add_child(enemy)
```

---

## 四、进阶示例：带进度条的关卡加载

### 4.1 LoadingScreen 场景

```gdscene
[gd_scene load_steps=3 format=3 uid="uid://xxx"]

[ext_resource type="Script" path="res://loading_screen.gd" id="1"]
[ext_resource type="FontFile" path="res://fonts/default.ttf" id="2"]

[node name="LoadingScreen" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0

[node name="ProgressBar" type="ProgressBar" parent="."]
offset_left = 100.0
offset_top = 280.0
offset_right = 540.0
offset_bottom = 300.0
value = 0.0

[node name="StatusLabel" type="Label" parent="."]
offset_left = 200.0
offset_top = 250.0
offset_right = 440.0
offset_bottom = 275.0
theme_override_fonts/font = ExtResource("2")
text = "加载中..."
horizontal_alignment = 1
```

### 4.2 LoadingScreen 脚本

```gdscene
extends Control

@onready var progress_bar = $ProgressBar
@onready var status_label = $StatusLabel

const LEVEL_PATH = "res://levels/level_03.tscn"
var loading = false

func _ready():
    start_loading()

func start_loading():
    loading = true
    status_label.text = "正在加载关卡..."
    ResourceLoader.load_threaded_request(LEVEL_PATH)

func _process(delta):
    if not loading:
        return

    var progress = []
    var status = ResourceLoader.load_threaded_get_status(LEVEL_PATH, progress)

    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            if progress.size() > 0:
                progress_bar.value = progress[0] * 100.0
                status_label.text = "加载中... %d%%" % (progress[0] * 100)

        ResourceLoader.THREAD_LOAD_LOADED:
            progress_bar.value = 100.0
            status_label.text = "加载完成！"
            loading = false
            await get_tree().create_timer(0.5).timeout
            finish_loading()

        ResourceLoader.THREAD_LOAD_FAILED:
            status_label.text = "加载失败！"
            loading = false

        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            status_label.text = "无效的资源路径！"
            loading = false

func finish_loading():
    var packed_scene = ResourceLoader.load_threaded_get(LEVEL_PATH)
    get_tree().change_scene_to_packed(packed_scene)
```

### 4.3 触发加载

```gdscene
# 在关卡出口处
func _on_LevelExit_body_entered(body):
    if body.is_in_group("player"):
        get_tree().change_scene_to_file("res://loading_screen.tscn")
```

---

## 五、批量资源预加载

### 5.1 预加载管理器

```gdscene
# PreloadManager.gd (Autoload singleton)
extends Node

var pending_resources: Dictionary = {}  # path -> status
var loaded_resources: Dictionary = {}   # path -> resource

signal resource_loaded(path)
signal all_resources_loaded

func request_load(paths: Array[String]):
    for path in paths:
        if not pending_resources.has(path):
            ResourceLoader.load_threaded_request(path)
            pending_resources[path] = ResourceLoader.THREAD_LOAD_IN_PROGRESS

func _process(delta):
    var all_done = true
    var to_remove = []

    for path in pending_resources:
        var progress = []
        var status = ResourceLoader.load_threaded_get_status(path, progress)

        match status:
            ResourceLoader.THREAD_LOAD_LOADED:
                loaded_resources[path] = ResourceLoader.load_threaded_get(path)
                to_remove.append(path)
                resource_loaded.emit(path)

            ResourceLoader.THREAD_LOAD_FAILED:
                push_warning("资源加载失败: " + path)
                to_remove.append(path)

            ResourceLoader.THREAD_LOAD_IN_PROGRESS:
                all_done = false

            _:
                to_remove.append(path)

    for path in to_remove:
        pending_resources.erase(path)

    if pending_resources.is_empty() and all_done:
        all_resources_loaded.emit()
        set_process(false)

func get_resource(path: Variant):
    return loaded_resources.get(path)

func is_loaded(path: String) -> bool:
    return loaded_resources.has(path)
```

### 5.2 使用示例

```gdscene
# 在游戏中使用
func _ready():
    # 请求预加载下一关的所有资源
    PreloadManager.request_load([
        "res://enemies/big_boss.tscn",
        "res://textures/boss_arena.png",
        "res://audio/boss_music.ogg",
        "res://particles/explosion.tres",
    ])

    PreloadManager.all_resources_loaded.connect(_on_all_loaded)

func _on_all_loaded():
    print("所有Boss战资源已预加载完成！")
    $EnterBossDoor.disabled = false
```

---

## 六、ResourceQueue（官方示例）

Godot 官方提供了更完整的 `ResourceQueue` 实现，位于：

```
tutorials/io/files/resource_queue.gd
```

**特性：**
- 队列化管理多个加载任务
- 回调通知机制
- 最大并发数控制
- 取消加载支持

---

## 七、最佳实践与注意事项

### 7.1 最佳实践

| 场景 | 建议 |
|------|------|
| **关卡切换** | 显示 Loading Screen + 进度条 |
| **游戏内预加载** | 进入新区域前提前加载 |
| **大量小资源** | 打包成 .pck 或使用 ResourceQueue |
| **关键资源** | 仍可用 preload() 确保立即可用 |

### 7.2 注意事项

⚠️ **潜在阻塞**：
- `load_threaded_get()` 在资源未完成时会**阻塞**
- 必须检查状态或确保有足够时间间隔

⚠️ **线程安全**：
- 不要在回调中操作主线程独占资源（如修改场景树）
- 应使用 `call_deferred()` 或信号机制

⚠️ **内存管理**：
- 后台加载的资源会占用内存
- 不再需要时应手动释放（`resource.unref()` 或切换场景时自动清理）

### 7.3 性能对比

| 方法 | 阻塞？ | 适用场景 |
|------|--------|----------|
| `preload()` | 编译时阻塞 | 小型、必需的资源 |
| `load()` | 运行时阻塞 | 偶尔使用的资源 |
| `load_threaded_*()` | 不阻塞 | 大型资源、关卡切换 |

---

## 八、参考链接

- [ResourceLoader 官方文档](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html)
- [ResourceQueue 示例](https://github.com/godotengine/godot-demo-projects/tree/master/gui/resource_queue)
- [文件系统教程](15A_File_System.md)
- [游戏存档教程](15C_Saving_Games.md)
- [性能优化教程](14A_General_Optimization.md)
