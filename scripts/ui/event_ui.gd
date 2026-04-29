## 事件 UI 面板。显示事件标题、描述和选项按钮，处理选项选择和后果弹窗。
## 生命周期：每回合由场景管理器创建 → _ready 加载事件 → 玩家选择 → 显示后果 → 点击关闭 → 切换状态
extends Control

## 选项被选中时发射，携带选项索引
signal option_selected(option_index: int)
## 事件流程完成时发射（后果弹窗关闭后）
signal event_completed

var _current_event: EventData = null
var _option_buttons: Array[Button] = []
var _title_label: Label
var _desc_label: Label
var _options_container: VBoxContainer
var _debug_weight_container: VBoxContainer

func _get_quiet_year_texts() -> Array[String]:
	return [
		tr("QUIET_YEAR_1"),
		tr("QUIET_YEAR_2"),
		tr("QUIET_YEAR_3"),
		tr("QUIET_YEAR_4"),
		tr("QUIET_YEAR_5"),
		tr("QUIET_YEAR_6")
	]

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
	_title_label.text = tr("EVENT_TITLE")
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title_label)

	var separator: HSeparator = HSeparator.new()
	vbox.add_child(separator)

	_desc_label = Label.new()
	_desc_label.text = tr("EVENT_DESC")
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

	if OS.is_debug_build():
		var wsep: Control = Control.new()
		wsep.custom_minimum_size = Vector2(0, 6)
		vbox.add_child(wsep)

		var wtitle: Label = Label.new()
		wtitle.text = "⚖ 权重分解"
		wtitle.add_theme_font_size_override("font_size", 12)
		wtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 1.0, 1.0))
		vbox.add_child(wtitle)

		_debug_weight_container = VBoxContainer.new()
		_debug_weight_container.add_theme_constant_override("separation", 1)
		vbox.add_child(_debug_weight_container)

	var spacer2: Control = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer2)


## 加载当前事件：掷骰判断是否触发 → 从 EventSystem 获取 → 显示或显示"平静的一年"
func _load_current_event() -> void:
	var session: GameSessionData = Global.get_game_session()
	if not _roll_event_trigger():
		Global.debug_log("[事件系统] 年龄=%d, 阶段=%s, 事件掷骰未通过（无事发生）" % [session.current_age, session.current_stage])
		_display_quiet_year()
		return
	var es: Node = get_node_or_null("/root/EventSystem")
	var event: EventData = null
	if es and es.has_method("get_events_for_current_age"):
		event = es.get_events_for_current_age()
	if event == null:
		var all_events: Array[EventData] = _get_events_for_stage()
		if all_events.is_empty():
			_display_quiet_year()
			return
		var pick_count: int = mini(3, all_events.size())
		display_event(all_events[randi() % pick_count])
	else:
		display_event(event)

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
			if prereq_id.begins_with("flag:"):
				var flag_id: String = prereq_id.substr(5)
				if not flag_id in session.chain_flags:
					prereq_met = false
					break
			elif not prereq_id in session.completed_events:
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
			if current_age >= min_age - 1 and current_age <= max_age + 1:
				stage_matched.append(event)
	age_matched.sort_custom(func(a: EventData, b: EventData) -> bool:
		return _age_distance(a, current_age) < _age_distance(b, current_age)
	)
	stage_matched.sort_custom(func(a: EventData, b: EventData) -> bool:
		return _age_distance(a, current_age) < _age_distance(b, current_age)
	)
	if not age_matched.is_empty():
		return age_matched
	return stage_matched

func _age_distance(event: EventData, current_age: int) -> int:
	var min_dist: int = 999
	for a: int in event.ages:
		var dist: int = absi(a - current_age)
		if dist < min_dist:
			min_dist = dist
	return min_dist

