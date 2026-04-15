extends GutTest

func test_player_save_data_serialization():
	# 创建测试数据
	var original = PlayerSaveData.new()
	original.currencies["life_wisdom"] = 100
	original.currencies["destiny_points"] = 50
	
	# 序列化
	var dict_data = original.to_dict()
	
	# 反序列化
	var restored = PlayerSaveData.from_dict(dict_data)
	
	# 验证
	assert_eq(restored.currencies["life_wisdom"], 100, "life_wisdom 应该匹配")
	assert_eq(restored.currencies["destiny_points"], 50, "destiny_points 应该匹配")

func test_player_save_data_default_values():
	var save_data = PlayerSaveData.new()
	
	assert_eq(save_data.unlocked_eras.size(), 1, "应该默认解锁 1 个时代")
	assert_eq(save_data.unlocked_eras[0], "china_modern", "默认解锁中国现代")
	assert_eq(save_data.currencies["life_wisdom"], 0, "默认人生智慧为 0")
	assert_eq(save_data.currencies["destiny_points"], 0, "默认命运点数为 0")
