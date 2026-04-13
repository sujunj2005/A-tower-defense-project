extends Node

signal event_triggered(event_data: Dictionary)
signal event_completed(event_id: String, selected_option: String)
signal battle_triggered(battle_trigger: Dictionary)

var session: GameSessionData

func _ready() -> void:
	session = Global.get_game_session()
	Global.session_reset.connect(_on_session_reset)

func _on_session_reset() -> void:
	session = Global.get_game_session()

func _get_config_manager() -> Node:
	return get_node_or_null("/root/ConfigManager")

func _get_age_system() -> Node:
	return get_node_or_null("/root/AgeSystem")

func get_events_for_current_age() -> Array[Dictionary]:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return []
	var events_data = cm.load_json("res://data/events.json")
	if not events_data is Dictionary or not events_data.has("events"):
		return []
	var age_sys: Node = _get_age_system()
	if not age_sys:
		return []
	var available_events: Array[Dictionary] = []
	for event: Dictionary in events_data.events:
		if _can_trigger(event, age_sys):
			available_events.append(event)
	return available_events

func _can_trigger(event: Dictionary, age_sys: Node) -> bool:
	var event_ages: Array = event.get("ages", [])
	if not age_sys.current_age in event_ages:
		return false
	var event_stage: String = event.get("stage", "")
	if event_stage != session.current_stage:
		return false
	var event_id: String = event.get("event_id", "")
	if event_id in session.completed_events:
		return false
	var chain_prerequisites: Array = event.get("chain_prerequisites", [])
	for prereq_id: String in chain_prerequisites:
		if not prereq_id in session.completed_events:
			return false
	var chain_excludes: Array = event.get("chain_excludes", [])
	for exclude_id: String in chain_excludes:
		if exclude_id in session.completed_events:
			return false
	return true

func trigger_event(event: Dictionary) -> void:
	Global.debug_log("触发事件：%s" % event.get("event_name", ""))
	event_triggered.emit(event)

func select_option(event: Dictionary, option: Dictionary) -> void:
	Global.debug_log("选择选项：%s" % option.get("option_id", ""))
	session.last_event_traits.clear()
	session.last_event_towers.clear()
	_apply_rewards(option.get("rewards", []))
	_apply_costs(option.get("cost", {}))
	if GameState.current_state == GameState.State.ENDING:
		return
	var event_id: String = event.get("event_id", "")
	session.completed_events.append(event_id)
	var old_age: int = session.current_age
	session.current_age += 1
	Global.debug_log("年龄+1 → %d" % session.current_age)
	if session.current_age != old_age:
		_apply_stage_attribute_growth()
		if GameState.current_state == GameState.State.ENDING:
			return
	_check_stage_transition()
	var age_sys: Node = _get_age_system()
	if age_sys and age_sys.has_method("increment_stage_events"):
		age_sys.increment_stage_events()
	if age_sys and "current_age" in age_sys:
		age_sys.current_age = session.current_age
	if option.get("battle_trigger") is Dictionary:
		_trigger_battle(option.battle_trigger)
	elif option.get("triggers_ending", false) == true:
		_trigger_life_ending(option.get("ending_reason", "player_choice"))
	event_completed.emit(event_id, option.get("option_id", ""))

func _apply_rewards(rewards: Array) -> void:
	var era_sys: Node = get_node_or_null("/root/EraSystem")
	for reward: Dictionary in rewards:
		var reward_type: String = reward.get("type", "")
		match reward_type:
			"tower":
				_grant_tower(reward.get("id", ""), reward.get("count", 1))
			"trait":
				_grant_trait(reward.get("id", ""))
			"gold":
				var base_gold: int = reward.get("value", reward.get("count", 0))
				var actual_gold: int = base_gold
				if base_gold > 0 and era_sys and era_sys.has_method("apply_gold_bonus"):
					actual_gold = era_sys.apply_gold_bonus(base_gold)
				session.gold += actual_gold
				Global.debug_log("金币变化：%d（基础：%d，加成后：%d）" % [actual_gold, base_gold, actual_gold])
			"attribute":
				var attr: String = reward.get("attribute", "intelligence")
				var count: int = reward.get("count", 0)
				if session.attributes.has(attr):
					session.attributes[attr] += count
					var ac: Node = get_node_or_null("/root/AttributeConfig")
					var attr_display: String = attr
					if ac and ac.has_method("get_display_name"):
						attr_display = ac.get_display_name(attr)
					Global.debug_log("属性变化：%s %+d → %d" % [attr_display, count, session.attributes[attr]])

func _grant_tower(tower_id: String, _count: int) -> void:
	session.add_tower(tower_id, _count if _count > 0 else -1)
	session.last_event_towers.append({"tower_id": tower_id, "count": _count})
	var count_text: String = "无限数量" if _count < 0 else "%d次" % _count
	Global.debug_log("获得防御塔：%s（%s）" % [tower_id, count_text])

