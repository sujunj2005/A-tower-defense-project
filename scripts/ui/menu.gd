extends Control
class_name MainMenu

func _ready():
	## 设置根节点Control的anchors跟随视口
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	setup_ui()
	_print_window_info()

func _notification(what: int) -> void:
	## 监听窗口大小变化
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_print_window_info()

func _print_window_info() -> void:
	## 打印窗口和stretch模式信息
	var root_window = get_tree().root
	if root_window:
		print("[Menu] 窗口大小: ", root_window.size)
		print("[Menu] content_scale_size: ", root_window.content_scale_size)
		print("[Menu] content_scale_mode: ", root_window.content_scale_mode)
		print("[Menu] content_scale_aspect: ", root_window.content_scale_aspect)
		print("[Menu] 视口大小: ", get_viewport().size)

func setup_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title = Label.new()
	title.text = "塔防游戏"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 100
	title.offset_bottom = 180
	title.offset_left = 0
	title.offset_right = 0
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	add_child(title)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.offset_left = -150
	vbox.offset_top = -60
	vbox.offset_right = 150
	vbox.offset_bottom = 60
	add_child(vbox)

	var start_btn = create_button("开始游戏", _on_start_pressed)
	vbox.add_child(start_btn)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	var quit_btn = create_button("退出游戏", _on_quit_pressed)
	vbox.add_child(quit_btn)

func create_button(text: String, callback: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 60)
	btn.pressed.connect(callback)
	btn.add_theme_font_size_override("font_size", 24)
	return btn

func _on_start_pressed():
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager:
		scene_manager.goto_game("map_01")
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
