extends Node2D
class_name Enemy

const _AbilityComponent = preload("res://scripts/components/enemy_ability_component.gd")


signal died(enemy: Enemy)
signal reached_base(enemy: Enemy)

var config: EnemyConfig
var current_health: float
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var enemy_sprite: Sprite2D
var health_bar: ProgressBar

var base_move_speed: float = 0.0
var slow_timer: float = 0.0
var slow_amount: float = 0.0
var is_slowed: bool = false

var dot_damage_per_second: float = 0.0
var dot_timer: float = 0.0
var dot_duration: float = 0.0
var dot_elapsed: float = 0.0
var dot_damage_type: int = 0
var is_dot_active: bool = false

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_duration: float = 0.0
var knockback_timer: float = 0.0
var is_being_knocked_back: bool = false

var damage_dealers: Dictionary[Node2D, float] = {}
var last_hit_tower: Node2D = null
var ability_component: Node
var is_spawned: bool = false

func _ready() -> void:
	add_to_group("enemies")

func initialize(enemy_config: EnemyConfig) -> void:
	config = enemy_config
	current_health = config.max_health
	base_move_speed = config.move_speed
	setup_sprite()
	setup_health_bar()
	call_deferred("_setup_abilities")

func setup_sprite() -> void:
	if not config:
		push_error("[Enemy] 配置为空！")
		return

	enemy_sprite = Sprite2D.new()

	if config.texture_path != "":
		var texture: Texture2D = AssetsManager.load_image(config.texture_path) as Texture2D
		if texture:
			enemy_sprite.texture = texture
		else:
			push_error("[Enemy] 加载纹理失败：%s" % config.texture_path)
	else:
		push_warning("[Enemy] 纹理路径为空")

	enemy_sprite.scale = Vector2(0.5, 0.5)
	enemy_sprite.z_index = 5
	add_child(enemy_sprite)

func _mark_as_spawned() -> void:
	is_spawned = true
	if enemy_sprite:
		enemy_sprite.modulate = Color(1.0, 0.7, 0.7, 0.9)
		enemy_sprite.scale = Vector2(0.4, 0.4)

func setup_health_bar() -> void:
	var health_bar_container: MarginContainer = MarginContainer.new()
	health_bar_container.anchor_left = 0.5
	health_bar_container.anchor_top = 0.0
	health_bar_container.anchor_right = 0.5
	health_bar_container.anchor_bottom = 0.0
	health_bar_container.offset_left = -25.0
	health_bar_container.offset_top = -40.0
	health_bar_container.offset_right = 25.0
	health_bar_container.offset_bottom = -30.0
	add_child(health_bar_container)

	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(50, 6)
	health_bar.max_value = config.max_health
	health_bar.value = current_health
	health_bar.show_percentage = false

	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	bg_style.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.2, 1.0)
	fill_style.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("fill", fill_style)

	health_bar_container.add_child(health_bar)

func set_path(points: Array[Vector2]) -> void:
	path_points = points
	current_path_index = 0
	if path_points.size() > 0:
		global_position = path_points[0]

func _process(delta: float) -> void:
	update_effect_states(delta)

	if is_being_knocked_back:
		return

	if path_points.is_empty():
		return

	if current_path_index >= path_points.size():
		reached_base.emit(self)
		queue_free()
		return

	var target_pos: Vector2 = path_points[current_path_index]
	var direction: Vector2 = (target_pos - global_position).normalized()

	var actual_speed: float = get_effective_move_speed()
	var move_distance: float = actual_speed * delta

	if global_position.distance_to(target_pos) <= move_distance:
		global_position = target_pos
		current_path_index += 1
	else:
		global_position += direction * move_distance

func update_effect_states(delta: float) -> void:
	update_slow_effect(delta)
	update_dot_effect(delta)
	update_knockback_effect(delta)

func apply_slow(speed_reduction: float, duration: float) -> void:
	if not config:
		return

	speed_reduction = clampf(speed_reduction, 0.0, 0.95)

	slow_amount = speed_reduction
	slow_timer = duration
	is_slowed = true

