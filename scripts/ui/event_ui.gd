extends Control

signal option_selected(option_index: int)
signal event_completed

var _current_event: EventData = null
var _option_buttons: Array[Button] = []
var _title_label: Label
var _desc_label: Label
var _options_container: VBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_load_current_event()

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.1, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_right = 300
	panel.offset_top = -250
	panel.offset_bottom = 250
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.text = "事件标题"
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title_label)

	var separator: HSeparator = HSeparator.new()
	vbox.add_child(separator)

	_desc_label = Label.new()
	_desc_label.text = "事件描述"
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.custom_minimum_size = Vector2(520, 80)
	vbox.add_child(_desc_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	_options_container = VBoxContainer.new()
	_options_container.add_theme_constant_override("separation", 8)
	vbox.add_child(_options_container)

	var spacer2: Control = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer2)

const QUIET_YEAR_TEXTS: Array[String] = [
	"平淡的一年，没有特别的事情发生。",
	"岁月静好，一切如常。",
	"波澜不惊的一年，平平淡淡才是真。",
	"日子就这样一天天过去了。",
	"这一年，你只是安静地生活着。",
	"没有惊喜，也没有意外。"
]

func _load_current_event() -> void:
	var session: GameSessionData = Global.get_game_session()
	if not _roll_event_trigger():
		Global.debug_log("[事件系统] 年龄=%d, 阶段=%s, 事件掷骰未通过（无事发生）" % [session.current_age, session.current_stage])
		_display_quiet_year()
		return
	var es: Node = get_node_or_null("/root/EventSystem")
	var events: Array[EventData] = []
	if es and es.has_method("get_events_for_current_age"):
		events = es.get_events_for_current_age()
	if events.is_empty():
		var all_events: Array[EventData] = _get_events_for_stage()
		if all_events.is_empty():
			_display_quiet_year()
			return
		var random_index: int = randi() % all_events.size()
		display_event(all_events[random_index])
	else:
		var random_index: int = randi() % events.size()
		display_event(events[random_index])

func _get_events_for_stage() -> Array[EventData]:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	var events_data: Dictionary = {}
	if cm and cm.has_method("load_json"):
		events_data = cm.load_json("res://data/events.json")
	if not events_data.has("events"):
		return []
	var session: GameSessionData = Global.get_game_session()
	var stage_id: String = session.current_stage
	var current_age: int = session.current_age
	var age_matched: Array[EventData] = []
	var stage_matched: Array[EventData] = []
	for event_raw: Dictionary in events_data.events:
		var event := EventData.from_dict(event_raw)
		var event_id: String = event.event_id
		if event_id in session.completed_events:
			continue
		var prereq_met: bool = true
		for prereq_id: String in event.chain_prerequisites:
			if not prereq_id in session.completed_events:
				prereq_met = false
				break
		if not prereq_met:
			continue
		var excluded: bool = false
		for exclude_id: String in event.chain_excludes:
			if exclude_id in session.completed_events:
				excluded = true
				break
		if excluded:
			continue
		if event.is_deadly:
			continue
		if event.stage != stage_id:
			continue
		var event_ages: Array = event.ages
		if current_age in event_ages:
			age_matched.append(event)
		else:
			var min_age: int = 999
			var max_age: int = 0
			for a: int in event_ages:
				if a < min_age:
					min_age = a
				if a > max_age:
					max_age = a
			if current_age >= min_age - 3 and current_age <= max_age + 3:
				stage_matched.append(event)
	if not age_matched.is_empty():
		return age_matched
	return stage_matched

