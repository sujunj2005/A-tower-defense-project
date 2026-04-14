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
		return ending.description
	return "未知结局"

func get_ending_name(ending_rating: String) -> String:
	var ending: Dictionary = get_ending_config(ending_rating)
	if ending.has("ending_name"):
		return ending.ending_name
	return "结局 " + ending_rating

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
	var stage_names: Dictionary = {
		"childhood": "童年", "youth": "青年",
		"middle_age": "中年", "old_age": "老年"
	}
	summary_parts.append("你出生在一个%s家庭。" % _get_family_desc())
	if "event_zhongkao" in session.completed_events:
		if "event_gaokao_choice" in session.completed_events:
			summary_parts.append("你通过高考进入大学，开启了知识改变命运的道路。")
		else:
			summary_parts.append("你选择了职高路线，早早步入社会。")
	else:
		summary_parts.append("你的求学之路与众不同。")
	if "event_college_love" in session.completed_events:
		summary_parts.append("大学里你遇到了真爱。")
	if "married" in session.traits:
		summary_parts.append("你组建了家庭，有了温暖的港湾。")
	if "event_first_job" in session.completed_events:
		summary_parts.append("你凭借努力获得了第一份工作。")
	if session.traits.size() >= 5:
		summary_parts.append("你的人生经历丰富多彩，积累了深厚的智慧。")
	elif session.traits.size() >= 3:
		summary_parts.append("你的人生有起有落，但始终在前行。")
	else:
		summary_parts.append("你的人生平淡但安稳。")
	var final_age: int = session.current_age
	summary_parts.append("你走过了%d个春秋，最终%s。" % [final_age, ending_data.get("ending_phrase", "画上了句号")])
	return {
		"ending_type": ending_type,
		"ending_name": ending_data.get("ending_name", "未知结局"),
		"summary": "".join(summary_parts),
		"rating": ending_data.get("rating", "C"),
		"reward": ending_data.get("reward", {}),
		"description": ending_data.get("description", "")
	}

func _get_family_desc() -> String:
	match session.family_background:
		"worker", "family_worker":
			return "工人"
		"farmer", "family_farmer":
			return "农民"
		"intellectual", "family_intellectual":
			return "知识分子"
		"business", "family_business":
			return "商人"
		_:
			return "普通"

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
