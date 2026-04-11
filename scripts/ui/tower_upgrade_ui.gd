extends PanelContainer

signal upgrade_confirmed(tower: Node)
signal upgrade_cancelled()

var _current_tower: Node = null
var _name_label: Label
var _level_label: Label
var _stats_label: Label
var _cost_label: Label
var _upgrade_button: Button
var _close_button: Button

func _ready() -> void:
	visible = false
	_build_ui()

func _build_ui() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	style.border_color = Color(0.6, 0.5, 0.2)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(8)
	style.set_content_margin_all(14)
	add_theme_stylebox_override("panel", style)

	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -140
	offset_top = -160
	offset_right = 140
	offset_bottom = 160
	z_index = 500

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 18)
	_name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	vbox.add_child(_name_label)

	_level_label = Label.new()
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_label.add_theme_font_size_override("font_size", 14)
	_level_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	vbox.add_child(_level_label)

	var separator: HSeparator = HSeparator.new()
	vbox.add_child(separator)

	_stats_label = Label.new()
	_stats_label.add_theme_font_size_override("font_size", 13)
	_stats_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(_stats_label)

	_cost_label = Label.new()
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cost_label.add_theme_font_size_override("font_size", 15)
	_cost_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	vbox.add_child(_cost_label)

	var btn_hbox: HBoxContainer = HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_hbox)

	_upgrade_button = Button.new()
	_upgrade_button.text = "升级"
	_upgrade_button.custom_minimum_size = Vector2(90, 38)
	var up_style: StyleBoxFlat = StyleBoxFlat.new()
	up_style.bg_color = Color(0.2, 0.5, 0.2, 0.9)
	up_style.set_corner_radius_all(6)
	up_style.set_content_margin_all(8)
	_upgrade_button.add_theme_stylebox_override("normal", up_style)
	var up_hover: StyleBoxFlat = StyleBoxFlat.new()
	up_hover.bg_color = Color(0.3, 0.65, 0.3, 1.0)
	up_hover.set_corner_radius_all(6)
	_upgrade_button.add_theme_stylebox_override("hover", up_hover)
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	btn_hbox.add_child(_upgrade_button)

	_close_button = Button.new()
	_close_button.text = "关闭"
	_close_button.custom_minimum_size = Vector2(90, 38)
	var close_style: StyleBoxFlat = StyleBoxFlat.new()
	close_style.bg_color = Color(0.5, 0.2, 0.2, 0.9)
	close_style.set_corner_radius_all(6)
	close_style.set_content_margin_all(8)
	_close_button.add_theme_stylebox_override("normal", close_style)
	var close_hover: StyleBoxFlat = StyleBoxFlat.new()
	close_hover.bg_color = Color(0.65, 0.3, 0.3, 1.0)
	close_hover.set_corner_radius_all(6)
	_close_button.add_theme_stylebox_override("hover", close_hover)
	_close_button.pressed.connect(_on_close_pressed)
	btn_hbox.add_child(_close_button)

func show_for_tower(tower: Node) -> void:
	_current_tower = tower
	if not tower or not tower.config:
		hide()
		return

	_name_label.text = tower.config.tower_name
	_level_label.text = "等级：%d / %d" % [tower.current_level, tower.max_level]
	_update_stats_display(tower)
	_update_cost_display(tower)

	if tower.current_level >= tower.max_level:
		_upgrade_button.text = "已满级"
		_upgrade_button.disabled = true
	else:
		_upgrade_button.text = "升级"
		_upgrade_button.disabled = false

	visible = true

func _update_stats_display(tower: Node) -> void:
	var info: String = ""
	info += "伤害：%.0f\n" % tower.config.damage
	info += "攻速：%.1f/s\n" % tower.config.attack_speed
	info += "射程：%.0f\n" % tower.config.attack_range

	if tower.config.has_method("get_special_description"):
		var special: String = tower.config.get_special_description()
		if special != "":
			info += "特殊：%s" % special

	_stats_label.text = info

func _update_cost_display(tower: Node) -> void:
	if tower.current_level >= tower.max_level:
		_cost_label.text = "已达最高等级"
		return

	var upgrade_cost: int = _calculate_upgrade_cost(tower)
	_cost_label.text = "升级费用：%d 金币" % upgrade_cost

func _calculate_upgrade_cost(tower: Node) -> int:
	var base_cost: int = int(tower.config.cost)
	var level_mult: float = 1.0 + float(tower.current_level) * 0.5
	return int(float(base_cost) * 0.4 * level_mult)

func _on_upgrade_pressed() -> void:
	if not _current_tower or not is_instance_valid(_current_tower):
		hide()
		return

	if _current_tower.current_level >= _current_tower.max_level:
		return

	var upgrade_cost: int = _calculate_upgrade_cost(_current_tower)
	var game_hud: Node = get_node_or_null("/root/MapManager/GameHUD")
	if not game_hud:
		game_hud = get_tree().get_first_node_in_group("game_hud")

	if game_hud and game_hud.has_method("can_afford") and not game_hud.can_afford(upgrade_cost):
		_cost_label.text = "金币不足！需要 %d" % upgrade_cost
		_cost_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		return

	if game_hud and game_hud.has_method("spend_gold"):
		game_hud.spend_gold(upgrade_cost)

	_current_tower.add_experience(_current_tower.experience_to_next_level)
	upgrade_confirmed.emit(_current_tower)

	show_for_tower(_current_tower)

func _on_close_pressed() -> void:
	upgrade_cancelled.emit()
	hide()
	_current_tower = null
