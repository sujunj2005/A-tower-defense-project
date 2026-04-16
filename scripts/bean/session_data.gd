class_name GameSessionData
extends Resource

@export var era_id: String = "china_modern"
@export var family_background: String = "worker"
@export var region: String = "tier2_city"

@export var current_age: int = 6
@export var current_stage: String = "childhood"
@export var stage_index: int = 0

@export var towers: Dictionary = {}
var initial_towers: Dictionary = {}
@export var traits: Array[String] = []
@export var gold: int = 50
@export var home_health: float = 100.0
@export var max_home_health: float = 100.0
@export var battle_start_health: float = -1.0

@export var attributes: Dictionary = {
	"intelligence": 50,
	"courage": 50,
	"health": 100
}

@export var completed_events: Array[String] = []
@export var completed_battles: Array[String] = []

@export var current_battle_id: String = ""
@export var current_battle_deadly: bool = false
@export var current_battle_victory: bool = false
@export var battle_rating: String = "D"
@export var current_battle_waves: Array[Dictionary] = []
@export var ending_reason: String = ""
@export var last_battle_rewards: Dictionary = {}
@export var last_event_traits: Array[String] = []
@export var last_event_towers: Array[Dictionary] = []

func has_tower(tower_id: String) -> bool:
	if not towers.has(tower_id):
		return false
	var count: int = towers[tower_id]
	return count != 0

func can_build_tower(tower_id: String) -> bool:
	if not towers.has(tower_id):
		return false
	var count: int = towers[tower_id]
	return count < 0 or count > 0

func on_tower_built(tower_id: String) -> void:
	if not towers.has(tower_id):
		return
	var count: int = towers[tower_id]
	if count > 0:
		towers[tower_id] = count - 1

func add_tower(tower_id: String, count: int = -1) -> void:
	if towers.has(tower_id):
		var existing: int = towers[tower_id]
		if existing < 0:
			return
		if count < 0:
			towers[tower_id] = -1
		else:
			towers[tower_id] = existing + count
	else:
		towers[tower_id] = count

func save_tower_snapshot() -> void:
	initial_towers = towers.duplicate()

func restore_tower_snapshot() -> void:
	for tower_id: String in initial_towers:
		if towers.has(tower_id):
			var current: int = towers[tower_id]
			var initial: int = initial_towers[tower_id]
			if initial < 0:
				towers[tower_id] = initial
			elif current < 0:
				pass
			else:
				towers[tower_id] = initial

func get_tower_ids() -> Array[String]:
	var result: Array[String] = []
	for tid: String in towers:
		if towers[tid] != 0:
			result.append(tid)
	return result

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
		"completed_battles": completed_battles,
		"current_battle_id": current_battle_id,
		"current_battle_deadly": current_battle_deadly,
		"current_battle_victory": current_battle_victory,
		"battle_rating": battle_rating,
		"current_battle_waves": current_battle_waves
	}

static func from_dict(data: Dictionary) -> GameSessionData:
	var session = GameSessionData.new()
	session.era_id = data.get("era_id", "china_modern")
	session.family_background = data.get("family_background", "worker")
	session.region = data.get("region", "tier2_city")
	session.current_age = data.get("current_age", 6)
	session.current_stage = data.get("current_stage", "childhood")
	session.stage_index = data.get("stage_index", 0)
	var raw_towers: Variant = data.get("towers", {})
	if raw_towers is Dictionary:
		session.towers = raw_towers
	elif raw_towers is Array:
		session.towers.clear()
		for t: String in raw_towers:
			session.towers[t] = -1
	session.traits = data.get("traits", [])
	session.gold = data.get("gold", 50)
	session.home_health = data.get("home_health", 100.0)
	session.max_home_health = data.get("max_home_health", 100.0)
	session.attributes = data.get("attributes", {"intelligence": 50, "courage": 50, "health": 100, "charm": 30, "work_ability": 0, "luck": 30})
	session.completed_events = data.get("completed_events", [])
	session.completed_battles = data.get("completed_battles", [])
	session.current_battle_id = data.get("current_battle_id", "")
	session.current_battle_deadly = data.get("current_battle_deadly", false)
	session.current_battle_victory = data.get("current_battle_victory", false)
	session.battle_rating = data.get("battle_rating", "D")
	var raw_waves: Array = data.get("current_battle_waves", [])
	session.current_battle_waves.clear()
	for w: Dictionary in raw_waves:
		session.current_battle_waves.append(w)
	return session
