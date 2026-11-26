extends VBoxContainer

signal traits_changed(trait_ids: Array[String], total_cost: int)

var _trait_dropdown: OptionButton
var _add_btn: Button
var _selected_container: HBoxContainer
var _empty_label: Label
var _congenital_data: Array[Dictionary] = []
var _selected_traits: Dictionary = {}
var _max_selectable: int = 3

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	_load_congenital_traits()
	_build_dropdown()
	_selected_container = HBoxContainer.new()
	_selected_container.add_theme_constant_override("separation", 6)
	add_child(_selected_container)
	_empty_label = Label.new()
	_empty_label.add_theme_font_size_override("font_size", 12)
	_empty_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	_empty_label.text = tr("LIFE_CHOICE_TRAIT_SELECTED_NONE")
	_selected_container.add_child(_empty_label)

func _build_dropdown() -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_trait_dropdown = OptionButton.new()
	_trait_dropdown.custom_minimum_size = Vector2(200, 28)
	row.add_child(_trait_dropdown)
	_add_btn = Button.new()
	_add_btn.text = "+"
	_add_btn.custom_minimum_size = Vector2(40, 28)
	_add_btn.pressed.connect(_on_add_trait)
	row.add_child(_add_btn)
	add_child(row)
	for i: int in range(_congenital_data.size()):
		var entry: Dictionary = _congenital_data[i]
		var tid: String = entry["trait_id"]
		var name_text: String = _get_trait_display_name(tid)
		_trait_dropdown.add_item("%s (%d)", i)
		_trait_dropdown.set_item_text(_trait_dropdown.item_count - 1, "%s (%d)" % [name_text, entry["cost"]])
	_trait_dropdown.select(0)
	_update_add_button()

func _load_congenital_traits() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	var data: Dictionary = {}
	if cm and cm.has_method("load_json"):
		data = cm.load_json("res://data/congenital_traits.json")
	else:
		var path: String = ConfigPath.resolve("res://data/congenital_traits.json")
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if not file:
			return
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		file.close()
		data = json.data
	_congenital_data.clear()
	for entry: Dictionary in data.get("congenital_traits", []):
		_congenital_data.append(entry)

func _get_trait_display_name(tid: String) -> String:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if ts:
		var cfg: Dictionary = ts.get_trait_config(tid)
		if not cfg.is_empty():
			return tr(cfg.get("name", tid))
	return tid

func _on_add_trait() -> void:
	if _selected_traits.size() >= _max_selectable:
		return
	var idx: int = _trait_dropdown.selected
	if idx < 0 or idx >= _congenital_data.size():
		return
	var entry: Dictionary = _congenital_data[idx]
	var tid: String = entry["trait_id"]
	if _selected_traits.has(tid):
		return
	_selected_traits[tid] = entry["cost"]
	_refresh_selected_display()
	_update_add_button()
	_emit_changed()

func _remove_trait(tid: String) -> void:
	_selected_traits.erase(tid)
	_refresh_selected_display()
	_update_add_button()
	_emit_changed()

