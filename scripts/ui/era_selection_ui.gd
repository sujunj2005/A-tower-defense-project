extends Control

signal era_selected(era_id: String)
signal family_selected(family_id: String)
signal region_selected(region_id: String)
signal start_game_confirmed

var _selected_era: String = "china_modern"
var _selected_family: String = "family_worker"
var _selected_region: String = "tier2_city"

var _era_label: Label
var _family_label: Label
var _family_desc_label: Label
var _family_traits_label: Label
var _family_towers_label: Label
var _family_hbox: HBoxContainer
var _families_data: Array[Dictionary] = []
var _eras_data: Array[Dictionary] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_load_eras_data()
	_load_families_data()
	_setup_ui()
	_update_selection_display()

func _load_eras_data() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return
	var eras_json: Dictionary = cm.load_json("res://data/eras.json")
	if not eras_json.has("eras"):
		return
	_eras_data.clear()
	var eras: Dictionary = eras_json.eras
	for era_id: String in eras:
		var era: Dictionary = eras[era_id]
		era["era_id"] = era_id
		_eras_data.append(era)

func _load_families_data() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		push_error("ConfigManager不可用，无法加载家庭背景数据")
		return
	var families_json: Dictionary = cm.load_json("res://data/family_backgrounds.json")
	if not families_json.has("family_backgrounds"):
		push_error("family_backgrounds.json缺少family_backgrounds字段")
		return
	_families_data.clear()
	for fam: Dictionary in families_json.family_backgrounds:
		_families_data.append(fam)

func _get_era_system() -> Node:
	return get_node_or_null("/root/EraSystem")

func _get_era_display_text() -> String:
	for era: Dictionary in _eras_data:
		if era.get("era_id", "") == _selected_era:
			var era_name: String = era.get("era_name", _selected_era)
			var period: String = era.get("time_period", "")
			return "时代：%s（%s）" % [era_name, period]
	return "时代：%s" % _selected_era

func _setup_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.1, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title: Label = Label.new()
	title.text = "选择你的出身"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 30
	title.offset_bottom = 80
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	add_child(title)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	main_vbox.offset_left = -280
	main_vbox.offset_top = -220
	main_vbox.offset_right = 280
	main_vbox.offset_bottom = 220
	add_child(main_vbox)

	_era_label = Label.new()
	_era_label.text = _get_era_display_text()
	_era_label.add_theme_font_size_override("font_size", 22)
	_era_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(_era_label)

	var family_header: Label = Label.new()
	family_header.text = "选择家境："
	family_header.add_theme_font_size_override("font_size", 20)
	family_header.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	main_vbox.add_child(family_header)

	_family_hbox = HBoxContainer.new()
	_family_hbox.add_theme_constant_override("separation", 10)
	main_vbox.add_child(_family_hbox)

	for fam: Dictionary in _families_data:
		var btn: Button = Button.new()
		btn.text = fam.get("family_name", fam.get("family_id", ""))
		btn.custom_minimum_size = Vector2(90, 40)
		btn.pressed.connect(_on_family_button.bind(fam.get("family_id", "")))
		_family_hbox.add_child(btn)

	_family_label = Label.new()
	_family_label.text = ""
	_family_label.add_theme_font_size_override("font_size", 18)
	_family_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(_family_label)

	_family_desc_label = Label.new()
	_family_desc_label.text = ""
	_family_desc_label.add_theme_font_size_override("font_size", 15)
	_family_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	_family_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(_family_desc_label)

	_family_traits_label = Label.new()
	_family_traits_label.text = ""
	_family_traits_label.add_theme_font_size_override("font_size", 16)
	_family_traits_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5, 1.0))
	_family_traits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_family_traits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(_family_traits_label)

	_family_towers_label = Label.new()
	_family_towers_label.text = ""
	_family_towers_label.add_theme_font_size_override("font_size", 14)
	_family_towers_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0, 1.0))
	_family_towers_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_family_towers_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(_family_towers_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	main_vbox.add_child(spacer)

	var start_btn: Button = Button.new()
	start_btn.text = "开始人生"
	start_btn.custom_minimum_size = Vector2(250, 55)
	start_btn.add_theme_font_size_override("font_size", 24)
	start_btn.pressed.connect(_on_start_pressed)
	main_vbox.add_child(start_btn)

	var back_btn: Button = Button.new()
	back_btn.text = "返回主菜单"
	back_btn.custom_minimum_size = Vector2(250, 45)
	back_btn.add_theme_font_size_override("font_size", 18)
	back_btn.pressed.connect(_on_back_pressed)
	main_vbox.add_child(back_btn)

func _on_family_button(family_id: String) -> void:
	_selected_family = family_id
	_update_selection_display()

func _update_selection_display() -> void:
	var selected_data: Dictionary = {}
	for fam: Dictionary in _families_data:
		if fam.get("family_id", "") == _selected_family:
			selected_data = fam
			break
	if selected_data.is_empty():
		return
	var fam_name: String = selected_data.get("family_name", _selected_family)
	var desc: String = selected_data.get("description", "")
	if _family_label:
		_family_label.text = "当前：%s" % fam_name
	if _family_desc_label:
		_family_desc_label.text = desc
	if _family_traits_label:
		var traits: Array = selected_data.get("traits", [])
		var trait_texts: Array[String] = []
		for trait_entry: Dictionary in traits:
			trait_texts.append(trait_entry.get("text", ""))
		_family_traits_label.text = " | ".join(trait_texts) if not trait_texts.is_empty() else ""
	if _family_towers_label:
		var initial_res: Dictionary = selected_data.get("initial_resources", {})
		var towers_config: Array = initial_res.get("towers", [])
		var tower_names: Array[String] = []
		for tower_entry: Dictionary in towers_config:
			for tid: String in tower_entry:
				var count: int = int(tower_entry[tid])
				var cfg: TowerBean = TowerConfig.get_config(tid)
				var display_name: String = cfg.tower_name if cfg else tid
				var count_text: String = "×∞" if count < 0 else "×%d" % count
				tower_names.append(display_name + count_text)
		_family_towers_label.text = "初始防御塔：%s" % ("、".join(tower_names) if not tower_names.is_empty() else "无")

func _on_start_pressed() -> void:
	var es: Node = _get_era_system()
	if es:
		if es.has_method("load_era"):
			es.load_era(_selected_era)
		if es.has_method("load_family"):
			es.load_family(_selected_family)
		if "current_region" in es:
			es.current_region = _selected_region
		if es.has_method("initialize_session"):
			es.initialize_session()
	start_game_confirmed.emit()
	GameState.change_state(GameState.State.STAGE)

func _on_back_pressed() -> void:
	GameState.change_state(GameState.State.MAIN_MENU)

func select_era(era_id: String) -> void:
	_selected_era = era_id
	era_selected.emit(era_id)

func select_family(family_id: String) -> void:
	_selected_family = family_id
	family_selected.emit(family_id)
	_update_selection_display()

func select_region(region_id: String) -> void:
	_selected_region = region_id
	region_selected.emit(region_id)
