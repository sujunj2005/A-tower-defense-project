extends CanvasLayer
class_name GameHUD

signal gold_changed(new_gold: int)
signal hp_changed(new_hp: int, max_hp: int)
signal tower_experience_changed(tower: Tower, new_exp: int)

@export_group("Game State")
@export var base_hp: int = 20
@export var max_base_hp: int = 20
@export var gold: int = 500

var panel: PanelContainer
var hp_bar: ProgressBar
var hp_label: Label
var gold_label: Label
var wave_label: Label

func _ready():
	setup_ui()
	add_to_group("game_hud")

func setup_ui():
	var margin = MarginContainer.new()
	margin.anchor_left = 0.0
	margin.anchor_top = 0.0
	margin.anchor_right = 0.0
	margin.anchor_bottom = 0.0
	margin.offset_left = 20.0
	margin.offset_top = 20.0
	margin.offset_right = 320.0
	margin.offset_bottom = 120.0
	add_child(margin)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 100)
	margin.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var hp_container = HBoxContainer.new()
	hp_container.add_theme_constant_override("separation", 10)
	vbox.add_child(hp_container)

	var hp_icon = Label.new()
	hp_icon.text = "❤ 基地血量:"
	hp_icon.add_theme_font_size_override("font_size", 16)
	hp_container.add_child(hp_icon)

	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(150, 20)
	hp_bar.max_value = max_base_hp
	hp_bar.value = base_hp
	hp_bar.show_percentage = false
	hp_bar.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	var fill_style = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		fill_style.bg_color = Color(0.2, 0.8, 0.2)
	hp_container.add_child(hp_bar)

	hp_label = Label.new()
	hp_label.text = "%d/%d" % [base_hp, max_base_hp]
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_label.custom_minimum_size.x = 60
	hp_container.add_child(hp_label)

	var gold_container = HBoxContainer.new()
	gold_container.add_theme_constant_override("separation", 10)
	vbox.add_child(gold_container)

	var gold_icon = Label.new()
	gold_icon.text = "💰 金币:"
	gold_icon.add_theme_font_size_override("font_size", 16)
	gold_container.add_child(gold_icon)

	gold_label = Label.new()
	gold_label.text = str(gold)
	gold_label.add_theme_font_size_override("font_size", 18)
	gold_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	gold_container.add_child(gold_label)

	var wave_container: HBoxContainer = HBoxContainer.new()
	wave_container.add_theme_constant_override("separation", 10)
	vbox.add_child(wave_container)
	var wave_icon: Label = Label.new()
	wave_icon.text = "⚔ 波次:"
	wave_icon.add_theme_font_size_override("font_size", 16)
	wave_container.add_child(wave_icon)
	wave_label = Label.new()
	wave_label.text = "准备中"
	wave_label.add_theme_font_size_override("font_size", 18)
	wave_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	wave_container.add_child(wave_label)

	var attr_button: Button = Button.new()
	attr_button.text = "📋 属性"
	attr_button.add_theme_font_size_override("font_size", 14)
	attr_button.custom_minimum_size = Vector2(80, 30)
	attr_button.pressed.connect(_show_attributes_popup)
	vbox.add_child(attr_button)