func update_slow_effect(delta: float) -> void:
	if not is_slowed:
		return

	slow_timer -= delta
	if slow_timer <= 0:
		is_slowed = false
		slow_amount = 0.0
		slow_timer = 0.0

func get_effective_move_speed() -> float:
	if not config:
		return 0.0

	if is_being_knocked_back:
		return knockback_velocity.length()

	if is_slowed:
		return base_move_speed * (1.0 - slow_amount)

	return base_move_speed

func apply_dot(damage_per_sec: float, duration: float, damage_type: int = 0, source_tower: Node2D = null) -> void:
	if not config:
		return

	dot_damage_per_second = damage_per_sec
	dot_duration = duration
	dot_elapsed = 0.0
	dot_timer = 1.0
	dot_damage_type = damage_type
	is_dot_active = true

	if source_tower and source_tower is Tower:
		if not damage_dealers.has(source_tower):
			damage_dealers[source_tower] = 0.0

func update_dot_effect(delta: float) -> void:
	if not is_dot_active or not config:
		return

	dot_elapsed += delta
	dot_timer -= delta

	if dot_timer <= 0:
		dot_timer = 1.0
		var dot_applier: Node2D = null
		if damage_dealers.size() > 0 and is_instance_valid(last_hit_tower):
			dot_applier = last_hit_tower
		take_damage(dot_damage_per_second, dot_damage_type, dot_applier)

	if dot_elapsed >= dot_duration:
		is_dot_active = false
		dot_damage_per_second = 0.0
		dot_elapsed = 0.0
		Global.debug_log("[敌人 %s] DOT效果结束" % [config.enemy_name if config else "未知"])

func apply_knockback(direction: Vector2, distance: float) -> void:
	if not config:
		return

	var knockback_time: float = 0.3
	knockback_velocity = direction * distance / knockback_time
	knockback_duration = knockback_time
	knockback_timer = knockback_time
	is_being_knocked_back = true

func update_knockback_effect(delta: float) -> void:
	if not is_being_knocked_back:
		return

	knockback_timer -= delta

	global_position += knockback_velocity * delta

	if knockback_timer <= 0:
		is_being_knocked_back = false
		knockback_velocity = Vector2.ZERO
		knockback_timer = 0.0

func take_damage(damage_amount: float, damage_type: int, attacker: Node2D = null) -> void:
	if not config:
		return
	if ability_component and ability_component.check_dodge(damage_type):
		return
	_play_hit_animation()
	var resistance: float
	if damage_type == DamageTypes.Type.PHYSICAL:
		resistance = config.physical_resistance
	else:
		resistance = config.magical_resistance
	if ability_component:
		resistance += ability_component.get_achievement_shield_reduction()
		var regret_mult: float = ability_component.get_regret_damage_multiplier()
		if regret_mult > 1.0:
			damage_amount *= regret_mult
	var actual_damage: float = damage_amount * (1.0 - resistance)
	current_health -= actual_damage

	if attacker and attacker is Tower:
		if not damage_dealers.has(attacker):
			damage_dealers[attacker] = 0.0
		damage_dealers[attacker] += actual_damage
		last_hit_tower = attacker

		Global.debug_log("[伤害记录] %s 对 %s 造成 %.1f 伤害，累计 %.1f" % [attacker.config.tower_name, config.enemy_name, actual_damage, damage_dealers[attacker]])

		if attacker.config and attacker.config.experience_on_hit > 0:
			attacker.add_experience(attacker.config.experience_on_hit)

	update_health_bar()

	if current_health <= 0:
		die()

func _play_hit_animation() -> void:
	if not enemy_sprite:
		return

	var tween: Tween = create_tween()

	var original_color: Color = enemy_sprite.modulate

	tween.tween_property(enemy_sprite, "modulate", Color(3, 3, 3, 1), 0.05)
	tween.tween_property(enemy_sprite, "modulate", Color(2, 0.2, 0.2, 1), 0.08)
	tween.tween_property(enemy_sprite, "modulate", original_color, 0.07)

