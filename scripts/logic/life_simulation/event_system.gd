## 事件系统。管理人生事件的触发、筛选、后果执行和状态推进。
## 核心流程：get_events_for_current_age() → trigger_event() → select_option() → 各 _apply_* 方法
## 作为 Autoload 全局单例运行，生命周期贯穿整个游戏会话。
extends Node

signal event_triggered(event_data: EventData)
signal event_completed(event_id: String, selected_option: String)
signal battle_triggered(battle_trigger: Dictionary)

var session: GameSessionData

func _ready() -> void:
	session = Global.get_game_session()
	Global.session_reset.connect(_on_session_reset)

func _on_session_reset() -> void:
	session = Global.get_game_session()
	if session.npcs.is_empty():
		_initialize_npcs()

func _get_config_manager() -> Node:
	return get_node_or_null("/root/ConfigManager")

func _get_age_system() -> Node:
	return get_node_or_null("/root/AgeSystem")

func _initialize_npcs() -> void:
	session.npcs.clear()
	var player_age: int = session.current_age
	var father := NPCData.new()
	father.npc_id = "npc_father"
	father.name = "NPC_FATHER"
	father.relation_type = "family"
	father.affection = 60
	father.health = 80
	father.age = player_age + 25
	father.life_stage = _get_life_stage_for_age(father.age)
	father.is_active = true
	father.willpower = randi_range(30, 70)
	father.craziness = randi_range(20, 60)
	father.generosity = randi_range(30, 70)
	father.loyalty = randi_range(40, 80)
	father.ambition = randi_range(30, 70)
	father.wealth = randi_range(0, 5000)
	father.trust = randi_range(50, 80)
	session.npcs.append(father)
	var mother := NPCData.new()
	mother.npc_id = "npc_mother"
	mother.name = "NPC_MOTHER"
	mother.relation_type = "family"
	mother.affection = 65
	mother.health = 80
	mother.age = player_age + 23
	mother.life_stage = _get_life_stage_for_age(mother.age)
	mother.is_active = true
	mother.willpower = randi_range(30, 70)
	mother.craziness = randi_range(20, 60)
	mother.generosity = randi_range(40, 80)
	mother.loyalty = randi_range(50, 90)
	mother.ambition = randi_range(20, 60)
	mother.wealth = randi_range(0, 3000)
	mother.trust = randi_range(50, 80)
	session.npcs.append(mother)
	Global.debug_log("[NPC] 初始化完成：父亲(age=%d), 母亲(age=%d)" % [father.age, mother.age])

func _get_life_stage_for_age(age: int) -> String:
	if age < 18:
		return "child"
	elif age <= 35:
		return "youth"
	elif age <= 55:
		return "adult"
	elif age <= 65:
		return "middle_age"
	else:
		return "elderly"

func get_events_for_current_age() -> EventData:
	if session.attributes.get("health", 0) <= 0 or session.home_health <= 0.0:
		_check_health_depleted()
		return null
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return null
	var events_data = cm.load_json("res://data/events.json")
	if not events_data is Dictionary or not events_data.has("events"):
		return null
	var age_sys: Node = _get_age_system()
	if not age_sys:
		return null
	var available_events: Array[EventData] = []
	var skipped_details: Array[String] = []
	for event_raw: Dictionary in events_data.events:
		var event := EventData.from_dict(event_raw)
		if _can_trigger(event, age_sys):
			available_events.append(event)
		else:
			if event.event_id != "event_nothing" and age_sys.current_age in event.ages:
				var reason: String = ""
				if event.stage != session.current_stage:
					reason = "阶段不匹配(event=%s, session=%s)" % [event.stage, session.current_stage]
				elif event.event_id in session.completed_events:
					reason = "已完成"
				elif event.get_trigger_chance() < 1.0:
					reason = "概率未通过(%.0f%%)" % (event.get_trigger_chance() * 100.0)
				else:
					reason = "前置/互斥/条件不满足"
				skipped_details.append("%s(%s): %s" % [event.event_id, event.event_name, reason])
	Global.debug_log("[事件系统] 年龄=%d, 阶段=%s, 可触发事件=%d, 跳过(年龄匹配但不可触发)=%d" % [age_sys.current_age, session.current_stage, available_events.size(), skipped_details.size()])
	for detail: String in skipped_details:
		Global.debug_log("[事件系统]   跳过: %s" % detail)
	if available_events.is_empty():
		return null
	var weights: Array[float] = []
	for ev: EventData in available_events:
		weights.append(_calculate_dynamic_weight(ev))
	return _weighted_random_select(available_events, weights)

