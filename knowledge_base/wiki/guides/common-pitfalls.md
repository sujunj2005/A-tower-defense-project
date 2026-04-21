# 常见踩坑避雷指南

> **适用版本**: Godot 4.x（4.6+）  
> **来源**: [Base 层 - 19_Pitfall_Records.md](../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md), [Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md), [GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md), [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md), [Godot_4x_Game_System_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md)  
> **重要性**: 🔴 必读 - 63 个常见陷阱及解决方案

---

## 📋 简介

本文档汇总了 Godot 4.x 开发中最容易遇到的 63 个陷阱，按类别分类并提供解决方案。所有踩坑记录均来自实战经验，帮助你避免重复踩坑。

---

## 🎯 快速查找

### 按问题查找

| 问题描述 | 章节 | 解决方案 |
|----------|------|----------|
| "除法结果不对" | §1 | 使用 `/ 2.0` 替代 `/ 2` |
| "场景切换崩溃" | §7 | 使用 `call_deferred` |
| "碰撞检测失效" | §13 | 调整 shape.size，不要修改 scale |
| "纹理不显示" | §23 | 移除 .tres 文件中的注释 |
| "配置值加载错误" | §23 | 移除 .tres 文件中的注释 |
| "TileMap 边框不对齐" | §24 | 使用 `MODEL_MATRIX * VERTEX` 计算世界坐标 |
| "Autoload class_name 冲突" | §27 | 移除 Autoload 脚本的 class_name |
| "Autoload 互访问报错" | §28 | 直接使用 Autoload 注册名称访问 |
| "trait 保留关键字报错" | §29 | 使用 trait_item 等替代命名 |
| "GUT 测试 API 不存在" | §30 | 使用 GUT v9.6.0+ 正确 API |
| ":= 类型推断失败" | §31 | 显式类型声明，删除 .godot 缓存 |
| "面板无法显示/状态不一致" | §26 | 包装属性时设置底层属性，不创建双重状态 |
| "GUT 测试运行器挂起" | §32 | 使用 GutConfig + run_tests() 模式 |
| "Autoload 引用替换挂起" | §33 | 不替换 Autoload 引用对象本身 |
| "watch_signals Autoload 挂起" | §34 | 禁止对 Autoload 使用 watch_signals |
| "测试引用不存在属性" | §35 | 编写测试前先读取被测类源码 |
| "select_option 参数类型错误" | §36 | 传入完整选项 Dictionary |
| ".tres 引用已删除文件加载失败" | §37 | 删除 .tres 前全局搜索并清理 ext_resource 引用 |
| "条件判断永远不匹配" | §38 | 数据格式在源头统一，消费者不做运行时转换 |
| "修改数据格式后成就失效" | §39 | 同步更新 JSON 配置文件中的硬编码值 |
| "Tooltip遮挡闪烁" | §40 | 设置 mouse_filter = IGNORE |
| "场景切换绕过UI不更新" | §41 | 统一场景切换入口 |
| "分裂敌人未计入存活数" | §42 | 使用 group 动态查询 |
| "freed instance报错" | §43 | is_instance_valid + 同步清理 |
| "击退与路径移动冲突" | §44 | 位移效果与常规移动互斥 |
| "奖励重复显示" | §45 | 分阶段存储奖励数据 |
| "效果字段名不一致" | §46 | 按 effect type 读取对应字段 |
| "节点移出场景树后get_node_or_null报错" | §51 | 场景切换调用后检查is_inside_tree() |
| "以freed对象为key的Dictionary遍历崩溃" | §52 | 用Array[Dictionary]替代对象key |
| "路径偏移不能用侧向力实现" | §53 | set_path时一次性偏移所有路径点 |
| "分裂/召唤怪偏移需叠加父怪偏移" | §54 | 子怪偏移=父怪偏移+自身随机偏移 |
| "怪出生时current_path_index应从1开始" | §55 | current_path_index=1，跳过出生点 |
| "实际生成路径可能与预期不同" | §56 | 修改前用Grep确认实际调用路径 |
| "Dictionary.has()对null值返回true" | §57 | 用.get() is ExpectedType判断 |
| "老年阶段不应无条件触发终局" | §58 | 终局只在health<=0或用户选择时触发 |
| "暴击特效额外伤害实例" | §81 | 暴击=伤害倍率，非额外take_damage |
| "debuff设置了但不生效" | §82 | take_damage中必须读取debuff_amount |
| "翻译键不匹配格式化报错" | §83 | tr()键名与CSV完全一致 |
| "终局状态机被UI回调覆盖" | §84 | 回调中检查当前状态再切换 |
| "ParticleProcessMaterial.color_ramp类型" | §85 | 用GradientTexture1D包装Gradient |

---

## 1️⃣ GDScript 踩坑

### §1 整数除法

**问题：** 两个整数相除会丢弃小数部分

```gdscript
var a = 5 / 2      # 结果为 2，不是 2.5！❌
var b = 5.0 / 2    # 结果为 2.5 ✅
```

