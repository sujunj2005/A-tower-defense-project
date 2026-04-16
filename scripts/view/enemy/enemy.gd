extends Node2D
class_name Enemy

const _AbilityComponent = preload("res://scripts/view/enemy/enemy_ability_component.gd")


signal died(enemy: Enemy)
signal reached_base(enemy: Enemy)
signal mouse_clicked(enemy: Enemy)

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
var is_selected: bool = false
var _selection_indicator: ColorRect = null
var spawn_offset: Vector2 = Vector2.ZERO
var secondary_offset: Vector2 = Vector2.ZERO
var waypoints: Array[Vector2] = []

func _ready() -> void:
	add_to_group("enemies")

func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	if is_selected:
		if not _selection_indicator:
			_selection_indicator = ColorRect.new()
			_selection_indicator.size = Vector2(60, 60)
			_selection_indicator.position = Vector2(-30, -30)
			_selection_indicator.z_index = 4
			_selection_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var shader_mat: ShaderMaterial = ShaderMaterial.new()
			var shader: Shader = Shader.new()
			shader.code = "shader_type canvas_item;\nvoid fragment() {\n	vec2 uv = UV;\n	float border = 0.08;\n	float alpha = 0.0;\n	if (uv.x < border || uv.x > 1.0 - border || uv.y < border || uv.y > 1.0 - border) {\n		alpha = 0.8;\n	}\n	float pulse = 0.5 + 0.5 * sin(TIME * 4.0);\n	alpha *= (0.6 + 0.4 * pulse);\n	COLOR = vec4(1.0, 0.85, 0.2, alpha);\n}"
			shader_mat.shader = shader
			_selection_indicator.material = shader_mat
			add_child(_selection_indicator)
		_selection_indicator.visible = true
	else:
		if _selection_indicator:
			_selection_indicator.visible = false

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
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(50, 6)
	health_bar.max_value = config.max_health
	health_bar.value = current_health
	health_bar.show_percentage = false
	health_bar.position = Vector2(-25, -40)
	health_bar.z_index = 20

	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	bg_style.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.2, 1.0)
	fill_style.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("fill", fill_style)

	add_child(health_bar)

func set_waypoints(wps: Array[Vector2], set_position: bool = false) -> void:
	waypoints = wps
	_rebuild_path_from_waypoints()
	current_path_index = 0
	if set_position and path_points.size() > 0:
		global_position = path_points[0]

func set_path(points: Array[Vector2], set_position: bool = false) -> void:
	waypoints = points
	path_points = points.duplicate()
	current_path_index = 0
	if set_position and path_points.size() > 0:
		global_position = path_points[0]

func _rebuild_path_from_waypoints() -> void:
	path_points.clear()
	if waypoints.size() < 2:
		if waypoints.size() == 1:
			path_points.append(waypoints[0] + spawn_offset + secondary_offset)
		return
	var total_offset: Vector2 = spawn_offset + secondary_offset
	for i: int in range(waypoints.size()):
		path_points.append(waypoints[i] + total_offset)



func _process(delta: float) -> void:
	if Global.soft_paused:
		return
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
	var direction_to_target: Vector2 = target_pos - global_position
	var dist_to_target: float = direction_to_target.length()

	var actual_speed: float = get_effective_move_speed()
	var move_distance: float = actual_speed * delta

	if dist_to_target <= move_distance:
		global_position = target_pos
		current_path_index += 1
	else:
		var move_dir: Vector2 = direction_to_target.normalized()
		global_position += move_dir * move_distance

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
		Global.debug_log("[敌人 %s] DOT效果结束" % [config.get_display_name() if config else "未知"])

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
	if damage_type == GameConfig.DamageType.PHYSICAL:
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
	_show_damage_number(actual_damage)

	if attacker and attacker is Tower:
		if not damage_dealers.has(attacker):
			damage_dealers[attacker] = 0.0
		damage_dealers[attacker] += actual_damage
		last_hit_tower = attacker

		var dt: Node = get_tree().get_first_node_in_group("damage_tracker")
		if dt and dt.has_method("record_damage"):
			dt.record_damage(attacker, actual_damage)

		Global.debug_log("[伤害记录] %s 对 %s 造成 %.1f 伤害，累计 %.1f" % [attacker.config.get_display_name(), config.get_display_name(), actual_damage, damage_dealers[attacker]])

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

