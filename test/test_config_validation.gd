extends SceneTree

const MapConfig = preload("res://scripts/config/map_config.gd")
const EnemyConfig = preload("res://scripts/config/enemy_config.gd")
const WaveConfig = preload("res://scripts/config/wave_config.gd")
const WaveEnemyConfig = preload("res://scripts/config/wave_enemy_config.gd")

func _init():
	print("\n========== 配置系统验证测试 ==========\n")
	
	test_map_config_loading()
	test_enemy_registry_cache()
	test_wave_configuration()
	test_enemy_config_access()
	
	print("\n========== 测试完成 ==========\n")
	quit()

func test_map_config_loading():
	print("[TEST] MapConfig 加载测试")
	var map_cfg = MapConfig.load_map("map_01")
	
	if map_cfg == null:
		print("  ❌ 失败: 无法加载 map_01")
		return
	
	print("  ✅ 地图名称:", map_cfg.map_name)
	print("  ✅ 地图尺寸:", map_cfg.map_width, "x", map_cfg.map_height)
	print("  ✅ 瓦片大小:", map_cfg.tile_size)
	print("  ✅ 路径点数量:", map_cfg.path_points.size())
	print("  ✅ 塔位置数量:", map_cfg.tower_positions.size())
	print("  ✅ 波次数量:", map_cfg.waves.size())
	print("  ✅ 敌人注册表大小:", map_cfg.enemy_registry.size())

func test_enemy_registry_cache():
	print("\n[TEST] 敌人注册表缓存测试")
	var map_cfg = MapConfig.load_map("map_01")
	if not map_cfg:
		print("  ❌ 失败: 无法加载地图配置")
		return
	
	map_cfg._cache_enemy_configs()
	
	for enemy_id in map_cfg._enemy_cache.keys():
		var cfg = map_cfg.get_cached_enemy_config(enemy_id)
		if cfg:
			print("  ✅ 缓存成功:", enemy_id, "-", cfg.enemy_name, "(HP:", cfg.max_health, ")")
		else:
			print("  ❌ 缓存失败:", enemy_id)

func test_wave_configuration():
	print("\n[TEST] 波次配置测试")
	var map_cfg = MapConfig.load_map("map_01")
	if not map_cfg:
		print("  ❌ 失败: 无法加载地图配置")
		return
	
	for i in range(map_cfg.waves.size()):
		var wave: WaveConfig = map_cfg.waves[i]
		print("  ✅ 波次", wave.wave_number, ":", wave.wave_name)
		print("     - 延迟:", wave.start_delay, "秒")
		print("     - 生成间隔:", wave.spawn_interval, "秒")
		print("     - 敌人类型数:", wave.enemies.size())
		
		for enemy_entry in wave.enemies:
			print("       →", enemy_entry.enemy_type, "x", enemy_entry.count)

func test_enemy_config_access():
	print("\n[TEST] EnemyConfig 访问测试（通过缓存）")
	var map_cfg = MapConfig.load_map("map_01")
	if not map_cfg:
		print("  ❌ 失败: 无法加载地图配置")
		return
	
	EnemyConfig.set_map_config(map_cfg)
	
	var heavy_cfg = EnemyConfig.get_config("heavy_armor")
	if heavy_cfg:
		print("  ✅ 重甲怪配置:")
		print("     - 名称:", heavy_cfg.enemy_name)
		print("     - HP:", heavy_cfg.max_health)
		print("     - 速度:", heavy_cfg.move_speed)
		print("     - 物理抗性:", heavy_cfg.physical_resistance)
		print("     - 魔法抗性:", heavy_cfg.magical_resistance)
	else:
		print("  ❌ 无法获取重甲怪配置")
	
	var magic_cfg = EnemyConfig.get_config("magic_shield")
	if magic_cfg:
		print("  ✅ 魔法怪配置:")
		print("     - 名称:", magic_cfg.enemy_name)
		print("     - HP:", magic_cfg.max_health)
		print("     - 速度:", magic_cfg.move_speed)
		print("     - 物理抗性:", magic_cfg.physical_resistance)
		print("     - 魔法抗性:", magic_cfg.magical_resistance)
	else:
		print("  ❌ 无法获取魔法怪配置")
	
	var invalid_cfg = EnemyConfig.get_config("nonexistent")
	if invalid_cfg == null:
		print("  ✅ 无效敌人类型返回 null (正确)")
	else:
		print("  ❌ 无效敌人类型应返回 null")
