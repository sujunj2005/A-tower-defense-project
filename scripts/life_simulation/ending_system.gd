extends Node

var session: GameSessionData

func _ready() -> void:
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