**解决方案：**
```gdscript
# ✅ 使用浮点数除数
var half_size = tile_size / 2.0
var center_x = viewport_size.x / 2.0

# ✅ 或显式转换
var half_size = float(tile_size) / 2
```

**常见场景：**
- 计算中心点：`position + size / 2.0`
- 计算一半距离：`distance / 2.0`
- 向量计算：`Vector2(size / 2.0, size / 2.0)`

### §2 Lambda 变量捕获

**问题：** Lambda 按值捕获，之后修改不影响

```gdscript
var x = 42
var lambda = func (): print(x)  # 按值捕获
x = "Hello"
lambda.call()  # 输出 42，不是 "Hello" ❌
```

### §3 类型数组赋值

**问题：** 类型数组不能直接赋值

```gdscript
var a: Array[Node2D] = [Node2D.new()]
var b: Array[Node] = []
b = a  # 错误！类型不兼容 ❌
b.assign(a)  # 正确 ✅
```

### §4 @export 在 _init() 中读取

**问题：** @export 的值在 _ready() 时才被赋值

```gdscript
@export var health: int = 100

func _init():
    print(health)  # 返回默认值 100，不是检查器设置的值 ❌

func _ready():
    print(health)  # 正确返回检查器值 ✅
```

### §5 静态变量与 @export/@onready

**问题：** 静态变量不能使用这些装饰器

```gdscript
static var my_var: int  # 错误！不能用于静态变量 ❌
@export var my_var: int   # 正确 ✅
@onready var my_var       # 正确 ✅
```

---

## 2️⃣ 节点系统踩坑

### §6 queue_free vs free

**问题：** free() 立即删除，queue_free() 延迟删除

```gdscript
node.free()    # 立即删除！后续引用会崩溃 ❌
node.queue_free()  # 延迟到帧末删除 ✅
```

### §7 场景切换时删除当前场景

**问题：** 在信号回调中直接删除当前场景会崩溃

```gdscript
# ❌ 错误：在信号回调中直接删除
get_tree().change_scene_to_file("res://scene2.tscn")  # 可能崩溃

# ✅ 正确：使用 call_deferred 延迟执行
get_tree().change_scene_to_file.call_deferred("res://scene2.tscn")
```

### §8 add_child 后 _ready() 未调用

**问题：** 需要手动初始化

```gdscript
var enemy = scene.instantiate()
add_child(enemy)
enemy.setup()  # _ready() 还未调用，需要手动初始化 ❌
```

### §9 循环引用 preload

**问题：** 两个脚本互相 preload 会报错

```gdscript
# a.gd
var b_scene = preload("res://b.tscn")
# b.gd 如果 preload("res://a.tscn") → 循环引用错误 ❌

# 解决方案：使用 load() 或 Autoload
```

### §10 get_node 使用节点名称而非类型

**问题：** 节点重命名后需要更新代码

```gdscript
$Sprite2D  # 通过名称获取
# 节点重命名后需要更新代码！❌

# ✅ 推荐：使用类型或路径
get_node("EnemyContainer/Enemy") as Enemy
```

---

## 3️⃣ 物理系统踩坑

### §11 move_and_slide 已包含 delta

**问题：** move_and_slide 不需要乘 delta

```gdscript
velocity.y += gravity * delta  # 加速度需要乘 delta ✅
move_and_slide(velocity * delta)  # ❌ 不需要乘 delta！
move_and_slide()  # ✅ 正确
```

### §12 RigidBody 直接设置位置

**问题：** 会破坏物理模拟

```gdscript
extends RigidBody3D
func _process(delta):
    position += velocity * delta  # ❌ 会破坏物理模拟！

# ✅ 正确方式：使用 _integrate_forces
func _integrate_forces(state):
    state.linear_velocity = velocity
```

### §13 CollisionShape Scale 必须保持 (1,1)

**问题：** scale 不影响碰撞体

```gdscript
$CollisionShape2D.scale = Vector2(2, 2)  # ❌ 无效！
# 应该调整 shape 属性的 size/extent
$CollisionShape2D.shape.size = Vector2(64, 64)  # ✅
```

### §14 物理代码必须在 _physics_process

**问题：** _process 时间步长不稳定

```gdscript
func _process(delta):        # ❌ 不稳定
    move_and_slide()

func _physics_process(delta):  # ✅ 固定时间步长
    move_and_slide()
```

### §15 is_on_floor() 只在 move_and_slide 后有效

**问题：** move_and_collide 不会更新状态

```gdscript
move_and_collide(velocity * delta)  # ❌ 不会更新 is_on_floor()
move_and_slide()                   # ✅ 会更新状态
```

---

## 4️⃣ UI 系统踩坑

### §16 Control.mouse_filter

**问题：** 需要设置正确的鼠标过滤

```gdscript
mouse_filter = Control.MOUSE_FILTER_IGNORE  # 点击穿透 ✅
mouse_filter = Control.MOUSE_FILTER_STOP     # 拦截点击 ✅
```

### §17 容器内子节点位置被覆盖

