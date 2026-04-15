class_name OptionData
extends Resource

@export var event_id: String = ""
@export var option_id: String = ""
@export var text: String = ""
@export var requirements: Dictionary = {}
@export var rewards: Array[Dictionary] = []
@export var cost: Dictionary = {}
@export var battle_trigger: Variant = null
@export var triggers_ending: bool = false
@export var ending_reason: String = ""

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
	return opt