func _check_conditions(conditions: Array[Dictionary]) -> bool:
	for cond: Dictionary in conditions:
		var cond_type: String = cond.get("type", "")
		var key: String = str(cond.get("key", ""))
		var op: String = str(cond.get("op", ">="))
		var value: Variant = cond.get("value", 0)
		match cond_type:
			"attribute":
				var current: int = session.attributes.get(key, 0)
				if not _compare_op(current, op, int(value)):
					return false
			"trait":
				if not key in session.traits:
					return false
			"trait_absent":
				if key in session.traits:
					return false
			"npc_relation":
				var npc_id: String = str(cond.get("npc_id", key))
				var found: bool = false
				for npc: NPCData in session.npcs:
					if npc.npc_id == npc_id and npc.is_active:
						found = true
						if not _compare_op(npc.affection, op, int(value)):
							return false
						break
				if found:
					pass
			"profession":
				if session.current_profession != key:
					return false
			"profession_absent":
				if session.current_profession != "":
					return false
			"trigger_chance", "family_member", "required_family":
				pass
	return true

func _compare_op(current: int, op: String, value: int) -> bool:
	match op:
		">=": return current >= value
		">": return current > value
		"<=": return current <= value
		"<": return current < value
		"==": return current == value
		"!=": return current != value
		_: return current >= value

func _calculate_dynamic_weight(event: EventData) -> float:
	var weight: float = event.event_weight
	if session.current_profession != "":
		var cm: Node = _get_config_manager()
		if cm and cm.has_method("load_json"):
			var prof_data = cm.load_json("res://data/professions.json")
			if prof_data is Dictionary and prof_data.has("professions"):
				for prof: Dictionary in prof_data.professions:
					if prof.get("profession_id", "") == session.current_profession:
						var event_pool: Array = prof.get("event_pool", [])
						if event.event_id in event_pool:
							weight *= 1.5
						break
	var family_member: String = event.get_family_member()
	var required_family: Array[String] = event.get_required_family()
	for npc: NPCData in session.npcs:
		if not npc.is_active:
			continue
		if family_member == npc.npc_id or npc.npc_id in required_family:
			if npc.affection > 70:
				weight *= 1.3
			elif npc.affection < 30:
				weight *= 0.5
	if not event.conditions.is_empty():
		for cond: Dictionary in event.conditions:
			if cond.get("type", "") == "trait" and str(cond.get("key", "")) in session.traits:
				weight *= 1.2
	if session.gold > 10000:
		for cond: Dictionary in event.conditions:
			if cond.get("type", "") == "attribute" and str(cond.get("key", "")) == "gold":
				weight *= 1.1
	if session.attributes.get("health", 0) > 200:
		for cond: Dictionary in event.conditions:
			if cond.get("type", "") == "attribute" and str(cond.get("key", "")) == "health":
				weight *= 1.1
	if event.event_id in session.locked_events:
		weight = 0.0
	if event.event_id in session.unlocked_events:
		weight *= 1.5
	weight *= _karma_weight_multiplier(event.karma_type)
	weight *= _personality_weight_modifier(event)
	weight *= _npc_personality_modifier(event)
	weight *= _tension_weight_modifier(event)
	weight *= _trait_boost_modifier(event)
	weight *= _freshness_modifier(event)
	weight *= _rarity_modifier(event.rarity)
	return weight

