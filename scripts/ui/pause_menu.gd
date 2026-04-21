extends Control
class_name PauseMenu

signal pause_toggled(is_paused: bool)

var is_paused: bool = false

var _bg_gui_input_callable: Callable

func _ready():
	visible = false
	setup_ui()
	# 确保节点能够接收输入事件
	mouse_filter = Control.MOUSE_FILTER_PASS
	# 启用输入处理
	set_process_input(true)

var _title_label: Label
var _resume_btn: Button
var _menu_btn: Button
var _abandon_btn: Button
var _quit_btn: Button

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh_texts()

func _refresh_texts() -> void:
	if _title_label: _title_label.text = tr("PAUSE_TITLE")
	if _resume_btn: _resume_btn.text = tr("BTN_RESUME")
	if _menu_btn: _menu_btn.text = tr("BTN_MAIN_MENU")
	if _abandon_btn: _abandon_btn.text = tr("BTN_ABANDON_GAME")
	if _quit_btn: _quit_btn.text = tr("BTN_QUIT")

func setup_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.name = "Background"
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_bg_gui_input_callable = _on_background_gui_input
	bg.gui_input.connect(_bg_gui_input_callable)
	add_child(bg)

	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300
	panel.offset_top = -225
	panel.offset_right = 300
	panel.offset_bottom = 225
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.add_theme_constant_override("margin_top", 40)
	vbox.add_theme_constant_override("margin_bottom", 40)
	vbox.add_theme_constant_override("margin_left", 40)
	vbox.add_theme_constant_override("margin_right", 40)
	panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.text = tr("PAUSE_TITLE")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 48)
	_title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	vbox.add_child(_title_label)

	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer_top)

	_resume_btn = create_button(tr("BTN_RESUME"), _on_resume_pressed)
	vbox.add_child(_resume_btn)

	_menu_btn = create_button(tr("BTN_MAIN_MENU"), _on_main_menu_pressed)
	vbox.add_child(_menu_btn)

	_abandon_btn = create_button(tr("BTN_ABANDON_GAME"), _on_abandon_pressed)
	_abandon_btn.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	vbox.add_child(_abandon_btn)

	_quit_btn = create_button(tr("BTN_QUIT"), _on_quit_pressed)
	vbox.add_child(_quit_btn)

func create_button(text: String, callback: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(600, 60)
	btn.pressed.connect(callback)
	btn.add_theme_font_size_override("font_size", 28)
	return btn

func _exit_tree():
	var bg = get_node_or_null("Background")
	if bg and bg.gui_input.is_connected(_bg_gui_input_callable):
		bg.gui_input.disconnect(_bg_gui_input_callable)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if is_paused:
				resume_game()
			else:
				pause_game()

func _on_background_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		resume_game()

func pause_game():
	is_paused = true
	# 暂停整个场景树
	var tree = get_tree()
	tree.paused = true
	# 确保当前节点（暂停菜单）不被暂停
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	visible = true
	pause_toggled.emit(true)

func resume_game():
	is_paused = false
	# 恢复场景树
	var tree = get_tree()
	tree.paused = false
	# 恢复正常处理模式
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	visible = false
	pause_toggled.emit(false)

func _on_resume_pressed():
	resume_game()

func _on_main_menu_pressed():
	is_paused = false
	visible = false
	var tree = get_tree()
	tree.paused = false
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"):
		ss.save_game(0)
	Global.reset_game_session()
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager:
		scene_manager.return_to_main_menu()
	else:
		tree.change_scene_to_file("res://scenes/menu.tscn")

func _on_abandon_pressed():
	is_paused = false
	visible = false
	var tree = get_tree()
	tree.paused = false
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("delete_save"):
		ss.delete_save(0)
	Global.reset_game_session()
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager:
		scene_manager.return_to_main_menu()
	else:
		tree.change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