func _grant_trait(trait_id: String) -> void:
	if not trait_id in session.traits:
		session.traits.append(trait_id)
		session.last_event_traits.append(trait_id)
		Global.debug_log("获得词条：%s" % trait_id)

func _apply_costs(costs: Dictionary) -> void:
	if costs.has("gold"):
		var gold_change: int = costs.gold
		session.gold += gold_change
		if gold_change < 0:
			Global.debug_log("消耗金币：%d" % (-gold_change))
	if costs.has("health"):
		var health_change: int = costs.health
		session.attributes["health"] += health_change
		if health_change < 0:
			Global.debug_log("消耗健康：%d" % (-health_change))
	if session.attributes.get("health", 0) <= 0:
		var age_sys_check: Node = _get_age_system()
		var is_old: bool = session.current_stage == "old_age"
		if age_sys_check and age_sys_check.has_method("get_stage_id"):
			is_old = is_old or age_sys_check.get_stage_id() == "old_age"
		if is_old:
			Global.debug_log("老年健康归零，触发人生结局（当前健康=%d，阶段=%s）" % [session.attributes.get("health", 0), session.current_stage])
			_trigger_life_ending("health_depleted")

func _apply_stage_attribute_growth() -> void:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return
	var stages_data = cm.load_json("res://data/stages.json")
	if not stages_data is Dictionary or not stages_data.has("stages"):
		return
	var age_sys: Node = _get_age_system()
	if not age_sys:
		return
	if not age_sys.has_method("get_stage_id"):
		return
	var stage_id: String = age_sys.get_stage_id()
	var stages: Dictionary = stages_data.stages
	if not stages.has(stage_id):
		return
	var growth: Dictionary = stages[stage_id].get("attribute_growth", {})
	for attr_name: String in growth:
		var growth_val: int = growth[attr_name]
		if session.attributes.has(attr_name):
			session.attributes[attr_name] += growth_val
		else:
			session.attributes[attr_name] = growth_val
		var ac: Node = get_node_or_null("/root/AttributeConfig")
		var attr_display: String = attr_name
		if ac and ac.has_method("get_display_name"):
			attr_display = ac.get_display_name(attr_name)
		Global.debug_log("阶段属性增长：%s %+d → %d" % [attr_display, growth_val, session.attributes[attr_name]])
	if growth.has("health"):
		var health_growth: int = growth["health"]
		session.max_home_health += float(health_growth)
		session.home_health += float(health_growth)
		Global.debug_log("生命值同步：max_home_health=%.0f, home_health=%.0f" % [session.max_home_health, session.home_health])

func _trigger_life_ending(reason: String) -> void:
	session.ending_reason = reason
	GameState.change_state(GameState.State.ENDING)

func _trigger_battle(battle_trigger: Dictionary) -> void:
	var battle_id: String = battle_trigger.get("battle_id", "unknown")
	var is_deadly: bool = battle_trigger.get("is_deadly", false)
	Global.debug_log("触发战斗：%s (致命：%s)" % [battle_id, str(is_deadly)])
	session.current_battle_id = battle_id
	session.current_battle_deadly = is_deadly
	session.current_battle_waves.clear()
	var raw_waves: Array = battle_trigger.get("waves", [])
	for wave_data: Dictionary in raw_waves:
		session.current_battle_waves.append(wave_data)
	Global.debug_log("波次配置已写入session，共%d波" % session.current_battle_waves.size())
	battle_triggered.emit(battle_trigger)

func check_option_requirements(option: Dictionary) -> bool:
	if not option.has("requirements"):
		return true
	for attr_name: String in option.requirements:
		var required_value: Variant = option.requirements[attr_name]
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

func _check_stage_transition() -> void:
	var stage_transitions: Dictionary = {
		"childhood": {"min_age": 15, "next_stage": "youth"},
		"youth": {"min_age": 35, "next_stage": "middle_age"},
		"middle_age": {"min_age": 50, "next_stage": "old_age"}
	}
	var current: String = session.current_stage
	if stage_transitions.has(current):
		var transition: Dictionary = stage_transitions[current]
		var min_age: int = transition.get("min_age", 999)
		var next_stage: String = transition.get("next_stage", "")
		if session.current_age >= min_age and next_stage != "":
			session.current_stage = next_stage
			Global.debug_log("阶段变更：%s → %s，当前年龄%d" % [current, next_stage, session.current_age])
			var age_sys: Node = _get_age_system()
			if age_sys:
				if "current_age" in age_sys:
					age_sys.current_age = session.current_age
				if age_sys.has_method("increase_age"):
					age_sys.increase_age(0)