func _karma_weight_multiplier(karma_type: String) -> float:
	var k: int = session.karma
	match karma_type:
		"positive":
			return 1.0 + (k / 100.0) * 0.3
		"negative":
			return 1.0 - (k / 100.0) * 0.5
		_:
			return 1.0

func _personality_weight_modifier(event: EventData) -> float:
	var modifier: float = 1.0
	var checks: Dictionary = event.personality_checks
	if checks.is_empty():
		return modifier
	for attr_name: String in checks:
		var threshold: String = str(checks[attr_name])
		var current: int = int(session.hidden_attributes.get(attr_name, 50))
		if threshold == "low" and current < 30:
			modifier *= 1.4
		elif threshold == "high" and current > 70:
			modifier *= 1.5
	return modifier

func _npc_personality_modifier(event: EventData) -> float:
	var modifier: float = 1.0
	if event.related_npcs.is_empty():
		return modifier
	for npc: NPCData in session.npcs:
		if not npc.is_active:
			continue
		if npc.npc_id in event.related_npcs:
			if npc.craziness > 80:
				modifier *= 1.4
			if npc.affection > 80:
				modifier *= 1.3
			elif npc.affection < 20:
				modifier *= 0.5
	return modifier

func _tension_weight_modifier(event: EventData) -> float:
	var modifier: float = 1.0
	if event.tension_category == "" or session.tensions.is_empty():
		return modifier
	for tension: TensionData in session.tensions:
		if tension.tension_type == event.tension_category:
			modifier *= (1.0 + tension.pressure)
	return modifier

func _trait_boost_modifier(event: EventData) -> float:
	var modifier: float = 1.0
	if event.trait_boosts.is_empty():
		return modifier
	for trait_id: String in event.trait_boosts:
		if trait_id in session.traits:
			modifier *= float(event.trait_boosts[trait_id])
	return modifier

func _freshness_modifier(event: EventData) -> float:
	if event.event_id in session.recent_events:
		return 0.3
	return 1.0

func _rarity_modifier(rarity: String) -> float:
	match rarity:
		"common":
			return 1.0
		"uncommon":
			return 0.5
		"rare":
			return 0.1
		"legendary":
			return 0.03
		_:
			return 1.0

func _weighted_random_select(events: Array[EventData], weights: Array[float]) -> EventData:
	var total: float = 0.0
	for w: float in weights:
		total += maxf(w, 0.0)
	if total <= 0.0:
		return events[randi() % events.size()]
	var roll: float = randf() * total
	var cumulative: float = 0.0
	for i: int in range(events.size()):
		cumulative += maxf(weights[i], 0.0)
		if roll <= cumulative:
			return events[i]
	return events[-1]

func _can_trigger(event: EventData, age_sys: Node) -> bool:
	if not age_sys.current_age in event.ages:
		return false
	if event.stage != session.current_stage:
		Global.debug_log("[事件系统] %s 阶段不匹配: event.stage=%s, session=%s" % [event.event_id, event.stage, session.current_stage])
		return false
	if event.event_id in session.completed_events:
		return false
	var chain_prerequisites: Array = event.chain_prerequisites
	for prereq_id: String in chain_prerequisites:
		if prereq_id.begins_with("flag:"):
			var flag_id: String = prereq_id.substr(5)
			if not flag_id in session.chain_flags:
				Global.debug_log("[事件系统] %s 前置标记未满足: %s" % [event.event_id, flag_id])
				return false
		elif not prereq_id in session.completed_events:
			Global.debug_log("[事件系统] %s 前置未满足: %s" % [event.event_id, prereq_id])
			return false
	var chain_excludes: Array = event.chain_excludes
	for exclude_id: String in chain_excludes:
		if exclude_id in session.completed_events:
			Global.debug_log("[事件系统] %s 互斥事件已完成: %s" % [event.event_id, exclude_id])
			return false
	var required_family: Array[String] = event.get_required_family()
	if not required_family.is_empty():
		var session_bg: String = session.family_background.replace("family_", "")
		var family_match: bool = false
		for rf: String in required_family:
			if rf.replace("family_", "") == session_bg:
				family_match = true
				break
		if not family_match:
			Global.debug_log("[事件系统] %s 家庭背景不满足: 需要%s, 当前%s" % [event.event_id, str(required_family), session.family_background])
			return false
	var trigger_chance: float = event.get_trigger_chance()
	if trigger_chance < 1.0 and randf() > trigger_chance:
		Global.debug_log("[事件系统] %s 概率未通过: %.0f%%" % [event.event_id, trigger_chance * 100.0])
		return false
	if not event.conditions.is_empty():
		if not _check_conditions(event.conditions):
			Global.debug_log("[事件系统] %s 条件不满足" % event.event_id)
			return false
	return true

