extends PanelContainer
class_name TargetInfoPanel

signal sell_tower_requested(tower: Tower)

var _current_tower: Tower = null
var _info_label: RichTextLabel
var _sell_button: Button
var _title_label: Label
var _close_button: Button
var _attack_toggle: CheckButton
var _attack_toggle_container: HBoxContainer

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if visible and _current_tower and is_instance_valid(_current_tower):
			_title_label.text = "🏰 " + _current_tower.config.get_display_name() + "  Lv." + str(_current_tower.current_level)
			_info_label.text = _build_tower_info_text(_current_tower)

func _ready() -> void:
	visible = false
	_setup_ui()

func _setup_ui() -> void:
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = 20.0
	offset_right = -20.0
	offset_top = -210.0
	offset_bottom = -10.0

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_color = Color(0.6, 0.55, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	var header: HBoxContainer = HBoxContainer.new()
	vbox.add_child(header)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)

	_close_button = Button.new()
	_close_button.text = "✕"
	_close_button.custom_minimum_size = Vector2(28, 28)
	_close_button.add_theme_font_size_override("font_size", 14)
	_close_button.pressed.connect(hide_panel)
	header.add_child(_close_button)

	_info_label = RichTextLabel.new()
	_info_label.bbcode_enabled = true
	_info_label.fit_content = true
	_info_label.scroll_following = false
	_info_label.custom_minimum_size = Vector2(0, 100)
	_info_label.add_theme_font_size_override("normal_font_size", 14)
	_info_label.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9, 1.0))
	vbox.add_child(_info_label)

	_attack_toggle_container = HBoxContainer.new()
	_attack_toggle_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_attack_toggle_container.add_theme_constant_override("separation", 8)
	vbox.add_child(_attack_toggle_container)

	var attack_lbl: Label = Label.new()
	attack_lbl.text = tr("TOWER_ATTACK_TOGGLE")
	attack_lbl.add_theme_font_size_override("font_size", 14)
	attack_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	_attack_toggle_container.add_child(attack_lbl)

	_attack_toggle = CheckButton.new()
	_attack_toggle.button_pressed = true
	_attack_toggle.pressed.connect(_on_attack_toggle_changed)
	_attack_toggle_container.add_child(_attack_toggle)

	_sell_button = Button.new()
	_sell_button.text = tr("SELL_TOWER")
	_sell_button.custom_minimum_size = Vector2(0, 36)
	_sell_button.add_theme_font_size_override("font_size", 15)
	_sell_button.visible = false
	var sell_style: StyleBoxFlat = StyleBoxFlat.new()
	sell_style.bg_color = Color(0.6, 0.2, 0.15, 0.9)
	sell_style.set_corner_radius_all(6)
	sell_style.set_content_margin_all(8)
	_sell_button.add_theme_stylebox_override("normal", sell_style)
	var sell_hover: StyleBoxFlat = StyleBoxFlat.new()
	sell_hover.bg_color = Color(0.75, 0.3, 0.2, 1.0)
	sell_hover.set_corner_radius_all(6)
	sell_hover.set_content_margin_all(8)
	_sell_button.add_theme_stylebox_override("hover", sell_hover)
	_sell_button.pressed.connect(_on_sell_pressed)
	vbox.add_child(_sell_button)

func show_tower_info(tower: Tower) -> void:
	if not tower or not tower.config:
		return
	_current_tower = tower
	_last_tower_level = tower.current_level
	_last_tower_exp = tower.current_experience
	_title_label.text = "🏰 " + tower.config.get_display_name() + "  Lv." + str(tower.current_level)
	_info_label.text = _build_tower_info_text(tower)
	if tower.config.sell_ratio > 0.0:
		var sell_price: int = _calculate_sell_price(tower)
		_sell_button.text = tr("SELL_RETURN") % sell_price
		_sell_button.visible = true
	else:
		_sell_button.visible = false
	if _attack_toggle:
		_attack_toggle.button_pressed = tower.is_attack_enabled
		_attack_toggle_container.visible = true
	visible = true

