class_name SkillBean
extends Resource

@export var skill_id: String = ""
@export var skill_name_key: String = ""
@export var skill_desc_key: String = ""
@export var skill_type: String = ""
@export var npc_id: String = ""
@export var required_affection: int = 75
@export var cooldown: float = 30.0
@export var duration: float = 8.0
@export var params: Dictionary = {}
@export var icon_color: Color = Color.WHITE

func get_display_name() -> String:
	return tr(skill_name_key)

func get_display_desc() -> String:
	return tr(skill_desc_key)

func to_dict() -> Dictionary:
	return {
		"skill_id": skill_id,
		"skill_name_key": skill_name_key,
		"skill_desc_key": skill_desc_key,
		"skill_type": skill_type,
		"npc_id": npc_id,
		"required_affection": required_affection,
		"cooldown": cooldown,
		"duration": duration,
		"params": params,
		"icon_color": {"r": icon_color.r, "g": icon_color.g, "b": icon_color.b, "a": icon_color.a}
	}

static func from_dict(data: Dictionary) -> SkillBean:
	var s := SkillBean.new()
	s.skill_id = str(data.get("skill_id", ""))
	s.skill_name_key = str(data.get("skill_name_key", ""))
	s.skill_desc_key = str(data.get("skill_desc_key", ""))
	s.skill_type = str(data.get("skill_type", ""))
	s.npc_id = str(data.get("npc_id", ""))
	s.required_affection = int(data.get("required_affection", 75))
	s.cooldown = float(data.get("cooldown", 30.0))
	s.duration = float(data.get("duration", 8.0))
	s.params = data.get("params", {})
	var c: Dictionary = data.get("icon_color", {})
	if c.has("r"):
		s.icon_color = Color(float(c.r), float(c.g), float(c.b), float(c.get("a", 1.0)))
	return s
