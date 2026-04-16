extends Node

var _configs: Dictionary = {}

func _ready() -> void:
	_load_configs()

func _load_configs() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return
	var data: Dictionary = cm.load_json("res://data/attributes.json")
	if data.has("attributes"):
		_configs = data.attributes

func get_display_name(attr_id: String) -> String:
	if _configs.has(attr_id):
		return tr(_configs[attr_id].get("display_name", attr_id))
	return attr_id

func get_icon(attr_id: String) -> String:
	if _configs.has(attr_id):
		return _configs[attr_id].get("icon", "")
	return ""

func get_display_with_icon(attr_id: String) -> String:
	var icon: String = get_icon(attr_id)
	var display_name: String = get_display_name(attr_id)
	if icon != "":
		return "%s %s" % [icon, display_name]
	return display_name