**问题：** Container 会重置子节点位置

```gdscript
# Container 内的子节点 position 会被容器重置
# 不要在 _process 中修改 Container 子节点的 position ❌
```

### §18 锚点预设后手动偏移

**问题：** 需要手动调整偏移

```gdscript
anchors_preset = Control.PRESET_CENTER
offset_left = -size.x / 2  # 需要手动调整偏移使控件居中
```

---

## 5️⃣ 渲染系统踩坑

### §19 screen_get_scale 平台限制

**问题：** 仅部分平台实现

```gdscript
screen_get_scale()  # 仅 Android、iOS、Linux(Wayland)、macOS、Web 实现
# Windows 上可能返回 1.0 ❌
```

### §20 Vector2/Vector3 内部使用 float32

**问题：** GPU 内部是 float32，可能有精度损失

```gdscript
var v: Vector2 = Vector2(1.0, 2.0)  # GDScript 是 float64
# 但 GPU 内部是 float32，可能有精度损失 ⚠️
```

### §21 3D 旋转避免欧拉角

**问题：** 可能万向节死锁

```gdscript
rotation_degrees = Vector3(0, 90, 0)  # 可能万向节死锁 ❌
quaternion = Quaternion.from_euler(...)   # ✅ 更安全
basis = Basis.from_euler(...)            # ✅ 更安全
```

### §22 Transform2D 乘法顺序

**问题：** 矩阵乘法不满足交换律

```gdscript
var t = parent_transform * child_transform  # 子的世界变换 ✅
# A * B ≠ B * A！矩阵乘法不满足交换律
```

---

## 6️⃣ 资源系统踩坑 🆕

### §23 .tres 文件中的注释导致字段加载失败

**问题：** 行内注释导致字段值无法正确加载

**错误示例：**
```tres
# ❌ 错误：注释导致字段加载失败
gold_drop = 20  # 高价值目标
experience_drop = 50  # 高经验奖励
texture_path = "res://images/enemies/marble_0_0.png"  # 纹理路径
```

**正确示例：**
```tres
# ✅ 正确：移除所有行内注释
gold_drop = 20
experience_drop = 50
texture_path = "res://images/enemies/marble_0_0.png"
```

**影响：**
- `texture_path` 变为空字符串 → 怪物纹理不显示
- `experience_drop` 变为默认值 5 → 经验值异常低
- `gold_drop` 可能正确加载（取决于默认值）

**解决方案：**
1. 移除所有 .tres 文件中的行内注释
2. 重新保存资源文件（在 Godot 编辑器中）
3. 重启 Godot 编辑器清除缓存

### §24 TileMap Shader 边框对齐问题

**问题：** TileMap 使用 shader 时边框对齐异常

**解决方案：** 使用 `MODEL_MATRIX * VERTEX` 计算世界坐标

详细说明：[TileMap Shader 边框问题](../base/practical-experiences/pitfall-cases/20_TileMap_Shader_Border_Pitfall.md)

### §25 窗口尺寸检测问题 🆕

**问题：** Godot 4.x 中窗口尺寸检测可能不准确

**表现：**
- 启动时窗口尺寸与项目设置不符
- 全屏模式下尺寸检测失效
- 多显示器环境尺寸错误

**解决方案：**
```gdscript
# ✅ 延迟获取窗口尺寸
func _ready():
    await get_tree().process_frame
    var window_size = DisplayServer.window_get_size()

# ✅ 使用视口尺寸
func get_actual_size() -> Vector2i:
    return get_viewport().get_visible_rect().size
```

详细说明：[窗口尺寸检测问题](../base/practical-experiences/pitfall-cases/Godot_4x_Window_Size_Detection_Issue.md)

### §26 内嵌 get/set 创建双重状态 🔴 高

**问题：** 包装属性时错误地创建了独立状态，导致状态不一致

```gdscript
# ❌ 错误：包装 Control 的 visible 属性时创建了两个独立状态
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if is_panel_visible != value:  # ❌ 检查自身（应该检查 visible）
            is_panel_visible = value    # ❌ 自赋值（冗余）
            visible = value             # ❌ 同步另一个属性
    get:
        return is_panel_visible  # ❌ 返回自身（应该返回 visible）

func _complete_tower_building():
    tower_select_ui.visible = false  # ❌ 直接设置 visible，is_panel_visible 仍为 true

func show_at_position(pos: Vector2):
    is_panel_visible = true  # ❌ setter 检查发现已是 true，不执行 visible = true
    # 结果：面板无法显示，点击塔位无反应！
```

