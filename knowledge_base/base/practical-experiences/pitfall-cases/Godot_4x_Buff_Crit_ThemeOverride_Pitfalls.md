# Godot 4.x Buff系统/伤害计算/主题API踩坑记录

> **记录日期**: 2026-04-21
> **适用版本**: Godot 4.x
> **项目**: Tower Defense 塔防项目
> **严重性**: 2x 🔴高 + 1x 🔴高

---

## §78 apply_buff 复合修改 config 导致 Timer 报错 🔴 高

### 问题现象

```
E 0:01:23:698   tower_attack_component.gd:53 @ setup_timer(): Time should be greater than zero.
   <C++ 错误>      Condition "p_time <= 0" is true.
   <栈追踪>         tower_attack_component.gd:53 @ setup_timer()
                 tower.gd:314 @ apply_buff()
                 effect_system.gd:184 @ _update_auras()
                 effect_system.gd:10 @ _process()
```

### 根因分析

1. `tower.gd:apply_buff()` 直接修改 `attack_component.config.damage` 和 `attack_component.config.attack_speed`
2. `attack_component.config` 与 `tower.config` 是**同一对象引用**（共享 Resource）
3. 每帧从 `_update_auras()` 调用 `apply_buff()`，值不断复合增长：`config.damage = config.damage * (1 + bonus)`
4. 复合增长导致 `attack_speed -> infinity`，`wait_time = 1/speed -> 0`，触发 Timer 报错

**关键认知**：Resource 对象在 Godot 中是引用语义，多个节点持有同一 Resource 实例时，任何一方修改属性都会影响所有引用方。每帧对同一属性做乘法运算，数值会指数级增长。

### 修复方案

1. 新增 `_base_damage` / `_base_attack_speed` 存储初始值（不被修改）
2. 在 `setup_tower()` 中保存基础值：`_base_damage = config.damage; _base_attack_speed = config.attack_speed`
3. 新增 `setup_timer_with_buffs(buff_dmg, buff_spd)` 方法，从基础值 + bonus 计算有效值
4. `apply_buff()` 不再修改 config，只存 bonus 值并调用 `setup_timer_with_buffs()`

```gdscript
# ❌ 错误：直接修改共享 config，每帧复合增长
func apply_buff(buff_dmg: float, buff_spd: float) -> void:
    attack_component.config.damage *= (1.0 + buff_dmg)    # 每帧乘！
    attack_component.config.attack_speed *= (1.0 + buff_spd)  # 指数增长！
    attack_component.setup_timer()

# ✅ 正确：保存基础值，从基础值计算有效值
var _base_damage: float = 0.0
var _base_attack_speed: float = 0.0

func setup_tower() -> void:
    _base_damage = config.damage
    _base_attack_speed = config.attack_speed

func apply_buff(buff_dmg: float, buff_spd: float) -> void:
    var effective_dmg: float = _base_damage * (1.0 + buff_dmg)
    var effective_spd: float = _base_attack_speed * (1.0 + buff_spd)
    attack_component.setup_timer_with_buffs(effective_dmg, effective_spd)
```

### 核心规则

🔴 **强制** —— 永远不要直接修改共享的 config/resource 对象的属性值作为"运行时状态"。应保存基础值副本，从基础值 + bonus 计算有效值。

### 涉及文件

- `scripts/view/tower/tower.gd` — apply_buff(), _update_buff(), _base_damage, _base_attack_speed
- `scripts/view/tower/tower_attack_component.gd` — setup_timer_with_buffs(), _create_timer_from_speed()

---

## §79 暴击伤害计算未包含 trait 加成 🔴 高

### 问题现象

暴击塔的伤害数值明显低于预期。普通攻击伤害符合预期，但暴击伤害仅为基础伤害 x 暴击倍率，缺少 trait 加成。

### 根因分析

1. `effect_system.gd:_apply_crit()` 使用 `source_tower.config.damage * multiplier` 计算暴击伤害
2. `config.damage` 是基础伤害值，不包含 trait 加成
3. 而正常攻击（`perform_melee_attack`/`perform_ranged_attack`）使用 `config.damage * (1 + trait_bonus)` 计算实际伤害
4. 导致暴击伤害 = 基础伤害 x 暴击倍率，而非 实际伤害 x 暴击倍率

**伤害公式不一致是隐蔽 Bug 的典型来源**：当伤害计算逻辑散布在多个方法中时，新增的伤害类型（暴击、AOE、DOT等）容易遗漏某些加成。

### 修复方案

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

### 核心规则

🔴 **强制** —— 所有伤害计算必须使用与攻击方法相同的公式（含 trait 加成、buff 加成等），保持一致性。

### 涉及文件

- `scripts/logic/tower_defense/effect_system.gd` — _apply_crit()

---

## §80 add_theme_stylebox_override vs set_theme_stylebox_override 🔴 高

### 问题现象

```
E 0:00:01:860   TargetInfoPanel._setup_ui: Invalid call. Nonexistent function 'set_theme_stylebox_override' in base 'Button'.
   <GDScript 源文件>target_info_panel.gd:99 @ TargetInfoPanel._setup_ui()
```

### 根因分析

1. 误用 `set_theme_stylebox_override()` 方法
2. Godot 4.x 正确 API 是 `add_theme_stylebox_override()`
3. 这是 Godot 3.x -> 4.x 的 API 变更，Godot 4 统一使用 `add_theme_*_override` 系列方法

**API 变更背景**：Godot 4 对主题系统做了全面重构，所有 `set_theme_*_override()` 方法统一改为 `add_theme_*_override()`。"add"语义更准确——它是在主题覆盖列表中添加一项，而非简单的"设置"。

### 修复

```gdscript
# ❌ 错误：Godot 3.x API
button.set_theme_stylebox_override("normal", style)

# ✅ 正确：Godot 4.x API
button.add_theme_stylebox_override("normal", style)
```

### Godot 4.x 主题覆盖 API 完整列表

| 类型 | 方法 | 用途 |
|------|------|------|
| StyleBox | `add_theme_stylebox_override(name, stylebox)` | 覆盖样式盒 |
| Color | `add_theme_color_override(name, color)` | 覆盖颜色 |
| Font | `add_theme_font_override(name, font)` | 覆盖字体 |
| FontSize | `add_theme_font_size_override(name, size)` | 覆盖字号 |
| Constant | `add_theme_constant_override(name, constant)` | 覆盖常量 |

### 核心规则

🔴 **强制** —— Godot 4.x 中覆盖主题属性统一使用 `add_theme_*_override()` 系列方法，不存在 `set_theme_*_override()` 方法。

### 涉及文件

- `scripts/ui/target_info_panel.gd`

---

## 关联编码规范

本文件中的踩坑经验提炼为以下编码规范：

1. **共享资源对象不可变原则**（§78 提炼）—— 详见 [Godot 编码规范汇总 - 23.1](../../Godot%20编码规范汇总.md#231-共享资源对象不可变原则-🔴-强制)
2. **伤害计算一致性原则**（§79 提炼）—— 详见 [Godot 编码规范汇总 - 23.2](../../Godot%20编码规范汇总.md#232-伤害计算一致性原则-🔴-强制)
3. **主题覆盖 API 规范**（§80 提炼）—— 详见 [Godot 编码规范汇总 - 23.3](../../Godot%20编码规范汇总.md#233-主题覆盖-api-规范-🔴-强制)

---

**文档版本**: 1.0
**创建日期**: 2026-04-21
**维护者**: Knowledge Base Administrator
