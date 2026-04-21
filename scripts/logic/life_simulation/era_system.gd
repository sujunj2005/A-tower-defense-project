extends Node

var current_era: Dictionary = {}
var current_family: Dictionary = {}
var current_region: String = "tier2_city"
var session: GameSessionData

func _ready() -> void:
	session = Global.get_game_session()
	Global.session_reset.connect(_on_session_reset)

func _on_session_reset() -> void:
	session = Global.get_game_session()
	current_era = {}
	current_family = {}
	current_region = "tier2_city"

func _get_config_manager() -> Node:
	return get_node_or_null("/root/ConfigManager")

func load_era(era_id: String) -> Error:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return ERR_DOES_NOT_EXIST
	var eras_data: Dictionary = cm.load_json("res://data/eras.json")
	if not eras_data.has("eras"):
		return ERR_DOES_NOT_EXIST
	var eras: Dictionary = eras_data.eras
	if eras.has(era_id):
		current_era = eras[era_id]
		current_era["era_id"] = era_id
		return OK
	return ERR_DOES_NOT_EXIST

func load_family(family_id: String) -> Error:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return ERR_DOES_NOT_EXIST
	var families_data: Dictionary = cm.load_json("res://data/family_backgrounds.json")
	if not families_data.has("family_backgrounds"):
		return ERR_DOES_NOT_EXIST
	for family: Dictionary in families_data.family_backgrounds:
		if family.get("family_id", "") == family_id:
			current_family = family
			return OK
	return ERR_DOES_NOT_EXIST

func initialize_session(
	selected_attributes: Dictionary,
	selected_traits: Array[String]
) -> void:
	session.era_id = current_era["era_id"]
	session.family_background = current_family["family_id"]
	session.region = current_region
	for attr_name: String in ["intelligence", "courage", "health"]:
		session.attributes[attr_name] = selected_attributes[attr_name]
	var initial_res: Dictionary = current_family.initial_resources
	session.gold = apply_gold_bonus(initial_res["gold"])
	var towers_config: Array = initial_res.towers
	for tower_entry: Dictionary in towers_config:
		for tid: String in tower_entry:
			var count: int = int(tower_entry[tid])
			session.add_tower(tid, count)
			Global.debug_log("初始防御塔：%s ×%s" % [tid, "∞" if count < 0 else str(count)])
	for trait_item: String in initial_res.traits:
		session.traits.append(trait_item)
	var base_health: float = float(session.attributes["health"])
	var health_bonus: float = get_family_modifier("health_bonus")
	session.max_home_health = base_health + health_bonus
	session.home_health = session.max_home_health
	session.attributes["health"] = int(session.max_home_health)
	for trait_id: String in selected_traits:
		session.traits.append(trait_id)
		_apply_congenital_trait_effect(trait_id)
	Global.debug_log("[EraSystem] 初始化完成 - 家庭：%s，金币：%d，生命：%.0f/%.0f，塔：%s，金币加成：%.0f%%，塔价格修正：%.0f%%，先天特质：%s" % [
		session.family_background, session.gold,
		session.home_health, session.max_home_health,
		str(session.towers),
		get_family_modifier("gold_bonus") * 100.0,
		get_family_modifier("tower_cost_modifier") * 100.0,
		str(selected_traits)
	])

func _apply_congenital_trait_effect(trait_id: String) -> void:
	get_node("/root/TraitSystem").grant_trait(trait_id)

func get_family_modifier(modifier_type: String) -> float:
	if current_family.has("modifiers"):
		return current_family.modifiers.get(modifier_type, 0.0)
	return 0.0

func apply_gold_bonus(base_gold: int) -> int:
	var bonus: float = get_family_modifier("gold_bonus")
	return int(float(base_gold) * (1.0 + bonus))

func get_tower_cost_modifier() -> float:
	return get_family_modifier("tower_cost_modifier")

func get_modified_tower_cost(base_cost: int) -> int:
	var modifier: float = get_tower_cost_modifier()
	return maxi(int(float(base_cost) * (1.0 + modifier)), 1)

func get_experience_bonus() -> float:
	return get_family_modifier("experience_bonus")
