extends Node

signal skill_unlocked(skill_id: String)
signal skill_used(skill_id: String)
signal skill_cooldown_updated(skill_id: String, remaining: float, total: float)

var _skill_configs: Dictionary = {}
var _unlocked_skills: Dictionary = {}
var _cooldown_timers: Dictionary = {}
var _active_effects: Array[Dictionary] = []
var _poison_zones: Array[Node2D] = []

func _ready() -> void:
	_load_skill_configs()
	Global.session_reset.connect(_on_session_reset)

func _load_skill_configs() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		push_warning("SkillSystem: ConfigManager not found")
		return
	var data: Dictionary = cm.load_json("res://data/skills.json")
	if not data.has("skills"):
		push_warning("SkillSystem: skills.json missing 'skills' key")
		return
	for skill_entry: Dictionary in data.skills:
		var sb: SkillBean = SkillBean.from_dict(skill_entry)
		_skill_configs[sb.skill_id] = sb

func _on_session_reset() -> void:
	_unlocked_skills.clear()
	for skill_id: String in _cooldown_timers:
		var timer: SceneTreeTimer = _cooldown_timers[skill_id]
		if timer and timer.time_left > 0.0:
			timer.time_left = 0.0
	_cooldown_timers.clear()
	_clear_active_effects()

func get_all_skill_configs() -> Dictionary:
	return _skill_configs

func get_skill_config(skill_id: String) -> SkillBean:
	return _skill_configs.get(skill_id, null)

func check_and_unlock_skills() -> void:
	var session: GameSessionData = Global.get_game_session()
	if not session:
		return
	for npc: NPCData in session.npcs:
		if not npc.is_active:
			continue
		for skill_id: String in _skill_configs:
			var sb: SkillBean = _skill_configs[skill_id]
			if sb.npc_id == npc.npc_id and npc.affection >= sb.required_affection:
				if not _unlocked_skills.has(skill_id):
					_unlocked_skills[skill_id] = sb
					skill_unlocked.emit(skill_id)
					Global.debug_log("SkillSystem: skill unlocked - %s (NPC: %s, affection: %d)" % [sb.get_display_name(), npc.name, npc.affection])

func is_skill_unlocked(skill_id: String) -> bool:
	return _unlocked_skills.has(skill_id)

func get_unlocked_skills() -> Dictionary:
	return _unlocked_skills

func is_skill_ready(skill_id: String) -> bool:
	if not is_skill_unlocked(skill_id):
		return false
	return not _cooldown_timers.has(skill_id)

func get_cooldown_remaining(skill_id: String) -> float:
	if not _cooldown_timers.has(skill_id):
		return 0.0
	var timer: SceneTreeTimer = _cooldown_timers[skill_id]
	return timer.time_left if timer else 0.0

func use_skill(skill_id: String, target_position: Vector2 = Vector2.ZERO) -> bool:
	if not is_skill_ready(skill_id):
		return false
	var sb: SkillBean = _unlocked_skills.get(skill_id)
	if not sb:
		return false
	_execute_skill(sb, target_position)
	_start_cooldown(sb)
	skill_used.emit(skill_id)
	Global.debug_log("SkillSystem: skill used - %s" % sb.get_display_name())
	return true

func _execute_skill(sb: SkillBean, target_position: Vector2) -> void:
	match sb.skill_type:
		"tower_buff":
			_apply_tower_buff(sb)
		"global_freeze":
			_apply_global_freeze(sb)
		"poison_zone":
			_apply_poison_zone(sb, target_position)

func _apply_tower_buff(sb: SkillBean) -> void:
	var damage_bonus: float = float(sb.params.get("damage_bonus", 0.5))
	var speed_bonus: float = float(sb.params.get("attack_speed_bonus", 0.2))
	var all_towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	for tower: Node2D in all_towers:
		if not is_instance_valid(tower) or not tower is Tower:
			continue
		tower.apply_buff(damage_bonus, speed_bonus, sb.duration)
	_active_effects.append({"type": "tower_buff", "skill_id": sb.skill_id, "remaining": sb.duration})
	Global.debug_log("SkillSystem: inspire active - dmg+%.0f%%, spd+%.0f%%, dur=%.1fs" % [damage_bonus * 100.0, speed_bonus * 100.0, sb.duration])

