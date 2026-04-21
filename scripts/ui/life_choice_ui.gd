extends Control

signal game_start_confirmed
signal back_to_menu

var _birthday_tab: Node
var _family_tab: Node
var _trait_tab: Node
var _attribute_tab: Node
var _points_display: Node
var _confirm_btn: Button
var _back_btn: Button
var _warning_label: Label

var _selected_era: String = "china_modern"
var _selected_region: String = "tier2_city"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 100)
	root_margin.add_theme_constant_override("margin_right", 100)
	root_margin.add_theme_constant_override("margin_top", 16)
	root_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(root_margin)
	_setup_background(root_margin)
	_setup_content(root_margin)
	_connect_signals()

func _setup_background(parent: Control) -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.1, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _setup_content(parent: Control) -> void:
	var outer: VBoxContainer = VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	offset_top = 40
	offset_bottom = -4
	outer.add_theme_constant_override("separation", 8)
	parent.add_child(outer)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	outer.add_child(title_row)
	var title_lbl: Label = Label.new()
	title_lbl.text = tr("LIFE_CHOICE_TITLE")
	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 1.0))
	title_row.add_child(title_lbl)

	var main: HBoxContainer = HBoxContainer.new()
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 12)
	outer.add_child(main)

	var col_appear: VBoxContainer = VBoxContainer.new()
	col_appear.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col_appear.alignment = BoxContainer.ALIGNMENT_CENTER
	main.add_child(col_appear)
	var appear_panel: PanelContainer = _wrap_module(null, "LIFE_CHOICE_APPEARANCE")
	appear_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_appear.add_child(appear_panel)

	var col_content: VBoxContainer = VBoxContainer.new()
	col_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_content.add_theme_constant_override("separation", 12)
	main.add_child(col_content)

	var row1: HBoxContainer = HBoxContainer.new()
	row1.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row1.add_theme_constant_override("separation", 12)
	col_content.add_child(row1)

	_birthday_tab = load("res://scripts/ui/life_choice/birthday_tab.gd").new()
	var bday_panel: PanelContainer = _wrap_module(_birthday_tab, "LIFE_CHOICE_TAB_BIRTHDAY")
	bday_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bday_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row1.add_child(bday_panel)

	_family_tab = load("res://scripts/ui/life_choice/family_tab.gd").new()
	var fam_panel: PanelContainer = _wrap_module(_family_tab, "LIFE_CHOICE_TAB_FAMILY")
	fam_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fam_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row1.add_child(fam_panel)

	var row2: HBoxContainer = HBoxContainer.new()
	row2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row2.add_theme_constant_override("separation", 12)
	col_content.add_child(row2)

	_trait_tab = load("res://scripts/ui/life_choice/trait_tab.gd").new()
	var trait_panel: PanelContainer = _wrap_module(_trait_tab, "LIFE_CHOICE_TAB_TRAIT")
	trait_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trait_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row2.add_child(trait_panel)

	_attribute_tab = load("res://scripts/ui/life_choice/attribute_tab.gd").new()
	var attr_panel: PanelContainer = _wrap_module(_attribute_tab, "LIFE_CHOICE_TAB_ATTRIBUTE")
	attr_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attr_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row2.add_child(attr_panel)

	var pts_row: HBoxContainer = HBoxContainer.new()
	pts_row.alignment = BoxContainer.ALIGNMENT_END
	col_content.add_child(pts_row)
	_points_display = load("res://scripts/ui/components/points_display.gd").new()
	pts_row.add_child(_points_display)

	var bottom_row: HBoxContainer = HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_row.add_theme_constant_override("separation", 20)
	outer.add_child(bottom_row)

	_warning_label = Label.new()
	_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warning_label.add_theme_font_size_override("font_size", 13)
	_warning_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	_warning_label.text = ""
	bottom_row.add_child(_warning_label)

	_back_btn = Button.new()
	_back_btn.text = tr("LIFE_CHOICE_BACK")
	_back_btn.custom_minimum_size = Vector2(140, 40)
	_back_btn.add_theme_font_size_override("font_size", 15)
	_back_btn.pressed.connect(_on_back)
	bottom_row.add_child(_back_btn)

	_confirm_btn = Button.new()
	_confirm_btn.text = tr("LIFE_CHOICE_CONFIRM")
	_confirm_btn.custom_minimum_size = Vector2(200, 40)
	_confirm_btn.add_theme_font_size_override("font_size", 17)
	_confirm_btn.pressed.connect(_on_confirm)
	bottom_row.add_child(_confirm_btn)


	_family_tab.setup(_points_display)
	_attribute_tab.setup(_points_display)

func _wrap_module(inner: Control, title_key: String = "") -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 1.0)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.5, 0.7, 0.8)
	style.set_corner_radius_all(4)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	if title_key != "":
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		var header_row: HBoxContainer = HBoxContainer.new()
		var icon_lbl: Label = Label.new()
		icon_lbl.text = "◆ "
		icon_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0, 1.0))
		icon_lbl.add_theme_font_size_override("font_size", 14)
		header_row.add_child(icon_lbl)
		var title_lbl: Label = Label.new()
		title_lbl.text = tr(title_key)
		title_lbl.add_theme_font_size_override("font_size", 14)
		title_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))
		header_row.add_child(title_lbl)
		vbox.add_child(header_row)
		if inner:
			vbox.add_child(inner)
		else:
			var placeholder: Control = Control.new()
			placeholder.custom_minimum_size = Vector2(200, 200)
			vbox.add_child(placeholder)
		panel.add_child(vbox)
	else:
		if inner:
			panel.add_child(inner)
	return panel

func _connect_signals() -> void:
	_family_tab.family_changed.connect(_on_family_changed)
	_trait_tab.traits_changed.connect(_on_traits_changed)
	_attribute_tab.attributes_changed.connect(_on_attributes_changed)
	_points_display.points_changed.connect(_on_points_changed)

func _on_family_changed(_family_id: String, _cost: int) -> void:
	_recalculate_points()

func _on_traits_changed(_ids: Array[String], _total_cost: int) -> void:
	_recalculate_points()

func _on_attributes_changed(_attrs: Dictionary, _delta: int) -> void:
	_recalculate_points()

func _on_points_changed(remaining: int) -> void:
	_confirm_btn.disabled = remaining < 0
	if remaining < 0:
		_warning_label.text = tr("LIFE_CHOICE_POINTS_NEGATIVE_WARNING")
	else:
		_warning_label.text = ""

func _recalculate_points() -> void:
	var family_cost: int = _family_tab.get_selected_cost()
	var trait_costs: Array[int] = _trait_tab.get_selected_costs()
	var attr_delta: int = _attribute_tab.get_total_delta()
	_points_display.recalculate(family_cost, trait_costs, attr_delta)

func _on_confirm() -> void:
	if _points_display.get_remaining() < 0:
		return
	var session: GameSessionData = Global.get_game_session()
	session.birthday = _birthday_tab.get_birthday()
	var es: EraSystem = get_node("/root/EraSystem")
	es.load_era(_selected_era)
	es.load_family(_family_tab.get_selected_family_id())
	es.current_region = _selected_region
	es.initialize_session(
		_attribute_tab.get_attributes(),
		_trait_tab.get_selected_trait_ids()
	)
	game_start_confirmed.emit()
	GameState.change_state(GameState.State.STAGE)

func _on_back() -> void:
	back_to_menu.emit()
	GameState.change_state(GameState.State.MAIN_MENU)