## 显示事件：更新标题/描述、创建选项按钮（含需求文本和可用性检查）
func display_event(event: EventData) -> void:
	_current_event = event
	if _title_label:
		_title_label.text = event.get_display_name()
	if _desc_label:
		_desc_label.text = event.get_display_desc()
	_clear_options()
	var options: Array = event.options
	for i: int in range(options.size()):
		var option: OptionData = options[i]
		var btn: Button = Button.new()
		var os: Node = get_node_or_null("/root/OptionSystem")
		var req_text: String = ""
		if os and os.has_method("format_requirements"):
			req_text = os.format_requirements(option.requirements)
		if not event.conditions.is_empty():
			var event_cond_text: String = _format_event_conditions(event.conditions, os)
			if event_cond_text != "":
				if req_text != "":
					req_text += tr("SEPARATOR_DUN")
				req_text += event_cond_text
		if not event.chain_prerequisites.is_empty():
			var prereq_text: String = _format_chain_prerequisites(event.chain_prerequisites)
			if prereq_text != "":
				if req_text != "":
					req_text += tr("SEPARATOR_DUN")
				req_text += prereq_text
		var btn_text: String = option.get_display_text() if option.text != "" else tr("OPTION_LABEL") % (i + 1)
		if req_text != "":
			btn_text += "\n" + tr("REQUIREMENT_NEED") % req_text
		var has_ending: bool = option.triggers_ending
		var has_battle: bool = option.battle_trigger is Dictionary
		if has_ending:
			btn_text += "\n" + tr("TRIGGER_ENDING")
		elif has_battle:
			btn_text += "\n" + tr("TRIGGER_BATTLE")
		btn.text = btn_text
		btn.custom_minimum_size = Vector2(0, 40)
		var can_select: bool = false
		if os and os.has_method("check_requirements"):
			can_select = os.check_requirements(option)
		else:
			can_select = _check_requirements(option.requirements)
		btn.disabled = not can_select
		if not can_select:
			btn.add_theme_color_override("font_disabled_color", Color(0.6, 0.3, 0.3, 1.0))
		elif has_ending:
			btn.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.4, 1.0))
		btn.pressed.connect(_on_option_pressed.bind(i))
		_options_container.add_child(btn)
		_option_buttons.append(btn)

	_update_weight_debug()

func _update_weight_debug() -> void:
	if not _debug_weight_container:
		return
	for child: Node in _debug_weight_container.get_children():
		child.queue_free()
	if not _current_event:
		return
	var es: Node = get_node_or_null("/root/EventSystem")
	if not es or not es.has_method("get_weight_debug_info"):
		return
	var info: Dictionary = es.get_weight_debug_info(_current_event)
	var ordered_keys: Array[String] = [
		"基础权重", "职业加成",
		"① Karma修正", "  (karma=", "② 人格修正", "  (checks=",
		"③ NPC修正", "  (npcs=", "④ 张力修正", "  (category=",
		"⑤ 特质加成", "  (boosts=", "⑥ 新鲜度", "  (近期事件)",
		"⑦ 稀有度", "  (rarity=", "最终权重"
	]
	for prefix: String in ordered_keys:
		for k: String in info:
			if k.begins_with(prefix):
				var val = info[k]
				if val is float:
					if k == "最终权重":
						var line: Label = Label.new()
						line.text = "  → 最终: %.3f" % val
						line.add_theme_font_size_override("font_size", 12)
						var c: Color
						if val >= 2.0:
							c = Color(0.4, 1.0, 0.4, 1.0)
						elif val >= 0.5:
							c = Color(1.0, 1.0, 1.0, 1.0)
						elif val >= 0.1:
							c = Color(1.0, 0.7, 0.3, 1.0)
						else:
							c = Color(1.0, 0.3, 0.3, 1.0)
						line.add_theme_color_override("font_color", c)
						_debug_weight_container.add_child(line)
					elif not k.begins_with("  "):
						var line: Label = Label.new()
						line.text = "  %s: ×%.2f" % [k.replace("① ","").replace("② ","").replace("③ ","").replace("④ ","").replace("⑤ ","").replace("⑥ ","").replace("⑦ ",""), val]
						line.add_theme_font_size_override("font_size", 10)
						var lc: Color = Color.RED if val < 0.3 else (Color.YELLOW if val < 0.7 else (Color.GREEN if val > 1.0 else Color.WHITE))
						line.add_theme_color_override("font_color", lc)
						_debug_weight_container.add_child(line)
				break

