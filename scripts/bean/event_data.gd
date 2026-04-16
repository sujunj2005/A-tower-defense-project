class_name EventData
extends Resource

@export var event_id: String = ""
@export var event_name: String = ""
@export var ages: Array[int] = []
@export var stage: String = ""
@export var description: String = ""
@export var options: Array[OptionData] = []
@export var is_deadly: bool = false
@export var trigger_chance: float = 1.0
@export var chain_prerequisites: Array[String] = []
@export var chain_excludes: Array[String] = []

func to_dict() -> Dictionary:
	var opts: Array[Dictionary] = []
	for opt: OptionData in options:
		opts.append(opt.to_dict())
	return {
		"event_id": event_id,
		"event_name": event_name,
		"ages": ages,
		"stage": stage,
		"description": description,
		"options": opts,
		"is_deadly": is_deadly,
		"trigger_chance": trigger_chance,
		"chain_prerequisites": chain_prerequisites,
		"chain_excludes": chain_excludes
	}

static func from_dict(data: Dictionary) -> EventData:
	var event := EventData.new()
	event.event_id = str(data.get("event_id", ""))
	event.event_name = str(data.get("event_name", ""))
	var raw_ages = data.get("ages", [])
	for a in raw_ages:
		event.ages.append(int(a))
	event.stage = str(data.get("stage", ""))
	event.description = str(data.get("description", ""))
	var raw_options = data.get("options", [])
	if raw_options.is_empty():
		var os: Node = Engine.get_main_loop().root.get_node_or_null("OptionSystem")
		if os and os.has_method("get_options_for_event"):
			event.options = os.get_options_for_event(event.event_id)
		else:
			event.options = _load_options_fallback(event.event_id)
	else:
		for opt in raw_options:
			if opt is OptionData:
				event.options.append(opt)
			elif opt is Dictionary:
				event.options.append(OptionData.from_dict(opt))
	event.is_deadly = bool(data.get("is_deadly", false))
	event.trigger_chance = float(data.get("trigger_chance", 1.0))
	var raw_prereqs = data.get("chain_prerequisites", [])
	for p in raw_prereqs:
		event.chain_prerequisites.append(str(p))
	var raw_excludes = data.get("chain_excludes", [])
	for e in raw_excludes:
		event.chain_excludes.append(str(e))
	return event

static func _load_options_fallback(event_id: String) -> Array[OptionData]:
	var result: Array[OptionData] = []
	var cm: Node = Engine.get_main_loop().root.get_node_or_null("ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return result
	var data = cm.load_json("res://data/options.json")
	if not data is Dictionary or not data.has("options"):
		return result
	for opt_raw: Dictionary in data.options:
		if opt_raw.get("event_id", "") == event_id:
			result.append(OptionData.from_dict(opt_raw))
	return result

func get_display_name() -> String:
	return tr(event_name)

func get_display_desc() -> String:
	return tr(description)
