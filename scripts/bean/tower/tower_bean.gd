## 防御塔数据 Bean。承载单座塔的完整静态配置与运行时参数，
## 由 [method from_dict] 从 towers.json 反序列化而来，供 [Tower] 视图和 [TowerAttackComponent] 消费。
class_name TowerBean
extends Resource

## 唯一标识符，对应 towers.json 中的 tower_id 字段
@export var tower_id: String = ""
## 翻译键，通过 [method get_display_name] 获取本地化名称
@export var tower_name: String = ""
@export var tower_level: int = 1
@export var description: String = ""
## 基础伤害值，升级后由 [method TowerConfig.get_damage_at_level] 重算
@export var damage: float = 10.0
## 伤害类型，参见 [enum GameConfig.DamageType]
@export var damage_type: int = 0
## 攻击模式，参见 [enum GameConfig.AttackMode]
@export var attack_mode: int = GameConfig.AttackMode.RANGED
## 攻击范围（像素），决定索敌圆和弹道飞行距离
@export var attack_range: float = 150.0
## 索敌范围（像素），通常比 attack_range 略大以提前锁定目标
@export var detection_range: float = 150.0
## 每秒攻击次数
@export var attack_speed: float = 1.0
@export var windup_duration: float = 0.0
## 弹道飞行速度（像素/秒），近战塔不使用
@export var projectile_speed: float = 300.0
@export var projectile_scene_path: String = ""
## 弹道类型，参见 [enum GameConfig.ProjectileType]
@export var projectile_type: int = GameConfig.ProjectileType.TARGET_LOCKED
@export var pierce_enabled: bool = false
@export var pierce_count: int = 2
## 穿透后每次衰减比例，0.7 表示后续目标仅受 70% 伤害
@export var pierce_damage_decay: float = 0.7
## 特效类型，参见 [enum GameConfig.EffectType]
@export var effect_type: int = GameConfig.EffectType.NONE
@export var effect_radius: float = 50.0
@export var effect_damage_ratio: float = 0.5
@export var effect_max_targets: int = 3
@export var effect_value: float = 0.0
## 建造费用
@export var cost: int = 100
## 卖出返还比例，0.7 = 返还 70% 建造费
@export var sell_ratio: float = 0.7
@export var max_level: int = 10
@export var experience_curve: float = 1.5
@export var base_experience_required: int = 100
## 每级伤害成长率，0.12 表示每级 +12% 基础伤害
@export var damage_growth: float = 0.12
@export var attack_speed_growth: float = 0.1
@export var range_growth: float = 0.05
## 每次命中获得的经验值
@export var experience_on_hit: int = 1
@export var texture_path: String = ""
@export var windup_animation: String = ""
@export var attack_animation: String = ""

var effect_id: String = ""
var effect_name: String = ""
var effect_desc: String = ""
var effect_icon: String = ""
var effect_params: Dictionary = {}
var sub_effects: Array = []
var passive_effect: Dictionary = {}

## 从 JSON 字典反序列化为 TowerBean 实例。
## [param data] 对应 towers.json 中单个塔的完整条目。
static func from_dict(data: Dictionary) -> TowerBean:
	var bean := TowerBean.new()
	# 1. 基础标识
	bean.tower_id = data.get("tower_id", "")
	bean.tower_name = data.get("tower_name", "")
	bean.description = data.get("description", "")
	# 2. 攻击模式映射（JSON 字符串 → 枚举）
	var attack_mode_str: String = data.get("attack_mode", "ranged")
	match attack_mode_str:
		"melee":
			bean.attack_mode = GameConfig.AttackMode.MELEE
		"none":
			bean.attack_mode = GameConfig.AttackMode.NONE
		_:
			bean.attack_mode = GameConfig.AttackMode.RANGED
	# 3. 战斗属性
	var stats: Dictionary = data.get("stats", {})
	bean.damage = float(stats.get("damage", 10))
	bean.attack_speed = float(stats.get("attack_speed", 1.0))
	bean.attack_range = float(stats.get("range", 150))
	# 近战索敌范围需更大以补偿无弹道延迟
	if bean.attack_mode == GameConfig.AttackMode.MELEE:
		bean.detection_range = bean.attack_range + 60.0
	else:
		bean.detection_range = bean.attack_range + 30.0
	bean.projectile_speed = float(stats.get("projectile_speed", 300))
	var dmg_type: String = stats.get("damage_type", "physical")
	bean.damage_type = GameConfig.DamageType.MAGICAL if dmg_type == "magic" else GameConfig.DamageType.PHYSICAL
	# 4. 经济参数
	var cost_data: Dictionary = data.get("cost", {})
	bean.cost = int(cost_data.get("build_cost", 100))
	bean.sell_ratio = float(cost_data.get("sell_ratio", 0.5))
	# 5. 升级成长
	var upgrade: Dictionary = data.get("upgrade_per_level", {})
	bean.max_level = int(upgrade.get("max_level", 10))
	bean.damage_growth = float(upgrade.get("damage_increase", 0.1))
	bean.attack_speed_growth = float(upgrade.get("attack_speed_increase", 0.05))
	# 6. 特效与被动
	_parse_special_effect(bean, data.get("special_effect", {}))
	if data.has("passive_effect"):
		bean.passive_effect = data.passive_effect
	# 7. 纹理路径：缺失时按 tower_id 哈希分配精灵图格子
	if data.has("texture_path") and str(data.texture_path) != "":
		bean.texture_path = str(data.texture_path)
	else:
		var tower_idx: int = bean.tower_id.hash() % 16
		var t_row: int = floori(tower_idx / 4.0)
		var t_col: int = tower_idx % 4
		bean.texture_path = "res://images/towers/Black - Plastic 1 128x128-%d-%d.png" % [t_row, t_col]
	return bean

