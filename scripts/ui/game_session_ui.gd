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

func _ready() -> void:
	_build_ui()
	_update_display()
	if _event_button:
		_event_button.pressed.connect(_on_event_pressed)
	var age_sys: Node = _get_age_system()
	if age_sys and age_sys.has_signal("stage_changed"):
		age_sys.stage_changed.connect(_on_stage_changed)

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
	title.text = "人生阶段"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_age_label = Label.new()
	_age_label.text = "年龄：6"
	vbox.add_child(_age_label)

	_stage_label = Label.new()
	_stage_label.text = "阶段：童年"
	vbox.add_child(_stage_label)

	_gold_label = Label.new()
	_gold_label.text = "金币：50"
	vbox.add_child(_gold_label)

	_health_label = Label.new()
	_health_label.text = "%s：100" % _attr_display("health")
	vbox.add_child(_health_label)

	_intelligence_label = Label.new()
	_intelligence_label.text = "%s：50" % _attr_display("intelligence")
	vbox.add_child(_intelligence_label)

	_courage_label = Label.new()
	_courage_label.text = "%s：50" % _attr_display("courage")
	vbox.add_child(_courage_label)

	var traits_title: Label = Label.new()
	traits_title.text = "词条："
	vbox.add_child(traits_title)

	_traits_container = HFlowContainer.new()
	_traits_container.add_theme_constant_override("h_separation", 4)
	_traits_container.add_theme_constant_override("v_separation", 4)
	vbox.add_child(_traits_container)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer)

	_event_button = Button.new()
	_event_button.text = "触发事件"
	_event_button.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(_event_button)

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
		return stages[stage_id].get("stage_name", stage_id)
	return stage_id

func _update_display() -> void:
	var session: GameSessionData = Global.get_game_session()
	if _age_label:
		_age_label.text = "年龄：%d" % session.current_age
	if _stage_label:
		_stage_label.text = "阶段：%s" % _get_stage_display_name(session.current_stage)
	if _gold_label:
		_gold_label.text = "金币：%d" % session.gold
	if _health_label:
		_health_label.text = "%s：%d" % [_attr_display("health"), session.attributes.get("health", 0)]
	if _intelligence_label:
		_intelligence_label.text = "%s：%d" % [_attr_display("intelligence"), session.attributes.get("intelligence", 0)]
	if _courage_label:
		_courage_label.text = "%s：%d" % [_attr_display("courage"), session.attributes.get("courage", 0)]
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
			no_trait.text = "无"
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