func display_event(event: EventData) -> void:
	_current_event = event
	if _title_label:
		_title_label.text = event.event_name
	if _desc_label:
		_desc_label.text = event.description
	_clear_options()
	var options: Array = event.options
	for i: int in range(options.size()):
		var option: OptionData = options[i]
		var btn: Button = Button.new()
		var os: Node = get_node_or_null("/root/OptionSystem")
		var req_text: String = ""
		if os and os.has_method("format_requirements"):
			req_text = os.format_requirements(option.requirements)
		else:
			req_text = _format_requirements(option.requirements)
		var btn_text: String = option.text if option.text != "" else "选项 %d" % (i + 1)
		if req_text != "":
			btn_text += "\n[需要: " + req_text + "]"
		var has_ending: bool = option.triggers_ending
		var has_battle: bool = option.battle_trigger is Dictionary
		if has_ending:
			btn_text += "\n[💀 触发结局]"
		elif has_battle:
			btn_text += "\n[⚔️ 触发战斗]"
		btn.text = btn_text
		btn.custom_minimum_size = Vector2(0, 40)
		var can_select: bool = false
		if os and os.has_method("check_requirements"):
			can_select = os.check_requirements(option)
		else:
			can_select = _check_requirements(option.requirements)
		btn.disabled = not can_select
		if not can_select:
			btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5, 1.0))
		elif has_ending:
			btn.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.4, 1.0))
		btn.pressed.connect(_on_option_pressed.bind(i))
		_options_container.add_child(btn)
		_option_buttons.append(btn)

func _format_requirements(requirements: Dictionary) -> String:
	var parts: Array[String] = []
	var session: GameSessionData = Global.get_game_session()
	var attr_names: Dictionary = {
		"intelligence": "智力",
		"courage": "勇气",
		"health": "健康",
		"charm": "魅力",
		"work_ability": "工作能力",
		"luck": "运气"
	}
	var bg_names: Dictionary = {
		"farmer": "农民",
		"worker": "工人",
		"merchant": "商人",
		"cadre": "干部",
		"farmer_or_worker": "农民或工人"
	}
	for key: String in requirements:
		var val: Variant = requirements[key]
		match key:
			"trait":
				var trait_id: String = str(val)
				if trait_id.begins_with("!"):
					var neg_id: String = trait_id.substr(1)
					var neg_name: String = neg_id
					var ts: Node = get_node_or_null("/root/TraitSystem")
					if ts and ts.has_method("get_trait_config"):
						var tc: Dictionary = ts.get_trait_config(neg_id)
						neg_name = tc.get("name", neg_id)
					parts.append("非「%s」" % neg_name)
				else:
					var ts2: Node = get_node_or_null("/root/TraitSystem")
					var tname: String = trait_id
					if ts2 and ts2.has_method("get_trait_config"):
						var tc2: Dictionary = ts2.get_trait_config(trait_id)
						tname = tc2.get("name", trait_id)
					parts.append("拥有「%s」" % tname)
			"gold":
				parts.append("金币≥%d" % int(val))
			"family_background":
				var bg_val: String = str(val)
				if bg_names.has(bg_val):
					parts.append("家庭背景：%s" % bg_names[bg_val])
				elif bg_val.begins_with("!"):
					var neg_bg: String = bg_val.substr(1)
					var neg_name2: String = bg_names.get(neg_bg, neg_bg)
					parts.append("非%s家庭" % neg_name2)
				else:
					parts.append("家庭背景：%s" % bg_val)
			"education":
				parts.append("学历：%s" % str(val))
			"work_ability":
				parts.append("工作能力≥%d" % int(val))
			_:
				var display_name: String = attr_names.get(key, key)
				parts.append("%s≥%d" % [display_name, int(val)])
	return "、".join(parts)

func _clear_options() -> void:
	for btn: Button in _option_buttons:
		btn.queue_free()
	_option_buttons.clear()

