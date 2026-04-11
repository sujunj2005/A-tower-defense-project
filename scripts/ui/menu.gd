extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_setup_ui()

func _setup_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title: Label = Label.new()
	title.text = "人生塔防"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 80
	title.offset_bottom = 160
	title.offset_left = 0
	title.offset_right = 0
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Life Tower Defense"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	subtitle.offset_top = 155
	subtitle.offset_bottom = 190
	subtitle.offset_left = 0
	subtitle.offset_right = 0
	subtitle.grow_horizontal = Control.GROW_DIRECTION_BOTH
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	add_child(subtitle)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.offset_left = -150
	vbox.offset_top = -80
	vbox.offset_right = 150
	vbox.offset_bottom = 80
	add_child(vbox)

	var start_btn: Button = _create_button("开始游戏", _on_start_pressed)
	vbox.add_child(start_btn)

	var meta_btn: Button = _create_button("长效成长", _on_meta_pressed)
	vbox.add_child(meta_btn)

	var load_btn: Button = _create_button("载入游戏", _on_load_pressed)
	vbox.add_child(load_btn)

	var quit_btn: Button = _create_button("退出游戏", _on_quit_pressed)
	vbox.add_child(quit_btn)

func _create_button(text: String, callback: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 55)
	btn.pressed.connect(callback)
	btn.add_theme_font_size_override("font_size", 22)
	return btn

func _on_start_pressed() -> void:
	GameState.change_state(GameState.State.ERA_SELECTION)

func _on_meta_pressed() -> void:
	GameState.change_state(GameState.State.META_PROGRESSION)

func _on_load_pressed() -> void:
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("load_game"):
		if ss.load_game(0):
			GameState.change_state(GameState.State.STAGE)
		else:
			Global.debug_log("没有可载入的存档")

func _on_quit_pressed() -> void:
	get_tree().quit()
