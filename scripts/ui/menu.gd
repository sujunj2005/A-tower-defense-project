extends Control

var _title_label: Label
var _subtitle_label: Label
var _continue_btn: Button
var _start_btn: Button
var _meta_btn: Button
var _load_btn: Button
var _quit_btn: Button
var _lang_btn: Button

var _debug_btn: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_setup_ui()
	_update_continue_button()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh_texts()

func _refresh_texts() -> void:
	if _title_label: _title_label.text = tr("MAIN_TITLE")
	if _subtitle_label: _subtitle_label.text = tr("MAIN_SUBTITLE")
	if _continue_btn: _continue_btn.text = tr("BTN_CONTINUE_GAME")
	if _start_btn: _start_btn.text = tr("BTN_START_GAME")
	if _meta_btn: _meta_btn.text = tr("BTN_META_GROWTH")
	if _load_btn: _load_btn.text = tr("BTN_LOAD_GAME")
	if _quit_btn: _quit_btn.text = tr("BTN_QUIT")
	if _lang_btn: _lang_btn.text = tr("BTN_LANGUAGE")
	if _debug_btn: _debug_btn.text = tr("BTN_DEBUG_TEST_MAP")

func _setup_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_title_label = Label.new()
	_title_label.text = tr("MAIN_TITLE")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_title_label.offset_top = 80
	_title_label.offset_bottom = 160
	_title_label.offset_left = 0
	_title_label.offset_right = 0
	_title_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_title_label.add_theme_font_size_override("font_size", 48)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = tr("MAIN_SUBTITLE")
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_subtitle_label.offset_top = 155
	_subtitle_label.offset_bottom = 190
	_subtitle_label.offset_left = 0
	_subtitle_label.offset_right = 0
	_subtitle_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_subtitle_label.add_theme_font_size_override("font_size", 20)
	_subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	add_child(_subtitle_label)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.offset_left = -150
	vbox.offset_top = -80
	vbox.offset_right = 150
	vbox.offset_bottom = 80
	add_child(vbox)

	_continue_btn = _create_button(tr("BTN_CONTINUE_GAME"), _on_continue_pressed)
	_continue_btn.modulate = Color(0.3, 1.0, 0.5)
	_continue_btn.visible = false
	vbox.add_child(_continue_btn)

	_start_btn = _create_button(tr("BTN_START_GAME"), _on_start_pressed)
	vbox.add_child(_start_btn)

	_meta_btn = _create_button(tr("BTN_META_GROWTH"), _on_meta_pressed)
	vbox.add_child(_meta_btn)

	_load_btn = _create_button(tr("BTN_LOAD_GAME"), _on_load_pressed)
	vbox.add_child(_load_btn)

	_quit_btn = _create_button(tr("BTN_QUIT"), _on_quit_pressed)
	vbox.add_child(_quit_btn)

	_lang_btn = _create_button(tr("BTN_LANGUAGE"), _on_language_pressed)
	vbox.add_child(_lang_btn)

	if OS.is_debug_build():
		_debug_btn = Button.new()
		_debug_btn.text = tr("BTN_DEBUG_TEST_MAP")
		_debug_btn.position = Vector2(20, 20)
		_debug_btn.add_theme_font_size_override("font_size", 16)
		_debug_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		_debug_btn.pressed.connect(_on_debug_test_map_pressed)
		add_child(_debug_btn)

func _create_button(text: String, callback: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 55)
	btn.pressed.connect(callback)
	btn.add_theme_font_size_override("font_size", 22)
	return btn

func _on_start_pressed() -> void:
	GameState.change_state(GameState.State.ERA_SELECTION)

func _on_continue_pressed() -> void:
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if not ss or not ss.has_method("load_game"):
		return
	if not ss.load_game(0):
		Global.debug_log(tr("NO_SAVE"))
		_update_continue_button()
		return
	var saved_state: int = ss.get_saved_game_state(0)
	if saved_state >= 0:
		GameState.change_state(saved_state)
	else:
		GameState.change_state(GameState.State.STAGE)

func _on_meta_pressed() -> void:
	GameState.change_state(GameState.State.META_PROGRESSION)

func _on_load_pressed() -> void:
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("load_game"):
		if ss.load_game(0):
			var saved_state: int = ss.get_saved_game_state(0)
			if saved_state >= 0:
				GameState.change_state(saved_state)
			else:
				GameState.change_state(GameState.State.STAGE)
		else:
			Global.debug_log(tr("NO_SAVE"))
			_update_continue_button()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _update_continue_button() -> void:
	if not _continue_btn:
		return
	_continue_btn.visible = false
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if not ss or not ss.has_method("has_save"):
		return
	if not ss.has_save(0):
		return
	var saved_state: int = ss.get_saved_game_state(0)
	if saved_state < 0:
		return
	if saved_state == GameState.State.ENDING:
		return
	_continue_btn.visible = true

func _on_debug_test_map_pressed() -> void:
	Global.debug_map_id = "map_test"
	Global.reset_game_session()
	GameState.change_state(GameState.State.BATTLE)

func _on_language_pressed() -> void:
	_show_language_selector()

func _show_language_selector() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -100
	panel.offset_bottom = 100
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	panel.add_child(vbox)

	var title := Label.new()
	title.text = tr("LANG_SELECT_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	var i18n: Node = get_node_or_null("/root/I18nManager")
	var current: String = i18n.current_locale if i18n else "zh"
	var locales: PackedStringArray = ["zh", "en"] if not i18n else i18n.get_supported_locales()
	for locale: String in locales:
		var btn := Button.new()
		var display: String = i18n.get_locale_display_name(locale) if i18n else locale
		btn.text = display
		btn.custom_minimum_size = Vector2(200, 45)
		btn.add_theme_font_size_override("font_size", 20)
		if locale == current:
			btn.modulate = Color(1.2, 1.2, 0.8)
		btn.pressed.connect(_on_lang_selected.bind(locale, overlay, panel))
		vbox.add_child(btn)

func _on_lang_selected(locale: String, overlay: ColorRect, panel: PanelContainer) -> void:
	var i18n: Node = get_node_or_null("/root/I18nManager")
	if i18n:
		i18n.set_language(locale)
	overlay.queue_free()
	panel.queue_free()
