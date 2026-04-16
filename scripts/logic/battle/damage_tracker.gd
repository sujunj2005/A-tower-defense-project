extends Node

signal damage_updated

var _records: Dictionary = {}
var _tower_to_key: Dictionary = {}
var _next_id: int = 0

func _ready() -> void:
	add_to_group("damage_tracker")

func record_damage(tower: Tower, actual_damage: float) -> void:
	if not tower or not is_instance_valid(tower):
		return
	var key: String = _get_or_create_key(tower)
	if not _records.has(key):
		var base_name: String = tower.config.get_display_name() if tower.config else tr("NO_DATA")
		var same_id_count: int = 0
		for k: String in _records:
			if _records[k]["tower_id"] == (tower.config.tower_id if tower.config else ""):
				same_id_count += 1
		var display_name: String = base_name
		if same_id_count > 0:
			display_name = "%s #%d" % [base_name, same_id_count + 1]
		_records[key] = {
			"tower_name": display_name,
			"tower_id": tower.config.tower_id if tower.config else "",
			"level": tower.current_level,
			"total_damage": 0.0,
			"is_sold": false
		}
	else:
		if is_instance_valid(tower):
			_records[key]["level"] = tower.current_level
	_records[key]["total_damage"] += actual_damage
	damage_updated.emit()

func mark_tower_sold(tower: Tower) -> void:
	if not tower:
		return
	var key: String = _get_key_for_tower(tower)
	if key != "" and _records.has(key):
		_records[key]["is_sold"] = true
	_tower_to_key.erase(tower)

func get_records() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key: String in _records:
		var rec: Dictionary = _records[key].duplicate()
		rec["key"] = key
		result.append(rec)
	result.sort_custom(_sort_by_damage_desc)
	return result

func get_total_damage() -> float:
	var total: float = 0.0
	for key: String in _records:
		total += _records[key]["total_damage"]
	return total

func reset() -> void:
	_records.clear()
	_tower_to_key.clear()
	_next_id = 0
	damage_updated.emit()

func _get_or_create_key(tower: Tower) -> String:
	if _tower_to_key.has(tower):
		return _tower_to_key[tower]
	var key: String = "tower_%d" % _next_id
	_next_id += 1
	_tower_to_key[tower] = key
	return key

func _get_key_for_tower(tower: Tower) -> String:
	if _tower_to_key.has(tower):
		return _tower_to_key[tower]
	return ""

static func _sort_by_damage_desc(a: Dictionary, b: Dictionary) -> bool:
	return a["total_damage"] > b["total_damage"]