func _format_event_conditions(conditions: Array[Dictionary], os: Node) -> String:
	var parts: Array[String] = []
	for cond: Dictionary in conditions:
		var cond_type: String = cond.get("type", "")
		match cond_type:
			"npc_relation":
				var npc_id: String = str(cond.get("npc_id", ""))
				var op: String = str(cond.get("op", ">="))
				var value: int = int(cond.get("value", 0))
				var npc_name: String = _get_npc_display_name(npc_id)
				if op == "<":
					parts.append(tr("REQ_NPC_RELATION_LT") % [npc_name, value])
				else:
					parts.append(tr("REQ_NPC_RELATION_GTE") % [npc_name, value])
			"profession":
				var prof_key: String = str(cond.get("key", ""))
				var prof_display: String = _get_profession_display_name(prof_key)
				parts.append(tr("REQ_PROFESSION") % prof_display)
			"profession_absent":
				parts.append(tr("REQ_PROFESSION_ABSENT"))
	return tr("SEPARATOR_DUN").join(parts)

func _format_chain_prerequisites(prerequisites: Array) -> String:
	var parts: Array[String] = []
	for prereq: String in prerequisites:
		if prereq.begins_with("flag:"):
			continue
		var ev_name: String = _get_event_display_name(prereq)
		parts.append(tr("REQ_COMPLETED_EVENT") % ev_name)
	return tr("SEPARATOR_DUN").join(parts)

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
		elif attr_name == "chain_flag":
			if not str(required_value) in session.chain_flags:
				return false
		elif attr_name == "family_member_alive":
			var mid: String = str(required_value)
			if not session.family_members.has(mid) or not session.family_members[mid].get("alive", false):
				return false
		elif attr_name == "family_member_met":
			var mid2: String = str(required_value)
			if not session.family_members.has(mid2) or not session.family_members[mid2].get("met", false):
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

## 选项按下：通知 EventSystem 执行后果 → 检查成就 → 显示后果弹窗
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

