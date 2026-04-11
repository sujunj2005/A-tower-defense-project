extends GutTest

## Task 4 战斗流程验证测试

var battle_manager: BattleManager
var session: GameSessionData

func before_each() -> void:
	session = GameSessionData.new()
	session.home_health = 100
	session.max_home_health = 100
	session.gold = 50
	Global.game_session = session
	
	battle_manager = BattleManager.new()
	add_child_autofree(battle_manager)
	watch_signals(battle_manager)

func after_each() -> void:
	Global.game_session = null

## 测试 1: BattleManager 初始化
func test_battle_manager_initialization() -> void:
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.WAITING, 
		"初始状态应为 WAITING")
	assert_eq(battle_manager.home_health, 100.0, 
		"默认老家生命值应为 100")
	assert_eq(battle_manager.max_home_health, 100.0, 
		"默认最大老家生命值应为 100")
	assert_eq(battle_manager.gold, 50, 
		"默认金币应为 50")
	assert_eq(battle_manager.total_waves, 1, 
		"垂直切片应为 1 波")

## 测试 2: 老家生命值系统
func test_home_health_system() -> void:
	battle_manager.home_take_damage(10.0)
	assert_eq(battle_manager.home_health, 90.0, 
		"受到 10 点伤害后生命值应为 90")
	assert_signal_emitted(battle_manager, "home_health_changed", 
		"home_health_changed 信号应触发")
	
	battle_manager.home_take_damage(100.0)
	assert_eq(battle_manager.home_health, 0.0, 
		"生命值不应低于 0")
	assert_eq(session.home_health, 0, 
		"会话数据应同步")

## 测试 3: 金币奖励系统
func test_gold_reward_system() -> void:
	var success = battle_manager.spend_gold(30)
	assert_true(success, "金币充足时应能消耗")
	assert_eq(battle_manager.get_gold(), 20, 
		"消耗 30 金币后余额应为 20")
	
	success = battle_manager.spend_gold(50)
	assert_false(success, "金币不足时不能消耗")
	
	var mock_enemy = Enemy.new()
	battle_manager.on_enemy_died(mock_enemy, 5)
	assert_eq(battle_manager.get_gold(), 25, 
		"敌人死亡后金币应增加 5")
	assert_signal_emitted(battle_manager, "enemy_died", 
		"enemy_died 信号应触发")
	assert_eq(session.gold, 25, 
		"会话金币数据应同步")

## 测试 4: 战斗状态转换
func test_battle_state_transitions() -> void:
	battle_manager.start_battle()
	assert_eq(battle_manager.battle_state, 
		BattleManager.BattleState.IN_PROGRESS, 
		"状态应变为 IN_PROGRESS")
	
	battle_manager._on_victory()
	assert_eq(battle_manager.battle_state, 
		BattleManager.BattleState.VICTORY, 
		"状态应变为 VICTORY")
	assert_signal_emitted(battle_manager, "battle_ended", 
		"battle_ended 信号应触发")

## 测试 5: 失败判定
func test_defeat_condition() -> void:
	battle_manager.start_battle()
	battle_manager.home_take_damage(100.0)
	
	assert_eq(battle_manager.battle_state, 
		BattleManager.BattleState.DEFEAT, 
		"状态应变为 DEFEAT")
	assert_signal_emitted(battle_manager, "battle_ended", 
		"battle_ended 信号应触发")

## 测试 6: 防御塔数据验证
func test_tower_data_validation() -> void:
	var tower_data = TowerData.new()
	tower_data.tower_id = "tower_chinese_basic"
	tower_data.tower_name = "语文之塔"
	tower_data.damage = 15.0
	tower_data.attack_speed = 1.2
	tower_data.range = 120.0
	
	assert_eq(tower_data.tower_id, "tower_chinese_basic", 
		"塔 ID 应匹配")
	assert_eq(tower_data.damage, 15.0, 
		"伤害值应匹配")
	assert_eq(tower_data.attack_speed, 1.2, 
		"攻速应匹配")
	
	var dict_data = tower_data.to_dict()
	var restored = TowerData.from_dict(dict_data)
	
	assert_eq(restored.tower_id, tower_data.tower_id, 
		"序列化后 ID 应匹配")
	assert_eq(restored.damage, tower_data.damage, 
		"序列化后伤害应匹配")

## 测试 7: 敌人数据验证
func test_enemy_data_validation() -> void:
	var enemy_data = EnemyData.new()
	enemy_data.enemy_id = "enemy_homework"
	enemy_data.enemy_name = "作业怪"
	enemy_data.health = 30.0
	enemy_data.speed = 50.0
	enemy_data.kill_reward_gold = 5
	
	assert_eq(enemy_data.enemy_id, "enemy_homework", 
		"敌人 ID 应匹配")
	assert_eq(enemy_data.health, 30.0, 
		"生命值应匹配")
	assert_eq(enemy_data.kill_reward_gold, 5, 
		"奖励金币应匹配")
	
	enemy_data.current_health = 100.0
	enemy_data.armor_type = "light"
	
	var damage = enemy_data.take_damage(20.0)
	assert_eq(damage, 16.0, 
		"轻甲应减少 20% 伤害")
	
	enemy_data.current_health = 0.0
	assert_true(enemy_data.is_dead(), 
		"0 血时应死亡")
	
	var dict_data = enemy_data.to_dict()
	var restored = EnemyData.from_dict(dict_data)
	
	assert_eq(restored.enemy_id, enemy_data.enemy_id, 
		"序列化后 ID 应匹配")

## 测试 8: 老家生命值百分比计算
func test_home_health_percent() -> void:
	var percent = battle_manager.get_home_health_percent()
	assert_eq(percent, 1.0, "满血时百分比应为 1.0")
	
	battle_manager.home_take_damage(50.0)
	percent = battle_manager.get_home_health_percent()
	assert_eq(percent, 0.5, "50% 血量时百分比应为 0.5")
	
	battle_manager.home_take_damage(50.0)
	percent = battle_manager.get_home_health_percent()
	assert_eq(percent, 0.0, "0 血量时百分比应为 0.0")

## 测试 9: 波次完成检查
func test_wave_completion() -> void:
	assert_eq(battle_manager.current_wave, 1, 
		"初始波次应为 1")
	assert_eq(battle_manager.total_waves, 1, 
		"垂直切片应为 1 波")
	assert_true(battle_manager.current_wave <= battle_manager.total_waves, 
		"当前波次不应超过总波次")

## 测试 10: 垂直切片完整流程
func test_vertical_slice_full_flow() -> void:
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.WAITING)
	
	battle_manager.start_battle()
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.IN_PROGRESS)
	
	battle_manager.home_take_damage(20.0)
	assert_eq(battle_manager.home_health, 80.0)
	
	var mock_enemy = Enemy.new()
	battle_manager.on_enemy_died(mock_enemy, 10)
	assert_eq(battle_manager.get_gold(), 60)
	
	battle_manager._on_victory()
	assert_eq(battle_manager.battle_state, BattleManager.BattleState.VICTORY)
	
	assert_eq(session.home_health, 80)
	assert_eq(session.gold, 60)
	assert_true(session.completed_battles.size() > 0)