func trigger_event(event: EventData) -> void:
	Global.debug_log("触发事件：%s" % event.event_name)
	event_triggered.emit(event)

func select_option(event: Dictionary, option: Dictionary) -> void:
	Global.debug_log("选择选项：%s" % option.get("option_id", ""))
	session.last_event_traits.clear()
	session.last_event_towers.clear()
	_apply_rewards(option.get("rewards", []))
	_apply_costs(option.get("cost", {}))
	_apply_attribute_changes(option.get("attribute_changes", {}))
	_apply_trait_changes(option.get("trait_gains", []), option.get("trait_losses", []))
	_apply_profession_change(option.get("profession_change", ""), option.get("profession_lost", false))
	_apply_npc_relation_changes(option.get("npc_relation_changes", []))
	_apply_tower_changes(option.get("tower_gains", []), option.get("tower_losses", []))
	_apply_gold_change(option.get("gold_change", 0))
	_apply_karma_change(option.get("karma_cost", 0))
	_apply_world_changes(option.get("world_changes", {}))
	_apply_tension_changes(option.get("tension_changes", []))
	_apply_event_unlocks(option.get("unlock_events", []), option.get("lock_events", []))
	if GameState.current_state == GameState.State.ENDING:
		return
	var opt_chain_flag: String = str(option.get("chain_flag", ""))
	if opt_chain_flag != "" and not opt_chain_flag in session.chain_flags:
		session.chain_flags.append(opt_chain_flag)
		Global.debug_log("[事件系统] 记录chain_flag: %s" % opt_chain_flag)
	_apply_family_effect(option.get("family_effect", {}))
	if GameState.current_state == GameState.State.ENDING:
		return
	var event_id: String = event.get("event_id", "")
	session.completed_events.append(event_id)
	session.recent_events.append(event_id)
	if session.recent_events.size() > 20:
		session.recent_events.pop_front()
	var old_age: int = session.current_age
	session.current_age += 1
	Global.debug_log("年龄+1 → %d" % session.current_age)
	for npc: NPCData in session.npcs:
		if npc.is_active:
			npc.age += 1
			npc.life_stage = _get_life_stage_for_age(npc.age)
	if session.current_age != old_age:
		_apply_salary_payment()
		_apply_stage_attribute_growth()
		_advance_tensions()
		var age_sys: Node = _get_age_system()
		if age_sys and age_sys.has_method("apply_age_penalty"):
			age_sys.apply_age_penalty()
		if GameState.current_state == GameState.State.ENDING:
			return
	_check_stage_transition()
	var age_sys: Node = _get_age_system()
	if age_sys and age_sys.has_method("increment_stage_events"):
		age_sys.increment_stage_events()
	if age_sys and "current_age" in age_sys:
		age_sys.current_age = session.current_age
	var opt_map_weights: Dictionary = option.get("map_weights", {})
	if not opt_map_weights.is_empty():
		for map_id in opt_map_weights:
			var weight: float = float(opt_map_weights[map_id])
			session.accumulated_map_weights[map_id] = session.accumulated_map_weights.get(map_id, 0.0) + weight
		Global.debug_log("[事件系统] 累积地图权重: %s" % str(session.accumulated_map_weights))
	var opt_modifiers: Array = option.get("battle_modifiers", [])
	if not opt_modifiers.is_empty():
		session.pending_battle_modifiers.append_array(opt_modifiers)
		Global.debug_log("[事件系统] 收集战斗修改器: %d个" % opt_modifiers.size())
	if option.get("battle_trigger") is Dictionary:
		_trigger_battle(option.battle_trigger)
	elif option.get("triggers_ending", false) == true:
		_trigger_life_ending(option.get("ending_reason", "player_choice"))
	event_completed.emit(event_id, option.get("option_id", ""))

