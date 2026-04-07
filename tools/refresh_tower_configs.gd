@tool
extends EditorScript

## 强制刷新所有防御塔资源配置
## 使用方法：在 Godot 编辑器中右键点击此脚本 -> 运行

func _run():
	print("\n========== 开始刷新防御塔资源配置 ==========")
	
	var tower_paths = [
		"res://resources/towers/basic_tower.tres",
		"res://resources/towers/archer_tower.tres",
		"res://resources/towers/magic_tower.tres"
	]
	
	for path in tower_paths:
		refresh_resource(path)
	
	print("========== 刷新完成 ==========\n")

func refresh_resource(path: String):
	print("处理：%s" % path)
	
	# 检查文件是否存在
	if not FileAccess.file_exists(path):
		push_error("文件不存在：%s" % path)
		return
	
	# 读取文件内容
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# 创建临时路径
	var temp_path = path + ".tmp_" + str(Time.get_unix_time_from_system())
	
	# 写入临时文件
	var temp_file = FileAccess.open(temp_path, FileAccess.WRITE)
	temp_file.store_string(content)
	temp_file.close()
	
	# 从临时文件加载资源（强制忽略缓存）
	var resource = ResourceLoader.load(temp_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	if resource:
		# 接管原始路径
		resource.take_over_path(path)
		
		# 删除临时文件
		DirAccess.remove_absolute(temp_path)
		
		# 重新保存资源
		var save_result = ResourceSaver.save(resource, path)
		
		if save_result == OK:
			print("  ✓ 成功刷新：%s" % path)
			print("    cost: %d" % resource.cost)
			print("    attack_mode: %d" % resource.attack_mode)
			print("    projectile_scene_path: %s" % resource.projectile_scene_path)
		else:
			push_error("  ✗ 保存失败：%s, 错误码：%d" % [path, save_result])
	else:
		push_error("  ✗ 加载失败：%s" % path)
		# 清理临时文件
		if FileAccess.file_exists(temp_path):
			DirAccess.remove_absolute(temp_path)