func _apply_global_freeze(sb: SkillBean) -> void:
	var all_enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy: Node2D in all_enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("apply_stun"):
			enemy.apply_stun(sb.duration)
	_active_effects.append({"type": "global_freeze", "skill_id": sb.skill_id, "remaining": sb.duration})
	Global.debug_log("SkillSystem: time freeze active - dur=%.1fs" % sb.duration)

func _apply_poison_zone(sb: SkillBean, target_position: Vector2) -> void:
	var radius: float = float(sb.params.get("radius", 120.0))
	var dps: float = float(sb.params.get("dps", 8.0))
	var zone: Node2D = _create_poison_zone_visual(target_position, radius)
	_poison_zones.append(zone)
	_active_effects.append({
		"type": "poison_zone",
		"skill_id": sb.skill_id,
		"remaining": sb.duration,
		"position": target_position,
		"radius": radius,
		"dps": dps,
		"zone_node": zone
	})
	Global.debug_log("SkillSystem: poison zone active - radius=%.0f, dps=%.1f, dur=%.1fs" % [radius, dps, sb.duration])

func _create_poison_zone_visual(pos: Vector2, radius: float) -> Node2D:
	var zone_node: Node2D = Node2D.new()
	zone_node.global_position = pos
	var circle: ColorRect = ColorRect.new()
	var size: float = radius * 2.0
	circle.size = Vector2(size, size)
	circle.position = Vector2(-radius, -radius)
	circle.color = Color(0.3, 0.8, 0.2, 0.25)
	circle.z_index = 3
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_node.add_child(circle)
	var scene_root: Node = get_tree().current_scene
	if scene_root:
		scene_root.add_child(zone_node)
	return zone_node

func _start_cooldown(sb: SkillBean) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(sb.cooldown)
	_cooldown_timers[sb.skill_id] = timer
	timer.timeout.connect(_on_cooldown_finished.bind(sb.skill_id))

func _on_cooldown_finished(skill_id: String) -> void:
	_cooldown_timers.erase(skill_id)
	var total: float = _skill_configs[skill_id].cooldown if _skill_configs.has(skill_id) else 0.0
	skill_cooldown_updated.emit(skill_id, 0.0, total)
	Global.debug_log("SkillSystem: cooldown finished - %s" % skill_id)

func _process(delta: float) -> void:
	if Global.soft_paused:
		return
	_update_active_effects(delta)
	_update_cooldown_signals()

func _update_active_effects(delta: float) -> void:
	var valid_effects: Array[Dictionary] = []
	for effect: Dictionary in _active_effects:
		effect.remaining -= delta
		if effect.remaining <= 0.0:
			_on_effect_expired(effect)
			continue
		if effect.type == "poison_zone":
			_tick_poison_zone(effect, delta)
		valid_effects.append(effect)
	_active_effects = valid_effects

func _tick_poison_zone(effect: Dictionary, delta: float) -> void:
	var zone_pos: Vector2 = effect.position
	var zone_radius: float = effect.radius
	var dps: float = effect.dps
	var all_enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy: Node2D in all_enemies:
		if not is_instance_valid(enemy):
			continue
		var dist: float = zone_pos.distance_to(enemy.global_position)
		if dist <= zone_radius and enemy.has_method("take_damage"):
			enemy.take_damage(dps * delta, GameConfig.DamageType.MAGICAL, null)

func _on_effect_expired(effect: Dictionary) -> void:
	if effect.type == "poison_zone" and effect.has("zone_node"):
		var zone: Node2D = effect.zone_node
		if is_instance_valid(zone):
			zone.queue_free()
		_poison_zones.erase(zone)
	Global.debug_log("SkillSystem: effect expired - %s" % effect.skill_id)

func _clear_active_effects() -> void:
	for effect: Dictionary in _active_effects:
		if effect.type == "poison_zone" and effect.has("zone_node"):
			var zone: Node2D = effect.zone_node
			if is_instance_valid(zone):
				zone.queue_free()
	_active_effects.clear()

func _update_cooldown_signals() -> void:
	for skill_id: String in _cooldown_timers:
		var timer: SceneTreeTimer = _cooldown_timers[skill_id]
		if timer and timer.time_left > 0.0:
			skill_cooldown_updated.emit(skill_id, timer.time_left, _skill_configs[skill_id].cooldown if _skill_configs.has(skill_id) else 0.0)
