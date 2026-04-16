extends RefCounted
class_name SpecialEffectConfig

var _effects: Dictionary = {}

func _init():
	var cm: Node = Engine.get_main_loop().root.get_node_or_null("/root/ConfigManager")
	if not cm:
		return
	var data: Dictionary = cm.load_json("res://data/special_effects.json")
	if not data.has("special_effects"):
		return
	for effect: Dictionary in data.special_effects:
		var eid: String = effect.get("effect_id", "")
		if eid != "":
			_effects[eid] = effect

func get_effect(eid: String) -> Dictionary:
	return _effects.get(eid, {})

func get_effect_name(eid: String) -> String:
	var e: Dictionary = _effects.get(eid, {})
	return e.get("effect_name", eid)

func get_effect_desc(eid: String) -> String:
	var e: Dictionary = _effects.get(eid, {})
	return e.get("description", "")

func get_effect_icon(eid: String) -> String:
	var e: Dictionary = _effects.get(eid, {})
	return e.get("icon", "")

func get_effect_type(eid: String) -> String:
	var e: Dictionary = _effects.get(eid, {})
	return e.get("effect_type", "")

func get_default_params(eid: String) -> Dictionary:
	var e: Dictionary = _effects.get(eid, {})
	return e.get("default_params", {})

func get_display_name(eid: String) -> String:
	return tr(get_effect_name(eid))

func get_display_desc(eid: String) -> String:
	return tr(get_effect_desc(eid))
