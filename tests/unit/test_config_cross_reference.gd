extends GutTest

var _events_data: Dictionary
var _traits_data: Dictionary
var _towers_data: Dictionary
var _enemies_data: Dictionary
var _attributes_data: Dictionary
var _stages_data: Dictionary

func before_all() -> void:
	_events_data = ConfigManager.load_json("res://data/events.json")
	_traits_data = ConfigManager.load_json("res://data/traits.json")
	_towers_data = ConfigManager.load_json("res://data/towers.json")
	_enemies_data = ConfigManager.load_json("res://data/enemies.json")
	_attributes_data = ConfigManager.load_json("res://data/attributes.json")
	_stages_data = ConfigManager.load_json("res://data/stages.json")

func _get_trait_ids() -> Dictionary:
	var ids: Dictionary = {}
	for t: Dictionary in _traits_data.traits:
		ids[t.trait_id] = true
	return ids

func _get_tower_ids() -> Dictionary:
	var ids: Dictionary = {}
	for t: Dictionary in _towers_data.towers:
		ids[t.tower_id] = true
	return ids

func _get_enemy_ids() -> Dictionary:
	var ids: Dictionary = {}
	for e: Dictionary in _enemies_data.enemies:
		ids[e.enemy_id] = true
	return ids

func _get_attribute_ids() -> Dictionary:
	var ids: Dictionary = {}
	for key: String in _attributes_data.attributes:
		ids[key] = true
	return ids

func _get_event_ids() -> Dictionary:
	var ids: Dictionary = {}
	for e: Dictionary in _events_data.events:
		ids[e.event_id] = true
	return ids

func _get_options_for_event(event_id: String) -> Array:
	var result: Array = []
	for ev: Dictionary in _events_data.events:
		if ev.get("event_id", "") == event_id:
			result = ev.get("options", [])
			break
	return result

func _get_stage_ranges() -> Dictionary:
	var ranges: Dictionary = {}
	var stages: Array = AgeSystem.STAGE_IDS.keys()
	for i: int in range(stages.size()):
		var stage: int = stages[i]
		var start_age: int = AgeSystem.STAGE_AGES[stage].start
		var end_age: int = AgeSystem.STAGE_AGES[stage].end
		if i + 1 < stages.size():
			end_age = AgeSystem.STAGE_AGES[stages[i + 1]].start - 1
		ranges[AgeSystem.STAGE_IDS[stage]] = {"start": start_age, "end": end_age}
	return ranges

func test_event_ages_match_stage_range() -> void:
	var stage_ranges: Dictionary = _get_stage_ranges()
	for ev: Dictionary in _events_data.events:
		var stage: String = ev.stage
		assert_true(stage_ranges.has(stage), "%s 引用了不存在的阶段 %s" % [ev.event_id, stage])
		if not stage_ranges.has(stage):
			continue
		var sr: Dictionary = stage_ranges[stage]
		assert_true(ev.ages.any(func(age: int) -> bool: return age >= sr.start and age <= sr.end),
			"%s 应至少有一个年龄落在 %s 阶段 (%d-%d)" % [ev.event_id, stage, sr.start, sr.end])

func test_event_trait_rewards_exist() -> void:
	var trait_ids: Dictionary = _get_trait_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in _get_options_for_event(ev.event_id):
			for trait_id: String in opt.get("trait_gains", []):
				assert_has(trait_ids, trait_id, "%s 选项获得的词条应有效" % ev.event_id)
			for r: Dictionary in opt.get("rewards", []):
				if r.type == "trait":
					assert_true(trait_ids.has(r.id),
						"%s 选项%s 奖励词条 %s 不存在于 traits.json" % [ev.event_id, opt.option_id, r.id])

func test_event_tower_rewards_exist() -> void:
	var tower_ids: Dictionary = _get_tower_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in _get_options_for_event(ev.event_id):
			for tower_id: String in opt.get("tower_gains", []):
				assert_has(tower_ids, tower_id, "%s 选项获得的塔应有效" % ev.event_id)
			for r: Dictionary in opt.get("rewards", []):
				if r.type == "tower":
					assert_true(tower_ids.has(r.id),
						"%s 选项%s 奖励防御塔 %s 不存在于 towers.json" % [ev.event_id, opt.option_id, r.id])

func test_event_attribute_rewards_exist() -> void:
	var attr_ids: Dictionary = _get_attribute_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in _get_options_for_event(ev.event_id):
			for r: Dictionary in opt.get("rewards", []):
				if r.type == "attribute":
					var reward := RewardData.from_dict(r)
					var attribute: String = reward.attribute if reward.attribute != "" else reward.id
					assert_has(attr_ids, attribute, "%s 选项奖励有效属性" % ev.event_id)

func test_event_battle_trigger_valid() -> void:
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in _get_options_for_event(ev.event_id):
			var bt = opt.get("battle_trigger", null)
			if bt == null:
				continue
			assert_true(bt is Dictionary, "%s 选项%s battle_trigger 应为字典" % [ev.event_id, opt.option_id])
			if bt is Dictionary:
				assert_true(bt.has("battle_id"), "%s 选项%s battle_trigger 应包含 battle_id" % [ev.event_id, opt.option_id])

func test_event_trait_requirements_exist() -> void:
	var trait_ids: Dictionary = _get_trait_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in _get_options_for_event(ev.event_id):
			var reqs: Dictionary = opt.get("requirements", {})
			if reqs.has("trait"):
				var tname: String = reqs.trait.lstrip("!")
				assert_true(trait_ids.has(tname),
					"%s 选项%s 需求词条 %s 不存在于 traits.json" % [ev.event_id, opt.option_id, tname])