func _show_damage_number(damage: float) -> void:
	var label: Label = Label.new()
	var dmg_int: int = int(ceilf(damage))
	label.text = str(dmg_int)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.global_position = global_position + Vector2(randf_range(-15.0, 15.0), -35.0)
	label.z_index = 30
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var parent_node: Node = get_parent()
	if parent_node:
		parent_node.add_child(label)
	else:
		add_child(label)
	var tween: Tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.4)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)

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

	var valid_dealers: Array[Dictionary] = []
	for key_variant: Variant in damage_dealers.keys():
		if is_instance_valid(key_variant) and key_variant is Tower:
			valid_dealers.append({"tower": key_variant, "damage": damage_dealers[key_variant]})

	var total_damage: float = 0.0
	for entry: Dictionary in valid_dealers:
		total_damage += entry.damage

	if total_damage <= 0.0:
		Global.debug_log("[经验分配] 没有伤害记录，total_damage = 0")
		return

	Global.debug_log("[经验分配] damage_dealers 数量：%d" % valid_dealers.size())
	for entry: Dictionary in valid_dealers:
		var tower: Tower = entry.tower as Tower
		if is_instance_valid(tower) and tower.config:
			var damage_ratio: float = entry.damage / total_damage
			Global.debug_log("[经验分配]   - %s: 累计伤害 %.1f (占总伤害 %.1f%%)" % [tower.config.get_display_name(), entry.damage, damage_ratio * 100.0])

	var last_hitter: Node2D = last_hit_tower
	var killing_bonus: float = 0.2
	var participation_bonus: float = 0.1

	var damage_pool: float = float(config.experience_drop) * 0.8
	var killing_bonus_pool: float = float(config.experience_drop) * killing_bonus

	var exp_bonus: float = 0.0
	var es: Node = get_node_or_null("/root/EraSystem")
	if es and es.has_method("get_family_modifier"):
		exp_bonus = es.get_family_modifier("experience_bonus")

	for entry: Dictionary in valid_dealers:
		var tower: Tower = entry.tower as Tower
		if not is_instance_valid(tower):
			Global.debug_log("[经验分配] 跳过无效塔实例")
			continue

		var damage_ratio: float = entry.damage / total_damage
		var exp_reward: float = 0.0

		exp_reward += damage_pool * damage_ratio

		if tower == last_hitter:
			exp_reward += killing_bonus_pool

		if damage_ratio > 0.05:
			exp_reward += float(config.experience_drop) * participation_bonus

		if exp_bonus > 0.0:
			exp_reward *= (1.0 + exp_bonus)

		if exp_reward > 0.0:
			if tower:
				var final_exp: int = int(max(1, exp_reward))
				tower.add_experience(final_exp)
				var bonus_text: String = tr("EXP_BONUS_FORMAT") % (exp_bonus * 100.0) if exp_bonus > 0.0 else ""
				Global.debug_log("[经验分配] %s 获得经验 %d (伤害占比 %.1f%%%s)" % [tower.config.get_display_name() if tower.config else "未知塔", final_exp, damage_ratio * 100.0, bonus_text])

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

func _find_forward_path_index(from_pos: Vector2) -> int:
	if path_points.size() <= 1:
		return 0
	var best_seg: int = 0
	var best_dist: float = INF
	for idx: int in range(path_points.size() - 1):
		var a: Vector2 = path_points[idx]
		var b: Vector2 = path_points[idx + 1]
		var ab: Vector2 = b - a
		var ap: Vector2 = from_pos - a
		var ab_len_sq: float = ab.length_squared()
		if ab_len_sq < 0.001:
			continue
		var t: float = clampf(ap.dot(ab) / ab_len_sq, 0.0, 1.0)
		var proj: Vector2 = a + ab * t
		var d: float = from_pos.distance_to(proj)
		if d < best_dist:
			best_dist = d
			best_seg = idx
			if t > 0.5:
				best_seg = idx + 1
	return mini(best_seg, path_points.size() - 1)