**解决方案：**
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
```

**核心要点**：
- **独立状态**：无底层属性 → setter 自赋值，getter 返回自身（如 `is_locked`, `hovered_tower`）
- **包装属性**：有底层属性 → setter 设置底层属性，getter 返回底层属性（如 `is_panel_visible` 包装 `visible`）
- **避免直接访问**：始终通过包装属性访问，不要直接修改底层属性

详细说明：[GDScript_Setter_Getter_Dual_State_Pitfall.md](../base/practical-experiences/pitfall-cases/GDScript_Setter_Getter_Dual_State_Pitfall.md)、[GDScript_Code_Standards.md](../base/practical-experiences/code-standards/GDScript_Code_Standards.md#34-内嵌-getset-使用场景与常见错误)

---

## 7️⃣ Autoload 单例踩坑 🆕

### §27 Autoload 脚本禁止 class_name 声明

**问题：** Autoload 脚本添加 `class_name` 会导致 "Class 'XXX' hides an autoload singleton" 编译错误

**原因：** Autoload 注册名本身就是全局标识符，再声明 class_name 会产生命名冲突

```gdscript
# ❌ 错误：Autoload 脚本中声明 class_name
class_name Global  # 报错：Class "Global" hides an autoload singleton
extends Node

# ✅ 正确：Autoload 脚本不声明 class_name
extends Node
# "Global" 已通过 Autoload 注册成为全局标识符
```

详细说明：[Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#27-autoload-脚本禁止-class_name-声明-🔴-高)

### §28 Autoload 单例间互访不能用 Global.get_node()

**问题：** 使用 `Global.get_node("ConfigManager")` 访问其他 Autoload 单例会报 "Node not found" 错误

**原因：** 所有 Autoload 都挂载在 `/root/` 下，互为兄弟节点，不是 Global 的子节点

```gdscript
# ❌ 错误：通过 Global.get_node() 访问兄弟 Autoload
config_manager = Global.get_node("ConfigManager")  # Node not found!

# ✅ 正确：直接使用 Autoload 全局名称
config_manager = ConfigManager  # Autoload 名称即全局变量
```

详细说明：[Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#28-autoload-单例间互访不能用-globalget_node-🔴-高)

---

## 8️⃣ GDScript 语言与工具踩坑 🆕

### §29 trait 是 GDScript 4.x 保留关键字

**问题：** 使用 `trait` 作为变量名会导致解析错误 "Expected loop variable name after 'for'"

**原因：** `trait` 在 GDScript 4.x 中是系统保留关键字（为未来特性预留）

```gdscript
# ❌ 错误：trait 是保留关键字
for trait in initial_res.traits:
    session.traits.append(trait)

# ✅ 正确：使用替代命名
for trait_item in initial_res.traits:
    session.traits.append(trait_item)
```

详细说明：[Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#29-trait-是-gdscript-4x-保留关键字-🟡-中)

### §30 GUT 测试框架 API 陷阱

**问题1：** `summary.get_test_count()` 不存在，运行时报 "Nonexistent function"
**问题2：** `var gut: Gut` 类型声明报错 '"Gut" is a variable but does not contain a type'
**问题3：** Lambda 回调方式验证信号不可靠

```gdscript
# ✅ 正确：GUT v9.6.0+ API
var totals = gut.get_summary().get_totals(gut)
var total_tests: int = totals.tests

# ✅ 正确：使用 Object 类型
var gut: Object = load("res://addons/gut/gut.gd").new()

# ✅ 正确：使用 GUT 内置信号监控
watch_signals(battle_manager)
assert_signal_emitted(battle_manager, "home_health_changed")
```

详细说明：[Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#30-gut-测试框架-api-陷阱-🟡-中)

### §31 := 类型推断限制与 .godot 缓存问题

**问题1：** `:=` 类型推断在右侧类型不明确时报错 "Cannot infer the type of variable"
**问题2：** 恢复 class_name 后报 "hides a global script class" 缓存错误

```gdscript
# ❌ 错误：右侧类型不明确时使用 :=
var total_tests := summary.get_test_count()  # Cannot infer type

# ✅ 正确：显式类型声明
var total_tests: int = totals.tests

# 缓存问题：删除 .godot 目录后重新打开项目
```

详细说明：[Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md#31-类型推断限制与-godot-缓存问题-🟡-中)

---

## 9️⃣ GUT 测试框架踩坑 🆕

### §32 GUT 测试运行器模式导致框架挂起 🔴 高

**问题：** 使用 `gut.add_script()` + `gut.test_scripts()` 模式运行测试时，框架在 `gut.gd:818 _test_the_scripts` 处无限挂起

**解决方案：** 必须使用 `GutConfig` + `run_tests()` 模式

```gdscript
# ❌ 错误：使用 add_script + test_scripts 模式
var gut = load("res://addons/gut/gut.gd").new()
add_child(gut)
gut.add_script("res://tests/unit/test_xxx.gd")
gut.test_scripts()  # 会导致框架挂起！

# ✅ 正确：使用 GutConfig + run_tests 模式
var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

func _ready() -> void:
    var gut = Gut.new()
    add_child(gut)
    var gut_config = GutConfig.new()
    gut_config._load_options_from_config_file("res://.gutconfig_xxx.json", gut_config.options)
    gut_config._apply_options(gut_config.options, gut)
    gut.run_tests()  # 关键：用 run_tests() 而非 test_scripts()
