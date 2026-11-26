# GDScript 代码规范

> **适用版本**: Godot 4.x（4.6+）  
> **来源**: [Base 层 - GDScript_Code_Standards.md](../../base/practical-experiences/code-standards/GDScript_Code_Standards.md)  
> **重要性**: 🔴 必读 - 所有 GDScript 代码必须遵循
> **说明**: 本文档为概念层摘要，章节编号已简化。完整编号体系请参考 [Base 层 - GDScript 代码规范](../../base/practical-experiences/code-standards/GDScript_Code_Standards.md)

---

## 📋 简介

本文档整理了 Godot 4.x GDScript 开发的完整代码规范标准，基于实战经验总结而成。遵循这些规范可以编写出更清晰、更高效、更易维护的代码。

---

## 🎯 核心原则

### 1. 警告处理原则

**优先级分级：**

| 级别 | 类型 | 处理要求 | 示例 |
|------|------|----------|------|
| 🔴 **高** | 类型安全警告 | **必须修复** | 类型转换、空值检查 |
| 🟡 **中** | 代码质量警告 | **建议修复** | 变量遮蔽、未使用变量 |
| 🟢 **低** | 兼容性警告 | **酌情修复** | 枚举值不匹配（已注释） |

**核心目标：**
- ✅ **零警告原则**：提交前确保编译警告数量为 0
- ✅ **可读性优先**：代码应清晰易懂，避免歧义
- ✅ **预防性编程**：提前避免常见问题，而非事后修复

---

## 📝 命名规范

### 1. 变量命名

#### 1.1 类成员变量 vs 函数参数

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

#### 1.2 推荐命名模式

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

### 2. 常量和枚举

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

## 🔢 变量与常量

### 1. 整数除法规范

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

**批量检查模式：**
搜索正则：`/ 2[^.0]` 或 `/ 2$`

### 2. 显性声明变量类型

**规则级别**: 🟡 建议 (强烈推荐) → 🔴 强制 (项目代码生成)

**核心要求**: 所有变量、数组、字典必须显式声明静态类型

#### 基础类型声明

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

#### 类型推断 (推荐用法)

```gdscript
# ✅ 推荐：使用 := 进行类型推断 (简洁且类型明确)
var health := 100        # 推断为 int
var speed := 5.5         # 推断为 float
var name := "Player"     # 推断为 String

# ⚠️ 踩坑点：:= 推断后类型固定，不能赋其他类型的值
var count := 0
count = "text"  # ❌ 错误！类型不匹配
```

#### 数组和字典类型声明

```gdscript
# ✅ 推荐：类型化数组
var scores: Array[int] = [10, 20, 30]
var enemies: Array[Enemy] = []

# ✅ 推荐：类型化字典
var config: Dictionary = {"health": 100, "speed": 5.0}
var typed_dict: Dictionary[String, int] = {"health": 100}

# ❌ 避免：非类型化数组/字典
var enemies = []  # 类型不明确
var config = {}   # 类型不明确
```

#### 函数参数和返回值类型

```gdscript
# ✅ 推荐：参数和返回值都有类型注解
func attack(target: Node2D, damage: int) -> bool:
    return true

func get_health() -> int:
    return health

# ❌ 避免：无类型注解
func attack(target, damage):  # 类型不明确
    pass
```

#### 类型转换

```gdscript
# ✅ 推荐：显式类型转换
var int_value: int = 42.7 as int
var float_value: float = 42
var half: float = 5 / 2.0  # 2.5

# ✅ 使用 as 进行安全转换
var node = get_node("Sprite")
var sprite = node as Sprite2D
if sprite:
    # 安全使用
    pass

# ⚠️ 踩坑点：整数除法
var half_wrong: int = 5 / 2  # 2 ❌
var half_correct: float = 5 / 2.0  # 2.5 ✅
```

#### 使用 as 声明自定义类型

**规则**: 对于自定义类类型，必须使用 `as` 关键字进行显式类型声明

```gdscript
# ✅ 推荐：从节点获取自定义脚本
var tower := $TowerNode as TowerScript
var enemy := get_node("Enemy") as EnemyScript

# ✅ 推荐：从信号回调中获取
func _on_area_entered(area: Area2D):
    var projectile := area as ProjectileScript
    if projectile:
        projectile.explode()

# ✅ 推荐：从数组中获取
for enemy_node in enemies:
    var enemy := enemy_node as EnemyScript
    if enemy:
        enemy.take_damage(10)

# ✅ 推荐：is + as 组合检查
func process_target(target: Node):
    if target is TowerScript:
        var tower := target as TowerScript
        tower.attack()

# ❌ 避免：不使用 as，类型不明确
var tower = $TowerNode  # 类型不明确
```

