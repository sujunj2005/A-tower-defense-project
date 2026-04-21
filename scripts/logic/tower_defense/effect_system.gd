extends Node

const EffectType = GameConfig.EffectType

var _active_effects: Array[Dictionary] = []
var _aura_towers: Array[Dictionary] = []
var _passive_towers: Array[Dictionary] = []

func _process(delta: float) -> void:
	_update_timed_effects(delta)
	_update_auras()

func apply_effect(effect_type: int, params: Dictionary, source_tower: Tower, target: Node2D) -> void:
	if not target or not is_instance_valid(target):
		return
	if effect_type == EffectType.NONE:
		return
	var probability: float = float(params.get("probability", 1.0))
	if probability < 1.0 and randf() > probability:
		return
	match effect_type:
		EffectType.SLOW:
			_apply_slow(target, params)
		EffectType.DOT:
			_apply_dot(target, params, source_tower)
		EffectType.BURN:
			_apply_burn(target, params, source_tower)
		EffectType.SPLASH:
			_apply_splash(target, params, source_tower)
		EffectType.KNOCKBACK:
			_apply_knockback(target, params, source_tower)
		EffectType.CRIT:
			_apply_crit(target, params, source_tower)
		EffectType.SILENCE:
			_apply_silence(target, params)
		EffectType.ARMOR_BREAK:
			_apply_armor_break(target, params)
		EffectType.CONFUSION:
			_apply_confusion(target, params)
		EffectType.DEBUFF:
			_apply_debuff(target, params)
		EffectType.SINGLE_CONTROL:
			_apply_single_control(target, params)
		EffectType.CULTURAL_SUPPRESSION:
			_apply_cultural_suppression(target, params, source_tower)
		EffectType.GOLD_BONUS:
			pass
		EffectType.SLOW_AURA:
			_register_aura(effect_type, params, source_tower)
		EffectType.BUFF_AURA:
			_register_aura(effect_type, params, source_tower)
		EffectType.SUMMON:
			_apply_summon(params, source_tower)

func apply_on_kill_effect(effect_type: int, params: Dictionary, source_tower: Tower, killed_enemy: Enemy) -> void:
	if effect_type == EffectType.GOLD_BONUS:
		var gold_per_kill: float = float(params.get("gold_per_kill", 0.2))
		var bonus: int = maxi(1, int(ceilf(killed_enemy.config.gold_drop * gold_per_kill)))
		var hud: Node = get_tree().get_first_node_in_group("game_hud")
		if hud and hud.has_method("add_gold"):
			hud.add_gold(bonus)
		if killed_enemy.has_method("show_gold_number"):
			killed_enemy.show_gold_number(bonus)

func _apply_slow(target: Node2D, params: Dictionary) -> void:
	if target.has_method("apply_slow"):
		target.apply_slow(float(params.get("value", 0.2)), float(params.get("duration", 1.5)))

func _apply_dot(target: Node2D, params: Dictionary, source_tower: Tower) -> void:
	if target.has_method("apply_dot"):
		target.apply_dot(float(params.get("value", 3.0)), float(params.get("duration", 3.0)), 0, source_tower)

func _apply_burn(target: Node2D, params: Dictionary, source_tower: Tower) -> void:
	if target.has_method("apply_dot"):
		target.apply_dot(float(params.get("value", 8.0)), 2.0, 1, source_tower)

func _apply_splash(center_target: Node2D, params: Dictionary, source_tower: Tower) -> void:
	if not center_target or not is_instance_valid(center_target):
		return
	var radius: float = float(params.get("radius", 100.0))
	var damage_ratio: float = float(params.get("damage_ratio", 1.0))
	var splash_damage: float = source_tower.config.damage * damage_ratio
	var all_enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var hit_count: int = 0
	for enemy: Node2D in all_enemies:
		if not is_instance_valid(enemy) or enemy == center_target:
			continue
		if center_target.global_position.distance_to(enemy.global_position) <= radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(splash_damage, 0, source_tower)
				hit_count += 1
			var kb_dist: float = float(params.get("knockback_distance", 20.0))
			var kb_prob: float = float(params.get("knockback_probability", 0.3))
			if kb_dist > 0.0 and randf() < kb_prob and enemy.has_method("apply_knockback"):
				var dir: Vector2 = (enemy.global_position - center_target.global_position).normalized()
				enemy.apply_knockback(dir, kb_dist)

func _apply_knockback(target: Node2D, params: Dictionary, source_tower: Tower) -> void:
	if target.has_method("apply_knockback"):
		var dir: Vector2 = (target.global_position - source_tower.global_position).normalized()
		target.apply_knockback(dir, float(params.get("distance", 50.0)))

