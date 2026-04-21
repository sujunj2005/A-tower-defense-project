extends Node

var session: GameSessionData

func _ready() -> void:
	session = Global.get_game_session()
	Global.session_reset.connect(_on_session_reset)

func _on_session_reset() -> void:
	session = Global.get_game_session()

func _get_config_manager() -> Node:
	return get_node_or_null("/root/ConfigManager")

func _get_currency_manager() -> Node:
	return get_node_or_null("/root/CurrencyManager")

func determine_ending(boss_battle_health_percent: float) -> String:
	if boss_battle_health_percent >= 1.0:
		return "S"
	elif boss_battle_health_percent >= 0.8:
		return "A"
	elif boss_battle_health_percent >= 0.5:
		return "B"
	elif boss_battle_health_percent > 0.0:
		return "C"
	else:
		return "D"

func get_ending_config(ending_rating: String) -> Dictionary:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return {}
	var endings_data: Dictionary = cm.load_json("res://data/endings.json")
	if not endings_data.has("endings"):
		return {}
	for ending: Dictionary in endings_data.endings:
		if ending.get("rating", "") == ending_rating:
			return ending
	return {}

func apply_ending_reward(ending_rating: String) -> void:
	var ending: Dictionary = get_ending_config(ending_rating)
	if ending.is_empty():
		return
	var reward: Dictionary = ending.get("reward", {})
	var cm: Node = _get_currency_manager()
	if not cm:
		return
	if reward.has("life_wisdom") and cm.has_method("add_life_wisdom"):
		cm.add_life_wisdom(reward.life_wisdom)
		Global.debug_log("获得人生智慧：%d" % reward.life_wisdom)
	if reward.has("destiny_points") and cm.has_method("add_destiny_points"):
		cm.add_destiny_points(reward.destiny_points)
		Global.debug_log("获得命运点数：%d" % reward.destiny_points)

func get_ending_description(ending_rating: String) -> String:
	var ending: Dictionary = get_ending_config(ending_rating)
	if ending.has("description"):
		return tr(ending.description)
	return tr("UNKNOWN_ENDING")

func get_ending_name(ending_rating: String) -> String:
	var ending: Dictionary = get_ending_config(ending_rating)
	if ending.has("ending_name"):
		return tr(ending.ending_name)
	return tr("UNKNOWN_ENDING") + " " + ending_rating

func determine_ending_by_life() -> String:
	var health: int = session.attributes.get("health", 0)
	var intelligence: int = session.attributes.get("intelligence", 0)
	var courage: int = session.attributes.get("courage", 0)
	var trait_count: int = session.traits.size()
	var has_no_regrets: bool = "no_regrets" in session.traits
	var has_regretful: bool = "regretful" in session.traits
	var ending_reason: String = session.ending_reason
	if ending_reason == "health_depleted":
		if has_no_regrets:
			return "peaceful_departure"
		if health <= -20:
			return "suffering_end"
		return "fading_away"
	if "warm_family" in session.traits and "mother_blessed" in session.traits:
		return "fulfilled_life"
	if "lonely_parent" in session.traits and "emotional_void" in session.traits:
		return "lonely_end"
	if "father_guilt" in session.traits or "unforgivable" in session.traits:
		return "regretful_life"
	if has_no_regrets and intelligence >= 80 and courage >= 70:
		return "legendary_life"
	if trait_count >= 8 and intelligence >= 70:
		return "extraordinary_life"
	if intelligence >= 70 and courage >= 60:
		return "successful_life"
	if courage >= 60:
		return "brave_life"
	if has_regretful:
		return "regretful_life"
	if intelligence >= 50:
		return "ordinary_life"
	return "humble_life"

func generate_life_summary() -> Dictionary:
	var ending_type: String = determine_ending_by_life()
	var ending_data: Dictionary = _get_ending_data(ending_type)
	var summary_parts: Array[String] = []
	summary_parts.append(tr("SUMMARY_FAMILY_ORIGIN") % _get_family_desc())
	if "event_zhongkao" in session.completed_events:
		if "event_gaokao_choice" in session.completed_events:
			summary_parts.append(tr("SUMMARY_UNIVERSITY_PATH"))
		else:
			summary_parts.append(tr("SUMMARY_VOCATIONAL_PATH"))
	else:
		summary_parts.append(tr("SUMMARY_DIFFERENT_PATH"))
	if "event_college_love" in session.completed_events:
		summary_parts.append(tr("SUMMARY_FOUND_LOVE"))
	if "married" in session.traits:
		summary_parts.append(tr("SUMMARY_MARRIED"))
	if "event_first_job" in session.completed_events:
		summary_parts.append(tr("SUMMARY_FIRST_JOB"))
	if session.family_members.get("spouse", {}).get("alive", false):
		summary_parts.append(tr("SUMMARY_SPOUSE_COMPANION"))
	if session.family_members.get("first_child", {}).get("born", false):
		summary_parts.append(tr("SUMMARY_CHILDREN_BORN"))
	if "warm_family" in session.traits:
		summary_parts.append(tr("SUMMARY_WARM_FAMILY"))
	elif "lonely_parent" in session.traits:
		summary_parts.append(tr("SUMMARY_LONELY_ENDING"))
	if session.traits.size() >= 5:
		summary_parts.append(tr("SUMMARY_RICH_LIFE"))
	elif session.traits.size() >= 3:
		summary_parts.append(tr("SUMMARY_UPS_AND_DOWNS"))
	else:
		summary_parts.append(tr("SUMMARY_QUIET_LIFE"))
	var final_age: int = session.current_age
	summary_parts.append(tr("SUMMARY_FINAL_AGE") % [final_age, tr(ending_data.get("ending_phrase", "ENDING_HUMBLE_LIFE_PHRASE"))])
	return {
		"ending_type": ending_type,
		"ending_name": tr(ending_data.get("ending_name", "未知结局")),
		"summary": "".join(summary_parts),
		"rating": ending_data.get("rating", "C"),
		"reward": ending_data.get("reward", {}),
		"description": tr(ending_data.get("description", ""))
	}

func _get_family_desc() -> String:
	match session.family_background:
		"worker", "family_worker":
			return tr("BG_WORKER")
		"farmer", "family_farmer":
			return tr("BG_FARMER")
		"intellectual", "family_intellectual":
			return tr("BG_CADRE")
		"business", "family_business":
			return tr("BG_MERCHANT")
		_:
			return tr("FAMILY_DEFAULT")

func _get_ending_data(ending_type: String) -> Dictionary:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return {}
	var endings_data: Dictionary = cm.load_json("res://data/endings.json")
	if not endings_data.has("endings"):
		return {}
	for ending: Dictionary in endings_data.endings:
		if ending.get("ending_id", "") == ending_type:
			return ending
	return {}