func _apply_rewards(rewards: Array) -> void:
	var era_sys: Node = get_node_or_null("/root/EraSystem")
	for reward_raw: Dictionary in rewards:
		var reward := RewardData.from_dict(reward_raw)
		match reward.reward_type:
			"tower":
				_grant_tower(reward.id, reward.count)
			"trait":
				_grant_trait(reward.id)
			"gold":
				var base_gold: int = reward.value if reward.value != 0 else reward.count
				var actual_gold: int = base_gold
				if base_gold > 0 and era_sys and era_sys.has_method("apply_gold_bonus"):
					actual_gold = era_sys.apply_gold_bonus(base_gold)
				session.gold += actual_gold
				Global.debug_log("金币变化：%d（基础：%d，加成后：%d）" % [actual_gold, base_gold, actual_gold])
			"attribute":
				var attr: String = reward.attribute if reward.attribute != "" else reward.id
				if attr == "":
					attr = "intelligence"
				var count: int = reward.value if reward.value != 0 else reward.count
				if session.attributes.has(attr):
					session.attributes[attr] += count
					var ac: Node = get_node_or_null("/root/AttributeConfig")
					var attr_display: String = attr
					if ac and ac.has_method("get_display_name"):
						attr_display = ac.get_display_name(attr)
					Global.debug_log("属性变化：%s %+d → %d" % [attr_display, count, session.attributes[attr]])
	_check_health_depleted()

func _grant_tower(tower_id: String, _count: int) -> void:
	session.add_tower(tower_id, _count if _count > 0 else -1)
	session.last_event_towers.append({"tower_id": tower_id, "count": _count})
	var count_text: String = tr("TOWER_INFINITE") if _count < 0 else tr("TOWER_COUNT_FORMAT") % _count
	Global.debug_log("获得防御塔：%s（%s）" % [tower_id, count_text])

func _grant_trait(trait_id: String) -> void:
	if not trait_id in session.traits:
		session.traits.append(trait_id)
		session.last_event_traits.append(trait_id)
		Global.debug_log("获得词条：%s" % trait_id)

func _apply_family_effect(fx: Variant) -> void:
	if fx is Array:
		for entry: Dictionary in fx:
			_apply_single_family_effect(entry)
	elif fx is Dictionary:
		_apply_single_family_effect(fx)

func _apply_single_family_effect(fx: Dictionary) -> void:
	if fx.is_empty():
		return
	var member_id: String = fx.get("member", "")
	if member_id == "" or not session.family_members.has(member_id):
		return
	var member: Dictionary = session.family_members[member_id]
	if fx.has("health_change"):
		member["health"] = int(member.get("health", 100)) + int(fx.health_change)
		Global.debug_log("[家庭] %s 健康变更: %+d → %d" % [member_id, int(fx.health_change), member["health"]])
	if fx.has("alive_change"):
		member["alive"] = fx.alive_change
		Global.debug_log("[家庭] %s 存活状态: %s" % [member_id, str(fx.alive_change)])
	if fx.has("born_change"):
		member["born"] = fx.born_change
		member["alive"] = true
		if fx.has("is_twin"):
			member["is_twin"] = fx.is_twin
		Global.debug_log("[家庭] %s 出生" % member_id)
	if fx.has("met_change"):
		member["met"] = fx.met_change
		Global.debug_log("[家庭] %s 相遇" % member_id)

