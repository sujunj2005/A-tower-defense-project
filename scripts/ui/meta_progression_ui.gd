extends Control

var _current_tab: int = 0
var _tab_buttons: Array[Button] = []
var _content_container: VBoxContainer
var _currency_bar: HBoxContainer
var _wisdom_label: Label
var _destiny_label: Label
var _tab_bar: HBoxContainer
var _back_button: Button
var _scroll_container: ScrollContainer

func _ready() -> void:
	_build_ui()
	_update_currency_display()
	_switch_tab(0)

func _build_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.anchors_preset = Control.PRESET_FULL_RECT
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)

	_currency_bar = HBoxContainer.new()
	_currency_bar.add_theme_constant_override("separation", 40)
	_currency_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(_currency_bar)

	_wisdom_label = Label.new()
	_wisdom_label.add_theme_font_size_override("font_size", 20)
	_wisdom_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	_currency_bar.add_child(_wisdom_label)

	_destiny_label = Label.new()
	_destiny_label.add_theme_font_size_override("font_size", 20)
	_destiny_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_currency_bar.add_child(_destiny_label)

	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 10)
	_tab_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(_tab_bar)

	var tab_names: Array[String] = ["解锁商店", "成就", "已解锁"]
	for i: int in range(tab_names.size()):
		var btn: Button = Button.new()
		btn.text = tab_names[i]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(_switch_tab.bind(i))
		_tab_bar.add_child(btn)
		_tab_buttons.append(btn)

	_scroll_container = ScrollContainer.new()
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(_scroll_container)

	_content_container = VBoxContainer.new()
	_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_container.add_theme_constant_override("separation", 8)
	_scroll_container.add_child(_content_container)

	_back_button = Button.new()
	_back_button.text = "返回主菜单"
	_back_button.custom_minimum_size = Vector2(200, 45)
	_back_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_back_button.pressed.connect(_on_back)
	main_vbox.add_child(_back_button)

func _switch_tab(tab_index: int) -> void:
	_current_tab = tab_index
	for i: int in range(_tab_buttons.size()):
		var btn: Button = _tab_buttons[i]
		if i == tab_index:
			btn.modulate = Color(1.2, 1.2, 0.8)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)
	_refresh_content()

func _refresh_content() -> void:
	for child: Node in _content_container.get_children():
		child.queue_free()
	_update_currency_display()
	match _current_tab:
		0:
			_show_unlock_shop()
		1:
			_show_achievements()
		2:
			_show_unlocked_content()

func _update_currency_display() -> void:
	var save: PlayerSaveData = Global.get_player_save()
	if _wisdom_label:
		_wisdom_label.text = "人生智慧：%d" % save.currencies.get("life_wisdom", 0)
	if _destiny_label:
		_destiny_label.text = "命运点数：%d" % save.currencies.get("destiny_points", 0)

func _show_unlock_shop() -> void:
	var unlock_sys: Node = get_node_or_null("/root/UnlockSystem")
	if not unlock_sys:
		return

	var all_unlocks: Dictionary = unlock_sys.get_all_unlocks()
	var available: Array[Dictionary] = unlock_sys.get_available_unlocks()

	if not available.is_empty():
		var header: Label = _create_section_header("可购买内容")
		_content_container.add_child(header)
		for unlock_info: Dictionary in available:
			_add_unlock_item(unlock_info)

	var locked_items: Array[Dictionary] = []
	for unlock_id: String in all_unlocks:
		if not unlock_sys.is_unlocked(unlock_id) and not unlock_sys.can_unlock(unlock_id):
			var config: Dictionary = all_unlocks[unlock_id].duplicate()
			config["unlock_id"] = unlock_id
			locked_items.append(config)

	if not locked_items.is_empty():
		var header2: Label = _create_section_header("未满足条件")
		_content_container.add_child(header2)
		for locked_info: Dictionary in locked_items:
			_add_locked_item(locked_info)

