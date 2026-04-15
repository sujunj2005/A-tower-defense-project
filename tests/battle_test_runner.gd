@tool
class_name BattleTestRunner
extends EditorScript

## 战斗流程测试脚本
## 使用方法：在 Godot 编辑器中右键 → 运行脚本

func _run() -> void:
	print("=== 战斗流程验证开始 ===")
	
	# 1. 测试数据结构
	_test_data_structures()
	
	# 2. 测试战斗管理器
	_test_battle_manager()
	
	# 3. 测试防御塔和敌人数据
	_test_tower_and_enemy_data()
	
	print("=== 战斗流程验证完成 ===")

func _test_data_structures() -> void:
	print("\n[1] 测试数据结构...")
	
	# 测试 TowerData
	var tower_data = TowerData.new()
	tower_data.tower_id = "tower_chinese_basic"
	tower_data.tower_name = "语文之塔"
	tower_data.damage = 15.0
	assert(tower_data.tower_id == "tower_chinese_basic", "TowerData ID 测试失败")
	assert(tower_data.damage == 15.0, "TowerData damage 测试失败")
	print("  ✅ TowerData 测试通过")
	
	# 测试 EnemyData
	var enemy_data = EnemyData.new()
	enemy_data.enemy_id = "enemy_homework"
	enemy_data.enemy_name = "作业怪"
	enemy_data.health = 30.0
	assert(enemy_data.enemy_id == "enemy_homework", "EnemyData ID 测试失败")
	assert(enemy_data.health == 30.0, "EnemyData health 测试失败")
	print("  ✅ EnemyData 测试通过")
	
	# 测试序列化和反序列化
	var tower_dict = tower_data.to_dict()
	var restored_tower = TowerData.from_dict(tower_dict)
	assert(restored_tower.tower_id == tower_data.tower_id, "TowerData 序列化测试失败")
	print("  ✅ TowerData 序列化测试通过")
	
	var enemy_dict = enemy_data.to_dict()
	var restored_enemy = EnemyData.from_dict(enemy_dict)
	assert(restored_enemy.enemy_id == enemy_data.enemy_id, "EnemyData 序列化测试失败")
	print("  ✅ EnemyData 序列化测试通过")

func _test_battle_manager() -> void:
	print("\n[2] 测试战斗管理器...")
	
	var battle_manager = BattleManager.new()
	assert(battle_manager.battle_state == BattleManager.BattleState.WAITING, "初始状态错误")
	
	# 测试老家生命值
	battle_manager.home_take_damage(10.0)
	assert(battle_manager.home_health == 90.0, "老家生命值计算错误")
	print("  ✅ 老家生命值系统测试通过")
	
	# 测试金币系统
	battle_manager.gold = 50
	var spent = battle_manager.spend_gold(30)
	assert(spent == true, "金币消耗失败")
	assert(battle_manager.get_gold() == 20, "金币余额错误")
	print("  ✅ 金币系统测试通过")
	
	# 测试失败判定
	battle_manager.home_take_damage(1000.0)
	assert(battle_manager.battle_state == BattleManager.BattleState.DEFEAT, "失败判定错误")
	print("  ✅ 失败判定测试通过")

func _test_tower_and_enemy_data() -> void:
	print("\n[3] 测试防御塔和敌人数据...")
	
	# 测试防御塔升级
	var tower = TowerData.new()
	tower.add_exp(150)
	assert(tower.level == 2, "防御塔升级失败")
	print("  ✅ 防御塔升级系统测试通过")
	
	# 测试敌人护甲减伤
	var enemy = EnemyData.new()
	enemy.armor_type = "light"
	enemy.current_health = 100.0
	var damage = enemy.take_damage(20.0)
	assert(damage == 16.0, "轻甲减伤计算错误")  # 20 * 0.8 = 16
	print("  ✅ 敌人护甲系统测试通过")
	
	# 测试敌人死亡判定
	enemy.current_health = 0.0
	assert(enemy.is_dead() == true, "死亡判定错误")
	print("  ✅ 敌人死亡判定测试通过")
	
	# 测试敌人血量重置
	enemy.reset_health()
	assert(enemy.current_health == enemy.max_health, "血量重置失败")
	print("  ✅ 敌人血量重置测试通过")