## 解析 special_effect 字段，将字符串类型映射为枚举并提取参数。
## 默认参数来自 SpecialEffectConfig，JSON overrides 会覆盖默认值。
static func _parse_special_effect(bean: TowerBean, special: Dictionary) -> void:
	var eid: String = special.get("effect_id", "")
	if eid == "":
		return
	bean.effect_id = eid
	var sec: SpecialEffectConfig = SpecialEffectConfig.new()
	bean.effect_name = sec.get_effect_name(eid)
	bean.effect_desc = sec.get_effect_desc(eid)
	bean.effect_icon = sec.get_effect_icon(eid)
	var effect_type_str: String = sec.get_effect_type(eid)
	var defaults: Dictionary = sec.get_default_params(eid)
	var overrides: Dictionary = special.get("overrides", {})
	var params: Dictionary = defaults.duplicate()
	for k: String in overrides:
		params[k] = overrides[k]
	bean.effect_params = params
	match effect_type_str:
		"slow":
			bean.effect_type = GameConfig.EffectType.SLOW
			bean.effect_value = float(params.get("value", 0.2))
		"dot":
			bean.effect_type = GameConfig.EffectType.DOT
			bean.effect_value = float(params.get("value", 5.0))
		"burn":
			bean.effect_type = GameConfig.EffectType.BURN
			bean.effect_value = float(params.get("value", 8.0))
		"splash", "aoe":
			bean.effect_type = GameConfig.EffectType.SPLASH
			bean.effect_radius = float(params.get("radius", 50.0))
		"crit":
			bean.effect_type = GameConfig.EffectType.CRIT
			bean.effect_value = float(params.get("crit_multiplier", 2.0))
		"silence":
			bean.effect_type = GameConfig.EffectType.SILENCE
			bean.effect_value = float(params.get("duration", 1.0))
		"armor_break":
			bean.effect_type = GameConfig.EffectType.ARMOR_BREAK
			bean.effect_value = float(params.get("value", 0.3))
		"confusion":
			bean.effect_type = GameConfig.EffectType.CONFUSION
			bean.effect_value = float(params.get("duration", 2.0))
		"debuff":
			bean.effect_type = GameConfig.EffectType.DEBUFF
			bean.effect_value = float(params.get("value", 0.15))
		"slow_aura":
			bean.effect_type = GameConfig.EffectType.SLOW_AURA
			bean.effect_radius = float(params.get("radius", 200.0))
		"buff_aura":
			bean.effect_type = GameConfig.EffectType.BUFF_AURA
			bean.effect_radius = float(params.get("radius", 200.0))
		"single_control":
			bean.effect_type = GameConfig.EffectType.SINGLE_CONTROL
			bean.effect_value = float(params.get("duration", 3.0))
		"cultural_suppression":
			bean.effect_type = GameConfig.EffectType.CULTURAL_SUPPRESSION
			bean.effect_value = float(params.get("bonus_damage", 0.5))
		"gold_bonus":
			bean.effect_type = GameConfig.EffectType.GOLD_BONUS
			bean.effect_value = float(params.get("gold_per_kill", 0.2))
		"summon":
			bean.effect_type = GameConfig.EffectType.SUMMON
		"pierce":
			bean.pierce_enabled = true
			bean.pierce_count = int(params.get("count", 2))
			bean.pierce_damage_decay = float(params.get("decay", 0.7))
		_:
			bean.effect_type = GameConfig.EffectType.NONE
	var sub_arr: Array = special.get("sub_effects", [])
	for sub: Dictionary in sub_arr:
		bean.sub_effects.append(sub)

## 序列化为字典，用于存档和调试输出。
func to_dict() -> Dictionary:
	return {
		"tower_id": tower_id,
		"tower_name": tower_name,
		"tower_level": tower_level,
		"description": description,
		"damage": damage,
		"damage_type": damage_type,
		"attack_mode": attack_mode,
		"attack_range": attack_range,
		"detection_range": detection_range,
		"attack_speed": attack_speed,
		"cost": cost,
		"sell_ratio": sell_ratio,
		"max_level": max_level,
		"damage_growth": damage_growth,
		"attack_speed_growth": attack_speed_growth,
		"range_growth": range_growth,
		"texture_path": texture_path
	}

## 返回本地化后的塔名称
func get_display_name() -> String:
	return tr(tower_name)

## 返回本地化后的特效名称
func get_display_effect_name() -> String:
	return tr(effect_name)

## 返回本地化后的特效描述
func get_display_effect_desc() -> String:
	return tr(effect_desc)
