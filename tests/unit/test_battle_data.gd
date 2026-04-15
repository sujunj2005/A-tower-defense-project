extends GutTest

## TowerData 和 EnemyData 单元测试

func test_tower_data_creation():
	var tower = TowerData.new()
	tower.tower_id = "tower_chinese_basic"
	tower.tower_name = "语文之塔"
	tower.damage = 15.0
	tower.attack_speed = 1.2
	
	assert_eq(tower.tower_id, "tower_chinese_basic", "塔 ID 应匹配")
	assert_eq(tower.tower_name, "语文之塔", "塔名称应匹配")
	assert_eq(tower.damage, 15.0, "伤害值应匹配")
	assert_eq(tower.attack_speed, 1.2, "攻速应匹配")

func test_tower_data_serialization():
	var original = TowerData.new()
	original.tower_id = "tower_math_basic"
	original.tower_name = "数学之塔"
	original.damage = 20.0
	original.level = 3
	
	# 序列化
	var dict_data = original.to_dict()
	
	# 反序列化
	var restored = TowerData.from_dict(dict_data)
	
	assert_eq(restored.tower_id, original.tower_id, "反序列化后 ID 应匹配")
	assert_eq(restored.tower_name, original.tower_name, "名称应匹配")
	assert_eq(restored.damage, original.damage, "伤害应匹配")
	assert_eq(restored.level, original.level, "等级应匹配")

func test_tower_exp_and_leveling():
	var tower = TowerData.new()
	tower.level = 1
	tower.exp = 0
	
	# 添加经验
	tower.add_exp(50)
	assert_eq(tower.exp, 50, "经验应为 50")
	assert_eq(tower.level, 1, "等级不应变化")
	
	# 升级
	tower.add_exp(100)
	assert_eq(tower.level, 2, "应升到 2 级")
	assert_eq(tower.exp, 50, "剩余经验应为 50")

func test_enemy_data_creation():
	var enemy = EnemyData.new()
	enemy.enemy_id = "enemy_homework"
	enemy.enemy_name = "作业怪"
	enemy.health = 30.0
	enemy.speed = 50.0
	
	assert_eq(enemy.enemy_id, "enemy_homework", "敌人 ID 应匹配")
	assert_eq(enemy.enemy_name, "作业怪", "敌人名称应匹配")
	assert_eq(enemy.health, 30.0, "生命值应匹配")
	assert_eq(enemy.speed, 50.0, "速度应匹配")

func test_enemy_armor_system():
	var enemy = EnemyData.new()
	enemy.current_health = 100.0
	
	# 无护甲
	enemy.armor_type = "none"
	var damage = enemy.take_damage(20.0)
	assert_eq(damage, 20.0, "无护甲应受全额伤害")
	
	# 轻甲（20% 减伤）
	enemy.current_health = 100.0
	enemy.armor_type = "light"
	damage = enemy.take_damage(20.0)
	assert_eq(damage, 16.0, "轻甲应减少 20% 伤害")
	
	# 重甲（40% 减伤）
	enemy.current_health = 100.0
	enemy.armor_type = "heavy"
	damage = enemy.take_damage(20.0)
	assert_eq(damage, 12.0, "重甲应减少 40% 伤害")

func test_enemy_death_and_reset():
	var enemy = EnemyData.new()
	enemy.current_health = 50.0
	
	# 未死亡
	assert_false(enemy.is_dead(), "50 血时不应死亡")
	
	# 死亡
	enemy.current_health = 0.0
	assert_true(enemy.is_dead(), "0 血时应死亡")
	
	# 重置
	enemy.max_health = 100.0
	enemy.reset_health()
	assert_eq(enemy.current_health, 100.0, "重置后血量应回满")
	assert_false(enemy.is_dead(), "重置后不应死亡")

func test_enemy_serialization():
	var original = EnemyData.new()
	original.enemy_id = "enemy_exam"
	original.enemy_name = "考试怪"
	original.armor_type = "light"
	original.kill_reward_gold = 12
	
	var dict_data = original.to_dict()
	var restored = EnemyData.from_dict(dict_data)
	
	assert_eq(restored.enemy_id, original.enemy_id, "ID 应匹配")
	assert_eq(restored.armor_type, original.armor_type, "护甲类型应匹配")
	assert_eq(restored.kill_reward_gold, original.kill_reward_gold, "奖励金币应匹配")
