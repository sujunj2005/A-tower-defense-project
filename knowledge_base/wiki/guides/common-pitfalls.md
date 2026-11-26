# 常见踩坑避雷指南

> **适用版本**: Godot 4.x（4.6+）  
> **来源**: [Base 层 - 19_Pitfall_Records.md](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md), [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md), [GUT_Testing_Pitfalls.md](../../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md), [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md), [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md)  
> **重要性**: 🔴 必读

---

## 📋 简介

按问题查阅踩坑结论、示例与原始复盘。§32–§35 的当前做法集中在项目测试规范。项目专项和其他编号可从[踩坑记录完整索引](../../outline/踩坑记录完整索引.md)查找。

带历史案例的示例用于解释当时的故障。当前项目源码和适用版本以各条的查证资料为准。

---

## 🎯 快速查找

### 按问题查找

| 问题描述 | 正文 |
|----------|------|
| "Docker 服务请求恒定 5s 超时" | [§T1](../../outline/环境与工具链踩坑记录.md) |
| "除法结果不对" | [§1](#1-整数除法) |
| "场景切换崩溃" | [§7](#7-场景切换时删除当前场景) |
| "碰撞检测失效" | [§13](#13-collisionshape-scale-必须保持-11) |
| "纹理不显示" | [§23](#23-tres-文件中的注释导致字段加载失败) |
| "配置值加载错误" | [§23](#23-tres-文件中的注释导致字段加载失败) |
| "TileMap 边框不对齐" | [§24](#24-tilemap-shader-边框对齐问题) |
| "Autoload class_name 冲突" | [§27](#27-autoload-脚本禁止-class_name-声明) |
| "Autoload 互访问报错" | [§28](#28-autoload-单例间互访不能用-globalget_node) |
| "trait 保留关键字报错" | [§29](#29-trait-是-gdscript-4x-保留关键字) |
| "GUT 测试 API 不存在" | [§30](#30-gut-测试框架-api-陷阱) |
| ":= 类型推断失败" | [§31](#31--类型推断限制与-godot-缓存问题) |
| "面板无法显示/状态不一致" | [§26](#26-内嵌-getset-创建双重状态--高) |
| "GUT 测试运行器挂起" | [§32](../../outline/Godot%20编码规范汇总.md#131-gut-测试运行器模式--强制) |
| "Autoload 引用替换挂起" | [§33](../../outline/Godot%20编码规范汇总.md#132-autoload-会话引用与重置) |
| "watch_signals Autoload 挂起" | [§34](../../outline/Godot%20编码规范汇总.md#133-autoload-信号测试) |
| "测试引用不存在属性" | [§35](../../outline/Godot%20编码规范汇总.md#134-测试前校验字段名--建议) |
| "select_option 参数类型错误" | [§36](#36-select_option-第二个参数类型错误--中) |
| ".tres 引用已删除文件加载失败" | [§37](#37-tres-文件-ext_resource-引用已删除文件导致整体加载失败--高) |
| "条件判断永远不匹配" | [§38](#38-数据格式不一致导致条件判断永远失败--中) |
| "修改数据格式后成就失效" | [§39](#39-修改数据格式时遗漏配置文件消费者--中) |
| "Tooltip遮挡闪烁" | [§40](#40-tooltip遮挡触发元素导致闪烁循环--中) |
| "场景切换绕过UI不更新" | [§41](#41-场景切换绕过导致ui不更新--高) |
| "分裂敌人未计入存活数" | [§42](#42-分裂召唤敌人未被计入存活数--中) |
| "freed instance报错" | [§43](#43-字典中保留已释放节点引用导致freed-instance报错--高) |
| "击退与路径移动冲突" | [§44](#44-击退效果与路径移动冲突--中) |
| "奖励重复显示" | [§45](#45-事件战斗奖励重复显示--中) |
| "效果字段名不一致" | [§46](#46-词条效果字段名不一致--中) |
| "节点移出场景树后get_node_or_null报错" | [§51](#51-节点被移出场景树后调用get_node_or_null报错--高) |
| "以freed对象为key的Dictionary遍历崩溃" | [§52](#52-以freed对象为key的dictionary遍历崩溃--高) |
| "路径偏移不能用侧向力实现" | [§53](#53-怪物路径偏移不能用侧向力实现--中) |
| "分裂/召唤怪偏移需叠加父怪偏移" | [§54](#54-分裂召唤怪偏移需叠加父怪偏移--中) |
| "怪出生时current_path_index应从1开始" | [§55](#55-怪出生时current_path_index应从1开始--中) |
| "实际生成路径可能与预期不同" | [§56](#56-实际生成路径可能与预期不同--中) |
| "Dictionary.has()对null值返回true" | [§57](#57-dictionaryhas对null值返回true--中) |
| "老年阶段不应无条件触发终局" | [§58](#58-老年阶段不应无条件触发终局--高) |
| "暴击特效额外伤害实例" | [§81](#81-暴击特效不应作为额外伤害实例--高) |
| "debuff设置了但不生效" | [§82](#82-debuff_amount设置但未使用导致效果不生效--中) |
| "翻译键不匹配格式化报错" | [§83](#83-翻译键不匹配导致格式化报错--高) |
| "终局状态机被UI回调覆盖" | [§84](#84-终局状态机被ui回调覆盖--高) |
| "ParticleProcessMaterial.color_ramp类型" | [§85](#85-particleprocessmaterialcolor_ramp类型限制--中) |

---

## 1️⃣ GDScript 踩坑

### §1 整数除法

**问题**: 两个整数相除会丢弃小数部分

```gdscript
var a = 5 / 2      # 结果为 2，不是 2.5！❌
var b = 5.0 / 2    # 结果为 2.5 ✅
```

**解决方案**:
```gdscript
# ✅ 使用浮点数除数
var half_size = tile_size / 2.0
var center_x = viewport_size.x / 2.0

# ✅ 或显式转换
var half_size = float(tile_size) / 2
```

**常见场景**:
- 计算中心点：`position + size / 2.0`
- 计算一半距离：`distance / 2.0`
- 向量计算：`Vector2(size / 2.0, size / 2.0)`

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#1-整数除法)

### §2 Lambda 变量捕获

**问题**: Lambda 按值捕获，之后修改不影响

```gdscript
var x = 42
var lambda = func (): print(x)  # 按值捕获
x = "Hello"
lambda.call()  # 输出 42，不是 "Hello" ❌
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#2-lambda-变量捕获)

### §3 类型数组赋值

**问题**: 类型数组不能直接赋值

```gdscript
var a: Array[Node2D] = [Node2D.new()]
var b: Array[Node] = []
b = a  # 错误！类型不兼容 ❌
b.assign(a)  # 正确 ✅
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#3-类型数组赋值)

### §4 @export 在 _init() 中读取

**问题**: @export 的值在 _ready() 时才被赋值

```gdscript
@export var health: int = 100

func _init():
    print(health)  # 返回默认值 100，不是检查器设置的值 ❌

func _ready():
    print(health)  # 正确返回检查器值 ✅
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#4-export-在-_init-中读取)

### §5 静态变量与 @export/@onready

**问题**: 静态变量不能使用这些装饰器

```gdscript
static var my_var: int  # 错误！不能用于静态变量 ❌
@export var my_var: int   # 正确 ✅
@onready var my_var       # 正确 ✅
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#5-静态变量与-exportonready)

---

## 2️⃣ 节点系统踩坑

### §6 queue_free vs free

**问题**: free() 立即删除，queue_free() 延迟删除

```gdscript
node.free()    # 立即删除！后续引用会崩溃 ❌
node.queue_free()  # 延迟到帧末删除 ✅
```

**使用场景**:
- ✅ **queue_free()**: 大多数情况（安全）
- ⚠️ **free()**: 确定不再引用且需要立即释放内存

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#6-queue_free-vs-free)

### §7 场景切换时删除当前场景

**问题**: 在信号回调中直接删除当前场景会崩溃

```gdscript
# ❌ 错误：在信号回调中直接删除
get_tree().change_scene_to_file("res://scene2.tscn")  # 可能崩溃

# ✅ 正确：使用 call_deferred 延迟执行
get_tree().change_scene_to_file.call_deferred("res://scene2.tscn")
```

**常见场景**:
- 按钮点击切换场景
- 信号触发场景切换
- 死亡后重新加载场景

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#7-场景切换时删除当前场景)

### §8 add_child 后 _ready() 未调用

`_ready()` 在节点首次进入场景树时按顺序执行。父节点已经在树中时，普通的 `add_child(enemy)` 会先完成新子节点的 `_ready()` 再返回。父节点还在树外时，子节点也要等实际入树才会执行 `_ready()`。

```gdscript
var enemy = enemy_scene.instantiate()
enemy.configure(spawn_data)  # 若 _ready() 需要这份数据，先写入配置
add_child(enemy)
```

如果初始化需要 `@onready` 引用，把这部分工作放在 `_ready()`。可在需要时用 `is_node_ready()` 查询状态。

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#8-add_child-后-_ready-未调用) · [节点生命周期](https://docs.godotengine.org/en/4.6/tutorials/scripting/overridable_functions.html)

### §9 循环引用 preload

**问题**: 两个脚本互相 preload 会报错

```gdscript
# a.gd
var b_scene = preload("res://b.tscn")
# b.gd 如果 preload("res://a.tscn") → 循环引用错误 ❌
```

**解决方案**:
- 使用 `load()` 动态加载
- 使用 Autoload 单例管理
- 重构代码避免循环依赖

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#9-循环引用-preload)

### §10 get_node 使用节点名称而非类型

`get_node()` 按 `NodePath` 查找。节点名或路径随场景调整时，`$Player` 和 `get_node("Player")` 都要随之更新。`as Node2D` 只检查找到的对象能否转换为目标类型。

```gdscript
@onready var player := get_node_or_null("Player") as Node2D
```

可选节点使用 `get_node_or_null()` 并处理空引用。若希望同场景内重新挂载节点后仍能引用它，可将节点配置为场景唯一名称，再用 `%Player`。

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#10-get_node-使用节点名称而非类型) · [场景唯一节点](https://docs.godotengine.org/en/4.6/tutorials/scripting/scene_unique_nodes.html)

---

## 3️⃣ 物理系统踩坑

### §11 move_and_slide 已包含 delta

`CharacterBody2D.move_and_slide()` 从 `velocity` 读取速度，并在内部使用物理步长。向 `velocity` 累加重力这样的加速度时需要乘以 `delta`。

```gdscript
func _physics_process(delta: float) -> void:
    velocity.y += gravity * delta
    move_and_slide()
```

返回值是表示是否碰撞的 `bool`，错误示例中的 `velocity = move_and_slide()` 会把布尔值赋给速度。

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#11-move_and_slide-已包含-delta) · [CharacterBody2D.move_and_slide()](https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html#class-characterbody2d-method-move-and-slide)

### §12 RigidBody 直接设置位置

每帧从 `_process()` 改写刚体位置会与物理模拟争夺控制。常规推动使用力或冲量，精细控制刚体状态使用 `_integrate_forces()`。

```gdscript
extends RigidBody3D

func launch_toward(target: Vector3, strength: float) -> void:
    apply_central_impulse((target - global_position).normalized() * strength)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    # 示例：限制速度，同时保留碰撞和重力产生的运动。
    state.linear_velocity = state.linear_velocity.limit_length(20.0)
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#12-rigidbody-直接设置位置) · [RigidBody3D](https://docs.godotengine.org/en/4.6/classes/class_rigidbody3d.html)

### §13 CollisionShape Scale 必须保持 (1,1)

**问题**: 修改父节点的 scale 会导致碰撞检测失效

```gdscript
# ❌ 错误：缩放父节点
$CharacterBody2D.scale = Vector2(2, 2)

# ✅ 正确：调整 shape.size
$CollisionShape2D.shape.size = Vector2(64, 64)
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#13-collisionshape-scale-必须保持-11)

### §14 物理代码必须在 _physics_process

`_process()` 的调用频率跟随渲染帧。把刚体和角色的持续移动逻辑放在 `_physics_process()`，以固定物理步进处理碰撞。

```gdscript
func _physics_process(_delta: float) -> void:
    move_and_slide()
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#14-物理代码必须在-_physics_process) · [CharacterBody2D.move_and_slide()](https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html#class-characterbody2d-method-move-and-slide)

### §15 is_on_floor() 只在 move_and_slide 后有效

`is_on_floor()` 读取上一次 `move_and_slide()` 的碰撞结果。`move_and_collide()` 不会刷新这个状态。要读取当前物理步的着地结果，在移动后读取。

```gdscript
move_and_slide()
var grounded_this_step := is_on_floor()
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#15-is_on_floor-只在-move_and_slide-后有效) · [CharacterBody2D.is_on_floor()](https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html#class-characterbody2d-method-is-on-floor)

---

## 4️⃣ UI 系统踩坑

### §16 Control.mouse_filter

**问题**: mouse_filter 设置不当导致输入失效

```gdscript
# STOP: 阻止事件传递
# IGNORE: 忽略输入
# PASS: 传递事件

# ✅ 根据需求设置
$Button.mouse_filter = Control.MOUSE_FILTER_STOP
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#16-controlmouse_filter)

### §17 容器内子节点位置被覆盖

**问题**: 容器会自动管理子节点位置

```gdscript
# ❌ 错误：在容器中手动设置子节点位置
$VBoxContainer/Label.position = Vector2(100, 100)  # 会被覆盖

# ✅ 正确：使用 MarginContainer 或锚点
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#17-容器内子节点位置被覆盖)

### §18 锚点预设后手动偏移

只设置锚点预设后，还要考虑偏移量和控件尺寸。需要居中时可以同时设置锚点与偏移，居中后再设置 `position` 会改变布局。

```gdscript
$Label.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
```

手动设居中偏移时，水平方向两侧应配合调整，例如左侧 `-size.x / 2.0` 与右侧 `size.x / 2.0`。如果控件由 `Container` 布局，使用容器的尺寸标志与边距。

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#18-锚点预设后手动偏移) · [Control 布局预设](https://docs.godotengine.org/en/4.6/classes/class_control.html#class-control-method-set-anchors-and-offsets-preset)

---

## 5️⃣ 渲染系统踩坑

### §19 screen_get_scale 平台限制

使用 `DisplayServer.screen_get_scale()` 查询显示器缩放。Godot 4.6 在 Android、iOS、Web、macOS 和 Wayland 实现了该接口，其他平台返回 `1.0`。macOS 对 Retina 返回 `2.0`。Wayland 优先传入 `SCREEN_OF_MAIN_WINDOW` 以获得主窗口所在屏幕的缩放。

```gdscript
var scale := DisplayServer.screen_get_scale(DisplayServer.SCREEN_OF_MAIN_WINDOW)
```

需要跨平台可调的界面时，保留手动缩放选项。

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#19-screen_get_scale-平台限制) · [DisplayServer.screen_get_scale()](https://docs.godotengine.org/en/4.6/classes/class_displayserver.html#class-displayserver-method-screen-get-scale)

### §20 Vector2/Vector3 内部使用 float32

GDScript 标量 `float` 为 64 位。Godot 默认构建中的 `Vector2`、`Vector3` 分量为 32 位，坐标越大，可分辨的最小位移越大。引擎使用 `precision=double` 构建时，向量分量可用双精度。

```gdscript
var far_position := Vector3(1_000_000.0, 0.0, 0.0)
# 在默认精度下，增加 0.01 可能仍得到相同的坐标。
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#20-vector2vector3-内部使用-float32) · [Vector3 精度](https://docs.godotengine.org/en/4.6/classes/class_vector3.html)

### §21 3D 旋转避免欧拉角

连续累积欧拉旋转在某些角度会出现万向节锁。组合或插值 3D 旋转时，用 `Node3D.quaternion` 或正交的旋转基。

```gdscript
quaternion = Quaternion.from_euler(Vector3(0.0, PI / 2.0, 0.0))
```

要从已有欧拉角构造旋转矩阵，也可以用 `Basis.from_euler()`。

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#21-3d-旋转避免欧拉角) · [Node3D.quaternion](https://docs.godotengine.org/en/4.6/classes/class_node3d.html#class-node3d-property-quaternion)

### §22 Transform2D 乘法顺序

`Transform2D` 的组合顺序会改变结果，例如非均匀缩放和旋转通常不能交换。将子节点局部变换转成全局变换时，父变换在左。

```gdscript
var world_transform := parent_transform * child_transform
var rotate_then_scale := Transform2D.IDENTITY.rotated(PI / 4.0).scaled(Vector2(2.0, 1.0))
var scale_then_rotate := Transform2D.IDENTITY.scaled(Vector2(2.0, 1.0)).rotated(PI / 4.0)
```

**查证资料** · [原始案例](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md#22-transform2d-乘法顺序) · [Transform2D](https://docs.godotengine.org/en/4.6/classes/class_transform2d.html)

---

## 6️⃣ 资源系统踩坑 🆕

### §23 .tres 文件中的注释导致字段加载失败

原案例在资源字段后使用了 GDScript 的 `#` 注释。该文件的敌人纹理路径读成空字符串，经验掉落回到了默认值 5。

```tres
gold_drop = 20
experience_drop = 50
texture_path = "res://images/enemies/marble_0_0.png"
```

Godot 4.6 的 `.tres` 文本格式使用分号 `;` 引导单行注释。若已在资源文件里写入 `#` 注释，可改用分号或删除注释，再重新载入检查字段。编辑器保存资源时会丢弃注释。

**查证资料** · [Godot_4x_Resource_File_Comment_Issue.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md) · [Godot 4.6 TRES 格式](https://docs.godotengine.org/en/4.6/engine_details/file_formats/tscn.html#tres-file-format)

### §24 TileMap Shader 边框对齐问题

**问题**: TileMap 使用 Shader 时，边框 UV 对齐不正确

```glsl
// ❌ 错误：使用 UV 直接计算
vec2 world_pos = UV * tile_size;

// ✅ 正确：使用 MODEL_MATRIX * VERTEX
vec4 world_vertex = MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0);
vec2 world_pos = world_vertex.xy;
```

**影响范围**:
- TileMap 边框渲染
- 自定义 TileMap Shader
- 地形边缘处理

**详细文档**: [20_TileMap_Shader_Border_Pitfall.md](../../base/practical-experiences/pitfall-cases/20_TileMap_Shader_Border_Pitfall.md)

### §25 窗口尺寸检测问题 🆕

旧案例在 `_ready()` 立即读窗口尺寸，遇到初始尺寸、全屏或多显示器缩放差异。需要窗口尺寸时读取 `Window.size`。如果要确认启动布局，可等待一帧后读取，并通过 `size_changed` 处理后续变动。

```gdscript
func _ready() -> void:
    await get_tree().process_frame
    var window_size := get_window().size
    var viewport_size := get_viewport().get_visible_rect().size
```

`window_size` 是窗口尺寸，`viewport_size` 是视口可见矩形的尺寸。若目的是让界面适应尺寸变化，优先用容器和 `Control.size_flags_horizontal`、`Control.size_flags_vertical`。

**查证资料** · [Godot_4x_Window_Size_Detection_Issue.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Window_Size_Detection_Issue.md) · [Godot 4.6 Window](https://docs.godotengine.org/en/4.6/classes/class_window.html)

### §26 内嵌 get/set 创建双重状态 🔴 高

**问题**: 包装属性时错误地创建了独立状态，导致状态不一致

```gdscript
# ❌ 错误：包装 Control 的 visible 属性时创建了两个独立状态
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if is_panel_visible != value:  # ❌ 检查自身（应该检查 visible）
            is_panel_visible = value    # ❌ 自赋值（冗余）
            visible = value             # ❌ 同步另一个属性
            if is_panel_visible:
                _on_panel_shown()
            else:
                _on_panel_hidden()
    get:
        return is_panel_visible  # ❌ 返回自身（应该返回 visible）

func _complete_tower_building():
    tower_select_ui.visible = false  # ❌ 直接设置 visible，is_panel_visible 仍为 true

func show_at_position(pos: Vector2):
    is_panel_visible = true  # ❌ setter 检查发现已是 true，不执行 visible = true
    # 结果：面板无法显示，点击塔位无反应！
```

**踩坑过程**：
1. 在 `_complete_tower_building()` 中直接设置 `visible = false`
2. `is_panel_visible` 仍为 `true`，状态不同步
3. 下次调用 `show_at_position()` 时设置 `is_panel_visible = true`
4. setter 检查发现 `is_panel_visible` 已经是 `true`，不执行 `visible = true`
5. **结果**：面板无法显示，点击塔位无反应

**解决方案**：

```gdscript
# ✅ 正确：包装 visible 属性
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if visible != value:  # ✅ 检查实际的 visible
            visible = value    # ✅ 直接设置 visible
            if visible:
                _on_panel_shown()
            else:
                _on_panel_hidden()
    get:
        return visible  # ✅ 返回实际的 visible

func _complete_tower_building():
    is_panel_visible = false  # ✅ 始终使用包装属性，状态保持一致

func show_at_position(pos: Vector2):
    is_panel_visible = true  # ✅ 正常工作
    position = pos
```

读写统一经过包装属性，显示回调和面板通过同一个状态判断。

**查证资料** · [GDScript_Setter_Getter_Dual_State_Pitfall.md](../../base/practical-experiences/pitfall-cases/GDScript_Setter_Getter_Dual_State_Pitfall.md) · [GDScript_Code_Standards.md](../../base/practical-experiences/code-standards/GDScript_Code_Standards.md#34-内嵌-getset-使用场景与常见错误-) · [gdscript-standards.md](../concepts/gdscript-standards.md#35-内嵌-getset-使用场景与常见错误-)

---

## 7️⃣ Autoload 单例踩坑 🆕

### §27 Autoload 脚本禁止 class_name 声明

**问题**: Autoload 脚本添加 `class_name` 会导致 "Class 'XXX' hides an autoload singleton" 编译错误

**原因**: Autoload 注册名本身就是全局标识符，再声明 class_name 会产生命名冲突

**解决方案**: 移除所有 Autoload 脚本的 `class_name` 声明，Autoload 名称即全局变量名

```gdscript
# ❌ 错误：Autoload 脚本中声明 class_name
# res://autoload/global.gd
class_name Global  # 报错：Class "Global" hides an autoload singleton
extends Node

# ✅ 正确：Autoload 脚本不声明 class_name
# res://autoload/global.gd
extends Node
# "Global" 已通过 Autoload 注册成为全局标识符
```

**影响范围**: 所有 Autoload 单例脚本

**详细文档**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#27-autoload-脚本禁止-class_name-声明--高)

### §28 Autoload 单例间互访不能用 Global.get_node()

**问题**: 使用 `Global.get_node("ConfigManager")` 访问其他 Autoload 单例会报 "Node not found" 错误

**原因**: Godot 4.x 中所有 Autoload 都挂载在 `/root/` 下，互为兄弟节点，不是 Global 的子节点

**解决方案**: 直接使用 Autoload 注册名称作为全局变量访问

```gdscript
# ❌ 错误：通过 Global.get_node() 访问兄弟 Autoload
config_manager = Global.get_node("ConfigManager") as ConfigManager  # Node not found!

# ✅ 正确：直接使用 Autoload 全局名称
config_manager = ConfigManager  # Autoload 名称即全局变量

# ✅ 正确：也可以通过 /root/ 路径访问（不推荐，冗长）
config_manager = get_node("/root/ConfigManager")
```

**节点树结构说明**:
```
/root
  ├── Global          ← Autoload，/root 的子节点
  ├── ConfigManager   ← Autoload，/root 的子节点
  ├── AgeSystem       ← Autoload，/root 的子节点
  └── ...             ← 都是兄弟关系，不是父子关系
```

**详细文档**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#28-autoload-单例间互访不能用-globalget_node--高)

---

## 8️⃣ GDScript 语言与工具踩坑 🆕

### §29 trait 是 GDScript 4.x 保留关键字

**问题**: 使用 `trait` 作为变量名会导致解析错误 "Expected loop variable name after 'for'"

**原因**: `trait` 在 GDScript 4.x 中是系统保留关键字（为未来特性预留）

**解决方案**: 使用 `trait_item`、`trait_data` 等替代命名

```gdscript
# ❌ 错误：trait 是保留关键字
for trait in initial_res.traits:
    session.traits.append(trait)

# ✅ 正确：使用替代命名
for trait_item in initial_res.traits:
    session.traits.append(trait_item)
```

**详细文档**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#29-trait-是-gdscript-4x-保留关键字--中)

### §30 GUT 测试框架 API 陷阱

**问题1**: `summary.get_test_count()` 不存在，运行时报 "Nonexistent function"
**问题2**: `var gut: Gut` 类型声明报错 '"Gut" is a variable but does not contain a type'
**问题3**: Lambda 回调方式验证信号不可靠，测试断言失败

**解决方案**:
```gdscript
# ❌ 错误：不存在的 API
var total_tests = summary.get_test_count()

# ✅ 正确：GUT v9.6.0+ 正确 API
var totals = gut.get_summary().get_totals(gut)
var total_tests: int = totals.tests
var passed_tests: int = totals.passing_tests
var failed_tests: int = totals.failing_tests

# ❌ 错误：Gut 作为类型
var gut: Gut  # "Gut" is a variable but does not contain a type

# ✅ 正确：使用 Object 类型
var gut: Object = load("res://addons/gut/gut.gd").new()

# ❌ 错误：Lambda 回调验证信号
var signal_received = false
battle_manager.home_health_changed.connect(func(_v): signal_received = true)
assert_true(signal_received)  # 不可靠

# ✅ 正确：使用 GUT 内置信号监控
watch_signals(battle_manager)
# 在此执行会触发信号的操作。
assert_signal_emitted(battle_manager, "home_health_changed")

# ✅ 正确：获取失败测试详情
func _print_failed_tests(gut: Object) -> void:
    var tc = gut.get_test_collector()
    for s in tc.scripts:
        for t in s.tests:
            if t.was_run and not t.is_passing():
                print("  - %s: %s" % [t.name, str(t.fail_texts)])
```

**详细文档**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#30-gut-测试框架-api-陷阱--中)

### §31 := 类型推断限制与 .godot 缓存问题

**问题1**: `:=` 类型推断在右侧类型不明确时报错 "Cannot infer the type of variable"
**问题2**: 恢复 class_name 后报 "hides a global script class" 缓存错误

**解决方案**:
```gdscript
# ❌ 错误：右侧类型不明确时使用 :=
var total_tests := summary.get_test_count()  # Cannot infer type

# ✅ 正确：显式类型声明
var total_tests: int = totals.tests

# 缓存问题解决方案：删除 .godot 目录后重新打开项目
# 项目根目录/.godot/ ← 删除此目录，Godot 会自动重建
```

**详细文档**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#31--类型推断限制与-godot-缓存问题--中)

---

## 9️⃣ GUT 测试框架踩坑 🆕

### §32 GUT 测试运行器模式导致框架挂起 🔴 高

[当前项目测试规范](../../outline/Godot%20编码规范汇总.md#131-gut-测试运行器模式--强制)

### §33 before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起 🔴 高

[当前项目测试规范](../../outline/Godot%20编码规范汇总.md#132-autoload-会话引用与重置)

### §34 watch_signals() 在 Autoload 实例上导致 GUT 挂起 🔴 高

[当前项目测试规范](../../outline/Godot%20编码规范汇总.md#133-autoload-信号测试)

### §35 测试中引用了不存在的类属性 🟡 中

[当前项目测试规范](../../outline/Godot%20编码规范汇总.md#134-测试前校验字段名--建议)

### §36 select_option() 第二个参数类型错误 🟡 中

**问题**: 调用 `EventSystem.select_option(event_data, 0)` 时传入 int 索引作为第二个参数，但实际签名要求 Dictionary 类型的 option 对象。

**根因**: `select_option(event: Dictionary, option: Dictionary)` 的第二个参数是完整的选项数据对象，不是选项索引。

**解决方案**: 传入实际的选项 Dictionary：

```gdscript
# ❌ 错误：传入 int 索引
EventSystem.select_option(event_data, 0)

# ✅ 正确：传入完整的选项 Dictionary
var option: Dictionary = {"option_id": "A", "text": "选项A"}
EventSystem.select_option(event_data, option)
```

**详细文档**: [GUT_Testing_Pitfalls.md](../../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md#36-select_option-第二个参数类型错误--中)

[当前项目选项结算](../../../scripts/logic/life_simulation/event_system.gd)

---

## 🔟 资源引用与数据一致性踩坑 🆕

### §37 .tres 文件 ext_resource 引用已删除文件导致整体加载失败 🔴 高

**问题**: 删除 `.tres` 资源文件后，其他 `.tres` 文件中的 `[ext_resource]` 仍引用已删除的文件路径，导致**整个 .tres 文件无法加载**

**根因**: Godot 的 `.tres` 文件加载是原子操作——所有 `[ext_resource]` 必须全部可解析，否则整个资源加载失败

**踩坑过程**:
1. 清理项目时批量删除了 14 个 `.tres` 文件
2. `map_01.tres` 中有 4 个 `[ext_resource]` 引用了已删除文件
3. 运行报错：`MapConfig: Failed to load resource from: res://resources/maps/map_01.tres`

**解决方案**:
```gdscript
# ✅ 删除 .tres 文件时，同步清理所有引用
# 1. 全局搜索被删除文件的路径
# 2. 从引用方 .tres 中移除对应的 [ext_resource] 行
# 3. 移除 [resource] 中使用该 id 的属性
# 4. 更新 load_steps 计数

# 预防：使用 .bak 后缀代替直接删除
# 重命名 heavy_armor.tres → heavy_armor.tres.bak
```

**详细文档**: [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md#37-tres-文件-ext_resource-引用已删除文件导致整体加载失败--高)

### §38 数据格式不一致导致条件判断永远失败 🟡 中

**问题**: `session.family_background` 存储完整 ID（`"family_farmer"`），而 `events.json` 条件使用短名（`"!farmer"`），比较永远不匹配

**根因**: 数据源（`family_backgrounds.json`）使用 `"family_farmer"` 格式，条件配置（`events.json`）使用 `"farmer"` 格式，两个配置文件的数据格式约定不一致

**错误修复方式**:
```gdscript
# ❌ 在每个消费者处提取短名
var session_bg_short: String = session.family_background.replace("family_", "")
if session_bg_short == "farmer":
```

**正确修复方式**:
```gdscript
# ✅ 在数据源统一格式
# era_system.gd
session.family_background = raw_family_id.replace("family_", "")
# 所有消费者直接比较
if session.family_background == "farmer":
```

**核心原则**: **数据格式应在源头统一，而非在每个消费者处转换**

**详细文档**: [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md#38-数据格式不一致导致条件判断永远失败--中)

### §39 修改数据格式时遗漏配置文件消费者 🟡 中

**问题：** 修改 `session` 字段格式后只更新了代码文件，遗漏了 `achievements.json` 中的硬编码值

**原因：** JSON 配置文件也是数据消费者，其中的硬编码值必须与代码中的数据格式保持一致

```jsonc
// ❌ 修改前：achievements.json 使用完整 ID
{
  "condition": {
    "type": "family_ending_combo",
    "family": "family_farmer"  // 与 session.family_background 不一致
  }
}

// ✅ 修改后：achievements.json 使用短名，与 session.family_background 一致
{
  "condition": {
    "type": "family_ending_combo",
    "family": "farmer"  // 与 session.family_background 一致
  }
}
```

**核心原则**：修改数据格式时，JSON 配置文件也是消费者，必须同步更新

**修改数据格式完整检查清单**:
```
- [ ] 全局搜索字段名（含 .gd / .json / .tres / .tscn）
- [ ] 逐一确认每个引用点的兼容性
- [ ] 更新代码中的比较逻辑
- [ ] 更新 JSON 配置中的硬编码值
- [ ] 更新默认值（如 session_data.gd 的 @export 默认值）
- [ ] 更新测试用例中的测试数据
- [ ] 运行场景验证
```

**详细文档**: [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md#39-修改数据格式时遗漏配置文件消费者--中)

---

## 1️⃣3️⃣ 游戏系统实战踩坑 🆕

### §40 Tooltip遮挡触发元素导致闪烁循环 🟡 中

**问题**: 词条悬停tooltip出现后立即消失，反复闪烁

**根因**: tooltip定位在badge上方，遮挡了badge，导致badge触发MOUSE_EXIT -> tooltip消失 -> 鼠标重新进入badge -> tooltip又出现 -> 循环闪烁

**解决方案**:
```gdscript
# ❌ 错误：tooltip遮挡触发元素
# tooltip 出现在 badge 上方，鼠标进入 tooltip 区域时 badge 触发 MOUSE_EXIT
# tooltip 消失 -> 鼠标重新进入 badge -> tooltip 又出现 -> 循环闪烁

# ✅ 正确：tooltip 及其所有子节点设置 mouse_filter = IGNORE
var tooltip: PanelContainer = PanelContainer.new()
tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
# 所有子节点也必须设置
for child in tooltip.get_children():
    if child is Control:
        child.mouse_filter = Control.MOUSE_FILTER_IGNORE
```

**规范**: 所有动态创建的悬浮UI组件，必须设置 `mouse_filter = MOUSE_FILTER_IGNORE`，避免遮挡触发元素

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#40-tooltip遮挡触发元素导致闪烁循环--中)

### §41 场景切换绕过导致UI不更新 🔴 高

**问题**: 战斗结算面板始终显示旧内容，修改result_ui.gd无效

**根因**: map_manager._show_battle_result()创建了简单面板并2.5秒后自动跳转State.STAGE，完全绕过了result_ui.gd的完整结算面板

**解决方案**:
```gdscript
# ❌ 错误：map_manager 中独立实现场景切换逻辑
func _show_battle_result():
    var panel = Panel.new()
    # ... 创建简单面板 ...
    await get_tree().create_timer(2.5).timeout
    GameState.change_state(State.STAGE)  # 绕过了 result_ui.gd！

# ✅ 正确：统一入口，让 result_ui.gd 处理完整结算
func _show_battle_result():
    GameState.change_state(State.RESULT)  # 由 result_ui.gd 处理完整结算
```

**规范**: 场景切换逻辑必须统一入口，避免多处独立实现相同功能导致绕过

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#41-场景切换绕过导致ui不更新--高)

### §42 分裂/召唤敌人未被计入存活数 🟡 中

**问题**: 多波怪同时在场时，战斗结算提前弹出

**根因**: 手动维护 `_enemies_alive` 计数器，但分裂/召唤的敌人没有增加计数，也没有连接died/reached_base信号

**解决方案**:
```gdscript
# ❌ 错误：手动维护计数器，分裂/召唤的敌人未计入
var _enemies_alive: int = 0

func _on_enemy_spawned():
    _enemies_alive += 1  # 分裂/召唤的敌人不会走这里

func _on_enemy_died():
    _enemies_alive -= 1
    if _enemies_alive <= 0:
        _on_wave_complete()  # 提前弹出结算！

# ✅ 正确：使用 group 动态查询存活敌人数量
func get_alive_enemy_count() -> int:
    return get_tree().get_nodes_in_group("enemies").size()

# ✅ 分裂/召唤的敌人自动加入 group 并连接信号
func _spawn_split_enemy(pos: Vector2):
    var enemy: CharacterBody2D = enemy_scene.instantiate()
    enemy.add_to_group("enemies")  # 自动计入
    enemy.died.connect(_on_enemy_died)
    enemy.reached_base.connect(_on_enemy_reached_base)
    enemy.global_position = pos
    add_child(enemy)
```

**规范**: 优先使用group动态查询而非手动维护计数器；动态创建的实体必须正确连接生命周期信号

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#42-分裂召唤敌人未被计入存活数--中)

### §43 字典中保留已释放节点引用导致freed instance报错 🔴 高

**问题**: `Trying to assign invalid previously freed instance` 报错

**根因**: 怪物技能摧毁防御塔后，built_towers字典中仍保留已queue_free()的塔引用；直接用 `var tower: Tower = dict[key]` 赋值时触发错误

**解决方案**:
```gdscript
# ❌ 错误：直接用 [] 访问字典，赋值时触发 freed instance 错误
var tower: Tower = built_towers[key]  # 如果 tower 已 freed，赋值报错！

# ✅ 正确方案 1：使用 .get() 获取引用，先检查 is_instance_valid() 再类型转换
var tower_ref = built_towers.get(key)
if is_instance_valid(tower_ref):
    var tower: Tower = tower_ref as Tower
    tower.do_something()

# ✅ 正确方案 2：塔被摧毁时同步从字典中移除引用
func _on_tower_destroyed(tower: Tower):
    var key: String = _get_tower_key(tower)
    built_towers.erase(key)

# ✅ 正确方案 3：hovered_tower 加 is_instance_valid() 保护
var hovered_tower_ref = hovered_tower
if is_instance_valid(hovered_tower_ref):
    hovered_tower_ref.show_info()
```

**规范**: 缓存节点引用的字典/数组，必须在节点释放时同步清理；访问前必须用 `is_instance_valid()` 检查；用 `.get()` 而非 `[]` 访问避免赋值时触发错误

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#43-字典中保留已释放节点引用导致freed-instance报错--高)

### §44 击退效果与路径移动冲突 🟡 中

**问题**: 敌人被击退后不按固定路径行动

**根因**: 击退效果直接修改global_position，但_process中同时计算路径移动，击退期间敌人同时被击退和沿路径移动

**解决方案**:
```gdscript
# ❌ 错误：击退和路径移动同时执行
func _process(delta: float):
    _move_along_path(delta)  # 路径移动
    # 击退效果也在修改 global_position，两者冲突！

func apply_knockback(direction: Vector2, force: float):
    # 直接修改 global_position，但 _process 还在移动
    global_position += direction * force

# ✅ 正确：击退期间跳过路径移动
var is_being_knocked_back: bool = false

func _process(delta: float):
    if is_being_knocked_back:
        return  # 击退期间跳过路径移动
    _move_along_path(delta)

func apply_knockback(direction: Vector2, force: float):
    is_being_knocked_back = true
    var tween: Tween = create_tween()
    tween.tween_property(self, "global_position", global_position + direction * force, 0.3)
    tween.tween_callback(func(): is_being_knocked_back = false)
```

**规范**: 位移效果（击退、拉拽等）与常规移动逻辑必须互斥，不能同时执行

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#44-击退效果与路径移动冲突--中)

### §45 事件/战斗奖励重复显示 🟡 中

**问题**: 战斗结算面板显示了事件选择时获得的词条和防御塔

**根因**: session.last_event_traits和last_event_towers记录了事件选择时的奖励，战斗结算面板读取了这些数据

**解决方案**:
```gdscript
# ❌ 错误：战斗结算面板读取事件奖励数据
func _show_battle_result():
    for trait in session.last_event_traits:  # 这是事件阶段的奖励！
        _add_trait_display(trait)
    for tower in session.last_event_towers:  # 这也是事件阶段的！
        _add_tower_display(tower)

# ✅ 正确：战斗结算只显示战斗获得的奖励
func _show_battle_result():
    var rewards: Dictionary = session.last_battle_rewards
    var gold: int = rewards.get("gold", 0)
    _add_gold_display(gold)
    var towers: Array = rewards.get("towers", [])
    for tower in towers:
        _add_tower_display(tower)
    # 不再读取 last_event_traits / last_event_towers
```

**规范**: 不同阶段的奖励数据必须分开存储和展示，避免跨阶段重复显示

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#45-事件战斗奖励重复显示--中)

### §46 词条效果字段名不一致 🟡 中

**问题**: tower_damage_bonus类词条显示"塔伤害+0"而非"塔伤害+15%"

**根因**: traits.json中tower_damage_bonus类型使用 `tower_damage_bonus` 字段名存储值（如0.15），而_format_effect只读取 `value` 字段

**解决方案**:
```gdscript
# ❌ 错误：假设所有效果都用 value 字段
func _format_effect(effect: Dictionary) -> String:
    var val: float = effect.get("value", 0)  # tower_damage_bonus 类型没有 value 字段！
    return "塔伤害+%.0f%%" % (val * 100)  # 显示 "塔伤害+0%"

# ✅ 正确：根据 effect type 读取对应字段
func _format_effect(effect: Dictionary) -> String:
    var effect_type: String = effect.get("type", "")
    # 优先读取类型特定字段，回退到 value
    var val: float = effect.get(effect_type, effect.get("value", 0))
    match effect_type:
        "tower_damage_bonus":
            return "塔伤害+%.0f%%" % (val * 100)
        "tower_attack_speed_bonus":
            return "攻速+%.0f%%" % (val * 100)
        _:
            return str(val)
```

**规范**: 效果格式化函数必须根据effect type读取对应字段，不能假设所有效果都用value字段

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#46-词条效果字段名不一致--中)

---

### §47 UI计数显示语义错误——"已放置/最大"vs"剩余可放/最大" 🟡 中

**问题**: 防御塔选择界面显示 "0/1"、"0/2"，用户认为没放塔时应该显示 "1/1"、"2/2"

**根因**: 计数逻辑本身正确，但显示格式用了 `placed/max`（已放置数/最大数），而用户期望的是 `remaining/max`（剩余可放数/最大数）

**解决方案**:
```gdscript
# ❌ 错误：显示"已放置/最大"
count_label.text = "%d/%d" % [tower_placed, tower_max]  # 0/1 → "0个可用"

# ✅ 正确：显示"剩余可放/最大"
var tower_remaining: int = tower_max - tower_placed
count_label.text = "%d/%d" % [tower_remaining, tower_max]  # 1/1 → "还能放1个"
```

**教训**: UI显示的数字语义必须与用户心智模型一致。"还可以放几个"比"已经放了几个"更有用

**详细文档**: [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#47-ui计数显示语义错误已放置最大vs剩余可放最大--中)

---

### §48 变量命名与GDScript内置标识符冲突 🟡 中

**问题**: Godot 控制台报 `SHADOWED_GLOBAL_IDENTIFIER` 警告，如 `var range`、`var color`、`var name`、`var size`、`var text`

**根因**: GDScript 有大量内置函数/类/常量（range、color、name、size、text等），局部变量同名会遮蔽全局标识符

**解决方案**:
```gdscript
# ❌ 错误：使用与GDScript内置标识符同名的变量
var range: float = 100.0       # 遮蔽内置函数 range()
var color: Color = Color.RED   # 遮蔽内置类 Color
var name: String = "tower"     # 遮蔽内置属性 name

# ✅ 正确：使用语义更明确的名称
var attack_range: float = 100.0
var fill_color: Color = Color.RED
var display_name: String = "tower"
```

**常见冲突标识符**: range, color, name, size, text, type, value, key, step, count, data, result, error, input, output, object, signal, method, function, class, load, string, position, scale, rotation

**教训**: 局部变量命名必须避免与GDScript内置标识符冲突，使用更具体的语义化名称

**详细文档**: [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#48-变量命名与gdscript内置标识符冲突--中)

---

### §49 已满的塔从UI消失而非变灰 🟡 中

**问题**: 数量限制的防御塔放满后从选择界面消失

**根因**: load_tower_configs() 中有 `if placed < max_count` 过滤，放满的塔不加入列表

**解决方案**:
```gdscript
# ❌ 错误：放满的塔从列表中移除
if placed < tower_config.max_count:
    _add_tower_button(tower_config)

# ✅ 正确：所有塔始终显示；已满的塔设置 button.disabled=true + modulate变灰
var button: Button = _add_tower_button(tower_config)
if placed >= tower_config.max_count:
    button.disabled = true
    button.modulate = Color(0.5, 0.5, 0.5, 1.0)
```

**教训**: UI中"不可用"的选项应该变灰禁用而非消失，保持用户对完整选项的认知

**详细文档**: [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#49-已满的塔从ui消失而非变灰--中)

---

### §50 调试误判——在正确的逻辑上反复修改 🟢 低

**问题**: 之前多次尝试用 get_nodes_in_group("towers") + get_meta("tower_id") 计数，但始终显示0，误以为是计数逻辑问题

**根因**: 实际根因是显示语义错误（§47），不是计数逻辑问题。但调试过程中发现 group + meta 方式本身是可行的

**解决方案**:
```gdscript
# ❌ 错误的调试方向：反复修改正确的计数逻辑
# 尝试1：换一种 group 查询方式
# 尝试2：换一种 meta 读取方式
# 尝试3：改用字典缓存计数
# ... 以上都是正确的逻辑，问题不在计数

# ✅ 正确的调试方向：先确认"正确行为"的定义
# 1. 问清楚"期望显示什么" → "1/1" 而非 "0/1"
# 2. 确认计数逻辑是否正确 → 放了0个塔，计数为0，逻辑正确
# 3. 确认显示格式是否正确 → "0/1" 表示"已放0个/总共1个"，但用户期望"剩余1个/总共1个"
# 4. 修改显示格式 → "剩余/最大"
```

**教训**: 调试bug时先确认"正确行为"的定义，避免在正确的逻辑上反复修改。先问清楚"期望显示什么"再动手

**详细文档**: [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#50-调试误判在正确的逻辑上反复修改--低)

---

## 1️⃣4️⃣ 场景树与Dictionary踩坑 🆕

### §51 节点被移出场景树后调用get_node_or_null报错 🔴 高

**问题**: `Can't use get_node() with absolute paths from outside the active scene tree`

**根因**: `select_option()`可能触发状态切换（如进入BATTLE），导致当前UI节点被移出场景树，后续的`get_node_or_null("/root/...")`调用报错

**解决方案**:
```gdscript
# ❌ 错误：场景切换调用后继续访问节点
func _on_option_pressed():
    EventSystem.select_option(event_data, option)  # 可能触发场景切换
    var node = get_node_or_null("/root/SomeNode")  # 报错！当前节点已不在场景树

# ✅ 正确：在可能触发场景切换的调用之后，加is_inside_tree()检查
func _on_option_pressed():
    EventSystem.select_option(event_data, option)
    if not is_inside_tree():
        return
    var node = get_node_or_null("/root/SomeNode")
```

**来源**: event_ui.gd _on_option_pressed()

**相关规范**: [Godot 编码规范汇总 - 16.2 可能触发场景切换的调用后必须检查is_inside_tree()](../../outline/Godot%20编码规范汇总.md#162-可能触发场景切换的调用后必须检查is_inside_tree--强制)

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#51-节点被移出场景树后调用get_node_or_null报错--高)

### §52 以freed对象为key的Dictionary遍历崩溃 🔴 高

**问题**: `Attempted to next an invalid (previously freed?) object instance into a 'TypedDictionary.Key'`

**根因**: `damage_dealers: Dictionary`以Tower对象为key，当Tower被释放后遍历该Dictionary时，GDScript内部类型验证失败

**解决方案**:
```gdscript
# ❌ 错误：以对象实例作为Dictionary的key
var damage_dealers: Dictionary = {}  # key = Tower对象
damage_dealers[tower] = 100.0
# Tower被释放后遍历 → 崩溃！

# ✅ 正确：用Array[Dictionary]存储，不以对象为key
var damage_dealers: Array[Dictionary] = []
damage_dealers.append({"tower": tower_ref, "damage": 100.0})

# ✅ 遍历时用is_instance_valid()过滤
for entry in damage_dealers:
    if is_instance_valid(entry["tower"]):
        var tower: Tower = entry["tower"] as Tower
        tower.do_something()
```

**来源**: enemy.gd distribute_experience()

**相关规范**: [Godot 编码规范汇总 - 16.3 不要以对象实例作为Dictionary的key](../../outline/Godot%20编码规范汇总.md#163-不要以对象实例作为dictionary的key--强制)

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#52-以freed对象为key的dictionary遍历崩溃--高)

---

## 1️⃣5️⃣ 路径系统踩坑 🆕

### §53 怪物路径偏移不能用侧向力实现 🟡 中

**问题**: 用`global_position += perpendicular * lateral_offset * delta`施加侧向力，怪物抖动/转圈，偏移不生效

**根因**: 侧向力与路径追踪的`global_position = target_pos`互相打架，每帧先移向目标点再被侧向力推开

**解决方案**:
```gdscript
# ❌ 错误：用侧向力实现路径偏移
func _process(delta: float):
    _move_along_path(delta)
    global_position += perpendicular * lateral_offset * delta  # 与路径移动冲突！

# ✅ 正确：在set_path()时一次性偏移所有路径点
func set_path(points: Array[Vector2]) -> void:
    path_points = points
    _apply_lateral_offset()  # 一次性偏移所有路径点

func _apply_lateral_offset() -> void:
    if lateral_offset == 0.0:
        return
    for i in range(path_points.size()):
        var direction: Vector2 = (path_points[i] - path_points[max(0, i - 1)]).normalized()
        var perpendicular: Vector2 = Vector2(-direction.y, direction.x)
        path_points[i] += perpendicular * lateral_offset
```

**来源**: enemy.gd set_path() / _apply_lateral_offset()

**相关规范**: [Godot 编码规范汇总 - 16.4 路径偏移必须一次性应用到所有路径点](../../outline/Godot%20编码规范汇总.md#164-路径偏移必须一次性应用到所有路径点--强制)

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#53-怪物路径偏移不能用侧向力实现--中)

### §54 分裂/召唤怪偏移需叠加父怪偏移 🟡 中

**问题**: 分裂/召唤怪的路径偏移只有自身随机偏移，没有继承父怪偏移，导致子怪路径与父怪不一致

**解决方案**:
```gdscript
# ❌ 错误：子怪偏移只有自身随机值
func _on_split_requested():
    child.lateral_offset = randf_range(-15.0, 15.0)

# ✅ 正确：子怪偏移 = 父怪偏移 + 自身随机偏移
func _on_split_requested():
    child.lateral_offset = lateral_offset + randf_range(-15.0, 15.0)

func _on_summon_requested():
    child.lateral_offset = lateral_offset + randf_range(-15.0, 15.0)
```

**来源**: enemy.gd _on_split_requested() / _on_summon_requested()

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#54-分裂召唤怪偏移需叠加父怪偏移--中)

### §55 怪出生时current_path_index应从1开始 🟡 中

**问题**: 怪出生在path_points[0]附近，但current_path_index=0，怪先走向path_points[0]（出生点本身）形成斜线

**解决方案**:
```gdscript
# ❌ 错误：从索引0开始，怪先走向出生点
enemy.current_path_index = 0  # 怪走向path_points[0]（出生点本身）

# ✅ 正确：从索引1开始，跳过出生点
enemy.current_path_index = 1  # 怪直接走向第二个转弯点
```

**来源**: map_manager.gd _on_enemy_spawn_requested()

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#55-怪出生时current_path_index应从1开始--中)

### §56 实际生成路径可能与预期不同 🟡 中

**问题**: 修改了enemy_spawner.gd的生成逻辑但没效果

**根因**: 游戏实际使用的是tower_defense/wave_manager.gd -> enemy_spawn_requested信号 -> map_manager._on_enemy_spawn_requested()，而enemy_spawner.gd根本没被调用

**解决方案**:
```gdscript
# ❌ 错误：假设某个文件/函数是被调用的入口
# 修改了 enemy_spawner.gd 但实际调用路径不经过它

# ✅ 正确：修改代码前必须用Grep搜索确认实际的调用路径
# 搜索 "enemy_spawn_requested" 信号的所有emit和connect
# 确认实际执行路径：wave_manager.gd -> map_manager.gd
```

**教训**: 修改代码前必须用Grep搜索确认实际的调用路径，不要假设

**来源**: map_manager.gd vs enemy_spawner.gd

**相关规范**: [Godot 编码规范汇总 - 16.1 修改代码前必须确认实际调用路径](../../outline/Godot%20编码规范汇总.md#161-修改代码前必须确认实际调用路径--强制)

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#56-实际生成路径可能与预期不同--中)

---

## 1️⃣6️⃣ Dictionary判断与终局逻辑踩坑 🆕

### §57 Dictionary.has()对null值返回true 🟡 中

**问题**: `option.has("battle_trigger")`当`battle_trigger: null`时返回true（key存在），导致逻辑分支错误

**根因**: `has()`检查的是key是否存在，而非value是否有效。key存在但value为null时，`has()`仍返回true

**解决方案**:
```gdscript
# ❌ 错误：用has()判断，null值时仍返回true
if option.has("battle_trigger"):  # battle_trigger: null 时也返回true！
    _enter_battle()  # 误触发战斗

# ✅ 正确：用.get() + 类型检查，类型安全且不受null值影响
if option.get("battle_trigger") is Dictionary:
    _enter_battle()  # 只在battle_trigger是Dictionary时触发
```

**来源**: event_ui.gd display_event() / _show_consequence_popup()

**相关规范**: [Godot 编码规范汇总 - 16.5 Dictionary值判断用.get()而非.has()](../../outline/Godot%20编码规范汇总.md#165-dictionary值判断用get而非has--建议)

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#57-dictionaryhas对null值返回true--中)

### §58 老年阶段不应无条件触发终局 🔴 高

**原始案例**：进入老年阶段后，结算界面只显示“查看结局”。当时的结算 UI 把 `old_age` 当成终局判据，战斗结算额外增加年龄，事件选项也在每次结算时重复应用老年健康扣减。

**当前项目**：老年阶段可以继续。结算页的继续操作与地图的战斗结算读取 `session.attributes` 中的生命值，耗尽时进入终局。`EventSystem.select_option()` 在年龄实际增长后应用阶段属性变化，并在选项未触发战斗时处理显式的 `triggers_ending`。核对这类问题时分别追踪终局、年龄推进和老年扣减的调用入口。

**代码依据** · [结算界面](../../../scripts/ui/result_ui.gd) · [地图战斗结算](../../../scripts/managers/map_manager.gd) · [事件结算](../../../scripts/logic/life_simulation/event_system.gd)

**查证资料** · [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#58-老年阶段不应无条件触发终局--高)

---

## 1️⃣7️⃣ 暴击/Debuff/翻译键/状态机/粒子材质踩坑 🆕

### §81 暴击特效不应作为额外伤害实例 🔴 高

**问题：** 1次攻击出现2-3个伤害数字，总伤害=base*(1+multiplier)而非base*multiplier

**原因：** CRIT特效在effect_system._apply_crit中调用take_damage造成额外伤害，而弹道命中也造成基础伤害

**解决方案：**
```gdscript
# ✅ 暴击作为伤害倍率，在攻击流程中判定
func _on_projectile_hit(target: Node2D) -> void:
    var final_damage: float = base_damage
    var is_crit: bool = _check_crit()
    if is_crit:
        final_damage *= crit_multiplier
    target.take_damage(final_damage, is_crit)

# effect_system.gd - execute_effects跳过CRIT类型
func execute_effects(effects: Array, source: Node2D, target: Node2D) -> void:
    for effect in effects:
        match effect.get("type", ""):
            "CRIT":
                continue  # 跳过CRIT
            "SLOW":
                _apply_slow(target, effect)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#81-暴击特效不应作为额外伤害实例--高)

### §82 debuff_amount设置但未使用导致效果不生效 🟡 中

**问题：** 历史塔的"削弱敌人属性"完全无效

**原因：** apply_debuff设置了debuff_amount，但take_damage中从未读取该值

**解决方案：**
```gdscript
# ✅ 在take_damage中将debuff_amount加入抗性计算
func take_damage(amount: float, is_crit: bool = false) -> void:
    var resistance: float = maxf(0.0, resistance - armor_break_amount - debuff_amount)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#82-debuff_amount设置但未使用导致效果不生效--中)

### §83 翻译键不匹配导致格式化报错 🔴 高

**问题：** `String formatting error: not all arguments converted`

**原因：** 代码使用`tr("ENEMY_DEBUFFED")`，但CSV中只有`ENEMY_DEBUFF`，tr()返回键名本身，格式化失败

**解决方案：**
```gdscript
# ✅ 确保代码中的翻译键与CSV中完全一致
var text: String = tr("ENEMY_DEBUFF") % [slow_amount, slow_timer]
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#83-翻译键不匹配导致格式化报错--高)

### §84 终局状态机被UI回调覆盖 🔴 高

**问题：** 健康归零后应进入ENDING状态，但被event_ui.gd的选项回调覆盖回STAGE

**原因：** 回调中不检查当前状态就强制切换到STAGE

**解决方案：**
```gdscript
# ✅ 回调中先检查当前状态
func _on_option_selected(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)
    if GameState.current_state == GameState.State.ENDING:
        return  # 终局状态已被设置，不覆盖
    GameState.change_state(State.STAGE)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#84-终局状态机被ui回调覆盖--高)

### §85 ParticleProcessMaterial.color_ramp类型限制 🟡 中

**问题：** 将Gradient对象直接赋值给color_ramp属性报错

**原因：** `color_ramp`需要`Texture2D`类型，不能直接赋值`Gradient`对象

**解决方案：**
```gdscript
# ✅ 用GradientTexture1D包装
var gradient_tex: GradientTexture1D = GradientTexture1D.new()
gradient_tex.gradient = gradient
process_mat.color_ramp = gradient_tex

# ✅ 纯色粒子直接用color属性
process_mat.color = Color(1.0, 0.3, 0.3)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#85-particleprocessmaterialcolor_ramp类型限制--中)

---

## 🔍 批量检查技巧

### 搜索整数除法
```bash
# 搜索除以 2 但没有小数点的情况
grep -rn "/ 2[^.0]" --include="*.gd" .
```

### 搜索变量遮蔽
```bash
# 搜索与成员变量同名的参数
grep -rn "func.*target:" --include="*.gd" .
```

### 搜索枚举使用
```bash
# 搜索硬编码的枚举值
grep -rn "emission_shape = [0-9]" --include="*.gd" .
```

---

## 📚 相关资源

### Base 层资料来源
- [19_Pitfall_Records.md](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md) - 完整踩坑记录
- [GDScript_Warning_Best_Practices.md](../../base/practical-experiences/pitfall-cases/GDScript_Warning_Best_Practices.md) - 警告处理最佳实践
- [Godot_4x_Resource_File_Comment_Issue.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md) - 资源文件注释问题
- [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md) - Autoload 单例踩坑 🆕
- [GUT_Testing_Pitfalls.md](../../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md) - GUT 测试框架踩坑 🆕
- [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md) - 资源引用与数据一致性踩坑 🆕
- [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md) - 游戏系统实战踩坑 🆕

### Wiki 层相关页面
- [GDScript 代码规范](../concepts/gdscript-standards.md)
- [性能优化实战](./performance-optimization-guide.md)

---

**最后更新**: 2026-11-27  
**维护者**: Knowledge Base Administrator  
**来源**: tower_defense 项目实战经验
