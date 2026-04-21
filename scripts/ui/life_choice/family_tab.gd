extends VBoxContainer

signal family_changed(family_id: String, points_cost: int)

var _families_data: Array[Dictionary] = []
var _selected_index: int = 0
var _family_label: Label
var _family_desc_label: Label
var _family_traits_label: Label
var _family_towers_label: Label
var _cost_label: Label
var _index_label: Label
var _prev_btn: Button
var _next_btn: Button
var _points_display: Node

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	var nav_row: HBoxContainer = HBoxContainer.new()
	nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_row.add_theme_constant_override("separation", 8)
	_prev_btn = Button.new()
	_prev_btn.text = "◀"
	_prev_btn.custom_minimum_size = Vector2(40, 32)
	_prev_btn.add_theme_font_size_override("font_size", 16)
	_prev_btn.pressed.connect(_on_prev)
	nav_row.add_child(_prev_btn)
	_index_label = Label.new()
	_index_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_index_label.custom_minimum_size = Vector2(60, 0)
	_index_label.add_theme_font_size_override("font_size", 14)
	_index_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	nav_row.add_child(_index_label)
	_next_btn = Button.new()
	_next_btn.text = "▶"
	_next_btn.custom_minimum_size = Vector2(40, 32)
	_next_btn.add_theme_font_size_override("font_size", 16)
	_next_btn.pressed.connect(_on_next)
	nav_row.add_child(_next_btn)
	add_child(nav_row)
	_family_label = Label.new()
	_family_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_family_label.add_theme_font_size_override("font_size", 15)
	add_child(_family_label)
	_family_desc_label = Label.new()
	_family_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_family_desc_label.add_theme_font_size_override("font_size", 12)
	_family_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	_family_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_family_desc_label)
	_family_traits_label = Label.new()
	_family_traits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_family_traits_label.add_theme_font_size_override("font_size", 12)
	_family_traits_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5, 1.0))
	_family_traits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_family_traits_label)
	_family_towers_label = Label.new()
	_family_towers_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_family_towers_label.add_theme_font_size_override("font_size", 11)
	_family_towers_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0, 1.0))
	_family_towers_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_family_towers_label)
	_cost_label = Label.new()
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_cost_label.add_theme_font_size_override("font_size", 14)
	_cost_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
	add_child(_cost_label)
	_load_families_data()

func setup(points_display: Node) -> void:
	_points_display = points_display

func _load_families_data() -> void:
	var file: FileAccess = FileAccess.open("res://data/family_backgrounds.json", FileAccess.READ)
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	var families_json: Dictionary = json.data
	_families_data.clear()
	for fam: Dictionary in families_json.family_backgrounds:
		_families_data.append(fam)
	_selected_index = randi() % _families_data.size()
	_update_display()
	family_changed.emit(_get_current()["family_id"], _get_current()["points_cost"])

func _get_current() -> Dictionary:
	if _families_data.is_empty() or _selected_index >= _families_data.size():
		return {}
	return _families_data[_selected_index]

func get_selected_family_id() -> String:
	return _get_current().get("family_id", "")

func get_selected_cost() -> int:
	return int(_get_current().get("points_cost", 0))

func _on_prev() -> void:
	if _families_data.size() <= 1:
		return
	_selected_index = (_selected_index - 1 + _families_data.size()) % _families_data.size()
	_update_display()
	family_changed.emit(_get_current()["family_id"], _get_current()["points_cost"])

func _on_next() -> void:
	if _families_data.size() <= 1:
		return
	_selected_index = (_selected_index + 1) % _families_data.size()
	_update_display()
	family_changed.emit(_get_current()["family_id"], _get_current()["points_cost"])

func _update_display() -> void:
	var fam: Dictionary = _get_current()
	if fam.is_empty():
		_family_label.text = "-"
		_family_desc_label.text = ""
		_family_traits_label.text = ""
		_family_towers_label.text = ""
		_cost_label.text = ""
		_index_label.text = "0/0"
		return
	_index_label.text = "%d/%d" % [_selected_index + 1, _families_data.size()]
	_family_label.text = tr(String(fam["family_name"]))
	_family_desc_label.text = tr(String(fam["description"]))
	var traits: Array = fam["traits"]
	var trait_texts: Array[String] = []
	for trait_entry: Dictionary in traits:
		trait_texts.append(tr(String(trait_entry["text"])))
	_family_traits_label.text = " | ".join(trait_texts) if not trait_texts.is_empty() else ""
	var initial_res: Dictionary = fam["initial_resources"]
	var towers_config: Array = initial_res["towers"]
	var tower_names: Array[String] = []
	for tower_entry: Dictionary in towers_config:
		for tid: String in tower_entry:
			var count: int = int(tower_entry[tid])
			var loc_key: String = String(tid).to_upper() + "_NAME"
			var display_name: String = tr(loc_key)
			var count_text: String = "×∞" if count < 0 else "×%d" % count
			tower_names.append(display_name + count_text)
	_family_towers_label.text = tr("LIFE_CHOICE_FAMILY_INITIAL_TOWERS") + "：" + (tr("SEPARATOR_DUN").join(tower_names) if not tower_names.is_empty() else tr("TRAITS_NONE"))
	_cost_label.text = tr("LIFE_CHOICE_FAMILY_COST") + "：%d" % int(fam["points_cost"])
