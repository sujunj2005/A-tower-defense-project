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

func _get_stage_ranges() -> Dictionary:
	var ranges: Dictionary = {}
	for sid: String in _stages_data.stages:
		var s: Dictionary = _stages_data.stages[sid]
		ranges[sid] = {"start": s.age_range.start, "end": s.age_range.end}
	return ranges

func test_event_ages_match_stage_range() -> void:
	var stage_ranges: Dictionary = _get_stage_ranges()
	for ev: Dictionary in _events_data.events:
		var stage: String = ev.stage
		assert_true(stage_ranges.has(stage), "%s 引用了不存在的阶段 %s" % [ev.event_id, stage])
		if not stage_ranges.has(stage):
			continue
		var sr: Dictionary = stage_ranges[stage]
		for age: int in ev.ages:
			assert_true(age >= sr.start and age <= sr.end,
				"%s age=%d 不在 %s 阶段范围内 (%d-%d)" % [ev.event_id, age, stage, sr.start, sr.end])

func test_event_trait_rewards_exist() -> void:
	var trait_ids: Dictionary = _get_trait_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in ev.options:
			for r: Dictionary in opt.get("rewards", []):
				if r.type == "trait":
					assert_true(trait_ids.has(r.id),
						"%s 选项%s 奖励词条 %s 不存在于 traits.json" % [ev.event_id, opt.option_id, r.id])

func test_event_tower_rewards_exist() -> void:
	var tower_ids: Dictionary = _get_tower_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in ev.options:
			for r: Dictionary in opt.get("rewards", []):
				if r.type == "tower":
					assert_true(tower_ids.has(r.id),
						"%s 选项%s 奖励防御塔 %s 不存在于 towers.json" % [ev.event_id, opt.option_id, r.id])

func test_event_attribute_rewards_exist() -> void:
	var attr_ids: Dictionary = _get_attribute_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in ev.options:
			for r: Dictionary in opt.get("rewards", []):
				if r.type == "attribute":
					assert_true(attr_ids.has(r.id),
						"%s 选项%s 奖励属性 %s 不存在于 attributes.json" % [ev.event_id, opt.option_id, r.id])

func test_event_battle_enemies_exist() -> void:
	var enemy_ids: Dictionary = _get_enemy_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in ev.options:
			var bt: Dictionary = opt.get("battle_trigger", {})
			if bt and bt.get("waves", []):
				for wave: Dictionary in bt.waves:
					for e: Dictionary in wave.get("enemies", []):
						assert_true(enemy_ids.has(e.id),
							"%s 选项%s 波次%d 敌人 %s 不存在于 enemies.json" % [ev.event_id, opt.option_id, wave.wave_number, e.id])

func test_event_trait_requirements_exist() -> void:
	var trait_ids: Dictionary = _get_trait_ids()
	for ev: Dictionary in _events_data.events:
		for opt: Dictionary in ev.options:
			var reqs: Dictionary = opt.get("requirements", {})
			if reqs.has("trait"):
				var tname: String = reqs.trait.lstrip("!")
				assert_true(trait_ids.has(tname),
					"%s 选项%s 需求词条 %s 不存在于 traits.json" % [ev.event_id, opt.option_id, tname])

func test_event_chain_prerequisites_exist() -> void:
	var event_ids: Dictionary = _get_event_ids()
	for ev: Dictionary in _events_data.events:
		for prereq: String in ev.get("chain_prerequisites", []):
			assert_true(event_ids.has(prereq),
				"%s 前置事件 %s 不存在于 events.json" % [ev.event_id, prereq])

func test_event_chain_excludes_exist() -> void:
	var event_ids: Dictionary = _get_event_ids()
	for ev: Dictionary in _events_data.events:
		for excl: String in ev.get("chain_excludes", []):
			assert_true(event_ids.has(excl),
				"%s 互斥事件 %s 不存在于 events.json" % [ev.event_id, excl])

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
		for e: Dictionary in stage.get("enemy_pool", []):
			assert_true(enemy_ids.has(e.id),
				"阶段%s 敌人池 %s 不存在于 enemies.json" % [sid, e.id])

func test_stages_attribute_growth_attrs_exist() -> void:
	var attr_ids: Dictionary = _get_attribute_ids()
	for sid: String in _stages_data.stages:
		var stage: Dictionary = _stages_data.stages[sid]
		var growth: Dictionary = stage.get("attribute_growth", {})
		for attr: String in growth:
			assert_true(attr_ids.has(attr),
				"阶段%s 属性增长 %s 不存在于 attributes.json" % [sid, attr])

func test_enemy_split_spawn_ids_exist() -> void:
	var enemy_ids: Dictionary = _get_enemy_ids()
	for e: Dictionary in _enemies_data.enemies:
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
