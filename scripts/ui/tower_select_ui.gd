extends Control
class_name TowerSelectUI

signal tower_selected(tower_type: String)
signal cancel_pressed()

var tower_configs: Dictionary = {}
var tower_type_list: Array = []

var panel: Panel
var title_label: Label
var tower_buttons_container: GridContainer
var cancel_button: Button
var tooltip_panel: PanelContainer
var tooltip_label: Label
var hovered_tower_type: String = ""
var warning_panel: PanelContainer
var warning_label: Label
var warning_timer: float = 0.0
var flashing_buttons: Dictionary = {}

# 🆕 使用内嵌 get/set 管理面板状态 (包装 Control 的 visible 属性)
var is_panel_visible: bool = false:
	set(value):
		if visible != value:  # 检查实际的 visible 状态
			visible = value  # 直接设置 Control 的 visible
			if visible:
				_on_panel_shown()
			else:
				_on_panel_hidden()
	get:
		return visible  # 直接返回 Control 的 visible 值

var is_locked: bool = false:
	set(value):
		if is_locked != value:
			is_locked = value
			# 锁定状态变化时更新 UI
			if is_locked:
				_lock_panel()
			else:
				_unlock_panel()
	get:
		return is_locked

func _ready():
	load_tower_configs()
	setup_ui()

func _get_placed_tower_counts() -> Dictionary:
	var counts: Dictionary = {}
	for t: Node in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(t) or not t.has_meta("tower_id"):
			continue
		var tid: String = str(t.get_meta("tower_id"))
		if tid != "":
			counts[tid] = counts.get(tid, 0) + 1
	return counts

func load_tower_configs():
	var session: GameSessionData = Global.get_game_session()
	tower_configs.clear()
	tower_type_list.clear()
	var tower_ids: Array[String] = session.get_tower_ids()
	var placed_counts: Dictionary = _get_placed_tower_counts()
	for tower_id: String in tower_ids:
		if session.towers.has(tower_id):
			var config: TowerBean = TowerConfig.get_config(tower_id)
			if config:
				tower_type_list.append(tower_id)
				tower_configs[tower_id] = config

func setup_ui():
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 400)
	panel.position = Vector2(-300, -200)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	vbox.custom_minimum_size = Vector2(560, 360)
	panel.add_child(vbox)
	
	title_label = Label.new()
	title_label.text = tr("TOWER_SELECT_TITLE")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title_label)
	
	var title_spacer = Control.new()
	title_spacer.custom_minimum_size.y = 15
	vbox.add_child(title_spacer)
	
	tower_buttons_container = GridContainer.new()
	tower_buttons_container.columns = 4
	tower_buttons_container.add_theme_constant_override("h_separation", 10)
	tower_buttons_container.add_theme_constant_override("v_separation", 10)
	vbox.add_child(tower_buttons_container)
	
	for tower_type in tower_type_list:
		if not tower_configs.has(tower_type):
			push_error("[TowerSelectUI] 配置不存在：%s" % tower_type)
			continue
		var config = tower_configs[tower_type]
		var button = create_tower_button(tower_type, config)
		tower_buttons_container.add_child(button)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 30
	vbox.add_child(spacer)
	
	cancel_button = Button.new()
	cancel_button.text = tr("BTN_CANCEL")
	cancel_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	cancel_button.custom_minimum_size = Vector2(100, 30)
	cancel_button.pressed.connect(_on_cancel_pressed)
	vbox.add_child(cancel_button)
	
	setup_tooltip()
	setup_warning()