## 显示后果弹窗：汇总金币/属性/词条/塔/职业/NPC/家庭/阶段增长等变化，点击关闭后切换游戏状态
func _show_consequence_popup(selected_option: OptionData) -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var popup: PanelContainer = PanelContainer.new()
	var popup_style := StyleBoxFlat.new()
	popup_style.bg_color = Color(0.12, 0.10, 0.18, 1.0)
	popup_style.corner_radius_top_left = 8
	popup_style.corner_radius_top_right = 8
	popup_style.corner_radius_bottom_left = 8
	popup_style.corner_radius_bottom_right = 8
	popup_style.set_border_width_all(2)
	popup_style.border_color = Color(0.4, 0.35, 0.55, 1.0)
	popup.add_theme_stylebox_override("panel", popup_style)
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
	title.text = tr("YOU_RECEIVED")
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var rewards: Array = selected_option.rewards
	var costs: Dictionary = selected_option.cost

	var gold_from_rewards: int = 0
	var attrs_from_rewards: Dictionary = {}
	var trait_ids_from_rewards: Array[String] = []
	var tower_from_rewards: Array[Dictionary] = []
	for reward: Dictionary in rewards:
		var reward_type: String = reward.get("type", "")
		match reward_type:
			"gold":
				gold_from_rewards += reward.get("value", reward.get("count", 0))
			"attribute":
				var attr_id: String = reward.get("attribute", reward.get("id", ""))
				var attr_val: int = reward.get("value", reward.get("count", 0))
				attrs_from_rewards[attr_id] = attrs_from_rewards.get(attr_id, 0) + attr_val
			"trait":
				trait_ids_from_rewards.append(reward.get("id", ""))
			"tower":
				tower_from_rewards.append({"tower_id": reward.get("id", ""), "count": reward.get("count", 1)})

	var era_sys: Node = get_node_or_null("/root/EraSystem")
	var actual_gold_from_rewards: int = gold_from_rewards
	if gold_from_rewards > 0 and era_sys and era_sys.has_method("apply_gold_bonus"):
		actual_gold_from_rewards = era_sys.apply_gold_bonus(gold_from_rewards)
	var cost_gold: int = costs.get("gold", 0)
	var total_gold: int = actual_gold_from_rewards + selected_option.gold_change + cost_gold
	if total_gold != 0:
		if total_gold >= 0:
			_add_popup_row(vbox, "💰", tr("GOLD_PLUS") % total_gold, Color(1.0, 0.85, 0.0, 1.0))
		else:
			_add_popup_row(vbox, "💰", tr("GOLD_MINUS") % absi(total_gold), Color(1.0, 0.4, 0.4, 1.0))

	var merged_attrs: Dictionary = {}
	for attr_id: String in attrs_from_rewards:
		if attr_id != "health":
			merged_attrs[attr_id] = attrs_from_rewards[attr_id]
	for attr_id: String in selected_option.attribute_changes:
		if attr_id != "health":
			merged_attrs[attr_id] = merged_attrs.get(attr_id, 0) + selected_option.attribute_changes[attr_id]

	var total_health: int = attrs_from_rewards.get("health", 0) + selected_option.attribute_changes.get("health", 0) + costs.get("health", 0)
	if total_health != 0:
		merged_attrs["health"] = total_health

	var ac: Node = get_node_or_null("/root/AttributeConfig")
	for attr_id: String in merged_attrs:
		var val: int = merged_attrs[attr_id]
		if val == 0:
			continue
		var attr_display: String = attr_id
		if ac and ac.has_method("get_display_with_icon"):
			attr_display = ac.get_display_with_icon(attr_id)
		if val >= 0:
			_add_popup_row(vbox, "", tr("ATTR_FORMAT") % [attr_display, val], Color(0.4, 1.0, 0.4, 1.0))
		else:
			_add_popup_row(vbox, "", tr("ATTR_FORMAT") % [attr_display, val], Color(1.0, 0.4, 0.4, 1.0))

	var all_trait_gains: Array[String] = []
	for tid: String in trait_ids_from_rewards:
		if not tid in all_trait_gains:
			all_trait_gains.append(tid)
	for tid: String in selected_option.trait_gains:
		if not tid in all_trait_gains:
			all_trait_gains.append(tid)

	if not all_trait_gains.is_empty():
		var sep_traits: HSeparator = HSeparator.new()
		vbox.add_child(sep_traits)
		var traits_title: Label = Label.new()
		traits_title.text = tr("NEW_TRAITS")
		traits_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		traits_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(traits_title)
		var ts: Node = get_node_or_null("/root/TraitSystem")
		for trait_id: String in all_trait_gains:
			var config: Dictionary = ts.get_trait_config(trait_id) if ts and ts.has_method("get_trait_config") else {}
			var trait_name: String = tr(str(config.get("name", trait_id)))
			var effects = config.get("effects", config.get("effect", []))
			var effect_text: String = ""
			if effects is Array and not effects.is_empty():
				var parts: Array = []
				for eff in effects:
					if eff is Dictionary:
						parts.append(_format_trait_effect(eff))
				effect_text = tr("SEPARATOR_SEMICOLON").join(parts)
			elif effects is Dictionary:
				effect_text = _format_trait_effect(effects)
			var trait_row: HBoxContainer = HBoxContainer.new()
			trait_row.add_theme_constant_override("separation", 6)
			var trait_icon: Label = Label.new()
			trait_icon.text = "✦"
			trait_icon.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0, 1.0))
			trait_row.add_child(trait_icon)
			var lbl: Label = Label.new()
			lbl.text = tr("TRAIT_EFFECT_FORMAT") % [trait_name, effect_text] if effect_text != "" else trait_name
			lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0, 1.0))
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.custom_minimum_size = Vector2(480, 0)
			trait_row.add_child(lbl)
			vbox.add_child(trait_row)

	if not selected_option.trait_losses.is_empty():
		var sep_loss: HSeparator = HSeparator.new()
		vbox.add_child(sep_loss)
		var loss_title: Label = Label.new()
		loss_title.text = tr("LOST_TRAITS")
		loss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loss_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(loss_title)
		var ts2: Node = get_node_or_null("/root/TraitSystem")
		for trait_id: String in selected_option.trait_losses:
			var config2: Dictionary = ts2.get_trait_config(trait_id) if ts2 and ts2.has_method("get_trait_config") else {}
			var loss_name: String = tr(str(config2.get("name", trait_id)))
			_add_popup_row(vbox, "✦", tr("TRAIT_LOST_FORMAT") % loss_name, Color(1.0, 0.4, 0.4, 1.0))

	var all_tower_gains: Array[Dictionary] = []
	var gained_tower_ids: Dictionary = {}
	for ti: Dictionary in tower_from_rewards:
		var tid: String = ti.get("tower_id", "")
		var tc: int = ti.get("count", 1)
		if not gained_tower_ids.has(tid):
			gained_tower_ids[tid] = tc
			all_tower_gains.append(ti)
		else:
			gained_tower_ids[tid] += tc
	for tid: String in selected_option.tower_gains:
		if not gained_tower_ids.has(tid):
			gained_tower_ids[tid] = 1
			all_tower_gains.append({"tower_id": tid, "count": 1})
		else:
			gained_tower_ids[tid] += 1
	for i: int in range(all_tower_gains.size()):
		var tid: String = all_tower_gains[i].get("tower_id", "")
		if gained_tower_ids.has(tid):
			all_tower_gains[i] = {"tower_id": tid, "count": gained_tower_ids[tid]}

	if not all_tower_gains.is_empty():
		var sep_towers: HSeparator = HSeparator.new()
		vbox.add_child(sep_towers)
		var towers_title: Label = Label.new()
		towers_title.text = tr("NEW_TOWERS")
		towers_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		towers_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(towers_title)
		for tower_info: Dictionary in all_tower_gains:
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

	if not selected_option.tower_losses.is_empty():
		var sep_tloss: HSeparator = HSeparator.new()
		vbox.add_child(sep_tloss)
		var tloss_title: Label = Label.new()
		tloss_title.text = tr("LOST_TOWERS")
		tloss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tloss_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(tloss_title)
		for tid: String in selected_option.tower_losses:
			var tower_display: String = _get_tower_display_name(tid)
			_add_popup_row(vbox, "🏰", tr("TOWER_LOST_FORMAT") % tower_display, Color(1.0, 0.4, 0.4, 1.0))

	if selected_option.profession_change != "" or selected_option.profession_lost:
		var sep_prof: HSeparator = HSeparator.new()
		vbox.add_child(sep_prof)
		var prof_title: Label = Label.new()
		prof_title.text = tr("PROFESSION_CHANGE_TITLE")
		prof_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prof_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(prof_title)
		if selected_option.profession_change != "":
			var prof_display: String = _get_profession_display_name(selected_option.profession_change)
			_add_popup_row(vbox, "💼", tr("PROFESSION_GAIN") % prof_display, Color(0.4, 1.0, 0.6, 1.0))
		if selected_option.profession_lost:
			_add_popup_row(vbox, "💼", tr("PROFESSION_LOST"), Color(1.0, 0.4, 0.4, 1.0))

	if not selected_option.npc_relation_changes.is_empty():
		var sep_npc: HSeparator = HSeparator.new()
		vbox.add_child(sep_npc)
		var npc_title: Label = Label.new()
		npc_title.text = tr("NPC_RELATION_TITLE")
		npc_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		npc_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(npc_title)
		for npc_change: Dictionary in selected_option.npc_relation_changes:
			var npc_id: String = str(npc_change.get("npc_id", ""))
			var npc_val: int = int(npc_change.get("value", 0))
			var npc_name: String = _get_npc_display_name(npc_id)
			if npc_val >= 0:
				_add_popup_row(vbox, "👤", tr("NPC_RELATION_UP") % [npc_name, npc_val], Color(0.4, 1.0, 0.6, 1.0))
			else:
				_add_popup_row(vbox, "👤", tr("NPC_RELATION_DOWN") % [npc_name, absi(npc_val)], Color(1.0, 0.4, 0.4, 1.0))

	var has_unlock: bool = not selected_option.unlock_events.is_empty()
	var has_lock: bool = not selected_option.lock_events.is_empty()
	if has_unlock or has_lock:
		var sep_ev: HSeparator = HSeparator.new()
		vbox.add_child(sep_ev)
		var ev_title: Label = Label.new()
		ev_title.text = tr("EVENT_CHANGE_TITLE")
		ev_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ev_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(ev_title)
		for ev_id: String in selected_option.unlock_events:
			var ev_name: String = _get_event_display_name(ev_id)
			_add_popup_row(vbox, "🔓", tr("EVENT_UNLOCKED") % ev_name, Color(0.4, 1.0, 0.6, 1.0))
		for ev_id: String in selected_option.lock_events:
			var ev_name: String = _get_event_display_name(ev_id)
			_add_popup_row(vbox, "🔒", tr("EVENT_LOCKED") % ev_name, Color(1.0, 0.4, 0.4, 1.0))

	var family_fx: Variant = selected_option.family_effect
	if family_fx is Dictionary and not family_fx.is_empty():
		_show_family_effect_section(vbox, [family_fx])
	elif family_fx is Array and not family_fx.is_empty():
		_show_family_effect_section(vbox, family_fx)

	var stage_growth: Dictionary = _get_stage_attribute_growth()
	if not stage_growth.is_empty():
		var sep_growth: HSeparator = HSeparator.new()
		vbox.add_child(sep_growth)
		var growth_title: Label = Label.new()
		growth_title.text = tr("STAGE_GROWTH")
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
	lbl_age.text = tr("AGE_PLUS_ONE")
	lbl_age.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))
	age_row.add_child(lbl_age)
	vbox.add_child(age_row)

	var has_ending_popup: bool = selected_option.triggers_ending
	var has_battle_popup: bool = selected_option.battle_trigger is Dictionary
	if has_ending_popup:
		var sep_ending: HSeparator = HSeparator.new()
		vbox.add_child(sep_ending)
		var ending_label: Label = Label.new()
		ending_label.text = tr("TRIGGER_ENDING")
		ending_label.add_theme_font_size_override("font_size", 24)
		ending_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1, 1.0))
		ending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(ending_label)
	elif has_battle_popup:
		var sep_battle: HSeparator = HSeparator.new()
		vbox.add_child(sep_battle)
		var battle_label: Label = Label.new()
		battle_label.text = tr("TRIGGER_BATTLE")
		battle_label.add_theme_font_size_override("font_size", 22)
		battle_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
		battle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(battle_label)

	var hint: Label = Label.new()
	hint.text = tr("HINT_CLICK_CLOSE")
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	var callback: Callable = func() -> void:
		overlay.queue_free()
		popup.queue_free()
		event_completed.emit()
		if GameState.current_state == GameState.State.ENDING:
			return
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

