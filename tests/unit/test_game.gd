extends GutTest

const TowerConfig = preload("res://scripts/logic/tower_defense/tower_config.gd")
const MapConfig = preload("res://scripts/logic/tower_defense/map_config.gd")
const GameHUD = preload("res://scripts/ui/game_hud.gd")
const Tower = preload("res://scripts/view/tower/tower.gd")
const PauseMenu = preload("res://scripts/ui/pause_menu.gd")
const EnemyConfig = preload("res://scripts/logic/tower_defense/enemy_config.gd")
const Enemy = preload("res://scripts/view/enemy/enemy.gd")

func before_all():
	var map_cfg = MapConfig.load_map("map_01")
	if map_cfg:
		EnemyConfig.set_map_config(map_cfg)
		map_cfg._cache_enemy_configs()

func test_tower_config_get_tower_types():
	var types = TowerConfig.get_tower_types()
	assert_eq(types.size(), 3, "Should have 3 tower types")
	assert_has(types, "basic", "Should have basic tower")
	assert_has(types, "archer", "Should have archer tower")
	assert_has(types, "magic", "Should have magic tower")

func test_tower_config_get_config_basic():
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	assert_eq(cfg.tower_name, "基础塔", "Basic tower name should be 基础塔")
	assert_eq(cfg.cost, 100, "Basic tower cost should be 100")
	assert_eq(cfg.damage, 10.0, "Basic tower damage should be 10")
	assert_eq(cfg.attack_range, 150.0, "Basic tower attack range should be 150")
	assert_eq(cfg.attack_speed, 1.0, "Basic tower attack speed should be 1.0")
	assert_eq(cfg.tower_level, 1, "Basic tower level should be 1")

func test_tower_config_get_config_archer():
	var cfg = TowerConfig.get_config("archer")
	assert_not_null(cfg, "Archer config should not be null")
	assert_eq(cfg.tower_name, "弓箭塔", "Archer tower name should be 弓箭塔")
	assert_eq(cfg.cost, 150, "Archer tower cost should be 150")
	assert_eq(cfg.damage, 15.0, "Archer tower damage should be 15")
	assert_eq(cfg.attack_range, 200.0, "Archer tower attack range should be 200")
	assert_eq(cfg.attack_speed, 1.5, "Archer tower attack speed should be 1.5")

func test_tower_config_get_config_magic():
	var cfg = TowerConfig.get_config("magic")
	assert_not_null(cfg, "Magic config should not be null")
	assert_eq(cfg.tower_name, "魔法塔", "Magic tower name should be 魔法塔")
	assert_eq(cfg.cost, 200, "Magic tower cost should be 200")
	assert_eq(cfg.damage, 25.0, "Magic tower damage should be 25")
	assert_eq(cfg.attack_range, 180.0, "Magic tower attack range should be 180")
	assert_eq(cfg.attack_speed, 0.8, "Magic tower attack speed should be 0.8")

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
	var cfg = TowerConfig.get_config("basic")
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

func test_game_hud_initial_state():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	assert_eq(hud.base_hp, 20, "Initial HP should be 20")
	assert_eq(hud.max_base_hp, 20, "Max HP should be 20")
	assert_eq(hud.gold, 500, "Initial gold should be 500")

func test_game_hud_can_afford():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	assert_true(hud.can_afford(100), "Should afford 100 gold")
	assert_true(hud.can_afford(500), "Should afford exactly 500 gold")
	assert_false(hud.can_afford(501), "Should not afford 501 gold")

func test_game_hud_spend_gold():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	var result = hud.spend_gold(100)
	assert_true(result, "Spend 100 should succeed")
	assert_eq(hud.gold, 400, "Gold should be 400 after spending 100")

func test_game_hud_spend_gold_insufficient():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	var result = hud.spend_gold(600)
	assert_false(result, "Spend 600 should fail")
	assert_eq(hud.gold, 500, "Gold should remain 500")

func test_game_hud_update_hp():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	hud.update_hp(10)
	assert_eq(hud.base_hp, 10, "HP should be 10")

