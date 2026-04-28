class_name GameSessionData
extends Resource

@export var era_id: String = "china_modern"
@export var family_background: String = "worker"
@export var region: String = "tier2_city"
@export var birthday: String = ""

@export var current_age: int = 6
@export var current_stage: String = "childhood"
@export var stage_index: int = 0

@export var towers: Dictionary = {}
var initial_towers: Dictionary = {}
@export var traits: Array[String] = []
@export var gold: int = 100
@export var home_health: float = 100.0
@export var max_home_health: float = 100.0
@export var battle_start_health: float = -1.0
@export var accumulated_damage: float = 0.0

@export var chain_flags: Array[String] = []
@export var family_members: Dictionary = {
	"father": {"alive": true, "age_offset": 25, "health": 80},
	"mother": {"alive": true, "age_offset": 23, "health": 85},
	"spouse": {"alive": false, "age_offset": -1, "health": 100, "met": false},
	"first_child": {"alive": false, "age_offset": -28, "health": 100, "born": false},
	"second_child": {"alive": false, "age_offset": -32, "health": 100, "born": false, "is_twin": false},
	"grandchild": {"alive": false, "age_offset": -52, "health": 100, "born": false}
}

@export var attributes: Dictionary = {
	"intelligence": 50,
	"courage": 50,
	"health": 100
}

@export var hidden_attributes: Dictionary = {
	"willpower": 50,
	"craziness": 50,
	"discipline": 50
}

@export var karma: int = 0
@export var fame: int = 0
@export var education_level: String = ""
@export var tensions: Array[TensionData] = []
@export var recent_events: Array[String] = []

@export var completed_events: Array[String] = []
@export var completed_battles: Array[String] = []

@export var current_battle_id: String = ""
@export var current_battle_deadly: bool = false
@export var current_battle_victory: bool = false
@export var battle_rating: String = "D"
@export var current_battle_waves: Array[Dictionary] = []
@export var current_map_id: String = ""
@export var global_difficulty: String = "normal"
var accumulated_map_weights: Dictionary = {}
var pending_battle_modifiers: Array[Dictionary] = []
@export var npcs: Array[NPCData] = []
@export var current_profession: String = ""
var unlocked_events: Array[String] = []
var locked_events: Array[String] = []
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
		"birthday": birthday,
		"current_age": current_age,
		"current_stage": current_stage,
		"stage_index": stage_index,
		"towers": towers,
		"traits": traits,
		"gold": gold,
		"home_health": home_health,
		"max_home_health": max_home_health,
		"accumulated_damage": accumulated_damage,
		"attributes": attributes,
		"hidden_attributes": hidden_attributes,
		"karma": karma,
		"fame": fame,
		"education_level": education_level,
		"tensions": _tensions_to_array(),
		"recent_events": recent_events,
		"chain_flags": chain_flags,
		"family_members": family_members,
		"completed_events": completed_events,
		"completed_battles": completed_battles,
		"current_battle_id": current_battle_id,
		"current_battle_deadly": current_battle_deadly,
		"current_battle_victory": current_battle_victory,
		"battle_rating": battle_rating,
		"current_battle_waves": current_battle_waves,
		"current_map_id": current_map_id,
		"global_difficulty": global_difficulty,
		"npcs": _npcs_to_array(),
		"current_profession": current_profession
	}

static func from_dict(data: Dictionary) -> GameSessionData:
	var session = GameSessionData.new()
	session.era_id = data.get("era_id", "china_modern")
	session.family_background = data.get("family_background", "worker")
	session.region = data.get("region", "tier2_city")
	session.birthday = data["birthday"]
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
	session.traits.clear()
	for item in data.get("traits", []):
		session.traits.append(str(item))
	session.gold = data.get("gold", 50)
	session.home_health = data.get("home_health", 100.0)
	session.max_home_health = data.get("max_home_health", 100.0)
	session.accumulated_damage = data.get("accumulated_damage", 0.0)
	session.attributes = data.get("attributes", {"intelligence": 50, "courage": 50, "health": 100, "charm": 30, "work_ability": 0, "luck": 30})
	session.hidden_attributes = data.get("hidden_attributes", {"willpower": 50, "craziness": 50, "discipline": 50})
	session.karma = int(data.get("karma", 0))
	session.fame = int(data.get("fame", 0))
	session.education_level = str(data.get("education_level", ""))
	session.tensions.clear()
	for t_data: Dictionary in data.get("tensions", []):
		session.tensions.append(TensionData.from_dict(t_data))
	session.recent_events.clear()
	for item in data.get("recent_events", []):
		session.recent_events.append(str(item))
	session.chain_flags.clear()
	for item in data.get("chain_flags", []):
		session.chain_flags.append(str(item))
	var default_family: Dictionary = {
		"father": {"alive": true, "age_offset": 25, "health": 80},
		"mother": {"alive": true, "age_offset": 23, "health": 85},
		"spouse": {"alive": false, "age_offset": -1, "health": 100, "met": false},
		"first_child": {"alive": false, "age_offset": -28, "health": 100, "born": false},
		"second_child": {"alive": false, "age_offset": -32, "health": 100, "born": false, "is_twin": false},
		"grandchild": {"alive": false, "age_offset": -52, "health": 100, "born": false}
	}
	session.family_members = data.get("family_members", default_family)
	session.completed_events.clear()
	for item in data.get("completed_events", []):
		session.completed_events.append(str(item))
	session.completed_battles.clear()
	for item in data.get("completed_battles", []):
		session.completed_battles.append(str(item))
	session.current_battle_id = data.get("current_battle_id", "")
	session.current_battle_deadly = data.get("current_battle_deadly", false)
	session.current_battle_victory = data.get("current_battle_victory", false)
	session.battle_rating = data.get("battle_rating", "D")
	var raw_waves: Array = data.get("current_battle_waves", [])
	session.current_battle_waves.clear()
	for w: Dictionary in raw_waves:
		session.current_battle_waves.append(w)
	session.current_map_id = data.get("current_map_id", "")
	session.global_difficulty = data.get("global_difficulty", "normal")
	session.npcs.clear()
	for npc_data: Dictionary in data.get("npcs", []):
		session.npcs.append(NPCData.from_dict(npc_data))
	session.current_profession = str(data.get("current_profession", ""))
	session.unlocked_events.clear()
	for item in data.get("unlocked_events", []):
		session.unlocked_events.append(str(item))
	session.locked_events.clear()
	for item in data.get("locked_events", []):
		session.locked_events.append(str(item))
	return session

func _npcs_to_array() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for npc: NPCData in npcs:
		result.append(npc.to_dict())
	return result

func _tensions_to_array() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for t: TensionData in tensions:
		result.append(t.to_dict())
	return result
