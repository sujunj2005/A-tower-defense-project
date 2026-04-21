class_name PlayerSaveData
extends Resource

## 解锁的时代
@export var unlocked_eras: Array[String] = ["china_modern"]

## 解锁的职业
@export var unlocked_professions: Array[String] = []

## 货币
@export var currencies: Dictionary = {
	"life_wisdom": 0,
	"destiny_points": 0
}

## 成就
@export var achievements: Array[String] = []

## 解锁的增益
@export var unlocked_buffs: Dictionary = {}

## 游戏统计
@export var play_stats: Dictionary = {
	"total_games": 0,
	"best_ending": "D",
	"total_playtime": 0
}

## 序列化为 Dictionary
func to_dict() -> Dictionary:
	return {
		"unlocked_eras": unlocked_eras,
		"unlocked_professions": unlocked_professions,
		"currencies": currencies,
		"achievements": achievements,
		"unlocked_buffs": unlocked_buffs,
		"play_stats": play_stats
	}

## 从 Dictionary 反序列化
static func from_dict(data: Dictionary) -> PlayerSaveData:
	var save_data = PlayerSaveData.new()
	save_data.unlocked_eras.clear()
	for item in data.get("unlocked_eras", ["china_modern"]):
		save_data.unlocked_eras.append(str(item))
	save_data.unlocked_professions.clear()
	for item in data.get("unlocked_professions", []):
		save_data.unlocked_professions.append(str(item))
	save_data.currencies = data.get("currencies", {"life_wisdom": 0, "destiny_points": 0})
	save_data.achievements.clear()
	for item in data.get("achievements", []):
		save_data.achievements.append(str(item))
	save_data.unlocked_buffs = data.get("unlocked_buffs", {})
	save_data.play_stats = data.get("play_stats", {"total_games": 0, "best_ending": "D", "total_playtime": 0})
	return save_data
