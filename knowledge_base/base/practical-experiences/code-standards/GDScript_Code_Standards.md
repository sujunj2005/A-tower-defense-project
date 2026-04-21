# Godot 4.x GDScript 代码规范指南

> 适用版本：Godot 4.x（特别是 4.6+） | 版本：2.0  
> 来源：基于实战经验整理的代码规范标准

---

## 目录

1. [编码原则](#1-编码原则)
2. [命名规范](#2-命名规范)
3. [变量与常量](#3-变量与常量)
   - [3.1 整数除法规范](#31-整数除法规范)
   - [3.2 显性声明变量类型](#32-显性声明变量类型-强制要求)
   - [3.3 内嵌 set/get 函数规范](#33-内嵌-setget-函数规范) 🆕
4. [函数规范](#4-函数规范)
5. [枚举处理](#5-枚举处理)
6. [资源管理](#6-资源管理)
7. [调试输出](#7-调试输出)
8. [错误与日志处理](#8-错误与日志处理)
9. [测试规范](#9-测试规范)
10. [代码审查清单](#10-代码审查清单)
11. [资源文件规范](#11-资源文件规范) 🆕
12. [Autoload 单例规范](#12-autoload-单例规范) 🆕
13. [测试编码守则](#13-测试编码守则) 🆕
14. [资源引用与数据一致性规范](#14-资源引用与数据一致性规范) 🆕
15. [游戏系统实战规范](#15-游戏系统实战规范) 🆕

---

## 1. 编码原则

### 1.1 警告处理原则

**优先级分级：**

| 级别 | 类型 | 处理要求 | 示例 |
|------|------|----------|------|
| 🔴 **高** | 类型安全警告 | **必须修复** | 类型转换、空值检查 |
| 🟡 **中** | 代码质量警告 | **建议修复** | 变量遮蔽、未使用变量 |
| 🟢 **低** | 兼容性警告 | **酌情修复** | 枚举值不匹配（已注释） |

### 1.2 代码质量目标

- ✅ **零警告原则**：提交前确保编译警告数量为 0
- ✅ **可读性优先**：代码应清晰易懂，避免歧义
- ✅ **预防性编程**：提前避免常见问题，而非事后修复

---

## 2. 命名规范

### 2.1 变量命名

#### 2.1.1 类成员变量 vs 函数参数

**规则：** 函数参数名不得与类成员变量同名

```gdscript
# ❌ 错误：命名冲突
extends Node2D

var target: Node2D = null
var config: TowerConfig

func attack(target: Node2D):  # ❌ 参数遮蔽成员变量
    target.attack()  # 哪个 target？

# ✅ 正确：使用描述性名称
extends Node2D

var target: Node2D = null
var config: TowerConfig

func attack(attack_target: Node2D):  # ✅ 参数名明确
    attack_target.attack()

# ✅ 正确：使用前缀区分
extends Node2D

var m_target: Node2D = null  # m_ = member
var m_config: TowerConfig

func attack(target: Node2D):  # ✅ 参数名简短清晰
    target.attack()
```

#### 2.1.2 推荐命名模式

**功能描述型：**
```gdscript
# 特效函数参数命名
func apply_slow_effect(slow_target: Node2D)
func apply_dot_effect(dot_target: Node2D)
func apply_knockback_effect(knockback_target: Node2D)
func apply_lifesteal_effect(lifesteal_target: Node2D)

# 配置参数命名
func setup(attack_config: TowerConfig)
func initialize(enemy_config: EnemyConfig)
```

**前缀约定：**
- `m_` - 成员变量（member），如 `m_target`
- `_` - 私有变量，如 `_internal_counter`
- `{功能}_` - 功能描述，如 `slow_target`, `damage_value`

#### 2.1.3 变量命名禁止与内置标识符冲突 🔴 强制

**规则**: GDScript 局部变量、导出属性禁止使用 GDScript 内置标识符，应使用语义更明确的名称

**原因**: GDScript 有大量内置函数/类/常量，局部变量同名会遮蔽全局标识符，触发 `SHADOWED_GLOBAL_IDENTIFIER` 警告，可能导致意外行为

**禁止使用的内置标识符列表**:

| 禁止使用 | 推荐替代 | 场景 |
|---------|---------|------|
| `range` | `attack_range`, `detect_range` | 攻击/检测范围 |
| `color` | `fill_color`, `growth_color` | 填充/生长颜色 |
| `name` | `display_name`, `era_name` | 显示/时代名称 |
| `size` | `img_size`, `cell_size` | 图片/格子尺寸 |
| `text` | `attr_text`, `label_text` | 属性/标签文本 |
| `type` | `enemy_type`, `item_type` | 敌人/物品类型 |
| `value` | `damage_value`, `score_value` | 伤害/分数值 |
| `key` | `config_key`, `dict_key` | 配置/字典键 |
| `step` | `move_step`, `anim_step` | 移动/动画步长 |
| `count` | `enemy_count`, `item_count` | 敌人/物品计数 |
| `data` | `config_data`, `save_data` | 配置/存档数据 |
| `result` | `battle_result`, `query_result` | 战斗/查询结果 |
| `error` | `load_error`, `parse_error` | 加载/解析错误 |
| `input` | `player_input`, `user_input` | 玩家/用户输入 |
| `output` | `log_output`, `calc_output` | 日志/计算输出 |
| `object` | `target_object`, `game_object` | 目标/游戏对象 |
| `signal` | `custom_signal`, `event_signal` | 自定义/事件信号 |
| `method` | `callback_method`, `api_method` | 回调/API方法 |
| `function` | `handler_function`, `util_function` | 处理/工具函数 |
| `class` | `enemy_class`, `item_class` | 敌人/物品类别 |
| `load` | `scene_load`, `asset_load` | 场景/资源加载 |
| `string` | `format_string`, `search_string` | 格式/搜索字符串 |
| `position` | `spawn_position`, `target_position` | 生成/目标位置 |
| `scale` | `damage_scale`, `time_scale` | 伤害/时间缩放 |
| `rotation` | `facing_rotation`, `spin_rotation` | 朝向/旋转角度 |

```gdscript
# ❌ 错误：使用与GDScript内置标识符同名的变量
var range: float = 100.0       # 遮蔽内置函数 range()
var color: Color = Color.RED   # 遮蔽内置类 Color
var name: String = "tower"     # 遮蔽内置属性 name
var size: Vector2 = Vector2(32, 32)  # 遮蔽内置属性 size
var text: String = "hello"     # 遮蔽内置属性 text

# ✅ 正确：使用语义更明确的名称
var attack_range: float = 100.0       # 攻击范围
var fill_color: Color = Color.RED     # 填充颜色
var display_name: String = "tower"    # 显示名称
var img_size: Vector2 = Vector2(32, 32)  # 图片尺寸
var attr_text: String = "hello"       # 属性文本
```

**踩坑记录**: [§48 变量命名与GDScript内置标识符冲突](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#48-变量命名与gdscript内置标识符冲突-🟡-中)

### 2.2 常量和枚举

```gdscript
# ✅ 推荐：使用有意义的常量
const MAX_SPEED = 100.0
const GRAVITY = 9.8

# ✅ 推荐：枚举值添加注释
enum ParticleEmissionShape {
    POINT = 0,    # 点发射
    BOX = 2,      # 盒子发射
    CIRCLE = 4,   # 圆形发射
    RING = 3      # 环形发射
}
```

---

## 3. 变量与常量

### 3.1 整数除法规范

**规则：** 除法运算必须使用浮点数，避免精度丢失

```gdscript
# ❌ 错误：整数除法丢弃小数
var half_size = tile_size / 2        # 65 / 2 = 32 (不是 32.5)
var center_x = viewport_size.x / 2
var offset = Vector2(size / 2, size / 2)

# ✅ 正确：使用浮点数除数
var half_size = tile_size / 2.0      # 65 / 2.0 = 32.5
var center_x = viewport_size.x / 2.0
var offset = Vector2(size / 2.0, size / 2.0)

# ✅ 正确：显式类型转换
var half_size = float(tile_size) / 2
```

**常见场景：**
- 计算中心点：`position + size / 2.0`
- 计算一半距离：`distance / 2.0`
- 向量计算：`Vector2(size / 2.0, size / 2.0)`

### 3.2 显性声明变量类型 (强制要求)

**规则级别**: 🔴 强制 (项目代码生成)

**说明**: 从版本 2.0 开始，类型声明从建议升级为强制要求

**核心要求**: 所有变量、数组、字典必须显式声明静态类型

#### 3.2.1 基础类型声明

```gdscript
# ✅ 推荐：显式类型注解
var health: int = 100
var speed: float = 5.0
var name: String = "Player"
var is_alive: bool = true
var position: Vector2 = Vector2.ZERO

# ❌ 避免：动态类型 (类型不明确)
var health = 100  # 类型不明确
var speed = 5.0   # 类型不明确
```

#### 3.2.2 类型推断 (推荐用法)

```gdscript
# ✅ 推荐：使用 := 进行类型推断 (简洁且类型明确)
var health := 100        # 推断为 int
var speed := 5.5         # 推断为 float
var name := "Player"     # 推断为 String
var target := get_node("Target")  # 推断为 Node

# ⚠️ 踩坑点：:= 推断后类型固定，不能赋其他类型的值
var count := 0
count = "text"  # ❌ 错误！类型不匹配
```

#### 3.2.3 数组和字典类型声明

```gdscript
# ✅ 推荐：类型化数组
var scores: Array[int] = [10, 20, 30]
var enemies: Array[Enemy] = []
var nodes: Array[Node2D] = []

# ✅ 推荐：类型化字典
var config: Dictionary = {"health": 100, "speed": 5.0}
var typed_dict: Dictionary[String, int] = {"health": 100, "damage": 50}

# ❌ 避免：非类型化数组/字典
var enemies = []  # 类型不明确
var config = {}   # 类型不明确
```

#### 3.2.4 函数参数和返回值类型

```gdscript
# ✅ 推荐：参数和返回值都有类型注解
func attack(target: Node2D, damage: int) -> bool:
    return true

func get_health() -> int:
    return health

func is_alive() -> bool:
    return health > 0

# ❌ 避免：无类型注解
func attack(target, damage):  # 类型不明确
    pass
```

#### 3.2.5 常量类型声明

```gdscript
# ✅ 推荐：常量显式声明类型
const MOVE_SPEED: float = 50.0
const MAX_HEALTH: int = 100
const PLAYER_NAME: String = "Player"

# ✅ 常量自动推断类型 (可接受)
const GRAVITY = 9.8  # 推断为 float
const MAX_SPEED = 100  # 推断为 int

# ✅ 类型数组/字典必须显式声明
const NUMBERS: Array[int] = [1, 2, 3]
const CONFIG: Dictionary[String, int] = {"health": 100}
```

#### 3.2.6 类型转换

```gdscript
# ✅ 推荐：显式类型转换
var int_value: int = 42.7 as int  # 42
var float_value: float = 42  # 42.0
var half: float = 5 / 2.0  # 2.5

# ✅ 使用 as 进行安全转换
var node = get_node("Sprite")
var sprite = node as Sprite2D
if sprite:
    # 安全使用
    pass

# ⚠️ 踩坑点：整数除法
var half_wrong: int = 5 / 2  # 2 ❌ (整数除法)
var half_correct: float = 5 / 2.0  # 2.5 ✅
```

#### 3.2.7 使用 as 声明自定义类型 (重要)

**规则**: 对于非 Godot 内置的自定义类类型，必须使用 `as` 关键字进行显式类型声明

**场景 1: 从节点获取自定义脚本**

```gdscript
# ✅ 推荐：使用 as 显式声明自定义类型
var tower := $TowerNode as TowerScript
var enemy := get_node("Enemy") as EnemyScript

# ❌ 避免：不使用 as，类型不明确
var tower = $TowerNode  # 类型不明确，可能是 Node 或 TowerScript
var enemy = get_node("Enemy")  # 类型不明确
```

**场景 2: 从信号或回调获取对象**

```gdscript
# ✅ 推荐：信号回调中使用 as 声明自定义类型
func _on_area_entered(area: Area2D):
    var enemy_projectile := area as EnemyProjectile
    if enemy_projectile:
        enemy_projectile.explode()
    
    var player_projectile := area as PlayerProjectile
    if player_projectile:
        player_projectile.on_hit()

# ❌ 避免：不使用 as，无法利用类型检查
func _on_area_entered(area: Area2D):
    if area.has_method("explode"):  # 动态检查，效率低
        area.explode()
```

**场景 3: 从数组或字典中获取自定义对象**

```gdscript
# ✅ 推荐：从容器中获取时使用 as 声明
var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
for enemy_node in enemies:
    var enemy := enemy_node as EnemyScript
    if enemy:
        enemy.take_damage(10)

# ✅ 推荐：从字典中获取时使用 as
var object_dict: Dictionary = {"tower": $TowerNode}
var tower := object_dict["tower"] as TowerScript
if tower:
    tower.attack()

# ❌ 避免：直接使用，类型不明确
var tower = object_dict["tower"]  # 类型不明确
tower.attack()  # 可能报错
```

**场景 4: 函数返回值类型转换**

```gdscript
# ✅ 推荐：函数返回 Variant 时使用 as 转换
func get_object_by_id(id: String) -> Object:
    return object_pool.get(id)

var obj := get_object_by_id("tower_1") as TowerScript
if obj:
    obj.attack()

# ✅ 推荐：使用 is + as 组合检查
func process_target(target: Node):
    if target is not TowerScript:
        push_error("目标不是 TowerScript 类型")
        return
    
    var tower := target as TowerScript
    tower.attack()
```

**场景 5: 使用 class_name 注册的自定义类**

```gdscript
# ✅ 推荐：class_name 注册的类可以直接使用 as
class_name TowerScript
extends Node2D

var tower := $TowerNode as TowerScript  # ✅ 直接使用

# ✅ 推荐：预加载的自定义脚本
const TowerScript = preload("res://scripts/tower_script.gd")
var tower := $TowerNode as TowerScript  # ✅ 使用 as 转换
```

**⚠️ 踩坑点**:

1. **as 转换失败返回 null**: `as` 转换失败时不会报错，而是返回 `null`
   ```gdscript
   var sprite := node as Sprite2D  # 如果 node 不是 Sprite2D，sprite 为 null
   if not sprite:
       push_error("类型转换失败")
       return
   ```

2. **必须检查转换结果**: 使用 `as` 后必须检查是否为 `null`
   ```gdscript
   var tower := $TowerNode as TowerScript
   if not tower:
       push_error("TowerNode 没有 TowerScript 脚本")
       return
   ```

3. **is 检查更安全**: 对于关键代码，使用 `is` 先检查再转换
   ```gdscript
   if node is TowerScript:
       var tower := node as TowerScript
       tower.attack()
   else:
       push_error("节点类型错误")
   ```

**最佳实践**:

1. **始终使用 as**: 对于自定义类型，始终使用 `as` 显式声明
2. **配合 is 检查**: 关键代码使用 `is` 先检查类型
3. **错误处理**: 转换失败时使用 `push_error` 记录错误
4. **类型注解**: 变量声明时同时使用类型注解和 as
   ```gdscript
   var tower: TowerScript = $TowerNode as TowerScript
   ```

#### 3.2.8 静态类型优势

**性能提升**:
- 方法调用：10-15% 性能提升
- 算术运算：8-12% 性能提升
- 错误检测：编译时发现，无需运行

**开发效率**:
- 代码补全：编辑器提供更精确的自动完成
- 自文档化：类型提示让代码更易理解
- 重构安全：类型检查帮助发现潜在问题

#### 3.2.9 检查清单

代码审查时检查:
- [ ] 所有变量都有类型声明 (显式或推断)
- [ ] 数组和字典明确了类型
- [ ] 函数参数有类型注解
- [ ] 函数有返回值类型注解
- [ ] 常量有类型声明 (或可推断)
- [ ] 类型转换使用 `as` 关键字 (特别是自定义类型)
- [ ] 无整数除法精度丢失问题
- [ ] 自定义类型使用 as 显式声明

### 3.3 内嵌 set/get 函数规范 🆕

**使用场景**：当变量修改时需要自动触发额外逻辑（如更新 UI、触发事件、数据验证等），应优先使用内嵌 set/get 函数

**核心优势**：
- ✅ **自动触发**：无需手动调用更新函数
- ✅ **集中管理**：所有修改逻辑在一处维护
- ✅ **类型安全**：配合静态类型，确保类型正确
- ✅ **数据验证**：可以在 set 中进行数据校验
- ✅ **代码简洁**：调用方无需关心内部逻辑

#### 3.3.1 基础语法

```gdscript
# ✅ 推荐：使用内嵌 set/get 函数
var hp: int = 100:
	set(new_value):
		hp = clampi(new_value, 0, 100)  # 数据验证：限制在 0-100
		update_hp_ui()  # 自动触发 UI 更新
	get:
		return hp

# ✅ 推荐：带事件触发的 setter
var level: int = 1:
	set(new_level):
		var old_level = level
		level = new_level
		if level > old_level:
			on_level_up.emit(level)  # 触发升级事件
		on_level_changed.emit(level)  # 触发等级变化事件
	get:
		return level

# ❌ 避免：手动调用更新函数
var hp: int = 100

func set_hp(new_hp: int):
	hp = clampi(new_hp, 0, 100)
	update_hp_ui()  # 需要手动调用，容易忘记

func take_damage(amount: int):
	hp -= amount
	update_hp_ui()  # 容易遗漏
```

#### 3.3.2 实战应用场景

**场景 1：血量/等级 UI 自动更新**

```gdscript
# ✅ 推荐：自动更新 UI
extends Node2D

@onready var hp_label: Label = $UI/HpLabel
@onready var level_label: Label = $UI/LevelLabel

var hp: int = 100:
	set(new_hp):
		hp = clampi(new_hp, 0, max_hp)
		if hp_label:
			hp_label.text = "%d / %d" % [hp, max_hp]
	get:
		return hp

var level: int = 1:
	set(new_level):
		level = max(1, new_level)  # 等级至少为 1
		if level_label:
			level_label.text = "Lv.%d" % level
	get:
		return level

var max_hp: int = 100

# 使用示例
func take_damage(amount: int):
	hp -= amount  # 自动触发 UI 更新，无需手动调用

func gain_exp(amount: int):
	if should_level_up():
		level += 1  # 自动触发等级 UI 更新
```

**场景 2：数据验证与边界检查**

```gdscript
# ✅ 推荐：在 setter 中进行数据验证
var gold: int = 0:
	set(new_gold):
		gold = max(0, new_gold)  # 金币不能为负数
		if gold != new_gold:
			push_warning("金币被限制为 %d（原值 %d）" % [gold, new_gold])
	get:
		return gold

var inventory_size: int = 20:
	set(new_size):
		inventory_size = clampi(new_size, 1, 100)  # 限制背包大小范围
		if inventory_size < new_size:
			push_warning("背包大小被限制为 %d" % inventory_size)
	get:
		return inventory_size

# 使用示例
func add_gold(amount: int):
	gold += amount  # 自动验证，不会出现负数

func remove_gold(amount: int):
	gold -= amount  # 自动验证，不会出现负数
```

**场景 3：状态变化触发事件**

```gdscript
# ✅ 推荐：状态变化时自动触发事件
extends CharacterBody2D

signal state_changed(old_state: int, new_state: int)
signal is_dead_changed(is_dead: bool)

var is_dead: bool = false:
	set(new_dead):
		if is_dead != new_dead:
			is_dead = new_dead
			is_dead_changed.emit(is_dead)
			if is_dead:
				on_death()
			else:
				on_revive()
	get:
		return is_dead

var state: int = IDLE:
	set(new_state):
		var old_state = state
		if state != new_state:
			state = new_state
			state_changed.emit(old_state, state)
			_on_state_entered(state)
	get:
		return state

const IDLE = 0
const MOVE = 1
const ATTACK = 2
const DEAD = 3

func _on_state_entered(new_state: int):
	match new_state:
		IDLE:
			play_idle_animation()
		MOVE:
			play_move_animation()
		ATTACK:
			play_attack_animation()
		DEAD:
			play_death_animation()
```

**场景 4：属性联动更新**

```gdscript
# ✅ 推荐：多个属性联动
extends Node2D

var base_damage: float = 10.0:
	set(new_damage):
		base_damage = max(0.0, new_damage)
		update_total_damage()  # 重新计算总伤害
	get:
		return base_damage

var damage_multiplier: float = 1.0:
	set(new_multiplier):
		damage_multiplier = max(0.0, new_multiplier)
		update_total_damage()  # 重新计算总伤害
	get:
		return damage_multiplier

var total_damage: float = 10.0  # 只读属性

func update_total_damage():
	total_damage = base_damage * damage_multiplier
	print("总伤害：%f" % total_damage)

# 使用示例
func upgrade_damage():
	base_damage += 5.0  # 自动重新计算总伤害

func apply_buff(multiplier: float):
	damage_multiplier *= multiplier  # 自动重新计算总伤害
```

#### 3.3.3 注意事项

**⚠️ 避免在 setter 中产生副作用**

```gdscript
# ❌ 错误：setter 中不应有复杂逻辑
var score: int = 0:
	set(new_score):
		score = new_score
		update_ui()  # ✅ 可以
		save_to_disk()  # ❌ 不应该在 setter 中保存
		send_network_request()  # ❌ 不应该网络请求
		play_sound()  # ❌ 不应该播放声音
	get:
		return score

# ✅ 正确：setter 只处理必要的更新
var score: int = 0:
	set(new_score):
		score = max(0, new_score)  # 数据验证
		update_score_ui()  # UI 更新
	get:
		return score

func save_game():
	# 在专门的函数中保存
	save_to_disk()
```

**⚠️ 避免循环引用**

```gdscript
# ❌ 错误：循环引用
var value_a: int = 0:
	set(new_a):
		value_a = new_a
		value_b = value_a * 2  # 触发 value_b 的 setter
	get:
		return value_a

var value_b: int = 0:
	set(new_b):
		value_b = new_b
		value_a = value_b / 2  # 触发 value_a 的 setter，死循环！
	get:
		return value_b

# ✅ 正确：使用内部变量避免循环
var _value_a: int = 0
var _value_b: int = 0

var value_a: int = 0:
	set(new_a):
		_value_a = new_a
		_value_b = _value_a * 2  # 直接修改内部变量
	get:
		return _value_a

var value_b: int = 0:
	set(new_b):
		_value_b = new_b
		_value_a = _value_b / 2  # 直接修改内部变量
	get:
		return _value_b
```

**⚠️ getter 应保持轻量**

```gdscript
# ❌ 错误：getter 中不应有耗时操作
var cached_value: float = 0.0:
	get:
		return expensive_calculation()  # ❌ 每次访问都重新计算
	set(new_value):
		cached_value = new_value

# ✅ 正确：getter 应该快速返回
var cached_value: float = 0.0:
	get:
		return cached_value  # ✅ 直接返回

func get_calculated_value() -> float:
	return expensive_calculation()  # 耗时操作使用显式函数
```

#### 3.3.4 与@export 配合使用

```gdscript
# ✅ 推荐：@export 与 set/get 配合
extends Node2D

@export var move_speed: float = 100.0:
	set(new_speed):
		move_speed = max(0.0, new_speed)
		if is_inside_tree():
			update_movement()  # 运行时实时更新
	get:
		return move_speed

@export var attack_range: float = 50.0:
	set(new_range):
		attack_range = max(0.0, new_range)
		update_attack_range_visual()  # 更新攻击范围显示
	get:
		return attack_range

func update_movement():
	# 根据速度更新移动逻辑
	pass

func update_attack_range_visual():
	# 更新攻击范围显示
	pass
```

#### 3.3.5 检查清单

代码审查时检查:
- [ ] set/get 语法正确（缩进、冒号）
- [ ] setter 中有数据验证（如需要）
- [ ] setter 触发了必要的更新（UI、事件等）
- [ ] getter 简单高效，无耗时操作
- [ ] 避免了循环引用
- [ ] setter 中无复杂副作用（网络请求、磁盘保存等）
- [ ] 配合@export 时能在编辑器中实时预览

---

### 3.4 内嵌 get/set 使用场景与常见错误 🆕

**核心要点**：内嵌 get/set 有两种主要使用场景——**独立状态**和**包装属性**。错误的使用方式会导致状态不一致、冗余赋值等问题。

#### 3.4.1 场景 1：独立状态 (Independent State)

**适用场景**：变量没有底层对应属性，是独立的存储变量

**特点**：
- setter 中使用**自赋值**设置内部存储
- getter **返回属性自身**
- 检查条件使用 `self != value`

```gdscript
# ✅ 正确：独立状态变量
var is_locked: bool = false:
    set(value):
        if is_locked != value:  # 检查自身当前值
            is_locked = value    # 自赋值设置内部存储
            if is_locked:
                _lock_panel()
            else:
                _unlock_panel()
    get:
        return is_locked  # 返回自身值

# ✅ 正确：对象引用类型的独立状态
var hovered_tower: Tower = null:
    set(value):
        if hovered_tower != value:  # 检查自身当前值
            hovered_tower = value    # 自赋值设置内部存储
            if hovered_tower:
                _on_tower_hovered(hovered_tower)
            else:
                _on_tower_hover_ended()
    get:
        return hovered_tower  # 返回自身值
```

**使用要点**：
1. setter 中检查 `if self != value` 避免重复触发
2. setter 中执行 `self = value` 进行自赋值
3. getter 中直接 `return self` 返回存储值
4. 适用于：标志位、对象引用、状态变量等

#### 3.4.2 场景 2：包装已有属性 (Property Wrapper)

**适用场景**：变量用于包装已有的底层属性（如 Control 的 visible、position 等）

**特点**：
- setter 中**直接设置底层属性**，**不自赋值**
- getter **直接返回底层属性值**
- 检查条件使用**底层属性的值**

```gdscript
# ✅ 正确：包装 Control 的 visible 属性
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if visible != value:  # ✅ 检查实际的 visible 状态
            visible = value    # ✅ 直接设置 Control 的 visible
            if visible:
                _on_panel_shown()
            else:
                _on_panel_hidden()
    get:
        return visible  # ✅ 直接返回 Control 的 visible 值
```

**使用要点**：
1. setter 中检查 `if underlying != value`（底层属性）
2. setter 中执行 `underlying = value` 设置底层属性
3. getter 中直接 `return underlying` 返回底层属性值
4. 适用于：包装节点内置属性、添加额外逻辑

#### 3.4.3 常见错误与踩坑

**❌ 错误用法：创建双重状态**

```gdscript
# ❌ 错误：包装属性时创建了两个独立状态
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if is_panel_visible != value:  # ❌ 检查自身（应该检查 visible）
            is_panel_visible = value    # ❌ 自赋值（冗余，应该直接设置 visible）
            visible = value             # ❌ 同步另一个属性
            if is_panel_visible:
                _on_panel_shown()
            else:
                _on_panel_hidden()
    get:
        return is_panel_visible  # ❌ 返回自身（应该返回 visible）
```

**问题分析**：
1. **两个独立状态**：创建了 `is_panel_visible` 和 `visible` 两个独立变量
2. **冗余自赋值**：`is_panel_visible = value` 是多余的
3. **手动同步风险**：需要手动同步两个属性，容易导致状态不一致
4. **真实踩坑案例**：

```gdscript
# 真实案例：TowerSelectUI 重构中的问题
extends Panel

# ❌ 错误的包装方式
var is_panel_visible: bool = false:
    set(value):
        if is_panel_visible != value:
            is_panel_visible = value
            visible = value  # 同步 visible
            # ... 触发事件

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

**✅ 正确做法**：

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

#### 3.4.4 使用场景对比表

| 场景 | 用法 | setter 检查 | setter 设置 | getter 返回 | 示例 |
|------|------|-----------|-----------|-----------|------|
| **独立状态** | 无底层属性 | `if self != value` | `self = value` | `return self` | `is_locked`, `hovered_tower` |
| **包装属性** | 有底层属性 | `if underlying != value` | `underlying = value` | `return underlying` | `is_panel_visible` (包装 `visible`) |
| **计算属性** | 只读 getter | N/A | N/A | 计算表达式 | `health_percent = health / max_health` |

**计算属性示例**：

```gdscript
# ✅ 计算属性：只读 getter
var health: float = 100.0
var max_health: float = 100.0

var health_percent: float:
    get:
        return health / max_health if max_health > 0 else 0.0
    # ✅ 没有 setter，只读计算属性
```

#### 3.4.5 最佳实践

1. **明确属性类型**：先判断是独立状态还是包装属性
   - 问自己：这个变量有底层对应属性吗？
   - 有 → 包装属性；没有 → 独立状态

2. **独立状态**：setter 中自赋值，getter 返回自身
   ```gdscript
   var my_state: int = 0:
       set(value):
           if my_state != value:
               my_state = value
               _on_state_changed()
       get:
           return my_state
   ```

3. **包装属性**：setter 设置底层属性，getter 返回底层属性
   ```gdscript
   var is_visible: bool = false:
       set(value):
           if visible != value:
               visible = value
               _on_visibility_changed()
       get:
           return visible
   ```

4. **避免直接访问**：使用包装属性时，不要直接访问底层属性
   ```gdscript
   # ❌ 避免
   visible = false  # 绕过了包装属性
   
   # ✅ 推荐
   is_panel_visible = false  # 使用包装属性
   ```

5. **状态一致性**：确保包装属性和底层属性始终同步
   - 始终通过包装属性访问
   - 不在其他地方直接修改底层属性

#### 3.4.6 检查清单

代码审查时检查:
- [ ] 正确区分独立状态和包装属性
- [ ] 独立状态使用自赋值，包装属性设置底层属性
- [ ] getter 返回正确的值（自身 vs 底层属性）
- [ ] 没有创建双重状态
- [ ] 避免了直接访问底层属性（包装属性场景）
- [ ] 状态始终保持一致
- [ ] 计算属性使用只读 getter

---

## 4. 函数规范

### 4.1 参数命名

**规则：** 参数名应具有描述性，避免与成员变量冲突

```gdscript
# ❌ 错误：参数名模糊
func process(data):
    pass

# ✅ 正确：参数名描述用途
func process_enemy_damage(enemy: Enemy, damage_amount: float):
    pass

# ❌ 错误：参数遮蔽成员变量
var config: TowerConfig
func setup(config: TowerConfig):  # ❌ 同名
    self.config = config

# ✅ 正确：使用不同名称
var config: TowerConfig
func setup(new_config: TowerConfig):  # ✅ 明确是新配置
    config = new_config
```

### 4.2 返回值处理

**规则：** 不得忽略函数返回值

```gdscript
# ❌ 错误：忽略返回值
some_array.has(element)
some_array.find(item)

# ✅ 正确：使用返回值
if some_array.has(element):
    pass

var index = some_array.find(item)
if index != -1:
    pass
```

---

## 5. 枚举处理

### 5.1 避免直接使用枚举常量

**原因：** Godot 版本变化可能导致枚举值不匹配

```gdscript
# ❌ 不推荐：依赖具体版本的枚举定义
material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT

# ✅ 推荐：使用整数值 + 注释
# Godot 4.x 发射形状值：
# 0 = POINT (点)
# 1 = SPHERE (球体)
# 2 = BOX (盒子)
# 3 = RING (环)
# 4 = CIRCLE (圆形)
# 5 = POINT_TEXTURE (点纹理)
material.emission_shape = 0
```

### 5.2 集中管理枚举映射

```gdscript
# ✅ 推荐：在配置文件中定义常量
class ParticleConstants:
    const EMISSION_SHAPE_POINT = 0
    const EMISSION_SHAPE_BOX = 2
    const EMISSION_SHAPE_CIRCLE = 4
    const EMISSION_SHAPE_RING = 3

# 使用
material.emission_shape = ParticleConstants.EMISSION_SHAPE_POINT
```

### 5.3 添加详细注释

```gdscript
# ✅ 推荐：完整注释
match particle_emission_shape:
    0:  # 点发射
        material.emission_shape = 0
    1:  # 矩形（使用 BOX）
        material.emission_shape = 2
        material.emission_box_extents = Vector3(...)
    2:  # 圆形
        material.emission_shape = 4
        material.emission_sphere_radius = ...
    3:  # 环
        material.emission_shape = 3
        material.emission_ring_radius = ...
```

---

## 6. 资源管理

### 6.1 资源 UID 规范

**规则：** 必须使用 Godot 自动生成的真实 UID，禁止编造占位符

```tres
# ❌ 错误：使用占位符 UID
[ext_resource type="Resource" uid="uid://arrow_projectile_unique_id" path="res://resources/projectiles/arrow_projectile.tres" id="2_projectile"]

# ✅ 正确：使用真实 UID
[ext_resource type="Resource" uid="uid://bir4roo7lnx42" path="res://resources/projectiles/arrow_projectile.tres" id="2_projectile"]
```

### 6.2 获取正确 UID 的方法

**步骤：**
1. 打开实际资源文件（如 `arrow_projectile.tres`）
2. 查看第一行的 UID：`uid="uid://bir4roo7lnx42"`
3. 复制并替换引用处的错误 UID

**预防措施：**
- ✅ 尽量在 Godot 编辑器中创建资源，不要手动编写 UID
- ✅ 使用检查器面板查看资源的真实 UID
- ✅ 避免手动修改 `.tres` 文件中的 UID，除非确定正确的值

### 6.3 资源加载

```gdscript
# ✅ 推荐：使用 preload 静态加载
const EnemyScene = preload("res://scenes/enemy.tscn")

# ✅ 推荐：动态加载时检查存在性
var resource = load("res://resources/config.tres")
if resource:
    pass
else:
    push_error("资源加载失败")
```

---

## 11. 资源文件规范 🆕

### 11.1 .tres 文件注释规范

**🔴 严重警告**：`.tres` 资源文件中**禁止在字段值后添加行内注释**，否则会导致字段加载失败！

**问题说明：**
- Godot 4.x 的资源解析器不支持行内注释
- 字段值后的 `# 注释` 会导致该字段被重置为默认值
- 影响：配置数据丢失、游戏功能异常

**错误示例：**
```tres
# ❌ 错误：注释导致字段加载失败
[resource]
script = ExtResource("1_heavy")
enemy_id = "heavy_armor"
gold_drop = 20  # 高价值目标           # ⚠️ 会导致加载失败！
experience_drop = 50  # 高经验奖励     # ⚠️ 会导致加载失败！
texture_path = "res://images/enemies/marble_0_0.png"  # ⚠️ 会导致加载失败！
```

**正确示例：**
```tres
# ✅ 正确：移除所有行内注释
[resource]
script = ExtResource("1_heavy")
enemy_id = "heavy_armor"
gold_drop = 20
experience_drop = 50
texture_path = "res://images/enemies/marble_0_0.png"
```

**影响案例：**
```
[EnemyConfig]        - texture_path:              # ⚠️ 空字符串（应为图片路径）
[EnemyConfig]        - experience_drop: 5         # ⚠️ 默认值（应为 50）
[EnemyConfig]        - gold_drop: 20              # ✅ 正确（默认值就是 20）
```

**解决方案：**
1. **立即修复**：移除所有 `.tres` 文件中的行内注释
2. **重新保存**：在 Godot 编辑器中打开并保存资源文件
3. **重启清理**：重启 Godot 编辑器清除缓存
4. **验证加载**：运行游戏验证配置正确加载

**详细说明：**
- [Godot_4x_Resource_File_Comment_Issue.md](../19_Common_Pitfalls/Godot_4x_Resource_File_Comment_Issue.md)
- [19_Pitfall_Records.md#§23](../19_Common_Pitfalls/19_Pitfall_Records.md)

### 11.2 资源文件最佳实践

**注释替代方案：**
```tres
# ✅ 方案 1：使用外部文档
# resources/enemies/heavy_armor_config.md
# - gold_drop: 20 (高价值目标)
# - experience_drop: 50 (高经验奖励)

# ✅ 方案 2：在脚本中添加注释
# enemy_config.gd
@export var gold_drop: int = 10  # 击杀掉落金钱（默认值）
@export var experience_drop: int = 5  # 击杀掉落经验（默认值）
```

**验证清单：**
- [ ] `.tres` 文件中没有行内注释（`#` 在字段值后）
- [ ] 所有导出字段都有正确的值
- [ ] 资源文件在 Godot 编辑器中能正确显示
- [ ] 运行游戏验证配置加载正确
- [ ] 关键配置值有单元测试覆盖

**批量检查脚本：**
```bash
# 搜索 .tres 文件中的行内注释
grep -rn "= .*  #" --include="*.tres" .

# 检查经验值配置
grep -rn "experience_drop" --include="*.tres" . | grep "#"

# 检查金币配置
grep -rn "gold_drop" --include="*.tres" . | grep "#"
```

---

## 7. 调试输出

### 7.1 输出级别选择

```gdscript
# print() - 开发阶段调试
print("[调试] 敌人数量：%d" % enemies.size())

# push_warning() - 需要注意的异常情况
push_warning("[警告] 目标不支持减速效果")

# push_error() - 严重错误
push_error("[错误] 资源加载失败：%s" % path)
```

### 7.2 生产代码规范

```gdscript
# ❌ 错误：生产代码包含调试输出
func take_damage(amount: float):
    print("受到伤害：%f" % amount)  # ❌ 应移除
    health -= amount

# ✅ 正确：使用条件编译
const DEBUG_MODE = false

func take_damage(amount: float):
    if DEBUG_MODE:
        print("受到伤害：%f" % amount)
    health -= amount

# ✅ 正确：使用 push_warning
func take_damage(amount: float):
    if health <= 0:
        push_warning("[敌人] 生命值为 0")
    health -= amount
```

---

## 8. 错误与日志处理

### 8.1 查看日志前先检查错误

**原则：** 在查看日志或调试前，先确认是否有错误发生

**检查流程：**
```bash
# 1. 先查看 Godot 错误面板
# Godot 编辑器 → Debugger → Errors 标签

# 2. 检查控制台输出
# 优先查看 ERROR 级别的输出，再查看 WARNING

# 3. 分类处理
# - ERROR: 必须立即修复
# - WARNING: 尽快修复，不影响运行时
# - INFO: 正常信息，无需处理
```

**实战案例：资源加载失败**
```
# ❌ 错误日志
ERROR: Failed loading resource: res://addons/gut/source_code_pro.fnt.
ERROR: editor/inspector/editor_preview_plugins.cpp:845 - Condition "sampled_font.is_null()" is true.

# 处理步骤：
# 1. 定位错误文件：source_code_pro.fnt.import
# 2. 检查 .import 文件是否损坏
# 3. 删除损坏的 .import 文件和缓存
# 4. 重启 Godot 重新导入
```

### 8.2 常见错误类型与处理

#### 8.2.1 资源加载错误

**错误信息：**
```
ERROR: Failed loading resource: res://path/to/resource.tres
```

**常见原因：**
- 资源文件路径错误
- 资源文件损坏
- .import 文件损坏
- UID 引用错误

**解决方案：**
```gdscript
# ✅ 推荐：加载前检查文件存在性
var resource_path = "res://resources/config.tres"
if ResourceLoader.exists(resource_path):
    var resource = load(resource_path)
    if resource:
        # 使用资源
        pass
    else:
        push_error("资源加载失败：%s" % resource_path)
else:
    push_error("资源文件不存在：%s" % resource_path)
```

#### 8.2.2 节点未找到错误

**错误信息：**
```
ERROR: Node not found: "NodeName"
```

**常见原因：**
- 节点名称拼写错误
- 节点路径错误
- 节点未添加到场景树

**预防措施：**
```gdscript
# ❌ 错误：硬编码节点名称
$Sprite2D  # 节点重命名后报错

# ✅ 正确：使用 has_node() 检查
if has_node("Sprite2D"):
    $Sprite2D.visible = true
else:
    push_warning("Sprite2D 节点未找到")

# ✅ 推荐：使用 @onready 和类型安全
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
    if sprite:
        sprite.visible = true
```

#### 8.2.3 空引用错误

**错误信息：**
```
ERROR: Attempted to access null instance
```

**常见原因：**
- 变量未初始化
- 对象已被删除
- 弱引用对象失效

**预防措施：**
```gdscript
# ✅ 推荐：始终检查空值
var target: Node2D = null

func process_target():
    if not target or not is_instance_valid(target):
        push_warning("目标无效")
        return
    
    # 安全使用 target
    target.position = Vector2.ZERO

# ✅ 推荐：使用 is_instance_valid()
if is_instance_valid(weak_ref_target):
    weak_ref_target.do_something()
```

#### 8.2.4 场景切换错误

**错误信息：**
```
ERROR: Attempted to access deleted scene
```

**常见原因：**
- 在信号回调中直接删除当前场景
- 场景切换时未使用延迟调用

**解决方案：**
```gdscript
# ❌ 错误：在信号回调中直接删除
func _on_button_pressed():
    get_tree().change_scene_to_file("res://scene2.tscn")
    # 可能导致崩溃

# ✅ 正确：使用 call_deferred
func _on_button_pressed():
    get_tree().change_scene_to_file.call_deferred("res://scene2.tscn")

# ✅ 推荐：先清理再切换
func _on_button_pressed():
    # 清理当前场景资源
    cleanup()
    # 延迟切换场景
    get_tree().change_scene_to_file.call_deferred("res://scene2.tscn")
```

### 8.3 日志分析最佳实践

**日志级别分类：**
```
ERROR   🔴 - 错误，必须修复
WARNING 🟡 - 警告，建议修复
INFO    🟢 - 信息，正常日志
```

**分析流程：**
1. **过滤 ERROR**：优先处理所有错误
2. **分类 WARNING**：区分严重警告和可接受警告
3. **清理 INFO**：移除生产环境的调试信息

**批量检查脚本：**
```bash
# 搜索所有 ERROR
grep -rn "push_error" --include="*.gd" .

# 搜索未处理的错误
grep -rn "# TODO.*error" --include="*.gd" .

# 检查调试输出残留
grep -rn "print\(" --include="*.gd" . | grep -v "push_"
```

---

## 9. 测试规范

### 9.1 代码更新后先自测

**原则：** 代码更新后，开发者必须先进行自测，确保基本功能正常

**自测流程：**
```
1. 编译检查
   ✅ 确保无编译错误
   ✅ 确保无警告（或仅有可接受的警告）

2. 基本功能测试
   ✅ 启动游戏，检查主菜单
   ✅ 进入核心玩法场景
   ✅ 测试主要功能（如塔的建造、攻击）
   ✅ 检查 UI 显示是否正常

3. 边界条件测试
   ✅ 测试极端情况（如资源为 0、最大敌人数量）
   ✅ 测试异常输入（如快速点击按钮）

4. 性能检查
   ✅ 检查 FPS 是否稳定
   ✅ 检查内存占用是否合理
```

**自测清单：**
- [ ] 游戏能正常启动
- [ ] 主菜单功能正常
- [ ] 核心玩法流程可运行
- [ ] 无崩溃或卡死
- [ ] 无明显的视觉错误
- [ ] 控制台无 ERROR 输出

### 9.2 重大功能使用 GUT 测试

**原则：** 重大功能、核心系统必须编写 GUT 单元测试

**什么是重大功能：**
- ✅ 核心战斗系统（伤害计算、特效触发）
- ✅ 经济系统（金币、花费、收益）
- ✅ 存档/读档系统
- ✅ 数据配置系统
- ✅ 网络同步逻辑
- ✅ 复杂的算法和逻辑

**GUT 测试示例：**
```gdscript
# test_damage_calculation.gd
extends GutTest

var DamageCalculator = load("res://scripts/systems/damage_calculator.gd")

func before_each():
    pass

func after_each():
    pass

## 测试基础伤害计算
func test_base_damage_calculation():
    var damage = DamageCalculator.calculate_base_damage(100, 1.5)
    assert_eq(damage, 150, "基础伤害计算错误")

## 测试暴击伤害
func test_critical_damage():
    var damage = DamageCalculator.calculate_critical(100, 2.0)
    assert_eq(damage, 200, "暴击伤害计算错误")

## 测试伤害衰减
func test_damage_decay():
    var damage = DamageCalculator.calculate_decay(100, 0.7, 2)
    assert_eq(damage, 49, "伤害衰减计算错误")
    assert_true(damage > 0, "衰减后伤害应为正数")

## 测试边界条件
func test_edge_cases():
    # 测试 0 值
    var damage = DamageCalculator.calculate_base_damage(0, 1.5)
    assert_eq(damage, 0, "0 基础伤害应返回 0")
    
    # 测试负数
    damage = DamageCalculator.calculate_base_damage(-100, 1.5)
    assert_eq(damage, 0, "负数伤害应返回 0")
```

**测试覆盖率要求：**
- 🔴 **核心系统**：覆盖率 ≥ 80%
- 🟡 **重要功能**：覆盖率 ≥ 60%
- 🟢 **辅助功能**：覆盖率 ≥ 40%

**测试运行：**
```bash
# 运行所有测试
GUT → Run All Tests

# 运行特定测试
GUT → Select Test → test_damage_calculation

# 命令行运行（CI/CD）
godot --headless --script res://addons/gut/gut_cmdln.gd
```

### 9.3 测试驱动开发（TDD）

**推荐流程：**
```
1. 编写测试（失败）
   ↓
2. 实现功能
   ↓
3. 运行测试（通过）
   ↓
4. 重构代码
   ↓
5. 再次运行测试（确保仍通过）
```

**TDD 示例：**
```gdscript
# 1. 先写测试（会失败）
func test_tower_cost_calculation():
    var cost = TowerConfig.get_cost("archer", 1.2)
    assert_eq(cost, 180, "弓箭塔 1 级成本应为 180")

# 2. 实现功能
func get_cost(tower_type: String, multiplier: float) -> int:
    var base_cost = get_base_cost(tower_type)
    return int(base_cost * multiplier)

# 3. 运行测试（通过）
# 4. 重构（如需要）
# 5. 再次测试（确保仍通过）
```

### 9.4 自动化测试集成

**CI/CD 流程：**
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run GUT Tests
        run: |
          godot --headless --script res://addons/gut/gut_cmdln.gd
```

**测试报告：**
- ✅ 每次提交自动运行测试
- ✅ 生成测试覆盖率报告
- ✅ 失败时通知开发者

---

## 10. 代码审查清单

### 10.1 提交前检查

**必须检查项：**
- [ ] 编译警告数量为 0（或仅有可接受的第三方警告）
- [ ] 所有除法运算都使用浮点数（`/ 2.0` 而不是 `/ 2`）
- [ ] 函数参数名不与成员变量冲突
- [ ] `.tres` 和 `.tscn` 文件中的 UID 都是正确的
- [ ] **`.tres` 文件中没有行内注释**（字段值后无 `#` 注释）🆕
- [ ] 所有警告都有注释说明（如果故意保留）
- [ ] 代码符合命名规范
- [ ] 调试代码已清理
- [ ] 已运行基本自测（启动游戏、核心功能测试）
- [ ] 重大功能已添加 GUT 测试
- [ ] 控制台无 ERROR 输出

### 10.2 批量检查脚本

**使用 Grep 搜索常见问题：**
```bash
# 搜索整数除法
grep -rn "/ 2[^.0]" --include="*.gd" .
grep -rn "/ 2$" --include="*.gd" .

# 搜索变量遮蔽
grep -rn "var target:" --include="*.gd" .
grep -rn "func.*target:" --include="*.gd" .

# 搜索枚举使用
grep -rn "emission_shape = [0-9]" --include="*.gd" .

# 搜索资源 UID
grep -rn "uid://.*_unique_id" --include="*.tres" .

# 🆕 搜索 .tres 文件中的行内注释
grep -rn "= .*  #" --include="*.tres" .
grep -rn "experience_drop.*#" --include="*.tres" .
grep -rn "gold_drop.*#" --include="*.tres" .
grep -rn "texture_path.*#" --include="*.tres" .

# 搜索 ERROR 输出
grep -rn "push_error" --include="*.gd" .

# 搜索调试输出残留
grep -rn "print\(" --include="*.gd" . | grep -v "push_"
```

### 10.3 代码审查流程

**审查步骤：**
1. **自动检查**：运行批量检查脚本
2. **手动审查**：重点检查新增代码
3. **警告清理**：确保无新增警告
4. **规范符合**：检查命名、注释等

---

## 9. 最佳实践总结

### 9.1 核心原则

1. **零警告原则**：提交前清除所有警告
2. **清晰命名**：变量名、参数名要有意义
3. **类型安全**：使用静态类型，避免隐式转换
4. **预防为主**：提前避免问题，而非事后修复

### 9.2 常见陷阱

| 问题 | 预防措施 | 检查方法 |
|------|----------|----------|
| 整数除法 | 始终使用 `/ 2.0` | `grep "/ 2[^.0]"` |
| 变量遮蔽 | 参数加前缀或后缀 | `grep "var target:"` |
| UID 错误 | 在编辑器中创建资源 | 手动检查 `.tres` 文件 |
| 枚举依赖 | 使用整数值 + 注释 | 代码审查 |
| **.tres 文件注释** 🆕 | **禁止行内注释** | `grep "= .* #" --include="*.tres"` |

### 9.3 常见错误案例

**基于实战经验的错误汇总：**

#### GDScript 错误
- ❌ **整数除法**：`5 / 2 = 2`（应为`5.0 / 2 = 2.5`）
- ❌ **变量遮蔽**：参数名与成员变量同名
- ❌ **@export 在 _init() 读取**：返回默认值而非检查器值
- ❌ **Lambda 变量捕获**：按值捕获，后续修改不影响

#### 节点系统错误
- ❌ **queue_free vs free**：free() 立即删除导致崩溃
- ❌ **场景切换删除当前场景**：应使用 call_deferred
- ❌ **add_child 后 _ready() 未调用**：需要手动初始化
- ❌ **循环引用 preload**：导致加载失败

#### 物理系统错误
- ❌ **move_and_slide 乘 delta**：已包含 delta，不应再乘
- ❌ **RigidBody 直接设置位置**：破坏物理模拟
- ❌ **CollisionShape 缩放**：应调整 shape 的 size，而非缩放节点
- ❌ **物理代码在 _process**：应在 _physics_process

#### UI 系统错误
- ❌ **修改 Container 子节点 position**：会被容器重置
- ❌ **锚点预设后未调整偏移**：需要手动计算 offset

#### 渲染系统错误
- ❌ **screen_get_scale 平台限制**：Windows 返回 1.0
- ❌ **3D 旋转使用欧拉角**：可能万向节死锁

#### 资源系统错误 🆕
- ❌ **.tres 文件行内注释**：导致字段加载失败（texture_path 为空，experience_drop 为默认值）
- ❌ **资源 UID 错误**：使用占位符 UID 而非真实 UID

### 9.4 学习资源

- [GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md) - 警告处理详细指南
- [Warning_Fix_Quick_Reference.md](./Warning_Fix_Quick_Reference.md) - 快速参考手册
- [19_Pitfall_Records.md](../19_Common_Pitfalls/19_Pitfall_Records.md) - 完整踩坑记录
- [01H_Style_Guide.md](../01_GDScript_Language/01H_Style_Guide.md) - 官方风格指南

---

## 12. Autoload 单例规范 🆕

### 12.1 禁止 class_name 声明 🔴 强制

**规则**: Autoload 脚本不得声明 `class_name`，注册名即全局标识符

**原因**: Autoload 注册名本身就是全局标识符，再声明 `class_name` 会产生命名冲突，导致 "Class 'XXX' hides an autoload singleton" 编译错误

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

### 12.2 直接名称访问 🔴 强制

**规则**: Autoload 间互访直接使用注册名称（如 `ConfigManager`），禁止 `Global.get_node("XXX")`

**原因**: Godot 4.x 中所有 Autoload 都挂载在 `/root/` 下，互为兄弟节点，不是父子关系

```gdscript
# ❌ 错误：通过 Global.get_node() 访问兄弟 Autoload
config_manager = Global.get_node("ConfigManager") as ConfigManager  # Node not found!

# ✅ 正确：直接使用 Autoload 全局名称
config_manager = ConfigManager  # Autoload 名称即全局变量
```

### 12.3 类型注解适配 🟡 建议

**规则**: 移除 class_name 后，引用 Autoload 类型的变量不写类型注解或用 `Object`

```gdscript
# ❌ 错误：Autoload 移除 class_name 后不能用作类型
var config_manager: ConfigManager  # 报错："ConfigManager" is not a type

# ✅ 正确：使用 Object 类型
var config_manager: Object = ConfigManager
```

### 12.4 枚举引用适配 🟡 建议

**规则**: 移除 class_name 后，跨脚本枚举引用需用整数值+注释替代

```gdscript
# ❌ 错误：跨脚本引用 Autoload 枚举
var current_stage: int = AgeSystem.Stage.OLD_AGE  # AgeSystem 无 class_name

# ✅ 正确：使用整数值 + 注释
var current_stage: int = 3  # Stage.OLD_AGE

# ✅ 正确：在 Autoload 中导出常量映射
const STAGE_OLD_AGE: int = 3   # Stage.OLD_AGE
```

### 12.5 保留关键字避让 🟡 建议

**规则**: 禁止使用 `trait` 等系统保留关键字作为变量名

```gdscript
# ❌ 错误：trait 是保留关键字
for trait in initial_res.traits:
    session.traits.append(trait)

# ✅ 正确：使用替代命名
for trait_item in initial_res.traits:
    session.traits.append(trait_item)
```

**详细踩坑记录**: [Godot_4x_Autoload_Pitfalls.md](../pitfall-cases/Godot_4x_Autoload_Pitfalls.md)

---

## 13. 测试编码守则 🆕

### 13.1 GUT 测试运行器模式 🔴 强制

**规则**: GUT 测试运行器必须使用 `GutConfig` + `run_tests()` 模式，禁止使用 `add_script()` + `test_scripts()` 模式

**原因**: `add_script()` + `test_scripts()` 模式在 Godot 4.x 中会导致测试框架在 `gut.gd:818 _test_the_scripts` 处无限挂起

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

### 13.2 禁止替换 Autoload 引用 🔴 强制

**规则**: 测试中禁止在 `before_each`/`after_each` 中替换 Autoload 全局引用

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

### 13.3 禁止 watch_signals Autoload 🔴 强制

**规则**: 禁止对 Autoload 单例调用 `watch_signals()`，改用基于状态的断言

```gdscript
# ❌ 错误：对 Autoload 使用 watch_signals
watch_signals(EventSystem)  # 导致 GUT 挂起！

# ✅ 正确：基于状态的断言
var session: GameSessionData = EventSystem.session
var old_gold: int = session.gold
EventSystem.select_option(event_data, gold_option)
assert_gt(session.gold, old_gold, "选择金币选项后金币应增加")
```

### 13.4 测试前校验字段名 🟡 建议

**规则**: 编写测试前必须先读取被测类源码，确认属性名和方法签名

### 13.5 GUT 测试代码审查清单

- [ ] 测试运行器使用 `GutConfig` + `run_tests()` 模式
- [ ] 没有在 `before_each`/`after_each` 中替换 Autoload 全局引用
- [ ] 没有对 Autoload 单例调用 `watch_signals()`
- [ ] 测试中引用的属性名和方法签名已与源码校验
- [ ] 涉及 Autoload 状态修改的测试有手动保存/恢复逻辑

**详细踩坑记录**: [GUT_Testing_Pitfalls.md](../pitfall-cases/GUT_Testing_Pitfalls.md)

---

## 14. 资源引用与数据一致性规范 🆕

### 14.1 删除 .tres 资源文件必须清理引用 🔴 强制

**规则**: 删除任何 `.tres` / `.resource` 文件前，必须全局搜索并清理所有引用该文件的 `ext_resource` 声明

**原因**: Godot 的 `.tres` 文件加载是原子操作——任何一个 `[ext_resource]` 找不到，整个 `.tres` 都无法加载

### 14.2 数据格式在源头统一 🔴 强制

**规则**: 数据格式转换只在数据入口处完成一次，所有消费者使用统一格式，禁止在消费者处做运行时格式转换

```gdscript
# ❌ 错误：在每个消费者处提取短名
var session_bg_short: String = session.family_background.replace("family_", "")

# ✅ 正确：在数据源统一格式
session.family_background = raw_family_id.replace("family_", "")
```

### 14.3 修改数据格式必须同步更新配置文件 🟡 建议

**规则**: 修改 session 字段或其他运行时数据格式后，必须同步检查并更新所有 JSON 配置文件中的硬编码值

### 14.4 修改数据格式完整检查清单

```
- [ ] 全局搜索字段名（含 .gd / .json / .tres / .tscn）
- [ ] 逐一确认每个引用点的兼容性
- [ ] 更新代码中的比较逻辑
- [ ] 更新 JSON 配置中的硬编码值
- [ ] 更新默认值（如 session_data.gd 的 @export 默认值）
- [ ] 更新测试用例中的测试数据
- [ ] 运行场景验证
```

**详细踩坑记录**: [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](../pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md)

---

## 15. 游戏系统实战规范 🆕

### 15.1 动态敌人管理使用 group 而非手动计数 🟡 建议

**规则**: 使用 Group 系统动态查询存活敌人数量，而非手动维护计数器

**原因**: 手动维护计数器容易遗漏分裂/召唤等动态创建的敌人，导致计数不准确，战斗结算提前弹出

```gdscript
# ❌ 错误：手动维护计数器
var _enemies_alive: int = 0

func _on_enemy_spawned():
    _enemies_alive += 1  # 分裂/召唤的敌人不会走这里

# ✅ 正确：使用 group 动态查询
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

### 15.2 缓存节点引用必须同步清理 🔴 强制

**规则**: 节点被 queue_free() 时，必须从所有缓存字典/数组中移除引用；访问缓存引用前必须用 `is_instance_valid()` 检查

**原因**: 字典/数组中保留已释放节点的引用会导致 `Trying to assign invalid previously freed instance` 报错

```gdscript
# ❌ 错误：直接用 [] 访问字典，节点已 freed 时赋值报错
var tower: Tower = built_towers[key]  # freed instance 报错！

# ✅ 正确：使用 .get() 获取引用，先检查 is_instance_valid() 再类型转换
var tower_ref = built_towers.get(key)
if is_instance_valid(tower_ref):
    var tower: Tower = tower_ref as Tower
    tower.do_something()

# ✅ 节点释放时同步清理
func _on_tower_destroyed(tower: Tower) -> void:
    var key: String = _get_tower_key(tower)
    built_towers.erase(key)
```

**核心要点**:
- 使用 `.get()` 而非 `[]` 访问字典，避免赋值时触发 freed instance 错误
- 节点被 queue_free() 时，必须从所有缓存容器中移除引用
- 访问缓存引用前必须用 `is_instance_valid()` 检查

### 15.3 悬浮 UI 组件设置 mouse_filter=IGNORE 🟡 建议

**规则**: Tooltip、弹窗等悬浮组件及其子节点应设置 `mouse_filter = MOUSE_FILTER_IGNORE`

**原因**: 悬浮组件遮挡触发元素会导致 MOUSE_EXIT/MOUSE_ENTER 循环闪烁

```gdscript
# ✅ 正确：tooltip 及其所有子节点设置 mouse_filter = IGNORE
func _create_tooltip(text: String) -> PanelContainer:
    var tooltip: PanelContainer = PanelContainer.new()
    tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var label: Label = Label.new()
    label.text = text
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 子节点也必须设置
    tooltip.add_child(label)
    return tooltip
```

### 15.4 位移效果与常规移动互斥 🟡 建议

**规则**: 击退、拉拽等位移效果执行期间，跳过常规路径移动

**原因**: 位移效果直接修改 global_position，与路径移动同时执行会导致位置冲突

```gdscript
# ✅ 正确：使用状态标志控制互斥
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

### 15.5 场景切换逻辑统一入口 🔴 强制

**规则**: 场景切换逻辑必须统一入口，避免多处独立实现相同功能导致绕过

**原因**: 多处独立实现场景切换会导致修改某一处时另一处不受影响，UI不更新

```gdscript
# ❌ 错误：map_manager 中独立实现场景切换，绕过了 result_ui.gd
func _show_battle_result():
    var panel = Panel.new()
    await get_tree().create_timer(2.5).timeout
    GameState.change_state(State.STAGE)  # 绕过了 result_ui.gd！

# ✅ 正确：统一入口，让 result_ui.gd 处理完整结算
func _show_battle_result():
    GameState.change_state(State.RESULT)  # 由 result_ui.gd 处理完整结算
```

### 15.6 不同阶段奖励数据分开存储 🟡 建议

**规则**: 不同阶段（事件选择、战斗结算等）的奖励数据必须分开存储和展示

**原因**: 混合存储会导致跨阶段重复显示奖励

```gdscript
# ✅ 正确：每个阶段使用独立的数据字段
var last_event_traits: Array = []      # 事件选择阶段奖励
var last_event_towers: Array = []      # 事件选择阶段奖励
var last_battle_rewards: Dictionary = {} # 战斗阶段奖励

# result_ui.gd - 战斗结算只读取战斗奖励
func _show_battle_result():
    var rewards: Dictionary = session.last_battle_rewards
    var gold: int = rewards.get("gold", 0)
    _add_gold_display(gold)
```

### 15.7 效果格式化按 type 读取对应字段 🟡 建议

**规则**: 效果格式化函数必须根据 effect type 读取对应字段，不能假设所有效果都用 value 字段

**原因**: 不同类型的词条效果可能使用不同的字段名存储数值

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

### 15.8 游戏系统代码审查清单

- [ ] 敌人管理使用 group 动态查询，而非手动计数器
- [ ] 分裂/召唤的敌人正确加入 group 并连接生命周期信号
- [ ] 缓存节点引用的字典/数组在节点释放时同步清理
- [ ] 访问缓存引用前使用 `is_instance_valid()` 检查
- [ ] 使用 `.get()` 而非 `[]` 访问字典
- [ ] 悬浮 UI 组件设置 `mouse_filter = MOUSE_FILTER_IGNORE`
- [ ] 位移效果与常规移动逻辑互斥
- [ ] 场景切换逻辑统一入口
- [ ] 不同阶段的奖励数据分开存储
- [ ] 效果格式化函数按 type 读取对应字段
- [ ] UI计数显示使用"剩余/最大"格式 🆕
- [ ] 不可用选项变灰禁用而非消失 🆕
- [ ] 变量命名不与GDScript内置标识符冲突 🆕
- [ ] 调试前先确认"正确行为"定义 🆕

### 15.9 UI计数显示使用"剩余/最大"格式 🟡 建议

**规则**: 有数量限制的UI元素，优先显示"剩余可用数/最大数"而非"已使用数/最大数"；已用完的选项应变灰禁用(disabled + modulate)，而非从界面移除

**原因**: "还可以放几个"比"已经放了几个"更符合用户心智模型；选项消失会让用户困惑"之前能选的选项去哪了"

```gdscript
# ❌ 错误：显示"已放置/最大"，语义与用户心智模型不符
var tower_placed: int = get_tree().get_nodes_in_group("towers").size()
count_label.text = "%d/%d" % [tower_placed, tower_max]
# 结果：0/1, 0/2 → 用户理解为"0个可用"

# ✅ 正确：显示"剩余可放/最大"，语义与用户心智模型一致
var tower_placed: int = get_tree().get_nodes_in_group("towers").size()
var tower_remaining: int = tower_max - tower_placed
count_label.text = "%d/%d" % [tower_remaining, tower_max]
# 结果：1/1, 2/2 → 用户理解为"还能放1个，总共1个位置"

# ❌ 错误：放满的塔从列表中移除
func load_tower_configs() -> void:
    for tower_config in tower_configs:
        var placed: int = _get_placed_count(tower_config.tower_id)
        if placed < tower_config.max_count:  # 放满的塔不加入列表
            _add_tower_button(tower_config)

# ✅ 正确：所有塔始终显示，已满的塔变灰禁用
func load_tower_configs() -> void:
    for tower_config in tower_configs:
        var placed: int = _get_placed_count(tower_config.tower_id)
        var is_full: bool = placed >= tower_config.max_count
        var button: Button = _add_tower_button(tower_config)
        if is_full:
            button.disabled = true           # 禁用按钮
            button.modulate = Color(0.5, 0.5, 0.5, 1.0)  # 变灰
```

**踩坑记录**: [§47 UI计数显示语义错误](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#47-ui计数显示语义错误已放置最大vs剩余可放最大-🟡-中) | [§49 已满的塔从UI消失而非变灰](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#49-已满的塔从ui消失而非变灰-🟡-中)

### 15.10 调试前确认"正确行为"定义 🟡 建议

**规则**: 调试bug时先确认"正确行为"的定义，避免在正确的逻辑上反复修改。先问清楚"期望显示什么"再动手

**原因**: 如果对"正确行为"的理解有误，会在正确的逻辑上反复修改，浪费大量调试时间

```gdscript
# ❌ 错误的调试方向：反复修改正确的计数逻辑
# 用户反馈"显示0/1不对" → 开发者认为是计数逻辑问题
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

**踩坑记录**: [§50 调试误判——在正确的逻辑上反复修改](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#50-调试误判在正确的逻辑上反复修改-🟢-低)

**详细踩坑记录**: [Godot_4x_Game_System_Pitfalls.md](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md)

---

## 16. 战斗系统与效果规范 🆕

### 16.1 暴击=伤害倍率而非额外伤害实例 🔴 强制

**规则**: CRIT类特效必须在攻击流程中判定为伤害倍率，通过is_crit参数控制UI显示。禁止在effect_system中单独调用take_damage造成额外伤害实例

**原因**: 暴击作为额外伤害实例时，加上弹道基础伤害，总伤害=base*(1+multiplier)而非设计意图的base*multiplier，且1次攻击出现2-3个伤害数字

```gdscript
# ❌ 错误：暴击作为额外伤害实例
func _apply_crit(source_tower: Tower, target: Node2D, multiplier: float) -> void:
    var crit_damage: float = base_damage * multiplier
    target.take_damage(crit_damage)  # 额外伤害实例！

# ✅ 正确：暴击作为伤害倍率，在攻击流程中判定
func _on_projectile_hit(target: Node2D) -> void:
    var final_damage: float = base_damage
    var is_crit: bool = _check_crit()
    if is_crit:
        final_damage *= crit_multiplier
    target.take_damage(final_damage, is_crit)
```

**踩坑记录**: [§81 暴击特效不应作为额外伤害实例](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#81-暴击特效不应作为额外伤害实例-🔴-高)

### 16.2 debuff效果验证 🟡 建议

**规则**: 添加新的状态效果（如debuff/slow/armor_break）时，必须验证效果值在take_damage中被实际使用，避免"设置了但不生效"的情况

**原因**: apply_debuff设置了debuff_amount，但take_damage中从未读取该值来降低抗性，导致效果完全不生效

```gdscript
# ❌ 错误：debuff_amount设置了但未使用
func apply_debuff(amount: float) -> void:
    debuff_amount = amount  # 设置了

func take_damage(amount: float, is_crit: bool = false) -> void:
    var resistance: float = maxf(0.0, resistance - armor_break_amount)  # 没读debuff！

# ✅ 正确：在take_damage中将debuff_amount加入抗性计算
func take_damage(amount: float, is_crit: bool = false) -> void:
    var resistance: float = maxf(0.0, resistance - armor_break_amount - debuff_amount)
```

**踩坑记录**: [§82 debuff_amount设置但未使用导致效果不生效](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#82-debuff_amount设置但未使用导致效果不生效-🟡-中)

### 16.3 翻译键一致性 🔴 强制

**规则**: 代码中使用的tr()键名必须与translations.csv中完全一致，包括大小写和后缀。新增翻译键时必须同步更新CSV文件

**原因**: 键名不匹配时tr()返回键名本身，后续%格式化因无占位符而报错 "not all arguments converted"

```gdscript
# ❌ 错误：翻译键与CSV不匹配
var text: String = tr("ENEMY_DEBUFFED") % [slow_amount, slow_timer]  # CSV中只有ENEMY_DEBUFF

# ✅ 正确：确保键名完全一致
var text: String = tr("ENEMY_DEBUFF") % [slow_amount, slow_timer]
```

**踩坑记录**: [§83 翻译键不匹配导致格式化报错](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#83-翻译键不匹配导致格式化报错-🔴-高)

### 16.4 状态机回调防护 🔴 强制

**规则**: UI回调中切换GameState状态前，必须检查当前状态是否已被其他逻辑修改（如健康归零触发ENDING），避免覆盖

**原因**: event_ui.gd选项回调中不检查当前状态就强制切换到STAGE，覆盖了_check_health_depleted设置的ENDING状态

```gdscript
# ❌ 错误：回调中不检查当前状态就切换
func _on_option_selected(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)
    GameState.change_state(State.STAGE)  # 可能覆盖ENDING状态！

# ✅ 正确：回调中先检查当前状态
func _on_option_selected(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)
    if GameState.current_state == GameState.State.ENDING:
        return  # 终局状态已被设置，不覆盖
    GameState.change_state(State.STAGE)
```

**踩坑记录**: [§84 终局状态机被UI回调覆盖](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#84-终局状态机被ui回调覆盖-🔴-高)

### 16.5 ParticleProcessMaterial颜色设置 🟡 建议

**规则**: 优先使用`process_mat.color`设置纯色粒子；需要渐变时必须用`GradientTexture1D`包装Gradient对象

**原因**: `color_ramp`属性需要`Texture2D`类型，不能直接赋值`Gradient`对象

```gdscript
# ❌ 错误：直接赋值Gradient对象
var gradient: Gradient = Gradient.new()
process_mat.color_ramp = gradient  # 类型错误！color_ramp需要Texture2D

# ✅ 正确：用GradientTexture1D包装
var gradient: Gradient = Gradient.new()
var gradient_tex: GradientTexture1D = GradientTexture1D.new()
gradient_tex.gradient = gradient
process_mat.color_ramp = gradient_tex

# ✅ 正确：纯色粒子直接用color属性
process_mat.color = Color(1.0, 0.3, 0.3)
```

**踩坑记录**: [§85 ParticleProcessMaterial.color_ramp类型限制](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md#85-particleprocessmaterialcolor_ramp类型限制-🟡-中)

### 16.6 战斗系统代码审查清单

- [ ] 暴击效果作为伤害倍率处理，不是额外伤害实例
- [ ] effect_system的execute_effects跳过CRIT类型
- [ ] take_damage中正确使用所有抗性降低值（armor_break + debuff）
- [ ] 新增状态效果时验证效果值在伤害计算中被实际使用
- [ ] tr()键名与translations.csv完全一致
- [ ] UI回调中切换状态前检查当前状态
- [ ] ParticleProcessMaterial渐变色使用GradientTexture1D包装

**详细踩坑记录**: [Godot_4x_Game_System_Pitfalls.md](../pitfall-cases/Godot_4x_Game_System_Pitfalls.md)

---

**文档说明：**
本规范基于实际项目中的经验教训整理，旨在建立统一的代码标准，提高代码质量和可维护性。

**最后更新：** 2026-04-22 | **版本：** 2.2

**实战统计：**
- 整数除法：修复 11 处
- 变量遮蔽：修复 4 处
- 枚举问题：修复 2 处
- 资源 UID：修复 2 处
- **.tres 文件注释**：修复 2 处
- GUT 字体错误：修复 1 处
- **暴击/debuff/翻译键/状态机/粒子材质**：修复 5 处 🆕
- **总计：基于 30+ 处实际修复经验**

**新增内容（版本 2.2）：**
- ✅ **战斗系统与效果规范章节**（暴击/debuff/翻译键/状态机/粒子材质）🆕
- ✅ 整合 §81-§85 踩坑记录的规范提炼
