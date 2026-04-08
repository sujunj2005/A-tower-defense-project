extends GutTest

func test_game_session_data_serialization():
	# 创建测试数据
	var original = GameSessionData.new()
	original.current_age = 18
	original.gold = 200
	original.attributes["intelligence"] = 80
	
	# 序列化
	var dict_data = original.to_dict()
	
	# 反序列化
	var restored = GameSessionData.from_dict(dict_data)
	
	# 验证
	assert_eq(restored.current_age, 18, "年龄应该匹配")
	assert_eq(restored.gold, 200, "金币应该匹配")
	assert_eq(restored.attributes["intelligence"], 80, "智力应该匹配")

func test_game_session_data_default_values():
	var session = GameSessionData.new()
	
	assert_eq(session.current_age, 6, "默认起始年龄为 6 岁")
	assert_eq(session.current_stage, "childhood", "默认阶段为童年")
	assert_eq(session.gold, 50, "默认金币为 50")
	assert_eq(session.home_health, 100, "默认老家生命值为 100")
