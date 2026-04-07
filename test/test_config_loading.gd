extends Node2D

func _ready():
	print("\n========== 配置文件加载测试 ==========\n")
	
	# 测试加载 TowerConfig
	print("[测试] 测试加载 TowerConfig 脚本...")
	var tower_config_script = load("res://scripts/config/tower_config.gd")
	if tower_config_script:
		print("[测试] ✅ TowerConfig 脚本加载成功")
	else:
		print("[测试] ❌ TowerConfig 脚本加载失败")
	
	# 测试加载 attack_types.gd
	print("\n[测试] 测试加载 attack_types.gd 脚本...")
	var attack_types_script = load("res://scripts/config/attack_types.gd")
	if attack_types_script:
		print("[测试] ✅ attack_types.gd 脚本加载成功")
	else:
		print("[测试] ❌ attack_types.gd 脚本加载失败")
	
	# 测试加载 attack_effects.gd
	print("\n[测试] 测试加载 attack_effects.gd 脚本...")
	var attack_effects_script = load("res://scripts/config/attack_effects.gd")
	if attack_effects_script:
		print("[测试] ✅ attack_effects.gd 脚本加载成功")
	else:
		print("[测试] ❌ attack_effects.gd 脚本加载失败")
	
	# 测试加载配置文件
	print("\n[测试] 测试加载配置文件...")
	var archer_config = load("res://resources/towers/archer_tower.tres")
	if archer_config:
		print("[测试] ✅ 弓箭塔配置文件加载成功")
		print("  塔名: %s" % archer_config.tower_name)
		print("  攻击模式: %d" % archer_config.attack_mode)
		print("  攻击范围: %.0f" % archer_config.attack_range)
		print("  前摇时长: %.2f" % archer_config.windup_duration)
		print("  弹道场景路径: %s" % archer_config.projectile_scene_path)
		print("  弹道类型: %d" % archer_config.projectile_type)
		print("  穿透启用: %s" % str(archer_config.pierce_enabled))
		print("  特效类型: %d" % archer_config.effect_type)
	else:
		print("[测试] ❌ 弓箭塔配置文件加载失败")
	
	print("\n========== 配置文件加载测试完成 ==========\n")
	get_tree().quit()