func _refresh_selected_display() -> void:
	for child: Control in _selected_container.get_children():
		_selected_container.remove_child(child)
		child.queue_free()
	if _selected_traits.is_empty():
		_empty_label = Label.new()
		_empty_label.add_theme_font_size_override("font_size", 12)
		_empty_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
		_empty_label.text = tr("LIFE_CHOICE_TRAIT_SELECTED_NONE")
		_selected_container.add_child(_empty_label)
		return
	var ts: Node = get_node_or_null("/root/TraitSystem")
	for tid: String in _selected_traits:
		var tag: HBoxContainer = HBoxContainer.new()
		tag.add_theme_constant_override("separation", 2)
		var name_text: String = _get_trait_display_name(tid)
		var cfg: Dictionary = {}
		if ts:
			cfg = ts.get_trait_config(tid)
		var tooltip: String = ""
		if not cfg.is_empty():
			var desc: String = tr(cfg.get("description", ""))
			var effect_lines: PackedStringArray = []
			if cfg.has("effect"):
				var eff: Dictionary = cfg.effect
				match eff.get("type", ""):
					"attribute_bonus":
						var attr_key: String = eff.get("attribute", "")
						var attr_name: String = tr("ATTR_" + attr_key.to_upper()) if attr_key else ""
						effect_lines.append("%s %+d" % [attr_name, eff.get("value", 0)])
					"health_bonus":
						effect_lines.append("HP %+d" % eff.get("value", 0))
					"gold_bonus":
						effect_lines.append("Gold %+d" % eff.get("value", 0))
					"gold_per_wave":
						effect_lines.append("Gold/Wave %+d" % eff.get("value", 0))
					"tower_damage_bonus":
						effect_lines.append("塔伤害+%.0f%%" % (eff.get("tower_damage_bonus", 0.0) * 100.0))
					"tower_attack_speed_bonus":
						effect_lines.append("塔攻速+%.0f%%" % (eff.get("value", 0.0) * 100.0))
					"damage_reduction":
						effect_lines.append("伤害减免%.0f%%" % (eff.get("value", 0.0) * 100.0))
					"tower_sell_ratio_bonus":
						effect_lines.append("出售价格+%.0f%%" % (eff.get("value", 0.0) * 100.0))
					"tower_build_discount":
						effect_lines.append("建造费用-%.0f%%" % (eff.get("value", 0.0) * 100.0))
			tooltip = "%s\n%s" % [desc, "\n".join(effect_lines)] if effect_lines else desc
		var tag_btn: Button = Button.new()
		tag_btn.text = name_text
		tag_btn.add_theme_font_size_override("font_size", 11)
		tag_btn.custom_minimum_size = Vector2(0, 24)
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.22, 0.35, 0.9)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.4, 0.55, 0.8, 0.8)
		style.set_corner_radius_all(4)
		style.content_margin_left = 8
		style.content_margin_right = 8
		tag_btn.add_theme_stylebox_override("normal", style)
		var hover_style: StyleBoxFlat = style.duplicate()
		hover_style.bg_color = Color(0.2, 0.3, 0.48, 0.95)
		hover_style.border_color = Color(0.6, 0.75, 1.0, 1.0)
		tag_btn.add_theme_stylebox_override("hover", hover_style)
		if tooltip:
			var tip: PopupPanel = PopupPanel.new()
			tip.unresizable = true
			var tip_bg: StyleBoxFlat = StyleBoxFlat.new()
			tip_bg.bg_color = Color(0.12, 0.14, 0.2, 0.97)
			tip_bg.border_width_left = 1
			tip_bg.border_width_right = 1
			tip_bg.border_width_top = 1
			tip_bg.border_width_bottom = 1
			tip_bg.border_color = Color(0.5, 0.6, 0.8, 0.9)
			tip_bg.set_corner_radius_all(4)
			tip_bg.content_margin_left = 10
			tip_bg.content_margin_right = 10
			tip_bg.content_margin_top = 6
			tip_bg.content_margin_bottom = 6
			tip.add_theme_stylebox_override("panel", tip_bg)
			var tip_lbl: Label = Label.new()
			tip_lbl.text = tooltip
			tip_lbl.add_theme_font_size_override("font_size", 12)
			tip_lbl.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88))
			tip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			tip_lbl.custom_minimum_size = Vector2(220, 0)
			tip.add_child(tip_lbl)
			add_child(tip)
			tag_btn.mouse_entered.connect(func():
				var pos: Vector2 = tag_btn.global_position + Vector2(0, tag_btn.size.y + 4)
				if pos.x + 240 > get_viewport().get_visible_rect().size.x:
					pos.x = get_viewport().get_visible_rect().size.x - 240
				if pos.y + 120 > get_viewport().get_visible_rect().size.y:
					pos.y = tag_btn.global_position.y - tip_lbl.get_minimum_size().y - 10
				tip.position = pos
				tip.popup()
			)
			tag_btn.mouse_exited.connect(func(): tip.hide())
		tag.add_child(tag_btn)
		var remove_btn: Button = Button.new()
		remove_btn.text = "×"
		remove_btn.add_theme_font_size_override("font_size", 14)
		remove_btn.custom_minimum_size = Vector2(20, 24)
		var remove_style: StyleBoxFlat = StyleBoxFlat.new()
		remove_style.bg_color = Color(0.3, 0.15, 0.15, 0.7)
		remove_style.border_width_left = 1
		remove_style.border_width_right = 1
		remove_style.border_width_top = 1
		remove_style.border_width_bottom = 1
		remove_style.border_color = Color(0.8, 0.3, 0.3, 0.8)
		remove_style.set_corner_radius_all(4)
		remove_style.content_margin_left = 4
		remove_style.content_margin_right = 4
		remove_btn.add_theme_stylebox_override("normal", remove_style)
		var remove_hover: StyleBoxFlat = remove_style.duplicate()
		remove_hover.bg_color = Color(0.5, 0.2, 0.2, 0.9)
		remove_hover.border_color = Color(1.0, 0.4, 0.4, 1.0)
		remove_btn.add_theme_stylebox_override("hover", remove_hover)
		var current_tid: String = tid
		remove_btn.pressed.connect(func(): _remove_trait(current_tid))
		tag.add_child(remove_btn)
		_selected_container.add_child(tag)

func _update_add_button() -> void:
	_add_btn.disabled = _selected_traits.size() >= _max_selectable

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

func _emit_changed() -> void:
	var ids: Array[String] = get_selected_trait_ids()
	var costs: Array[int] = get_selected_costs()
	var total: int = 0
	for c: int in costs:
		total += c
	traits_changed.emit(ids, total)