func setup_tooltip():
	tooltip_panel = PanelContainer.new()
	tooltip_panel.visible = false
	tooltip_panel.z_index = 200
	tooltip_panel.anchor_left = 0.5
	tooltip_panel.anchor_top = 0.5
	tooltip_panel.anchor_right = 0.5
	tooltip_panel.anchor_bottom = 0.5
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = Color(0.8, 0.7, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	tooltip_panel.add_theme_stylebox_override("panel", style)
	add_child(tooltip_panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	tooltip_panel.add_child(vbox)
	
	tooltip_label = Label.new()
	tooltip_label.add_theme_font_size_override("font_size", 14)
	tooltip_label.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(tooltip_label)

func setup_warning():
	warning_panel = PanelContainer.new()
	warning_panel.visible = false
	warning_panel.z_index = 300
	warning_panel.anchor_left = 0.5
	warning_panel.anchor_top = 0.5
	warning_panel.anchor_right = 0.5
	warning_panel.anchor_bottom = 0.5
	warning_panel.offset_left = -120
	warning_panel.offset_top = -25
	warning_panel.offset_right = 120
	warning_panel.offset_bottom = 25
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.1, 0.1, 0.95)
	style.border_color = Color(1, 0.3, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	warning_panel.add_theme_stylebox_override("panel", style)
	add_child(warning_panel)
	
	warning_label = Label.new()
	warning_label.text = tr("NOT_ENOUGH_GOLD")
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.add_theme_font_size_override("font_size", 18)
	warning_label.add_theme_color_override("font_color", Color(1, 1, 1))
	warning_panel.add_child(warning_label)

func flash_button_red(button: Button):
	if flashing_buttons.has(button):
		flashing_buttons[button]["timer"] = 0.6
		return
	
	var style_red = StyleBoxFlat.new()
	style_red.bg_color = Color(0.5, 0.1, 0.1, 0.95)
	style_red.border_color = Color(1, 0.2, 0.2, 1.0)
	style_red.border_width_left = 3
	style_red.border_width_top = 3
	style_red.border_width_right = 3
	style_red.border_width_bottom = 3
	style_red.set_corner_radius_all(8)
	style_red.set_content_margin_all(8)
	
	var original_normal = button.get_meta("original_normal_style")
	var original_hover = button.get_meta("original_hover_style")
	button.add_theme_stylebox_override("normal", style_red)
	button.add_theme_stylebox_override("hover", style_red)
	flashing_buttons[button] = {"timer": 0.6, "original": original_normal, "original_hover": original_hover, "red": style_red}

func _process(delta):
	if tooltip_panel.visible and hovered_tower_type != "":
		tooltip_panel.position = get_local_mouse_position() + Vector2(20, -60)
	
	if warning_timer > 0:
		warning_timer -= delta
		warning_panel.visible = fmod(warning_timer * 6.0, 2.0) < 1.0
		if warning_timer <= 0:
			warning_panel.visible = false
	
	var to_remove = []
	for button in flashing_buttons.keys():
		if not is_instance_valid(button):
			to_remove.append(button)
			continue
		var data = flashing_buttons[button]
		data["timer"] -= delta
		if data["timer"] <= 0:
			button.add_theme_stylebox_override("normal", data["original"])
			button.add_theme_stylebox_override("hover", data["original_hover"])
			to_remove.append(button)
		else:
			if fmod(data["timer"] * 8.0, 2.0) < 1.0:
				button.add_theme_stylebox_override("normal", data["red"])
				button.add_theme_stylebox_override("hover", data["red"])
			else:
				button.add_theme_stylebox_override("normal", data["original"])
				button.add_theme_stylebox_override("hover", data["original_hover"])
	for btn in to_remove:
		flashing_buttons.erase(btn)

func create_tower_button(tower_type: String, config: TowerBean) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(130, 120)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.2, 0.25, 0.8)
	style_normal.set_corner_radius_all(8)
	style_normal.set_content_margin_all(8)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.35, 0.35, 0.45, 0.95)
	style_hover.border_color = Color(0.8, 0.7, 0.3, 1.0)
	style_hover.border_width_bottom = 3
	style_hover.set_corner_radius_all(8)
	style_hover.set_content_margin_all(8)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.25, 0.25, 0.35, 0.9)
	style_pressed.set_corner_radius_all(8)
	style_pressed.set_content_margin_all(8)
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.set_meta("original_normal_style", style_normal)
	button.set_meta("original_hover_style", style_hover)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(vbox)
	
	var texture_rect = TextureRect.new()
	if config.texture_path != "" and ResourceLoader.exists(config.texture_path):
		texture_rect.texture = AssetsManager.load_image(config.texture_path)
	else:
		var placeholder: Image = Image.create(80, 80, false, Image.FORMAT_RGBA8)
		var fill_color: Color = Color(0.3, 0.5, 0.8, 1.0) if config.damage_type == 1 else Color(0.8, 0.4, 0.3, 1.0)
		placeholder.fill(fill_color)
		texture_rect.texture = ImageTexture.create_from_image(placeholder)
	texture_rect.custom_minimum_size = Vector2(80, 80)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(texture_rect)
	
	var name_label = Label.new()
	name_label.text = config.get_display_name()
	name_label.set_meta("tower_id", tower_type)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(name_label)
	
	var cost_label = Label.new()
	var era_sys: Node = get_node_or_null("/root/EraSystem")
	var display_cost: int = config.cost
	if era_sys and era_sys.has_method("get_modified_tower_cost"):
		display_cost = era_sys.get_modified_tower_cost(config.cost)
	cost_label.text = tr("TOWER_COST") % display_cost
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(cost_label)

	var session: GameSessionData = Global.get_game_session()
	var tower_max: int = session.towers.get(tower_type, 0)
	var tower_placed: int = 0
	for t: Node in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(t) or not t.has_meta("tower_id"):
			continue
		if str(t.get_meta("tower_id")) == tower_type:
			tower_placed += 1
	var tower_remaining: int = tower_max - tower_placed
	var is_full: bool = tower_max >= 0 and tower_remaining <= 0
	var count_label = Label.new()
	if tower_max < 0:
		count_label.text = tr("TOWER_INFINITE")
		count_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	else:
		count_label.text = "%d/%d" % [tower_remaining, tower_max]
		if is_full:
			count_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		else:
			count_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(count_label)
	
	if is_full:
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5, 0.6)
	else:
		button.pressed.connect(_on_tower_button_pressed.bind(tower_type))
		button.mouse_entered.connect(_on_tower_button_hovered.bind(tower_type, config))
		button.mouse_exited.connect(_on_tower_button_exited)
	
	return button

