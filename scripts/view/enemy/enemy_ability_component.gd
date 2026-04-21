extends Node

var enemy: Node2D
var abilities: Array[Dictionary] = []
var _ability_timers: Dictionary = {}

signal ability_triggered(ability_id: String)
signal split_requested(split_enemy_id: String, count: int, position: Vector2)
signal summon_requested(summon_configs: Array, position: Vector2)
signal tower_destroy_requested(target_count: int)

func initialize(enemy_node: Enemy, enemy_abilities: Array[Dictionary]) -> void:
	enemy = enemy_node
	abilities = enemy_abilities
	for ability: Dictionary in abilities:
		if ability.has("cooldown"):
			_ability_timers[ability.ability_id] = 0.0

func _process(delta: float) -> void:
	if Global.soft_paused:
		return
	if not enemy or not is_instance_valid(enemy):
		return
	for ability: Dictionary in abilities:
		_process_ability(ability, delta)

func _process_ability(ability: Dictionary, delta: float) -> void:
	if enemy and enemy.is_silenced:
		return
	var ability_id: String = ability.get("ability_id", "")
	match ability_id:
		"dodge":
			pass
		"split":
			pass
		"spawn_homework":
			_process_summon_ability(ability, delta)
		"self_buff":
			_process_self_buff(ability, delta)
		"destroy_tower":
			_process_destroy_tower(ability, delta)
		"summon_stress":
			_process_boss_summon(ability, delta)
		"memory_attack":
			_process_memory_attack(ability, delta)
		"achievement_shield":
			pass

func check_dodge(damage_type: int) -> bool:
	for ability: Dictionary in abilities:
		if ability.get("ability_id", "") == "dodge":
			var trigger_on: String = ability.get("trigger_on", "")
			if trigger_on == "physical_damage" and damage_type == 0:
				var prob: float = ability.get("dodge_probability", 0.0)
				if randf() < prob:
					Global.debug_log("[闪避] %s 闪避了物理攻击！" % enemy.get("config").enemy_name)
					return true
	return false

func _process_summon_ability(ability: Dictionary, delta: float) -> void:
	var ability_id: String = ability.get("ability_id", "")
	if not _ability_timers.has(ability_id):
		_ability_timers[ability_id] = 0.0
	_ability_timers[ability_id] -= delta
	if _ability_timers[ability_id] <= 0.0:
		_ability_timers[ability_id] = ability.get("cooldown", 5.0)
		var spawn_id: String = ability.get("spawn_enemy_id", "")
		var count: int = ability.get("spawn_count", 1)
		summon_requested.emit([{"id": spawn_id, "count": count}], enemy.global_position)
		ability_triggered.emit(ability_id)

func _process_self_buff(ability: Dictionary, delta: float) -> void:
	var ability_id: String = ability.get("ability_id", "")
	if not _ability_timers.has(ability_id):
		_ability_timers[ability_id] = 0.0
	_ability_timers[ability_id] -= delta
	if _ability_timers[ability_id] <= 0.0:
		_ability_timers[ability_id] = ability.get("buff_interval", 3.0)
		var _damage_increase: float = ability.get("damage_increase_per_buff", 0.05)
		var _speed_increase: float = ability.get("speed_increase_per_buff", 0.03)
		var max_stacks: int = ability.get("max_stacks", 10)
		if not enemy.has_meta("buff_stacks"):
			enemy.set_meta("buff_stacks", 0)
		var stacks: int = enemy.get_meta("buff_stacks")
		if stacks < max_stacks:
			stacks += 1
			enemy.set_meta("buff_stacks", stacks)
			enemy.base_move_speed *= (1.0 + _speed_increase)
			Global.debug_log("[自我强化] %s 强化层数 %d" % [enemy.get("config").enemy_name, stacks])
		ability_triggered.emit(ability_id)

func _process_destroy_tower(ability: Dictionary, delta: float) -> void:
	var ability_id: String = ability.get("ability_id", "")
	if not _ability_timers.has(ability_id):
		_ability_timers[ability_id] = ability.get("cooldown", 15.0)
	_ability_timers[ability_id] -= delta
	if _ability_timers[ability_id] <= 0.0:
		_ability_timers[ability_id] = ability.get("cooldown", 15.0)
		var target_count: int = ability.get("target_count", 1)
		var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
		var valid_count: int = 0
		for t: Node in towers:
			if is_instance_valid(t) and t is Tower and not t.is_destroyed:
				valid_count += 1
		Global.debug_log("[BOSS能力] destroy_tower 冷却完成，目标数=%d，场上可用塔=%d" % [target_count, valid_count])
		tower_destroy_requested.emit(target_count)
		ability_triggered.emit(ability_id)

func _process_boss_summon(ability: Dictionary, delta: float) -> void:
	var ability_id: String = ability.get("ability_id", "")
	if not _ability_timers.has(ability_id):
		_ability_timers[ability_id] = ability.get("cooldown", 10.0)
	_ability_timers[ability_id] -= delta
	if _ability_timers[ability_id] <= 0.0:
		_ability_timers[ability_id] = ability.get("cooldown", 10.0)
		var spawn_configs: Array = ability.get("spawn_enemies", [])
		summon_requested.emit(spawn_configs, enemy.global_position)
		ability_triggered.emit(ability_id)

func _process_memory_attack(ability: Dictionary, delta: float) -> void:
	var ability_id: String = ability.get("ability_id", "")
	if not _ability_timers.has(ability_id):
		_ability_timers[ability_id] = ability.get("cooldown", 12.0)
	_ability_timers[ability_id] -= delta
	if _ability_timers[ability_id] <= 0.0:
		_ability_timers[ability_id] = ability.get("cooldown", 12.0)
		var pool: Array = ability.get("spawn_enemy_pool", [])
		var count: int = ability.get("spawn_count", 3)
		var chosen: Array[Dictionary] = []
		for i: int in range(count):
			if pool.size() > 0:
				var enemy_id: String = pool[randi() % pool.size()]
				chosen.append({"id": enemy_id, "count": 1})
		if not chosen.is_empty():
			summon_requested.emit(chosen, enemy.global_position)
		ability_triggered.emit(ability_id)

func get_achievement_shield_reduction() -> float:
	for ability: Dictionary in abilities:
		if ability.get("ability_id", "") == "achievement_shield":
			var reduction_per: float = ability.get("damage_reduction_per_achievement", 0.02)
			var max_reduction: float = ability.get("max_reduction", 0.50)
			var player_save: PlayerSaveData = Global.get_player_save()
			var achievement_count: int = player_save.achievements.size()
			var reduction: float = minf(float(achievement_count) * reduction_per, max_reduction)
			return reduction
	return 0.0

func get_regret_damage_multiplier() -> float:
	for ability: Dictionary in abilities:
		if ability.get("ability_id", "") == "regret_damage":
			var bonus: float = ability.get("bonus_damage", 2.0)
			var session: GameSessionData = Global.get_game_session()
			var incomplete: int = 0
			var total_events: int = 20
			if session.completed_events.size() < total_events:
				incomplete = total_events - session.completed_events.size()
			if incomplete > 0:
				var multiplier: float = 1.0 + (bonus - 1.0) * (float(incomplete) / float(total_events))
				return multiplier
	return 1.0

func trigger_death_split() -> void:
	for ability: Dictionary in abilities:
		if ability.get("ability_id", "") == "split" and ability.get("trigger_on", "") == "death":
			var split_id: String = ability.get("split_enemy_id", "")
			var count: int = ability.get("split_count", 2)
			split_requested.emit(split_id, count, enemy.global_position)
			ability_triggered.emit("split")
