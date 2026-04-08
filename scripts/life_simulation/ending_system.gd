class_name EndingSystem
extends Node

var session: GameSessionData
var config_manager: ConfigManager

func _ready() -> void:
	session = Global.get_game_session()
	config_manager = Global.get_node("ConfigManager") as ConfigManager

## 判定结局
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

## 获取结局配置
func get_ending_config(ending_rating: String) -> Dictionary:
	var endings_data = config_manager.load_json("res://data/endings.json")
	if not endings_data.has("endings"):
		return {}
	
	for ending in endings_data.endings:
		if ending.get("rating") == ending_rating:
			return ending
	
	return {}

## 应用结局奖励
func apply_ending_reward(ending_rating: String) -> void:
	var ending = get_ending_config(ending_rating)
	if ending.is_empty():
		return
	
	if ending.has("reward"):
		var reward = ending.reward
		var player_save = Global.get_player_save()
		
		if reward.has("life_wisdom"):
			player_save.currencies["life_wisdom"] += reward.life_wisdom
			Global.debug_log("获得人生智慧：%d" % reward.life_wisdom)
		
		if reward.has("destiny_points"):
			player_save.currencies["destiny_points"] += reward.destiny_points
			Global.debug_log("获得命运点数：%d" % reward.destiny_points)

## 获取结局描述
func get_ending_description(ending_rating: String) -> String:
	var ending = get_ending_config(ending_rating)
	if ending.has("description"):
		return ending.description
	return "未知结局"

## 获取结局名称
func get_ending_name(ending_rating: String) -> String:
	var ending = get_ending_config(ending_rating)
	if ending.has("ending_name"):
		return ending.ending_name
	return "结局 " + ending_rating