func test_game_hud_update_hp_clamp():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	hud.update_hp(-5)
	assert_eq(hud.base_hp, 0, "HP should clamp to 0")
	hud.update_hp(100)
	assert_eq(hud.base_hp, 20, "HP should clamp to 20")

func test_game_hud_update_gold():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	hud.update_gold(1000)
	assert_eq(hud.gold, 1000, "Gold should be 1000")

func test_game_hud_signals():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	watch_signals(hud)
	hud.spend_gold(100)
	assert_signal_emitted(hud, "gold_changed", "gold_changed should emit on spend")
	hud.update_hp(15)
	assert_signal_emitted(hud, "hp_changed", "hp_changed should emit on update")

func test_tower_initialize():
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.initialize(cfg)
	assert_not_null(tower.config, "Tower config should be set")
	assert_eq(tower.config.tower_name, "基础塔", "Tower name should match config")

func test_tower_has_attack_component():
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.initialize(cfg)
	await wait_for_signal(tower.tree_entered, 1.0)
	var attack_comp = tower.get_node_or_null("TowerAttackComponent")
	assert_not_null(attack_comp, "Tower should have TowerAttackComponent child")

func test_pause_menu_initial_state():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	await wait_for_signal(menu.tree_entered, 1.0)
	assert_false(menu.is_paused, "Should not be paused initially")
	assert_false(menu.visible, "Should not be visible initially")

func test_pause_menu_toggle():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	await wait_for_signal(menu.tree_entered, 1.0)
	menu.pause_game()
	assert_true(menu.is_paused, "Should be paused after pause_game")
	assert_true(menu.visible, "Should be visible after pause_game")
	menu.resume_game()
	assert_false(menu.is_paused, "Should not be paused after resume_game")
	assert_false(menu.visible, "Should not be visible after resume_game")

func test_pause_menu_has_panel():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	await wait_for_signal(menu.tree_entered, 1.0)
	var panel = menu.get_node_or_null("Panel")
	assert_not_null(panel, "Pause menu should have a Panel child")
	if panel:
		assert_eq(int(panel.size.x), 600, "Panel width should be 600")
		assert_eq(int(panel.size.y), 450, "Panel height should be 450")

func test_pause_menu_has_background():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	await wait_for_signal(menu.tree_entered, 1.0)
	var bg = menu.get_node_or_null("Background")
	assert_not_null(bg, "Pause menu should have Background child")

func test_pause_menu_signal():
	var menu = PauseMenu.new()
	add_child_autofree(menu)
	await wait_for_signal(menu.tree_entered, 1.0)
	watch_signals(menu)
	menu.pause_game()
	assert_signal_emitted(menu, "pause_toggled", "pause_toggled should emit on pause_game")
	menu.resume_game()
	assert_signal_emitted(menu, "pause_toggled", "pause_toggled should emit on resume_game")

func test_enemy_config_get_enemy_types():
	var types = EnemyConfig.get_enemy_types()
	assert_eq(types.size(), 2, "Should have 2 enemy types")
	assert_has(types, "heavy_armor", "Should have heavy_armor enemy")
	assert_has(types, "magic_shield", "Should have magic_shield enemy")

func test_enemy_config_heavy_armor():
	var cfg = EnemyConfig.get_config("heavy_armor")
	assert_not_null(cfg, "Heavy armor config should not be null")
	assert_eq(cfg.enemy_name, "重甲怪", "Heavy armor name should be 重甲怪")
	assert_eq(cfg.max_health, 150.0, "Heavy armor HP should be 150")
	assert_eq(cfg.move_speed, 60.0, "Heavy armor speed should be 60")
	assert_eq(cfg.physical_resistance, 0.7, "Heavy armor physical resistance should be 0.7")
	assert_eq(cfg.magical_resistance, 0.1, "Heavy armor magical resistance should be 0.1")

