extends GutTest

const TowerConfig = preload("res://scripts/config/tower_config.gd")
const Tower = preload("res://scripts/tower.gd")
const TowerAttackComponent = preload("res://scripts/components/tower_attack_component.gd")
const Projectile = preload("res://scripts/components/projectile.gd")
const AttackMode = preload("res://scripts/config/attack_types.gd").AttackMode
const ProjectileType = preload("res://scripts/config/attack_types.gd").ProjectileType
const EffectType = preload("res://scripts/config/attack_effects.gd").EffectType
const DetectionState = preload("res://scripts/config/detection_states.gd").DetectionState
const WindupState = preload("res://scripts/config/detection_states.gd").WindupState
const DamageTypes = preload("res://scripts/damage_types.gd")

# 模拟敌人节点
class MockEnemy extends Node2D:
	var current_health: float = 100.0
	var config = {}
	
	func initialize(cfg):
		config = cfg
		current_health = cfg.max_health
		add_to_group("enemies")
	
	func take_damage(amount: float, damage_type: int):
		current_health -= amount
		print("[MockEnemy] 受到 %.0f 点伤害，剩余生命值: %.0f" % [amount, current_health])
		if current_health <= 0:
			died.emit()
	
	signal died
	signal reached_base

func test_tower_attack_component_initialization():
	"""测试塔攻击组件初始化"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	assert_not_null(tower.attack_component, "Tower should have attack component")
	assert_eq(tower.attack_component.config, cfg, "Attack component config should match tower config")
	assert_eq(tower.attack_component.tower, tower, "Attack component should reference the tower")

func test_windup_mechanism():
	"""测试前摇机制"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("magic")
	assert_not_null(cfg, "Magic config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	var attack_comp = tower.attack_component
	assert_not_null(attack_comp, "Attack component should exist")
	
	# 测试前摇状态初始化
	assert_eq(attack_comp.windup_state, WindupState.IDLE, "Initial windup state should be IDLE")
	
	# 创建模拟敌人
	var enemy = MockEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = tower.global_position + Vector2(100, 0)
	enemy.initialize({"max_health": 100.0})
	
	# 设置目标
	attack_comp.target = enemy
	
	# 测试前摇开始
	attack_comp.start_windup()
	assert_eq(attack_comp.windup_state, WindupState.WINDUP_ACTIVE, "Windup state should be WINDUP_ACTIVE after start")
	assert_not_null(attack_comp.committed_target, "Committed target should be set")

func test_melee_attack():
	"""测试近战攻击"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	var attack_comp = tower.attack_component
	assert_not_null(attack_comp, "Attack component should exist")
	assert_eq(cfg.attack_mode, AttackMode.MELEE, "Basic tower should use MELEE attack mode")
	
	# 创建模拟敌人
	var enemy = MockEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = tower.global_position + Vector2(50, 0)
	enemy.initialize({"max_health": 100.0})
	
	# 保存初始生命值
	var initial_health = enemy.current_health
	
	# 执行近战攻击
	attack_comp.target = enemy
	attack_comp.execute_attack()
	
	# 验证伤害
	assert_lt(enemy.current_health, initial_health, "Enemy health should decrease after attack")
	assert_eq(enemy.current_health, initial_health - cfg.damage, "Enemy health should decrease by tower damage")

func test_ranged_attack():
	"""测试远程攻击"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("archer")
	assert_not_null(cfg, "Archer config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	var attack_comp = tower.attack_component
	assert_not_null(attack_comp, "Attack component should exist")
	assert_eq(cfg.attack_mode, AttackMode.RANGED, "Archer tower should use RANGED attack mode")
	
	# 创建模拟敌人
	var enemy = MockEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = tower.global_position + Vector2(150, 0)
	enemy.initialize({"max_health": 100.0})
	
	# 执行远程攻击
	attack_comp.target = enemy
	attack_comp.execute_attack()
	
	# 验证弹道是否创建（通过检查场景树中的Projectile节点）
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	assert_gt(projectiles.size(), 0, "Ranged attack should create projectile")

func test_projectile_types():
	"""测试弹道类型"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	# 测试弓箭塔（POSITION_FIXED）
	var archer_cfg = TowerConfig.get_config("archer")
	assert_not_null(archer_cfg, "Archer config should not be null")
	assert_eq(archer_cfg.projectile_type, ProjectileType.POSITION_FIXED, "Archer tower should use POSITION_FIXED projectile")
	
	# 测试魔法塔（TARGET_LOCKED）
	var magic_cfg = TowerConfig.get_config("magic")
	assert_not_null(magic_cfg, "Magic config should not be null")
	assert_eq(magic_cfg.projectile_type, ProjectileType.TARGET_LOCKED, "Magic tower should use TARGET_LOCKED projectile")

func test_pierce_system():
	"""测试穿透系统"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("archer")
	assert_not_null(cfg, "Archer config should not be null")
	assert_true(cfg.pierce_enabled, "Archer tower should have pierce enabled")
	assert_gt(cfg.pierce_count, 1, "Archer tower should have pierce count > 1")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	# 创建多个模拟敌人
	var enemies = []
	for i in range(3):
		var enemy = MockEnemy.new()
		add_child_autofree(enemy)
		enemy.global_position = tower.global_position + Vector2(100 + i * 50, 0)
		enemy.initialize({"max_health": 100.0})
		enemies.append(enemy)
	
	# 执行远程攻击
	var attack_comp = tower.attack_component
	attack_comp.target = enemies[0]
	attack_comp.execute_attack()
	
	# 验证穿透效果（通过日志或信号）
	# 这里我们通过检查是否创建了弹道来验证
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	assert_gt(projectiles.size(), 0, "Pierce attack should create projectile")

func test_splash_effect():
	"""测试AOE爆炸特效"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("magic")
	assert_not_null(cfg, "Magic config should not be null")
	assert_eq(cfg.effect_type, EffectType.SPLASH, "Magic tower should have SPLASH effect")
	assert_gt(cfg.effect_radius, 0, "Magic tower should have effect radius > 0")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	# 创建主目标和周围敌人
	var main_enemy = MockEnemy.new()
	add_child_autofree(main_enemy)
	main_enemy.global_position = tower.global_position + Vector2(150, 0)
	main_enemy.initialize({"max_health": 100.0})
	
	var nearby_enemy = MockEnemy.new()
	add_child_autofree(nearby_enemy)
	nearby_enemy.global_position = main_enemy.global_position + Vector2(30, 30)
	nearby_enemy.initialize({"max_health": 100.0})
	
	# 保存初始生命值
	var main_initial_health = main_enemy.current_health
	var nearby_initial_health = nearby_enemy.current_health
	
	# 执行攻击
	var attack_comp = tower.attack_component
	attack_comp.target = main_enemy
	attack_comp.execute_attack()
	
	# 验证主目标和周围敌人都受到伤害
	assert_lt(main_enemy.current_health, main_initial_health, "Main target should take damage")
	assert_lt(nearby_enemy.current_health, nearby_initial_health, "Nearby enemy should take splash damage")

func test_attack_range_validation():
	"""测试攻击范围验证"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	var attack_comp = tower.attack_component
	assert_not_null(attack_comp, "Attack component should exist")
	
	# 创建超出攻击范围的敌人
	var distant_enemy = MockEnemy.new()
	add_child_autofree(distant_enemy)
	distant_enemy.global_position = tower.global_position + Vector2(cfg.attack_range + 100, 0)
	distant_enemy.initialize({"max_health": 100.0})
	
	# 保存初始生命值
	var initial_health = distant_enemy.current_health
	
	# 尝试攻击超出范围的敌人
	attack_comp.target = distant_enemy
	attack_comp.execute_attack()
	
	# 验证敌人没有受到伤害
	assert_eq(distant_enemy.current_health, initial_health, "Enemy outside attack range should not take damage")

func test_target_death_during_windup():
	"""测试前摇期间目标死亡的情况"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("magic")
	assert_not_null(cfg, "Magic config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	var attack_comp = tower.attack_component
	assert_not_null(attack_comp, "Attack component should exist")
	
	# 创建模拟敌人
	var enemy = MockEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = tower.global_position + Vector2(100, 0)
	enemy.initialize({"max_health": 100.0})
	
	# 开始前摇
	attack_comp.target = enemy
	attack_comp.start_windup()
	assert_eq(attack_comp.windup_state, WindupState.WINDUP_ACTIVE, "Windup should be active")
	
	# 模拟敌人死亡
	enemy.queue_free()
	
	# 等待一帧，让前摇系统检测到目标死亡
	await get_tree().process_frame
	
	# 验证前摇被取消
	assert_eq(attack_comp.windup_state, WindupState.IDLE, "Windup should be cancelled when target dies")
	assert_null(attack_comp.committed_target, "Committed target should be null")

func test_projectile_lifetime():
	"""测试弹道生命周期"""
	var tower = Tower.new()
	add_child_autofree(tower)
	
	var cfg = TowerConfig.get_config("archer")
	assert_not_null(cfg, "Archer config should not be null")
	
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	
	# 创建模拟敌人
	var enemy = MockEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = tower.global_position + Vector2(150, 0)
	enemy.initialize({"max_health": 100.0})
	
	# 执行远程攻击
	var attack_comp = tower.attack_component
	attack_comp.target = enemy
	attack_comp.execute_attack()
	
	# 验证弹道存在
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	assert_gt(projectiles.size(), 0, "Projectile should be created")
	
	# 模拟弹道命中目标
	for projectile in projectiles:
		if projectile is Projectile:
			projectile.on_hit_target(enemy)
			break
	
	# 等待一帧，让弹道销毁
	await get_tree().process_frame
	
	# 验证弹道已销毁
	var remaining_projectiles = get_tree().get_nodes_in_group("projectiles")
	assert_eq(remaining_projectiles.size(), 0, "Projectile should be destroyed after hitting target")
