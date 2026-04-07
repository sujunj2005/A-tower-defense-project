extends Node2D

const TowerConfig = preload("res://scripts/config/tower_config.gd")

func _ready():
	print("\n========== 防御塔攻击系统 V2.1 兼容性测试 ==========\n")
	
	# 测试塔配置文件加载
	test_tower_configs()
	
	# 测试攻击类型配置文件加载
	test_attack_types()
	
	# 测试攻击特效配置文件加载
	test_attack_effects()
	
	print("\n========== 兼容性测试完成 ==========\n")
	get_tree().quit()

func test_tower_configs():
	print("[测试] 测试塔配置文件加载...")
	
	# 获取所有塔类型
	var tower_types = TowerConfig.get_tower_types()
	print("[测试] 塔类型数量: %d" % tower_types.size())
	
	# 测试每个塔类型的配置加载
	for tower_type in tower_types:
		var config = TowerConfig.get_config(tower_type)
		if config:
			print("[测试] ✅ 加载成功: %s - %s" % [tower_type, config.tower_name])
			print("  攻击模式: %d" % config.attack_mode)
			print("  攻击范围: %.0f" % config.attack_range)
			print("  索敌范围: %.0f" % config.detection_range)
			print("  前摇时长: %.2f" % config.windup_duration)
			print("  弹道场景路径: %s" % config.projectile_scene_path)
			print("  弹道类型: %d" % config.projectile_type)
			print("  穿透启用: %s" % str(config.pierce_enabled))
			print("  特效类型: %d" % config.effect_type)
		else:
			print("[测试] ❌ 加载失败: %s" % tower_type)

func test_attack_types():
	print("\n[测试] 测试攻击类型配置文件加载...")
	
	try:
		const AttackMode = preload("res://scripts/config/attack_types.gd").AttackMode
		const ProjectileType = preload("res://scripts/config/attack_types.gd").ProjectileType
		print("[测试] ✅ 攻击类型配置文件加载成功")
		print("  AttackMode.MELEE: %d" % AttackMode.MELEE)
		print("  AttackMode.RANGED: %d" % AttackMode.RANGED)
		print("  ProjectileType.TARGET_LOCKED: %d" % ProjectileType.TARGET_LOCKED)
		print("  ProjectileType.POSITION_FIXED: %d" % ProjectileType.POSITION_FIXED)
	except:
		print("[测试] ❌ 攻击类型配置文件加载失败")

func test_attack_effects():
	print("\n[测试] 测试攻击特效配置文件加载...")
	
	try:
		const EffectType = preload("res://scripts/config/attack_effects.gd").EffectType
		print("[测试] ✅ 攻击特效配置文件加载成功")
		print("  EffectType.NONE: %d" % EffectType.NONE)
		print("  EffectType.PIERCE: %d" % EffectType.PIERCE)
		print("  EffectType.SPLASH: %d" % EffectType.SPLASH)
	except:
		print("[测试] ❌ 攻击特效配置文件加载失败")
