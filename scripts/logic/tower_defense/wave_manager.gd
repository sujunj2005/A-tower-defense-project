extends Node

signal wave_started(wave_number: int, total_waves: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()
signal boss_wave_started(boss_id: String)
signal enemy_spawn_requested(enemy_id: String)
signal survival_wave_started(wave_number: int)
signal summon_button_requested(show: bool, countdown: float, is_first_wave: bool)

enum WaveMode {STANDARD, SURVIVAL, EVENT}

const WAVE_DELAY_SECONDS: float = 2.0
const SUMMON_COUNTDOWN_SECONDS: float = 20.0

var current_mode: WaveMode = WaveMode.STANDARD
var current_wave: int = 0
var total_waves: int = 10
var is_active: bool = false
var is_boss_wave: bool = false

var _stage_config: Dictionary = {}
var _enemy_pool: Array[Dictionary] = []
var _difficulty_multiplier: float = 1.0
var _gold_multiplier: float = 1.0
var _enemies_alive: int = 0
var _enemies_spawned: int = 0
var _enemies_to_spawn: int = 0
var _spawn_timer: Timer
var _wave_delay_timer: Timer
var _survival_wave_count: int = 0
var _event_waves: Array[Dictionary] = []
var _current_wave_enemy_queue: Array[Dictionary] = []
var _current_spawn_interval: float = 1.5
var _waiting_for_summon: bool = false
var _summon_countdown: float = 0.0
var _is_first_wave: bool = true
var _pending_show_summon: bool = false

func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)

	_wave_delay_timer = Timer.new()
	_wave_delay_timer.one_shot = true
	_wave_delay_timer.timeout.connect(_on_wave_delay_timeout)
	add_child(_wave_delay_timer)

func _process(delta: float) -> void:
	if Global.soft_paused:
		return
	if _pending_show_summon:
		_pending_show_summon = false
		_show_summon_button()
	if _waiting_for_summon and not _is_first_wave:
		_summon_countdown -= delta
		if _summon_countdown <= 0.0:
			force_start_next_wave()
	if _wave_delay_timer.time_left > 0.0:
		var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
		if enemies.is_empty():
			_wave_delay_timer.stop()
			_on_wave_delay_timeout()

func start_battle(stage_config: Dictionary, mode: WaveMode = WaveMode.STANDARD) -> void:
	_stage_config = stage_config
	var raw_pool: Array = stage_config.get("enemy_pool", [])
	_enemy_pool.clear()
	for item: Dictionary in raw_pool:
		_enemy_pool.append(item)
	_difficulty_multiplier = float(stage_config.get("battle_difficulty", 1.0))
	_gold_multiplier = float(stage_config.get("gold_multiplier", 1.0))
	current_mode = mode
	current_wave = 0
	is_active = true
	_survival_wave_count = 0
	_event_waves.clear()
	_waiting_for_summon = false
	_summon_countdown = 0.0
	_is_first_wave = true

	if mode == WaveMode.STANDARD:
		total_waves = 10
	elif mode == WaveMode.EVENT:
		total_waves = _event_waves.size()
	else:
		total_waves = -1

	_show_summon_button()

func start_event_battle(waves: Array[Dictionary], extra_waves: int = 0) -> void:
	_event_waves.clear()
	for wave_data: Dictionary in waves:
		_event_waves.append(wave_data)
	for i: int in range(extra_waves):
		if not _event_waves.is_empty():
			_event_waves.append(_event_waves[-1].duplicate(true))
	current_mode = WaveMode.EVENT
	current_wave = 0
	total_waves = _event_waves.size()
	is_active = true
	is_boss_wave = false
	_enemy_pool.clear()
	_difficulty_multiplier = 1.0
	_gold_multiplier = 1.0
	_waiting_for_summon = false
	_summon_countdown = 0.0
	_is_first_wave = true
	_show_summon_button()

