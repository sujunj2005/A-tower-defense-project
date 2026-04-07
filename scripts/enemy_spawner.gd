extends Node
class_name EnemySpawner

signal enemy_reached_base(enemy: Enemy)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

var map_config: MapConfig
var map_manager
var spawn_timer: Timer
var start_delay_timer: Timer

var current_wave_index: int = 0
var current_enemy_index_in_wave: int = 0
var enemies_spawned_in_wave: int = 0
var total_enemies_in_current_wave: int = 0
var is_spawning: bool = false
var is_initialized: bool = false
var wave_in_progress: bool = false

func initialize(config: MapConfig, manager):
	map_config = config
	map_manager = manager
	EnemyConfig.set_map_config(map_config)
	is_initialized = true

func _ready():
	if not is_initialized:
		return
	setup_timers()

func setup_timers():
	start_delay_timer = Timer.new()
	start_delay_timer.wait_time = 5.0
	start_delay_timer.one_shot = true
	start_delay_timer.timeout.connect(_on_start_delay_finished)
	add_child(start_delay_timer)
	start_delay_timer.start()
	
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_start_delay_finished():
	start_next_wave()

func start_next_wave():
	if current_wave_index >= map_config.waves.size():
		all_waves_completed.emit()
		stop_spawning()
		return
	
	var wave = map_config.waves[current_wave_index]
	wave_started.emit(wave.wave_number)
	wave_in_progress = true
	enemies_spawned_in_wave = 0
	current_enemy_index_in_wave = 0
	total_enemies_in_current_wave = 0
	
	for enemy_config in wave.enemies:
		total_enemies_in_current_wave += enemy_config.count
	
	is_spawning = true
	
	if not spawn_timer.is_inside_tree():
		add_child(spawn_timer)
	
	spawn_timer.wait_time = wave.spawn_interval
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if not is_spawning:
		return
	
	var wave = map_config.waves[current_wave_index]
	
	# 每次生成一个敌人
	if enemies_spawned_in_wave < total_enemies_in_current_wave:
		var enemy_config = _get_next_single_enemy_to_spawn(wave)
		if enemy_config:
			spawn_enemy_from_config(enemy_config)
			enemies_spawned_in_wave += 1
		
		if enemies_spawned_in_wave >= total_enemies_in_current_wave:
			_complete_current_wave()

func _get_next_single_enemy_to_spawn(wave: WaveConfig) -> WaveEnemyConfig:
	# 按顺序生成敌人，每次返回一个敌人配置
	# 追踪全局已生成数量
	var global_spawned_count = 0
	
	for i in range(wave.enemies.size()):
		var enemy_entry = wave.enemies[i]
		
		# 如果当前索引还没到这个类型，跳过
		if i < current_enemy_index_in_wave:
			global_spawned_count += enemy_entry.count
			continue
		
		# 计算该类型已经生成了多少个
		var spawned_for_this_type = enemies_spawned_in_wave - global_spawned_count
		
		# 如果该类型还有未生成的，返回它
		if spawned_for_this_type < enemy_entry.count:
			current_enemy_index_in_wave = i
			return enemy_entry
		
		global_spawned_count += enemy_entry.count
	
	return null

func _complete_current_wave():
	var wave = map_config.waves[current_wave_index]
	wave_completed.emit(wave.wave_number)
	wave_in_progress = false
	
	spawn_timer.stop()
	
	current_enemy_index_in_wave = 0
	enemies_spawned_in_wave = 0
	
	await get_tree().create_timer(2.0).timeout
	
	current_wave_index += 1
	start_next_wave()

func spawn_enemy(enemy_type: String):
	var config = EnemyConfig.get_config(enemy_type)
	if not config:
		push_error("Failed to load enemy config: %s" % enemy_type)
		return
	
	var enemy = Enemy.new()
	enemy.initialize(config)
	
	var spawn_pos = Vector2(map_config.spawn_point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)
	enemy.position = spawn_pos
	
	var world_path: Array[Vector2] = []
	for point in map_config.path_points:
		var world_point = Vector2(point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)
		world_path.append(world_point)
	enemy.set_path(world_path)
	
	enemy.reached_base.connect(_on_enemy_reached_base)
	map_manager.add_child(enemy)

## 🆕 使用 WaveEnemyConfig 生成敌人
func spawn_enemy_from_config(wave_enemy_config: WaveEnemyConfig):
	var config = wave_enemy_config.get_enemy_config_value()
	if not config:
		push_error("Failed to load enemy config from WaveEnemyConfig")
		return
	
	var enemy = Enemy.new()
	enemy.initialize(config)
	
	var spawn_pos = Vector2(map_config.spawn_point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)
	enemy.position = spawn_pos
	
	var world_path: Array[Vector2] = []
	for point in map_config.path_points:
		var world_point = Vector2(point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)
		world_path.append(world_point)
	enemy.set_path(world_path)
	
	enemy.reached_base.connect(_on_enemy_reached_base)
	map_manager.add_child(enemy)

func _on_enemy_reached_base(enemy: Enemy):
	enemy_reached_base.emit(enemy)

func stop_spawning():
	is_spawning = false
	if spawn_timer:
		spawn_timer.stop()

func start_spawning():
	if not is_spawning:
		is_spawning = true
		if spawn_timer and not spawn_timer.is_inside_tree():
			add_child(spawn_timer)
		spawn_timer.start()
