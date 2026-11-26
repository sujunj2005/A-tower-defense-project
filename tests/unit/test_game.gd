extends GutTest

const TowerConfig = preload("res://scripts/logic/tower_defense/tower_config.gd")
const MapConfig = preload("res://scripts/logic/tower_defense/map_config.gd")
const GameHUD = preload("res://scripts/ui/game_hud.gd")
const Tower = preload("res://scripts/view/tower/tower.gd")
const PauseMenu = preload("res://scripts/ui/pause_menu.gd")
const EnemyConfig = preload("res://scripts/logic/tower_defense/enemy_config.gd")
const Enemy = preload("res://scripts/view/enemy/enemy.gd")

func _assert_tower_config(tower_id: String, attack_mode: int) -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/towers.json")
	var cfg := TowerConfig.get_config(tower_id)
	assert_not_null(cfg, "Tower %s should exist" % tower_id)
	if cfg == null:
		return
	for entry: Dictionary in data.towers:
		if entry.tower_id != tower_id:
			continue
		assert_eq(cfg.tower_name, str(entry.tower_name))
		assert_eq(cfg.cost, int(entry.cost.build_cost))
		assert_eq(cfg.damage, float(entry.stats.damage))
		assert_eq(cfg.attack_range, float(entry.stats.range))
		assert_eq(cfg.attack_speed, float(entry.stats.attack_speed))
		assert_eq(cfg.attack_mode, attack_mode)
		return
	fail_test("Missing tower in data: %s" % tower_id)

func _assert_enemy_config(enemy_id: String) -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/enemies.json")
	var cfg := EnemyConfig.get_config(enemy_id)
	assert_not_null(cfg, "Enemy %s should exist" % enemy_id)
	if cfg == null:
		return
	for entry: Dictionary in data.enemies:
		if entry.enemy_id != enemy_id:
			continue
		assert_eq(cfg.enemy_name, str(entry.enemy_name))
		assert_eq(cfg.max_health, float(entry.stats.health))
		assert_eq(cfg.move_speed, float(entry.stats.speed))
		return
	fail_test("Missing enemy in data: %s" % enemy_id)

func _add_enemy(physical_resistance: float = 0.0, magical_resistance: float = 0.0) -> Enemy:
	var cfg := EnemyConfig.get_config("enemy_homework")
	cfg.max_health = 150.0
	cfg.physical_resistance = physical_resistance
	cfg.magical_resistance = magical_resistance
	var enemy := Enemy.new()
	add_child_autofree(enemy)
	enemy.initialize(cfg)
	return enemy

func test_tower_config_get_tower_types():
	var data: Dictionary = ConfigManager.load_json("res://data/towers.json")
	var types: Array = TowerConfig.get_tower_types()
	assert_eq(types.size(), data.towers.size())
	for entry: Dictionary in data.towers:
		assert_has(types, entry.tower_id)

func test_tower_config_get_melee_tower():
	_assert_tower_config("tower_sports_basic", GameConfig.AttackMode.MELEE)

func test_tower_config_get_ranged_tower():
	_assert_tower_config("tower_chinese_basic", GameConfig.AttackMode.RANGED)

func test_tower_config_get_support_tower():
	_assert_tower_config("tower_time_advanced", GameConfig.AttackMode.NONE)

func test_tower_config_get_config_invalid():
	var cfg = TowerConfig.get_config("nonexistent")
	assert_null(cfg, "Invalid tower type should return null")

func test_tower_config_all_have_texture_paths():
	var types = TowerConfig.get_tower_types()
	for t in types:
		var cfg = TowerConfig.get_config(t)
		assert_not_null(cfg, "Config for %s should not be null" % t)
		assert_ne(cfg.texture_path, "", "Tower %s should have a texture path" % t)

func test_tower_config_is_resource():
	var cfg = TowerConfig.get_config("tower_sports_basic")
	assert_not_null(cfg, "Basic config should not be null")
	assert_true(cfg is Resource, "TowerConfig should extend Resource")