func _check_health_depleted() -> void:
	if session.attributes.get("health", 0) <= 0 or session.home_health <= 0.0:
		Global.debug_log("健康归零，触发人生结局（属性健康=%d，基地生命=%.0f，阶段=%s）" % [session.attributes.get("health", 0), session.home_health, session.current_stage])
		if session.attributes.get("health", 0) <= 0:
			session.home_health = 0.0
		_trigger_life_ending("health_depleted")

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
	_check_health_depleted()

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
	_check_health_depleted()

func _apply_salary_payment() -> void:
	var es: Node = get_node_or_null("/root/EconomySystem")
	if es and es.has_method("apply_salary"):
		var salary: int = es.apply_salary()
		if salary > 0:
			Global.debug_log("[薪资] 年龄增长，获得薪资：%d 金币" % salary)

func _trigger_life_ending(reason: String) -> void:
	session.ending_reason = reason
	GameState.change_state(GameState.State.ENDING)

func _trigger_battle(battle_trigger: Dictionary) -> void:
	var battle_id: String = battle_trigger.get("battle_id", "unknown")
	var is_deadly: bool = battle_trigger.get("is_deadly", false)
	Global.debug_log("触发战斗：%s (致命：%s)" % [battle_id, str(is_deadly)])
	var force_map: String = str(battle_trigger.get("force_map_id", ""))
	var selected_map_id: String = ""
	if force_map != "":
		selected_map_id = force_map
		Global.debug_log("[事件系统] 强制地图: %s" % selected_map_id)
	elif is_deadly:
		selected_map_id = "map_hospital"
		Global.debug_log("[事件系统] 致命战斗→医院地图: %s" % selected_map_id)
	elif not session.accumulated_map_weights.is_empty():
		selected_map_id = _select_map_by_weights(session.accumulated_map_weights)
		session.accumulated_map_weights.clear()
		Global.debug_log("[事件系统] 权重选图: %s" % selected_map_id)
	else:
		selected_map_id = "map_01"
		Global.debug_log("[事件系统] 默认地图: %s" % selected_map_id)
	session.current_map_id = selected_map_id
	session.current_battle_id = battle_id
	session.current_battle_deadly = is_deadly
	session.current_battle_waves.clear()
	battle_triggered.emit(battle_trigger)

func _select_map_by_weights(weights: Dictionary) -> String:
	var current_era: String = session.era_id
	var available_ids: Array = MapConfig.get_map_ids()
	var filtered_weights: Dictionary = {}
	for map_id in weights:
		if not map_id in available_ids:
			continue
		var map_cfg: MapConfig = MapConfig.load_map(map_id)
		if map_cfg == null:
			continue
		if map_cfg.era_id == "" or map_cfg.era_id == current_era:
			filtered_weights[map_id] = float(weights[map_id])
	if filtered_weights.is_empty():
		return "map_01"
	var best_id: String = ""
	var best_weight: float = -1.0
	for map_id in filtered_weights:
		if filtered_weights[map_id] > best_weight:
			best_weight = filtered_weights[map_id]
			best_id = map_id
	return best_id

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
		else:
			var current_value: int = session.attributes.get(attr_name, 0)
			if current_value < int(required_value):
				return false
	return true

