extends Node

signal content_unlocked(unlock_id: String, unlock_type: String)

var player_save: PlayerSaveData
var unlock_configs: Dictionary = {}

func _ready() -> void:
	player_save = Global.get_player_save()
	_load_unlock_configs()

func _load_unlock_configs() -> void:
	unlock_configs = {
		"era_ancient_greece": {
			"type": "era",
			"name": tr("UNLOCK_ERA_ANCIENT_GREECE"),
			"cost": {"destiny_points": 50},
			"prerequisite": ""
		},
		"era_ming_qing": {
			"type": "era",
			"name": tr("UNLOCK_ERA_MING_QING"),
			"cost": {"destiny_points": 50},
			"prerequisite": ""
		},
		"profession_doctor": {
			"type": "profession",
			"name": tr("UNLOCK_PROFESSION_DOCTOR"),
			"cost": {"destiny_points": 30},
			"prerequisite": ""
		},
		"profession_lawyer": {
			"type": "profession",
			"name": tr("UNLOCK_PROFESSION_LAWYER"),
			"cost": {"destiny_points": 30},
			"prerequisite": ""
		},
		"profession_programmer": {
			"type": "profession",
			"name": tr("UNLOCK_PROFESSION_PROGRAMMER"),
			"cost": {"destiny_points": 30},
			"prerequisite": ""
		},
		"difficulty_easy": {
			"type": "difficulty",
			"name": tr("UNLOCK_DIFFICULTY_EASY"),
			"cost": {"life_wisdom": 200},
			"prerequisite": ""
		},
		"difficulty_hard": {
			"type": "difficulty",
			"name": tr("UNLOCK_DIFFICULTY_HARD"),
			"cost": {"destiny_points": 20},
			"prerequisite": "ach_perfect_life"
		},
		"difficulty_hell": {
			"type": "difficulty",
			"name": tr("UNLOCK_DIFFICULTY_HELL"),
			"cost": {"destiny_points": 50},
			"prerequisite": "ach_battle_master"
		},
		"buff_tower_attack": {
			"type": "buff",
			"name": tr("UNLOCK_BUFF_TOWER_ATTACK"),
			"cost": {"life_wisdom": 100},
			"prerequisite": "",
			"effect": {"tower_damage_bonus": 0.10}
		},
		"buff_home_health": {
			"type": "buff",
			"name": tr("BUFF_HOME_HEALTH"),
			"cost": {"life_wisdom": 100},
			"prerequisite": "",
			"effect": {"home_health_bonus": 0.20}
		},
		"buff_gold_bonus": {
			"type": "buff",
			"name": tr("UNLOCK_BUFF_GOLD_BONUS"),
			"cost": {"life_wisdom": 150},
			"prerequisite": "",
			"effect": {"gold_income_bonus": 0.10}
		}
	}

func is_unlocked(unlock_id: String) -> bool:
	match unlock_configs.get(unlock_id, {}).get("type", ""):
		"era":
			return unlock_id in player_save.unlocked_eras
		"profession":
			return unlock_id in player_save.unlocked_professions
		"buff":
			return unlock_id in player_save.unlocked_buffs
		"difficulty", _:
			return unlock_id in player_save.unlocked_buffs

func can_unlock(unlock_id: String) -> bool:
	if is_unlocked(unlock_id):
		return false
	var config: Dictionary = unlock_configs.get(unlock_id, {})
	if config.is_empty():
		return false
	var prerequisite: String = config.get("prerequisite", "")
	if prerequisite != "" and not prerequisite in player_save.achievements:
		return false
	var cost: Dictionary = config.get("cost", {})
	for currency_id: String in cost:
		if not _cm_can_afford(currency_id, cost[currency_id]):
			return false
	return true

func unlock(unlock_id: String) -> bool:
	if not can_unlock(unlock_id):
		return false
	var config: Dictionary = unlock_configs.get(unlock_id, {})
	var cost: Dictionary = config.get("cost", {})
	for currency_id: String in cost:
		if not _cm_spend(currency_id, cost[currency_id]):
			return false
	var unlock_type: String = config.get("type", "")
	match unlock_type:
		"era":
			player_save.unlocked_eras.append(unlock_id)
		"profession":
			player_save.unlocked_professions.append(unlock_id)
		"buff", "difficulty":
			player_save.unlocked_buffs[unlock_id] = config.get("effect", {})
	content_unlocked.emit(unlock_id, unlock_type)
	Global.debug_log("Unlocked: %s (%s)" % [config.get("name", unlock_id), unlock_type])
	return true

func get_unlock_config(unlock_id: String) -> Dictionary:
	return unlock_configs.get(unlock_id, {})

func get_all_unlocks() -> Dictionary:
	return unlock_configs.duplicate()

func get_available_unlocks() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for unlock_id: String in unlock_configs:
		if not is_unlocked(unlock_id) and can_unlock(unlock_id):
			var config: Dictionary = unlock_configs[unlock_id].duplicate()
			config["unlock_id"] = unlock_id
			result.append(config)
	return result

func _get_currency_manager() -> Node:
	return get_node_or_null("/root/CurrencyManager")

func _cm_can_afford(currency_id: String, amount: int) -> bool:
	var cm: Node = _get_currency_manager()
	if cm and cm.has_method("can_afford"):
		return cm.can_afford(currency_id, amount)
	return false

func _cm_spend(currency_id: String, amount: int) -> bool:
	var cm: Node = _get_currency_manager()
	if cm and cm.has_method("spend_currency"):
		return cm.spend_currency(currency_id, amount)
	return false