func test_map_config_registry():
	var ids = MapConfig.get_map_ids()
	assert_has(ids, "map_01", "Should have map_01 registered")

func test_map_config_load_map():
	var cfg = MapConfig.load_map("map_01")
	if cfg:
		assert_ne(cfg.map_name, "", "Map name should not be empty")
		assert_gt(cfg.map_width, 0, "Map width should be > 0")
		assert_gt(cfg.map_height, 0, "Map height should be > 0")
		assert_gt(cfg.tile_size, 0, "Tile size should be > 0")
		assert_gt(cfg.path_points.size(), 0, "Path points should not be empty")
		assert_gt(cfg.tower_positions.size(), 0, "Tower positions should not be empty")
	else:
		assert_true(false, "map_01 .tres file not found, cannot test map config loading")

func test_map_config_load_invalid_map():
	var cfg = MapConfig.load_map("nonexistent_map")
	assert_null(cfg, "Loading nonexistent map should return null")
	assert_push_error("Map ID 'nonexistent_map' not found in registry")

func test_game_hud_initial_state():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	assert_eq(hud.base_hp, 20, "Initial HP should be 20")
	assert_eq(hud.max_base_hp, 20, "Max HP should be 20")
	assert_eq(hud.gold, 500, "Initial gold should be 500")

func test_game_hud_can_afford():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	assert_true(hud.can_afford(100), "Should afford 100 gold")
	assert_true(hud.can_afford(500), "Should afford exactly 500 gold")
	assert_false(hud.can_afford(501), "Should not afford 501 gold")

func test_game_hud_spend_gold():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	var result = hud.spend_gold(100)
	assert_true(result, "Spend 100 should succeed")
	assert_eq(hud.gold, 400, "Gold should be 400 after spending 100")

func test_game_hud_spend_gold_insufficient():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	var result = hud.spend_gold(600)
	assert_false(result, "Spend 600 should fail")
	assert_eq(hud.gold, 500, "Gold should remain 500")

func test_game_hud_update_hp():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	hud.update_hp(10)
	assert_eq(hud.base_hp, 10, "HP should be 10")

func test_game_hud_update_hp_clamp():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	hud.update_hp(-5)
	assert_eq(hud.base_hp, 0, "HP should clamp to 0")
	hud.update_hp(100)
	assert_eq(hud.base_hp, 20, "HP should clamp to 20")

func test_game_hud_update_gold():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	hud.update_gold(1000)
	assert_eq(hud.gold, 1000, "Gold should be 1000")

func test_game_hud_signals():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	watch_signals(hud)
	hud.spend_gold(100)
	assert_signal_emitted(hud, "gold_changed", "gold_changed should emit on spend")
	hud.update_hp(15)
	assert_signal_emitted(hud, "hp_changed", "hp_changed should emit on update")

func test_tower_initialize():
	var cfg = TowerConfig.get_config("tower_sports_basic")
	assert_not_null(cfg, "Basic config should not be null")
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.initialize(cfg)
	assert_not_null(tower.config, "Tower config should be set")
	assert_eq(tower.config.tower_name, cfg.tower_name, "Tower name should match config")

func test_tower_has_attack_component():
	var cfg = TowerConfig.get_config("tower_sports_basic")
	assert_not_null(cfg, "Basic config should not be null")
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.initialize(cfg)
	var attack_comp = tower.attack_component
	assert_not_null(attack_comp, "Tower should have TowerAttackComponent child")
	if attack_comp:
		assert_same(attack_comp.get_parent(), tower)

func test_pause_menu_initial_state():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	assert_false(menu.is_paused, "Should not be paused initially")
	assert_false(menu.visible, "Should not be visible initially")

func test_pause_menu_toggle():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	menu.pause_game()
	assert_true(menu.is_paused, "Should be paused after pause_game")
	assert_true(menu.visible, "Should be visible after pause_game")
	menu.resume_game()
	assert_false(menu.is_paused, "Should not be paused after resume_game")
	assert_false(menu.visible, "Should not be visible after resume_game")

