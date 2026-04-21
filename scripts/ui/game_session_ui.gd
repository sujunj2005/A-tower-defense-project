extends Node2D

signal event_requested
signal age_advanced

var _age_label: Label
var _stage_label: Label
var _gold_label: Label
var _health_label: Label
var _intelligence_label: Label
var _courage_label: Label
var _traits_container: HFlowContainer
var _event_button: Button

var _pause_canvas: CanvasLayer
var _pause_menu: Control
var _is_paused: bool = false
var _pause_bg_gui_input_callable: Callable

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_display()

func _ready() -> void:
	_build_ui()
	_update_display()
	if _event_button:
		_event_button.pressed.connect(_on_event_pressed)
	var age_sys: Node = _get_age_system()
	if age_sys and age_sys.has_signal("stage_changed"):
		age_sys.stage_changed.connect(_on_stage_changed)
	set_process_input(true)

func _build_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	panel.offset_right = 280
	panel.offset_left = 10
	panel.offset_top = 10
	panel.offset_bottom = -10
	canvas.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = tr("LIFE_STAGE")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_age_label = Label.new()
	_age_label.text = tr("AGE_LABEL") % 6
	vbox.add_child(_age_label)

	_stage_label = Label.new()
	_stage_label.text = tr("STAGE_LABEL") % tr("STAGE_CHILDHOOD_NAME")
	vbox.add_child(_stage_label)

	_gold_label = Label.new()
	_gold_label.text = tr("GOLD_LABEL") % 50
	vbox.add_child(_gold_label)

	_health_label = Label.new()
	_health_label.text = tr("ATTR_FORMAT") % [_attr_display("health"), 100]
	vbox.add_child(_health_label)

	_intelligence_label = Label.new()
	_intelligence_label.text = tr("ATTR_FORMAT") % [_attr_display("intelligence"), 50]
	vbox.add_child(_intelligence_label)

	_courage_label = Label.new()
	_courage_label.text = tr("ATTR_FORMAT") % [_attr_display("courage"), 50]
	vbox.add_child(_courage_label)

	var traits_title: Label = Label.new()
	traits_title.text = tr("TRAITS_LABEL")
	vbox.add_child(traits_title)

	_traits_container = HFlowContainer.new()
	_traits_container.add_theme_constant_override("h_separation", 4)
	_traits_container.add_theme_constant_override("v_separation", 4)
	vbox.add_child(_traits_container)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer)

	_event_button = Button.new()
	_event_button.text = tr("BTN_TRIGGER_EVENT")
	_event_button.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(_event_button)

	_build_pause_menu()

func _get_age_system() -> Node:
	return get_node_or_null("/root/AgeSystem")

func _get_trait_system() -> Node:
	return get_node_or_null("/root/TraitSystem")

func _get_achievement_system() -> Node:
	return get_node_or_null("/root/AchievementSystem")

func _get_stage_display_name(stage_id: String) -> String:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return stage_id
	var stages_data: Dictionary = cm.load_json("res://data/stages.json")
	if not stages_data.has("stages"):
		return stage_id
	var stages: Dictionary = stages_data.stages
	if stages.has(stage_id):
		return tr(stages[stage_id].get("stage_name", stage_id))
	return stage_id

func _update_display() -> void:
	var session: GameSessionData = Global.get_game_session()
	if _age_label:
		_age_label.text = tr("AGE_LABEL") % session.current_age
	if _stage_label:
		_stage_label.text = tr("STAGE_LABEL") % _get_stage_display_name(session.current_stage)
	if _gold_label:
		_gold_label.text = tr("GOLD_LABEL") % session.gold
	if _health_label:
		_health_label.text = tr("ATTR_FORMAT") % [_attr_display("health"), session.attributes.get("health", 0)]
	if _intelligence_label:
		_intelligence_label.text = tr("ATTR_FORMAT") % [_attr_display("intelligence"), session.attributes.get("intelligence", 0)]
	if _courage_label:
		_courage_label.text = tr("ATTR_FORMAT") % [_attr_display("courage"), session.attributes.get("courage", 0)]
	if _traits_container:
		for child: Node in _traits_container.get_children():
			child.queue_free()
		var ts: Node = _get_trait_system()
		var badge_script: GDScript = load("res://scripts/ui/components/trait_badge.gd")
		for trait_id: String in session.traits:
			var badge: HBoxContainer = badge_script.new()
			badge.setup(trait_id)
			badge.hovered.connect(_on_trait_hovered)
			badge.unhovered.connect(_on_trait_unhovered)
			_traits_container.add_child(badge)
		if session.traits.is_empty():
			var no_trait: Label = Label.new()
			no_trait.text = tr("TRAITS_NONE")
			no_trait.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
			_traits_container.add_child(no_trait)