func _apply_crit(target: Node2D, params: Dictionary, source_tower: Tower) -> void:
	var crit_prob: float = float(params.get("crit_probability", 0.1))
	if randf() > crit_prob:
		return
	var multiplier: float = float(params.get("crit_multiplier", 2.0))
	var base_dmg: float = source_tower.config.damage
	var ts: Node = get_node_or_null("/root/TraitSystem")
	var trait_bonus: float = 0.0
	if ts and ts.has_method("get_trait_effects_for_tower"):
		trait_bonus = ts.get_trait_effects_for_tower(source_tower.config.tower_id)
	var effective_dmg: float = base_dmg * (1.0 + trait_bonus)
	var extra_damage: float = effective_dmg * (multiplier - 1.0)
	if target.has_method("take_damage"):
		target.take_damage(extra_damage, 0, source_tower)
		if target.has_method("show_crit_number"):
			target.show_crit_number(effective_dmg * multiplier)

func _apply_silence(target: Node2D, params: Dictionary) -> void:
	if target.has_method("apply_silence"):
		target.apply_silence(float(params.get("duration", 1.0)))

func _apply_armor_break(target: Node2D, params: Dictionary) -> void:
	if target.has_method("apply_armor_break"):
		target.apply_armor_break(float(params.get("value", 0.3)), float(params.get("duration", 3.0)))

func _apply_confusion(target: Node2D, params: Dictionary) -> void:
	if target.has_method("apply_confusion"):
		target.apply_confusion(float(params.get("duration", 2.0)))

func _apply_debuff(target: Node2D, params: Dictionary) -> void:
	if target.has_method("apply_debuff"):
		target.apply_debuff(float(params.get("value", 0.15)), float(params.get("duration", 3.0)))

func _apply_single_control(target: Node2D, params: Dictionary) -> void:
	if target.has_method("apply_stun"):
		target.apply_stun(float(params.get("duration", 3.0)))

func _apply_cultural_suppression(target: Node2D, params: Dictionary, source_tower: Tower) -> void:
	if not target is Enemy or not target.config:
		return
	var target_tags: Array = params.get("target_tags", [])
	var enemy_type: String = target.config.enemy_type.to_lower()
	var matched: bool = false
	for tag: String in target_tags:
		if enemy_type.find(tag.to_lower()) >= 0:
			matched = true
			break
	if not matched:
		return
	var bonus: float = float(params.get("bonus_damage", 0.5))
	var extra_damage: float = source_tower.config.damage * bonus
	if target.has_method("take_damage"):
		target.take_damage(extra_damage, 0, source_tower)

func _register_aura(effect_type: int, params: Dictionary, source_tower: Tower) -> void:
	for aura: Dictionary in _aura_towers:
		if aura.source == source_tower:
			return
	_aura_towers.append({
		"effect_type": effect_type,
		"params": params,
		"source": source_tower
	})

func _update_auras() -> void:
	var valid_auras: Array[Dictionary] = []
	for aura: Dictionary in _aura_towers:
		var tower: Tower = aura.source
		if not is_instance_valid(tower):
			continue
		valid_auras.append(aura)
		var radius: float = float(aura.params.get("radius", 200.0))
		var effect_type: int = aura.effect_type
		var all_enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
		for enemy: Node2D in all_enemies:
			if not is_instance_valid(enemy):
				continue
			var dist: float = tower.global_position.distance_to(enemy.global_position)
			if dist <= radius:
				if effect_type == EffectType.SLOW_AURA:
					if enemy.has_method("apply_slow"):
						enemy.apply_slow(float(aura.params.get("slow_value", 0.25)), 0.5)
		if effect_type == EffectType.BUFF_AURA:
			var all_towers: Array[Node] = get_tree().get_nodes_in_group("towers")
			for other: Node2D in all_towers:
				if not is_instance_valid(other) or other == tower:
					continue
				var dist_t: float = tower.global_position.distance_to(other.global_position)
				if dist_t <= radius:
					if other.has_method("apply_buff"):
						other.apply_buff(
							float(aura.params.get("damage_bonus", 0.15)),
							float(aura.params.get("attack_speed_bonus", 0.1)),
							0.5
						)
	_aura_towers = valid_auras

func _apply_summon(params: Dictionary, source_tower: Tower) -> void:
	var mm: Node = get_tree().get_first_node_in_group("map_manager")
	if not mm or not mm.has_method("summon_temp_tower"):
		return
	mm.summon_temp_tower(
		source_tower.global_position,
		params.get("summon_tower_stats", {}),
		float(params.get("summon_duration", 30.0))
	)

func _update_timed_effects(delta: float) -> void:
	pass

func remove_aura_for_tower(tower: Tower) -> void:
	_aura_towers = _aura_towers.filter(func(a: Dictionary) -> bool: return a.source != tower)

func register_passive(tower: Tower) -> void:
	if not tower or not tower.config or tower.config.passive_effect.is_empty():
		return
	for p: Dictionary in _passive_towers:
		if p.source == tower:
			return
	_passive_towers.append({
		"source": tower,
		"effect": tower.config.passive_effect
	})

func unregister_passive(tower: Tower) -> void:
	_passive_towers = _passive_towers.filter(func(p: Dictionary) -> bool: return p.source != tower)

func get_global_gold_bonus() -> float:
	var total: float = 0.0
	for p: Dictionary in _passive_towers:
		if not is_instance_valid(p.source):
			continue
		var effect: Dictionary = p.effect
		if effect.get("type", "") == "global_gold_bonus":
			total += float(effect.get("gold_bonus", 0.0))
	return total