**⚠️ 踩坑点**:
- `as` 转换失败返回 `null`，不会报错
- 使用 `as` 后必须检查是否为 `null`
- 关键代码使用 `is` 先检查再转换

详细文档：[GDScript 静态类型指南](../guides/gdscript-static-typing.md#7-类型转换)

### 3. 内嵌 set/get 函数规范 🆕

**使用场景**：当变量修改时需要自动触发额外逻辑（如更新 UI、触发事件、数据验证等），应优先使用内嵌 set/get 函数

**核心优势**：
- ✅ **自动触发**：无需手动调用更新函数
- ✅ **集中管理**：所有修改逻辑在一处维护
- ✅ **类型安全**：配合静态类型，确保类型正确
- ✅ **数据验证**：可以在 set 中进行数据校验
- ✅ **代码简洁**：调用方无需关心内部逻辑

#### 3.1 基础语法

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

#### 3.2 实战应用场景

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

# 使用示例
func take_damage(amount: int):
	hp -= amount  # 自动触发 UI 更新，无需手动调用
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
```

#### 3.3 注意事项

**⚠️ 避免在 setter 中产生副作用**
```gdscript
# ❌ 错误：setter 中不应有复杂逻辑
var score: int = 0:
	set(new_score):
		score = new_score
		update_ui()  # ✅ 可以
		save_to_disk()  # ❌ 不应该在 setter 中保存
		send_network_request()  # ❌ 不应该网络请求
	get:
		return score

# ✅ 正确：setter 只处理必要的更新
var score: int = 0:
	set(new_score):
		score = max(0, new_score)  # 数据验证
		update_score_ui()  # UI 更新
	get:
		return score
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

#### 3.4 与@export 配合使用

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
```

#### 3.5 内嵌 get/set 使用场景与常见错误 🆕

**核心要点**：内嵌 get/set 有两种主要使用场景——**独立状态**和**包装属性**。错误的使用方式会导致状态不一致、冗余赋值等问题。

##### 3.5.1 场景 1：独立状态 (Independent State)

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

##### 3.5.2 场景 2：包装已有属性 (Property Wrapper)

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

##### 3.5.3 常见错误与踩坑

[§26 内嵌 get/set 创建双重状态](../guides/common-pitfalls.md#26-内嵌-getset-创建双重状态--高)

##### 3.5.4 使用场景对比表

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

##### 3.5.5 最佳实践

1. **明确属性类型**：先判断是独立状态还是包装属性
   - 问自己：这个变量有底层对应属性吗？
   - 有 → 包装属性；没有 → 独立状态

2. **独立状态**：setter 中自赋值，getter 返回自身
3. **包装属性**：setter 设置底层属性，getter 返回底层属性
4. **避免直接访问**：使用包装属性时，不要直接访问底层属性
5. **状态一致性**：确保包装属性和底层属性始终同步

**检查清单**：
- [ ] 正确区分独立状态和包装属性
- [ ] 独立状态使用自赋值，包装属性设置底层属性
- [ ] getter 返回正确的值（自身 vs 底层属性）
- [ ] 没有创建双重状态
- [ ] 避免了直接访问底层属性（包装属性场景）
- [ ] 状态始终保持一致

详细文档：[Base 层 - GDScript 代码规范](../../base/practical-experiences/code-standards/GDScript_Code_Standards.md#34-内嵌-getset-使用场景与常见错误-)

---

## 📦 函数规范

### 1. 参数命名

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

### 2. 返回值处理

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

## 🔀 枚举处理

### 版本兼容性

**问题：** Godot 不同版本间枚举值可能变化

```gdscript
# ❌ 直接使用枚举常量（版本兼容性问题）
material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT

# ✅ 使用直接整数值 + 详细注释
# Godot 4.x 发射形状值：
# 0 = POINT (点)
# 1 = SPHERE (球体)
# 2 = BOX (盒子)
# 3 = RING (环)
# 4 = CIRCLE (圆形)
# 5 = POINT_TEXTURE (点纹理)

match particle_emission_shape:
    0:  # 点
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

**最佳实践：**
1. 使用整数值避免版本依赖
2. 添加详细注释说明映射关系
3. 在配置文件中集中管理枚举映射

---

## 📦 资源管理

### 1. Preload vs Load

```gdscript
# ✅ 推荐：编译时加载（性能更好）
const EnemyScene = preload("res://scenes/enemy.tscn")

# ✅ 推荐：运行时加载（动态加载）
var scene = load("res://scenes/enemy.tscn")
```

### 2. 资源 UID

```gdscript
# ❌ 错误：手动编写 UID 可能无效
var resource = load("uid://invalid_uid")

# ✅ 正确：使用 Godot 自动生成的真实 UID
# 在 Godot 编辑器中保存资源时会自动生成 UID
```

---

## 🐛 调试输出

### 日志分级

```gdscript
# 错误（必须修复的问题）
push_error("[Tower] 目标不存在")

# 警告（需要注意的问题）
push_warning("[Tower] 目标不支持攻击效果")

# 信息（正常流程）
print("[Tower] 攻击目标：%s" % target.name)

# 调试（仅开发环境）
if OS.is_debug_build():
    print("[DEBUG] Tower 状态：%s" % state)
```

---

## 🔧 Autoload 单例编码规范 🆕

### 1. 禁止 class_name 声明 🔴 强制

[§27 Autoload 脚本禁止 class_name 声明](../guides/common-pitfalls.md#27-autoload-脚本禁止-class_name-声明)

### 2. 直接名称访问 🔴 强制

[§28 Autoload 单例间互访不能用 Global.get_node()](../guides/common-pitfalls.md#28-autoload-单例间互访不能用-globalget_node)

### 3. 类型注解适配 🟡 建议

移除 class_name 后，Autoload 名称不再是类型标识符，不能用于类型注解。

```gdscript
# ❌ 错误：Autoload 移除 class_name 后不能用作类型
var config_manager: ConfigManager  # 报错

# ✅ 正确：使用 Object 类型或不写类型注解
var config_manager: Object = ConfigManager
var config_manager = ConfigManager
```

### 4. 枚举引用适配 🟡 建议

移除 class_name 后，跨脚本枚举引用需用整数值+注释或常量映射替代。

```gdscript
# ❌ 错误：跨脚本引用 Autoload 枚举
var current_stage: int = AgeSystem.Stage.OLD_AGE  # AgeSystem 无 class_name

# ✅ 正确：使用整数值 + 注释
var current_stage: int = 3  # Stage.OLD_AGE

# ✅ 正确：在 Autoload 中导出常量映射
const STAGE_OLD_AGE: int = 3   # Stage.OLD_AGE
# 其他脚本中使用
var current_stage: int = AgeSystem.STAGE_OLD_AGE
```

### 5. 保留关键字避让 🟡 建议

[§29 trait 是 GDScript 4.x 保留关键字](../guides/common-pitfalls.md#29-trait-是-gdscript-4x-保留关键字)

---

## 🧪 测试编码守则 🆕

### 1. GUT 测试运行器模式 🔴 强制

[§32 GUT 测试运行器模式导致框架挂起](../../outline/Godot%20编码规范汇总.md#131-gut-测试运行器模式--强制)

<a id="2-禁止替换-autoload-引用--强制"></a>

### 2. Autoload 会话引用与重置

[§33 before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起](../../outline/Godot%20编码规范汇总.md#132-autoload-会话引用与重置)

<a id="3-禁止-watch_signals-autoload--强制"></a>

### 3. Autoload 信号测试

[§34 watch_signals() 在 Autoload 实例上导致 GUT 挂起](../../outline/Godot%20编码规范汇总.md#133-autoload-信号测试)

### 4. 测试前校验字段名 🟡 建议

[§35 测试中引用了不存在的类属性](../../outline/Godot%20编码规范汇总.md#134-测试前校验字段名--建议)

### 5. Autoload 测试字段恢复 🟡 建议

[查看项目规范](../../outline/Godot%20编码规范汇总.md#135-autoload-测试字段恢复--建议)

### 6. GUT 测试代码审查清单

[查看项目规范](../../outline/Godot%20编码规范汇总.md#136-gut-测试代码审查清单)

---

## 📦 资源引用与数据一致性规范 🆕

### 14.1 删除 .tres 资源文件必须清理引用 🔴 强制

[§37 .tres 文件 ext_resource 引用已删除文件导致整体加载失败](../guides/common-pitfalls.md#37-tres-文件-ext_resource-引用已删除文件导致整体加载失败--高)

### 14.2 数据格式在源头统一 🔴 强制

[§38 数据格式不一致导致条件判断永远失败](../guides/common-pitfalls.md#38-数据格式不一致导致条件判断永远失败--中)

### 14.3 修改数据格式必须同步更新配置文件 🟡 建议

[§39 修改数据格式时遗漏配置文件消费者](../guides/common-pitfalls.md#39-修改数据格式时遗漏配置文件消费者--中)

### 14.4 修改数据格式完整检查清单

[§39 修改数据格式时遗漏配置文件消费者](../guides/common-pitfalls.md#39-修改数据格式时遗漏配置文件消费者--中)

---

## 🎮 游戏系统实战规范 🆕

### 15.1 动态敌人管理使用 group 而非手动计数 🟡 建议

[§42 分裂/召唤敌人未被计入存活数](../guides/common-pitfalls.md#42-分裂召唤敌人未被计入存活数--中)

### 15.2 缓存节点引用必须同步清理 🔴 强制

[§43 字典中保留已释放节点引用导致freed instance报错](../guides/common-pitfalls.md#43-字典中保留已释放节点引用导致freed-instance报错--高)

### 15.3 悬浮 UI 组件设置 mouse_filter=IGNORE 🟡 建议

[§40 Tooltip遮挡触发元素导致闪烁循环](../guides/common-pitfalls.md#40-tooltip遮挡触发元素导致闪烁循环--中)

### 15.4 位移效果与常规移动互斥 🟡 建议

[§44 击退效果与路径移动冲突](../guides/common-pitfalls.md#44-击退效果与路径移动冲突--中)

### 15.5 场景切换逻辑统一入口 🔴 强制

[§41 场景切换绕过导致UI不更新](../guides/common-pitfalls.md#41-场景切换绕过导致ui不更新--高)

### 15.6 不同阶段奖励数据分开存储 🟡 建议

[§45 事件/战斗奖励重复显示](../guides/common-pitfalls.md#45-事件战斗奖励重复显示--中)

### 15.7 效果格式化按 type 读取对应字段 🟡 建议

[§46 词条效果字段名不一致](../guides/common-pitfalls.md#46-词条效果字段名不一致--中)

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

[§47 UI计数显示语义错误——"已放置/最大"vs"剩余可放/最大"](../guides/common-pitfalls.md#47-ui计数显示语义错误已放置最大vs剩余可放最大--中) · [§49 已满的塔从UI消失而非变灰](../guides/common-pitfalls.md#49-已满的塔从ui消失而非变灰--中)

### 15.10 调试前确认"正确行为"定义 🟡 建议

[§50 调试误判——在正确的逻辑上反复修改](../guides/common-pitfalls.md#50-调试误判在正确的逻辑上反复修改--低)

---

## 🌳 场景树与路径系统规范 🆕

### 16.1 修改代码前必须确认实际调用路径 🔴 强制

[§56 实际生成路径可能与预期不同](../guides/common-pitfalls.md#56-实际生成路径可能与预期不同--中)

### 16.2 可能触发场景切换的调用后必须检查is_inside_tree() 🔴 强制

[§51 节点被移出场景树后调用get_node_or_null报错](../guides/common-pitfalls.md#51-节点被移出场景树后调用get_node_or_null报错--高)

### 16.3 不要以对象实例作为Dictionary的key 🔴 强制

[§52 以freed对象为key的Dictionary遍历崩溃](../guides/common-pitfalls.md#52-以freed对象为key的dictionary遍历崩溃--高)

### 16.4 路径偏移必须一次性应用到所有路径点 🔴 强制

[§53 怪物路径偏移不能用侧向力实现](../guides/common-pitfalls.md#53-怪物路径偏移不能用侧向力实现--中)

### 16.5 Dictionary值判断用.get()而非.has() 🟡 建议

[§57 Dictionary.has()对null值返回true](../guides/common-pitfalls.md#57-dictionaryhas对null值返回true--中)

### 16.6 场景树与路径系统代码审查清单

- [ ] 修改代码前用Grep搜索确认实际调用路径
- [ ] 可能触发场景切换的调用后检查`is_inside_tree()`
- [ ] 不以对象实例作为Dictionary的key
- [ ] 路径偏移在`set_path()`时一次性应用
- [ ] Dictionary值判断用`.get() is ExpectedType`而非`.has()`
- [ ] 分裂/召唤子怪的路径偏移叠加父怪偏移
- [ ] 怪出生时`current_path_index`从1开始

**详细踩坑记录**: [Godot_4x_Game_System_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md)

---

## ⚔️ 战斗系统与效果规范 🆕

### 暴击=伤害倍率而非额外伤害实例 🔴 强制

[§81 暴击特效不应作为额外伤害实例](../guides/common-pitfalls.md#81-暴击特效不应作为额外伤害实例--高)

### debuff效果验证 🟡 建议

[§82 debuff_amount设置但未使用导致效果不生效](../guides/common-pitfalls.md#82-debuff_amount设置但未使用导致效果不生效--中)

### 翻译键一致性 🔴 强制

[§83 翻译键不匹配导致格式化报错](../guides/common-pitfalls.md#83-翻译键不匹配导致格式化报错--高)

### 状态机回调防护 🔴 强制

[§84 终局状态机被UI回调覆盖](../guides/common-pitfalls.md#84-终局状态机被ui回调覆盖--高)

### ParticleProcessMaterial颜色设置 🟡 建议

[§85 ParticleProcessMaterial.color_ramp类型限制](../guides/common-pitfalls.md#85-particleprocessmaterialcolor_ramp类型限制--中)

---

## ✅ 代码审查清单

在提交代码前，检查以下项目：

### 命名规范
- [ ] 函数参数名未与成员变量同名
- [ ] 变量名具有描述性
- [ ] 常量使用大写命名
- [ ] 变量命名未与GDScript内置标识符冲突 🆕

### 类型安全
- [ ] 所有变量都有类型声明
- [ ] 数组和字典明确了类型
- [ ] 除法运算使用了浮点数

### 代码质量
- [ ] 没有未使用的变量
- [ ] 没有忽略返回值
- [ ] 没有变量遮蔽问题

### 资源管理
- [ ] 优先使用 preload
- [ ] UID 是 Godot 自动生成的
- [ ] 资源路径正确
- [ ] 删除 .tres 前已清理 ext_resource 引用

### 数据一致性
- [ ] 数据格式在源头统一
- [ ] 修改数据格式后同步更新了 JSON 配置
- [ ] 全局搜索确认所有引用点兼容

### 游戏系统 🆕
- [ ] 敌人管理使用 group 动态查询
- [ ] 缓存节点引用在释放时同步清理
- [ ] 悬浮 UI 组件设置 mouse_filter = IGNORE
- [ ] 位移效果与常规移动互斥
- [ ] 场景切换逻辑统一入口
- [ ] 不同阶段奖励数据分开存储
- [ ] 效果格式化按 type 读取对应字段
- [ ] UI计数显示使用"剩余/最大"格式
- [ ] 不可用选项变灰禁用而非消失
- [ ] 调试前先确认"正确行为"定义

### 场景树与路径系统 🆕
- [ ] 修改代码前用Grep搜索确认实际调用路径
- [ ] 可能触发场景切换的调用后检查`is_inside_tree()`
- [ ] 不以对象实例作为Dictionary的key
- [ ] 路径偏移在`set_path()`时一次性应用
- [ ] Dictionary值判断用`.get() is ExpectedType`而非`.has()`
- [ ] 分裂/召唤子怪的路径偏移叠加父怪偏移
- [ ] 怪出生时`current_path_index`从1开始

### 战斗系统与效果 🆕
- [ ] 暴击效果作为伤害倍率处理，不是额外伤害实例
- [ ] effect_system的execute_effects跳过CRIT类型
- [ ] take_damage中正确使用所有抗性降低值（armor_break + debuff）
- [ ] 新增状态效果时验证效果值在伤害计算中被实际使用
- [ ] tr()键名与translations.csv完全一致
- [ ] UI回调中切换状态前检查当前状态
- [ ] ParticleProcessMaterial渐变色使用GradientTexture1D包装
- [ ] 纯色粒子优先使用process_mat.color

### 调试输出
- [ ] 使用了合适的日志级别
- [ ] 调试输出在发布版本中禁用
- [ ] 日志信息清晰有意义

---

## 📚 相关资源

### Base 层资料来源
- [GDScript_Code_Standards.md](../../base/practical-experiences/code-standards/GDScript_Code_Standards.md) - 完整代码规范标准

### 踩坑记录
- [GDScript 警告处理最佳实践](../../base/practical-experiences/pitfall-cases/GDScript_Warning_Best_Practices.md)
- [19 个常见踩坑记录](../../base/practical-experiences/pitfall-cases/19_Pitfall_Records.md)
- [GUT 测试框架踩坑](../../base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md) 🆕

### Wiki 层相关页面
- [常见踩坑避雷指南](../guides/common-pitfalls.md)
- [性能优化实战指南](../guides/performance-optimization-guide.md)

---

**最后更新**: 2026-04-22  
**维护者**: Knowledge Base Administrator  
**来源**: tower_defense 项目实战经验
