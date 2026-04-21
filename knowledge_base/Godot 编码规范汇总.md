# Godot 4.x GDScript 编码规范汇总

> **适用版本**: Godot 4.x（特别是 4.6+）  
> **最后更新**: 2026-04-22（新增第 24 章 战斗系统与效果规范）
> **来源**: 知识库 Base 层 `base/practical-experiences/code-standards/`  
> **重要性**: 🔴 必读 - 所有 GDScript 代码必须遵循

---

## 📋 目录

1. [核心原则](#1-核心原则)
2. [命名规范](#2-命名规范)
   - [2.1 变量命名](#21-变量命名)
     - [2.1.1 类成员变量 vs 函数参数](#211-类成员变量-vs-函数参数)
     - [2.1.2 推荐命名模式](#212-推荐命名模式)
     - [2.1.3 变量命名禁止与内置标识符冲突](#213-变量命名禁止与内置标识符冲突-🔴-强制) 🆕
3. [变量与常量](#3-变量与常量)
   - [3.1 变量声明](#31-变量声明)
   - [3.2 常量定义](#32-常量定义)
   - [3.3 枚举使用](#33-枚举使用)
   - [3.4 内嵌 set/get 函数规范](#34-内嵌-setget-函数规范) 🆕
4. [函数规范](#4-函数规范)
5. [类型系统](#5-类型系统)
6. [资源管理](#6-资源管理)
7. [警告处理](#7-警告处理)
8. [调试与日志](#8-调试与日志)
9. [性能优化](#9-性能优化)
10. [代码审查清单](#10-代码审查清单)
11. [资源文件规范](#11-资源文件规范)
12. [Autoload 单例规范](#12-autoload-单例规范) 🆕
13. [测试编码守则](#13-测试编码守则) 🆕
14. [资源引用与数据一致性规范](#14-资源引用与数据一致性规范) 🆕
15. [游戏系统实战规范](#15-游戏系统实战规范) 🆕
16. [场景树与路径系统规范](#16-场景树与路径系统规范) 🆕
17. [GPU 计算与渲染管线规范](#17-gpu-计算与渲染管线规范) 🆕
18. [国际化(i18n)规范](#18-国际化i18n规范) 🆕
19. [GDScript编辑工作流规范](#19-gdscript编辑工作流规范) 🆕
20. [Area2D鼠标信号与交互系统规范](#20-area2d鼠标信号与交互系统规范) 🆕
21. [程序化生成图片规范](#21-程序化生成图片规范) 🆕
22. [Godot UI 程序化构建规范](#22-godot-ui-程序化构建规范) 🆕
23. [Buff系统与伤害计算规范](#23-buff系统与伤害计算规范) 🆕

---

## 1. 核心原则

### 1.1 警告处理原则

**优先级分级**:

| 级别 | 类型 | 处理要求 | 示例 |
|------|------|----------|------|
| 🔴 **高** | 类型安全警告 | **必须修复** | 类型转换、空值检查 |
| 🟡 **中** | 代码质量警告 | **建议修复** | 变量遮蔽、未使用变量 |
| 🟢 **低** | 兼容性警告 | **酌情修复** | 枚举值不匹配（已注释） |

**核心目标**:
- ✅ **零警告原则**: 提交前确保编译警告数量为 0
- ✅ **可读性优先**: 代码应清晰易懂，避免歧义
- ✅ **预防性编程**: 提前避免常见问题，而非事后修复

### 1.2 代码质量目标

- **可读性**: 代码应清晰易懂，避免歧义
- **可维护性**: 易于修改和扩展
- **性能**: 在可读性基础上优化性能
- **一致性**: 遵循团队统一的代码风格

---

## 2. 命名规范

### 2.1 变量命名

#### 2.1.1 类成员变量 vs 函数参数

**规则**: 函数参数名不得与类成员变量同名

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

**功能描述型**:
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

**前缀约定**:
- `m_` - 成员变量（member），如 `m_target`
- `_` - 私有变量，如 `_internal_counter`
- `{功能}_` - 功能描述，如 `slow_target`, `damage_value`

#### 2.1.3 变量命名禁止与内置标识符冲突 🔴 强制

**规则**: GDScript 局部变量、导出属性禁止使用以下内置标识符：range, color, name, size, text, type, value, key, step, count, data, result, error, input, output, object, signal, method, function, class, load, string, position, scale, rotation

**原因**: GDScript 有大量内置函数/类/常量，局部变量同名会遮蔽全局标识符，触发 `SHADOWED_GLOBAL_IDENTIFIER` 警告

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

**踩坑记录**: [§48 变量命名与GDScript内置标识符冲突](./踩坑记录完整索引.md#48-变量命名与gdscript内置标识符冲突-🟡-中)

### 2.2 函数命名

```gdscript
# ✅ 动词 + 名词：清晰表达功能
func attack_target(target: Node2D)
func apply_damage(amount: int)
func spawn_enemy(type: String)

# ✅ 布尔函数使用 is/can/has/should 前缀
func is_ready() -> bool
func can_attack() -> bool
func has_target() -> bool
func should_retreat() -> bool

# ✅ 获取/设置使用 get/set 前缀
func get_health() -> int
func set_health(value: int)
```

### 2.3 常量和信号

```gdscript
# 常量：全大写 + 下划线
const MAX_HEALTH: int = 100
const DAMAGE_MULTIPLIER: float = 1.5

# 信号：过去时或现在时
signal health_changed(new_value: int)
signal enemy_defeated(enemy: Enemy)
signal attack_started
```

---

## 3. 变量与常量

### 3.1 变量声明

```gdscript
# ✅ 必须使用类型注解
var health: int = 100
var speed: float = 5.0
var target: Node2D = null

# ✅ 使用显式类型转换
var half_size: float = size / 2.0
var int_value: int = float_value as int

# ❌ 避免隐式类型
var health = 100  # 类型不明确
```

### 3.2 常量定义

```gdscript
# ✅ 类级别常量
class_name Tower
const MAX_RANGE: float = 100.0
const DAMAGE_MULTIPLIER: float = 1.5

# ✅ 使用 enum 定义相关常量
enum DamageType { PHYSICAL, FIRE, ICE, LIGHTNING }

# ✅ 使用 const 而非 #define
const GRAVITY: float = 9.8  # ✅
```

### 3.3 枚举使用

```gdscript
# ✅ 定义枚举类型
enum State { IDLE, WALK, JUMP, FALL, ATTACK }
var current_state: State = State.IDLE

# ✅ 使用类型安全的枚举
func change_state(new_state: State):
    current_state = new_state

# ⚠️ 注意：枚举值不匹配的警告可以注释
# warning-ignore:enum_value_not_in_enum
```

### 3.4 内嵌 set/get 函数规范 🆕

**使用场景**：当变量修改时需要自动触发额外逻辑（如更新 UI、触发事件、数据验证等），应优先使用内嵌 set/get 函数

**核心优势**：
- ✅ **自动触发**：无需手动调用更新函数
- ✅ **集中管理**：所有修改逻辑在一处维护
- ✅ **类型安全**：配合静态类型，确保类型正确
- ✅ **数据验证**：可以在 set 中进行数据校验
- ✅ **代码简洁**：调用方无需关心内部逻辑

```gdscript
# ✅ 推荐：使用内嵌 set/get 函数自动更新 UI
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

# ✅ 推荐：数据验证与边界检查
var gold: int = 0:
	set(new_gold):
		gold = max(0, new_gold)  # 金币不能为负数
		if gold != new_gold:
			push_warning("金币被限制为 %d（原值 %d）" % [gold, new_gold])
	get:
		return gold

# ✅ 推荐：状态变化触发事件
signal state_changed(old_state: int, new_state: int)

var state: int = IDLE:
	set(new_state):
		var old_state = state
		if state != new_state:
			state = new_state
			state_changed.emit(old_state, state)
			_on_state_entered(state)
	get:
		return state

# ❌ 避免：手动调用更新函数（容易遗漏）
var hp: int = 100

func take_damage(amount: int):
	hp -= amount
	update_hp_ui()  # 容易遗漏
```

**注意事项**：
- ⚠️ 避免在 setter 中产生副作用（如网络请求、磁盘保存）
- ⚠️ 避免循环引用（两个 setter 互相调用）
- ⚠️ getter 应保持轻量，不应有耗时操作

**与@export 配合使用**：
```gdscript
@export var move_speed: float = 100.0:
	set(new_speed):
		move_speed = max(0.0, new_speed)
		if is_inside_tree():
			update_movement()  # 运行时实时更新
	get:
		return move_speed
```

#### 3.4 内嵌 get/set 使用场景与常见错误 🆕

**核心要点**：内嵌 get/set 有两种主要使用场景——**独立状态**和**包装属性**。错误的使用方式会导致状态不一致、冗余赋值等问题。

**场景 1：独立状态 (Independent State)** - 无底层属性
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
        if hovered_tower != value:
            hovered_tower = value
            if hovered_tower:
                _on_tower_hovered(hovered_tower)
            else:
                _on_tower_hover_ended()
    get:
        return hovered_tower
```

**场景 2：包装已有属性 (Property Wrapper)** - 有底层属性
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

**❌ 常见错误：创建双重状态**
```gdscript
# ❌ 错误：包装属性时创建了两个独立状态
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if is_panel_visible != value:  # ❌ 检查自身（应该检查 visible）
            is_panel_visible = value    # ❌ 自赋值（冗余）
            visible = value             # ❌ 同步另一个属性
    get:
        return is_panel_visible  # ❌ 返回自身（应该返回 visible）

# 踩坑案例：TowerSelectUI 重构中，由于直接设置 visible = false
# 而不是 is_panel_visible = false，导致状态不同步，面板无法显示
```

**使用场景对比表**：

| 场景 | 用法 | setter 检查 | setter 设置 | getter 返回 | 示例 |
|------|------|-----------|-----------|-----------|------|
| **独立状态** | 无底层属性 | `if self != value` | `self = value` | `return self` | `is_locked`, `hovered_tower` |
| **包装属性** | 有底层属性 | `if underlying != value` | `underlying = value` | `return underlying` | `is_panel_visible` (包装 `visible`) |
| **计算属性** | 只读 getter | N/A | N/A | 计算表达式 | `health_percent = health / max_health` |

**最佳实践**：
1. **明确属性类型**：先判断是独立状态还是包装属性
2. **独立状态**：setter 中自赋值，getter 返回自身
3. **包装属性**：setter 设置底层属性，getter 返回底层属性
4. **避免直接访问**：使用包装属性时，不要直接访问底层属性
5. **状态一致性**：确保包装属性和底层属性始终同步

详细文档：[Base 层 - GDScript 代码规范](./base/practical-experiences/code-standards/GDScript_Code_Standards.md#34-内嵌-getset-使用场景与常见错误)

---

## 4. 函数规范

### 4.1 函数定义

```gdscript
# ✅ 必须使用类型注解
func attack(target: Node2D, damage: int) -> bool:
    return true

# ✅ 使用 @export 暴露函数给编辑器
@export func set_health(value: int):
    health = value

# ✅ 使用 @static_unload 优化静态函数
@static_unload
func utility_function():
    pass
```

### 4.2 参数传递

```gdscript
# ✅ 基本类型按值传递
func modify_value(value: int) -> int:
    return value + 1

# ✅ 对象类型按引用传递
func modify_node(node: Node2D):
    node.position = Vector2.ZERO

# ⚠️ 需要副本时使用 .duplicate()
func modify_array(array: Array) -> Array:
    var copy = array.duplicate()
    # 修改 copy...
    return copy
```

### 4.3 返回值处理

```gdscript
# ✅ 明确返回类型
func get_health() -> int:
    return health

# ✅ 可能失败返回 null
func find_target() -> Node2D:
    if has_target():
        return target
    return null

# ✅ 使用 Result 模式
func try_attack() -> Dictionary:
    if can_attack():
        return {"success": true, "damage": 10}
    return {"success": false, "error": "Cannot attack"}
```

---

## 5. 类型系统

### 5.1 显性声明变量类型 (强制要求)

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
var target := get_node("Target")  # 推断为 Node

# ⚠️ 踩坑点：:= 推断后类型固定，不能赋其他类型的值
var count := 0
count = "text"  # ❌ 错误！类型不匹配
```

#### 数组和字典类型声明

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

#### 函数参数和返回值类型

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

#### 常量类型声明

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

#### 类型转换

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

#### 使用 as 声明自定义类型 (重要)

**规则**: 对于非 Godot 内置的自定义类类型，必须使用 `as` 关键字进行显式类型声明

**场景 1: 从节点获取自定义脚本**

```gdscript
# ✅ 推荐：使用 as 显式声明自定义类型
var tower := $TowerNode as TowerScript
var enemy := get_node("Enemy") as EnemyScript

# ❌ 避免：不使用 as，类型不明确
var tower = $TowerNode  # 类型不明确，可能是 Node 或 TowerScript
```

**场景 2: 从信号或回调获取对象**

```gdscript
# ✅ 推荐：信号回调中使用 as 声明自定义类型
func _on_area_entered(area: Area2D):
    var enemy_projectile := area as EnemyProjectile
    if enemy_projectile:
        enemy_projectile.explode()

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
   ```

**最佳实践**:
1. 始终使用 as 声明自定义类型
2. 配合 is 检查类型
3. 转换失败时使用 push_error 记录错误
4. 类型注解与 as 结合：`var tower: TowerScript = $TowerNode as TowerScript`

### 5.2 静态类型优势

**性能提升**:
- 方法调用：10-15% 性能提升
- 算术运算：8-12% 性能提升
- 错误检测：编译时发现，无需运行

**开发效率**:
- 代码补全：编辑器提供更精确的自动完成
- 自文档化：类型提示让代码更易理解
- 重构安全：类型检查帮助发现潜在问题

```gdscript
# ✅ 使用静态类型
var health: int = 100
var speed: float = 5.0
var target: Node2D

# ❌ 避免动态类型
var health = 100  # 类型不明确
var target  # 可能是任何类型
```

### 5.3 类型转换 (补充)

```gdscript
# ✅ 显式类型转换
var int_value: int = 42.7 as int  # 42
var float_value: float = 42  # 42.0

# ✅ 使用 as 进行安全转换
var node = get_node("Sprite")
var sprite = node as Sprite2D
if sprite:
    # 安全使用
    pass

# ⚠️ 注意整数除法
var half: float = 5 / 2.0  # 2.5 ✅
var half_wrong: int = 5 / 2  # 2 ❌
```

### 5.4 数组和字典类型 (补充)

```gdscript
# ✅ 类型化数组
var numbers: Array[int] = [1, 2, 3]
var enemies: Array[Enemy] = []

# ✅ 类型化字典
var config: Dictionary = {"health": 100, "speed": 5.0}
var typed_dict: Dictionary[String, int] = {"health": 100}

# ⚠️ 注意：类型数组不能直接赋值
var a: Array[Node2D] = [Node2D.new()]
var b: Array[Node] = []
b.assign(a)  # ✅ 使用 assign()
```

### 5.5 代码审查检查清单

代码审查时检查:
- [ ] 所有变量都有类型声明 (显式或推断)
- [ ] 数组和字典明确了类型
- [ ] 函数参数有类型注解
- [ ] 函数有返回值类型注解
- [ ] 常量有类型声明 (或可推断)
- [ ] 类型转换使用 `as` 关键字
- [ ] 无整数除法精度丢失问题

详细文档：[GDScript 静态类型指南](wiki/guides/gdscript-static-typing.md)

---

## 6. 资源管理

### 6.1 preload vs load

```gdscript
# ✅ preload: 编译时加载，用于频繁使用的资源
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

# ✅ load: 运行时加载，用于动态资源
func load_level(level_name: String):
    var level = load("res://levels/%s.tscn" % level_name)
    return level

# ⚠️ 注意：避免在循环中 load()
# ❌ 错误
for i in range(10):
    var res = load("res://resource_%d.tres" % i)

# ✅ 正确：预加载或缓存
var cache: Dictionary = {}
for i in range(10):
    if not cache.has(i):
        cache[i] = load("res://resource_%d.tres" % i)
```

### 6.2 资源释放

```gdscript
# ✅ 使用对象池管理频繁创建/销毁的资源
var pool: Array[PackedScene] = []

func spawn():
    if pool.size() > 0:
        return pool.pop_back()
    return create_new()

func despawn(obj):
    pool.append(obj)

# ✅ 及时释放不再使用的资源
func unload_level():
    current_level = null
    # Godot 会自动释放引用计数为 0 的资源
```

### 6.3 循环依赖避免

```gdscript
# ❌ 错误：循环引用
# a.gd
var b_scene = preload("res://b.tscn")
# b.gd
var a_scene = preload("res://a.tscn")  # 报错！

# ✅ 解决方案 1：使用 load()
var b_scene = load("res://b.tscn")

# ✅ 解决方案 2：使用 Autoload
var b_scene = ResourceManager.get_scene("b")

# ✅ 解决方案 3：重构代码结构
```

---

## 7. 警告处理

### 7.1 常见警告及修复

| 警告 | 原因 | 修复方案 |
|------|------|----------|
| `UNSAFE_PROPERTY_ACCESS` | 类型不安全 | 使用 `as` 或显式转换 |
| `UNSAFE_METHOD_ACCESS` | 方法调用类型不安全 | 添加类型检查 |
| `UNUSED_VARIABLE` | 未使用变量 | 删除或添加 `_` 前缀 |
| `SHADOWED_VARIABLE` | 变量遮蔽 | 重命名参数或成员变量 |
| `STANDALONE_EXPRESSION` | 独立表达式无效果 | 删除或添加注释说明 |

### 7.2 警告抑制

```gdscript
# ✅ 有理由的警告抑制（必须注释说明）
# warning-ignore:unsafe_property_access
var node = get_node("Sprite") as Sprite2D  # 已确认节点存在

# warning-ignore:unused_variable
var _unused: int = 0  # 预留接口，未来使用

# ✅ 局部抑制
func risky_operation():
    # warning-ignore-next-line:unsafe_method_access
    some_risky_method()
```

---

## 8. 调试与日志

### 8.1 打印调试

```gdscript
# ✅ 使用 print() 进行调试
print("Health: ", health)
print("Position: ", position)

# ✅ 使用 print_rich() 格式化输出
print_rich("[color=red]Error:[/color] ", error_message)

# ✅ 使用 push_error() 报告错误
push_error("Failed to load resource: ", path)

# ✅ 使用 assert() 检查前提条件
assert(health >= 0, "Health cannot be negative")
```

### 8.2 日志分级

```gdscript
# ✅ 定义日志级别
enum LogLevel { DEBUG, INFO, WARNING, ERROR }

func log(level: LogLevel, message: String):
    match level:
        LogLevel.DEBUG:
            print("[DEBUG] ", message)
        LogLevel.INFO:
            print("[INFO] ", message)
        LogLevel.WARNING:
            push_warning("[WARNING] ", message)
        LogLevel.ERROR:
            push_error("[ERROR] ", message)
```

---

## 9. 性能优化

### 9.1 代码级优化

```gdscript
# ✅ 缓存频繁访问的节点
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta):
    sprite.modulate.a = 0.5  # ✅ 使用缓存
    # $Sprite2D.modulate.a = 0.5  # ❌ 每次查找

# ✅ 使用 _physics_process 处理物理
func _physics_process(delta):
    velocity = move_and_slide()  # ✅

# ✅ 避免在循环中创建对象
# ❌ 错误
for i in range(100):
    var vec = Vector2(i, i)  # 创建 100 个对象

# ✅ 正确
var vec: Vector2
for i in range(100):
    vec.x = i
    vec.y = i
```

### 9.2 内存优化

```gdscript
# ✅ 使用对象池
var enemy_pool: Array[Enemy] = []

func spawn_enemy():
    if enemy_pool.size() > 0:
        return enemy_pool.pop_back()
    return Enemy.new()

# ✅ 及时释放资源
func cleanup():
    enemies.clear()
    # Godot 会自动释放引用计数为 0 的资源
```

### 9.3 视觉层 vs 逻辑层分离

```gdscript
# ✅ 视觉调整使用 Offset/flip_h
sprite.flip_h = direction < 0  # ✅ 视觉翻转
# sprite.scale.x = -1  # ❌ 会破坏物理

# ✅ 逻辑移动使用 Position
position += velocity * delta  # ✅ 逻辑移动
# sprite.position += velocity * delta  # ❌ 视觉移动
```

---

## 10. 代码审查清单

### 10.1 提交前检查

- [ ] **零警告**: 编译警告数量为 0
- [ ] **类型注解**: 所有变量和函数都有类型注解
- [ ] **命名规范**: 遵循命名规范，无命名冲突
- [ ] **资源管理**: 正确使用 preload/load，无循环依赖
- [ ] **内存管理**: 及时释放不再使用的资源
- [ ] **性能优化**: 缓存频繁访问的节点
- [ ] **错误处理**: 使用 push_error() 报告错误
- [ ] **调试代码**: 移除或注释调试 print()
- [ ] **注释清晰**: 关键逻辑有注释说明
- [ ] **格式统一**: 代码格式符合团队规范

### 10.2 性能检查

- [ ] 避免在 _process 中执行昂贵操作
- [ ] 使用 _physics_process 处理物理
- [ ] 缓存频繁访问的节点
- [ ] 使用对象池管理频繁创建/销毁的对象
- [ ] 避免在循环中创建对象
- [ ] 使用静态类型提升性能

---

## 11. 资源文件规范

### 11.1 .tres 文件注释禁止 🔴

**问题**: .tres 资源文件中不能写注释

```gdscript
# ❌ 错误：在 .tres 文件中写注释
[gd_resource type="Resource" class_name="GameData"]

[resource]
# 这是注释 ← 会导致字段加载失败！
health = 100

# ✅ 正确：移除所有注释
[gd_resource type="Resource" class_name="GameData"]

[resource]
health = 100
```

**影响范围**:
- 所有 `.tres` 文件
- 所有 `.resource` 文件
- 导出的资源文件

**解决方案**:
- 在代码中添加注释，而非资源文件
- 使用文档字符串说明资源用途
- 代码审查时检查 .tres 文件

### 11.2 资源文件命名

```gdscript
# ✅ 推荐命名格式
res://resources/configs/game_config.tres
res://resources/data/enemy_data.tres
res://resources/settings/audio_settings.tres

# ✅ 使用子分类
class_name GameConfig extends Resource
class_name EnemyData extends Resource
```

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

# ✅ 正确：也可以通过 /root/ 路径访问（不推荐，冗长）
config_manager = get_node("/root/ConfigManager")
```

**节点树结构**:
```
/root
  ├── Global          ← Autoload，/root 的子节点
  ├── ConfigManager   ← Autoload，/root 的子节点
  └── ...             ← 都是兄弟关系，不是父子关系
```

### 12.3 类型注解适配 🟡 建议

**规则**: 移除 class_name 后，引用 Autoload 类型的变量不写类型注解或用 `Object`

**原因**: 移除 `class_name` 后，Autoload 名称不再是类型标识符，不能用于类型注解

```gdscript
# ❌ 错误：Autoload 移除 class_name 后不能用作类型
var config_manager: ConfigManager  # 报错："ConfigManager" is not a type

# ✅ 正确：使用 Object 类型
var config_manager: Object = ConfigManager

# ✅ 正确：不写类型注解（依赖推断）
var config_manager = ConfigManager
```

### 12.4 枚举引用适配 🟡 建议

**规则**: 移除 class_name 后，跨脚本枚举引用需用整数值+注释替代

**原因**: 移除 `class_name` 后，其他脚本无法通过类名访问枚举（如 `Stage.OLD_AGE`）

```gdscript
# ❌ 错误：跨脚本引用 Autoload 枚举
var current_stage: int = AgeSystem.Stage.OLD_AGE  # AgeSystem 无 class_name

# ✅ 正确：使用整数值 + 注释
var current_stage: int = 3  # Stage.OLD_AGE

# ✅ 正确：在 Autoload 中导出常量映射
# age_system.gd (Autoload)
extends Node

enum Stage { BABY, CHILD, ADULT, OLD_AGE, DEATH }

const STAGE_BABY: int = 0      # Stage.BABY
const STAGE_CHILD: int = 1     # Stage.CHILD
const STAGE_ADULT: int = 2     # Stage.ADULT
const STAGE_OLD_AGE: int = 3   # Stage.OLD_AGE
const STAGE_DEATH: int = 4     # Stage.DEATH

# 其他脚本中使用
var current_stage: int = AgeSystem.STAGE_OLD_AGE
```

### 12.5 保留关键字避让 🟡 建议

**规则**: 禁止使用 `trait` 等系统保留关键字作为变量名

**原因**: `trait` 在 GDScript 4.x 中是系统保留关键字（为未来特性预留），使用会导致解析错误

```gdscript
# ❌ 错误：trait 是保留关键字
for trait in initial_res.traits:
    session.traits.append(trait)

# ✅ 正确：使用替代命名
for trait_item in initial_res.traits:
    session.traits.append(trait_item)
```

### 12.6 Autoload 代码审查清单

- [ ] Autoload 脚本没有 `class_name` 声明
- [ ] Autoload 间互访使用直接名称，不用 `get_node()`
- [ ] 引用 Autoload 类型的变量使用 `Object` 或无类型注解
- [ ] 跨脚本枚举引用使用整数值+注释或常量映射
- [ ] 没有使用 `trait` 等保留关键字作为变量名
- [ ] Autoload 脚本没有使用 `free()` 或 `queue_free()`

**详细踩坑记录**: [Godot_4x_Autoload_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md)

---

## 13. 测试编码守则 🆕

### 13.1 GUT 测试运行器模式 🔴 强制

**规则**: GUT 测试运行器必须使用 `GutConfig` + `run_tests()` 模式，禁止使用 `add_script()` + `test_scripts()` 模式

**原因**: `add_script()` + `test_scripts()` 模式在 Godot 4.x 中会导致测试框架在 `gut.gd:818 _test_the_scripts` 处无限挂起，特别是涉及 Autoload 的测试场景

```gdscript
# ❌ 错误：使用 add_script + test_scripts 模式
var gut = load("res://addons/gut/gut.gd").new()
add_child(gut)
gut.add_script("res://tests/unit/test_xxx.gd")
gut.test_scripts()  # 会导致框架挂起！

# ✅ 正确：使用 GutConfig + run_tests 模式
var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

var gut: Object
var gut_config: Object

func _ready() -> void:
    gut = Gut.new()
    add_child(gut)
    gut_config = GutConfig.new()
    var config_result: int = gut_config._load_options_from_config_file(
        "res://.gutconfig_xxx.json",
        gut_config.options
    )
    if config_result != 1:
        push_error("加载 GUT 配置文件失败")
        return
    gut_config._apply_options(gut_config.options, gut)
    gut.end_run.connect(_on_gut_end_run)
    gut.run_tests()  # 关键：用 run_tests() 而非 test_scripts()
```

### 13.2 禁止替换 Autoload 引用 🔴 强制

**规则**: 测试中禁止在 `before_each`/`after_each` 中替换 Autoload 全局引用（如 `Global.game_session = newObj`），改为直接操作 Autoload 持有的引用字段

**原因**: 替换 Autoload 引用的对象本身会导致其他 Autoload 持有的旧引用与全局引用不一致，同时 GUT 框架对全局 Autoload 状态的变更非常敏感，替换整个对象会触发框架内部异常导致挂起

```gdscript
# ❌ 错误：替换 Autoload 引用的对象本身
func before_each() -> void:
    _old_session = Global.game_session
    Global.game_session = GameSessionData.new()  # 导致 GUT 挂起！

func after_each() -> void:
    Global.game_session = _old_session

# ✅ 正确：直接操作 Autoload 持有的引用字段
func test_something() -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    # ... 执行测试 ...
    session.gold = old_gold  # 恢复

# ✅ 推荐：纯数据类直接创建独立实例
func test_session_data() -> void:
    var session: GameSessionData = GameSessionData.new()
    session.gold = 100
    assert_eq(session.gold, 100, "金币应正确设置")
```

### 13.3 禁止 watch_signals Autoload 🔴 强制

**规则**: 禁止对 Autoload 单例调用 `watch_signals()`，改用基于状态的断言

**原因**: GUT 的 `watch_signals()` 机制需要对目标对象进行信号监听注册，但 Autoload 单例的生命周期由 Godot 引擎管理，与测试框架的生命周期不一致，导致信号监听无法正常清理，进而导致测试框架无限挂起

```gdscript
# ❌ 错误：对 Autoload 使用 watch_signals
func test_event_system() -> void:
    watch_signals(EventSystem)  # 导致 GUT 挂起！
    EventSystem.select_option(event_data, option)
    assert_signal_emitted(EventSystem, "option_selected")

# ✅ 正确：基于状态的断言
func test_event_system() -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    EventSystem.select_option(event_data, gold_option)
    assert_gt(session.gold, old_gold, "选择金币选项后金币应增加")
```

### 13.4 测试前校验字段名 🟡 建议

**规则**: 编写测试前必须先读取被测类源码，确认属性名和方法签名，避免引用不存在的字段

**原因**: 凭记忆假设字段名容易导致测试引用不存在的属性（如 `owned_towers` vs 实际的 `towers`），造成运行时错误

```gdscript
# ❌ 错误：凭记忆假设字段名
func test_towers() -> void:
    assert_eq(session.owned_towers.size(), 0)  # owned_towers 不存在！

# ✅ 正确：先确认类定义再编写测试
# GameSessionData 中的实际定义：var towers: Array[Dictionary] = []
func test_towers() -> void:
    assert_eq(session.towers.size(), 0, "初始塔列表应为空")
```

### 13.5 Autoload 测试字段恢复 🟡 建议

**规则**: 涉及 Autoload 状态修改的测试，在每个测试函数内手动保存/恢复被修改的字段值，而非依赖 `before_each`/`after_each`

**原因**: `before_each`/`after_each` 中替换 Autoload 全局引用会导致框架挂起（见 13.2），因此应在每个测试函数内精细控制状态恢复

```gdscript
# ✅ 推荐：在每个测试函数内手动保存/恢复
func test_gold_change() -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    session.gold = 500
    # ... 执行测试断言 ...
    session.gold = old_gold  # 恢复

# ✅ 推荐：使用辅助方法封装恢复逻辑
func _with_session_gold(gold_value: int, callback: Callable) -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    session.gold = gold_value
    callback.call()
    session.gold = old_gold
```

### 13.6 GUT 测试代码审查清单

- [ ] 测试运行器使用 `GutConfig` + `run_tests()` 模式
- [ ] 没有在 `before_each`/`after_each` 中替换 Autoload 全局引用
- [ ] 没有对 Autoload 单例调用 `watch_signals()`
- [ ] 测试中引用的属性名和方法签名已与源码校验
- [ ] 涉及 Autoload 状态修改的测试有手动保存/恢复逻辑
- [ ] 纯数据类的测试使用独立实例而非 Autoload 引用

**详细踩坑记录**: [GUT_Testing_Pitfalls.md](./base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md)

---

## 14. 资源引用与数据一致性规范 🆕

### 14.1 删除 .tres 资源文件必须清理引用 🔴 强制

**规则**: 删除任何 `.tres` / `.resource` 文件前，必须全局搜索并清理所有引用该文件的 `ext_resource` 声明

**原因**: Godot 的 `.tres` 文件加载是原子操作——任何一个 `[ext_resource]` 找不到，整个 `.tres` 都无法加载，而非仅跳过缺失资源

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

**预防措施**:
- 删除资源前全局搜索文件路径（含 .gd / .json / .tres / .tscn）
- 使用 `.bak` 后缀代替直接删除，便于追溯
- 逐步迁移到 JSON 配置，避免 .tres 引用链

### 14.2 数据格式在源头统一 🔴 强制

**规则**: 数据格式转换只在数据入口处完成一次，所有消费者使用统一格式，禁止在消费者处做运行时格式转换

**原因**: 在每个消费者处做运行时转换会导致：1) 重复代码 2) 遗漏某个消费者 3) 转换逻辑不一致

```gdscript
# ❌ 错误：在每个消费者处提取短名
# event_ui.gd
var session_bg_short: String = session.family_background.replace("family_", "")
if session_bg_short == "farmer":

# event_system.gd
var session_bg_short: String = session.family_background.replace("family_", "")
if session_bg_short == "farmer":

# ✅ 正确：在数据源统一格式
# era_system.gd（数据入口）
session.family_background = raw_family_id.replace("family_", "")

# 所有消费者直接比较
if session.family_background == "farmer":
```

**核心原则**: 数据格式应在源头统一，而非在每个消费者处转换

### 14.3 修改数据格式必须同步更新配置文件 🟡 建议

**规则**: 修改 session 字段或其他运行时数据格式后，必须同步检查并更新所有 JSON 配置文件中的硬编码值

**原因**: JSON 配置文件也是数据消费者，其中的硬编码值必须与代码中的数据格式保持一致。遗漏配置文件会导致匹配失败且难以排查

```json
// ❌ 修改 session.family_background 为短名后，遗漏 achievements.json
{
  "condition": {
    "type": "family_ending_combo",
    "family": "family_farmer"  // 与 session.family_background("farmer") 不一致
  }
}

// ✅ 同步更新配置文件
{
  "condition": {
    "type": "family_ending_combo",
    "family": "farmer"  // 与 session.family_background 一致
  }
}
```

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

**详细踩坑记录**: [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](./base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md)

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
# enemy.gd - 在 _ready() 中注册
func _ready() -> void:
    add_to_group("enemies")

# map_manager.gd - 动态获取存活数量
func get_alive_enemy_count() -> int:
    return get_tree().get_nodes_in_group("enemies").size()
```

**分裂/召唤敌人的处理**:
```gdscript
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

# ✅ hovered_tower 等引用加 is_instance_valid() 保护
func _process(delta: float) -> void:
    if is_instance_valid(hovered_tower):
        hovered_tower.show_info()
```

**核心要点**:
- 使用 `.get()` 而非 `[]` 访问字典，避免赋值时触发 freed instance 错误
- 节点被 queue_free() 时，必须从所有缓存容器中移除引用
- 访问缓存引用前必须用 `is_instance_valid()` 检查

### 15.3 悬浮 UI 组件设置 mouse_filter=IGNORE 🟡 建议

**规则**: Tooltip、弹窗等悬浮组件及其子节点应设置 `mouse_filter = MOUSE_FILTER_IGNORE`

**原因**: 悬浮组件遮挡触发元素会导致 MOUSE_EXIT/MOUSE_ENTER 循环闪烁

```gdscript
# ❌ 错误：tooltip 遮挡 badge 导致闪烁循环
# tooltip 出现在 badge 上方 -> 鼠标进入 tooltip -> badge 触发 MOUSE_EXIT
# -> tooltip 消失 -> 鼠标重新进入 badge -> tooltip 又出现 -> 循环

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
# ❌ 错误：击退和路径移动同时执行
func _process(delta: float):
    _move_along_path(delta)  # 击退效果也在修改 global_position，两者冲突

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
    # ... 创建简单面板 ...
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
# ❌ 错误：战斗结算面板读取事件奖励数据
func _show_battle_result():
    for trait in session.last_event_traits:  # 这是事件阶段的奖励！
        _add_trait_display(trait)

# ✅ 正确：每个阶段使用独立的数据字段
# session.gd
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
    return "塔伤害+%.0f%%" % (val * 100)  # 显示 "塔伤害+0%"

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

**规则**: 有数量限制的UI元素，优先显示"剩余可用数/最大数"而非"已使用数/最大数"

**原因**: "还可以放几个"比"已经放了几个"更符合用户心智模型

```gdscript
# ❌ 错误：显示"已放置/最大"
count_label.text = "%d/%d" % [tower_placed, tower_max]  # 0/1 → "0个可用"

# ✅ 正确：显示"剩余可放/最大"
var tower_remaining: int = tower_max - tower_placed
count_label.text = "%d/%d" % [tower_remaining, tower_max]  # 1/1 → "还能放1个"
```

**已用完的选项应变灰禁用(disabled + modulate)，而非从界面移除**:

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

**踩坑记录**: [§47 UI计数显示语义错误](./踩坑记录完整索引.md#47-ui计数显示语义错误已放置最大vs剩余可放最大-🟡-中) | [§49 已满的塔从UI消失而非变灰](./踩坑记录完整索引.md#49-已满的塔从ui消失而非变灰-🟡-中)

### 15.10 调试前确认"正确行为"定义 🟡 建议

**规则**: 调试bug时先确认"正确行为"的定义，避免在正确的逻辑上反复修改。先问清楚"期望显示什么"再动手

**原因**: 如果对"正确行为"的理解有误，会在正确的逻辑上反复修改，浪费大量调试时间

```gdscript
# ❌ 错误的调试方向：反复修改正确的计数逻辑
# 用户反馈"显示0/1不对" → 开发者认为是计数逻辑问题
# 尝试1：换一种 group 查询方式
# 尝试2：换一种 meta 读取方式
# ... 以上都是正确的逻辑，问题不在计数

# ✅ 正确的调试方向：先确认"正确行为"的定义
# 1. 问清楚"期望显示什么" → "1/1" 而非 "0/1"
# 2. 确认计数逻辑是否正确 → 逻辑正确
# 3. 确认显示格式是否正确 → 格式语义错误
# 4. 修改显示格式 → "剩余/最大"
```

**踩坑记录**: [§50 调试误判——在正确的逻辑上反复修改](./踩坑记录完整索引.md#50-调试误判在正确的逻辑上反复修改-🟢-低)

---

## 16. 场景树与路径系统规范 🆕

### 16.1 修改代码前必须确认实际调用路径 🔴 强制

**规则**: 修改代码前必须用Grep搜索所有引用点，确认实际执行路径，不要假设某个文件/函数是被调用的入口

**原因**: 项目中可能存在多个同名或相似功能的文件，实际调用路径可能与预期不同，修改错误的文件不会生效

```gdscript
# ❌ 错误：假设某个文件/函数是被调用的入口
# 修改了 enemy_spawner.gd 但实际调用路径不经过它
# 实际路径：wave_manager.gd -> map_manager.gd

# ✅ 正确：修改前用Grep搜索确认实际调用路径
# 1. 搜索信号名：grep -rn "enemy_spawn_requested" --include="*.gd"
# 2. 确认emit和connect的位置
# 3. 追踪完整的调用链
```

**踩坑记录**: [§56 实际生成路径可能与预期不同](./踩坑记录完整索引.md#56-实际生成路径可能与预期不同-🟡-中)

### 16.2 可能触发场景切换的调用后必须检查is_inside_tree() 🔴 强制

**规则**: `select_option()`、`change_state()`等可能触发场景切换的调用后，节点可能被移出场景树，后续的`get_node_or_null()`、`get_tree()`等调用前必须检查`is_inside_tree()`

**原因**: 场景切换会将当前UI节点移出场景树，后续对场景树的访问会报错 `Can't use get_node() with absolute paths from outside the active scene tree`

```gdscript
# ❌ 错误：场景切换调用后继续访问节点
func _on_option_pressed():
    EventSystem.select_option(event_data, option)  # 可能触发场景切换
    var node = get_node_or_null("/root/SomeNode")  # 报错！

# ✅ 正确：在可能触发场景切换的调用之后，加is_inside_tree()检查
func _on_option_pressed():
    EventSystem.select_option(event_data, option)
    if not is_inside_tree():
        return
    var node = get_node_or_null("/root/SomeNode")
```

**踩坑记录**: [§51 节点被移出场景树后调用get_node_or_null报错](./踩坑记录完整索引.md#51-节点被移出场景树后调用get_node_or_null报错-🔴-高)

### 16.3 不要以对象实例作为Dictionary的key 🔴 强制

**规则**: 不要以对象实例（如Node、Tower等）作为Dictionary的key，改用`Array[Dictionary]`存储，如`{"tower": tower_ref, "damage": 100.0}`

**原因**: 对象被释放后遍历Dictionary时，GDScript内部类型验证会失败，导致 `Attempted to next an invalid (previously freed?) object instance` 崩溃

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

**踩坑记录**: [§52 以freed对象为key的Dictionary遍历崩溃](./踩坑记录完整索引.md#52-以freed对象为key的dictionary遍历崩溃-🔴-高)

### 16.4 路径偏移必须一次性应用到所有路径点 🔴 强制

**规则**: 路径偏移必须在`set_path()`时一次性计算偏移后的路径点，不要用侧向力/每帧偏移实现路径偏移

**原因**: 侧向力与路径追踪的`global_position = target_pos`互相打架，每帧先移向目标点再被侧向力推开，导致怪物抖动/转圈

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

**踩坑记录**: [§53 怪物路径偏移不能用侧向力实现](./踩坑记录完整索引.md#53-怪物路径偏移不能用侧向力实现-🟡-中)

### 16.5 Dictionary值判断用.get()而非.has() 🟡 建议

**规则**: Dictionary值判断使用`.get("key") is ExpectedType`而非`.has("key")`，类型安全且不受null值影响

**原因**: `has("key")`检查的是key是否存在，而非value是否有效。key存在但value为null时，`has()`仍返回true，可能导致逻辑分支错误

```gdscript
# ❌ 错误：用has()判断，null值时仍返回true
if option.has("battle_trigger"):  # battle_trigger: null 时也返回true！
    _enter_battle()  # 误触发战斗

# ✅ 正确：用.get() + 类型检查，类型安全且不受null值影响
if option.get("battle_trigger") is Dictionary:
    _enter_battle()  # 只在battle_trigger是Dictionary时触发
```

**踩坑记录**: [§57 Dictionary.has()对null值返回true](./踩坑记录完整索引.md#57-dictionaryhas对null值返回true-🟡-中)

### 16.6 场景树与路径系统代码审查清单

- [ ] 修改代码前用Grep搜索确认实际调用路径
- [ ] 可能触发场景切换的调用后检查`is_inside_tree()`
- [ ] 不以对象实例作为Dictionary的key
- [ ] 路径偏移在`set_path()`时一次性应用
- [ ] Dictionary值判断用`.get() is ExpectedType`而非`.has()`
- [ ] 分裂/召唤子怪的路径偏移叠加父怪偏移 🆕
- [ ] 怪出生时`current_path_index`从1开始 🆕

---

## 🔗 相关文档

### Base 层原始文档
- [GDScript_Code_Standards.md](./base/practical-experiences/code-standards/GDScript_Code_Standards.md)
- [20A_Godot_Large_Project_Pitfalls_Deep_Dive.md](./base/practical-experiences/best-practices/20A_Godot_Large_Project_Pitfalls_Deep_Dive.md)
- [20B_Godot_Pitfalls_Verification_Guidelines.md](./base/practical-experiences/best-practices/20B_Godot_Pitfalls_Verification_Guidelines.md)
- [20C_Godot_Best_Practices_Quick_Reference.md](./base/practical-experiences/best-practices/20C_Godot_Best_Practices_Quick_Reference.md)

### Wiki 层整合文档
- [GDScript 代码规范](./wiki/concepts/gdscript-standards.md)
- [常见踩坑避雷指南](./wiki/guides/common-pitfalls.md)

---

## 17. GPU 计算与渲染管线规范 🆕

> **案例参考**: [CompositorEffect + Compute Shader 案例库](./cases/compositor-effect-library/)

### 17.1 RenderingDevice 资源必须正确释放 🔴 强制

**规则**: 所有通过 `rd.xxx_create()` 创建的 RID 资源（shader、pipeline、uniform_set、texture、sampler 等），必须在对象销毁时通过 `rd.free_rid()` 释放

**原因**: RenderingDevice 管理的 RID 是 GPU 侧资源，不被 Godot 垃圾回收系统管理。不释放会导致 GPU 内存泄漏

```gdscript
# ✅ 正确：在 _notification(NOTIFICATION_PREDELETE) 中释放所有 RID
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        if compute_shader.is_valid():
            rd.free_rid(compute_shader)
        if rd.uniform_set_is_valid(uniform_set):
            rd.free_rid(uniform_set)
        if rd.compute_pipeline_is_valid(pipeline):
            rd.free_rid(pipeline)
        if texture.is_valid():
            rd.free_rid(texture)

# ❌ 错误：依赖 Godot GC，GPU 资源不会被自动释放
func _exit_tree() -> void:
    # 没有释放 RID，GPU 内存泄漏！
```

**案例参考**: [案例1 - ComputeHelper 资源释放](./cases/compositor-effect-library/01_Compute_Shader_Plus_Plugin.md#24-资源释放)

### 17.2 Push Constant 必须 16 字节对齐 🔴 强制

**规则**: push_constant 的 PackedByteArray 大小必须是 16 字节的倍数；vec3 在 GLSL 中占 4 个 float slot（16 字节），不是 3 个

**原因**: GLSL std430 内存布局要求每个 uniform block 按 16 字节对齐，不满足会导致 shader 读取到错误数据

```gdscript
# ✅ 正确：push constant 补零到 16 字节倍数
var mode_bytes := PackedByteArray()
mode_bytes.resize(16)  # 单个 uint 只占 4 字节，但必须补齐到 16
mode_bytes.encode_u32(0, mode)

# ✅ 正确：vec3 按 vec4 对齐
var position_bytes := PackedFloat32Array([x, y, z, 0.0])  # 第 4 个 float 是 padding

# ❌ 错误：vec3 只传 3 个 float
var position_bytes := PackedFloat32Array([x, y, z])  # 下一个数据会读错位！
```

**GLSL std430 对齐规则**:
| 类型 | 字节数 | slot 数 | 说明 |
|------|--------|---------|------|
| `int` / `float` | 4 | 1 | 单值 |
| `vec2` | 8 | 2 | 双值 |
| `vec3` | **16** | **4** | 占 4 slot，不是 3！ |
| `vec4` | 16 | 4 | 四值 |
| `mat4` | 64 | 16 | 4×4 矩阵 |

**案例参考**: [案例1 - ByteArrayHelper std430 对齐](./cases/compositor-effect-library/01_Compute_Shader_Plus_Plugin.md#四-bytearrayhelper-glsl-std430-内存对齐)

### 17.3 uniform_set_dirty 标记避免重复创建 🔴 强制

**规则**: uniform set 应使用 dirty 标记机制，仅在绑定的 uniform RID 变更时重建，不在每帧重复创建

**原因**: `rd.uniform_set_create()` 和 `rd.free_rid()` 是昂贵操作，每帧调用会导致严重性能下降

```gdscript
# ✅ 正确：dirty 标记机制
var uniform_set_dirty := true
var uniform_set: RID

func run() -> void:
    if uniform_set_dirty:
        # 仅在 dirty 时重建
        if uniform_set.is_valid() and rd.uniform_set_is_valid(uniform_set):
            rd.free_rid(uniform_set)
        uniform_set = rd.uniform_set_create(bindings, shader, 0)
        uniform_set_dirty = false
    # 使用 uniform_set ...

func add_uniform(uniform: Uniform) -> void:
    uniforms.append(uniform)
    uniform.rid_updated.connect(func(): uniform_set_dirty = true)

# ❌ 错误：每帧都创建和释放
func _render_callback(...) -> void:
    var uniform_set = rd.uniform_set_create(bindings, shader, 0)  # 每帧创建！
    # ...
    rd.free_rid(uniform_set)  # 每帧释放！
```

**案例参考**: [案例1 - ComputeHelper uniform_set_dirty 机制](./cases/compositor-effect-library/01_Compute_Shader_Plus_Plugin.md#22-uniform-绑定机制)

### 17.4 CompositorEffect 基础模板 🟡 建议

**规则**: 新建 CompositorEffect 时遵循标准模板：`@tool` 标记、`_render_callback` 实现、size 为 0 时 early return、work group 正确计算

```gdscript
@tool
extends CompositorEffect
class_name MyEffect

var rd := RenderingServer.get_rendering_device()
var shader: RID
var pipeline: RID

func _init() -> void:
    var shader_file := preload("res://effects/my_effect.glsl")
    var shader_spirv := shader_file.get_spirv()
    shader = rd.shader_create_from_spirv(shader_spirv)
    pipeline = rd.compute_pipeline_create(shader)

func _render_callback(_callback_type: int, render_data: RenderData) -> void:
    var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    var size := render_scene_buffers.get_internal_size()

    if size.x == 0 or size.y == 0:
        return

    var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)
    # ... uniform 绑定 ...
    var uniform_set := rd.uniform_set_create(bindings, shader, 0)
    var compute_list := rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
    rd.compute_list_end()
    rd.free_rid(uniform_set)
```

**案例参考**: [案例2 - CompositorEffect 基础架构](./cases/compositor-effect-library/02_CompositorEffect_Basic_Architecture.md#二基本模板)

### 17.5 G-Buffer 按需请求 🟡 建议

**规则**: 只请求需要的 G-Buffer 类型，不用全局开启所有缓冲

```gdscript
func _init() -> void:
    # ✅ 正确：只请求需要的缓冲
    needs_normal_roughness = true    # 只需要法线时开启
    # needs_motion_vectors = false   # 不需要运动向量

    # ❌ 错误：无条件开启所有缓冲
    needs_normal_roughness = true    # 即使不使用也开启
    needs_motion_vectors = true      # 浪费性能
```

**可用 G-Buffer 列表**:
| 缓冲 | 请求方式 | 提取方法 | 用途 |
|------|---------|---------|------|
| Color | 自动可用 | `get_color_layer(0)` | 颜色读写 |
| Depth | 自动可用 | `get_depth_layer(0)` | 深度采样 |
| Normal+Roughness | `needs_normal_roughness = true` | `get_texture("forward_clustered", "normal_roughness")` | 法线/粗糙度 |
| Motion Vectors | `needs_motion_vectors = true` | `get_texture("forward_clustered", "motion_vectors")` | 运动模糊 |

**案例参考**: [案例2 - G-Buffer 提取](./cases/compositor-effect-library/02_CompositorEffect_Basic_Architecture.md#三g-buffer-提取)

### 17.6 编辑器热重载工具 🟢 参考

**规则**: Compute Shader 开发期间提供编辑器热重载按钮，提升迭代效率

```gdscript
@export_tool_button("Reload Shader", "Reload") var reload_button := reload_shader

func reload_shader() -> void:
    var shader_file: RDShaderFile = load("res://effects/my_effect.glsl")
    var shader_spirv := shader_file.get_spirv()
    rd.free_rid(pipeline)
    rd.free_rid(shader)
    shader = rd.shader_create_from_spirv(shader_spirv)
    pipeline = rd.compute_pipeline_create(shader)
```

**案例参考**: [案例5 - 编辑器热重载](./cases/compositor-effect-library/05_Ray_Tracing_Path_Tracing.md#35-编辑器热重载)

### 17.7 GPU 数据读取限制 🟡 建议

**规则**: 从 GPU 读取数据（`get_image()` / `get_image_async()`）非常慢，仅用于调试或离线处理，禁止在每帧调用

```gdscript
# ✅ 正确：仅在调试或一次性操作时读取
func _debug_save_depth() -> void:
    var image := depth_uniform.get_image()  # 仅调试时使用
    image.save_png("res://debug_depth.png")

# ✅ 正确：异步读取避免阻塞主线程（Godot 4.4+）
func process_result() -> void:
    output_texture.get_image_async().connect(_on_image_ready)

# ❌ 错误：每帧从 GPU 读取
func _render_callback(...) -> void:
    # ...
    var debug_image := output_texture.get_image()  # 每帧阻塞！
```

**案例参考**: [案例1 - ImageUniform 异步读取](./cases/compositor-effect-library/01_Compute_Shader_Plus_Plugin.md#32-异步读取-gpu-数据godot-44)

### 17.8 Work Group 计算公式 🟢 参考

**规则**: work group 数量使用向上取整除法，确保覆盖所有像素

```gdscript
# ✅ 正确：向上取整
var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)

# 对应 GLSL: layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
```

### 17.9 GPU 计算代码审查清单

- [ ] 所有 RID 在 `_notification(NOTIFICATION_PREDELETE)` 中释放
- [ ] push_constant 大小是 16 字节的倍数
- [ ] vec3 按 vec4 对齐（占 4 个 float slot）
- [ ] 使用 `uniform_set_dirty` 标记避免每帧重建
- [ ] CompositorEffect 使用 `@tool` 标记
- [ ] `_render_callback` 中 size 为 0 时 early return
- [ ] work group 使用向上取整公式
- [ ] 只请求需要的 G-Buffer
- [ ] 不在每帧调用 `get_image()` / `get_image_async()`
- [ ] 编辑器热重载按钮（开发期间）

---

## 18. 国际化(i18n)规范 🆕

### 18.1 翻译键命名规范 [🔴强制]

翻译键必须遵循 `{CATEGORY}_{ENTITY_ID}_{FIELD}` 格式：

```gdscript
# ✅ 正确
TOWER_CHINESE_BASIC_NAME
ENEMY_HOMEWORK_NAME
EVENT_MATH_CONTEST_DESC
TRAIT_LITTLE_SINGER_NAME
ATTR_INTELLIGENCE_DISPLAY_NAME
BTN_SUMMON

# ❌ 错误 - 语义不清或命名不一致
STAGE_CHILDHOOD          # 缺少_NAME后缀，与STAGE_CHILDHOOD_NAME重复
AGE_PLUS_1               # 命名不统一，应为AGE_PLUS_ONE
TOWERS_SEPARATOR         # 与SEPARATOR_DUN语义重复
```

添加翻译键前必须搜索是否已存在语义相同的键：
```bash
grep "SEPARATOR" locale/translations.csv
```

### 18.2 Bean层get_display_name()模式 [🔴强制]

所有配置Bean类必须提供 `get_display_name()` 方法，返回 `tr(field_value)` 实现运行时语言切换：

```gdscript
# ✅ 正确 - TowerBean
func get_display_name() -> String:
    return tr(tower_name)

# ✅ 正确 - EnemyConfig
func get_display_name() -> String:
    return tr(enemy_name)

# ❌ 错误 - 直接使用原始字段
var display = config.tower_name  # 返回翻译键而非翻译值
```

### 18.3 CSV格式串完整性 [🔴强制]

含格式占位符的翻译键，所有语言列的占位符数量必须一致：

```csv
# ✅ 正确 - 中英文参数数量匹配
ENEMY_SLOWED,🐌 减速中（-%.0f%%，%.1fs）,🐌 Slowed (-%.0f%%, %.1fs)

# ❌ 错误 - 英文列截断，缺少第二个参数
ENEMY_SLOWED,🐌 减速中（-%.0f%%，%.1fs）,🐌 Slowed (-%.0f%%
```

### 18.4 硬编码中文替换规范 [🔴强制]

所有玩家可见的硬编码中文字符串必须替换为tr()调用：

```gdscript
# ✅ 正确
text += tr("ATTR_FORMAT") % [display_name, value]
parts.append(tr("REQ_HAS_TRAIT") % trait_name)
return tr("SEPARATOR_DUN").join(parts)

# ❌ 错误
text += "%s：%d" % [display_name, value]       # 硬编码中文冒号
parts.append("拥有「%s」" % trait_name)          # 硬编码中文格式
return "、".join(parts)                          # 硬编码中文分隔符
```

分隔符/格式串翻译键对照表：

| 中文 | 翻译键 | 英文 |
|------|--------|------|
| 、 | SEPARATOR_DUN | , |
| ； | SEPARATOR_SEMICOLON | ; |
| %s：%d | ATTR_FORMAT | %s: %d |
| %s≥%d | REQUIREMENT_FORMAT | %s>=%d |
| %s：%s | TRAIT_EFFECT_FORMAT | %s: %s |

### 18.5 i18n改造完整性检查 [🟡建议]

进行i18n改造时，必须检查以下内容：

1. **搜索同名函数**：同一功能可能在多个文件中实现，必须全部改造
   ```bash
   grep -r "func format_requirements" scripts/
   ```

2. **验证CSV完整性**：改造完成后，检查en列是否全部填充
   ```python
   # 检查空en列
   total, empty = 0, 0
   for row in csv.reader(open("translations.csv")):
       if len(row) >= 3 and not row[2].strip():
           empty += 1
   ```

3. **运行时验证**：切换到英文模式，检查所有UI区域无残留中文

4. **去重检查**：确认无语义重复的翻译键

### 18.6 is_instance_valid()检查 [🔴强制]

在_process/_physics_process中引用可能被queue_free()释放的对象时，必须先检查有效性：

```gdscript
# ✅ 正确
for button in flashing_buttons.keys():
    if not is_instance_valid(button):
        to_remove.append(button)
        continue
    button.add_theme_stylebox_override("normal", style)

# ❌ 错误 - 按钮可能已被释放
for button in flashing_buttons.keys():
    button.add_theme_stylebox_override("normal", style)  # 崩溃！
```

queue_free()后及时清理相关引用：
```gdscript
func _on_button_removed(button):
    flashing_buttons.erase(button)
```

**详细踩坑记录**: [Godot_4x_i18n_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md)

---

## 19. GDScript编辑工作流规范 🆕

### 19.1 编辑后必须读回验证缩进 [🔴强制]

GDScript 是缩进敏感语言（与 Python 相同），缩进即逻辑。使用 `mcp_godot_edit_script` 或 `SearchReplace` 修改 GDScript 文件后，**必须立即 Read 文件确认缩进正确**，然后才能运行测试。

```gdscript
# ❌ 错误：file.close() 多了一个 tab，在 while 循环内部
while not file.eof_reached():
    var line: String = file.get_line()
    file.close()  # ← 第一次循环就关闭文件！导致编辑器崩溃

# ✅ 正确：file.close() 与 while 同级，在循环外部
while not file.eof_reached():
    var line: String = file.get_line()
file.close()  # ← 循环结束后才关闭
```

**根因**：纯文本替换工具（`edit_script`、`SearchReplace`）不理解语法结构，只机械匹配和替换字符串，不会校验缩进层级。一个 tab 的差异就是"在循环内"还是"在循环外"的区别。

### 19.2 大段新增代码优先用Write工具 [🔴强制]

对于大段新增代码（如整个新方法），优先用 `Write` 工具写完整文件，而非片段替换。

```bash
# ❌ 错误：用片段替换添加整个新方法（缩进极易出错）
edit_script(old_snippet="func _old_method():", new_snippet="func _old_method():\n\t...\n\nfunc _new_method():\n\tvar x = 1\n\t...")

# ✅ 正确：用 Write 写完整文件，缩进由工具保证
Write(content=完整文件内容, file_path=目标文件)
```

### 19.3 片段替换前必须先Read确认上下文缩进 [🔴强制]

如果用片段替换，先 Read 原文件确认上下文的精确缩进，再构造替换内容。

```bash
# 标准流程（不可跳过任何步骤）：
# 1. Read 原文件 → 确认上下文精确缩进
# 2. 构造替换内容 → 逐行对比 tab 层级
# 3. 执行替换（edit_script / SearchReplace）
# 4. Read 修改后的文件 → 验证缩进正确
# 5. 运行测试 → 确认功能正常
```

### 19.4 编辑工作流必须三步走 [🔴强制]

编辑流程必须是：**编辑 -> 读回验证 -> 运行测试**，绝不能跳过读回验证步骤。

| 步骤 | 操作 | 目的 | 可跳过 |
|------|------|------|--------|
| 1. 编辑 | 执行 edit_script / SearchReplace | 修改代码 | 否 |
| 2. 读回验证 | Read 修改后的文件 | 确认缩进和结构正确 | **否** |
| 3. 运行测试 | 运行场景/单测 | 确认功能正常 | 否 |

**实际案例**：`autoload/i18n_manager.gd` 中 `file.close()` 多了一个 tab 缩进，从 `while` 循环外滑入循环内，第一次循环就关闭文件，第二次循环读取已关闭文件，直接导致 Godot 编辑器崩溃。

**详细踩坑记录**: [GDScript_Indentation_Editor_Crash_Pitfall.md](./base/practical-experiences/pitfall-cases/GDScript_Indentation_Editor_Crash_Pitfall.md) | [踩坑记录完整索引 §65](./踩坑记录完整索引.md#65-gdscript-缩进错误导致-godot-编辑器崩溃-🔴-高)

---

## 20. Area2D鼠标信号与交互系统规范 🆕

### 20.1 禁止使用 Area2D 鼠标信号做悬停检测 🔴 强制

**规则**: 禁止使用 Area2D 的 `mouse_entered`/`mouse_exited`/`input_event` 信号做鼠标悬停检测，必须使用 `_process()` 中的 `Rect2.has_point()` 或距离检测实现

**原因**: Godot 4 中 Area2D 的鼠标检测信号在特定场景下（CanvasLayer 叠加、Control 节点遮挡等）可能完全不工作，且无任何错误提示。即使 `input_pickable=true`、`collision_layer/mask` 正确、`CollisionShape2D` 已添加且有效，信号仍可能不触发

```gdscript
# ❌ 错误：依赖 Area2D 鼠标信号做悬停检测
extends Area2D

func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)  # 可能永远不触发！
    mouse_exited.connect(_on_mouse_exited)    # 可能永远不触发！
    input_event.connect(_on_input_event)      # InputEventMouseMotion 可能不触发！

# ✅ 正确：使用 _process + Rect2.has_point() 矩形碰撞检测
extends Node2D

var is_mouse_hovering: bool = false
var hover_rect: Rect2

func _ready() -> void:
    # 根据碰撞形状计算矩形区域
    var shape: CollisionShape2D = $CollisionShape2D
    var rect_shape: RectangleShape2D = shape.shape as RectangleShape2D
    if rect_shape:
        hover_rect = Rect2(
            global_position - rect_shape.size / 2.0,
            rect_shape.size
        )

func _process(_delta: float) -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var was_hovering: bool = is_mouse_hovering
    is_mouse_hovering = hover_rect.has_point(mouse_pos)

    if is_mouse_hovering and not was_hovering:
        _on_mouse_entered()
    elif not is_mouse_hovering and was_hovering:
        _on_mouse_exited()
```

**圆形碰撞区域的替代方案**:
```gdscript
# ✅ 圆形碰撞区域用距离检测
var hover_center: Vector2
var hover_radius: float

func _process(_delta: float) -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var was_hovering: bool = is_mouse_hovering
    is_mouse_hovering = mouse_pos.distance_to(hover_center) <= hover_radius

    if is_mouse_hovering and not was_hovering:
        _on_mouse_entered()
    elif not is_mouse_hovering and was_hovering:
        _on_mouse_exited()
```

**踩坑记录**: [§66 Area2D 鼠标信号不可靠](./踩坑记录完整索引.md#66-area2d-鼠标信号不可靠-🔴-高)

### 20.2 同一交互功能只允许一条实现路径 🔴 强制

**规则**: 同一交互功能（如悬停检测、tooltip显示、场景切换等）只能有一条实现路径，禁止"备用"或"并行"系统。本项目对同一功能的多套系统**零容忍**，发现即重构。

**关键认知**: 问题的严重之处不在于"有两套代码"，而在于**两套机制同时在运行，开发者却不知道**。其中一套是每帧轮询（性能浪费），另一套是信号驱动（从未生效），两者互不通信，导致所有针对信号路径的修复全部无效。

**调试首要原则**: 实现新功能或修复 Bug 时，**首先要验证架构**——用 Grep 搜索项目中所有可能实现同一功能的路径（搜索关键词如 hover、tooltip、click 等），确认只有一条实现路径。一旦发现多套系统，即刻重构，零容忍。**假设架构而不是验证架构，是调试失败的根本原因；验证架构才是调试时应该做的事情。**

**原因**: 多套并行系统会导致：1) 开发者不确定实际走哪条路径，修复无效；2) 两套系统维护两份逻辑，bug 只在其中一套出现；3) 新系统未复用旧系统的翻译方法等功能，导致回归

```gdscript
# ❌ 错误：三套独立悬停系统并存
# 系统1：MapManager._update_tower_hover() —— 每帧轮询（战斗场景实际使用）
# 系统2：Tower Area2D mouse_entered/mouse_exited —— 信号（战斗场景不使用）
# 系统3：TooltipManager —— 独立逻辑
# 结果：开发者以为走系统2，实际走系统1，所有针对系统2的修复都无效

# ✅ 正确：Tower 自身检测 + 发射信号，Manager 只响应信号
# tower.gd —— 对象自身用 _process + Rect2 检测，发射信号
func _process(_delta: float) -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var rect: Rect2 = Rect2(global_position - Vector2(20, 20), Vector2(40, 40))
    var is_inside: bool = rect.has_point(mouse_pos)
    if is_inside != is_mouse_hovering:
        is_mouse_hovering = is_inside  # setter 自动发射信号

# map_manager.gd —— 管理器只连接信号，不做轮询
func _build_tower(slot_index: int, tower_config: TowerBean) -> void:
    var tower: Tower = Tower.new()
    tower.mouse_hover_started.connect(_on_tower_hover_started)
    tower.mouse_hover_ended.connect(_on_tower_hover_ended)

func _on_tower_hover_started(tower: Tower) -> void:
    hovered_tower = tower
    _show_tower_hover_ui(tower)

func _show_tower_info(tower: Tower) -> void:
    var cfg: TowerBean = tower.config
    var info: String = "%s (Lv.%d)\n" % [cfg.get_display_name(), tower.current_level]  # ✅ 复用翻译方法
```

🔴 **强制**: 禁止轮询机制。不要在 _process 中每帧遍历所有对象做碰撞检测，应让对象自身检测并发射信号，管理器只负责响应信号。

**重构步骤**:
```
1. 用 Grep 搜索所有 emit/connect 确认当前有几条交互路径在运行
2. 如果发现多条路径并存 → 立即停止，先搞清楚哪条在生效
3. 删除所有未生效的路径（不要保留"备用"）
4. 删除轮询机制，改用信号驱动（对象._process 检测 → 发射信号 → Manager 处理）
5. 确保唯一路径复用翻译方法（cfg.get_display_name()），不直接用翻译键（cfg.tower_name）
6. 运行测试验证功能完整
7. Grep 确认无残留的并行系统代码
```

**踩坑记录**: [§67 多套并行交互系统导致隐蔽 Bug](./踩坑记录完整索引.md#67-多套并行交互系统导致隐蔽-bug-🔴-高)

### 20.3 Area2D鼠标信号与交互系统代码审查清单

- [ ] 没有使用 Area2D 的 `mouse_entered`/`mouse_exited` 做悬停检测
- [ ] 悬停检测使用 `_process()` + `Rect2.has_point()` 或距离检测
- [ ] 同一交互功能只有一条实现路径，无并行系统
- [ ] 没有轮询机制（不在 _process 中遍历所有对象做碰撞检测）
- [ ] 对象自身检测并发射信号，管理器只响应信号
- [ ] 重构时先删除旧系统再实现新系统，不保留"备用"
- [ ] 新系统复用了旧系统的翻译方法（`get_display_name()`）等功能
- [ ] 用 Grep 搜索确认无残留的并行系统代码
- [ ] 调试时：首先要验证架构，Grep 搜索所有可能路径，确认只有一条实现路径
- [ ] 发现同一功能多套系统 → 即刻重构，零容忍

**详细踩坑记录**: [Godot_4x_Area2D_Mouse_Signal_And_Parallel_Systems_Pitfall.md](./base/practical-experiences/pitfall-cases/Godot_4x_Area2D_Mouse_Signal_And_Parallel_Systems_Pitfall.md)

---

## 21. 程序化生成图片规范 🆕

> **踩坑案例**: [Godot_4x_PNG_Generation_Pitfall.md](./base/practical-experiences/pitfall-cases/Godot_4x_PNG_Generation_Pitfall.md)
> **踩坑索引**: [§68 Python 原生手写 PNG 导致 Godot 导入失败](./踩坑记录完整索引.md#68-python-原生手写-png-导致-godot-导入失败-🔴-高)

### 21.1 必须使用 Pillow/PIL 库生成 PNG 🔴 强制

**规则**: Godot 项目需要程序化生成图片时，必须使用 Python Pillow (PIL) 库，禁止使用 Python 原生 `struct+zlib` 手写 PNG 二进制格式

**原因**:
1. PNG 格规范复杂，手动构造容易遗漏必要字段（IHDR bit depth、gAMA、cHRM、sRGB 等）
2. Godot 导入系统对 PNG 格式要求严格，容错性低
3. 即使其他图像查看器能打开，Godot 仍可能拒绝导入
4. 调试困难，难以定位具体哪个字段有问题

```python
# ✅ 正确：使用 Pillow 生成标准 RGBA PNG
from PIL import Image, ImageDraw
import os

os.makedirs("images/status_icons", exist_ok=True)

# 创建 RGBA 模式图片（支持透明通道）
img = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)
draw.ellipse([1, 1, 18, 18], fill=(51, 102, 230, 255),
             outline=(51, 102, 230, 200))
img.save("images/status_icons/status_slow.png")

# ❌ 错误：用 Python 原生 struct+zlib 手写 PNG
import struct, zlib
# 手动构造 IHDR + IDAT + IEND chunk
# 文件可被其他查看器打开，但 Godot 拒绝导入！
```

**Pillow 安装与使用**:
```bash
# 安装 Pillow
pip install Pillow
```

### 21.2 图片模式必须为 RGBA 🟡 建议

**规则**: 生成游戏 UI 图标、状态图标等需要透明背景的图片时，必须使用 `"RGBA"` 模式

**原因**:
- 游戏UI通常需要透明背景
- Godot 的 Texture2D 导入支持 Alpha 通道
- RGB 模式不支持透明，会导致图标显示异常

```python
# ✅ 正确：RGBA 模式支持透明
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))  # 透明背景

# ⚠️ 注意：RGB 模式不支持透明
img = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))  # 白色背景
```

### 21.3 生成后必须触发文件系统重扫描 🟡 建议

**规则**: 使用外部工具（如 Python 脚本）生成图片后，必须调用 `mcp_godot_rescan_filesystem` 让 Godot 重新扫描文件系统

**原因**:
- Godot 不会自动检测外部工具生成的文件
- 需要手动触发文件系统扫描才能识别新文件
- 扫描后 Godot 会自动生成 `.import` 缓存文件

**验证步骤**:
1. 运行 Python 生成脚本
2. 在 Godot 编辑器中调用 `mcp_godot_rescan_filesystem`
3. 检查目标目录下是否自动生成 `.import` 文件
4. 在编辑器中验证图片正常显示

### 21.4 禁止在 headless 模式运行依赖 Autoload 的脚本 🟡 建议

**规则**: 不要使用 `godot --headless --script` 方式运行依赖 Autoload 单例的工具脚本

**原因**:
- headless 模式下 Autoload 仍会初始化
- Autoload 可能依赖编辑器资源或场景树（如 I18nManager 加载翻译文件、GameState 切换状态）
- 工具脚本应保持独立，不依赖游戏逻辑

**替代方案**:
| 需求 | 推荐方案 |
|------|----------|
| 批量生成图片/资源 | Python 脚本 + Pillow/PIL |
| 数据迁移/转换 | 独立 Python 脚本 |
| 测试 | GUT 测试框架（GutConfig + run_tests） |
| 编辑器内操作 | EditorPlugin / EditorScript |

### 21.5 程序化生成图片代码模板

#### 基础模板：批量生成状态图标

```python
from PIL import Image, ImageDraw
import os

def generate_status_icons(output_dir: str = "images/status_icons") -> None:
    """生成敌人状态效果图标"""
    os.makedirs(output_dir, exist_ok=True)

    icons = {
        "status_slow":       ((51, 102, 230), "snow"),        # 减速 - 蓝色
        "status_dot":        ((230, 77, 26),   "fire"),         # 持续伤害 - 橙红
        "status_stun":       ((230, 230, 51),  "star"),         # 眩晕 - 黄色
        "status_silence":    ((153, 77, 204),  "cross"),        # 沉默 - 紫色
        "status_confusion":  ((179, 102, 230), "?"),            # 混乱 - 淡紫
        "status_armor_break":((204, 128, 26),  "shield"),       # 破甲 - 棕色
        "status_debuff":     ((128, 77, 77),   "down"),         # 削弱 - 暗红
    }

    SIZE = 20
    CX = SIZE // 2
    CY = SIZE // 2

    for name, (rgb, shape) in icons.items():
        # 创建 RGBA 图片（透明背景）
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # 绘制圆形背景
        draw.ellipse(
            [1, 1, SIZE-2, SIZE-2],
            fill=(*rgb, 255),
            outline=(*[max(0, c-60) for c in rgb], 200)
        )

        # 根据形状绘制符号
        _draw_icon_symbol(draw, CX, CY, shape)

        # 保存为 PNG
        path = f"{output_dir}/{name}.png"
        img.save(path)
        print(f"Generated: {path}")

    print(f"\nAll {len(icons)} icons generated successfully!")

def _draw_icon_symbol(draw: ImageDraw.ImageDraw, cx: int, cy: int, shape: str) -> None:
    """绘制图标符号"""
    white = (255, 255, 255, 220)
    dark = (50, 50, 50, 220)

    if shape == "snow":
        # 雪花：十字形
        draw.line([(cx, 2), (cx, 18)], fill=white, width=1)
        draw.line([(2, cy), (18, cy)], fill=white, width=1)
    elif shape == "fire":
        # 火焰：三角形
        draw.polygon([(cx, 4), (cx-5, 17), (cx+5, 17)], fill=(255, 200, 100, 220))
    elif shape == "star":
        # 星星：倒三角
        draw.polygon([(cx, 4), (cx-5, 16), (cx+5, 16)], fill=dark)
    elif shape == "cross":
        # 叉号：X 形
        draw.line([(cx-4, cy-4), (cx+4, cy+4)], fill=white, width=2)
        draw.line([(cx+4, cy-4), (cx-4, cy+4)], fill=white, width=2)
    elif shape == "?":
        # 问号
        draw.text((cx-3, 3), "?", fill=white)
    elif shape == "shield":
        # 盾牌：菱形
        draw.polygon([(cx, 3), (cx-6, cy), (cx, 17), (cx+6, cy)], fill=dark)
    elif shape == "down":
        # 向下箭头
        draw.polygon([(cx, 17), (cx-5, cy), (cx+5, cy)], fill=(255, 100, 100, 220))

if __name__ == "__main__":
    generate_status_icons()
```

#### 高级模板：带配置的图片生成器

```python
from PIL import Image, ImageDraw, ImageFont
import json
from dataclasses import dataclass
from typing import Tuple, Optional

@dataclass
class IconConfig:
    """图标配置"""
    name: str
    rgb: Tuple[int, int, int]
    symbol: str
    size: int = 20
    description: str = ""

def generate_icons_from_config(config_path: str, output_dir: str) -> None:
    """从 JSON 配置文件生成图标"""
    with open(config_path, 'r', encoding='utf-8') as f:
        configs = json.load(f)

    os.makedirs(output_dir, exist_ok=True)

    for cfg_dict in configs:
        cfg = IconConfig(**cfg_dict)
        img = Image.new("RGBA", (cfg.size, cfg.size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # 绘制圆形背景
        margin = 1
        draw.ellipse(
            [margin, margin, cfg.size-margin, cfg.size-margin],
            fill=(*cfg.rgb, 255),
            outline=(*[max(0, c-60) for c in cfg.rgb], 200)
        )

        # 绘制符号
        cx, cy = cfg.size // 2, cfg.size // 2
        _draw_icon_symbol(draw, cx, cy, cfg.symbol)

        # 保存
        path = f"{output_dir}/{cfg.name}.png"
        img.save(path)
        print(f"✓ {cfg.name}: {path}")

if __name__ == "__main__":
    generate_icons_from_config("icons_config.json", "images/status_icons")
```

### 21.6 程序化生成图片代码审查清单

- [ ] 使用 Pillow/PIL 而非原生 struct+zlib 生成 PNG
- [ ] 图片模式为 "RGBA" 以支持透明通道
- [ ] 生成目录已通过 `os.makedirs(exist_ok=True)` 创建
- [ ] 图片尺寸适合游戏 UI（建议 16x16、20x20、32x32 等标准尺寸）
- [ ] 颜色值使用元组格式 `(R, G, B, A)` 而非分离参数
- [ ] 生成后调用 `mcp_godot_rescan_filesystem` 重新扫描
- [ ] 检查 `.import` 文件是否自动生成
- [ ] 在 Godot 编辑器中验证图片正常显示
- [ ] 不依赖 Godot Autoload 或游戏逻辑
- [ ] 脚本可独立运行，无需 Godot 环境

### 21.7 常见问题排查

| 问题现象 | 可能原因 | 解决方案 |
|----------|----------|----------|
| Godot 显示红叉 ❌ | 使用了原生手写 PNG | 改用 Pillow/PIL |
| 图片无透明背景 | 使用了 RGB 模式 | 改用 RGBA 模式 |
| .import 文件未生成 | 未触发文件系统扫描 | 调用 mcp_godot_rescan_filesystem |
| headless 脚本报错 | 依赖 Autoload 初始化 | 改用独立 Python 脚本 |
| 图片模糊/锯齿 | 尺寸太小或未抗锯齿 | 使用合适尺寸（>=16x16） |

---

## 22. Godot UI 程序化构建规范 🆕

> **踩坑关联**: [§69 ColorRect鼠标事件吞噬](./踩坑记录完整索引.md#69-colorrect鼠标事件吞噬-🔴-高) | [§70 z-index遮挡](./踩坑记录完整索引.md#70-z-index遮挡问题-🟡-中) | [§71 offset vs MarginContainer](./踩坑记录完整索引.md#71-offset-vs-margincontainer-🟡-中) | [§72 Signal重复连接](./踩坑记录完整索引.md#72-signal重复连接-🟡-中) | [§75 tooltip延迟](./踩坑记录完整索引.md#75-godot内置tooltip延迟-🟡-中) | [§76 效果类型match遗漏](./踩坑记录完整索引.md#76-效果类型match遗漏-🟡-中) | [§77 属性名国际化缺失](./踩坑记录完整索引.md#77-属性名国际化缺失-🟡-中)

### 22.1 布局架构标准模式 🔴 强制

**规则**: 程序化构建 UI 面板时，遵循标准三层布局架构：

```
MarginContainer(统一外边距, 如100px)
  └── ColorRect背景 (MOUSE_FILTER_IGNORE)
       └── 内容VBoxContainer / HBoxContainer
            ├── PanelContainer + StyleBoxFlat (模块视觉分隔)
            │    └── 具体内容
            ├── PanelContainer + StyleBoxFlat (同层面板用 HBox 包裹)
            │    └── 具体内容
            └── ...
```

**核心要点**:

1. **外层 MarginContainer**: 统一管理面板与屏幕边缘的留白，使用 `add_theme_constant_override` 设置
2. **ColorRect 背景**: 必须设置 `mouse_filter = MOUSE_FILTER_IGNORE`（见 §69）
3. **PanelContainer + StyleBoxFlat**: 实现模块化的视觉分隔（圆角、边框、背景色）
4. **HBoxContainer 包裹同层面板**: 同一行多个面板用 HBox 对齐

```gdscript
# ✅ 标准面板构建模板
func _build_panel() -> Control:
    # 第1层：外边距
    var root_margin: MarginContainer = MarginContainer.new()
    root_margin.add_theme_constant_override("margin_left", 100)
    root_margin.add_theme_constant_override("margin_right", 100)
    root_margin.add_theme_constant_override("margin_top", 60)
    root_margin.add_theme_constant_override("margin_bottom", 60)

    # 第2层：背景（必须 IGNORE）
    var bg: ColorRect = ColorRect.new()
    bg.color = Color(0.12, 0.12, 0.18, 0.95)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 🔴 关键！
    root_margin.add_child(bg)

    # 第3层：内容容器
    var content_vbox: VBoxContainer = VBoxContainer.new()
    content_vbox.add_theme_constant_override("separation", 12)
    root_margin.add_child(content_vbox)

    # 模块：标题区域
    var title_panel: PanelContainer = _create_styled_panel()
    var title_label: Label = Label.new()
    title_label.text = tr("PANEL_TITLE")
    title_panel.add_child(title_label)
    content_vbox.add_child(title_panel)

    # 模块：内容区域（SIZE_EXPAND_FILL 自适应填充）
    var body_panel: PanelContainer = _create_styled_panel()
    body_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content_vbox.add_child(body_panel)

    return root_margin

func _create_styled_panel() -> PanelContainer:
    var panel: PanelContainer = PanelContainer.new()
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = Color(0.18, 0.18, 0.24, 0.9)
    style.border_color = Color(0.35, 0.35, 0.45, 0.8)
    style.set_border_width_all(1)
    style.set_corner_radius_all(6)
    panel.add_theme_stylebox_override("panel", style)
    return panel
```

**踩坑记录**: [§69 ColorRect 鼠标事件吞噬](./踩坑记录完整索引.md#69-colorrect鼠标事件吞噬-🔴-高)

---

### 22.2 装饰性 Control 必须 MOUSE_FILTER_IGNORE 🔴 强制

**规则**: 所有作为纯装饰用途的 Control 节点（ColorRect、Panel、TextureRect 等），如果不需要接收鼠标输入，必须在创建后立即设置 `mouse_filter = MOUSE_FILTER_IGNORE`

```gdscript
# ✅ 装饰节点创建后立即设置
var bg: ColorRect = ColorRect.new()
bg.color = Color(0, 0, 0, 0.5)
bg.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 装饰 → IGNORE

var separator: HSeparator = HSeparator.new()
separator.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 分隔线 → IGNORE

var icon_bg: TextureRect = TextureRect.new()
icon_bg.texture = preload("res://assets/icon_bg.png")
icon_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 图标底图 → IGNORE

# ❌ 错误：忘记设置 → 吞噬所有鼠标事件
var overlay: ColorRect = ColorRect.new()
overlay.color = Color(0, 0, 0, 0.7)
# 缺少 mouse_filter = IGNORE → 下面的按钮全废了！
```

**需要设置 IGNORE 的场景**:
| 节点类型 | 用途 | 是否需要 IGNORE |
|----------|------|----------------|
| ColorRect | 半透明遮罩/背景填充 | 是 |
| TextureRect | 装饰图标/背景图 | 是 |
| Panel | 纯装饰面板 | 是 |
| HSeparator/VSeparator | 视觉分隔线 | 是 |
| Button | 可点击按钮 | 否（保持 STOP） |
| PanelContainer | 可交互面板容器 | 否（保持 STOP） |
| PopupPanel | 弹出面板 | 否（但子节点需 IGNORE） |

**踩坑记录**: [§69 ColorRect 鼠标事件吞噬](./踩坑记录完整索引.md#69-colorrect鼠标事件吞噬-🔴-高)

---

### 22.3 add_child 顺序即渲染层级 🟡 建议

**规则**: Godot UI 的渲染顺序严格遵循 `add_child()` 的调用顺序——后添加的子节点渲染在上层。需要显示在最上层的元素应最后执行 `add_child()`

```gdscript
# ✅ 正确：从底层到顶层依次添加
func build_popup() -> void:
    # 1. 最底层：暗化遮罩
    var overlay: ColorRect = _create_overlay()
    add_child(overlay)           # 第1个添加 → 最底层

    # 2. 中层：弹出面板
    var popup: PanelContainer = _build_popup_content()
    add_child(popup)             # 第2个添加 → 在遮罩之上

    # 3. 最上层：关闭按钮（确保可点击）
    var close_btn: Button = _create_close_button()
    add_child(close_btn)         # 最后添加 → 最顶层

# ✅ 也正确：先全部添加再用 move_child 调整
func build_popup_alt() -> void:
    var overlay: ColorRect = _create_overlay()
    var popup: PanelContainer = _build_popup_content()

    add_child(popup)     # 先添加
    add_child(overlay)   # 后添加（overlay 在 popup 之上？不对！）
    # 修正：把 popup 移到最上层
    move_child(popup, get_child_count())
```

**注意**: Godot 没有 CSS 式的 `z-index` 数字属性。如需调整层级：
- `move_child(node, get_child_count())` — 移到最顶层
- `move_child(node, 0)` — 移到最底层
- `move_child(node, target_index)` — 移到指定位置

**踩坑记录**: [§70 z-index 遮挡问题](./踩坑记录完整索引.md#70-z-index遮挡问题-🟡-中)

---

### 22.4 面板留白用 MarginContainer 不用 offset 🟡 建议

**规则**: 创建面板内部留白/内边距时，使用 `MarginContainer + theme constant override`；禁止使用 `offset_left/right/top/bottom` 模拟 padding

```gdscript
# ❌ 错误：用 offset 模拟内边距（在 Container 中不可靠）
var inner: PanelContainer = PanelContainer.new()
inner.offset_left = 16     // 可能被父容器覆盖
inner.offset_right = -16
inner.offset_top = 12
inner.offset_bottom = -12
parent.add_child(inner)

# ✅ 正确：MarginContainer 管理内边距
var margin: MarginContainer = MarginContainer.new()
margin.add_theme_constant_override("margin_left", 16)
margin.add_theme_constant_override("margin_right", 16)
margin.add_theme_constant_override("margin_top", 12)
margin.add_theme_constant_override("margin_bottom", 12)
parent.add_child(margin)

var inner: PanelContainer = PanelContainer.new()
margin.add_child(inner)  // 内边距由 MarginContainer 自动管理
```

**嵌套示例 — 复杂面板的多级留白**:
```gdscript
func _build_complex_panel() -> MarginContainer:
    # 外层：屏幕边距 100px
    var outer: MarginContainer = MarginContainer.new()
    outer.add_theme_constant_override("margin_left", 100)
    outer.add_theme_constant_override("margin_right", 100)
    outer.add_theme_constant_override("margin_top", 60)
    outer.add_theme_constant_override("margin_bottom", 60)

    # 中层：面板内边距 20px
    var inner_margin: MarginContainer = MarginContainer.new()
    inner_margin.add_theme_constant_override("margin_left", 20)
    inner_margin.add_theme_constant_override("margin_right", 20)
    inner_margin.add_theme_constant_override("margin_top", 16)
    inner_margin.add_theme_constant_override("margin_bottom", 16)
    outer.add_child(inner_margin)

    # 内容
    var content: VBoxContainer = VBoxContainer.new()
    content.add_theme_constant_override("separation", 10)
    inner_margin.add_child(content)

    return outer
```

**踩坑记录**: [§71 offset vs MarginContainer](./踩坑记录完整索引.md#71-offset-vs-margincontainer-🟡-中)

---

### 22.5 Signal 连接安全模式 🔴 强制

**规则**: 所有 `signal.connect()` 调用前必须有 `is_connected()` 守卫检查，防止热重载时重复连接报错

```gdscript
# ✅ 标准安全连接模式
func _connect_signals() -> void:
    if not some_button.pressed.is_connected(_on_button_pressed):
        some_button.pressed.connect(_on_button_pressed)

    if not close_btn.pressed.is_connected(_on_close_pressed):
        close_btn.pressed.connect(_on_close_pressed)

    if not _tooltip_target.mouse_entered.is_connected(_on_tooltip_show):
        _tooltip_target.mouse_entered.connect(_on_tooltip_show)
    if not _tooltip_target.mouse_exited.is_connected(_on_tooltip_hide):
        _tooltip_target.mouse_exited.connect(_on_tooltip_hide)

# ✅ 批量连接辅助方法
func safe_connect(signal_obj: Signal, callback: Callable) -> void:
    if not signal_obj.is_connected(callback):
        signal_obj.connect(callback)

# 使用
safe_connect(some_button.pressed, _on_button_pressed)
safe_connect(close_btn.pressed, _on_close_pressed)
```

**为什么是强制**: Godot 4.x 中对已连接的信号再次调用 `connect()` 会报运行时错误 `"Signal is already connected to the method"`。热重载（F6）会重新执行 `_ready()`，导致信号被重复连接

**最佳实践**: 将所有信号连接集中到一个 `_connect_signals()` 方法中，在 `_ready()` 末尾调用一次：

```gdscript
func _ready() -> void:
    _build_ui()          # 构建UI树
    _connect_signals()   # 统一连接信号（带守卫检查）
    _refresh_data()      # 刷新数据

func _connect_signals() -> void:
    safe_connect(confirm_btn.pressed, _on_confirm)
    safe_connect(cancel_btn.pressed, _on_cancel)
    # ... 所有信号连接集中管理 ...
```

**踩坑记录**: [§72 Signal 重复连接](./踩坑记录完整索引.md#72-signal重复连接-🟡-中)

---

### 22.6 自定义即时 Tooltip 模式 🟡 建议

**规则**: 需要即时反馈的悬停提示（词条效果预览、属性详情、技能描述等），不使用内置 `tooltip_text`（有 ~0.5-1s 延迟），改用 `PopupPanel + mouse_entered/mouse_exited` 自定义实现

#### 完整实现模板

```gdscript
extends Control
## 自定义即时 Tooltip 组件
## 用法：挂载到需要 tooltip 的父节点上，调用 bind_target() 绑定目标控件

var _popup: PopupPanel
var _label: RichTextLabel
var _current_target: Control

func _ready() -> void:
    _build_popup()
    # 确保 popup 在所有兄弟节点之上
    # （因为是最后 add_child 的）

func _build_popup() -> void:
    _popup = PopupPanel.new()
    _popup.mouse_filter = Control.MOUSE_FILTER_IGNORE

    # 深色半透明风格
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = Color(0.13, 0.13, 0.18, 0.96)
    style.border_color = Color(0.4, 0.45, 0.55, 0.9)
    style.set_border_width_all(1)
    style.set_corner_radius_all(5)
    style.shadow_color = Color(0, 0, 0, 0.5)
    style.shadow_size = 4
    _popup.add_theme_stylebox_override("panel", style)

    _label = RichTextLabel.new()
    _label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _label.add_theme_font_size_override("normal_font_size", 14)
    _label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.92, 1.0))
    _popup.add_child(_label)

    add_child(_popup)

func bind_target(target: Control, formatter: Callable) -> void:
    """绑定目标控件和格式化回调"""
    _current_target = target
    if not target.mouse_entered.is_connected(_on_show):
        target.mouse_entered.connect(_on_show.bind(formatter))
    if not target.mouse_exited.is_connected(_on_hide):
        target.mouse_exited.connect(_on_hide)

func _on_show(formatter: Callable) -> void:
    var text: String = formatter.call()
    _label.parse_bbcode(text)  # 支持富文本

    var pos: Vector2 = get_global_mouse_position() + Vector2(12, 12)

    # 边界检测
    var min_size: Vector2 = _label.get_minimum_size() + Vector2(16, 12)
    var screen: Vector2i = DisplayServer.window_get_size()
    if pos.x + min_size.x > screen.x:
        pos.x = screen.x - min_size.x - 5
    if pos.y + min_size.y > screen.y:
        pos.y = pos.y - min_size.y - 28

    _popup.position = pos
    _popup.popup()

func _on_hide() -> void:
    _popup.hide()
```

#### 使用示例

```gdscript
# 在 TraitBadge 上绑定即时 tooltip
var instant_tooltip: InstantTooltip  # 上述脚本组件

func _ready() -> void:
    instant_tooltip = InstantTooltip.new()
    add_child(instant_tooltip)

    var badge: TextureButton = _create_trait_badge(trait_data)
    instant_tooltip.bind_target(badge, _format_trait_tooltip)

func _format_trait_tooltip() -> String:
    var lines: PackedStringArray = []
    lines.append("[b]%s[/b]" % tr(trait_data.get("name_key", "")))
    lines.append("")
    for effect in trait_data.get("effects", []):
        lines.append(_format_effect_i18n(effect))
    return "\n".join(lines)
```

**内置 vs 自定义 Tooltip 对比**:

| 特性 | 内置 tooltip_text | 自定义 PopupPanel |
|------|-------------------|-------------------|
| 延迟 | 0.5~1s（固定） | 即时（无延迟） |
| 样式控制 | 受主题限制 | 完全自定义 |
| 富文本 | 不支持 | 支持 BBCode |
| 边界检测 | 自动 | 手动（更精确） |
| 适用场景 | 表单标签说明 | 游戏内交互反馈 |

**踩坑记录**: [§75 Godot 内置 tooltip 延迟](./踩坑记录完整索引.md#75-godot内置tooltip延迟-🟡-中)

---

### 22.7 match 语句兜底规范 🟡 建议

**规则**: `match` 语句的 `_:` 兜底分支不应输出原始数据（`str(dictionary)` / `str(object)` / `str(array)`）。应给出有意义的降级显示，同时发出 `push_warning` 提醒开发者补充处理

```gdscript
# ❌ 错误：兜底分支暴露原始数据
func _format_effect(effect: Dictionary) -> String:
    match effect.get("type", ""):
        "tower_damage_bonus":
            return "塔伤害+%.0f%%" % [val * 100]
        _:  # 用户看到 {type: xxx, value: yyy}
            return str(effect)

# ✅ 正确：兜底分支降级显示 + 警告
func _format_effect(effect: Dictionary) -> String:
    var effect_type: String = effect.get("type", "")
    var val = effect.get(effect_type, effect.get("value", 0))

    match effect_type:
        "tower_damage_bonus":
            return tr("EFFECT_TOWER_DMG") % [val * 100]
        "tower_attack_speed_bonus":
            return tr("EFFECT_TOWER_ATK_SPD") % [val * 100]
        "enemy_slow":
            return tr("EFFECT_SLOW") % [val * 100]
        "enemy_dot":
            return tr("EFFECT_DOT") % [val * 100]
        "attribute_bonus":
            var attr: String = effect.get("attribute", "")
            return tr("EFFECT_ATTR") % [tr("ATTR_" + attr.to_upper()), val]
        "gold_bonus":
            return tr("EFFECT_GOLD") % [int(val)]
        _:
            push_warning("未知效果类型 '%s'，请补充 format 分支" % effect_type)
            return tr("EFFECT_UNKNOWN") % [effect_type, val]
```

**适用范围**: 所有面向用户输出的 `match` 格式化函数——效果格式化、状态文本、类型名称转换等

**踩坑记录**: [§76 效果类型 match 遗漏](./踩坑记录完整索引.md#76-效果类型match遗漏-🟡-中) | [§77 属性名国际化缺失](./踩坑记录完整索引.md#77-属性名国际化缺失-🟡-中)

---

### 22.8 动态文本必须 i18n 🔴 强制

**规则**: 程序化构建 UI 时，所有动态生成的用户可见文本必须经过 `tr()` 翻译。枚举值/key 到翻译键的映射模式为 `tr("{CATEGORY}_{KEY}".to_upper())`

```gdscript
# ❌ 错误：硬编码或直接拼接未翻译 key
label.text = "伤害：%d" % damage                    # 硬编码中文
label.text = "%s: +%d" % [attr_name, value]         # 未翻译属性名
text = "%s+%d%%" % ["塔伤害", bonus]                # 直接中文

# ✅ 正确：所有用户可见文本走 tr()
label.text = tr("DAMAGE_FORMAT") % [damage]          # tr + 数组参数
label.text = tr("ATTRIBUTE_BONUS") % [
    tr("ATTR_" + attr_name.to_upper()),              # key → 翻译键
    value
]
text = tr("TOWER_DMG_BONUS_FMT") % [int(bonus * 100)]

# 属性名翻译键映射表
# intelligence → ATTR_INTELLIGENCE → "智力" / "Intelligence"
# strength     → ATTR_STRENGTH     → "力量" / "Strength"
# agility      → ATTR_AGILITY      → "敏捷" / "Agility"
```

**动态文本 i18n 检查清单**:
- [ ] 数值格式化字符串使用 tr() 翻译键
- [ ] 枚举/key 值通过 `to_upper()` 映射到翻译键
- [ ] tr() 的 `%` 格式化传数组参数 `[arg]`（见 §74）
- [ ] match 兜底分支也使用 tr()（见 §77）
- [ ] 无硬编码中文字符串残留

**踩坑记录**: [§74 tr() 格式化参数类型](./踩坑记录完整索引.md#74-tr格式化参数类型-🟡-中) | [§77 属性名国际化缺失](./踩坑记录完整索引.md#77-属性名国际化缺失-🟡-中)

---

### 22.9 SIZE_EXPAND_FILL 自适应填充 🟢 参考

**规则**: 需要自适应填充可用空间的子节点，设置 `size_flags_horizontal` 和/或 `size_flags_vertical` 为 `SIZE_EXPAND_FILL`

```gdscript
# ✅ 内容区域自适应填充剩余空间
var scroll: ScrollContainer = ScrollContainer.new()
scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL  # 垂直方向撑满
parent_vbox.add_child(scroll)

var list: VBoxContainer = VBoxContainer.new()
list.size_flags_horizontal = Control.SIZE_EXPAND_FILL   # 水平方向撑满
scroll.add_child(list)

# ✅ 多列等宽布局
var hbox: HBoxContainer = HBoxContainer.new()
add_child(hbox)

var left_panel: PanelContainer = PanelContainer.new()
left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
hbox.add_child(left_panel)

var right_panel: PanelContainer = PanelContainer.new()
right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
hbox.add_child(right_panel)
# 左右各占 50%

# ✅ 按比例分配（2:1）
var main_area: PanelContainer = PanelContainer.new()
main_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
main_area.size_flags_stretch_ratio = 2.0  # 占 2/3
hbox.add_child(main_area)

var side_bar: PanelContainer = PanelContainer.new()
side_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
side_bar.size_flags_stretch_ratio = 1.0  # 占 1/3
hbox.add_child(side_bar)
```

**SizeFlags 常用值**:
| 值 | 含义 | 使用场景 |
|----|------|---------|
| `SIZE_FILL` | 填充但不扩展 | 固定比例分配 |
| `SIZE_EXPAND` | 扩展占据额外空间 | 优先占用剩余空间 |
| `SIZE_EXPAND_FILL` | 扩展+填充 | 自适应撑满（最常用） |
| `SIZE_SHRINK_BEGIN` | 从开头收缩 | 文本截断 |
| `SIZE_SHRINK_CENTER` | 居中收缩 | 居中对齐 |

---

### 22.10 JSON 数据访问安全模式 🟡 建议

**规则**: 读取外部 JSON 数据配置时，通过单例配置系统（如 TraitSystem、TowerConfigManager）获取结构化数据，避免在 UI 代码中直接硬编码字段名字符串

```gdscript
# ❌ 错误：UI代码中散落字典字段访问
var trait_id: String = trait_dict.get("id", "")       # 字段名可能不对
var name: String = trait_dict.get("name", "")
var effects: Array = trait_dict.get("effects", [])

# ✅ 正确：通过单例获取，字段访问封装在 Bean/DataClass 中
var trait_cfg: TraitConfig = TraitSystem.get_trait_config(trait_id_str)
var display_name: String = tr(trait_cfg.name_key)     # 已封装的字段
var effects: Array[TEffectData] = trait_cfg.effects    # 类型安全的数组

# ✅ 如果必须直接读 JSON，先用 keys() 确认结构
var data: Dictionary = JSON.parse_string(json_text).data
print("JSON keys: %s" % str(data.keys()))  # 先打印确认
var actual_id: String = data.get("trait_id", data.get("id", ""))  # 兼容两种命名
```

**预防措施**:
1. 新增 JSON 数据源时同步创建对应的 Data Class 封装
2. 单元测试验证 JSON 解析结果的完整性
3. UI 代码只调用单例接口，不直接操作原始字典

**踩坑记录**: [§73 JSON 字段名不匹配](./踩坑记录完整索引.md#73-json字段名不匹配-🟡-中)

---

### 22.11 UI 程序化构建代码审查清单

**布局架构**:
- [ ] 外层使用 MarginContainer 管理统一边距
- [ ] ColorRect 背景设置了 `MOUSE_FILTER_IGNORE`
- [ ] PanelContainer 使用 StyleBoxFlat 实现模块分隔
- [ ] 同行多面板用 HBoxContainer 包裹
- [ ] add_child 顺序符合预期渲染层级（底层→顶层）
- [ ] 面板留白用 MarginContainer，不用 offset

**信号连接**:
- [ ] 所有 `signal.connect()` 前有 `is_connected()` 守卫
- [ ] 信号连接集中在 `_connect_signals()` 方法中
- [ ] 热重载不会产生重复连接错误

**数据与国际化**:
- [ ] 所有用户可见文本经过 `tr()` 翻译
- [ ] tr() 格式化传数组参数 `[arg]`
- [ ] 属性名/枚举通过 `to_upper()` 映射到翻译键
- [ ] JSON 字段访问通过单例/Bean 封装，不硬编码字段名
- [ ] match 兜底分支不输出原始数据

**交互体验**:
- [ ] 即时提示用 PopupPanel 替代 tooltip_text
- [ ] PopupPanel 及子节点设置 `MOUSE_FILTER_IGNORE`
- [ ] Tooltip 有边界检测防止超出屏幕
- [ ] SIZE_EXPAND_FILL 用于自适应填充区域

**踩坑关联总表**:
| 编号 | 问题 | 严重性 | 快速跳转 |
|------|------|--------|----------|
| §69 | ColorRect 鼠标事件吞噬 | 🔴 高 | [查看](./踩坑记录完整索引.md#69-colorrect鼠标事件吞噬-🔴-高) |
| §70 | z-index 遮挡问题 | 🟡 中 | [查看](./踩坑记录完整索引.md#70-z-index遮挡问题-🟡-中) |
| §71 | offset vs MarginContainer | 🟡 中 | [查看](./踩坑记录完整索引.md#71-offset-vs-margincontainer-🟡-中) |
| §72 | Signal 重复连接 | 🟡 中 | [查看](./踩坑记录完整索引.md#72-signal重复连接-🟡-中) |
| §73 | JSON 字段名不匹配 | 🟡 中 | [查看](./踩坑记录完整索引.md#73-json字段名不匹配-🟡-中) |
| §74 | tr() 格式化参数类型 | 🟡 中 | [查看](./踩坑记录完整索引.md#74-tr格式化参数类型-🟡-中) |
| §75 | Godot 内置 tooltip 延迟 | 🟡 中 | [查看](./踩坑记录完整索引.md#75-godot内置tooltip延迟-🟡-中) |
| §76 | 效果类型 match 遗漏 | 🟡 中 | [查看](./踩坑记录完整索引.md#76-效果类型match遗漏-🟡-中) |
| §77 | 属性名国际化缺失 | 🟡 中 | [查看](./踩坑记录完整索引.md#77-属性名国际化缺失-🟡-中) |

---

## 📚 学习资源

### 官方文档
- [GDScript 基础](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [GDScript 进阶](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_advanced.html)
- [资源系统](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)

### 最佳实践
- [Godot 最佳实践](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
- [Godot 风格指南](https://docs.godotengine.org/en/stable/community/style_guide.html)

---

**文档版本**: 2.3
**最后更新**: 2026-04-21
**维护者**: Knowledge Base Administrator
**来源**: 知识库 Base 层 `base/practical-experiences/code-standards/`

---

## 23. Buff系统与伤害计算规范 🆕

> **踩坑关联**: [§78 apply_buff复合修改config](./踩坑记录完整索引.md#78-apply_buff-复合修改-config-导致-timer-报错-🔴-高) | [§79 暴击伤害未含trait加成](./踩坑记录完整索引.md#79-暴击伤害计算未包含-trait-加成-🔴-高) | [§80 add_theme_stylebox_override误用](./踩坑记录完整索引.md#80-add_theme_stylebox_override-vs-set_theme_stylebox_override-🔴-高)

### 23.1 共享资源对象不可变原则 🔴 强制

**规则**: Godot 中 Resource 对象（如 TowerBean/Config）可能被多个节点共享引用，永远不要直接修改其属性值作为"运行时状态"。应保存基础值副本（如 `_base_damage`），从基础值 + bonus 计算有效值。

**原因**: Resource 对象在 Godot 中是引用语义，`tower.config` 与 `attack_component.config` 可能指向同一实例。直接修改共享 config 的属性会导致：
1. 其他引用方看到被修改的值（非预期）
2. 每帧重复修改导致值复合增长（指数级膨胀）
3. 派生值（如 `wait_time = 1/speed`）可能变为 0 或无穷大

```gdscript
# ❌ 错误：直接修改共享 config，每帧复合增长
func apply_buff(buff_dmg: float, buff_spd: float) -> void:
    attack_component.config.damage *= (1.0 + buff_dmg)    # 每帧乘！指数增长！
    attack_component.config.attack_speed *= (1.0 + buff_spd)
    attack_component.setup_timer()

# ✅ 正确：保存基础值，从基础值计算有效值
var _base_damage: float = 0.0
var _base_attack_speed: float = 0.0

func setup_tower() -> void:
    _base_damage = config.damage           # 初始化时保存基础值
    _base_attack_speed = config.attack_speed

func apply_buff(buff_dmg: float, buff_spd: float) -> void:
    var effective_dmg: float = _base_damage * (1.0 + buff_dmg)      # 从基础值计算
    var effective_spd: float = _base_attack_speed * (1.0 + buff_spd)
    attack_component.setup_timer_with_buffs(effective_dmg, effective_spd)
```

**适用场景**:
- buff/debuff 系统（攻击力加成、攻速加成等）
- 光环效果（范围增益/减益）
- 动态属性修改（等级提升、装备加成等）
- 任何需要从基础值 + 修正值计算有效值的场景

**核心模式**:
```
基础值（不可变） + bonus（可变） = 有效值（每帧从基础值重新计算）
```

**踩坑记录**: [§78 apply_buff 复合修改 config 导致 Timer 报错](./踩坑记录完整索引.md#78-apply_buff-复合修改-config-导致-timer-报错-🔴-高)

---

### 23.2 伤害计算一致性原则 🔴 强制

**规则**: 所有伤害计算（普通攻击、暴击、AOE、DOT 等）必须使用相同的伤害公式，包含所有适用的加成（trait、buff、等级等）。在 effect_system 中计算伤害时，必须调用与攻击方法相同的加成计算逻辑。

**原因**: 伤害计算逻辑散布在多个方法中时，新增的伤害类型（暴击、AOE、DOT等）容易遗漏某些加成，导致伤害数值不符合预期。这种 Bug 隐蔽性高——普通攻击看起来正常，只有特定伤害类型偏低。

```gdscript
# ❌ 错误：暴击只用基础伤害，遗漏 trait 加成
func _apply_crit(source_tower: Tower, target: Node2D, multiplier: float) -> void:
    var crit_damage: float = source_tower.config.damage * multiplier  # 缺少 trait！

# ✅ 正确：使用与攻击方法相同的伤害公式
func _apply_crit(source_tower: Tower, target: Node2D, multiplier: float) -> void:
    var base_dmg: float = source_tower.config.damage
    var ts: Node = get_node_or_null("/root/TraitSystem")
    var trait_bonus: float = 0.0
    if ts and ts.has_method("get_trait_effects_for_tower"):
        trait_bonus = ts.get_trait_effects_for_tower(source_tower.config.tower_id)
    var effective_dmg: float = base_dmg * (1.0 + trait_bonus)
    var crit_damage: float = effective_dmg * multiplier
```

**推荐做法 —— 提取统一的伤害计算方法**:

```gdscript
# ✅ 最佳实践：提取统一的 get_effective_damage() 方法
func get_effective_damage(tower: Tower) -> float:
    var base_dmg: float = tower.config.damage
    var trait_bonus: float = _get_trait_bonus(tower)
    var buff_bonus: float = _get_buff_bonus(tower)
    return base_dmg * (1.0 + trait_bonus) * (1.0 + buff_bonus)

# 所有伤害计算都调用统一方法
func perform_attack(tower: Tower, target: Node2D) -> void:
    var damage: float = get_effective_damage(tower)
    target.take_damage(damage)

func _apply_crit(tower: Tower, target: Node2D, multiplier: float) -> void:
    var damage: float = get_effective_damage(tower) * multiplier
    target.take_damage(damage)

func _apply_aoe(tower: Tower, targets: Array, multiplier: float) -> void:
    var damage: float = get_effective_damage(tower) * multiplier
    for target in targets:
        target.take_damage(damage)
```

**适用场景**:
- 暴击效果（crit multiplier）
- AOE 效果（范围伤害倍率）
- DOT 效果（持续伤害倍率）
- 任何基于塔伤害的效果

**踩坑记录**: [§79 暴击伤害计算未包含 trait 加成](./踩坑记录完整索引.md#79-暴击伤害计算未包含-trait-加成-🔴-高)

---

### 23.3 主题覆盖 API 规范 🔴 强制

**规则**: Godot 4.x 中覆盖主题属性统一使用 `add_theme_*_override()` 系列方法，不存在 `set_theme_*_override()` 方法。

**原因**: Godot 3.x -> 4.x 的 API 变更。Godot 4 对主题系统做了全面重构，所有 `set_theme_*_override()` 方法统一改为 `add_theme_*_override()`。"add" 语义更准确——它是在主题覆盖列表中添加一项，而非简单的"设置"。

```gdscript
# ❌ 错误：Godot 3.x API（Godot 4 中不存在）
button.set_theme_stylebox_override("normal", style)     # Nonexistent function!
button.set_theme_color_override("font_color", color)    # Nonexistent function!
button.set_theme_font_override("font", font)            # Nonexistent function!
button.set_theme_font_size_override("font_size", 16)    # Nonexistent function!
button.set_theme_constant_override("margin_left", 20)   # Nonexistent function!

# ✅ 正确：Godot 4.x API
button.add_theme_stylebox_override("normal", style)
button.add_theme_color_override("font_color", color)
button.add_theme_font_override("font", font)
button.add_theme_font_size_override("font_size", 16)
button.add_theme_constant_override("margin_left", 20)
```

**Godot 4.x 主题覆盖 API 完整列表**:

| 类型 | 方法 | 参数类型 | 用途 |
|------|------|----------|------|
| StyleBox | `add_theme_stylebox_override(name, stylebox)` | StyleBox | 覆盖样式盒（normal/hover/pressed等） |
| Color | `add_theme_color_override(name, color)` | Color | 覆盖颜色（font_color/icon_color等） |
| Font | `add_theme_font_override(name, font)` | Font | 覆盖字体 |
| FontSize | `add_theme_font_size_override(name, size)` | int | 覆盖字号 |
| Constant | `add_theme_constant_override(name, constant)` | int | 覆盖常量（margin/separation等） |

**常见用例**:
```gdscript
# PanelContainer 样式覆盖
var panel: PanelContainer = PanelContainer.new()
var style: StyleBoxFlat = StyleBoxFlat.new()
style.bg_color = Color(0.18, 0.18, 0.24, 0.9)
style.set_border_width_all(1)
style.set_corner_radius_all(6)
panel.add_theme_stylebox_override("panel", style)  # ✅

# Label 字体颜色覆盖
var label: Label = Label.new()
label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.92))  # ✅

# MarginContainer 边距覆盖
var margin: MarginContainer = MarginContainer.new()
margin.add_theme_constant_override("margin_left", 20)    # ✅
margin.add_theme_constant_override("margin_right", 20)   # ✅
margin.add_theme_constant_override("margin_top", 10)     # ✅
margin.add_theme_constant_override("margin_bottom", 10)  # ✅
```

**踩坑记录**: [§80 add_theme_stylebox_override vs set_theme_stylebox_override](./踩坑记录完整索引.md#80-add_theme_stylebox_override-vs-set_theme_stylebox_override-🔴-高)

---

### 23.4 Buff系统与伤害计算代码审查清单

**共享资源不可变**:
- [ ] 不直接修改共享 Resource/Config 对象的属性作为运行时状态
- [ ] Buff/Debuff 系统保存基础值副本（`_base_damage` 等）
- [ ] 有效值从基础值 + bonus 每帧重新计算，不做累积乘法
- [ ] `apply_buff()` 只存 bonus 值，不修改 config 属性
- [ ] Timer 的 wait_time 不会因复合增长变为 0

**伤害计算一致性**:
- [ ] 所有伤害类型使用统一的伤害公式
- [ ] 暴击/AOE/DOT 伤害包含 trait 加成
- [ ] 暴击/AOE/DOT 伤害包含 buff 加成
- [ ] 提取了 `get_effective_damage()` 统一方法
- [ ] 新增伤害类型时对照攻击方法确认加成完整性

**主题覆盖 API**:
- [ ] 使用 `add_theme_*_override()` 而非 `set_theme_*_override()`
- [ ] StyleBox 覆盖使用 `add_theme_stylebox_override()`
- [ ] 颜色覆盖使用 `add_theme_color_override()`
- [ ] 字体覆盖使用 `add_theme_font_override()`
- [ ] 字号覆盖使用 `add_theme_font_size_override()`
- [ ] 常量覆盖使用 `add_theme_constant_override()`

**踩坑关联总表**:
| 编号 | 问题 | 严重性 | 快速跳转 |
|------|------|--------|----------|
| §78 | apply_buff 复合修改 config | 🔴 高 | [查看](./踩坑记录完整索引.md#78-apply_buff-复合修改-config-导致-timer-报错-🔴-高) |
| §79 | 暴击伤害未含 trait 加成 | 🔴 高 | [查看](./踩坑记录完整索引.md#79-暴击伤害计算未包含-trait-加成-🔴-高) |
| §80 | add_theme_stylebox_override 误用 | 🔴 高 | [查看](./踩坑记录完整索引.md#80-add_theme_stylebox_override-vs-set_theme_stylebox_override-🔴-高) |
| §81 | 暴击特效额外伤害实例 | 🔴 高 | [查看](./踩坑记录完整索引.md#81-暴击特效不应作为额外伤害实例-🔴-高) |
| §82 | debuff_amount 设置未使用 | 🟡 中 | [查看](./踩坑记录完整索引.md#82-debuff_amount设置但未使用导致效果不生效-🟡-中) |
| §83 | 翻译键不匹配格式化报错 | 🔴 高 | [查看](./踩坑记录完整索引.md#83-翻译键不匹配导致格式化报错-🔴-高) |
| §84 | 终局状态机被UI回调覆盖 | 🔴 高 | [查看](./踩坑记录完整索引.md#84-终局状态机被ui回调覆盖-🔴-高) |
| §85 | ParticleProcessMaterial.color_ramp 类型 | 🟡 中 | [查看](./踩坑记录完整索引.md#85-particleprocessmaterialcolor_ramp类型限制-🟡-中) |

---

## 24. 战斗系统与效果规范 🆕

### 24.1 暴击=伤害倍率而非额外伤害实例 🔴 强制

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

# effect_system.gd - execute_effects跳过CRIT类型
func execute_effects(effects: Array, source: Node2D, target: Node2D) -> void:
    for effect in effects:
        match effect.get("type", ""):
            "CRIT":
                continue  # 跳过CRIT，暴击已在攻击流程中处理
            "SLOW":
                _apply_slow(target, effect)
```

**踩坑记录**: [§81 暴击特效不应作为额外伤害实例](./踩坑记录完整索引.md#81-暴击特效不应作为额外伤害实例-🔴-高)

---

### 24.2 debuff效果验证 🟡 建议

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

**踩坑记录**: [§82 debuff_amount设置但未使用导致效果不生效](./踩坑记录完整索引.md#82-debuff_amount设置但未使用导致效果不生效-🟡-中)

---

### 24.3 翻译键一致性 🔴 强制

**规则**: 代码中使用的tr()键名必须与translations.csv中完全一致，包括大小写和后缀。新增翻译键时必须同步更新CSV文件

**原因**: 键名不匹配时tr()返回键名本身，后续%格式化因无占位符而报错 "not all arguments converted"

```gdscript
# ❌ 错误：翻译键与CSV不匹配
var text: String = tr("ENEMY_DEBUFFED") % [slow_amount, slow_timer]  # CSV中只有ENEMY_DEBUFF

# ✅ 正确：确保键名完全一致
var text: String = tr("ENEMY_DEBUFF") % [slow_amount, slow_timer]
```

**踩坑记录**: [§83 翻译键不匹配导致格式化报错](./踩坑记录完整索引.md#83-翻译键不匹配导致格式化报错-🔴-高)

---

### 24.4 状态机回调防护 🔴 强制

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

**踩坑记录**: [§84 终局状态机被UI回调覆盖](./踩坑记录完整索引.md#84-终局状态机被ui回调覆盖-🔴-高)

---

### 24.5 ParticleProcessMaterial颜色设置 🟡 建议

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

**踩坑记录**: [§85 ParticleProcessMaterial.color_ramp类型限制](./踩坑记录完整索引.md#85-particleprocessmaterialcolor_ramp类型限制-🟡-中)

---

### 24.6 战斗系统代码审查清单

**暴击与伤害**:
- [ ] 暴击效果作为伤害倍率处理，不是额外伤害实例
- [ ] effect_system的execute_effects跳过CRIT类型
- [ ] take_damage中正确使用所有抗性降低值（armor_break + debuff）
- [ ] 新增状态效果时验证效果值在伤害计算中被实际使用

**翻译与状态**:
- [ ] tr()键名与translations.csv完全一致
- [ ] UI回调中切换状态前检查当前状态

**粒子效果**:
- [ ] ParticleProcessMaterial渐变色使用GradientTexture1D包装
- [ ] 纯色粒子优先使用process_mat.color