func _show_summon_button() -> void:
	_waiting_for_summon = true
	if _is_first_wave:
		_summon_countdown = 0.0
		summon_button_requested.emit(true, 0.0, true)
	else:
		_summon_countdown = SUMMON_COUNTDOWN_SECONDS
		summon_button_requested.emit(true, _summon_countdown, false)

func _hide_summon_button() -> void:
	_waiting_for_summon = false
	_summon_countdown = 0.0
	summon_button_requested.emit(false, 0.0, false)

func force_start_next_wave() -> void:
	if not _waiting_for_summon:
		return
	_hide_summon_button()
	start_next_wave()

func start_next_wave() -> void:
	if not is_active:
		return

	current_wave += 1

	if current_mode == WaveMode.STANDARD and current_wave > total_waves:
		all_waves_completed.emit()
		is_active = false
		return

	if current_mode == WaveMode.EVENT and current_wave > total_waves:
		all_waves_completed.emit()
		is_active = false
		return

	if current_mode == WaveMode.SURVIVAL:
		_survival_wave_count += 1
		survival_wave_started.emit(_survival_wave_count)

	is_boss_wave = false
	if current_mode == WaveMode.STANDARD and current_wave == total_waves:
		is_boss_wave = true
	if current_mode == WaveMode.EVENT and current_wave == total_waves:
		var last_wave: Dictionary = _event_waves[total_waves - 1] if total_waves > 0 else {}
		var enemies: Array = last_wave.get("enemies", [])
		for e: Dictionary in enemies:
			if e.get("id", "").begins_with("boss_"):
				is_boss_wave = true
				break

	if current_mode == WaveMode.EVENT:
		_start_event_wave()
	elif is_boss_wave:
		_start_boss_wave()
	else:
		_start_normal_wave()

	wave_started.emit(current_wave, total_waves if current_mode != WaveMode.SURVIVAL else -1)

func _start_normal_wave() -> void:
	var base_count: int = _get_base_enemy_count()
	var scaled_count: int = int(float(base_count) * _get_wave_difficulty())
	_enemies_to_spawn = maxi(scaled_count, 1)
	_enemies_spawned = 0
	_enemies_alive = _enemies_to_spawn

	var spawn_interval: float = _get_spawn_interval()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.start()

func _start_boss_wave() -> void:
	var boss_id: String = _get_boss_id()
	if boss_id != "":
		boss_wave_started.emit(boss_id)

	var boss_plus_minions: int = 1 + int(float(current_wave) * 0.5)
	_enemies_to_spawn = boss_plus_minions
	_enemies_spawned = 0
	_enemies_alive = _enemies_to_spawn

	_spawn_timer.wait_time = 2.0
	_spawn_timer.start()

func _start_event_wave() -> void:
	var wave_index: int = current_wave - 1
	if wave_index < 0 or wave_index >= _event_waves.size():
		return
	var wave_data: Dictionary = _event_waves[wave_index]
	_current_wave_enemy_queue.clear()
	var enemies: Array = wave_data.get("enemies", [])
	for enemy_entry: Dictionary in enemies:
		var eid: String = enemy_entry.get("id", "enemy_homework")
		var count: int = int(enemy_entry.get("count", 1))
		for _i: int in range(count):
			_current_wave_enemy_queue.append({"id": eid})
	_current_spawn_interval = float(wave_data.get("spawn_interval", 1.5))
	_enemies_to_spawn = _current_wave_enemy_queue.size()
	_enemies_spawned = 0
	_enemies_alive = _enemies_to_spawn
	_spawn_timer.wait_time = _current_spawn_interval
	_spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if Global.soft_paused:
		return
	if _enemies_spawned >= _enemies_to_spawn:
		_spawn_timer.stop()
		_on_all_enemies_spawned()
		return

	var enemy_id: String = ""
	if current_mode == WaveMode.EVENT and not _current_wave_enemy_queue.is_empty():
		var entry: Dictionary = _current_wave_enemy_queue.pop_front()
		enemy_id = entry.get("id", "enemy_homework")
	elif is_boss_wave and _enemies_spawned == 0:
		enemy_id = _get_boss_id()
		if enemy_id == "":
			enemy_id = _pick_enemy_from_pool()
	else:
		enemy_id = _pick_enemy_from_pool()

	_spawn_single_enemy(enemy_id)
	_enemies_spawned += 1