func update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_health
		var health_ratio: float = current_health / config.max_health
		if health_ratio > 0.6:
			health_bar.get_theme_stylebox("fill").bg_color = Color(0.2, 0.8, 0.2, 1.0)
		elif health_ratio > 0.3:
			health_bar.get_theme_stylebox("fill").bg_color = Color(0.8, 0.8, 0.2, 1.0)
		else:
			health_bar.get_theme_stylebox("fill").bg_color = Color(0.8, 0.2, 0.2, 1.0)

func die() -> void:
	if ability_component:
		ability_component.trigger_death_split()
	if config and config.gold_drop > 0:
		var game_hud: Node = get_node_or_null("/root/MapManager/GameHUD")
		if not game_hud:
			game_hud = get_tree().get_first_node_in_group("game_hud")

		if game_hud:
			if game_hud.has_method("add_gold"):
				game_hud.add_gold(config.gold_drop)
				Global.debug_log("[Enemy] 发放金币：%d" % config.gold_drop)

			if damage_dealers.size() > 0:
				distribute_experience(game_hud)
			else:
				var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
				if towers.size() > 0 and game_hud.has_method("add_tower_experience"):
					var exp_per_tower: float = float(config.experience_drop) / float(towers.size())
					for tower_node: Node in towers:
						if tower_node is Tower:
							tower_node.add_experience(int(exp_per_tower))
							Global.debug_log("[Enemy] 平均分配经验：%d" % int(exp_per_tower))

	died.emit(self)
	queue_free()

func distribute_experience(game_hud: Node) -> void:
	if not game_hud or not game_hud.has_method("add_tower_experience"):
		return

	var total_damage: float = 0.0
	for tower_key: Node2D in damage_dealers:
		total_damage += damage_dealers[tower_key]

	if total_damage <= 0.0:
		Global.debug_log("[经验分配] 没有伤害记录，total_damage = 0")
		return

	Global.debug_log("[经验分配] damage_dealers 数量：%d" % damage_dealers.size())
	for tower_key: Node2D in damage_dealers:
		if is_instance_valid(tower_key) and tower_key is Tower and (tower_key as Tower).config:
			var damage_ratio: float = damage_dealers[tower_key] / total_damage
			Global.debug_log("[经验分配]   - %s: 累计伤害 %.1f (占总伤害 %.1f%%)" % [(tower_key as Tower).config.tower_name, damage_dealers[tower_key], damage_ratio * 100.0])

	var last_hitter: Node2D = last_hit_tower
	var killing_bonus: float = 0.2
	var participation_bonus: float = 0.1

	var damage_pool: float = float(config.experience_drop) * 0.8
	var killing_bonus_pool: float = float(config.experience_drop) * killing_bonus

	var exp_bonus: float = 0.0
	var es: Node = get_node_or_null("/root/EraSystem")
	if es and es.has_method("get_family_modifier"):
		exp_bonus = es.get_family_modifier("experience_bonus")

	for tower_key: Node2D in damage_dealers:
		if not is_instance_valid(tower_key):
			Global.debug_log("[经验分配] 跳过无效塔实例")
			continue

		var damage_ratio: float = damage_dealers[tower_key] / total_damage
		var exp_reward: float = 0.0

		exp_reward += damage_pool * damage_ratio

		if tower_key == last_hitter:
			exp_reward += killing_bonus_pool

		if damage_ratio > 0.05:
			exp_reward += float(config.experience_drop) * participation_bonus

		if exp_bonus > 0.0:
			exp_reward *= (1.0 + exp_bonus)

		if exp_reward > 0.0:
			var tower_ref: Tower = tower_key as Tower
			if tower_ref:
				var final_exp: int = int(max(1, exp_reward))
				tower_ref.add_experience(final_exp)
				var bonus_text: String = "，经验获取提升%.0f%%" % (exp_bonus * 100.0) if exp_bonus > 0.0 else ""
				Global.debug_log("[经验分配] %s 获得经验 %d (伤害占比 %.1f%%%s)" % [tower_ref.config.tower_name if tower_ref.config else "未知塔", final_exp, damage_ratio * 100.0, bonus_text])

func get_current_health() -> float:
	return current_health