func _show_attributes_popup() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var popup: PanelContainer = PanelContainer.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	popup.offset_left = -300
	popup.offset_right = 300
	popup.offset_top = -280
	popup.offset_bottom = 280
	add_child(popup)

	var outer_vbox: VBoxContainer = VBoxContainer.new()
	outer_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_vbox.offset_left = 15
	outer_vbox.offset_right = -15
	outer_vbox.offset_top = 10
	outer_vbox.offset_bottom = -10
	outer_vbox.add_theme_constant_override("separation", 6)
	popup.add_child(outer_vbox)

	var title: Label = Label.new()
	title.text = "角色属性"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(title)

	var session: GameSessionData = Global.get_game_session()
	var stage_display: String = session.current_stage
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if cm and cm.has_method("load_json"):
		var stages_data: Dictionary = cm.load_json("res://data/stages.json")
		if stages_data.has("stages") and stages_data.stages.has(session.current_stage):
			stage_display = stages_data.stages[session.current_stage].get("stage_name", session.current_stage)
	var age_info: String = "🎂 年龄：%d  |  📌 阶段：%s" % [session.current_age, stage_display]
	var age_label: Label = Label.new()
	age_label.text = age_info
	age_label.add_theme_font_size_override("font_size", 16)
	age_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6, 1.0))
	outer_vbox.add_child(age_label)

	var sep_age: HSeparator = HSeparator.new()
	outer_vbox.add_child(sep_age)

	var attrs: Dictionary = session.attributes
	var ac: Node = get_node_or_null("/root/AttributeConfig")
	var attr_text: String = ""
	for attr_name: String in attrs:
		var display: String = attr_name
		if ac and ac.has_method("get_display_with_icon"):
			display = ac.get_display_with_icon(attr_name)
		if attr_text != "":
			attr_text += "  "
		attr_text += "%s：%d" % [display, attrs[attr_name]]
	var attr_label: Label = Label.new()
	attr_label.text = attr_text
	attr_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outer_vbox.add_child(attr_label)

	var sep0: HSeparator = HSeparator.new()
	outer_vbox.add_child(sep0)

	var traits_title: Label = Label.new()
	traits_title.text = "词条"
	traits_title.add_theme_font_size_override("font_size", 16)
	traits_title.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0, 1.0))
	outer_vbox.add_child(traits_title)

	var traits_flow: HFlowContainer = HFlowContainer.new()
	traits_flow.add_theme_constant_override("h_separation", 4)
	traits_flow.add_theme_constant_override("v_separation", 4)
	outer_vbox.add_child(traits_flow)

	var badge_script: GDScript = load("res://scripts/ui/components/trait_badge.gd")
	for trait_id: String in session.traits:
		var badge: HBoxContainer = badge_script.new()
		badge.setup(trait_id)
		badge.hovered.connect(_on_trait_hovered)
		badge.unhovered.connect(_on_trait_unhovered)
		traits_flow.add_child(badge)

	if session.traits.is_empty():
		var no_trait: Label = Label.new()
		no_trait.text = "无"
		no_trait.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
		traits_flow.add_child(no_trait)

	var sep1: HSeparator = HSeparator.new()
	outer_vbox.add_child(sep1)

	var effects_title: Label = Label.new()
	effects_title.text = "生效效果总和"
	effects_title.add_theme_font_size_override("font_size", 16)
	effects_title.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0, 1.0))
	outer_vbox.add_child(effects_title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll)

	var effects_columns: HBoxContainer = HBoxContainer.new()
	effects_columns.add_theme_constant_override("separation", 12)
	effects_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(effects_columns)

	var left_col: VBoxContainer = VBoxContainer.new()
	left_col.add_theme_constant_override("separation", 4)
	left_col.custom_minimum_size = Vector2(270, 0)
	effects_columns.add_child(left_col)

	var right_col: VBoxContainer = VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 4)
	right_col.custom_minimum_size = Vector2(270, 0)
	effects_columns.add_child(right_col)

	var ts: Node = get_node_or_null("/root/TraitSystem")
	var effect_items: Array[Dictionary] = []
	if ts and ts.has_method("get_all_damage_bonus_details"):
		var dmg_details: Dictionary = ts.get_all_damage_bonus_details()
		var universal_dmg: float = dmg_details.get("universal", 0.0)
		var specific_dmg: Dictionary = dmg_details.get("specific", {})
		if universal_dmg > 0.0:
			effect_items.append({"text": "伤害加成（通用）：+%.0f%%" % (universal_dmg * 100.0), "color": Color(0.4, 1.0, 0.4, 1.0)})
		for tower_id: String in specific_dmg:
			var bonus: float = specific_dmg[tower_id]
			if bonus > 0.0:
				var tower_name: String = _get_tower_display_name(tower_id)
				effect_items.append({"text": "伤害加成（%s）：+%.0f%%" % [tower_name, bonus * 100.0], "color": Color(0.3, 0.9, 0.3, 1.0)})
	if ts and ts.has_method("get_all_attack_speed_bonus_details"):
		var as_details: Dictionary = ts.get_all_attack_speed_bonus_details()
		var universal_as: float = as_details.get("universal", 0.0)
		var specific_as: Dictionary = as_details.get("specific", {})
		if universal_as > 0.0:
			effect_items.append({"text": "攻速加成（通用）：+%.0f%%" % (universal_as * 100.0), "color": Color(0.4, 1.0, 0.4, 1.0)})
		for tower_id: String in specific_as:
			var bonus: float = specific_as[tower_id]
			if bonus > 0.0:
				var tower_name: String = _get_tower_display_name(tower_id)
				effect_items.append({"text": "攻速加成（%s）：+%.0f%%" % [tower_name, bonus * 100.0], "color": Color(0.3, 0.9, 0.3, 1.0)})
	if ts and ts.has_method("get_damage_reduction"):
		var dr: float = ts.get_damage_reduction()
		if dr > 0.0:
			effect_items.append({"text": "伤害减免：%.0f%%" % (dr * 100.0), "color": Color(0.4, 1.0, 0.4, 1.0)})
	if ts and ts.has_method("get_gold_per_wave"):
		var gpw: float = ts.get_gold_per_wave()
		if gpw > 0.0:
			effect_items.append({"text": "每波额外金币：+%.0f" % gpw, "color": Color(0.4, 1.0, 0.4, 1.0)})

	var half: int = ceili(float(effect_items.size()) / 2.0)
	for i: int in range(effect_items.size()):
		var item: Dictionary = effect_items[i]
		var lbl: Label = Label.new()
		lbl.text = item.text
		lbl.add_theme_color_override("font_color", item.color)
		if i < half:
			left_col.add_child(lbl)
		else:
			right_col.add_child(lbl)

	var hint: Label = Label.new()
	hint.text = "点击任意地方关闭"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(hint)

	var callback: Callable = func() -> void:
		overlay.queue_free()
		popup.queue_free()
	overlay.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			callback.call()
	)
	popup.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			callback.call()
	)