func _check_requirements(requirements: Dictionary) -> bool:
	var session: GameSessionData = Global.get_game_session()
	for attr_name: String in requirements:
		var required_value: Variant = requirements[attr_name]
		if attr_name == "trait":
			if str(required_value).begins_with("!"):
				var trait_id: String = str(required_value).substr(1)
				if trait_id in session.traits:
					return false
			else:
				if not str(required_value) in session.traits:
					return false
		elif attr_name == "gold":
			if session.gold < int(required_value):
				return false
		elif attr_name == "family_background":
			var required_bg: String = str(required_value)
			var session_bg_short: String = session.family_background.replace("family_", "")
			if required_bg.begins_with("!"):
				var excluded: String = required_bg.substr(1)
				if session_bg_short == excluded or session.family_background == excluded:
					return false
			elif required_bg == "farmer_or_worker":
				if session_bg_short != "farmer" and session_bg_short != "worker":
					return false
			else:
				if session_bg_short != required_bg and session.family_background != required_bg:
					return false
		elif attr_name == "education":
			var edu_trait: String = str(required_value)
			if not edu_trait in session.traits:
				return false
		elif attr_name == "work_ability":
			var threshold: int = int(required_value)
			var ability: int = session.attributes.get("intelligence", 0) + session.attributes.get("courage", 0)
			if ability < threshold:
				return false
		else:
			var current_value: int = session.attributes.get(attr_name, 0)
			if current_value < int(required_value):
				return false
	return true

func _on_option_pressed(index: int) -> void:
	if not is_inside_tree():
		return
	var options: Array = _current_event.options
	if index < 0 or index >= options.size():
		return
	var selected_option: OptionData = options[index]
	var es: Node = get_node_or_null("/root/EventSystem")
	if es and es.has_method("select_option"):
		es.select_option(_current_event.to_dict(), selected_option.to_dict())
	if not is_inside_tree():
		return
	var rewards: Array = selected_option.rewards
	for reward: Dictionary in rewards:
		if reward.get("type", "") == "trait":
			var ach_sys: Node = get_node_or_null("/root/AchievementSystem")
			if ach_sys and ach_sys.has_method("on_trait_acquired"):
				ach_sys.on_trait_acquired(reward.get("id", ""))
	option_selected.emit(index)
	_show_consequence_popup(selected_option)

