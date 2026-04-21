# 塔防游戏案例研究

> 来源项目：`tower_defense`（未完成项目）| 适用版本：Godot 4.6 | 最后更新：2026-04-01

---

## 目录

1. [项目架构概览](#1-项目架构概览)
2. [数据模型架构（BaseModel 模式）](#2-数据模型架构basemodel-模式)
3. [加密存档系统](#3-加密存档系统)
4. [异步场景加载管理器](#4-异步场景加载管理器)
5. [配置管理器（ConfigFile）](#5-配置管理器configfile)
6. [Camera2D 完整控制器](#6-camera2d-完整控制器)
7. [建造系统：弹出面板与类型匹配](#7-建造系统弹出面板与类型匹配)
8. [角色继承体系（攻击/受击分离）](#8-角色继承体系攻击受击分离)
9. [动态脚本挂载（运行时 set_script）](#9-动态脚本挂载运行时-set_script)
10. [节点组（Group）在地图设计中的应用](#10-节点组group在地图设计中的应用)
11. [自定义 Tooltip 实现](#11-自定义-tooltip-实现)
12. [项目踩坑记录与最佳实践](#12-项目踩坑记录与最佳实践)

---

## 1. 项目架构概览

### 1.1 目录结构

```
tower_defense/
├── scenes/
│   ├── main.gd                    # 主入口场景
│   ├── main.tscn
│   ├── presets_actor.gd           # 预设角色（开始游戏按钮等）
│   ├── loading_screen/
│   │   └── loading_scene.gd       # 加载界面（进度条+动画）
│   └── tower_defense/
│       ├── tower_defense.gd       # 塔防战斗场景控制器
│       ├── tower_defense_camera.gd # 塔防相机（缩放/移动/震动）
│       ├── tower_pit.gd           # 塔坑（可点击放置塔的位置）
│       ├── characters/
│       │   ├── base_character.gd  # 角色基类
│       │   ├── tower.gd           # 防御塔
│       │   ├── attack/
│       │   │   ├── base_attacker.gd    # 攻击基类
│       │   │   ├── melee_attacker.gd   # 近战攻击
│       │   │   └── range_attacker.gd   # 远程攻击
│       │   └── attacked/
│       │       └── base_under_attacked.gd  # 受击基类
│       └── game_scenes/
│           ├── build_popup_panel.gd     # 建造弹出面板
│           └── buildable_menu_unit.gd   # 可建造菜单单元
├── models/
│   ├── base_model.gd             # 数据模型基类
│   ├── player.gd                 # 玩家数据模型
│   ├── towers.gd                 # 塔数据模型
│   └── temp.gd                   # 临时数据模型
├── managers/
│   ├── load_manager.gd           # 异步加载管理器
│   ├── configure_manager.gd      # 配置管理器
│   └── game_archive_manager.gd   # 存档管理器
└── project.godot
```

### 1.2 Autoload 单例

```
project.godot:
[autoload]
Panku="*uid://cyftuo4syatlv"           # 控制台插件
ConfigureManager="*res://managers/configure_manager.gd"  # 配置管理
LoadManager="*res://managers/load_manager.gd"            # 场景加载
GameArchiveManager="*res://managers/game_archive_manager.gd"  # 存档管理
```

### 1.3 场景切换流程

```
main.tscn → (点击开始游戏) → loading_scene → tower_defense.tscn
                  ↑                              ↓
            LoadManager.load_scene()    动态加载地图 + 初始化 pits
```

---

## 2. 数据模型架构（BaseModel 模式）

> 来源文件：`models/base_model.gd`、`models/player.gd`、`models/towers.gd`

### 2.1 基础模型类

```gdscript
class_name BaseModel
extends Node

func _init(_fill_data: Dictionary):
    pass

func to_dict() -> Dictionary:
    return {}
```

### 2.2 继承体系

```
BaseModel (Node)
├── PlayerModel
│   ├── towers: TowersModel
│   └── temp: TempModel
├── TowersModel
│   ├── tower_list: Array
│   └── using_towers: Array
└── TempModel
    └── curr_map: String
```

### 2.3 完整实现示例

```gdscript
class_name TowersModel
extends BaseModel

static var max_tower_id: int = 0
@export var tower_list: Array
@export var using_towers: Array = []

func _init(fill_data: Dictionary):
    if "max_tower_id" in fill_data:
        max_tower_id = fill_data["max_tower_id"]
    tower_list = fill_data["tower_list"]

func add_tower(tower_type: String, extra_data = {}) -> bool:
    var base_tower_data := {
        "tower_id": max_tower_id,
        "tower_type": tower_type,
        "tower_durability": extra_data.get("tower_durability", 100)
    }
    tower_list.append(base_tower_data)
    max_tower_id += 1
    return max_tower_id - 1

func remove_tower(index: int) -> bool:
    tower_list.remove_at(index)
    return true

func modify_tower(index: int, modify_data: Dictionary) -> void:
    tower_list[index] = modify_data

func to_dict() -> Dictionary:
    return {
        "max_tower_id": max_tower_id,
        "tower_list": tower_list
    }
```

```gdscript
class_name PlayerModel
extends BaseModel

@export var archive_name: String
var towers: TowersModel
var temp: TempModel

func _init(fill_data: Dictionary):
    archive_name = fill_data["name"]
    var tower_data = fill_data.get("towers", {
        "max_tower_id": 0,
        "tower_list": []
    })
    towers = TowersModel.new(tower_data)
    temp = TempModel.new(fill_data.get("curr_map", {}))

func to_dict() -> Dictionary:
    return {
        "archive_name": archive_name,
        "towers": towers.to_dict()
    }
```

> **踩坑点**：`BaseModel` 继承自 `Node`，但数据模型通常不需要进入场景树。如果不需要场景树功能，可以继承自 `RefCounted` 以获得自动内存管理。

> **踩坑点**：`_init()` 中不能使用 `@export` 变量的默认值，因为 `@export` 的值在 `_ready()` 时才被编辑器赋值。在 `_init()` 中应从参数获取所有数据。

---

## 3. 加密存档系统

> 来源文件：`managers/game_archive_manager.gd`

### 3.1 加密读写

```gdscript
extends Node

const archive_path: String = "user://archive"
const archive_file_path: String = "user://archives.dat"
const private_key: String = "69D6822B625FF242C53A7E0D86C6EE0E"

var player: PlayerModel

func save_archive(save_archive_name: String = "") -> void:
    var dir := DirAccess.open(archive_path)
    if not dir:
        DirAccess.make_dir_absolute(archive_path)
        dir = DirAccess.open(archive_path)

    var file := FileAccess.open_encrypted_with_pass(
        archive_path + "/" + save_archive_name,
        FileAccess.WRITE,
        private_key
    )
    if file:
        var data := JSON.stringify(player.to_dict())
        file.store_line(data)
        file.close()

func load_archive(load_archive_name: String) -> void:
    var file := FileAccess.open_encrypted_with_pass(
        archive_path + "/" + load_archive_name,
        FileAccess.READ,
        private_key
    )
    if not file:
        push_error("存档不存在: %s" % load_archive_name)
        return

    var player_dict: Dictionary
    while file.get_position() < file.get_length():
        var line := file.get_line()
        player_dict = JSON.parse_string(line)

    if player_dict:
        player = PlayerModel.new(player_dict)
```

### 3.2 存档列表管理

```gdscript
static func show_all_archive() -> Array[Dictionary]:
    if not DirAccess.dir_exists_absolute(archive_path):
        DirAccess.make_dir_absolute(archive_path)

    var file_names: Array[String] = []
    var dir := DirAccess.open(archive_path)
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".dat"):
                file_names.append(file_name)
            file_name = dir.get_next()

    var archives_file := FileAccess.open_encrypted_with_pass(
        archive_file_path, FileAccess.READ, private_key
    )
    if not archives_file:
        return []

    var archives_dict: Dictionary
    while archives_file.get_position() < archives_file.get_length():
        var data := archives_file.get_line()
        archives_dict = JSON.parse_string(data)

    if not archives_dict:
        return []

    var result: Array[Dictionary] = []
    for name: String in file_names:
        if name in archives_dict["archives"]:
            result.append({
                "name": name,
                "total_time": archives_dict["archives"][name].get("total_time", 0)
            })
    return result
```

> **踩坑点**：`FileAccess.open_encrypted_with_pass` 使用 AES-256 加密。密钥长度建议至少 32 个字符。密钥硬编码在代码中不安全，生产环境应使用用户输入的密码或设备唯一标识作为密钥。

> **踩坑点**：`JSON.stringify()` 和 `JSON.parse_string()` 只能处理基本类型（int、float、String、Array、Dictionary）。不能序列化 Object、Resource、Node 等复杂类型。数据模型必须实现 `to_dict()` 方法将自身转换为可序列化的 Dictionary。

> **踩坑点**：`user://` 路径在不同平台上的实际位置不同。Windows 上是 `%APPDATA%/Godot/app_userdata/项目名/`。使用 `DirAccess.make_dir_absolute()` 确保目录存在。

---

## 4. 异步场景加载管理器

> 来源文件：`managers/load_manager.gd`

### 4.1 完整实现

```gdscript
extends Node

signal progress_change(progress: float)
signal load_done

@export var loading_scene_path: String = "res://scenes/loading_screen/loading_scene.tscn"
var loading_scene: PackedScene
var _loaded_resource: PackedScene
var _now_loading_scene_path: String
var _progress: Array = []
var use_sub_threads: bool = true

func _ready():
    loading_scene = load(loading_scene_path)
    set_process(false)

func load_scene(scene_path: String) -> void:
    _now_loading_scene_path = scene_path

    var loading_instance := loading_scene.instantiate()
    progress_change.connect(loading_instance._update_progress_bar)
    load_done.connect(loading_instance._start_outro_animation)

    get_tree().get_root().add_child(loading_instance)
    await Signal(loading_instance, "loading_screen_has_full_coverage")

    var state := ResourceLoader.load_threaded_request(
        _now_loading_scene_path, "", use_sub_threads
    )
    if state == OK:
        set_process(true)

func _process(_delta: float) -> void:
    var status := ResourceLoader.load_threaded_get_status(
        _now_loading_scene_path, _progress
    )
    match status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, \
        ResourceLoader.THREAD_LOAD_FAILED:
            push_error("加载失败: %s" % _now_loading_scene_path)
            return
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            progress_change.emit(_progress[0])
        ResourceLoader.THREAD_LOAD_LOADED:
            _loaded_resource = ResourceLoader.load_threaded_get(
                _now_loading_scene_path
            )
            progress_change.emit(1.0)
            load_done.emit()
            get_tree().change_scene_to_packed(_loaded_resource)
            set_process(false)
```

### 4.2 加载界面配合

```gdscript
extends CanvasLayer

signal loading_screen_has_full_coverage

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $Panel/ProgressBar

func _update_progress_bar(new_value: float) -> void:
    progress_bar.set_value_no_signal(new_value * 100)

func _start_outro_animation() -> void:
    await animation_player.animation_finished
    animation_player.play("end_load")
    await animation_player.animation_finished
    animation_player.play("RESET")
    await animation_player.animation_finished
    queue_free()
```

> **踩坑点**：`ResourceLoader.load_threaded_get_status()` 的第二个参数必须是外部传入的 `Array`，函数会将进度值（0.0~1.0）写入此数组的第一个元素。

> **踩坑点**：`load_threaded_request` 同一路径只能有一个加载请求。重复请求会被忽略。加载完成后必须调用 `load_threaded_get` 获取资源并释放加载槽。

> **踩坑点**：加载界面使用 `await Signal(loading_instance, "loading_screen_has_full_coverage")` 等待入场动画完成后再开始加载资源，确保用户看到过渡效果。

---

## 5. 配置管理器（ConfigFile）

> 来源文件：`managers/configure_manager.gd`

### 5.1 实现

```gdscript
extends Node

var game_config: ConfigFile
var game_settings: Dictionary = {}

func _init():
    game_config = ConfigFile.new()
    game_config.load("res://conf/game_config.cfg")
    game_settings["screen_size"] = Vector2i(1920, 1080)

func get_value(section: String, key: String, default: Variant = null) -> Variant:
    return game_config.get_value(section, key, default)

func edit_conf_file_by_section(section: String, content: Dictionary = {}) -> void:
    if content == {}:
        push_error("配置文件内容为空")
        return
    for key in content:
        game_config.set_value(section, key, content[key])
    game_config.save("res://conf/game_config.cfg")
```

### 5.2 配置文件格式

```ini
[towers]
bishops/name="主教塔"
bishops/desc="远程攻击，高伤害"
bishops/texture_normal="res://assets/towers/bishops.png"
bishops/foundation_type="curb"

queen/name="皇后塔"
queen/desc="范围攻击，低伤害"
queen/texture_normal="res://assets/towers/queen.png"
queen/foundation_type="foundation"

[loading_scene]
loading_scene_path="res://scenes/loading_screen/loading_scene.tscn"
```

> **踩坑点**：`ConfigureManager` 在 `_init()` 中加载配置文件，但 Autoload 的 `_init()` 在场景树初始化之前执行。此时 `res://` 路径可能尚未完全可用。建议将配置加载移到 `_ready()` 中，或使用 `ProjectSettings` 替代。

> **踩坑点**：`ConfigFile` 保存到 `res://` 路径在导出后不可写（只读）。运行时需要修改的配置应保存到 `user://` 路径。

---

## 6. Camera2D 完整控制器

> 来源文件：`scenes/tower_defense/tower_defense_camera.gd`

### 6.1 完整实现

```gdscript
extends Camera2D

@export var max_scale: float = 2.0
@export var min_scale: float = 1.0
@export var step_scale: float = 0.1
@export var scale_speed: int = 8
@export var camera_speed: int = 300

@export var shake: bool = false
@export var offset_rate: float = 0.2
@export var x_offset: int = 10
@export var y_offset: int = 20

var _times: int = 0
var curr_scale: float = 1.0

func _handle_zoom(delta: float) -> bool:
    var target_zoom := Vector2.ONE * curr_scale
    if zoom != target_zoom:
        zoom = zoom.lerp(target_zoom, scale_speed * delta)
        return true
    return false

func _handle_move(delta: float) -> Vector2:
    var direction := Vector2.ZERO
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1

    if direction == Vector2.ZERO:
        return position

    direction = direction.normalized() * camera_speed
    return position + direction * delta

func _fix_position(target: Vector2) -> Vector2:
    var camera_size := Vector2(get_viewport_rect().size)
    var viewport_size := camera_size / zoom
    var min_v := viewport_size / 2
    var max_v := camera_size - viewport_size / 2
    target.x = clamp(target.x, min_v.x, max_v.x)
    target.y = clamp(target.y, min_v.y, max_v.y)
    return target

func _handle_shake() -> void:
    if shake:
        _times += 1
        var final_pos := Vector2(sin(_times) * x_offset, sin(_times) * y_offset)
        offset = offset.lerp(final_pos, offset_rate)
    elif _times:
        _times = 0

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var target_value := curr_scale
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            target_value = curr_scale + step_scale
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            target_value = curr_scale - step_scale
        curr_scale = clamp(target_value, min_scale, max_scale)

func _ready():
    position = get_viewport_rect().size / 2

func _process(delta: float) -> void:
    _handle_shake()
    var zoom_changed: bool = _handle_zoom(delta)
    var target := _handle_move(delta)
    if zoom_changed:
        target = _fix_position(target)
    position = target
```

### 6.2 功能分解

| 功能 | 实现方式 | 关键 API |
|------|---------|---------|
| 缩放 | 滚轮控制 `curr_scale`，`lerp` 平滑过渡 | `zoom`、`lerp()` |
| 移动 | 方向键输入，归一化后乘以速度 | `Input.is_action_pressed()` |
| 边界限制 | 根据缩放后的视口大小计算边界 | `get_viewport_rect()`、`clamp()` |
| 震动 | 正弦函数生成偏移，`lerp` 平滑 | `offset`、`sin()` |

> **踩坑点**：缩放时必须重新计算边界限制。`_fix_position()` 通过 `camera_size / zoom` 计算当前视口实际大小，确保相机不会超出地图边界。

> **踩坑点**：`_unhandled_input` 而非 `_input` 处理滚轮事件，避免被 UI 控件拦截。如果 UI 需要消费滚轮事件（如滚动列表），`_unhandled_input` 不会被触发。

> **踩坑点**：震动使用 `sin()` 函数而非 `randf()`，产生有规律的周期性震动效果。如果需要更自然的随机震动，使用 `randf_range()`。

---

## 7. 建造系统：弹出面板与类型匹配

> 来源文件：`scenes/tower_defense/game_scenes/build_popup_panel.gd`、`buildable_menu_unit.gd`

### 7.1 插座-插头类型匹配

```gdscript
func popup_menu(trigger_button: Control) -> void:
    var support_type: Array[String] = trigger_button.support_type
    var has_usable := false

    for unit in _tower_unit_list:
        if support_type.has(unit.tower_type):
            has_usable = true
            unit.visible_in_panel = true
        else:
            unit.visible_in_panel = false

    if not has_usable:
        $MarginContainer/Label.visible = true
    else:
        $MarginContainer/Label.visible = false

    self.show()
```

### 7.2 弹出面板位置计算

```gdscript
func _on_towerpit_pressed(trigger_button: Control) -> void:
    var mouse_pos: Vector2 = get_viewport().get_mouse_position()
    var screen_size := ConfigureManager.game_settings["screen_size"]
    var content_size := $MarginContainer.size

    var pop_x := clamp(mouse_pos.x, 0, screen_size.x - content_size.x)
    var pop_y := clamp(mouse_pos.y, 0, screen_size.y - content_size.y)

    offset = Vector2i(pop_x, pop_y)
    popup_menu(trigger_button)
```

### 7.3 点击外部关闭

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and visible:
        self.hide()
```

### 7.4 塔坑信号传递链

```
TowerPit (TextureButton)
    │ pressed signal
    ▼
BuildPopupPanel._on_towerpit_pressed(triggerButton)
    │ 显示弹出面板，过滤可建造的塔
    ▼
BuildableMenuUnit._on_button_pressed()
    │ tower_selected signal
    ▼
BuildPopupPanel._on_buildable_menu_unit_tower_selected(tower_index)
    │ 隐藏面板，标记塔为使用中
```

> **踩坑点**：弹出面板位置使用 `clamp()` 确保不超出屏幕边界。必须考虑面板自身的 `size`，否则右侧和底部的面板会被裁剪。

> **踩坑点**：`_unhandled_input` 处理点击外部关闭时，面板自身的按钮点击也会触发 `_unhandled_input`。需要确保按钮的 `pressed` 信号先于 `_unhandled_input` 处理（Godot 的输入传播顺序保证了这一点）。

---

## 8. 角色继承体系（攻击/受击分离）

> 来源文件：`scenes/tower_defense/characters/`

### 8.1 继承结构

```
BaseCharacter (Node2D) ← 角色基类
├── Tower (防御塔)
│   ├── BaseAttacker (Node) ← 攻击组件
│   │   ├── MeleeAttacker (近战攻击)
│   │   └── RangeAttacker (远程攻击)
│   └── BaseUnderAttacked (Node) ← 受击组件
```

### 8.2 组合优于继承

项目使用**组合模式**而非深层继承：

```gdscript
class_name BaseCharacter
extends Node2D

@export_group("GameInfo")
@export var char_name: String
@export var can_attack: bool
@export var can_attacked: bool

@export_group("AttackInfo")
@export_node_path var attack_node  ## 攻击组件节点路径

@export_group("AttackedInfo")
@export_node_path var attacked_node  ## 受击组件节点路径

@export_group("BuffPack")
@export_multiline var buff_pack: Dictionary
@export var buffs: Array
```

```gdscript
class_name BaseAttacker
extends Node

@export_group("Attack")
@export var is_range: bool
@export var range: int
@export var attack_speed: float

@export_subgroup("AttributeFirepower")
@export var normal: int
@export var file: int    # 火属性
@export var water: int   # 水属性
@export var wind: int    # 风属性
@export var light: int   # 光属性
@export var dark: int    # 暗属性
```

> **设计模式**：攻击和受击作为独立组件（Node 子类），通过 `@export_node_path` 关联到角色。这样不同的角色可以自由组合不同的攻击/受击行为，避免深层继承树。

> **踩坑点**：`@export_group` 和 `@export_subgroup` 只影响编辑器中的属性分组显示，不影响运行时行为。合理使用可以让检查器面板更清晰。

> **踩坑点**：`@export_node_path` 在编辑器中显示为节点路径选择器，运行时需要通过 `get_node()` 或 `get_node_or_null()` 获取实际节点。

---

## 9. 动态脚本挂载（运行时 set_script）

> 来源文件：`scenes/tower_defense/tower_defense.gd`

### 9.1 运行时给节点挂载脚本

```gdscript
func _ready():
    var pits_list: Array[Node] = get_tree().get_nodes_in_group("Pits")
    var pits_script = load("res://scenes/tower_defense/tower_pit.gd")

    for pit in pits_list:
        if not pit is TextureButton:
            continue
        pit.set_script(pits_script)
        pit.pressed.connect(pit._on_pressed)
        pit.on_towerpit_pressed.connect($BuildPopupPanel._on_towerpit_pressed)
```

### 9.2 被挂载的脚本

```gdscript
extends TextureButton

signal on_towerpit_pressed(triggerButton)

@export var using: bool = true:
    set(value):
        if typeof(value) != TYPE_BOOL:
            return
        using = value
        disabled = value
        visible = value

@export var toward: Vector2i
@export var support_type: Array[String] = ["curb", "foundation"]

func _on_pressed():
    on_towerpit_pressed.emit(self)
```

> **踩坑点**：`set_script()` 会替换节点的脚本，但不会重新执行 `_ready()`。如果新脚本需要在 `_ready()` 中初始化，需要手动调用。

> **踩坑点**：`set_script()` 后，`@export` 变量的默认值会覆盖节点上已有的属性值。如果场景中已设置了这些属性，需要在 `set_script()` 后重新赋值。

> **踩坑点**：`set_script()` 后连接信号时，方法名必须以 `self.` 或节点引用开头（如 `pit._on_pressed`），因为新脚本的方法与旧脚本的方法是不同的函数引用。

---

## 10. 节点组（Group）在地图设计中的应用

> 来源文件：`scenes/tower_defense/tower_defense.gd`

### 10.1 通过组获取地图元素

```gdscript
func _ready():
    var pits_list: Array[Node] = get_tree().get_nodes_in_group("Pits")
    if pits_list.is_empty():
        push_warning("地图中没有 Pits 组")
```

### 10.2 设计模式

在地图编辑器中，将所有可放置塔的位置（TowerPit）添加到 `Pits` 组。战斗场景加载地图后，通过 `get_nodes_in_group("Pits")` 获取所有位置，统一挂载脚本和连接信号。

> **踩坑点**：`get_nodes_in_group()` 返回的是节点引用数组，不是副本。修改数组中的节点会直接影响场景中的节点。

> **踩坑点**：节点组是全局的，同一组名在不同场景中都会被收集。如果多个场景有同名组，`get_nodes_in_group()` 会返回所有场景中的匹配节点。使用 `get_tree().get_nodes_in_group()` 时注意作用域。

---

## 11. 自定义 Tooltip 实现

> 来源文件：`scenes/tower_defense/game_scenes/buildable_menu_unit.gd`

### 11.1 覆写 `_make_custom_tooltip`

```gdscript
func _make_custom_tooltip(for_text: String) -> Control:
    var label := Label.new()
    var target_text := ""
    if tower_using:
        target_text += "防御塔使用中\n"
    label.text = target_text + for_text
    return label
```

### 11.2 触发条件

```gdscript
@export var tower_desc: String = "主教塔的说明"

func _ready():
    tooltip_text = tower_desc
```

> **踩坑点**：`tooltip_text` 必须设置在节点自身上（不是子节点），否则 `_make_custom_tooltip` 不会被触发。

> **踩坑点**：`_make_custom_tooltip` 返回的 Control 节点会被 Godot 自动管理生命周期（显示/隐藏/销毁）。不要手动 `add_child` 或 `queue_free` 这个节点。

---

## 12. 项目踩坑记录与最佳实践

### 12.1 踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| Autoload `_init()` 中加载配置失败 | `_init()` 在场景树初始化前执行 | 将配置加载移到 `_ready()` |
| `set_script()` 后属性丢失 | 新脚本的默认值覆盖了节点属性 | `set_script()` 后手动恢复属性 |
| 加密存档无法在 `res://` 写入 | 导出后 `res://` 只读 | 使用 `user://` 路径 |
| `JSON.parse_string()` 返回 null | 存档文件格式损坏 | 添加格式校验和错误处理 |
| 弹出面板被屏幕裁剪 | 未考虑面板尺寸 | 使用 `clamp()` 计算位置 |
| Camera2D 缩放后超出边界 | 未根据缩放调整限制范围 | `_fix_position()` 动态计算 |
| `@export` 变量在 `_init()` 中无效 | 编辑器赋值在 `_ready()` 时才生效 | `_init()` 中从参数获取数据 |
| 节点组返回跨场景节点 | 组是全局的 | 使用有意义的组名前缀 |

### 12.2 最佳实践

1. **数据模型与场景分离**：使用 `BaseModel` + `to_dict()` 模式，将游戏数据与 Godot 节点解耦，便于序列化和网络同步
2. **组合优于继承**：攻击/受击作为独立组件，通过节点路径关联，避免深层继承
3. **Autoload 职责单一**：每个 Autoload 只负责一个领域（加载/配置/存档），避免上帝对象
4. **信号链传递**：TowerPit → BuildPopupPanel → BuildableMenuUnit，通过信号解耦
5. **插座-插头类型系统**：通过 `support_type` 数组实现灵活的类型匹配，一个插座支持多种插头
