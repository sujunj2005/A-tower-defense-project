extends Node2D

signal event_requested
signal age_advanced

var _age_label: Label
var _stage_label: Label
var _gold_label: Label
var _health_label: Label
var _intelligence_label: Label
var _courage_label: Label
var _profession_label: Label
var _traits_container: HFlowContainer
var _event_button: Button

var _npc_container: VBoxContainer

var _debug_container: VBoxContainer
var _debug_willpower_label: Label
var _debug_craziness_label: Label
var _debug_discipline_label: Label
var _debug_karma_label: Label
var _debug_fame_label: Label
var _debug_happiness_label: Label
var _debug_appearance_label: Label
var _debug_education_label: Label
var _debug_tension_container: VBoxContainer

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

	var hcontainer: HBoxContainer = HBoxContainer.new()
	hcontainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hcontainer.offset_left = 10
	hcontainer.offset_top = 10
	hcontainer.offset_right = -10
	hcontainer.offset_bottom = -10
	hcontainer.add_theme_constant_override("separation", 10)
	canvas.add_child(hcontainer)

	var left_panel: PanelContainer = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(260, 0)
	hcontainer.add_child(left_panel)

	var left_vbox: VBoxContainer = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 8)
	left_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	left_panel.add_child(left_vbox)

	var title: Label = Label.new()
	title.text = tr("LIFE_STAGE")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_vbox.add_child(title)

	_age_label = Label.new()
	_age_label.text = tr("AGE_LABEL") % 6
	left_vbox.add_child(_age_label)

	_stage_label = Label.new()
	_stage_label.text = tr("STAGE_LABEL") % tr("STAGE_CHILDHOOD_NAME")
	left_vbox.add_child(_stage_label)

	_profession_label = Label.new()
	_profession_label.text = ""
	left_vbox.add_child(_profession_label)

	_gold_label = Label.new()
	_gold_label.text = tr("GOLD_LABEL") % 100
	left_vbox.add_child(_gold_label)

	_health_label = Label.new()
	_health_label.text = tr("ATTR_FORMAT") % [_attr_display("health"), 100]
	left_vbox.add_child(_health_label)

	_intelligence_label = Label.new()
	_intelligence_label.text = tr("ATTR_FORMAT") % [_attr_display("intelligence"), 50]
	left_vbox.add_child(_intelligence_label)

	_courage_label = Label.new()
	_courage_label.text = tr("ATTR_FORMAT") % [_attr_display("courage"), 50]
	left_vbox.add_child(_courage_label)

	var traits_title: Label = Label.new()
	traits_title.text = tr("TRAITS_LABEL")
	left_vbox.add_child(traits_title)

	_traits_container = HFlowContainer.new()
	_traits_container.add_theme_constant_override("h_separation", 4)
	_traits_container.add_theme_constant_override("v_separation", 4)
	left_vbox.add_child(_traits_container)

	if OS.is_debug_build():
		_debug_container = VBoxContainer.new()
		_debug_container.name = "DebugPanel"
		_debug_container.add_theme_constant_override("separation", 2)
		left_vbox.add_child(_debug_container)

		var debug_sep: Control = Control.new()
		debug_sep.custom_minimum_size = Vector2(0, 6)
		_debug_container.add_child(debug_sep)

		var debug_title: Label = Label.new()
		debug_title.text = "👁 上帝模式"
		debug_title.add_theme_font_size_override("font_size", 13)
		debug_title.add_theme_color_override("font_color", Color(1.0, 0.55, 0.0, 1.0))
		_debug_container.add_child(debug_title)

		_debug_willpower_label = Label.new()
		_debug_willpower_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_willpower_label)

		_debug_craziness_label = Label.new()
		_debug_craziness_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_craziness_label)

		_debug_discipline_label = Label.new()
		_debug_discipline_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_discipline_label)

		_debug_karma_label = Label.new()
		_debug_karma_label.add_theme_font_size_override("font_size", 12)
		_debug_container.add_child(_debug_karma_label)

		_debug_fame_label = Label.new()
		_debug_fame_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_fame_label)

		_debug_happiness_label = Label.new()
		_debug_happiness_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_happiness_label)

		_debug_appearance_label = Label.new()
		_debug_appearance_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_appearance_label)

		_debug_education_label = Label.new()
		_debug_education_label.add_theme_font_size_override("font_size", 11)
		_debug_container.add_child(_debug_education_label)

		var tension_title: Label = Label.new()
		tension_title.text = "⏳ 活跃张力"
		tension_title.add_theme_font_size_override("font_size", 12)
		tension_title.add_theme_color_override("font_color", Color(0.8, 0.4, 1.0, 1.0))
		_debug_container.add_child(tension_title)

		_debug_tension_container = VBoxContainer.new()
		_debug_tension_container.add_theme_constant_override("separation", 1)
		_debug_container.add_child(_debug_tension_container)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	left_vbox.add_child(spacer)

	_event_button = Button.new()
	_event_button.text = tr("BTN_TRIGGER_EVENT")
	_event_button.custom_minimum_size = Vector2(0, 40)
	left_vbox.add_child(_event_button)

	var right_panel: PanelContainer = PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(240, 0)
	right_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var center_spacer: Control = Control.new()
	center_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hcontainer.add_child(center_spacer)
	hcontainer.add_child(right_panel)

	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 6)
	right_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	right_panel.add_child(right_vbox)

	var npc_title: Label = Label.new()
	npc_title.text = tr("FRIENDS_FAMILY_TITLE")
	npc_title.add_theme_font_size_override("font_size", 20)
	npc_title.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 1.0))
	npc_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_vbox.add_child(npc_title)

	_npc_container = VBoxContainer.new()
	_npc_container.add_theme_constant_override("separation", 4)
	right_vbox.add_child(_npc_container)

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