func _show_family_effect_section(vbox: VBoxContainer, effects: Array) -> void:
	var sep_family: HSeparator = HSeparator.new()
	vbox.add_child(sep_family)
	var family_title: Label = Label.new()
	family_title.text = tr("FAMILY_EFFECT_TITLE")
	family_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	family_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	vbox.add_child(family_title)
	for fx: Dictionary in effects:
		var member_id: String = fx.get("member", "")
		var member_name: String = _get_family_member_display_name(member_id)
		var parts: Array[String] = []
		if fx.has("health_change"):
			var hv: int = int(fx.health_change)
			parts.append(tr("FAMILY_HEALTH_CHANGE") % [member_name, hv])
		if fx.has("alive_change"):
			if fx.alive_change:
				parts.append(tr("FAMILY_ALIVE_TRUE") % member_name)
			else:
				parts.append(tr("FAMILY_ALIVE_FALSE") % member_name)
		if fx.has("born_change"):
			if fx.born_change:
				parts.append(tr("FAMILY_BORN") % member_name)
		if fx.has("met_change"):
			if fx.met_change:
				parts.append(tr("FAMILY_MET") % member_name)
		if parts.is_empty():
			parts.append(member_name)
		_add_popup_row(vbox, "🏠", "  ".join(parts), Color(0.9, 0.75, 0.5, 1.0))

