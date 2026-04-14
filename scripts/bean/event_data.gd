class_name EventData
extends Resource

@export var event_id: String = ""
@export var event_name: String = ""
@export var ages: Array[int] = []
@export var stage: String = ""
@export var description: String = ""
@export var options: Array[Dictionary] = []
@export var is_deadly: bool = false
@export var trigger_chance: float = 1.0
@export var chain_prerequisites: Array[String] = []
@export var chain_excludes: Array[String] = []

func to_dict() -> Dictionary:
	return {
		"event_id": event_id,
		"event_name": event_name,
		"ages": ages,
		"stage": stage,
		"description": description,
		"options": options,
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
	for opt in raw_options:
		event.options.append(Dictionary(opt))
	event.is_deadly = bool(data.get("is_deadly", false))
	event.trigger_chance = float(data.get("trigger_chance", 1.0))
	var raw_prereqs = data.get("chain_prerequisites", [])
	for p in raw_prereqs:
		event.chain_prerequisites.append(str(p))
	var raw_excludes = data.get("chain_excludes", [])
	for e in raw_excludes:
		event.chain_excludes.append(str(e))
	return event
