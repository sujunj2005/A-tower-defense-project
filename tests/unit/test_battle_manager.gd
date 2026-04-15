extends GutTest

## BattleManager 单元测试

func test_battle_manager_initialization():
	var battle_manager = BattleManager.new()
	
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.WAITING, "初始状态应为 WAITING")
	assert_eq(battle_manager.home_health, 100.0, "默认老家生命值应为 100")
	assert_eq(battle_manager.max_home_health, 100.0, "默认最大老家生命值应为 100")
	assert_eq(battle_manager.gold, 50, "默认金币应为 50")
	assert_eq(battle_manager.total_waves, 1, "垂直切片应为 1 波")

func test_home_health_damage():
	var battle_manager = BattleManager.new()
	
	# 测试受到伤害
	battle_manager.home_take_damage(10.0)
	assert_eq(battle_manager.home_health, 90.0, "受到 10 点伤害后生命值应为 90")
	
	# 测试生命值不低于 0
	battle_manager.home_take_damage(100.0)
	assert_eq(battle_manager.home_health, 0.0, "生命值不应低于 0")

func test_gold_system():
	var battle_manager = BattleManager.new()
	
	# 测试金币消耗
	var success = battle_manager.spend_gold(30)
	assert_true(success, "金币充足时应能消耗")
	assert_eq(battle_manager.get_gold(), 20, "消耗 30 金币后余额应为 20")
	
	# 测试金币不足
	success = battle_manager.spend_gold(50)
	assert_false(success, "金币不足时不能消耗")
	assert_eq(battle_manager.get_gold(), 20, "消耗失败后金币应不变")

func test_battle_state_transitions():
	var battle_manager = BattleManager.new()
	
	# 开始战斗
	battle_manager.start_battle()
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.IN_PROGRESS, "状态应变为 IN_PROGRESS")
	
	# 模拟胜利（需要手动触发）
	# 这里测试状态不能重复变更
	battle_manager.start_battle()  # 重复调用
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.IN_PROGRESS, "状态不应重复变更")

func test_home_health_percent():
	var battle_manager = BattleManager.new()
	
	var percent = battle_manager.get_home_health_percent()
	assert_eq(percent, 1.0, "满血时百分比应为 1.0")
	
	battle_manager.home_take_damage(50.0)
	percent = battle_manager.get_home_health_percent()
	assert_eq(percent, 0.5, "50% 血量时百分比应为 0.5")