func get_effect_state_info() -> Dictionary:
	return {
		"is_slowed": is_slowed,
		"slow_amount": slow_amount,
		"slow_timer_remaining": slow_timer,
		"is_dot_active": is_dot_active,
		"dot_damage_per_second": dot_damage_per_second,
		"dot_remaining": max(0.0, dot_duration - dot_elapsed),
		"is_being_knocked_back": is_being_knocked_back,
		"effective_move_speed": get_effective_move_speed(),
		"base_move_speed": base_move_speed
	}

func _setup_abilities() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm:
		return
	var enemies_data: Dictionary = cm.load_json("res://data/enemies.json")
	if not enemies_data.has("enemies"):
		return
	var enemy_id: String = config.enemy_id if config else ""
	for enemy_entry: Dictionary in enemies_data.enemies:
		if enemy_entry.get("enemy_id", "") == enemy_id:
			var abilities: Array = enemy_entry.get("special_abilities", [])
			if not abilities.is_empty():
				var typed_abilities: Array[Dictionary] = []
				for ab: Dictionary in abilities:
					typed_abilities.append(ab)
				ability_component = _AbilityComponent.new()
				add_child(ability_component)
				ability_component.initialize(self, typed_abilities)
				ability_component.split_requested.connect(_on_split_requested)
				ability_component.summon_requested.connect(_on_summon_requested)
				ability_component.tower_destroy_requested.connect(_on_tower_destroy_requested)
			break

func _on_split_requested(split_enemy_id: String, count: int, pos: Vector2) -> void:
	Global.debug_log("[分裂] %s 死亡分裂为 %d 个 %s" % [config.enemy_name, count, split_enemy_id])
	for i: int in range(count):
		var split_config: EnemyConfig = EnemyConfig.get_config(split_enemy_id)
		if split_config:
			var split_enemy: Enemy = Enemy.new()
			split_enemy.initialize(split_config)
			split_enemy.global_position = pos + Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
			split_enemy._mark_as_spawned()
			if path_points.size() > 0:
				split_enemy.set_path(path_points)
				split_enemy.current_path_index = current_path_index
			var mm: Node = get_node_or_null("/root/MapManager")
			if mm and mm.has_method("_on_enemy_reached_base"):
				split_enemy.reached_base.connect(mm._on_enemy_reached_base)
			if mm and mm.has_method("_on_enemy_killed"):
				split_enemy.died.connect(mm._on_enemy_killed)
			get_parent().add_child(split_enemy)

func _on_summon_requested(summon_configs: Array, pos: Vector2) -> void:
	for entry: Dictionary in summon_configs:
		var summon_id: String = entry.get("id", "")
		var count: int = entry.get("count", 1)
		for i: int in range(count):
			var summon_config: EnemyConfig = EnemyConfig.get_config(summon_id)
			if summon_config:
				var summon_enemy: Enemy = Enemy.new()
				summon_enemy.initialize(summon_config)
				summon_enemy.global_position = pos + Vector2(randf_range(-30.0, 30.0), randf_range(-30.0, 30.0))
				summon_enemy._mark_as_spawned()
				if path_points.size() > 0:
					summon_enemy.set_path(path_points)
					summon_enemy.current_path_index = current_path_index
				var mm: Node = get_node_or_null("/root/MapManager")
				if mm and mm.has_method("_on_enemy_reached_base"):
					summon_enemy.reached_base.connect(mm._on_enemy_reached_base)
				if mm and mm.has_method("_on_enemy_killed"):
					summon_enemy.died.connect(mm._on_enemy_killed)
				get_parent().add_child(summon_enemy)

func _on_tower_destroy_requested(target_count: int) -> void:
	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	var valid_towers: Array[Node] = []
	for t: Node in towers:
		if is_instance_valid(t) and t is Tower:
			valid_towers.append(t)
	var mm: Node = get_node_or_null("/root/MapManager")
	for i: int in range(mini(target_count, valid_towers.size())):
		if valid_towers.is_empty():
			break
		var idx: int = randi() % valid_towers.size()
		var target_tower: Node = valid_towers[idx]
		Global.debug_log("[BOSS] %s 消灭了塔：%s" % [config.enemy_name, target_tower.name])
		if mm and mm.has_method("remove_built_tower"):
			mm.remove_built_tower(target_tower)
		target_tower.queue_free()
		valid_towers.remove_at(idx)