func _on_trait_hovered(badge: Control, trait_id: String) -> void:
	var tm: Node = get_node_or_null("/root/TooltipManager")
	if tm and tm.has_method("show_trait_tooltip"):
		tm.show_trait_tooltip(trait_id, badge.global_position + Vector2(0.0, -60.0))

func _on_trait_unhovered() -> void:
	var tm: Node = get_node_or_null("/root/TooltipManager")
	if tm and tm.has_method("hide_tooltip"):
		tm.hide_tooltip()

func _get_tower_display_name(tower_id: String) -> String:
	var cfg: TowerBean = TowerConfig.get_config(tower_id)
	if cfg and cfg.tower_name != "":
		return cfg.tower_name
	return tower_id

func update_hp(value: int):
	base_hp = clampi(value, 0, max_base_hp)
	hp_bar.value = base_hp
	hp_label.text = "%d/%d" % [base_hp, max_base_hp]
	if base_hp <= max_base_hp * 0.3:
		var fill_style = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
		if fill_style:
			fill_style.bg_color = Color(0.9, 0.2, 0.2)
	elif base_hp <= max_base_hp * 0.6:
		var fill_style = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
		if fill_style:
			fill_style.bg_color = Color(0.9, 0.7, 0.1)
	hp_changed.emit(base_hp, max_base_hp)

func update_gold(value: int):
	gold = value
	gold_label.text = str(gold)
	gold_changed.emit(gold)

func can_afford(cost: int) -> bool:
	return gold >= cost

func spend_gold(cost: int) -> bool:
	if can_afford(cost):
		gold -= cost
		gold_label.text = str(gold)
		gold_changed.emit(gold)
		return true
	return false

func add_gold(amount: int) -> void:
	gold += amount
	gold_label.text = str(gold)
	gold_changed.emit(gold)

func update_wave(wave_number: int, total_waves: int = 0) -> void:
	if wave_label:
		if total_waves > 0:
			wave_label.text = "%d/%d" % [wave_number, total_waves]
		else:
			wave_label.text = str(wave_number)

func add_tower_experience(tower: Tower, amount: int) -> void:
	if tower and is_instance_valid(tower):
		tower.add_experience(amount)
		tower_experience_changed.emit(tower, tower.current_experience)
