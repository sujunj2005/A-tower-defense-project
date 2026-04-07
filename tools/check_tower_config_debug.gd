extends Node

func _ready():
	print("\n========== 验证防御塔资源配置 ==========\n")
	
	var tower_paths = {
		"basic": "res://resources/towers/basic_tower.tres",
		"archer": "res://resources/towers/archer_tower.tres",
		"magic": "res://resources/towers/magic_tower.tres"
	}
	
	for tower_type in tower_paths.keys():
		var path = tower_paths[tower_type]
		print("[%s] 配置检查：" % tower_type.to_upper())
		print("  路径：%s" % path)
		
		if not ResourceLoader.exists(path):
			print("  ❌ 文件不存在\n")
			continue
		
		var config = load(path) as TowerConfig
		if not config:
			print("  ❌ 无法加载为 TowerConfig\n")
			continue
		
		# 检查关键字段
		print("  tower_name: %s" % config.tower_name)
		print("  cost: %d %s" % [config.cost, "⚠️ 使用默认值" if config.cost == 100 and tower_type != "basic" else ""])
		print("  attack_mode: %d (%s) %s" % [
			config.attack_mode,
			"MELEE" if config.attack_mode == 0 else "RANGED",
			"⚠️ 使用默认值" if config.attack_mode == 0 and tower_type != "basic" else ""
		])
		print("  damage: %.1f" % config.damage)
		print("  projectile_scene_path: %s %s" % [
			config.projectile_scene_path if config.projectile_scene_path != "" else "(空)",
			"⚠️ 使用默认值" if config.projectile_scene_path == "" and config.attack_mode == 1 else ""
		])
		print("  projectile_scene: %s\n" % ("已加载" if config.projectile_scene else "null"))
	
	print("==========================================\n")
	get_tree().quit()