func _add_unlock_item(unlock_info: Dictionary) -> void:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.2, 0.15, 0.9)
	style.border_color = Color(0.4, 0.7, 0.4)
	style.border_width_bottom = 2
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)
	_content_container.add_child(panel)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_label: Label = Label.new()
	name_label.text = unlock_info.get("name", "未知")
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)

	var type_label: Label = Label.new()
	var type_map: Dictionary = {"era": "时代", "profession": "职业", "difficulty": "难度", "buff": "增益"}
	type_label.text = "类型：%s" % type_map.get(unlock_info.get("type", ""), unlock_info.get("type", ""))
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(type_label)

	var cost: Dictionary = unlock_info.get("cost", {})
	var cost_text: String = ""
	for currency_id: String in cost:
		var currency_name: Dictionary = {"life_wisdom": "人生智慧", "destiny_points": "命运点数"}
		cost_text += "%s：%d  " % [currency_name.get(currency_id, currency_id), cost[currency_id]]
	var cost_label: Label = Label.new()
	cost_label.text = cost_text.strip_edges()
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	info_vbox.add_child(cost_label)

	var buy_btn: Button = Button.new()
	buy_btn.text = "购买"
	buy_btn.custom_minimum_size = Vector2(80, 35)
	var unlock_id: String = unlock_info.get("unlock_id", "")
	buy_btn.pressed.connect(_on_buy_unlock.bind(unlock_id))
	hbox.add_child(buy_btn)

func _add_locked_item(locked_info: Dictionary) -> void:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.7)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)
	_content_container.add_child(panel)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_label: Label = Label.new()
	name_label.text = locked_info.get("name", "未知")
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	info_vbox.add_child(name_label)

	var prereq: String = locked_info.get("prerequisite", "")
	if prereq != "":
		var prereq_label: Label = Label.new()
		prereq_label.text = "需要成就：%s" % prereq
		prereq_label.add_theme_font_size_override("font_size", 12)
		prereq_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
		info_vbox.add_child(prereq_label)

	var cost: Dictionary = locked_info.get("cost", {})
	var cost_text: String = ""
	for currency_id: String in cost:
		var currency_name: Dictionary = {"life_wisdom": "人生智慧", "destiny_points": "命运点数"}
		cost_text += "%s：%d  " % [currency_name.get(currency_id, currency_id), cost[currency_id]]
	var cost_label: Label = Label.new()
	cost_label.text = cost_text.strip_edges()
	cost_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info_vbox.add_child(cost_label)

	var lock_label: Label = Label.new()
	lock_label.text = "未满足"
	lock_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hbox.add_child(lock_label)

func _show_achievements() -> void:
	var ach_sys: Node = get_node_or_null("/root/AchievementSystem")
	if not ach_sys:
		return

	var all_achs: Dictionary = ach_sys.get_all_achievements()
	var unlocked: Array[String] = ach_sys.get_unlocked_achievements()

	if not unlocked.is_empty():
		var header1: Label = _create_section_header("已解锁成就 (%d)" % unlocked.size())
		_content_container.add_child(header1)
		for ach_id: String in unlocked:
			var config: Dictionary = all_achs.get(ach_id, {})
			_add_achievement_item(ach_id, config, true)

	var locked_count: int = 0
	var locked_achs: Array[Dictionary] = []
	for ach_id: String in all_achs:
		if not ach_id in unlocked:
			locked_count += 1
			locked_achs.append({"id": ach_id, "config": all_achs[ach_id]})

	if locked_count > 0:
		var header2: Label = _create_section_header("未解锁成就 (%d)" % locked_count)
		_content_container.add_child(header2)
		for entry: Dictionary in locked_achs:
			_add_achievement_item(entry.id, entry.config, false)

