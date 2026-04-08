class_name GameSessionData
extends Resource

## 开局配置
@export var era_id: String = "china_modern"
@export var family_background: String = "worker"
@export var region: String = "tier2_city"

## 游戏进度
@export var current_age: int = 6
@export var current_stage: String = "childhood"
@export var stage_index: int = 0

## 战斗资源
@export var towers: Array[Dictionary] = []
@export var traits: Array[String] = []
@export var gold: int = 50
@export var home_health: int = 100
@export var max_home_health: int = 100

## 属性
@export var attributes: Dictionary = {
	"intelligence": 50,
	"courage": 50,
	"health": 100
}

## 进度标记
@export var completed_events: Array[String] = []
@export var completed_battles: Array[String] = []

## 序列化为 Dictionary
func to_dict() -> Dictionary:
	return {
		"era_id": era_id,
		"family_background": family_background,
		"region": region,
		"current_age": current_age,
		"current_stage": current_stage,
		"stage_index": stage_index,
		"towers": towers,
		"traits": traits,
		"gold": gold,
		"home_health": home_health,
		"max_home_health": max_home_health,
		"attributes": attributes,
		"completed_events": completed_events,
		"completed_battles": completed_battles
	}

## 从 Dictionary 反序列化
static func from_dict(data: Dictionary) -> GameSessionData:
	var session = GameSessionData.new()
	session.era_id = data.get("era_id", "china_modern")
	session.family_background = data.get("family_background", "worker")
	session.region = data.get("region", "tier2_city")
	session.current_age = data.get("current_age", 6)
	session.current_stage = data.get("current_stage", "childhood")
	session.stage_index = data.get("stage_index", 0)
	session.towers = data.get("towers", [])
	session.traits = data.get("traits", [])
	session.gold = data.get("gold", 50)
	session.home_health = data.get("home_health", 100)
	session.max_home_health = data.get("max_home_health", 100)
	session.attributes = data.get("attributes", {"intelligence": 50, "courage": 50, "health": 100})
	session.completed_events = data.get("completed_events", [])
	session.completed_battles = data.get("completed_battles", [])
	return session