func _get_family_member_display_name(member_id: String) -> String:
	var names: Dictionary = {
		"father": tr("FAMILY_FATHER"),
		"mother": tr("FAMILY_MOTHER"),
		"spouse": tr("FAMILY_SPOUSE"),
		"first_child": tr("FAMILY_FIRST_CHILD"),
		"second_child": tr("FAMILY_SECOND_CHILD"),
		"grandchild": tr("FAMILY_GRANDCHILD"),
	}
	return names.get(member_id, member_id)

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
			return tr("EFFECT_TOWER_DAMAGE") % (val * 100.0)
		"tower_attack_speed_bonus":
			var val: float = float(effect.get("value", 0))
			return tr("EFFECT_TOWER_SPEED") % (val * 100.0)
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
			return tr("EFFECT_GOLD_BONUS") % val
		"health_bonus":
			var ac2: Node = get_node_or_null("/root/AttributeConfig")
			var hdisplay: String = tr("ATTR_HEALTH")
			if ac2 and ac2.has_method("get_display_name"):
				hdisplay = ac2.get_display_name("health")
			var hval: int = int(effect.get("value", 0))
			return "%s%+d" % [hdisplay, hval]
		"gold_per_wave":
			var val: int = int(effect.get("value", 0))
			return tr("EFFECT_GOLD_PER_WAVE") % val
		"damage_reduction":
			var val: float = float(effect.get("value", 0))
			return tr("EFFECT_DAMAGE_REDUCTION") % (val * 100.0)
		"event_trigger_bonus":
			var val: float = float(effect.get("value", 0))
			return tr("EFFECT_EVENT_TRIGGER") % (val * 100.0)
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
				return tr(tower.get("tower_name", tower.get("name", tower_id)))
		return tower_id
	if towers is Dictionary and towers.has(tower_id):
		return tr(towers[tower_id].get("name", towers[tower_id].get("tower_name", tower_id)))
	return tower_id