func _on_split_requested(split_enemy_id: String, count: int, pos: Vector2) -> void:
	Global.debug_log("[分裂] %s 死亡分裂为 %d 个 %s" % [config.get_display_name(), count, split_enemy_id])
	var spawn_radius: float = 45.0
	for i: int in range(count):
		var split_config: EnemyConfig = EnemyConfig.get_config(split_enemy_id)
		if split_config:
			var split_enemy: Enemy = Enemy.new()
			split_enemy.initialize(split_config)
			split_enemy.spawn_offset = spawn_offset
			split_enemy.secondary_offset = secondary_offset + Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
			if waypoints.size() > 0:
				split_enemy.set_waypoints(waypoints)
			var angle: float = TAU * float(i) / float(count) + randf_range(-0.8, 0.8)
			var dist: float = spawn_radius + randf_range(-10.0, 15.0)
			var spawn_pos: Vector2 = pos + Vector2(cos(angle) * dist, sin(angle) * dist)
			split_enemy._mark_as_spawned()
			var mm: Node = get_node_or_null("/root/MapManager")
			if mm and mm.has_method("_on_enemy_reached_base"):
				split_enemy.reached_base.connect(mm._on_enemy_reached_base)
			if mm and mm.has_method("_on_enemy_killed"):
				split_enemy.died.connect(mm._on_enemy_killed)
			get_parent().add_child(split_enemy)
			split_enemy.global_position = spawn_pos
			if split_enemy.path_points.size() > 1:
				split_enemy.current_path_index = current_path_index

func _on_summon_requested(summon_configs: Array, pos: Vector2) -> void:
	var spawn_radius: float = 55.0
	var total_count: int = 0
	for entry: Dictionary in summon_configs:
		total_count += int(entry.get("count", 1))
	var global_idx: int = 0
	for entry: Dictionary in summon_configs:
		var summon_id: String = entry.get("id", "")
		var count: int = entry.get("count", 1)
		for i: int in range(count):
			var summon_config: EnemyConfig = EnemyConfig.get_config(summon_id)
			if summon_config:
				var summon_enemy: Enemy = Enemy.new()
				summon_enemy.initialize(summon_config)
				summon_enemy.spawn_offset = spawn_offset
				summon_enemy.secondary_offset = secondary_offset + Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
				if waypoints.size() > 0:
					summon_enemy.set_waypoints(waypoints)
				var angle: float = TAU * float(global_idx) / float(total_count) + randf_range(-0.3, 0.3)
				var dist: float = spawn_radius + randf_range(-5.0, 10.0)
				var spawn_pos: Vector2 = pos + Vector2(cos(angle) * dist, sin(angle) * dist)
				summon_enemy._mark_as_spawned()
				var mm: Node = get_node_or_null("/root/MapManager")
				if mm and mm.has_method("_on_enemy_reached_base"):
					summon_enemy.reached_base.connect(mm._on_enemy_reached_base)
				if mm and mm.has_method("_on_enemy_killed"):
					summon_enemy.died.connect(mm._on_enemy_killed)
				get_parent().add_child(summon_enemy)
				summon_enemy.global_position = spawn_pos
				if summon_enemy.path_points.size() > 1:
					summon_enemy.current_path_index = current_path_index
			global_idx += 1

func _on_tower_destroy_requested(target_count: int) -> void:
	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	var valid_towers: Array[Node] = []
	for t: Node in towers:
		if is_instance_valid(t) and t is Tower and not t.is_destroyed:
			if t.config and t.config.tower_id != "tower_ruins":
				valid_towers.append(t)
	for i: int in range(mini(target_count, valid_towers.size())):
		if valid_towers.is_empty():
			break
		var idx: int = randi() % valid_towers.size()
		var target_tower: Tower = valid_towers[idx] as Tower
		Global.debug_log("[BOSS] %s 消灭了塔：%s" % [config.get_display_name(), target_tower.name])
		target_tower.destroy()
		valid_towers.remove_at(idx)