func _get_profession_display() -> String:
	var session: GameSessionData = Global.get_game_session()
	if session.current_profession == "":
		return tr("PROFESSION_NONE")
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return session.current_profession
	var prof_data = cm.load_json("res://data/professions.json")
	if not prof_data is Dictionary or not prof_data.has("professions"):
		return session.current_profession
	for prof: Dictionary in prof_data.professions:
		if prof.get("profession_id", "") == session.current_profession:
			var name: String = tr(prof.get("name", session.current_profession))
			var salary: int = int(prof.get("salary", 0))
			if salary > 0:
				return "%s  %s" % [name, tr("SALARY_LABEL") % salary]
			return name
	return session.current_profession

func _update_display() -> void:
	var session: GameSessionData = Global.get_game_session()
	if _age_label:
		_age_label.text = tr("AGE_LABEL") % session.current_age
	if _stage_label:
		_stage_label.text = tr("STAGE_LABEL") % _get_stage_display_name(session.current_stage)
	if _profession_label:
		_profession_label.text = tr("PROFESSION_LABEL") % _get_profession_display()
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
	_update_npc_display()
	_update_debug_panel()

func _update_npc_display() -> void:
	if not _npc_container:
		return
	for child: Node in _npc_container.get_children():
		child.queue_free()
	var session: GameSessionData = Global.get_game_session()
	var active_npcs: Array[NPCData] = []
	for npc: NPCData in session.npcs:
		if npc.is_active:
			active_npcs.append(npc)
	if active_npcs.is_empty():
		var no_npc: Label = Label.new()
		no_npc.text = tr("NPC_NONE")
		no_npc.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
		no_npc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_npc_container.add_child(no_npc)
		return
	for npc: NPCData in active_npcs:
		var npc_box: PanelContainer = PanelContainer.new()
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.12, 0.18, 0.8)
		style.set_corner_radius_all(4)
		style.set_content_margin_all(6)
		style.border_color = Color(0.3, 0.4, 0.6, 0.5)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		npc_box.add_theme_stylebox_override("panel", style)
		_npc_container.add_child(npc_box)
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		npc_box.add_child(vbox)
		var name_label: Label = Label.new()
		var relation_key: String = "NPC_RELATION_" + npc.relation_type.to_upper()
		name_label.text = "%s（%s）" % [tr(npc.name), tr(relation_key)]
		name_label.add_theme_font_size_override("font_size", 15)
		name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))
		vbox.add_child(name_label)
		var stage_text: String = tr("NPC_LIFE_STAGE_" + npc.life_stage.to_upper())
		var info_label: Label = Label.new()
		info_label.text = "%s  %s" % [stage_text, tr("NPC_AGE_LABEL") % npc.age]
		info_label.add_theme_font_size_override("font_size", 12)
		info_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1.0))
		vbox.add_child(info_label)
		var affection_label: Label = Label.new()
		var aff_color: Color
		if npc.affection >= 70:
			aff_color = Color(0.4, 1.0, 0.4, 1.0)
		elif npc.affection >= 40:
			aff_color = Color(1.0, 1.0, 0.4, 1.0)
		else:
			aff_color = Color(1.0, 0.4, 0.4, 1.0)
		affection_label.text = tr("NPC_AFFECTION_LABEL") % npc.affection
		affection_label.add_theme_font_size_override("font_size", 12)
		affection_label.add_theme_color_override("font_color", aff_color)
		vbox.add_child(affection_label)
		if npc.health < 50:
			var health_label: Label = Label.new()
			health_label.text = tr("NPC_HEALTH_LOW") % npc.health
			health_label.add_theme_font_size_override("font_size", 12)
			health_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3, 1.0))
			vbox.add_child(health_label)