func _on_tower_button_hovered(tower_type: String, config: TowerBean):
	hovered_tower_type = tower_type
	var info_text = "%s (Lv.%d)\n" % [config.get_display_name(), config.tower_level]
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += tr("TOWER_INFO_COST") % config.cost + "\n"
	info_text += tr("TOWER_INFO_DAMAGE") % config.damage + "\n"
	info_text += tr("TOWER_INFO_RANGE") % config.attack_range + "\n"
	info_text += tr("TOWER_INFO_SPEED") % config.attack_speed
	if config.effect_id != "":
		info_text += "\n" + config.effect_icon + " " + config.get_display_effect_name() + " — " + config.get_display_effect_desc()
	for sub: Dictionary in config.sub_effects:
		var sub_eid: String = sub.get("effect_id", "")
		if sub_eid != "":
			var sec: SpecialEffectConfig = SpecialEffectConfig.new()
			info_text += "\n" + sec.get_effect_icon(sub_eid) + " " + sec.get_display_name(sub_eid) + " — " + sec.get_display_desc(sub_eid)
	tooltip_label.text = info_text
	tooltip_panel.visible = true
	tooltip_panel.position = get_local_mouse_position() + Vector2(20, -60)

func _on_tower_button_exited():
	hovered_tower_type = ""
	tooltip_panel.visible = false

## 🆕 面板显示时的回调
func _on_panel_shown() -> void:
	# 可以在这里添加面板显示时的逻辑
	pass

## 🆕 面板隐藏时的回调
func _on_panel_hidden() -> void:
	tooltip_panel.visible = false
	hovered_tower_type = ""
	warning_panel.visible = false
	warning_timer = 0.0
	is_locked = false

## 🆕 锁定面板
func _lock_panel() -> void:
	# 可以添加锁定时的视觉效果
	pass

## 🆕 解锁面板
func _unlock_panel() -> void:
	pass

func _on_tower_button_pressed(tower_type: String):
	if is_locked:
		return
	is_locked = true
	tooltip_panel.visible = false
	hovered_tower_type = ""
	emit_signal("tower_selected", tower_type)

func _on_cancel_pressed():
	emit_signal("cancel_pressed")
	is_panel_visible = false

func close_panel():
	is_panel_visible = false

func show_at_position(pos: Vector2):
	is_locked = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 0)
	panel.position = pos - panel.custom_minimum_size / 2.0
	is_panel_visible = true
	_refresh_tower_buttons()

func _refresh_tower_buttons() -> void:
	load_tower_configs()
	for child: Node in tower_buttons_container.get_children():
		child.queue_free()
	for tower_type: String in tower_type_list:
		if not tower_configs.has(tower_type):
			continue
		var config: TowerBean = tower_configs[tower_type]
		var button: Button = create_tower_button(tower_type, config)
		tower_buttons_container.add_child(button)

func show_not_enough_gold(tower_type: String):
	var config = tower_configs[tower_type]
	var era_sys: Node = get_node_or_null("/root/EraSystem")
	var actual_cost: int = config.cost
	if era_sys and era_sys.has_method("get_modified_tower_cost"):
		actual_cost = era_sys.get_modified_tower_cost(config.cost)
	warning_label.text = tr("NOT_ENOUGH_GOLD_NEED") % actual_cost
	warning_timer = 1.0
	for child in tower_buttons_container.get_children():
		if child is Button:
			for sub in child.get_children():
				if sub is VBoxContainer:
					for label in sub.get_children():
						if label is Label and label.get_meta("tower_id", "") == config.tower_id:
							flash_button_red(child)
							break