```

详细说明：[GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md#32-gut-测试运行器模式导致框架挂起-🔴-高)

### §33 before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起 🔴 高

**问题：** 在 `before_each()` 中替换 `Global.game_session` 为新实例会导致 GUT 挂起

**解决方案：** 不替换 Autoload 引用对象本身，改为直接操作 Autoload 持有的引用字段

```gdscript
# ❌ 错误：替换 Autoload 引用的对象本身
func before_each() -> void:
    Global.game_session = GameSessionData.new()  # 导致 GUT 挂起！

# ✅ 正确：直接操作 Autoload 持有的引用字段
func test_something() -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    # ... 执行测试 ...
    session.gold = old_gold  # 恢复
```

详细说明：[GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md#33-before_eachafter_each-修改-autoload-全局引用导致-gut-挂起-🔴-高)

### §34 watch_signals() 在 Autoload 实例上导致 GUT 挂起 🔴 高

**问题：** 对 Autoload 单例调用 `watch_signals()` 会导致测试框架无限挂起

**解决方案：** 避免对 Autoload 使用 `watch_signals()`，改用基于状态的断言

```gdscript
# ❌ 错误：对 Autoload 使用 watch_signals
watch_signals(EventSystem)  # 导致 GUT 挂起！

# ✅ 正确：基于状态的断言
var session: GameSessionData = EventSystem.session
var old_gold: int = session.gold
EventSystem.select_option(event_data, gold_option)
assert_gt(session.gold, old_gold, "选择金币选项后金币应增加")
```

详细说明：[GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md#34-watch_signals-在-autoload-实例上导致-gut-挂起-🔴-高)

### §35 测试中引用了不存在的类属性 🟡 中

**问题：** 测试中使用了 `session.owned_towers` 等不存在的字段名

**解决方案：** 编写测试前必须先读取被测类源码，确认属性名和方法签名

```gdscript
# ❌ 错误：凭记忆假设字段名
assert_eq(session.owned_towers.size(), 0)  # owned_towers 不存在！

# ✅ 正确：先确认类定义再编写测试
assert_eq(session.towers.size(), 0, "初始塔列表应为空")
```

详细说明：[GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md#35-测试中引用了不存在的类属性-🟡-中)

### §36 select_option() 第二个参数类型错误 🟡 中

**问题：** 传入 int 索引而非 Dictionary 类型的 option 对象

**解决方案：** 传入完整的选项 Dictionary

```gdscript
# ❌ 错误：传入 int 索引
EventSystem.select_option(event_data, 0)

# ✅ 正确：传入完整的选项 Dictionary
var option: Dictionary = {"option_id": "A", "text": "选项A"}
EventSystem.select_option(event_data, option)
```

详细说明：[GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md#36-select_option-第二个参数类型错误-🟡-中)

---

## 🔟 资源引用与数据一致性踩坑 🆕

### §37 .tres 文件 ext_resource 引用已删除文件导致整体加载失败 🔴 高

**问题：** 删除 `.tres` 资源文件后，其他 `.tres` 文件中的 `[ext_resource]` 仍引用已删除文件，导致整个 `.tres` 无法加载

**原因：** Godot 的 `.tres` 文件加载是原子操作——任何一个 `ext_resource` 找不到就整体失败，而非仅跳过缺失资源

```gdscript
# ❌ 错误：删除 .tres 后不清理引用
# 删除了 res://resources/enemies/heavy_armor.tres
# 但 map_01.tres 中仍有：
# [ext_resource id="3" type="Resource" path="res://resources/enemies/heavy_armor.tres"]
# → map_01.tres 整体加载失败！

# ✅ 正确：删除前全局搜索引用，同步清理
# 1. 搜索被删文件路径
# 2. 移除引用方 .tres 中的 [ext_resource] 行
# 3. 移除 [resource] 中使用该 id 的属性
# 4. 更新 load_steps 计数
```

详细说明：[Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md#37-tres-文件-ext_resource-引用已删除文件导致整体加载失败-🔴-高)

### §38 数据格式不一致导致条件判断永远失败 🟡 中

**问题：** `session.family_background` 存完整 ID（`"family_farmer"`），条件配置用短名（`"farmer"`），比较永远不匹配

**原因：** 数据源使用完整 ID 格式，条件配置使用短名格式，两个配置文件的数据格式约定不一致

```gdscript
# ❌ 错误：在每个消费者处提取短名（运行时转换）
var session_bg_short: String = session.family_background.replace("family_", "")
if session_bg_short == "farmer":  # 每个消费者都要做转换

# ✅ 正确：在数据源统一格式，消费者直接使用
# era_system.gd（数据入口）
session.family_background = raw_family_id.replace("family_", "")
# 所有消费者直接比较
if session.family_background == "farmer":
```

**核心原则**：数据格式应在源头统一，而非在每个消费者处转换

详细说明：[Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md#38-数据格式不一致导致条件判断永远失败-🟡-中)

### §39 修改数据格式时遗漏配置文件消费者 🟡 中

**问题：** 修改 `session` 字段格式后只更新了代码文件，遗漏了 `achievements.json` 中的硬编码值

**原因：** JSON 配置文件也是数据消费者，其中的硬编码值必须与代码中的数据格式保持一致

```json
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

