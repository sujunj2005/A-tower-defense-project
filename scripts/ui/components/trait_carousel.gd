extends HBoxContainer

signal selection_changed(trait_id: String, selected: bool)

var _traits_data: Array[Dictionary] = []
var _selected_traits: Dictionary = {}
var _current_index: int = 0
var _max_selectable: int = 3
var _selected_count: int = 0

var _left_btn: Button
var _right_btn: Button
var _card: PanelContainer
var _name_label: Label
var _desc_label: Label
var _effect_label: Label
var _cost_label: Label
var _select_btn: Button
var _counter_label: Label

func _ready() -> void:
	add_theme_constant_override("separation", 6)
	_left_btn = Button.new()
	_left_btn.text = "◀"
	_left_btn.custom_minimum_size = Vector2(30, 80)
	_left_btn.pressed.connect(_on_left)
	add_child(_left_btn)
	var card_vbox: VBoxContainer = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 2)
	card_vbox.custom_minimum_size = Vector2(200, 80)
	_card = PanelContainer.new()
	_card.add_child(card_vbox)
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 13)
	card_vbox.add_child(_name_label)
	_desc_label = Label.new()
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.add_theme_font_size_override("font_size", 11)
	_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(_desc_label)
	_effect_label = Label.new()
	_effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_effect_label.add_theme_font_size_override("font_size", 11)
	_effect_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5, 1.0))
	card_vbox.add_child(_effect_label)
	_cost_label = Label.new()
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cost_label.add_theme_font_size_override("font_size", 11)
	_cost_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
	card_vbox.add_child(_cost_label)
	add_child(_card)
	_right_btn = Button.new()
	_right_btn.text = "▶"
	_right_btn.custom_minimum_size = Vector2(30, 80)
	_right_btn.pressed.connect(_on_right)
	add_child(_right_btn)
	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 4)
	_select_btn = Button.new()
	_select_btn.custom_minimum_size = Vector2(60, 26)
	_select_btn.pressed.connect(_on_toggle_select)
	right_vbox.add_child(_select_btn)
	_counter_label = Label.new()
	_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counter_label.add_theme_font_size_override("font_size", 11)
	right_vbox.add_child(_counter_label)
	add_child(right_vbox)
	_update_display()

func setup(traits_data: Array[Dictionary], max_selectable: int = 3) -> void:
	_traits_data = traits_data
	_max_selectable = max_selectable
	_selected_traits.clear()
	_selected_count = 0
	_current_index = 0
	_update_display()

func get_selected_trait_ids() -> Array[String]:
	var result: Array[String] = []
	for tid: String in _selected_traits:
		result.append(tid)
	return result

func get_selected_costs() -> Array[int]:
	var result: Array[int] = []
	for tid: String in _selected_traits:
		result.append(_selected_traits[tid])
	return result

func _on_left() -> void:
	if _traits_data.is_empty():
		return
	_current_index = (_current_index - 1 + _traits_data.size()) % _traits_data.size()
	_update_display()

func _on_right() -> void:
	if _traits_data.is_empty():
		return
	_current_index = (_current_index + 1) % _traits_data.size()
	_update_display()

func _on_toggle_select() -> void:
	if _traits_data.is_empty():
		return
	var entry: Dictionary = _traits_data[_current_index]
	var tid: String = entry["trait_id"]
	if _selected_traits.has(tid):
		_selected_traits.erase(tid)
		_selected_count -= 1
		selection_changed.emit(tid, false)
	else:
		if _selected_count >= _max_selectable:
			return
		_selected_traits[tid] = entry["cost"]
		_selected_count += 1
		selection_changed.emit(tid, true)
	_update_display()

func _update_display() -> void:
	if _traits_data.is_empty():
		_name_label.text = "-"
		_desc_label.text = ""
		_effect_label.text = ""
		_cost_label.text = ""
		_select_btn.text = "-"
		_select_btn.disabled = true
		_counter_label.text = "0/%d" % _max_selectable
		return
	var entry: Dictionary = _traits_data[_current_index]
	var tid: String = entry["trait_id"]
	var cfg: Dictionary = get_node("/root/TraitSystem").get_trait_config(tid)
	var name_text: String = tr(cfg["name"])
	var desc_text: String = tr(cfg["description"])
	var effect_text: String = ""
	if cfg.has("effect"):
		effect_text = _format_effect(cfg.effect)
	_name_label.text = name_text
	_desc_label.text = desc_text
	_effect_label.text = effect_text
	_cost_label.text = tr("LIFE_CHOICE_TRAIT_COST") + "：%d" % entry["cost"]
	var is_selected: bool = _selected_traits.has(tid)
	_select_btn.text = tr("LIFE_CHOICE_TRAIT_SELECTED") if is_selected else "+"
	_select_btn.disabled = false
	_counter_label.text = "%d/%d" % [_selected_count, _max_selectable]

func _format_effect(effect: Dictionary) -> String:
	var etype: String = effect["type"]
	match etype:
		"attribute_bonus":
			var ak: String = effect.get("attribute", "")
			var an: String = tr("ATTR_" + ak.to_upper()) if ak else ""
			return "%s %+d" % [an, effect["value"]]
		"health_bonus":
			return "HP %+d" % effect["value"]
		"gold_bonus":
			return "Gold %+d" % effect["value"]
		"gold_per_wave":
			return "Gold/Wave %+d" % effect["value"]
		"tower_damage_bonus":
			return "Dmg +%.0f%%" % (effect["tower_damage_bonus"] * 100.0)
		"tower_attack_speed_bonus":
			return "ASPD +%.0f%%" % (effect["value"] * 100.0)
		"damage_reduction":
			return "DR +%.0f%%" % (effect["value"] * 100.0)
		_:
			return etype