func _show_consequence_popup(selected_option: OptionData) -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var popup: PanelContainer = PanelContainer.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	popup.offset_left = -280
	popup.offset_right = 280
	popup.offset_top = -280
	popup.offset_bottom = 280
	add_child(popup)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 15
	scroll.offset_right = -15
	scroll.offset_top = 15
	scroll.offset_bottom = -15
	popup.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.custom_minimum_size = Vector2(520, 0)
	scroll.add_child(vbox)

	var title: Label = Label.new()
	title.text = "你获得"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep0: HSeparator = HSeparator.new()
	vbox.add_child(sep0)

	var rewards: Array = selected_option.rewards
	var costs: Dictionary = selected_option.cost
	var has_gold_section: bool = false
	var has_trait_section: bool = false
	var has_tower_section: bool = false

	for reward: Dictionary in rewards:
		var reward_type: String = reward.get("type", "")
		match reward_type:
			"gold":
				if not has_gold_section:
					has_gold_section = true
				var gold_val: int = reward.get("value", reward.get("count", 0))
				if gold_val >= 0:
					_add_popup_row(vbox, "💰", "金币 +%d" % gold_val, Color(1.0, 0.85, 0.0, 1.0))
				else:
					_add_popup_row(vbox, "💰", "金币 %d" % gold_val, Color(1.0, 0.4, 0.4, 1.0))
			"attribute":
				var ac: Node = get_node_or_null("/root/AttributeConfig")
				var attr_id: String = reward.get("attribute", reward.get("id", ""))
				var attr_display: String = attr_id
				if ac and ac.has_method("get_display_with_icon"):
					attr_display = ac.get_display_with_icon(attr_id)
				var count_val: int = reward.get("value", reward.get("count", 0))
				if count_val >= 0:
					_add_popup_row(vbox, "", "%s +%d" % [attr_display, count_val], Color(0.4, 1.0, 0.4, 1.0))
				else:
					_add_popup_row(vbox, "", "%s %d" % [attr_display, count_val], Color(1.0, 0.4, 0.4, 1.0))

	if costs.has("gold"):
		var cost_val: int = costs.gold
		if cost_val < 0:
			has_gold_section = true
			_add_popup_row(vbox, "💰", "金币 %d" % cost_val, Color(1.0, 0.4, 0.4, 1.0))
	if costs.has("health"):
		var health_cost: int = costs.health
		if health_cost < 0:
			var ac2: Node = get_node_or_null("/root/AttributeConfig")
			var health_display: String = "health"
			if ac2 and ac2.has_method("get_display_with_icon"):
				health_display = ac2.get_display_with_icon("health")
			_add_popup_row(vbox, "", "%s %d" % [health_display, health_cost], Color(1.0, 0.4, 0.4, 1.0))

	var trait_rewards: Array[String] = []
	for reward: Dictionary in rewards:
		if reward.get("type", "") == "trait":
			trait_rewards.append(reward.get("id", ""))

	if not trait_rewards.is_empty():
		has_trait_section = true
		var sep_traits: HSeparator = HSeparator.new()
		vbox.add_child(sep_traits)
		var traits_title: Label = Label.new()
		traits_title.text = "——新获得词条——"
		traits_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		traits_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(traits_title)
		var ts: Node = get_node_or_null("/root/TraitSystem")
		for trait_id: String in trait_rewards:
			var config: Dictionary = ts.get_trait_config(trait_id) if ts and ts.has_method("get_trait_config") else {}
			var trait_name: String = config.get("name", trait_id)
			var effects = config.get("effects", config.get("effect", []))
			var effect_text: String = ""
			if effects is Array and not effects.is_empty():
				var parts: Array = []
				for eff in effects:
					if eff is Dictionary:
						parts.append(_format_trait_effect(eff))
				effect_text = "；".join(parts)
			elif effects is Dictionary:
				effect_text = _format_trait_effect(effects)
			var trait_row: HBoxContainer = HBoxContainer.new()
			trait_row.add_theme_constant_override("separation", 6)
			var trait_icon: Label = Label.new()
			trait_icon.text = "✦"
			trait_icon.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0, 1.0))
			trait_row.add_child(trait_icon)
			var lbl: Label = Label.new()
			lbl.text = "%s：%s" % [trait_name, effect_text] if effect_text != "" else trait_name
			lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0, 1.0))
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.custom_minimum_size = Vector2(480, 0)
			trait_row.add_child(lbl)
			vbox.add_child(trait_row)

	var tower_rewards: Array[Dictionary] = []
	for reward: Dictionary in rewards:
		if reward.get("type", "") == "tower":
			tower_rewards.append({"tower_id": reward.get("id", ""), "count": reward.get("count", 1)})

	if not tower_rewards.is_empty():
		has_tower_section = true
		var sep_towers: HSeparator = HSeparator.new()
		vbox.add_child(sep_towers)
		var towers_title: Label = Label.new()
		towers_title.text = "——新获得防御塔——"
		towers_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		towers_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(towers_title)
		for tower_info: Dictionary in tower_rewards:
			var tid: String = tower_info.get("tower_id", "")
			var tcount: int = tower_info.get("count", 1)
			var tower_display: String = _get_tower_display_name(tid)
			var tower_stats: String = _get_tower_stats_display(tid)
			var count_text: String = " ×%d" % tcount if tcount > 1 else ""
			_add_popup_row(vbox, "🏰", tower_display + count_text, Color(0.6, 0.8, 1.0, 1.0))
			if tower_stats != "":
				var stats_label: Label = Label.new()
				stats_label.text = "  " + tower_stats
				stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
				stats_label.add_theme_font_size_override("font_size", 14)
				vbox.add_child(stats_label)

	var stage_growth: Dictionary = _get_stage_attribute_growth()
	if not stage_growth.is_empty():
		var sep_growth: HSeparator = HSeparator.new()
		vbox.add_child(sep_growth)
		var growth_title: Label = Label.new()
		growth_title.text = "—— 阶段属性增长 ——"
		growth_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		growth_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(growth_title)
		var ac3: Node = get_node_or_null("/root/AttributeConfig")
		for attr_name: String in stage_growth:
			var growth_val: int = stage_growth[attr_name]
			var attr_disp: String = attr_name
			if ac3 and ac3.has_method("get_display_with_icon"):
				attr_disp = ac3.get_display_with_icon(attr_name)
			var growth_color: Color = Color(0.4, 1.0, 0.4, 1.0) if growth_val >= 0 else Color(1.0, 0.4, 0.4, 1.0)
			_add_popup_row(vbox, "", "%s %+d" % [attr_disp, growth_val], growth_color)

	var age_row: HBoxContainer = HBoxContainer.new()
	age_row.add_theme_constant_override("separation", 6)
	var age_icon: Label = Label.new()
	age_icon.text = "🎂"
	age_icon.add_theme_font_size_override("font_size", 18)
	age_row.add_child(age_icon)
	var lbl_age: Label = Label.new()
	lbl_age.text = "年龄 +1"
	lbl_age.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))
	age_row.add_child(lbl_age)
	vbox.add_child(age_row)

	var has_ending_popup: bool = selected_option.triggers_ending
	var has_battle_popup: bool = selected_option.battle_trigger is Dictionary
	if has_ending_popup:
		var sep_ending: HSeparator = HSeparator.new()
		vbox.add_child(sep_ending)
		var ending_label: Label = Label.new()
		ending_label.text = "💀 触发结局"
		ending_label.add_theme_font_size_override("font_size", 24)
		ending_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1, 1.0))
		ending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(ending_label)
	elif has_battle_popup:
		var sep_battle: HSeparator = HSeparator.new()
		vbox.add_child(sep_battle)
		var battle_label: Label = Label.new()
		battle_label.text = "⚔️ 触发战斗！"
		battle_label.add_theme_font_size_override("font_size", 22)
		battle_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
		battle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(battle_label)

	var hint: Label = Label.new()
	hint.text = "点击任意地方关闭"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	var callback: Callable = func() -> void:
		overlay.queue_free()
		popup.queue_free()
		event_completed.emit()
		if selected_option.triggers_ending:
			var es: Node = get_node_or_null("/root/EventSystem")
			if es and es.has_method("_trigger_life_ending"):
				es._trigger_life_ending(selected_option.ending_reason if selected_option.ending_reason != "" else "player_choice")
			else:
				GameState.change_state(GameState.State.ENDING)
		elif selected_option.battle_trigger is Dictionary:
			GameState.change_state(GameState.State.BATTLE)
		else:
			GameState.change_state(GameState.State.STAGE)
	overlay.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			callback.call()
	)
	popup.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			callback.call()
	)