func _check_stage_transition() -> void:
	var stage_transitions: Dictionary = {
		"childhood": {"min_age": 14, "next_stage": "youth"},
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

func _apply_attribute_changes(changes: Dictionary) -> void:
	if changes.is_empty():
		return
	for attr_name: String in changes:
		var change_val: int = int(changes[attr_name])
		if session.attributes.has(attr_name):
			session.attributes[attr_name] += change_val
			Global.debug_log("[后果] 属性变化：%s %+d → %d" % [attr_name, change_val, session.attributes[attr_name]])
	_check_health_depleted()

func _apply_trait_changes(gains: Array, losses: Array) -> void:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	for trait_id: String in gains:
		if ts and ts.has_method("grant_trait"):
			ts.grant_trait(trait_id)
		else:
			if not trait_id in session.traits:
				session.traits.append(trait_id)
				session.last_event_traits.append(trait_id)
	for trait_id: String in losses:
		if ts and ts.has_method("remove_trait"):
			ts.remove_trait(trait_id)
		else:
			if trait_id in session.traits:
				session.traits.erase(trait_id)
		Global.debug_log("[后果] 失去词条：%s" % trait_id)

func _apply_profession_change(new_profession: String, lost: bool) -> void:
	if lost:
		var old: String = session.current_profession
		session.current_profession = ""
		Global.debug_log("[后果] 失去职业：%s" % old)
	if new_profession != "":
		session.current_profession = new_profession
		Global.debug_log("[后果] 获得职业：%s" % new_profession)

func _apply_npc_relation_changes(changes: Array) -> void:
	for change: Dictionary in changes:
		var npc_id: String = str(change.get("npc_id", ""))
		var value: int = int(change.get("value", 0))
		var found: bool = false
		for npc: NPCData in session.npcs:
			if npc.npc_id == npc_id:
				npc.affection = clampi(npc.affection + value, 0, 100)
				Global.debug_log("[后果] NPC好感度变化：%s %+d → %d" % [npc_id, value, npc.affection])
				found = true
				break
		if not found and value > 0:
			var new_npc: NPCData = NPCData.new()
			new_npc.npc_id = npc_id
			new_npc.name = str(change.get("name", npc_id))
			new_npc.relation_type = str(change.get("relation_type", _infer_relation_from_id(npc_id)))
			new_npc.affection = clampi(50 + value, 0, 100)
			new_npc.health = int(change.get("health", 100))
			new_npc.age = session.current_age + int(change.get("age_offset", 0))
			new_npc.life_stage = _get_life_stage_for_age(new_npc.age)
			new_npc.is_active = true
			new_npc.willpower = randi_range(30, 70)
			new_npc.craziness = randi_range(20, 60)
			new_npc.generosity = randi_range(30, 70)
			new_npc.loyalty = randi_range(40, 80)
			new_npc.ambition = randi_range(30, 70)
			new_npc.wealth = randi_range(0, 3000)
			new_npc.trust = randi_range(50, 80)
			session.npcs.append(new_npc)
			Global.debug_log("[后果] 新增NPC：%s（%s，好感%d）" % [tr(new_npc.name), new_npc.relation_type, new_npc.affection])

func _infer_relation_from_id(npc_id: String) -> String:
	if npc_id.find("father") >= 0:
		return "father"
	elif npc_id.find("mother") >= 0:
		return "mother"
	elif npc_id.find("grandma_m") >= 0:
		return "grandma_m"
	elif npc_id.find("grandma") >= 0:
		return "grandma_p"
	elif npc_id.find("grandpa") >= 0:
		return "grandpa_p"
	elif npc_id.find("friend") >= 0:
		return "friend"
	elif npc_id.find("mentor") >= 0:
		return "mentor"
	elif npc_id.find("colleague") >= 0:
		return "colleague"
	elif npc_id.find("child") >= 0:
		return "child"
	elif npc_id.find("spouse") >= 0:
		return "spouse"
	return "other"

func _apply_tower_changes(gains: Array, losses: Array) -> void:
	for tower_id: String in gains:
		session.add_tower(tower_id, -1)
		session.last_event_towers.append({"tower_id": tower_id, "count": -1})
		Global.debug_log("[后果] 获得防御塔：%s" % tower_id)
	for tower_id: String in losses:
		if session.towers.has(tower_id):
			session.towers.erase(tower_id)
			Global.debug_log("[后果] 失去防御塔：%s" % tower_id)

func _apply_gold_change(amount: int) -> void:
	if amount == 0:
		return
	session.gold = maxi(session.gold + amount, 0)
	if amount > 0:
		Global.debug_log("[后果] 金币 +%d → %d" % [amount, session.gold])
	else:
		Global.debug_log("[后果] 金币 %d → %d" % [amount, session.gold])

func _apply_event_unlocks(unlocks: Array, locks: Array) -> void:
	for event_id: String in unlocks:
		if not event_id in session.unlocked_events:
			session.unlocked_events.append(event_id)
			Global.debug_log("[后果] 解锁事件：%s" % event_id)
	for event_id: String in locks:
		if not event_id in session.locked_events:
			session.locked_events.append(event_id)
			Global.debug_log("[后果] 锁定事件：%s" % event_id)

func _apply_karma_change(karma_cost: int) -> void:
	if karma_cost == 0:
		return
	session.karma = clampi(session.karma + karma_cost, -100, 100)
	Global.debug_log("[后果] 业力 %+d → %d" % [karma_cost, session.karma])

func _apply_world_changes(changes: Dictionary) -> void:
	if changes.is_empty():
		return
	for key: String in changes:
		var val: int = int(changes[key])
		if session.attributes.has(key):
			session.attributes[key] += val
			Global.debug_log("[后果] 属性变化：%s %+d → %d" % [key, val, session.attributes[key]])
		elif session.hidden_attributes.has(key):
			session.hidden_attributes[key] += val
			Global.debug_log("[后果] 隐性属性变化：%s %+d → %d" % [key, val, session.hidden_attributes[key]])
		elif key == "karma":
			_apply_karma_change(val)
		elif key == "gold":
			_apply_gold_change(val)
		elif key == "fame":
			session.fame = maxi(session.fame + val, 0)
			Global.debug_log("[后果] 名望 %+d → %d" % [val, session.fame])
	_check_health_depleted()

func _apply_tension_changes(changes: Array) -> void:
	for change: Dictionary in changes:
		var action: String = str(change.get("action", ""))
		match action:
			"add":
				var t := TensionData.new()
				t.tension_id = str(change.get("tension_id", ""))
				t.source_event = str(change.get("source_event", ""))
				t.title = str(change.get("title", ""))
				t.description = str(change.get("description", ""))
				t.duration = int(change.get("duration", 3))
				t.remaining = t.duration
				t.pressure = float(change.get("pressure", 0.5))
				t.resolution_event = str(change.get("resolution_event", ""))
				t.tension_type = str(change.get("tension_type", ""))
				var existing_idx: int = -1
				for i: int in range(session.tensions.size()):
					if session.tensions[i].tension_id == t.tension_id:
						existing_idx = i
						break
				if existing_idx >= 0:
					session.tensions[existing_idx] = t
				else:
					session.tensions.append(t)
				Global.debug_log("[张力] 添加：%s（类型=%s，持续=%d年，压力=%.1f）" % [t.tension_id, t.tension_type, t.remaining, t.pressure])
			"resolve":
				var category: String = str(change.get("tension_category", ""))
				var tid: String = str(change.get("tension_id", ""))
				var to_remove: Array[int] = []
				for i: int in range(session.tensions.size()):
					if (category != "" and session.tensions[i].tension_type == category) or (tid != "" and session.tensions[i].tension_id == tid):
						to_remove.append(i)
				to_remove.reverse()
				for idx: int in to_remove:
					var removed: TensionData = session.tensions.pop_at(idx)
					Global.debug_log("[张力] 解除：%s" % removed.tension_id)
			"extend":
				var tid2: String = str(change.get("tension_id", ""))
				var years: int = int(change.get("years", 1))
				for tension: TensionData in session.tensions:
					if tension.tension_id == tid2:
						tension.remaining += years
						tension.duration += years
						Global.debug_log("[张力] 延长：%s +%d年 → 剩余%d年" % [tid2, years, tension.remaining])

func _advance_tensions() -> void:
	var to_resolve: Array[TensionData] = []
	for tension: TensionData in session.tensions:
		tension.remaining -= 1
		if tension.remaining <= 0:
			to_resolve.append(tension)
		else:
			Global.debug_log("[张力] 推进：%s 剩余%d年" % [tension.tension_id, tension.remaining])
	for tension: TensionData in to_resolve:
		session.tensions.erase(tension)
		Global.debug_log("[张力] 到期：%s → 触发结算事件 %s" % [tension.tension_id, tension.resolution_event])
		if tension.resolution_event != "":
			session.unlocked_events.append(tension.resolution_event)