func _on_all_enemies_spawned() -> void:
	_is_first_wave = false
	if current_wave >= total_waves:
		return
	_wave_delay_timer.wait_time = WAVE_DELAY_SECONDS
	_wave_delay_timer.start()

func _spawn_single_enemy(enemy_id: String) -> void:
	enemy_spawn_requested.emit(enemy_id)

func _on_enemy_reached_base(_enemy: Enemy) -> void:
	_enemies_alive -= 1
	_check_wave_complete()

func _on_enemy_died(_enemy: Enemy) -> void:
	_enemies_alive -= 1
	_check_wave_complete()

func _check_wave_complete() -> void:
	if _enemies_spawned >= _enemies_to_spawn and _enemies_alive <= 0:
		_apply_gold_per_wave()
		wave_completed.emit(current_wave)
		if current_wave >= total_waves:
			all_waves_completed.emit()
			is_active = false

func _on_wave_delay_timeout() -> void:
	if Global.soft_paused:
		_pending_show_summon = true
		return
	_show_summon_button()

func _pick_enemy_from_pool() -> String:
	if _enemy_pool.is_empty():
		return "enemy_homework"

	var total_weight: int = 0
	for entry: Dictionary in _enemy_pool:
		total_weight += int(entry.get("weight", 1))

	var roll: int = randi() % total_weight
	var cumulative: int = 0
	for entry: Dictionary in _enemy_pool:
		cumulative += int(entry.get("weight", 1))
		if roll < cumulative:
			return entry.get("id", "enemy_homework")

	return _enemy_pool[0].get("id", "enemy_homework")

func _get_boss_id() -> String:
	for entry: Dictionary in _enemy_pool:
		var eid: String = entry.get("id", "")
		if eid.begins_with("boss_"):
			return eid
	return ""

func _get_base_enemy_count() -> int:
	if current_mode == WaveMode.SURVIVAL:
		return 5 + _survival_wave_count * 2
	return 3 + current_wave

func _get_wave_difficulty() -> float:
	var wave_scale: float = 1.0 + float(current_wave - 1) * 0.15
	if current_mode == WaveMode.SURVIVAL:
		wave_scale = 1.0 + float(_survival_wave_count - 1) * 0.2
	return _difficulty_multiplier * wave_scale

func _get_spawn_interval() -> float:
	var base_interval: float = 1.5
	var wave_reduction: float = float(current_wave - 1) * 0.05
	if current_mode == WaveMode.SURVIVAL:
		wave_reduction = float(_survival_wave_count - 1) * 0.08
	return maxf(base_interval - wave_reduction, 0.4)

func stop_battle() -> void:
	is_active = false
	_spawn_timer.stop()
	_wave_delay_timer.stop()
	_hide_summon_button()

func _apply_gold_per_wave() -> void:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if not ts or not ts.has_method("get_gold_per_wave"):
		return
	var bonus: int = ts.get_gold_per_wave()
	if bonus <= 0:
		return
	var esys: Node = get_node_or_null("/root/EconomySystem")
	if esys and esys.has_method("earn_gold"):
		esys.earn_gold(bonus)
		Global.debug_log("词条每波金币奖励：%d" % bonus)

func get_wave_info() -> Dictionary:
	return {
		"current_wave": current_wave,
		"total_waves": total_waves,
		"is_boss_wave": is_boss_wave,
		"mode": current_mode,
		"enemies_alive": _enemies_alive,
		"enemies_remaining": _enemies_to_spawn - _enemies_spawned,
		"difficulty_multiplier": _get_wave_difficulty(),
		"gold_multiplier": _gold_multiplier
	}