func test_enemy_config_magic_shield():
	var cfg = EnemyConfig.get_config("magic_shield")
	assert_not_null(cfg, "Magic shield config should not be null")
	assert_eq(cfg.enemy_name, "魔法怪", "Magic shield name should be 魔法怪")
	assert_eq(cfg.max_health, 100.0, "Magic shield HP should be 100")
	assert_eq(cfg.move_speed, 100.0, "Magic shield speed should be 100")
	assert_eq(cfg.physical_resistance, 0.1, "Magic shield physical resistance should be 0.1")
	assert_eq(cfg.magical_resistance, 0.7, "Magic shield magical resistance should be 0.7")

func test_enemy_config_invalid():
	var cfg = EnemyConfig.get_config("nonexistent")
	assert_null(cfg, "Invalid enemy type should return null")

func test_enemy_initialize():
	var cfg = EnemyConfig.get_config("heavy_armor")
	assert_not_null(cfg, "Heavy armor config should not be null")
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	enemy.initialize(cfg)
	assert_not_null(enemy.config, "Enemy config should be set")
	assert_eq(enemy.current_health, 150.0, "Enemy HP should match config")

func test_enemy_take_damage_physical():
	var cfg = EnemyConfig.get_config("heavy_armor")
	assert_not_null(cfg, "Heavy armor config should not be null")
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	enemy.initialize(cfg)
	enemy.take_damage(100.0, GameConfig.DamageType.PHYSICAL)
	assert_eq(enemy.get_current_health(), 120.0, "Heavy armor should take 30 damage from 100 physical (70% resistance): 150 - 30 = 120")

func test_enemy_take_damage_magical():
	var cfg = EnemyConfig.get_config("heavy_armor")
	assert_not_null(cfg, "Heavy armor config should not be null")
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	enemy.initialize(cfg)
	enemy.take_damage(100.0, GameConfig.DamageType.MAGICAL)
	assert_eq(enemy.get_current_health(), 60.0, "Heavy armor should take 90 damage from 100 magical (10% resistance)")

func test_enemy_died_signal():
	var cfg = EnemyConfig.get_config("magic_shield")
	assert_not_null(cfg, "Magic shield config should not be null")
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	enemy.initialize(cfg)
	watch_signals(enemy)
	enemy.take_damage(1000.0, GameConfig.DamageType.PHYSICAL)
	assert_signal_emitted(enemy, "died", "died signal should emit on death")

func test_tower_config_damage_type():
	var cfg = TowerConfig.get_config("basic")
	assert_not_null(cfg, "Basic config should not be null")
	assert_eq(cfg.damage_type, 0, "Basic tower damage type should be 0 (physical)")

func test_damage_types_enum():
	assert_eq(GameConfig.DamageType.PHYSICAL, 0, "PHYSICAL should be 0")
	assert_eq(GameConfig.DamageType.MAGICAL, 1, "MAGICAL should be 1")

func test_enemy_config_has_texture():
	var heavy_cfg = EnemyConfig.get_config("heavy_armor")
	assert_not_null(heavy_cfg, "Heavy armor config should not be null")
	assert_ne(heavy_cfg.texture_path, "", "Heavy armor should have texture path")
	
	var magic_cfg = EnemyConfig.get_config("magic_shield")
	assert_not_null(magic_cfg, "Magic shield config should not be null")
	assert_ne(magic_cfg.texture_path, "", "Magic shield should have texture path")

func test_enemy_reached_base_signal():
	var cfg = EnemyConfig.get_config("magic_shield")
	assert_not_null(cfg, "Magic shield config should not be null")
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	enemy.initialize(cfg)
	watch_signals(enemy)
	var path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	enemy.set_path(path)
	enemy.current_path_index = 2
	enemy._process(0.1)
	assert_signal_emitted(enemy, "reached_base", "reached_base signal should emit when path completed")

func test_game_hud_update_hp_decrease():
	var hud = GameHUD.new()
	add_child_autofree(hud)
	await wait_for_signal(hud.tree_entered, 1.0)
	var initial_hp = hud.base_hp
	hud.update_hp(initial_hp - 1)
	assert_eq(hud.base_hp, initial_hp - 1, "HP should decrease by 1")