func _get_npc_display_name(npc_id: String) -> String:
	var names: Dictionary = {
		"npc_father": tr("NPC_FATHER"),
		"npc_mother": tr("NPC_MOTHER"),
		"npc_friend": tr("NPC_FRIEND"),
		"npc_mentor": tr("NPC_MENTOR"),
		"npc_colleague": tr("NPC_COLLEAGUE"),
		"npc_spouse": tr("NPC_SPOUSE"),
	}
	return names.get(npc_id, npc_id)

func _get_profession_display_name(profession_id: String) -> String:
	var names: Dictionary = {
		"programmer": tr("PROFESSION_PROGRAMMER"),
		"doctor": tr("PROFESSION_DOCTOR"),
		"teacher": tr("PROFESSION_TEACHER"),
		"civil_servant": tr("PROFESSION_CIVIL_SERVANT"),
		"entrepreneur": tr("PROFESSION_ENTREPRENEUR"),
	}
	return names.get(profession_id, profession_id)

func _get_event_display_name(event_id: String) -> String:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return event_id
	var events_data = cm.load_json("res://data/events.json")
	if not events_data.has("events"):
		return event_id
	for ev: Dictionary in events_data.events:
		if ev.get("event_id", "") == event_id:
			return tr(str(ev.get("event_name", event_id)))
	return event_id

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
	return tr("TOWER_STATS_FORMAT") % [damage, attack_speed, attack_range]