func _add_popup_row(container: VBoxContainer, icon: String, text: String, color: Color) -> void:
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
	container.add_child(row)

func _format_trait_effect(effect: Dictionary) -> String:
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
			var ac2: Node = get_node_or_null("/root/AttributeConfig")
			var hdisplay: String = "健康"
			if ac2 and ac2.has_method("get_display_name"):
				hdisplay = ac2.get_display_name("health")
			var hval: int = int(effect.get("value", 0))
			return "%s%+d" % [hdisplay, hval]
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

func _get_trait_display_name(trait_id: String) -> String:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if ts and ts.has_method("get_trait_config"):
		var config: Dictionary = ts.get_trait_config(trait_id)
		return config.get("name", trait_id)
	return trait_id

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
	var attack_range: float = stats.get("range", tower_config.get("range", 100.0))
	return "伤害：%d  攻速：%.1f  射程：%.0f" % [damage, attack_speed, attack_range]

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

func _setup_tower_hover(control: Control, tower_id: String) -> void:
	control.mouse_entered.connect(func() -> void:
		var tm: Node = get_node_or_null("/root/TooltipManager")
		if not tm or not tm.has_method("show_static_tooltip"):
			return
		var cm: Node = get_node_or_null("/root/ConfigManager")
		if not cm or not cm.has_method("load_json"):
			return
		var towers_data = cm.load_json("res://data/towers.json")
		if not towers_data.has("towers"):
			return
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
			return
		var stats: Dictionary = tower_config.get("stats", tower_config)
		var tower_name: String = tower_config.get("tower_name", tower_config.get("name", tower_id))
		var desc: String = "伤害：%d  攻速：%.1f  射程：%.0f" % [
			stats.get("damage", tower_config.get("damage", 0)),
			stats.get("attack_speed", tower_config.get("attack_speed", 1.0)),
			stats.get("range", tower_config.get("range", 100.0))
		]
		tm.show_static_tooltip(tower_name, desc, control.global_position + Vector2(0.0, -60.0))
	)
	control.mouse_exited.connect(func() -> void:
		var tm: Node = get_node_or_null("/root/TooltipManager")
		if tm and tm.has_method("hide_tooltip"):
			tm.hide_tooltip()
	)