func _on_event_pressed() -> void:
	event_requested.emit()
	GameState.change_state(GameState.State.EVENT)

func _on_stage_changed(new_stage: String) -> void:
	_update_display()
	var ach: Node = _get_achievement_system()
	if ach and ach.has_method("on_stage_reached"):
		ach.on_stage_reached(new_stage)

func _on_trait_hovered(badge: Control, trait_id: String) -> void:
	var tm: Node = get_node_or_null("/root/TooltipManager")
	if tm and tm.has_method("show_trait_tooltip"):
		tm.show_trait_tooltip(trait_id, badge.global_position + Vector2(0.0, -60.0))

func _on_trait_unhovered() -> void:
	var tm: Node = get_node_or_null("/root/TooltipManager")
	if tm and tm.has_method("hide_tooltip"):
		tm.hide_tooltip()

func _attr_display(attr_id: String) -> String:
	var ac: Node = get_node_or_null("/root/AttributeConfig")
	if ac and ac.has_method("get_display_with_icon"):
		return ac.get_display_with_icon(attr_id)
	return attr_id

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _is_paused:
				_resume_game()
			else:
				_pause_game()

func _build_pause_menu() -> void:
	_pause_canvas = CanvasLayer.new()
	_pause_canvas.layer = 100
	add_child(_pause_canvas)

	_pause_menu = Control.new()
	_pause_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_menu.mouse_filter = Control.MOUSE_FILTER_PASS
	_pause_menu.visible = false
	_pause_canvas.add_child(_pause_menu)

	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.name = "PauseBg"
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_bg_gui_input_callable = _on_pause_bg_gui_input
	bg.gui_input.connect(_pause_bg_gui_input_callable)
	_pause_menu.add_child(bg)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300
	panel.offset_top = -200
	panel.offset_right = 300
	panel.offset_bottom = 200
	_pause_menu.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.add_theme_constant_override("margin_top", 30)
	vbox.add_theme_constant_override("margin_bottom", 30)
	vbox.add_theme_constant_override("margin_left", 40)
	vbox.add_theme_constant_override("margin_right", 40)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = tr("PAUSE_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	vbox.add_child(title)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)

	var resume_btn = Button.new()
	resume_btn.text = tr("BTN_RESUME")
	resume_btn.custom_minimum_size = Vector2(600, 60)
	resume_btn.add_theme_font_size_override("font_size", 28)
	resume_btn.pressed.connect(_resume_game)
	vbox.add_child(resume_btn)

	var menu_btn = Button.new()
	menu_btn.text = tr("BTN_MAIN_MENU")
	menu_btn.custom_minimum_size = Vector2(600, 60)
	menu_btn.add_theme_font_size_override("font_size", 28)
	menu_btn.pressed.connect(_on_pause_main_menu)
	vbox.add_child(menu_btn)

	var abandon_btn = Button.new()
	abandon_btn.text = tr("BTN_ABANDON_GAME")
	abandon_btn.custom_minimum_size = Vector2(600, 60)
	abandon_btn.add_theme_font_size_override("font_size", 28)
	abandon_btn.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	abandon_btn.pressed.connect(_on_pause_abandon)
	vbox.add_child(abandon_btn)

func _on_pause_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_resume_game()

func _pause_game() -> void:
	_is_paused = true
	get_tree().paused = true
	_pause_menu.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_pause_canvas.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_pause_menu.visible = true

func _resume_game() -> void:
	_is_paused = false
	get_tree().paused = false
	_pause_menu.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_pause_canvas.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_pause_menu.visible = false

func _on_pause_main_menu() -> void:
	_is_paused = false
	_pause_menu.visible = false
	get_tree().paused = false
	_pause_menu.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_pause_canvas.set_process_mode(Node.PROCESS_MODE_INHERIT)
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"):
		ss.save_game(0)
	Global.reset_game_session()
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager:
		scene_manager.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_pause_abandon() -> void:
	_is_paused = false
	_pause_menu.visible = false
	get_tree().paused = false
	_pause_menu.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_pause_canvas.set_process_mode(Node.PROCESS_MODE_INHERIT)
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("delete_save"):
		ss.delete_save(0)
	Global.reset_game_session()
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager:
		scene_manager.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
