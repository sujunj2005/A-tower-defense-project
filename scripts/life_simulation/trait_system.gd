extends Node

var session: GameSessionData
var trait_configs: Dictionary[String, Dictionary] = {}

func _ready() -> void:
	session = Global.get_game_session()
	_load_trait_configs()

func _load_trait_configs() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return
	var traits_data: Dictionary = cm.load_json("res://data/traits.json")
	if not traits_data.has("traits"):
		return
	var traits_list: Array = traits_data.get("traits", [])
	for trait_data in traits_list:
		var tid: String = trait_data.get("trait_id", "")
		if tid != "":
			trait_configs[tid] = trait_data

## 授予词条
func grant_trait(trait_id: String) -> void:
	if not trait_id in session.traits:
		session.traits.append(trait_id)
		_apply_trait_effect(trait_id)
		Global.debug_log("获得词条：%s" % trait_id)

## 应用词条效果
func _apply_trait_effect(trait_id: String) -> void:
	if not trait_configs.has(trait_id):
		return
	var config: Dictionary = trait_configs[trait_id]
	if not config.has("effect"):
		return
	var effect: Dictionary = config.effect
	var effect_type: String = effect.get("type", "")
	match effect_type:
		"tower_damage_bonus":
			_apply_tower_damage_bonus(effect)
		"attribute_bonus":
			_apply_attribute_bonus(effect)
		"gold_bonus":
			_apply_gold_bonus(effect)
		"health_bonus":
			_apply_health_bonus(effect)
		"tower_attack_speed_bonus":
			Global.debug_log("词条效果：塔攻速加成 +%.0f%%（被动，由攻击系统自动应用）" % [effect.get("value", 0.0) * 100.0])
		"gold_per_wave":
			Global.debug_log("词条效果：每波金币 +%d（被动，由波次系统自动发放）" % effect.get("value", 0))
		"damage_reduction":
			Global.debug_log("词条效果：伤害减免 +%.0f%%（被动，由战斗系统自动应用）" % [effect.get("value", 0.0) * 100.0])
		"event_trigger_bonus":
			Global.debug_log("词条效果：事件触发率 +%.0f%%（被动，由事件系统自动应用）" % [effect.get("value", 0.0) * 100.0])
		_:
			Global.debug_log("词条效果类型未实现：%s" % effect_type)

func _apply_tower_damage_bonus(effect: Dictionary) -> void:
	var bonus: float = effect.get("tower_damage_bonus", 0.0)
	var tower_types: Array = effect.get("tower_types", [])
	Global.debug_log("词条效果：塔伤害加成 +%.0f%%，适用塔类型：%s" % [bonus * 100.0, str(tower_types)])

func _apply_attribute_bonus(effect: Dictionary) -> void:
	var attr_name: String = effect.get("attribute", "")
	var bonus: int = effect.get("value", 0)
	if attr_name != "" and bonus != 0:
		var asys: Node = get_node_or_null("/root/AttributeSystem")
		if asys and asys.has_method("increase_attribute"):
			asys.increase_attribute(attr_name, bonus)

func _apply_gold_bonus(effect: Dictionary) -> void:
	var bonus: int = effect.get("value", 0)
	if bonus != 0:
		session.gold += bonus
		Global.debug_log("词条效果：金币 %+d" % bonus)

func _apply_health_bonus(effect: Dictionary) -> void:
	var bonus: int = effect.get("value", 0)
	if bonus > 0:
		var asys: Node = get_node_or_null("/root/AttributeSystem")
		if asys and asys.has_method("increase_attribute"):
			asys.increase_attribute("health", bonus)

func get_trait_effects_for_tower(tower_type: String) -> float:
	var total_bonus: float = 0.0
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "tower_damage_bonus":
			var tower_types: Array = effect.get("tower_types", [])
			if tower_types.is_empty() or tower_type in tower_types:
				total_bonus += effect.get("tower_damage_bonus", 0.0)
	return total_bonus

func get_all_damage_bonus_details() -> Dictionary:
	var universal_bonus: float = 0.0
	var specific_bonuses: Dictionary = {}
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "tower_damage_bonus":
			var tower_types: Array = effect.get("tower_types", [])
			var bonus: float = effect.get("tower_damage_bonus", 0.0)
			if tower_types.is_empty():
				universal_bonus += bonus
			else:
				for tt: String in tower_types:
					if not specific_bonuses.has(tt):
						specific_bonuses[tt] = 0.0
					specific_bonuses[tt] += bonus
	return {"universal": universal_bonus, "specific": specific_bonuses}

func get_all_attack_speed_bonus_details() -> Dictionary:
	var universal_bonus: float = 0.0
	var specific_bonuses: Dictionary = {}
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "tower_attack_speed_bonus":
			var tower_types: Array = effect.get("tower_types", [])
			var bonus: float = effect.get("value", 0.0)
			if tower_types.is_empty():
				universal_bonus += bonus
			else:
				for tt: String in tower_types:
					if not specific_bonuses.has(tt):
						specific_bonuses[tt] = 0.0
					specific_bonuses[tt] += bonus
	return {"universal": universal_bonus, "specific": specific_bonuses}

func get_attack_speed_bonus_for_tower(tower_type: String) -> float:
	var total_bonus: float = 0.0
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "tower_attack_speed_bonus":
			var tower_types: Array = effect.get("tower_types", [])
			if tower_types.is_empty() or tower_type in tower_types:
				total_bonus += effect.get("value", 0.0)
	return total_bonus

func get_damage_reduction() -> float:
	var total_reduction: float = 0.0
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "damage_reduction":
			total_reduction += effect.get("value", 0.0)
	return minf(total_reduction, 0.5)

func get_gold_per_wave() -> int:
	var total_gold: int = 0
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "gold_per_wave":
			total_gold += effect.get("value", 0)
	return total_gold

func get_event_trigger_bonus() -> float:
	var total_bonus: float = 0.0
	for trait_id: String in session.traits:
		var config: Dictionary = trait_configs.get(trait_id, {})
		if not config.has("effect"):
			continue
		var effect: Dictionary = config.effect
		if effect.get("type", "") == "event_trigger_bonus":
			total_bonus += effect.get("value", 0.0)
	return total_bonus

## 移除词条
func remove_trait(trait_id: String) -> void:
	if trait_id in session.traits:
		session.traits.erase(trait_id)
		Global.debug_log("移除词条：%s" % trait_id)

## 检查是否拥有词条
func has_trait(trait_id: String) -> bool:
	return trait_id in session.traits

## 获取所有词条
func get_all_traits() -> Array[String]:
	return session.traits.duplicate() as Array[String]

## 获取词条配置
func get_trait_config(trait_id: String) -> Dictionary:
	return trait_configs.get(trait_id, {})
