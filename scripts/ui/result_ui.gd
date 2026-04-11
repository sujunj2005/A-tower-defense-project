extends Control

signal continue_pressed
signal ending_requested

var _rating: String = ""
var _rewards: Dictionary = {}

var _rating_label: Label
var _rewards_container: VBoxContainer
var _continue_button: Button
var _ending_button: Button
var _bg: ColorRect

func _ready() -> void:
	_setup_ui()
	_load_battle_result()

func _setup_ui() -> void:
	_bg = ColorRect.new()
	_bg.color = Color(0.05, 0.05, 0.1, 0.95)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_bg.gui_input.connect(_on_bg_input)
	add_child(_bg)

	var outer: VBoxContainer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	outer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	outer.offset_left = -280
	outer.offset_top = -300
	outer.offset_right = 280
	outer.offset_bottom = 300
	add_child(outer)

	_rating_label = Label.new()
	_rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rating_label.add_theme_font_size_override("font_size", 32)
	outer.add_child(_rating_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(540, 380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)

	_rewards_container = VBoxContainer.new()
	_rewards_container.add_theme_constant_override("separation", 6)
	_rewards_container.custom_minimum_size = Vector2(520, 0)
	scroll.add_child(_rewards_container)

	var hint: Label = Label.new()
	hint.text = "点击任意地方关闭"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(hint)

	_continue_button = Button.new()
	_continue_button.text = "继续人生"
	_continue_button.custom_minimum_size = Vector2(200, 50)
	_continue_button.add_theme_font_size_override("font_size", 20)
	_continue_button.pressed.connect(_on_continue)
	outer.add_child(_continue_button)

	_ending_button = Button.new()
	_ending_button.text = "查看结局"
	_ending_button.custom_minimum_size = Vector2(200, 50)
	_ending_button.add_theme_font_size_override("font_size", 20)
	_ending_button.pressed.connect(_on_ending)
	outer.add_child(_ending_button)

func _on_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close_result()

func _load_battle_result() -> void:
	var session: GameSessionData = Global.get_game_session()
	var rating: String = session.battle_rating
	var rewards: Dictionary = session.last_battle_rewards

	if rewards.is_empty():
		rewards = {"gold": 0, "tower_id": "", "rating": rating}

	var br: Node = get_node_or_null("/root/BattleRating")
	if br and br.has_method("is_deadly_battle_survived"):
		if br.is_deadly_battle_survived(session.home_health, session.current_battle_deadly):
			var ach_sys: Node = get_node_or_null("/root/AchievementSystem")
			if ach_sys and ach_sys.has_method("on_deadly_event_survived"):
				ach_sys.on_deadly_event_survived()

	var ach_sys2: Node = get_node_or_null("/root/AchievementSystem")
	if ach_sys2 and ach_sys2.has_method("on_battle_won"):
		ach_sys2.on_battle_won()

	display_result(rating, rewards)

func display_result(rating: String, rewards: Dictionary) -> void:
	_rating = rating
	_rewards = rewards

	var br: Node = get_node_or_null("/root/BattleRating")
	var rating_desc: String = "未知评价"
	if br and br.has_method("get_rating_description"):
		rating_desc = br.get_rating_description(rating)

	if _rating_label:
		var rating_colors: Dictionary = {
			"S": Color(1.0, 0.84, 0.0),
			"A": Color(0.4, 0.8, 1.0),
			"B": Color(0.4, 1.0, 0.4),
			"C": Color(1.0, 1.0, 0.4),
			"D": Color(0.8, 0.4, 0.4)
		}
		_rating_label.text = "战斗评价：%s" % rating
		_rating_label.add_theme_color_override("font_color", rating_colors.get(rating, Color.WHITE))

	if _rewards_container:
		for child: Node in _rewards_container.get_children():
			child.queue_free()

		var desc_label: Label = Label.new()
		desc_label.text = rating_desc
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
		_rewards_container.add_child(desc_label)

		var sep1: HSeparator = HSeparator.new()
		_rewards_container.add_child(sep1)

		if rewards.has("gold") and rewards.gold > 0:
			_add_reward_row("💰", "金币 +%d" % rewards.gold, Color(1.0, 0.85, 0.0, 1.0))

		var es: Node = get_node_or_null("/root/EconomySystem")
		if es and es.has_method("calculate_interest"):
			var interest: int = es.calculate_interest()
			if interest > 0:
				_add_reward_row("🏦", "利息收入：%d" % interest, Color(0.4, 1.0, 0.4, 1.0))

		var session: GameSessionData = Global.get_game_session()
		var battle_tower_id: String = rewards.get("tower_id", "")

		if battle_tower_id != "":
			var sep_traits: HSeparator = HSeparator.new()
			_rewards_container.add_child(sep_traits)
			var towers_title: Label = Label.new()
			towers_title.text = "——新获得防御塔——"
			towers_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			towers_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
			_rewards_container.add_child(towers_title)
			var tower_display: String = _get_tower_display_name(battle_tower_id)
			var tower_stats: String = _get_tower_stats_display(battle_tower_id)
			_add_reward_row("🏰", tower_display, Color(0.6, 0.8, 1.0, 1.0))
			if tower_stats != "":
				var stats_row: HBoxContainer = HBoxContainer.new()
				stats_row.add_theme_constant_override("separation", 6)
				var stats_label: Label = Label.new()
				stats_label.text = "  " + tower_stats
				stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
				stats_label.add_theme_font_size_override("font_size", 14)
				stats_row.add_child(stats_label)
				_rewards_container.add_child(stats_row)

		var stage_growth: Dictionary = _get_stage_attribute_growth()
		if not stage_growth.is_empty():
			var sep3: HSeparator = HSeparator.new()
			_rewards_container.add_child(sep3)
			var growth_title: Label = Label.new()
			growth_title.text = "—— 阶段属性增长 ——"
			growth_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			growth_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
			_rewards_container.add_child(growth_title)
			var ac: Node = get_node_or_null("/root/AttributeConfig")
			for attr_name: String in stage_growth:
				var growth_val: int = stage_growth[attr_name]
				var attr_disp: String = attr_name
				if ac and ac.has_method("get_display_with_icon"):
					attr_disp = ac.get_display_with_icon(attr_name)
				var growth_color: Color = Color(0.4, 1.0, 0.4, 1.0) if growth_val >= 0 else Color(1.0, 0.4, 0.4, 1.0)
				var attr_text: String = "%s %+d" % [attr_disp, growth_val]
				_add_reward_row("", attr_text, growth_color)

		var age_row: HBoxContainer = HBoxContainer.new()
		age_row.add_theme_constant_override("separation", 6)
		var age_icon: Label = Label.new()
		age_icon.text = "🎂"
		age_row.add_child(age_icon)
		var lbl_age: Label = Label.new()
		lbl_age.text = "年龄 +1"
		lbl_age.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))
		age_row.add_child(lbl_age)
		_rewards_container.add_child(age_row)

		if session.current_stage == "old_age":
			var old_age_decline: Dictionary = _get_old_age_decline()
			if not old_age_decline.is_empty():
				var sep4: HSeparator = HSeparator.new()
				_rewards_container.add_child(sep4)
				var decline_title: Label = Label.new()
				decline_title.text = "—— 老年衰退 ——"
				decline_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				decline_title.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3, 1.0))
				_rewards_container.add_child(decline_title)
				var ac2: Node = get_node_or_null("/root/AttributeConfig")
				for attr_name: String in old_age_decline:
					var decline_val: int = old_age_decline[attr_name]
					var attr_disp: String = attr_name
					if ac2 and ac2.has_method("get_display_with_icon"):
						attr_disp = ac2.get_display_with_icon(attr_name)
					_add_reward_row("", "%s %d" % [attr_disp, decline_val], Color(1.0, 0.4, 0.4, 1.0))

	var session2: GameSessionData = Global.get_game_session()
	var is_final_battle: bool = session2.current_stage == "old_age"
	if _ending_button:
		_ending_button.visible = is_final_battle
	if _continue_button:
		_continue_button.visible = not is_final_battle

