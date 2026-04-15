extends GutTest

func test_events_json_loads() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/events.json")
	assert_true(data.has("events"), "events.json 应包含 events 字段")
	var events: Array = data.events
	assert_true(events.size() >= 20, "events.json 应包含至少 20 个事件，实际：%d" % events.size())

func test_events_have_required_fields() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/events.json")
	var options_data: Dictionary = ConfigManager.load_json("res://data/options.json")
	for event: Dictionary in data.events:
		assert_true(event.has("event_id"), "事件应包含 event_id")
		assert_true(event.has("event_name"), "事件应包含 event_name")
		var event_options: Array = []
		for opt: Dictionary in options_data.get("options", []):
			if opt.get("event_id", "") == event.event_id:
				event_options.append(opt)
		assert_true(event_options.size() >= 2, "事件 %s 应至少有 2 个选项，实际：%d" % [event.event_id, event_options.size()])

func test_endings_json_loads() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/endings.json")
	assert_true(data.has("endings"), "endings.json 应包含 endings 字段")
	assert_true(data.endings.size() >= 5, "endings.json 应包含至少 5 个结局")

func test_endings_have_all_ratings() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/endings.json")
	var ratings: Array = []
	for ending: Dictionary in data.endings:
		assert_true(ending.has("rating"), "结局应包含 rating")
		ratings.append(ending.rating)
	assert_true("S" in ratings, "应包含 S 级结局")
	assert_true("A" in ratings, "应包含 A 级结局")
	assert_true("D" in ratings, "应包含 D 级结局")

func test_achievements_json_loads() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/achievements.json")
	assert_true(data.has("achievements"), "achievements.json 应包含 achievements 字段")
	assert_true(data.achievements.size() >= 10, "achievements.json 应包含至少 10 个成就")

func test_stages_json_loads() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/stages.json")
	assert_true(data.has("stages"), "stages.json 应包含 stages 字段")
	assert_eq(data.stages.size(), 4, "stages.json 应包含 4 个阶段")

func test_stages_have_required_fields() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/stages.json")
	var stage_names: Array = []
	for stage: Dictionary in data.stages:
		assert_true(stage.has("stage_id"), "阶段应包含 stage_id")
		assert_true(stage.has("stage_name"), "阶段应包含 stage_name")
		assert_true(stage.has("enemy_pool"), "阶段应包含 enemy_pool")
		stage_names.append(stage.stage_name)
	assert_true("童年" in stage_names, "应包含童年阶段")
	assert_true("老年" in stage_names, "应包含老年阶段")

func test_towers_json_loads() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/towers.json")
	assert_true(data.has("towers"), "towers.json 应包含 towers 字段")
	assert_true(data.towers.size() >= 10, "towers.json 应包含至少 10 种塔")

func test_enemies_json_loads() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/enemies.json")
	assert_true(data.has("enemies"), "enemies.json 应包含 enemies 字段")
	assert_true(data.enemies.size() >= 6, "enemies.json 应包含至少 6 种敌人")

func test_session_data_battle_context_defaults() -> void:
	var session: GameSessionData = GameSessionData.new()
	assert_eq(session.current_battle_id, "", "默认 battle_id 应为空")
	assert_false(session.current_battle_deadly, "默认 deadly 应为 false")
	assert_false(session.current_battle_victory, "默认 victory 应为 false")

func test_session_data_battle_context_set() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.current_battle_id = "battle_zhongkao"
	session.current_battle_deadly = false
	session.current_battle_victory = true
	assert_eq(session.current_battle_id, "battle_zhongkao", "battle_id 应正确设置")
	assert_true(session.current_battle_victory, "victory 应为 true")

func test_session_data_serialization_roundtrip() -> void:
	var original: GameSessionData = GameSessionData.new()
	original.current_battle_id = "battle_cancer"
	original.current_battle_deadly = true
	original.current_battle_victory = false
	original.gold = 100
	original.home_health = 80.0
	var dict_data: Dictionary = original.to_dict()
	var restored: GameSessionData = GameSessionData.from_dict(dict_data)
	assert_eq(restored.current_battle_id, "battle_cancer", "反序列化 battle_id 应正确")
	assert_true(restored.current_battle_deadly, "反序列化 deadly 应正确")
	assert_false(restored.current_battle_victory, "反序列化 victory 应正确")

func test_session_data_home_health_is_float() -> void:
	var session: GameSessionData = GameSessionData.new()
	assert_eq(session.home_health, 100.0, "默认 home_health 应为 100.0 (float)")