func _setup_trait_hover(control: Control, trait_id: String) -> void:
	control.mouse_entered.connect(func() -> void:
		var tm: Node = get_node_or_null("/root/TooltipManager")
		if not tm or not tm.has_method("show_trait_tooltip"):
			return
		tm.show_trait_tooltip(trait_id, control.global_position + Vector2(0.0, -60.0))
	)
	control.mouse_exited.connect(func() -> void:
		var tm: Node = get_node_or_null("/root/TooltipManager")
		if tm and tm.has_method("hide_tooltip"):
			tm.hide_tooltip()
	)

func _on_badge_hovered(badge: Control, trait_id: String) -> void:
	var tm: Node = get_node_or_null("/root/TooltipManager")
	if tm and tm.has_method("show_trait_tooltip"):
		tm.show_trait_tooltip(trait_id, badge.global_position + Vector2(0.0, -60.0))

func _on_badge_unhovered() -> void:
	var tm: Node = get_node_or_null("/root/TooltipManager")
	if tm and tm.has_method("hide_tooltip"):
		tm.hide_tooltip()

func _roll_event_trigger() -> bool:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return true
	var stages_data: Dictionary = cm.load_json("res://data/stages.json")
	if not stages_data.has("stages"):
		return true
	var session: GameSessionData = Global.get_game_session()
	var stage_id: String = session.current_stage
	var stages: Dictionary = stages_data.stages
	if not stages.has(stage_id):
		return true
	var base_rate: float = stages[stage_id].get("event_trigger_rate", 0.7)
	var bonus: float = 0.0
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if ts and ts.has_method("get_event_trigger_bonus"):
		bonus = ts.get_event_trigger_bonus()
	var final_rate: float = clampf(base_rate + bonus, 0.0, 1.0)
	return randf() < final_rate

func _display_quiet_year() -> void:
	if _title_label:
		_title_label.text = "今年无事发生"
	if _desc_label:
		_desc_label.text = QUIET_YEAR_TEXTS[randi() % QUIET_YEAR_TEXTS.size()]
	_clear_options()
	var growth: Dictionary = _get_stage_attribute_growth()
	if not growth.is_empty():
		var ac: Node = get_node_or_null("/root/AttributeConfig")
		var growth_parts: Array[String] = []
		for attr_name: String in growth:
			var growth_val: int = growth[attr_name]
			var attr_disp: String = attr_name
			if ac and ac.has_method("get_display_with_icon"):
				attr_disp = ac.get_display_with_icon(attr_name)
			growth_parts.append("%s%+d" % [attr_disp, growth_val])
		if not growth_parts.is_empty():
			var growth_label: Label = Label.new()
			growth_label.text = "年龄 +1 | " + "  ".join(growth_parts)
			growth_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4, 1.0))
			growth_label.add_theme_font_size_override("font_size", 16)
			_options_container.add_child(growth_label)
	var btn: Button = Button.new()
	btn.text = "继续"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(_on_quiet_year_continue)
	_options_container.add_child(btn)
	_option_buttons.append(btn)

func _on_quiet_year_continue() -> void:
	var es: Node = get_node_or_null("/root/EventSystem")
	if es and es.has_method("select_option"):
		es.select_option({"event_id": "quiet_year"}, {"option_id": "continue", "rewards": []})
	else:
		var session: GameSessionData = Global.get_game_session()
		session.current_age += 1
	GameState.change_state(GameState.State.STAGE)