func _add_reward_row(icon: String, text: String, color: Color) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	if icon != "":
		var icon_lbl: Label = Label.new()
		icon_lbl.text = icon
		icon_lbl.add_theme_font_size_override("font_size", 18)
		row.add_child(icon_lbl)
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(480, 0)
	row.add_child(lbl)
	_rewards_container.add_child(row)
	return row

func _get_tower_display_name(tower_id: String) -> String:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return tower_id
	var towers_data = cm.load_json("res://data/towers.json")
	if not towers_data.has("towers"):
		return tower_id
	var towers = towers_data.towers
	if towers is Array:
		for tower in towers:
			if tower.get("tower_id", "") == tower_id:
				return tower.get("tower_name", tower.get("name", tower_id))
		return tower_id
	if towers is Dictionary and towers.has(tower_id):
		return towers[tower_id].get("name", towers[tower_id].get("tower_name", tower_id))
	return tower_id

func _get_tower_stats_display(tower_id: String) -> String:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return ""
	var towers_data = cm.load_json("res://data/towers.json")
	if not towers_data.has("towers"):
		return ""
	var towers = towers_data.towers
	var tower_config: Dictionary = {}
	if towers is Array:
		for t in towers:
			if t.get("tower_id", "") == tower_id:
				tower_config = t
				break
	elif towers is Dictionary and towers.has(tower_id):
		tower_config = towers[tower_id]
	if tower_config.is_empty():
		return ""
	var stats: Dictionary = tower_config.get("stats", tower_config)
	var damage: int = stats.get("damage", tower_config.get("damage", 0))
	var attack_speed: float = stats.get("attack_speed", tower_config.get("attack_speed", 1.0))
	var range_val: float = stats.get("range", tower_config.get("range", 100.0))
	return "伤害：%d  攻速：%.1f  射程：%.0f" % [damage, attack_speed, range_val]

