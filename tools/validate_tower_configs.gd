@tool
extends EditorScript

## 验证所有 TowerConfig 资源的合法性
## 使用方法：右键点击此脚本 -> 运行

func _run():
	print("\n========== 验证防御塔资源配置 ==========")
	
	var tower_paths = [
		"res://resources/towers/basic_tower.tres",
		"res://resources/towers/archer_tower.tres",
		"res://resources/towers/magic_tower.tres"
	]
	
	var all_valid = true
	for path in tower_paths:
		if not validate_tower_config(path):
			all_valid = false
	
	if all_valid:
		print("\n✓ 所有资源配置验证通过")
	else:
		print("\n✗ 存在资源配置问题，请检查上述错误")
	print("==========================================\n")

func validate_tower_config(path: String) -> bool:
	print("\n验证：%s" % path)
	
	if not FileAccess.file_exists(path):
		push_error("  ✗ 文件不存在")
		return false
	
	var config = load(path) as TowerConfig
	if not config:
		push_error("  ✗ 无法加载为 TowerConfig")
		return false
	
	# 验证必要字段
	var valid = true
	
	if config.tower_name == "":
		push_error("  ✗ tower_name 为空")
		valid = false
	
	if config.cost <= 0:
		push_error("  ✗ cost 必须 > 0 (当前值：%d)" % config.cost)
		valid = false
	
	if config.damage <= 0:
		push_error("  ✗ damage 必须 > 0 (当前值：%.1f)" % config.damage)
		valid = false
	
	if config.attack_mode < 0 or config.attack_mode > 1:
		push_error("  ✗ attack_mode 必须是 0 或 1 (当前值：%d)" % config.attack_mode)
		valid = false
	
	# 验证远程塔的配置
	if config.attack_mode == 1:  # RANGED
		if config.projectile_scene_path == "":
			push_error("  ✗ 远程塔必须配置 projectile_scene_path")
			valid = false
		else:
			print("  ✓ projectile_scene_path: %s" % config.projectile_scene_path)
	
	# 打印配置摘要
	print("  ✓ tower_name: %s" % config.tower_name)
	print("  ✓ cost: %d" % config.cost)
	print("  ✓ damage: %.1f" % config.damage)
	print("  ✓ attack_mode: %d (%s)" % [
		config.attack_mode,
		"MELEE" if config.attack_mode == 0 else "RANGED"
	])
	
	return valid