func _get_choice_flags() -> Dictionary:
	var choice_flags: Dictionary = {}
	for ev: Dictionary in _events_data.events:
		for option: Dictionary in ev.get("options", []):
			var flag: String = option.get("chain_flag", "")
			if flag != "":
				choice_flags[flag] = true
	return choice_flags

func test_event_chain_prerequisites_exist() -> void:
	var event_ids: Dictionary = _get_event_ids()
	var choice_flags: Dictionary = _get_choice_flags()
	for ev: Dictionary in _events_data.events:
		var prerequisites: Array = ev.get("chain_prerequisites", []) + ev.get("chain_prerequisites_any", [])
		for prereq: String in prerequisites:
			if prereq.begins_with("flag:"):
				assert_true(choice_flags.has(prereq.substr(5)),
					"%s 的前置标记 %s 应由某个选项写入" % [ev.event_id, prereq])
			else:
				assert_true(event_ids.has(prereq),
					"%s 的前置事件 %s 应存在于 events.json" % [ev.event_id, prereq])

func test_event_chain_excludes_exist() -> void:
	var event_ids: Dictionary = _get_event_ids()
	var choice_flags: Dictionary = _get_choice_flags()
	for ev: Dictionary in _events_data.events:
		for excl: String in ev.get("chain_excludes", []):
			if excl.begins_with("flag:"):
				assert_has(choice_flags, excl.substr(5), "%s 引用有效的互斥标记" % ev.event_id)
			else:
				assert_has(event_ids, excl, "%s 引用有效的互斥事件" % ev.event_id)

func test_second_child_is_excluded_by_twins_flag() -> void:
	for raw: Dictionary in _events_data.events:
		if raw.event_id != "event_second_child":
			continue
		var event := EventData.from_dict(raw)
		var session := GameSessionData.new()
		for prereq: String in event.chain_prerequisites + event.chain_prerequisites_any:
			if prereq.begins_with("flag:"):
				session.chain_flags.append(prereq.substr(5))
			else:
				session.completed_events.append(prereq)
		assert_true(event.matches_event_chain(session), "满足前置条件时应可触发")
		session.chain_flags.append("child_twins")
		assert_false(event.matches_event_chain(session), "生过双胞胎后应阻止二胎事件")
		return
	fail_test("缺少二胎事件配置")

func test_stages_available_towers_exist() -> void:
	var tower_ids: Dictionary = _get_tower_ids()
	for sid: String in _stages_data.stages:
		var stage: Dictionary = _stages_data.stages[sid]
		for tid: String in stage.get("available_towers", []):
			assert_true(tower_ids.has(tid),
				"阶段%s 可用塔 %s 不存在于 towers.json" % [sid, tid])

func test_stages_enemy_pool_exist() -> void:
	var enemy_ids: Dictionary = _get_enemy_ids()
	for sid: String in _stages_data.stages:
		var stage: Dictionary = _stages_data.stages[sid]
		for enemy_id: String in stage.get("enemy_pool", {}):
			assert_has(enemy_ids, enemy_id, "阶段 %s 的敌人池引用有效敌人" % sid)

func test_stages_attribute_growth_attrs_exist() -> void:
	var attr_ids: Dictionary = _get_attribute_ids()
	for sid: String in _stages_data.stages:
		var stage: Dictionary = _stages_data.stages[sid]
		assert_true(stage.get("attribute_growth", {}) is Dictionary, "阶段属性成长应为字典")
		var growth: Dictionary = stage.get("attribute_growth", {})
		for attr: String in growth:
			assert_true(attr_ids.has(attr),
				"阶段%s 属性增长 %s 不存在于 attributes.json" % [sid, attr])

func test_enemy_split_spawn_ids_exist() -> void:
	var enemy_ids: Dictionary = _get_enemy_ids()
	for e: Dictionary in _enemies_data.enemies:
		assert_true(e.get("special_abilities", []) is Array, "敌人特殊能力应为数组")
		for ability: Dictionary in e.get("special_abilities", []):
			if ability.has("split_enemy_id"):
				assert_true(enemy_ids.has(ability.split_enemy_id),
					"%s 分裂敌人 %s 不存在于 enemies.json" % [e.enemy_id, ability.split_enemy_id])
			if ability.has("spawn_enemy_id"):
				assert_true(enemy_ids.has(ability.spawn_enemy_id),
					"%s 召唤敌人 %s 不存在于 enemies.json" % [e.enemy_id, ability.spawn_enemy_id])
			if ability.has("spawn_enemy_pool"):
				for pool_id: String in ability.spawn_enemy_pool:
					assert_true(enemy_ids.has(pool_id),
						"%s 召唤池敌人 %s 不存在于 enemies.json" % [e.enemy_id, pool_id])
			if ability.has("spawn_enemies"):
				for se: Dictionary in ability.spawn_enemies:
					assert_true(enemy_ids.has(se.id),
						"%s 召唤敌人 %s 不存在于 enemies.json" % [e.enemy_id, se.id])

func test_no_age_gaps_in_critical_stages() -> void:
	var age_coverage: Dictionary = {}
	for ev: Dictionary in _events_data.events:
		for age: int in ev.ages:
			age_coverage[age] = true
	var critical_stages: Dictionary = {"youth": [15, 34], "middle_age": [35, 49]}
	for sname: String in critical_stages:
		var bounds: Array = critical_stages[sname]
		for age: int in range(bounds[0], bounds[1] + 1):
			assert_true(age_coverage.has(age),
				"关键阶段%s 年龄%d 无任何事件覆盖" % [sname, age])