func _add_achievement_item(ach_id: String, config: Dictionary, is_unlocked: bool) -> void:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if is_unlocked:
		style.bg_color = Color(0.15, 0.2, 0.15, 0.9)
		style.border_color = Color(0.8, 0.7, 0.3)
		style.border_width_bottom = 2
	else:
		style.bg_color = Color(0.15, 0.15, 0.2, 0.7)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)
	_content_container.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	var name_label: Label = Label.new()
	name_label.text = config.get("achievement_name", ach_id)
	name_label.add_theme_font_size_override("font_size", 16)
	if not is_unlocked:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(name_label)

	var desc: String = config.get("description", "")
	if desc != "":
		var desc_label: Label = Label.new()
		desc_label.text = desc
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		vbox.add_child(desc_label)

	var reward: Dictionary = config.get("reward", {})
	if not reward.is_empty():
		var reward_text: String = "奖励："
		for currency_id: String in reward:
			var currency_name: Dictionary = {"life_wisdom": "人生智慧", "destiny_points": "命运点数"}
			reward_text += "%s+%d  " % [currency_name.get(currency_id, currency_id), reward[currency_id]]
		var reward_label: Label = Label.new()
		reward_label.text = reward_text.strip_edges()
		reward_label.add_theme_font_size_override("font_size", 12)
		reward_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		vbox.add_child(reward_label)

func _show_unlocked_content() -> void:
	var save: PlayerSaveData = Global.get_player_save()
	var unlock_sys: Node = get_node_or_null("/root/UnlockSystem")

	if not save.unlocked_eras.is_empty():
		var header1: Label = _create_section_header("已解锁时代")
		_content_container.add_child(header1)
		for era_id: String in save.unlocked_eras:
			var name_str: String = era_id
			if unlock_sys and unlock_sys.has_method("get_unlock_config"):
				var cfg: Dictionary = unlock_sys.get_unlock_config(era_id)
				name_str = cfg.get("name", era_id)
			_add_content_label("  %s" % name_str, Color(0.4, 0.7, 1.0))

	if not save.unlocked_professions.is_empty():
		var header2: Label = _create_section_header("已解锁职业")
		_content_container.add_child(header2)
		for prof_id: String in save.unlocked_professions:
			var name_str: String = prof_id
			if unlock_sys and unlock_sys.has_method("get_unlock_config"):
				var cfg: Dictionary = unlock_sys.get_unlock_config(prof_id)
				name_str = cfg.get("name", prof_id)
			_add_content_label("  %s" % name_str, Color(0.4, 1.0, 0.4))

	if not save.unlocked_buffs.is_empty():
		var header3: Label = _create_section_header("已解锁增益")
		_content_container.add_child(header3)
		for buff_id: String in save.unlocked_buffs:
			var name_str: String = buff_id
			if unlock_sys and unlock_sys.has_method("get_unlock_config"):
				var cfg: Dictionary = unlock_sys.get_unlock_config(buff_id)
				name_str = cfg.get("name", buff_id)
			_add_content_label("  %s" % name_str, Color(1.0, 0.84, 0.0))

	if not save.achievements.is_empty():
		var header4: Label = _create_section_header("已获得成就 (%d)" % save.achievements.size())
		_content_container.add_child(header4)
		for ach_id: String in save.achievements:
			_add_content_label("  %s" % ach_id, Color(0.8, 0.7, 0.3))

func _add_content_label(text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	_content_container.add_child(label)

func _create_section_header(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	return label

func _on_buy_unlock(unlock_id: String) -> void:
	var unlock_sys: Node = get_node_or_null("/root/UnlockSystem")
	if not unlock_sys:
		return
	var success: bool = unlock_sys.unlock(unlock_id)
	if success:
		Global.debug_log("成功解锁：%s" % unlock_id)
	else:
		Global.debug_log("解锁失败：%s" % unlock_id)
	_refresh_content()

func _on_back() -> void:
	GameState.change_state(GameState.State.MAIN_MENU)
