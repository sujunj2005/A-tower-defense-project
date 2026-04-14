extends Node

signal achievement_unlocked(achievement_id: String)

var player_save: PlayerSaveData
var achievement_configs: Dictionary = {}

var _battle_won_count: int = 0
var _deadly_event_survived_count: int = 0
var _families_completed: Array[String] = []
var _stages_reached: Array[String] = []

func _ready() -> void:
	player_save = Global.get_player_save()
	_load_achievement_configs()

func _load_achievement_configs() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return
	var data: Dictionary = cm.load_json("res://data/achievements.json")
	if not data.has("achievements"):
		return
	for ach: Dictionary in data.achievements:
		achievement_configs[ach.achievement_id] = ach

func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in player_save.achievements

func check_achievement(achievement_id: String) -> bool:
	if is_unlocked(achievement_id):
		return false
	var config: Dictionary = achievement_configs.get(achievement_id, {})
	if config.is_empty():
		return false
	var condition: Dictionary = config.get("condition", {})
	var condition_type: String = condition.get("type", "")
	var met: bool = false
	match condition_type:
		"battle_won":
			met = _battle_won_count >= condition.get("count", 1)
		"ending_reached":
			if player_save.play_stats.has("best_ending"):
				var best: String = player_save.play_stats.best_ending
				var required: String = condition.get("rating", "S")
				met = _is_rating_equal_or_better(best, required)
		"battle_rating":
			met = player_save.play_stats.get("best_battle_rating", "") == condition.get("rating", "S")
		"trait_acquired":
			var trait_id: String = condition.get("trait_id", "")
			var session: GameSessionData = Global.get_game_session()
			met = trait_id in session.traits
		"stages_completed":
			var required_stages: Array = condition.get("stages", [])
			met = true
			for s: String in required_stages:
				if not s in _stages_reached:
					met = false
					break
		"deadly_event_survived":
			met = _deadly_event_survived_count >= condition.get("count", 1)
		"family_ending_combo":
			var family: String = condition.get("family", "")
			var _min_rating: String = condition.get("min_rating", "A")
			met = family in _families_completed
		"families_completed":
			var required_families: Array = condition.get("families", [])
			met = true
			for f: String in required_families:
				if not f in _families_completed:
					met = false
					break
	if met:
		_grant_achievement(achievement_id)
	return met

func _grant_achievement(achievement_id: String) -> void:
	if is_unlocked(achievement_id):
		return
	player_save.achievements.append(achievement_id)
	var config: Dictionary = achievement_configs.get(achievement_id, {})
	var reward: Dictionary = config.get("reward", {})
	for currency_id: String in reward:
		_cm_add_currency(currency_id, reward[currency_id])
	achievement_unlocked.emit(achievement_id)
	Global.debug_log("成就解锁：%s" % config.get("achievement_name", achievement_id))

func _is_rating_equal_or_better(current: String, required: String) -> bool:
	var rating_order: Dictionary = {"S": 5, "A": 4, "B": 3, "C": 2, "D": 1}
	var current_val: int = rating_order.get(current, 0)
	var required_val: int = rating_order.get(required, 0)
	return current_val >= required_val

func on_battle_won() -> void:
	_battle_won_count += 1
	for ach_id: String in achievement_configs:
		if achievement_configs[ach_id].get("condition", {}).get("type", "") == "battle_won":
			check_achievement(ach_id)

func on_ending_reached(rating: String) -> void:
	var rating_order: Dictionary = {"S": 5, "A": 4, "B": 3, "C": 2, "D": 1}
	var best_val: int = rating_order.get(player_save.play_stats.get("best_ending", "D"), 0)
	var current_val: int = rating_order.get(rating, 0)
	if current_val > best_val:
		player_save.play_stats["best_ending"] = rating
	var session: GameSessionData = Global.get_game_session()
	var family: String = session.family_background
	if not family in _families_completed:
		_families_completed.append(family)
	player_save.play_stats["total_games"] = int(player_save.play_stats.get("total_games", 0)) + 1
	for ach_id: String in achievement_configs:
		var cond_type: String = achievement_configs[ach_id].get("condition", {}).get("type", "")
		if cond_type in ["ending_reached", "family_ending_combo", "families_completed"]:
			check_achievement(ach_id)

func on_stage_reached(stage_name: String) -> void:
	if not stage_name in _stages_reached:
		_stages_reached.append(stage_name)
	for ach_id: String in achievement_configs:
		if achievement_configs[ach_id].get("condition", {}).get("type", "") == "stages_completed":
			check_achievement(ach_id)

func on_trait_acquired(trait_id: String) -> void:
	for ach_id: String in achievement_configs:
		var cond: Dictionary = achievement_configs[ach_id].get("condition", {})
		if cond.get("type", "") == "trait_acquired" and cond.get("trait_id", "") == trait_id:
			check_achievement(ach_id)

func on_deadly_event_survived() -> void:
	_deadly_event_survived_count += 1
	for ach_id: String in achievement_configs:
		if achievement_configs[ach_id].get("condition", {}).get("type", "") == "deadly_event_survived":
			check_achievement(ach_id)

func get_achievement_config(achievement_id: String) -> Dictionary:
	return achievement_configs.get(achievement_id, {})

func get_all_achievements() -> Dictionary:
	return achievement_configs.duplicate()

func get_unlocked_achievements() -> Array[String]:
	return player_save.achievements.duplicate() as Array[String]

func _cm_add_currency(currency_id: String, amount: int) -> void:
	var cm: Node = _get_currency_manager()
	if cm and cm.has_method("add_currency"):
		cm.add_currency(currency_id, amount)

func _get_currency_manager() -> Node:
	return get_node_or_null("/root/CurrencyManager")