func _get_stage_attribute_growth() -> Dictionary:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return {}
	var stages_data = cm.load_json("res://data/stages.json")
	if not stages_data is Dictionary or not stages_data.has("stages"):
		return {}
	var session: GameSessionData = Global.get_game_session()
	var stage_id: String = session.current_stage
	var stages = stages_data.stages
	if not stages is Dictionary or not stages.has(stage_id):
		return {}
	return stages[stage_id].get("attribute_growth", {})

func _get_old_age_decline() -> Dictionary:
	var session: GameSessionData = Global.get_game_session()
	if session.current_stage != "old_age":
		return {}
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return {}
	var stages_data = cm.load_json("res://data/stages.json")
	if not stages_data is Dictionary or not stages_data.has("stages"):
		return {}
	var stages = stages_data.stages
	if not stages is Dictionary:
		return {}
	if not stages.has("old_age"):
		return {}
	var growth: Dictionary = stages.old_age.get("attribute_growth", {})
	var result: Dictionary = {}
	for attr_name: String in growth:
		if growth[attr_name] < 0:
			result[attr_name] = growth[attr_name]
	return result

func _format_effect(effect: Dictionary) -> String:
	var effect_type: String = effect.get("type", "")
	match effect_type:
		"tower_damage_bonus":
			var val: float = float(effect.get("tower_damage_bonus", effect.get("value", 0)))
			return "塔伤害+%.0f%%" % (val * 100.0)
		"tower_attack_speed_bonus":
			var val: float = float(effect.get("value", 0))
			return "塔攻速+%.0f%%" % (val * 100.0)
		"attribute_bonus":
			var ac: Node = get_node_or_null("/root/AttributeConfig")
			var attr_name: String = effect.get("attribute", "")
			var display: String = attr_name
			if ac and ac.has_method("get_display_name"):
				display = ac.get_display_name(attr_name)
			var val: int = int(effect.get("value", 0))
			return "%s%+d" % [display, val]
		"gold_bonus":
			var val: int = int(effect.get("value", 0))
			return "金币%+d" % val
		"health_bonus":
			var val: int = int(effect.get("value", 0))
			return "生命%+d" % val
		"gold_per_wave":
			var val: int = int(effect.get("value", 0))
			return "每波金币+%d" % val
		"damage_reduction":
			var val: float = float(effect.get("value", 0))
			return "伤害减免%.0f%%" % (val * 100.0)
		"event_trigger_bonus":
			var val: float = float(effect.get("value", 0))
			return "事件触发率%+.0f%%" % (val * 100.0)
		_:
			var val = effect.get("value", effect.get("tower_damage_bonus", ""))
			return "%s: %s" % [effect_type, str(val)]

func _close_result() -> void:
	var session: GameSessionData = Global.get_game_session()
	if session.current_stage == "old_age":
		GameState.change_state(GameState.State.ENDING)
	else:
		GameState.change_state(GameState.State.STAGE)

func _on_continue() -> void:
	continue_pressed.emit()
	GameState.change_state(GameState.State.STAGE)

func _on_ending() -> void:
	ending_requested.emit()
	GameState.change_state(GameState.State.ENDING)
