extends Node

signal rating_determined(rating: String, health_percent: float)

func determine_rating(health_percent: float) -> String:
	if health_percent >= 1.0:
		return "S"
	elif health_percent >= 0.8:
		return "A"
	elif health_percent >= 0.5:
		return "B"
	elif health_percent > 0.0:
		return "C"
	else:
		return "D"

func determine_battle_rating(home_health: float, max_home_health: float) -> String:
	var health_percent: float = 0.0
	if max_home_health > 0.0:
		health_percent = home_health / max_home_health
	var rating: String = determine_rating(health_percent)
	rating_determined.emit(rating, health_percent)
	Global.debug_log("Battle Rating: %s (Base HP %.0f%%)" % [rating, health_percent * 100.0])
	return rating

func get_rating_gold_reward(rating: String) -> int:
	var es: Node = _get_economy_system()
	if es and es.has_method("get_rating_gold_reward"):
		return es.get_rating_gold_reward(rating)
	return 0

func get_rating_description(rating: String) -> String:
	var descriptions: Dictionary = {
		"S": tr("RATING_S"),
		"A": tr("RATING_A"),
		"B": tr("RATING_B"),
		"C": tr("RATING_C"),
		"D": tr("RATING_D")
	}
	return descriptions.get(rating, tr("RATING_UNKNOWN"))

func apply_battle_rewards(rating: String) -> Dictionary:
	var es: Node = _get_economy_system()
	if es and es.has_method("apply_battle_rewards"):
		return es.apply_battle_rewards(rating)
	return {}

func is_deadly_battle_survived(home_health: float, is_deadly: bool) -> bool:
	return is_deadly and home_health > 0.0

func _get_economy_system() -> Node:
	return get_node_or_null("/root/EconomySystem")
