extends VBoxContainer

signal traits_changed(trait_ids: Array[String], total_cost: int)

var _carousel: Node
var _selected_container: HBoxContainer
var _empty_label: Label
var _congenital_data: Array[Dictionary] = []

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	_load_congenital_traits()
	_carousel = load("res://scripts/ui/components/trait_carousel.gd").new()
	add_child(_carousel)
	_carousel.setup(_congenital_data, 3)
	_carousel.selection_changed.connect(_on_selection_changed)
	_selected_container = HBoxContainer.new()
	_selected_container.add_theme_constant_override("separation", 6)
	add_child(_selected_container)
	_empty_label = Label.new()
	_empty_label.add_theme_font_size_override("font_size", 12)
	_empty_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	_empty_label.text = tr("LIFE_CHOICE_TRAIT_SELECTED_NONE")
	_selected_container.add_child(_empty_label)

func _load_congenital_traits() -> void:
	var file: FileAccess = FileAccess.open("res://data/congenital_traits.json", FileAccess.READ)
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	var data: Dictionary = json.data
	_congenital_data.clear()
	for entry: Dictionary in data.congenital_traits:
		_congenital_data.append(entry)

func get_selected_trait_ids() -> Array[String]:
	return _carousel.get_selected_trait_ids()

func get_selected_costs() -> Array[int]:
	return _carousel.get_selected_costs()

func _make_tag(tid: String, name_text: String, tooltip: String) -> Button:
	var tag: Button = Button.new()
	tag.text = name_text
	tag.add_theme_font_size_override("font_size", 11)
	tag.custom_minimum_size = Vector2(0, 24)
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
	tag.add_theme_stylebox_override("normal", style)
	var hover_style: StyleBoxFlat = style.duplicate()
	hover_style.bg_color = Color(0.2, 0.3, 0.48, 0.95)
	hover_style.border_color = Color(0.6, 0.75, 1.0, 1.0)
	tag.add_theme_stylebox_override("hover", hover_style)
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
	tag.mouse_entered.connect(func():
		var pos: Vector2 = tag.global_position + Vector2(0, tag.size.y + 4)
		if pos.x + 240 > get_viewport().get_visible_rect().size.x:
			pos.x = get_viewport().get_visible_rect().size.x - 240
		if pos.y + 120 > get_viewport().get_visible_rect().size.y:
			pos.y = tag.global_position.y - tip_lbl.get_minimum_size().y - 10
		tip.position = pos
		tip.popup()
	)
	tag.mouse_exited.connect(func(): tip.hide())
	return tag

func _on_selection_changed(_trait_id: String, _selected: bool) -> void:
	var ids: Array[String] = get_selected_trait_ids()
	var costs: Array[int] = get_selected_costs()
	var total: int = 0
	for c: int in costs:
		total += c
	for child: Control in _selected_container.get_children():
		_selected_container.remove_child(child)
		child.queue_free()
	if ids.is_empty():
		_empty_label = Label.new()
		_empty_label.add_theme_font_size_override("font_size", 12)
		_empty_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
		_empty_label.text = tr("LIFE_CHOICE_TRAIT_SELECTED_NONE")
		_selected_container.add_child(_empty_label)
	else:
		var ts: Node = get_node_or_null("/root/TraitSystem")
		for tid: String in ids:
			var name_text: String = tid
			var tooltip: String = tid
			if ts:
				var cfg: Dictionary = ts.get_trait_config(tid)
				if not cfg.is_empty():
					name_text = tr(cfg.get("name", tid))
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
					tooltip = "%s\n%s" % [desc, "\n".join(effect_lines)] if effect_lines else desc
			var tag: Button = _make_tag(tid, name_text, tooltip)
			_selected_container.add_child(tag)
	traits_changed.emit(ids, total)