func hide_panel() -> void:
	visible = false
	_current_tower = null

func get_current_tower() -> Tower:
	return _current_tower

func _build_tower_info_text(tower: Tower) -> String:
	var cfg: TowerBean = tower.config
	var dmg: float = cfg.damage
	var aspeed: float = cfg.attack_speed
	var rng: float = cfg.attack_range
	var ts: Node = get_node_or_null("/root/TraitSystem")
	var dmg_bonus: float = 0.0
	var as_bonus: float = 0.0
	if ts and ts.has_method("get_trait_effects_for_tower"):
		dmg_bonus = ts.get_trait_effects_for_tower(cfg.tower_id)
	if ts and ts.has_method("get_attack_speed_bonus_for_tower"):
		as_bonus = ts.get_attack_speed_bonus_for_tower(cfg.tower_id)
	var final_dmg: float = dmg * (1.0 + dmg_bonus)
	var final_as: float = aspeed * (1.0 + as_bonus)
	var dmg_type_name: String = tr("DAMAGE_TYPE_MAGIC") if cfg.damage_type == 1 else tr("DAMAGE_TYPE_PHYSICAL")
	var text: String = ""
	text += tr("TOWER_INFO_DAMAGE") % final_dmg
	if dmg_bonus > 0.0:
		text += "  [color=green](+%.0f%%)[/color]" % (dmg_bonus * 100.0)
	text += "    %s" % dmg_type_name
	if tower.config.effect_id != "":
		text += "\n" + tower.config.effect_icon + " " + tower.config.get_display_effect_name() + " — " + tower.config.get_display_effect_desc()
	for sub: Dictionary in tower.config.sub_effects:
		var sub_eid: String = sub.get("effect_id", "")
		if sub_eid != "":
			var sec: SpecialEffectConfig = SpecialEffectConfig.new()
			text += "\n" + sec.get_effect_icon(sub_eid) + " " + sec.get_display_name(sub_eid) + " — " + sec.get_display_desc(sub_eid)
	text += "\n" + tr("TOWER_INFO_RANGE") % rng
	text += "    " + tr("TOWER_INFO_SPEED") % final_as
	if as_bonus > 0.0:
		text += "  [color=green](+%.0f%%)[/color]" % (as_bonus * 100.0)
	text += "\n" + tr("TOWER_EXP") % [tower.current_experience, tower.experience_required, cfg.cost]
	return text

func _calculate_sell_price(tower: Tower) -> int:
	if not tower or not tower.config:
		return 0
	var base_cost: int = tower.config.cost
	var level_bonus: float = 1.0 + float(tower.current_level - 1) * 0.1
	return int(float(base_cost) * tower.config.sell_ratio * level_bonus)

func _on_sell_pressed() -> void:
	if _current_tower and is_instance_valid(_current_tower):
		sell_tower_requested.emit(_current_tower)
	hide_panel()

func _on_attack_toggle_changed() -> void:
	if not _current_tower or not is_instance_valid(_current_tower):
		return
	_current_tower.is_attack_enabled = _attack_toggle.button_pressed
	if not _attack_toggle.button_pressed:
		_current_tower.modulate = Color(1, 1, 1, 0.5)
	else:
		_current_tower.modulate = Color(1, 1, 1, 1)

var _last_tower_level: int = -1
var _last_tower_exp: int = -1

func _process(_delta: float) -> void:
	if visible and _current_tower and is_instance_valid(_current_tower):
		var tower: Tower = _current_tower
		if tower.current_level != _last_tower_level or tower.current_experience != _last_tower_exp:
			_last_tower_level = tower.current_level
			_last_tower_exp = tower.current_experience
			_title_label.text = "🏰 " + tower.config.get_display_name() + "  Lv." + str(tower.current_level)
			_info_label.text = _build_tower_info_text(tower)
		if _sell_button.visible and tower.config.sell_ratio > 0.0:
			_sell_button.text = tr("SELL_RETURN") % _calculate_sell_price(tower)
	elif visible and not is_instance_valid(_current_tower):
		hide_panel()