func test_pause_menu_has_panel():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	var panel = menu.get_node_or_null("Panel")
	assert_not_null(panel, "Pause menu should have a Panel child")
	if panel:
		assert_eq(int(panel.size.x), 600, "Panel width should be 600")
		assert_eq(int(panel.size.y), 450, "Panel height should be 450")

func test_pause_menu_has_background():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	var bg = menu.get_node_or_null("Background")
	assert_not_null(bg, "Pause menu should have Background child")

func test_pause_menu_signal():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	watch_signals(menu)
	menu.pause_game()
	assert_signal_emitted(menu, "pause_toggled", "pause_toggled should emit on pause_game")
	menu.resume_game()
	assert_signal_emitted(menu, "pause_toggled", "pause_toggled should emit on resume_game")

func test_enemy_config_get_enemy_types():
	var data: Dictionary = ConfigManager.load_json("res://data/enemies.json")
	var types: Array = EnemyConfig.get_enemy_types()
	for entry: Dictionary in data.enemies:
		assert_has(types, entry.enemy_id)

func test_enemy_config_loads_regular_enemy():
	_assert_enemy_config("enemy_homework")

func test_enemy_config_loads_boss():
	_assert_enemy_config("boss_final_judgment")

func test_enemy_config_invalid():
	var cfg = EnemyConfig.get_config("nonexistent")
	assert_null(cfg, "Invalid enemy type should return null")

func test_enemy_initialize():
	var enemy := _add_enemy()
	assert_eq(enemy.config.enemy_id, "enemy_homework")
	assert_eq(enemy.current_health, 150.0, "Enemy HP should match config")

func test_enemy_take_damage_physical():
	var enemy := _add_enemy(0.7, 0.1)
	enemy.take_damage(100.0, GameConfig.DamageType.PHYSICAL)
	assert_almost_eq(enemy.get_current_health(), 120.0, 0.001)

func test_enemy_take_damage_magical():
	var enemy := _add_enemy(0.7, 0.1)
	enemy.take_damage(100.0, GameConfig.DamageType.MAGICAL)
	assert_almost_eq(enemy.get_current_health(), 60.0, 0.001)

func test_enemy_died_signal():
	var enemy := _add_enemy()
	watch_signals(enemy)
	enemy.take_damage(1000.0, GameConfig.DamageType.PHYSICAL)
	assert_signal_emitted(enemy, "died", "died signal should emit on death")

func test_tower_config_damage_type():
	var cfg = TowerConfig.get_config("tower_sports_basic")
	assert_not_null(cfg, "Basic config should not be null")
	assert_eq(cfg.damage_type, GameConfig.DamageType.PHYSICAL)

func test_damage_types_enum():
	assert_eq(GameConfig.DamageType.PHYSICAL, 0, "PHYSICAL should be 0")
	assert_eq(GameConfig.DamageType.MAGICAL, 1, "MAGICAL should be 1")

func test_enemy_config_has_texture():
	for enemy_id: String in ["enemy_homework", "boss_final_judgment"]:
		var cfg := EnemyConfig.get_config(enemy_id)
		assert_not_null(cfg)
		if cfg:
			assert_true(ResourceLoader.exists(cfg.texture_path), "%s has an available texture" % enemy_id)

func test_enemy_reached_base_signal():
	var enemy := _add_enemy()
	watch_signals(enemy)
	var path: Array[Vector2] = [Vector2.ZERO, Vector2(100, 0)]
	enemy.set_path(path)
	enemy.current_path_index = enemy.path_points.size()
	enemy._process(0.1)
	assert_signal_emitted(enemy, "reached_base", "reached_base signal should emit when path completed")

func test_game_hud_update_hp_decrease():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	var initial_hp = hud.base_hp
	hud.update_hp(initial_hp - 1)
	assert_eq(hud.base_hp, initial_hp - 1, "HP should decrease by 1")
