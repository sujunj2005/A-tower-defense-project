extends GutTest

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
	assert_false(session.current_battle_deadly, "deadly 应为 false")
	assert_true(session.current_battle_victory, "victory 应为 true")

func test_session_data_battle_context_serialization() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.current_battle_id = "battle_gaokao"
	session.current_battle_deadly = true
	session.current_battle_victory = false
	var dict_data: Dictionary = session.to_dict()
	assert_eq(dict_data.get("current_battle_id", ""), "battle_gaokao", "序列化应包含 battle_id")
	assert_eq(dict_data.get("current_battle_deadly", false), true, "序列化应包含 deadly")
	assert_eq(dict_data.get("current_battle_victory", true), false, "序列化应包含 victory")

func test_session_data_battle_context_deserialization() -> void:
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
	assert_eq(session.max_home_health, 100.0, "默认 max_home_health 应为 100.0 (float)")

func test_session_data_traits_array() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.traits.append("happy_childhood")
	session.traits.append("math_talent")
	assert_eq(session.traits.size(), 2, "应能添加特质")
	assert_true(session.traits.has("math_talent"), "应包含已添加的特质")

func test_session_data_towers_array() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.towers.append({"tower_id": "tower_math_basic", "level": 1})
	session.towers.append({"tower_id": "tower_chinese_basic", "level": 2})
	assert_eq(session.towers.size(), 2, "应能添加塔数据")
	assert_eq(session.towers[1]["tower_id"], "tower_chinese_basic", "塔 ID 应正确")

func test_session_data_completed_events() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.completed_events.append("event_kindergarten_show")
	assert_true(session.completed_events.has("event_kindergarten_show"), "应记录已完成事件")

func test_session_data_completed_battles() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.completed_battles.append("battle_zhongkao")
	assert_true(session.completed_battles.has("battle_zhongkao"), "应记录已完成战斗")

func test_session_data_attributes_default() -> void:
	var session: GameSessionData = GameSessionData.new()
	assert_eq(session.attributes.get("intelligence", 0), 50, "默认智力应为 50")
	assert_eq(session.attributes.get("courage", 0), 50, "默认勇气应为 50")
	assert_eq(session.attributes.get("health", 0), 100, "默认健康应为 100")