详细说明：[Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md#39-修改数据格式时遗漏配置文件消费者-🟡-中)

---

## 1️⃣3️⃣ 游戏系统实战踩坑 🆕

### §40 Tooltip遮挡触发元素导致闪烁循环 🟡 中

**问题：** 词条悬停tooltip出现后立即消失，反复闪烁

**原因：** tooltip定位在badge上方，遮挡了badge，导致badge触发MOUSE_EXIT -> tooltip消失 -> 鼠标重新进入badge -> tooltip又出现 -> 循环闪烁

**解决方案：**
```gdscript
# ✅ 正确：tooltip 及其所有子节点设置 mouse_filter = IGNORE
var tooltip: PanelContainer = PanelContainer.new()
tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
for child in tooltip.get_children():
    if child is Control:
        child.mouse_filter = Control.MOUSE_FILTER_IGNORE
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#40-tooltip遮挡触发元素导致闪烁循环-🟡-中)

### §41 场景切换绕过导致UI不更新 🔴 高

**问题：** 战斗结算面板始终显示旧内容，修改result_ui.gd无效

**原因：** map_manager._show_battle_result()创建了简单面板并2.5秒后自动跳转State.STAGE，完全绕过了result_ui.gd的完整结算面板

**解决方案：**
```gdscript
# ❌ 错误：map_manager 中独立实现场景切换逻辑
func _show_battle_result():
    await get_tree().create_timer(2.5).timeout
    GameState.change_state(State.STAGE)  # 绕过了 result_ui.gd！

# ✅ 正确：统一入口，让 result_ui.gd 处理完整结算
func _show_battle_result():
    GameState.change_state(State.RESULT)  # 由 result_ui.gd 处理完整结算
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#41-场景切换绕过导致ui不更新-🔴-高)

### §42 分裂/召唤敌人未被计入存活数 🟡 中

**问题：** 多波怪同时在场时，战斗结算提前弹出

**原因：** 手动维护 `_enemies_alive` 计数器，但分裂/召唤的敌人没有增加计数

**解决方案：**
```gdscript
# ❌ 错误：手动维护计数器
var _enemies_alive: int = 0

# ✅ 正确：使用 group 动态查询存活敌人数量
func get_alive_enemy_count() -> int:
    return get_tree().get_nodes_in_group("enemies").size()

# ✅ 分裂/召唤的敌人自动加入 group 并连接信号
func _spawn_split_enemy(pos: Vector2) -> void:
    var enemy: CharacterBody2D = enemy_scene.instantiate()
    enemy.add_to_group("enemies")  # 自动计入
    enemy.died.connect(_on_enemy_died)
    enemy.reached_base.connect(_on_enemy_reached_base)
    enemy.global_position = pos
    add_child(enemy)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#42-分裂召唤敌人未被计入存活数-🟡-中)

### §43 字典中保留已释放节点引用导致freed instance报错 🔴 高

**问题：** `Trying to assign invalid previously freed instance` 报错

**原因：** 怪物技能摧毁防御塔后，built_towers字典中仍保留已queue_free()的塔引用

**解决方案：**
```gdscript
# ✅ 正确：使用 .get() 获取引用，先检查 is_instance_valid() 再类型转换
var tower_ref = built_towers.get(key)
if is_instance_valid(tower_ref):
    var tower: Tower = tower_ref as Tower
    tower.do_something()

# ✅ 节点释放时同步从字典中移除引用
func _on_tower_destroyed(tower: Tower) -> void:
    var key: String = _get_tower_key(tower)
    built_towers.erase(key)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#43-字典中保留已释放节点引用导致freed-instance报错-🔴-高)

### §44 击退效果与路径移动冲突 🟡 中

**问题：** 敌人被击退后不按固定路径行动

**原因：** 击退效果直接修改global_position，但_process中同时计算路径移动

**解决方案：**
```gdscript
# ✅ 正确：击退期间跳过路径移动
var is_being_knocked_back: bool = false

func _process(delta: float) -> void:
    if is_being_knocked_back:
        return  # 击退期间跳过路径移动
    _move_along_path(delta)

func apply_knockback(direction: Vector2, force: float) -> void:
    is_being_knocked_back = true
    var tween: Tween = create_tween()
    tween.tween_property(self, "global_position", global_position + direction * force, 0.3)
    tween.tween_callback(func(): is_being_knocked_back = false)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#44-击退效果与路径移动冲突-🟡-中)

### §45 事件/战斗奖励重复显示 🟡 中

**问题：** 战斗结算面板显示了事件选择时获得的词条和防御塔

**原因：** session.last_event_traits和last_event_towers记录了事件选择时的奖励，战斗结算面板读取了这些数据

**解决方案：**
```gdscript
# ❌ 错误：战斗结算面板读取事件奖励数据
func _show_battle_result():
    for trait in session.last_event_traits:  # 这是事件阶段的奖励！
        _add_trait_display(trait)

# ✅ 正确：战斗结算只显示战斗获得的奖励
func _show_battle_result():
    var rewards: Dictionary = session.last_battle_rewards
    var gold: int = rewards.get("gold", 0)
    _add_gold_display(gold)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#45-事件战斗奖励重复显示-🟡-中)

### §46 词条效果字段名不一致 🟡 中

**问题：** tower_damage_bonus类词条显示"塔伤害+0"而非"塔伤害+15%"

**原因：** traits.json中tower_damage_bonus类型使用 `tower_damage_bonus` 字段名存储值，而_format_effect只读取 `value` 字段

**解决方案：**
```gdscript
# ❌ 错误：假设所有效果都用 value 字段
func _format_effect(effect: Dictionary) -> String:
    var val: float = effect.get("value", 0)  # tower_damage_bonus 类型没有 value 字段！

# ✅ 正确：根据 effect type 读取对应字段，回退到 value
func _format_effect(effect: Dictionary) -> String:
    var effect_type: String = effect.get("type", "")
    var val: float = effect.get(effect_type, effect.get("value", 0))
    match effect_type:
        "tower_damage_bonus":
            return "塔伤害+%.0f%%" % (val * 100)
        "tower_attack_speed_bonus":
            return "攻速+%.0f%%" % (val * 100)
        _:
            return str(val)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#46-词条效果字段名不一致-🟡-中)

---

### §47 UI计数显示语义错误——"已放置/最大"vs"剩余可放/最大" 🟡 中

**问题**: 防御塔选择界面显示 "0/1"，用户期望 "1/1"

**关键代码**:
```gdscript
# ❌ 错误：显示"已放置/最大"
count_label.text = "%d/%d" % [tower_placed, tower_max]  # 0/1

# ✅ 正确：显示"剩余可放/最大"
var tower_remaining: int = tower_max - tower_placed
count_label.text = "%d/%d" % [tower_remaining, tower_max]  # 1/1
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#47-ui计数显示语义错误已放置最大vs剩余可放最大-🟡-中)

---

### §48 变量命名与GDScript内置标识符冲突 🟡 中

**问题**: `var range`、`var color`、`var name` 等触发 SHADOWED_GLOBAL_IDENTIFIER 警告

**关键代码**:
```gdscript
# ❌ 错误：遮蔽内置标识符
var range: float = 100.0
var color: Color = Color.RED

# ✅ 正确：使用语义更明确的名称
var attack_range: float = 100.0
var fill_color: Color = Color.RED
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#48-变量命名与gdscript内置标识符冲突-🟡-中)

---

### §49 已满的塔从UI消失而非变灰 🟡 中

**问题**: 放满的防御塔从选择界面消失

**关键代码**:
```gdscript
# ❌ 错误：放满的塔从列表中移除
if placed < tower_config.max_count:
    _add_tower_button(tower_config)

# ✅ 正确：所有塔始终显示，已满的塔变灰禁用
var button: Button = _add_tower_button(tower_config)
if placed >= tower_config.max_count:
    button.disabled = true
    button.modulate = Color(0.5, 0.5, 0.5, 1.0)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#49-已满的塔从ui消失而非变灰-🟡-中)

---

### §50 调试误判——在正确的逻辑上反复修改 🟢 低

**问题**: 误以为是计数逻辑问题，实际是显示语义错误

**教训**: 调试bug时先确认"正确行为"的定义，先问清楚"期望显示什么"再动手

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#50-调试误判在正确的逻辑上反复修改-🟢-低)

---

## 1️⃣4️⃣ 场景树与Dictionary踩坑 🆕

### §51 节点被移出场景树后调用get_node_or_null报错 🔴 高

**问题：** `Can't use get_node() with absolute paths from outside the active scene tree`

**原因：** `select_option()`可能触发状态切换，导致当前UI节点被移出场景树

**解决方案：**
```gdscript
# ✅ 在可能触发场景切换的调用之后，加is_inside_tree()检查
EventSystem.select_option(event_data, option)
if not is_inside_tree():
    return
var node = get_node_or_null("/root/SomeNode")
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#51-节点被移出场景树后调用get_node_or_null报错-🔴-高)

### §52 以freed对象为key的Dictionary遍历崩溃 🔴 高

**问题：** `Attempted to next an invalid (previously freed?) object instance into a 'TypedDictionary.Key'`

**原因：** 以Tower对象为Dictionary的key，Tower被释放后遍历崩溃

**解决方案：**
```gdscript
# ✅ 用Array[Dictionary]存储，不以对象为key
var damage_dealers: Array[Dictionary] = []
damage_dealers.append({"tower": tower_ref, "damage": 100.0})
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#52-以freed对象为key的dictionary遍历崩溃-🔴-高)

---

## 1️⃣5️⃣ 路径系统踩坑 🆕

### §53 怪物路径偏移不能用侧向力实现 🟡 中

**问题：** 用侧向力实现路径偏移，怪物抖动/转圈

**原因：** 侧向力与路径追踪的`global_position = target_pos`互相打架

**解决方案：**
```gdscript
# ✅ 在set_path()时一次性偏移所有路径点
func set_path(points: Array[Vector2]) -> void:
    path_points = points
    _apply_lateral_offset()
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#53-怪物路径偏移不能用侧向力实现-🟡-中)

### §54 分裂/召唤怪偏移需叠加父怪偏移 🟡 中

**问题：** 子怪路径偏移只有自身随机偏移，没有继承父怪偏移

**解决方案：**
```gdscript
# ✅ 子怪偏移 = 父怪偏移 + 自身随机偏移
child.lateral_offset = lateral_offset + randf_range(-15.0, 15.0)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#54-分裂召唤怪偏移需叠加父怪偏移-🟡-中)

### §55 怪出生时current_path_index应从1开始 🟡 中

**问题：** 怪出生在path_points[0]附近，current_path_index=0，怪先走向出生点形成斜线

**解决方案：**
```gdscript
# ✅ 从索引1开始，跳过出生点
enemy.current_path_index = 1
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#55-怪出生时current_path_index应从1开始-🟡-中)

### §56 实际生成路径可能与预期不同 🟡 中

**问题：** 修改了enemy_spawner.gd但没效果，实际调用路径不经过它

**教训：** 修改代码前必须用Grep搜索确认实际的调用路径，不要假设

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#56-实际生成路径可能与预期不同-🟡-中)

---

## 1️⃣6️⃣ Dictionary判断与终局逻辑踩坑 🆕

### §57 Dictionary.has()对null值返回true 🟡 中

**问题：** `option.has("battle_trigger")`当`battle_trigger: null`时返回true

**原因：** `has()`检查key是否存在，而非value是否有效

**解决方案：**
```gdscript
# ✅ 用.get() + 类型检查
if option.get("battle_trigger") is Dictionary:
    _enter_battle()
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#57-dictionaryhas对null值返回true-🟡-中)

### §58 老年阶段不应无条件触发终局 🔴 高

**问题：** 51岁进入老年阶段后，战斗结束直接触发终局

**根因：** 三个问题叠加——老年=终局、战斗增长年龄、每次选择都扣健康

**解决方案：**
```gdscript
# ✅ 终局只在health<=0或用户选择triggers_ending选项时触发
is_final_battle = session.health <= 0 or option_has_triggers_ending
# 战斗不增长年龄，只在事件阶段增长
# _apply_stage_attribute_growth只在年龄实际增长时调用
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#58-老年阶段不应无条件触发终局-🔴-高)

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

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#81-暴击特效不应作为额外伤害实例-🔴-高)

### §82 debuff_amount设置但未使用导致效果不生效 🟡 中

**问题：** 历史塔的"削弱敌人属性"完全无效

**原因：** apply_debuff设置了debuff_amount，但take_damage中从未读取该值

**解决方案：**
```gdscript
# ✅ 在take_damage中将debuff_amount加入抗性计算
func take_damage(amount: float, is_crit: bool = false) -> void:
    var resistance: float = maxf(0.0, resistance - armor_break_amount - debuff_amount)
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#82-debuff_amount设置但未使用导致效果不生效-🟡-中)

### §83 翻译键不匹配导致格式化报错 🔴 高

**问题：** `String formatting error: not all arguments converted`

**原因：** 代码使用`tr("ENEMY_DEBUFFED")`，但CSV中只有`ENEMY_DEBUFF`，tr()返回键名本身，格式化失败

**解决方案：**
```gdscript
# ✅ 确保代码中的翻译键与CSV中完全一致
var text: String = tr("ENEMY_DEBUFF") % [slow_amount, slow_timer]
```

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#83-翻译键不匹配导致格式化报错-🔴-高)

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

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#84-终局状态机被ui回调覆盖-🔴-高)

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

详细说明：[Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md#85-particleprocessmaterialcolor_ramp类型限制-🟡-中)

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
- [19_Pitfall_Records.md](../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md) - 完整踩坑记录
- [GDScript_Warning_Best_Practices.md](../base/practical-experiences/pitfall-cases/GDScript_Warning_Best_Practices.md) - 警告处理最佳实践
- [Godot_4x_Resource_File_Comment_Issue.md](../base/practical-experiences/pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md) - 资源文件注释问题
- [Godot_4x_Autoload_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md) - Autoload 单例踩坑 🆕
- [GUT_Testing_Pitfalls.md](../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md) - GUT 测试框架踩坑 🆕
- [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md) - 资源引用与数据一致性踩坑 🆕
- [Godot_4x_Game_System_Pitfalls.md](../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md) - 游戏系统实战踩坑 🆕

### Wiki 层相关页面
- [GDScript 代码规范](./gdscript-standards.md)
- [性能优化实战](../guides/performance-optimization.md)

---

**最后更新**: 2026-04-22  
**维护者**: Knowledge Base Administrator  
**来源**: tower_defense 项目实战经验