func _update_debug_panel() -> void:
	if not _debug_container:
		return
	var session: GameSessionData = Global.get_game_session()
	if _debug_willpower_label:
		_debug_willpower_label.text = "意志力: %d" % session.hidden_attributes.get("willpower", 0)
		var w: int = session.hidden_attributes.get("willpower", 50)
		_debug_willpower_label.add_theme_color_override("font_color", Color.RED if w < 30 else (Color.GREEN if w > 70 else Color.WHITE))
	if _debug_craziness_label:
		_debug_craziness_label.text = "疯狂度: %d" % session.hidden_attributes.get("craziness", 0)
		var c: int = session.hidden_attributes.get("craziness", 50)
		_debug_craziness_label.add_theme_color_override("font_color", Color.RED if c > 70 else Color.WHITE)
	if _debug_discipline_label:
		_debug_discipline_label.text = "纪律性: %d" % session.hidden_attributes.get("discipline", 0)
		var d: int = session.hidden_attributes.get("discipline", 50)
		_debug_discipline_label.add_theme_color_override("font_color", Color.RED if d < 30 else (Color.GREEN if d > 70 else Color.WHITE))
	if _debug_karma_label:
		var ktext: String = "业力: %+d" % session.karma
		if session.karma >= 70:
			ktext += " 🌟主角光环"
		elif session.karma >= 30:
			ktext += " ✨好运"
		elif session.karma <= -70:
			ktext += " 💀厄运缠身"
		elif session.karma <= -30:
			ktext += " ⚠走背运"
		_debug_karma_label.text = ktext
		var kc: Color = Color.GREEN if session.karma >= 30 else (Color.RED if session.karma <= -30 else Color.WHITE)
		_debug_karma_label.add_theme_color_override("font_color", kc)
	if _debug_fame_label:
		_debug_fame_label.text = "名望: %d" % session.fame
	if _debug_happiness_label:
		_debug_happiness_label.text = "幸福感: %d" % session.attributes.get("happiness", 0)
	if _debug_appearance_label:
		_debug_appearance_label.text = "外貌值: %d" % session.attributes.get("appearance", 0)
	if _debug_education_label:
		_debug_education_label.text = "学历: %s" % (session.education_level if session.education_level != "" else "无")
	if _debug_tension_container:
		for child: Node in _debug_tension_container.get_children():
			child.queue_free()
		if session.tensions.is_empty():
			var no_t: Label = Label.new()
			no_t.text = "  无"
			no_t.add_theme_font_size_override("font_size", 10)
			no_t.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1.0))
			_debug_tension_container.add_child(no_t)
		else:
			for t: TensionData in session.tensions:
				var tl: Label = Label.new()
				var bar: String = ""
				var bar_len: int = 10
				var filled: int = ceil((1.0 - float(t.remaining) / maxf(float(t.duration), 1.0)) * bar_len)
				for i: int in bar_len:
					bar += "█" if i < filled else "░"
				tl.text = "  %s [%s] %d年" % [tr(t.title) if t.title != "" else t.tension_type, bar, t.remaining]
				tl.add_theme_font_size_override("font_size", 10)
				var tc: Color = Color.RED if t.pressure > 0.7 else (Color.YELLOW if t.pressure > 0.3 else Color(0.6, 0.8, 0.6, 1.0))
				tl.add_theme_color_override("font_color", tc)
				_debug_tension_container.add_child(tl)

func _on_event_pressed() -> void:
	var session: GameSessionData = Global.get_game_session()
	if session.attributes.get("health", 0) <= 0:
		session.ending_reason = "health_depleted"
		GameState.change_state(GameState.State.ENDING)
		return
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
