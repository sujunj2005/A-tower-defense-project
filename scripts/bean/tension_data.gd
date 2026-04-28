class_name TensionData
extends Resource

@export var tension_id: String = ""
@export var source_event: String = ""
@export var title: String = ""
@export var description: String = ""
@export var remaining: int = 0
@export var duration: int = 0
@export var pressure: float = 0.0
@export var resolution_event: String = ""
@export var tension_type: String = ""

func to_dict() -> Dictionary:
	return {
		"tension_id": tension_id,
		"source_event": source_event,
		"title": title,
		"description": description,
		"remaining": remaining,
		"duration": duration,
		"pressure": pressure,
		"resolution_event": resolution_event,
		"tension_type": tension_type
	}

static func from_dict(data: Dictionary) -> TensionData:
	var t := TensionData.new()
	t.tension_id = str(data.get("tension_id", ""))
	t.source_event = str(data.get("source_event", ""))
	t.title = str(data.get("title", ""))
	t.description = str(data.get("description", ""))
	t.remaining = int(data.get("remaining", 0))
	t.duration = int(data.get("duration", 0))
	t.pressure = float(data.get("pressure", 0.0))
	t.resolution_event = str(data.get("resolution_event", ""))
	t.tension_type = str(data.get("tension_type", ""))
	return t
