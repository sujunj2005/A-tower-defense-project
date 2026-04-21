class_name TowerBean
extends Resource

@export var tower_id: String = ""
@export var tower_name: String = ""
@export var tower_level: int = 1
@export var description: String = ""
@export var damage: float = 10.0
@export var damage_type: int = 0
@export var attack_mode: int = GameConfig.AttackMode.RANGED
@export var attack_range: float = 150.0
@export var detection_range: float = 150.0
@export var attack_speed: float = 1.0
@export var windup_duration: float = 0.0
@export var projectile_speed: float = 300.0
@export var projectile_scene_path: String = ""
@export var projectile_type: int = GameConfig.ProjectileType.POSITION_FIXED
@export var pierce_enabled: bool = false
@export var pierce_count: int = 2
@export var pierce_damage_decay: float = 0.7
@export var effect_type: int = GameConfig.EffectType.NONE
@export var effect_radius: float = 50.0
@export var effect_damage_ratio: float = 0.5
@export var effect_max_targets: int = 3
@export var effect_value: float = 0.0
@export var cost: int = 100
@export var sell_ratio: float = 0.5
@export var max_level: int = 10
@export var experience_curve: float = 1.5
@export var base_experience_required: int = 100
@export var damage_growth: float = 0.2
@export var attack_speed_growth: float = 0.1
@export var range_growth: float = 0.05
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

static func from_dict(data: Dictionary) -> TowerBean:
	var bean := TowerBean.new()
	bean.tower_id = data.get("tower_id", "")
	bean.tower_name = data.get("tower_name", "")
	bean.description = data.get("description", "")
	var attack_mode_str: String = data.get("attack_mode", "ranged")
	match attack_mode_str:
		"melee":
			bean.attack_mode = GameConfig.AttackMode.MELEE
		"none":
			bean.attack_mode = GameConfig.AttackMode.NONE
		_:
			bean.attack_mode = GameConfig.AttackMode.RANGED
	var stats: Dictionary = data.get("stats", {})
	bean.damage = float(stats.get("damage", 10))
	bean.attack_speed = float(stats.get("attack_speed", 1.0))
	bean.attack_range = float(stats.get("range", 150))
	if bean.attack_mode == GameConfig.AttackMode.MELEE:
		bean.detection_range = bean.attack_range + 60.0
	else:
		bean.detection_range = bean.attack_range + 30.0
	bean.projectile_speed = float(stats.get("projectile_speed", 300))
	var dmg_type: String = stats.get("damage_type", "physical")
	bean.damage_type = GameConfig.DamageType.MAGICAL if dmg_type == "magic" else GameConfig.DamageType.PHYSICAL
	var cost_data: Dictionary = data.get("cost", {})
	bean.cost = int(cost_data.get("build_cost", 100))
	bean.sell_ratio = float(cost_data.get("sell_ratio", 0.5))
	var upgrade: Dictionary = data.get("upgrade_per_level", {})
	bean.max_level = int(upgrade.get("max_level", 10))
	bean.damage_growth = float(upgrade.get("damage_increase", 0.1))
	bean.attack_speed_growth = float(upgrade.get("attack_speed_increase", 0.05))
	_parse_special_effect(bean, data.get("special_effect", {}))
	if data.has("passive_effect"):
		bean.passive_effect = data.passive_effect
	if data.has("texture_path") and str(data.texture_path) != "":
		bean.texture_path = str(data.texture_path)
	else:
		var tower_idx: int = bean.tower_id.hash() % 16
		var t_row: int = floori(tower_idx / 4.0)
		var t_col: int = tower_idx % 4
		bean.texture_path = "res://images/towers/Black - Plastic 1 128x128-%d-%d.png" % [t_row, t_col]
	return bean

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

func get_display_name() -> String:
	return tr(tower_name)

func get_display_effect_name() -> String:
	return tr(effect_name)

func get_display_effect_desc() -> String:
	return tr(effect_desc)