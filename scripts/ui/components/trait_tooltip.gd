extends Control

var _title_label: Label
var _desc_label: Label
var _panel: PanelContainer

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.18, 0.95)
	style.border_color = Color(0.5, 0.5, 0.7, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_title_label)

	_desc_label = Label.new()
	_desc_label.add_theme_font_size_override("font_size", 14)
	_desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.custom_minimum_size = Vector2(200, 0)
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_desc_label)

func setup(trait_id: String) -> void:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if ts and ts.has_method("get_trait_config"):
		var config: Dictionary = ts.get_trait_config(trait_id)
		if _title_label:
			_title_label.text = config.get("name", trait_id)
		if _desc_label:
			var desc: String = config.get("description", "")
			var effects = config.get("effects", config.get("effect", []))
			if not effects.is_empty():
				var effect_texts: Array[String] = []
				if effects is Array:
					for eff: Dictionary in effects:
						effect_texts.append(_format_effect(eff))
				elif effects is Dictionary:
					effect_texts.append(_format_effect(effects))
				if not effect_texts.is_empty():
					desc += "\n" + "；".join(effect_texts)
			_desc_label.text = desc
	else:
		if _title_label:
			_title_label.text = trait_id
		if _desc_label:
			_desc_label.text = ""

func setup_static(title: String, description: String) -> void:
	if _title_label:
		_title_label.text = title
	if _desc_label:
		_desc_label.text = description

func show_at(pos: Vector2) -> void:
	visible = true
	var tooltip_size: Vector2 = get_combined_minimum_size()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var adjusted_pos: Vector2 = pos
	if adjusted_pos.x + tooltip_size.x > viewport_size.x:
		adjusted_pos.x = viewport_size.x - tooltip_size.x - 5.0
	if adjusted_pos.y + tooltip_size.y > viewport_size.y:
		adjusted_pos.y = adjusted_pos.y - tooltip_size.y - 10.0
	if adjusted_pos.x < 0.0:
		adjusted_pos.x = 5.0
	if adjusted_pos.y < 0.0:
		adjusted_pos.y = 5.0
	position = adjusted_pos
	size = tooltip_size

func hide_tooltip() -> void:
	visible = false

func _format_effect(effect: Dictionary) -> String:
	var effect_type: String = effect.get("type", "")
	match effect_type:
		"tower_damage_bonus":
			var val: float = float(effect.get("tower_damage_bonus", effect.get("value", 0)))
			return "塔伤害+%.0f%%" % (val * 100.0)
		"tower_attack_speed_bonus":
			var val: float = float(effect.get("value", 0))
			return "塔攻速+%.0f%%" % (val * 100.0)
		"attribute_bonus":
			var ac: Node = get_node_or_null("/root/AttributeConfig")
			var attr_name: String = effect.get("attribute", "")
			var display: String = attr_name
			if ac and ac.has_method("get_display_with_icon"):
				display = ac.get_display_with_icon(attr_name)
			var val: int = int(effect.get("value", 0))
			return "%s%+d" % [display, val]
		"gold_bonus":
			var val: int = int(effect.get("value", 0))
			return "金币%+d" % val
		"health_bonus":
			var val: int = int(effect.get("value", 0))
			return "生命%+d" % val
		"gold_per_wave":
			var val: int = int(effect.get("value", 0))
			return "每波金币+%d" % val
		"damage_reduction":
			var val: float = float(effect.get("value", 0))
			return "伤害减免%.0f%%" % (val * 100.0)
		"event_trigger_bonus":
			var val: float = float(effect.get("value", 0))
			return "事件触发率%+.0f%%" % (val * 100.0)
		_:
			var val = effect.get("value", effect.get("tower_damage_bonus", ""))
			return "%s: %s" % [effect_type, str(val)]
