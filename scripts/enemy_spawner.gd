extends Node
class_name EnemySpawner

signal enemy_reached_base(enemy: Enemy)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

var map_config: MapConfig
var map_manager: Node2D
var spawn_timer: Timer
var start_delay_timer: Timer

var current_wave_index: int = 0
var current_enemy_index_in_wave: int = 0
var enemies_spawned_in_wave: int = 0
var total_enemies_in_current_wave: int = 0
var is_spawning: bool = false
var is_initialized: bool = false
var wave_in_progress: bool = false

func initialize(map_config_param: MapConfig, map_manager_node: Node2D) -> void:
	map_config = map_config_param
	map_manager = map_manager_node
	EnemyConfig.set_map_config(map_config)
	is_initialized = true

func _ready() -> void:
	if not is_initialized:
		return
	setup_timers()

func setup_timers() -> void:
	start_delay_timer = Timer.new()
	start_delay_timer.wait_time = 5.0
	start_delay_timer.one_shot = true
	start_delay_timer.timeout.connect(_on_start_delay_finished)
	add_child(start_delay_timer)
	start_delay_timer.start()

	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_start_delay_finished() -> void:
	start_next_wave()

func start_next_wave() -> void:
	if current_wave_index >= map_config.waves.size():
		all_waves_completed.emit()
		stop_spawning()
		return

	var wave: WaveConfig = map_config.waves[current_wave_index]
	wave_started.emit(wave.wave_number)
	wave_in_progress = true
	enemies_spawned_in_wave = 0
	current_enemy_index_in_wave = 0
	total_enemies_in_current_wave = 0

	for enemy_config: WaveEnemyConfig in wave.enemies:
		total_enemies_in_current_wave += enemy_config.count

	is_spawning = true

	if not spawn_timer.is_inside_tree():
		add_child(spawn_timer)

	spawn_timer.wait_time = wave.spawn_interval
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if not is_spawning:
		return

	var wave: WaveConfig = map_config.waves[current_wave_index]

	if enemies_spawned_in_wave < total_enemies_in_current_wave:
		var enemy_config: WaveEnemyConfig = _get_next_single_enemy_to_spawn(wave)
		if enemy_config:
			spawn_enemy_from_config(enemy_config)
			enemies_spawned_in_wave += 1

		if enemies_spawned_in_wave >= total_enemies_in_current_wave:
			_complete_current_wave()

func _get_next_single_enemy_to_spawn(wave: WaveConfig) -> WaveEnemyConfig:
	var global_spawned_count: int = 0

	for i: int in range(wave.enemies.size()):
		var enemy_entry: WaveEnemyConfig = wave.enemies[i]

		if i < current_enemy_index_in_wave:
			global_spawned_count += enemy_entry.count
			continue

		var spawned_for_this_type: int = enemies_spawned_in_wave - global_spawned_count

		if spawned_for_this_type < enemy_entry.count:
			current_enemy_index_in_wave = i
			return enemy_entry

		global_spawned_count += enemy_entry.count

	return null

func _complete_current_wave() -> void:
	var wave: WaveConfig = map_config.waves[current_wave_index]
	wave_completed.emit(wave.wave_number)
	wave_in_progress = false

	spawn_timer.stop()

	current_enemy_index_in_wave = 0
	enemies_spawned_in_wave = 0

	await get_tree().create_timer(2.0).timeout

	current_wave_index += 1
	start_next_wave()

func spawn_enemy(enemy_type: String) -> void:
	var enemy_cfg: EnemyConfig = EnemyConfig.get_config(enemy_type)
	if not enemy_cfg:
		push_error("Failed to load enemy config: %s" % enemy_type)
		return

	var enemy: Enemy = Enemy.new()
	enemy.initialize(enemy_cfg)

	var spawn_pos: Vector2 = _calculate_spawn_position()
	enemy.position = spawn_pos

	var world_path: Array[Vector2] = _calculate_world_path()
	enemy.set_path(world_path)

	enemy.reached_base.connect(_on_enemy_reached_base)
	map_manager.add_child(enemy)

func spawn_enemy_from_config(wave_enemy_config: WaveEnemyConfig) -> void:
	var enemy_cfg: EnemyConfig = wave_enemy_config.get_enemy_config_value()
	if not enemy_cfg:
		push_error("Failed to load enemy config from WaveEnemyConfig")
		return

	var enemy: Enemy = Enemy.new()
	enemy.initialize(enemy_cfg)

	var spawn_pos: Vector2 = _calculate_spawn_position()
	enemy.position = spawn_pos

	var world_path: Array[Vector2] = _calculate_world_path()
	enemy.set_path(world_path)

	enemy.reached_base.connect(_on_enemy_reached_base)
	map_manager.add_child(enemy)

func _calculate_spawn_position() -> Vector2:
	return Vector2(map_config.spawn_point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)

func _calculate_world_path() -> Array[Vector2]:
	var world_path: Array[Vector2] = []
	for point: Vector2i in map_config.path_points:
		var world_point: Vector2 = Vector2(point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)
		world_path.append(world_point)
	return world_path

func _on_enemy_reached_base(enemy: Enemy) -> void:
	enemy_reached_base.emit(enemy)

func stop_spawning() -> void:
	is_spawning = false
	if spawn_timer:
		spawn_timer.stop()

func start_spawning() -> void:
	if not is_spawning:
		is_spawning = true
		if spawn_timer and not spawn_timer.is_inside_tree():
			add_child(spawn_timer)
		spawn_timer.start()