func _get_stage_attribute_growth() -> Dictionary:
	if not is_inside_tree():
		return {}
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
		var tower_name: String = tr(tower_config.get("tower_name", tower_config.get("name", tower_id)))
		var desc: String = tr("TOWER_STATS_FORMAT") % [
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
		_title_label.text = tr("QUIET_YEAR_TITLE")
	if _desc_label:
		var texts: Array[String] = _get_quiet_year_texts()
		_desc_label.text = texts[randi() % texts.size()]
	_clear_options()
	var btn: Button = Button.new()
	btn.text = tr("BTN_CONTINUE")
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(_on_quiet_year_continue)
	_options_container.add_child(btn)
	_option_buttons.append(btn)

func _on_quiet_year_continue() -> void:
	var es: Node = get_node_or_null("/root/EventSystem")
	if es and es.has_method("select_option"):
		es.select_option({"event_id": "quiet_year"}, {"option_id": "continue", "rewards": []})
	_show_quiet_year_popup()

func _show_quiet_year_popup() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var popup: PanelContainer = PanelContainer.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	popup.offset_left = -280
	popup.offset_right = 280
	popup.offset_top = -200
	popup.offset_bottom = 200
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
	title.text = tr("QUIET_YEAR_TITLE")
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	if is_inside_tree():
		var es: Node = get_node_or_null("/root/EconomySystem")
		if es and es.has_method("calculate_salary"):
			var salary: int = es.calculate_salary()
			if salary > 0:
				_add_popup_row(vbox, "💼", tr("SALARY_INCOME") % salary, Color(0.4, 1.0, 0.4, 1.0))

	var growth: Dictionary = _get_stage_attribute_growth()
	if not growth.is_empty():
		var sep_growth: HSeparator = HSeparator.new()
		vbox.add_child(sep_growth)
		var growth_title: Label = Label.new()
		growth_title.text = tr("STAGE_GROWTH")
		growth_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		growth_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		vbox.add_child(growth_title)
		if is_inside_tree():
			var ac: Node = get_node_or_null("/root/AttributeConfig")
			for attr_name: String in growth:
				var growth_val: int = growth[attr_name]
				var attr_disp: String = attr_name
				if ac and ac.has_method("get_display_with_icon"):
					attr_disp = ac.get_display_with_icon(attr_name)
				var growth_color: Color = Color(0.4, 1.0, 0.4, 1.0) if growth_val >= 0 else Color(1.0, 0.4, 0.4, 1.0)
				_add_popup_row(vbox, "", "%s %+d" % [attr_disp, growth_val], growth_color)

	var age_row: HBoxContainer = HBoxContainer.new()
	age_row.add_theme_constant_override("separation", 6)
	var age_icon: Label = Label.new()
	age_icon.text = "🎂"
	age_icon.add_theme_font_size_override("font_size", 18)
	age_row.add_child(age_icon)
	var lbl_age: Label = Label.new()
	lbl_age.text = tr("AGE_PLUS_ONE")
	lbl_age.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))
	age_row.add_child(lbl_age)
	vbox.add_child(age_row)

	var hint: Label = Label.new()
	hint.text = tr("HINT_CLICK_CLOSE")
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	var callback: Callable = func() -> void:
		overlay.queue_free()
		popup.queue_free()
		event_completed.emit()
		if GameState.current_state == GameState.State.ENDING:
			return
		GameState.change_state(GameState.State.STAGE)
	overlay.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			callback.call()
	)
	popup.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			callback.call()
	)
