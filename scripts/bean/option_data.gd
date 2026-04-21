class_name OptionData
extends Resource

@export var event_id: String = ""
@export var option_id: String = ""
@export var text: String = ""
@export var requirements: Dictionary = {}
@export var rewards: Array[Dictionary] = []
@export var cost: Dictionary = {}
@export var battle_trigger: Variant = null
@export var map_weights: Dictionary = {}
@export var force_map_id: String = ""
@export var battle_modifiers: Array[Dictionary] = []
@export var triggers_ending: bool = false
@export var ending_reason: String = ""
@export var chain_flag: String = ""
@export var family_effect: Variant = {}

func to_dict() -> Dictionary:
	var result: Dictionary = {
		"option_id": option_id,
		"text": text,
		"requirements": requirements,
		"rewards": rewards,
		"battle_trigger": battle_trigger,
	}
	if not cost.is_empty():
		result["cost"] = cost
	if triggers_ending:
		result["triggers_ending"] = true
		result["ending_reason"] = ending_reason
	if chain_flag != "":
		result["chain_flag"] = chain_flag
	if not map_weights.is_empty():
		result["map_weights"] = map_weights
	if force_map_id != "":
		result["force_map_id"] = force_map_id
	if not battle_modifiers.is_empty():
		result["battle_modifiers"] = battle_modifiers
	var fx = family_effect
	if fx is Dictionary and not fx.is_empty():
		result["family_effect"] = fx
	elif fx is Array and not fx.is_empty():
		result["family_effect"] = fx
	return result

static func from_dict(data: Dictionary) -> OptionData:
	var opt := OptionData.new()
	opt.event_id = str(data.get("event_id", ""))
	opt.option_id = str(data.get("option_id", ""))
	opt.text = str(data.get("text", ""))
	opt.requirements = Dictionary(data.get("requirements", {}))
	var raw_rewards = data.get("rewards", [])
	for r in raw_rewards:
		opt.rewards.append(Dictionary(r))
	opt.cost = Dictionary(data.get("cost", {}))
	opt.battle_trigger = data.get("battle_trigger", null)
	opt.triggers_ending = bool(data.get("triggers_ending", false))
	opt.ending_reason = str(data.get("ending_reason", ""))
	opt.chain_flag = str(data.get("chain_flag", ""))
	opt.map_weights = Dictionary(data.get("map_weights", {}))
	opt.force_map_id = str(data.get("force_map_id", ""))
	var raw_mods: Array = data.get("battle_modifiers", [])
	opt.battle_modifiers.clear()
	for m: Dictionary in raw_mods:
		opt.battle_modifiers.append(m)
	var raw_fx = data.get("family_effect", {})
	if raw_fx is Array:
		opt.family_effect = raw_fx
	else:
		opt.family_effect = Dictionary(raw_fx)
	return opt

func get_display_text() -> String:
	return tr(text)
