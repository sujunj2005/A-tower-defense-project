extends Node
class_name TowerAttackComponent

# 引入依赖
const AttackMode = GameConfig.AttackMode
const ProjectileType = GameConfig.ProjectileType
const EffectType = GameConfig.EffectType
const DetectionState = GameConfig.DetectionState
const WindupState = GameConfig.WindupState

## 公共属性
var config: TowerBean
var tower: Tower
var target: Node2D = null

## 状态机属性
var detection_state: DetectionState = DetectionState.IDLE
var windup_state: WindupState = WindupState.IDLE

## 计时器
var attack_timer: Timer
var windup_timer: float = 0.0
var committed_target: Node2D = null  # 前摇期间锁定的目标（承诺机制）

## 回调信号（用于特效系统等）
signal attack_executed(target: Node2D, damage: float)
signal windup_started(target: Node2D)
signal windup_completed(target: Node2D)

func _ready():
	setup_timer()

func setup_timer():
	if not config:
		return
	
	if config.attack_speed <= 0:
		push_error("[塔 %s] attack_speed 为 %.2f，无法启动攻击定时器！" % [config.get_display_name(), config.attack_speed])
		return
	
	if attack_timer:
		attack_timer.stop()
		attack_timer.queue_free()
		attack_timer = null
	
	var effective_speed: float = config.attack_speed
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if ts and ts.has_method("get_attack_speed_bonus_for_tower"):
		var tower_type: String = config.tower_id if config else ""
		var speed_bonus: float = ts.get_attack_speed_bonus_for_tower(tower_type)
		effective_speed = config.attack_speed * (1.0 + speed_bonus)
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0 / effective_speed
	attack_timer.autostart = true
	attack_timer.timeout.connect(_on_attack_cycle)
	add_child(attack_timer)

## 每帧更新（用于前摇计时）
func _process(delta):
	if Global.soft_paused:
		return
	if windup_state == WindupState.WINDUP_ACTIVE:
		update_windup(delta)

## ==================== 攻击周期主循环 ====================
func _on_attack_cycle():
	if Global.soft_paused:
		return
	# 阶段 1: 索敌（Detection）
	find_target()

	if not target:
		# 无目标，保持空闲
		detection_state = DetectionState.IDLE
		windup_state = WindupState.IDLE
		return

	# 检查目标是否在攻击范围内
	var distance = tower.global_position.distance_to(target.global_position)
	if distance > config.attack_range:
		# 目标不在攻击范围，等待下一周期
		return

	# 阶段2: 检查是否需要前摇（Windup）
	if config.windup_duration > 0 and windup_state == WindupState.IDLE:
		start_windup()
		return  # 等待前摇完成

	# 阶段3: 执行攻击（Attack）
	if windup_state == WindupState.COMMITTED or config.windup_duration <= 0:
		execute_attack()

## ==================== 前摇状态机（Windup System）====================

## 开始前摇
func start_windup():
	# 前摇开始条件检查（必须同时满足）
	# 条件 A: 当前没有正在执行的前摇
	if windup_state != WindupState.IDLE:
		return
	
	# 条件 B: 存在有效目标
	if not target or not is_instance_valid(target):
		return
	
	# 条件 C: 目标当前在攻击范围内
	var distance: float = tower.global_position.distance_to(target.global_position)
	if distance > config.attack_range:
		return
	
	# ✅ 所有条件满足，启动前摇
	windup_state = WindupState.WINDUP_ACTIVE
	windup_timer = config.windup_duration
	committed_target = target  # 锁定目标（承诺机制）
	
	# 发射信号（可用于播放前摇动画）
	windup_started.emit(committed_target)

## 更新前摇计时器
func update_windup(delta: float):
	if windup_state != WindupState.WINDUP_ACTIVE:
		return
	
	windup_timer -= delta
	
	# 检查目标是否仍然有效（场景 3: 目标死亡）
	if not is_instance_valid(committed_target):
		cancel_windup()
		return
	
	# 前摇时间到达
	if windup_timer <= 0:
		windup_state = WindupState.COMMITTED
		windup_completed.emit(committed_target)
		
		# 立即执行攻击（不等待下一个 timer 周期）
		execute_attack()

## 取消前摇
func cancel_windup():
	windup_state = WindupState.IDLE
	windup_timer = 0.0
	committed_target = null
	detection_state = DetectionState.IDLE

## ==================== 攻击执行（Attack Execution）====================

## 执行攻击（根据攻击模式分支）
func execute_attack():
	# 使用承诺的目标（如果存在），否则使用当前目标
	var attack_target = committed_target if committed_target else target

	# 最终有效性检查
	if not attack_target or not is_instance_valid(attack_target):
		cancel_windup()
		return

	detection_state = DetectionState.ATTACKING

	match config.attack_mode:
		AttackMode.MELEE:
			perform_melee_attack(attack_target)
		AttackMode.RANGED:
			perform_ranged_attack(attack_target)
		_:
			push_error("[塔 %s] 未知的攻击模式: %d" % [config.get_display_name(), config.attack_mode])

	# 阶段4: 触发特效
	execute_effects(attack_target)

	# 阶段5: 进入冷却（由Timer自动处理）
	detection_state = DetectionState.COOLDOWN

	# 重置前摇状态
	reset_windup_state()

## 近战攻击：AOE 范围伤害（对所有范围内敌人造成伤害）
func perform_melee_attack(attack_target: Node2D):
	_play_melee_attack_animation()
	var trait_bonus: float = _get_trait_damage_bonus()
	var final_damage: float = config.damage * (1.0 + trait_bonus)
	var enemies_hit_count: int = 0
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue
		var distance_to_enemy: float = tower.global_position.distance_to(enemy.global_position)
		if distance_to_enemy <= config.attack_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(final_damage, config.damage_type, tower)
				enemies_hit_count += 1
	
	attack_executed.emit(attack_target, final_damage)
	
	if enemies_hit_count > 0:
		print("[近战攻击] %s 攻击范围内命中 %d 个敌人，每个 %.0f 伤害" % [config.get_display_name(), enemies_hit_count, final_damage])

## 🆕 播放近战攻击动画
func _play_melee_attack_animation() -> void:
	if not tower or not tower.tower_sprite:
		return
	
	# 使用 Tween 实现简单的攻击动画：快速放大后恢复
	var tween: Tween = tower.create_tween()
	
	# 攻击时短暂放大（模拟挥击动作）
	tween.tween_property(tower.tower_sprite, "scale", Vector2(1.0, 1.0), 0.05)  # 原始大小
	tween.tween_property(tower.tower_sprite, "scale", Vector2(1.2, 1.2), 0.08)   # 放大 120%
	tween.tween_property(tower.tower_sprite, "scale", Vector2(0.9, 0.9), 0.06)   # 收缩 90%
	tween.tween_property(tower.tower_sprite, "scale", Vector2(1.0, 1.0), 0.04)   # 恢复原始大小

## 远程攻击：生成弹道实例
func perform_ranged_attack(attack_target: Node2D):
	_play_ranged_attack_animation()
	var trait_bonus: float = _get_trait_damage_bonus()
	var final_damage: float = config.damage * (1.0 + trait_bonus)
	var pbean: ProjectileBean = TowerConfig.create_projectile_bean(config)
	if pbean and pbean.projectile_type == GameConfig.ProjectileType.TARGET_LOCKED:
		var projectile = create_projectile_from_bean(pbean, attack_target, final_damage)
		if projectile:
			attack_executed.emit(attack_target, final_damage)
	else:
		push_error("[塔 %s] 远程攻击未配置弹道！" % config.get_display_name())
		perform_melee_attack(attack_target)

func _play_ranged_attack_animation() -> void:
	if not tower or not tower.tower_sprite:
		return
	var tween: Tween = tower.create_tween()
	tween.tween_property(tower.tower_sprite, "scale", Vector2(0.85, 1.15), 0.04)
	tween.tween_property(tower.tower_sprite, "scale", Vector2(1.0, 1.0), 0.08)

## 从 ProjectileBean 创建弹道
func create_projectile_from_bean(pbean: ProjectileBean, attack_target: Node2D, final_damage: float = -1.0) -> Projectile:
	var projectile_scene_path = "res://scenes/projectile.tscn"
	if not ResourceLoader.exists(projectile_scene_path):
		push_error("[塔 %s] 弹道场景不存在：%s" % [config.get_display_name(), projectile_scene_path])
		return null
	var projectile_scene = load(projectile_scene_path) as PackedScene
	if not projectile_scene:
		push_error("[塔 %s] 无法加载弹道场景：%s" % [config.get_display_name(), projectile_scene_path])
		return null
	var projectile = projectile_scene.instantiate() as Projectile
	if not projectile:
		push_error("[塔 %s] 弹道实例化失败！" % config.get_display_name())
		return null
	projectile.bean = pbean
	projectile.source_tower = tower
	projectile.global_position = tower.global_position
	
	# 添加到场景中
	if tower.get_parent():
		tower.get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
	
	# 设置弹道目标
	if projectile.has_method("set_target"):
		var dmg: float = final_damage if final_damage >= 0.0 else config.damage
		projectile.set_target(attack_target, dmg)
	
	return projectile

## 🆕 设置旧版弹道（兼容 PackedScene 方式）
func setup_legacy_projectile(projectile: Projectile, attack_target: Node2D, final_damage: float = -1.0):
	# 设置弹道起始位置
	projectile.global_position = tower.global_position
	
	# 🆕 设置来源塔（用于经验分配）
	projectile.source_tower = tower
	
	# 从配置中读取弹道属性
	projectile.projectile_type = config.projectile_type
	projectile.speed = config.projectile_speed
	projectile.effect_type = config.effect_type
	projectile.effect_radius = config.effect_radius
	projectile.pierce_enabled = config.pierce_enabled
	projectile.pierce_count = config.pierce_count
	
	# 添加到场景中（添加到塔的父节点，避免随塔移动）
	if tower.get_parent():
		tower.get_parent().add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
	
	# 设置弹道目标
	if projectile.has_method("set_target"):
		var dmg: float = final_damage if final_damage >= 0.0 else config.damage
		projectile.set_target(attack_target, dmg)

## ==================== 特效系统（Effects System）====================

## 执行攻击特效
func execute_effects(primary_target: Node2D):
	if not config or config.effect_type == EffectType.NONE:
		return
	
	match config.effect_type:
		EffectType.PIERCE:
			# PIERCE 由弹道系统内部处理
			pass
		EffectType.SPLASH:
			apply_splash_effect(primary_target)
		EffectType.SLOW:
			apply_slow_effect(primary_target)
		EffectType.DOT:
			apply_dot_effect(primary_target)
		EffectType.KNOCKBACK:
			apply_knockback_effect(primary_target)
		EffectType.LIFESTEAL:
			apply_lifesteal_effect(primary_target)

## AOE范围爆炸特效
func apply_splash_effect(center_target: Node2D):
	if not center_target or not is_instance_valid(center_target):
		return

	var splash_damage = config.damage * config.effect_damage_ratio
	var enemies_hit = 0

	# 获取所有敌人
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy == center_target:
			continue  # 主目标已在攻击时造成伤害

		# 检查是否在 AOE 范围内
		var distance = center_target.global_position.distance_to(enemy.global_position)
		if distance <= config.effect_radius:
			# 🆕 造成 AOE 伤害（传递 tower 参数）
			if enemy.has_method("take_damage"):
				enemy.take_damage(splash_damage, config.damage_type, tower)
				enemies_hit += 1

			# 检查是否达到最大目标数
			if enemies_hit >= config.effect_max_targets:
				break

	print("[特效] SPLASH爆炸! 半径%.0fpx, 伤害%.0f, 命中%d个额外目标" % [
		config.effect_radius, splash_damage, enemies_hit
	])

## 减速特效
func apply_slow_effect(slow_target: Node2D):
	if not slow_target or not is_instance_valid(slow_target):
		return

	if slow_target.has_method("apply_slow"):
		slow_target.apply_slow(config.effect_value, 1.0)  # 默认持续 1 秒
	else:
		print("[特效] 目标不支持减速效果")

## 持续伤害特效
func apply_dot_effect(dot_target: Node2D):
	if not dot_target or not is_instance_valid(dot_target):
		return

	if dot_target.has_method("apply_dot"):
		# 🆕 传递 source_tower 参数，用于 DOT 伤害的经验分配
		dot_target.apply_dot(config.effect_value, 3.0, config.damage_type, tower)
	else:
		print("[特效] 目标不支持 DOT 效果")

## 击退特效
func apply_knockback_effect(knockback_target: Node2D):
	if not knockback_target or not is_instance_valid(knockback_target):
		return

	if knockback_target.has_method("apply_knockback"):
		var direction: Vector2 = (knockback_target.global_position - tower.global_position).normalized()
		knockback_target.apply_knockback(direction, config.effect_radius)
	else:
		print("[特效] 目标不支持击退效果")

## 吸血特效
func apply_lifesteal_effect(lifesteal_target: Node2D):
	if not lifesteal_target or not is_instance_valid(lifesteal_target):
		return

	# 吸血效果需要塔有治疗功能，暂时仅记录
	print("[特效] LIFESTEAL 吸血效果尚未实现")

## ==================== 辅助方法 ====================

## 重置前摇状态
func reset_windup_state():
	windup_state = WindupState.IDLE
	windup_timer = 0.0
	committed_target = null

## 索敌逻辑（查找范围内最近的敌人）
func find_target():
	target = null
	if not tower or not config:
		return
	
	# 近战模式：使用攻击范围作为索敌范围（无额外索敌范围）
	# 远程模式：使用索敌范围（如果配置了）或攻击范围
	var range_val: float
	if config.attack_mode == AttackMode.MELEE:
		range_val = config.attack_range  # 近战直接用攻击范围
	else:
		range_val = config.detection_range if config.detection_range > 0 else config.attack_range
	
	var closest_dist = range_val
	var closest_enemy: Node2D = null
	
	detection_state = DetectionState.DETECTING
	
	var enemies = tower.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = tower.global_position.distance_to(enemy.global_position)
		if dist <= closest_dist:
			closest_dist = dist
			closest_enemy = enemy
	
	target = closest_enemy
	
	if target:
		detection_state = DetectionState.TRACKING
	else:
		detection_state = DetectionState.IDLE
	
	# 同步到塔对象
	if tower:
		tower.set_target(target)

## 获取当前状态信息（用于调试和UI显示）
func get_state_info() -> Dictionary:
	return {
		"detection_state": detection_state,
		"windup_state": windup_state,
		"target": target,
		"committed_target": committed_target,
		"windup_timer_remaining": windup_timer,
		"is_attacking": detection_state == DetectionState.ATTACKING,
		"in_windup": windup_state == WindupState.WINDUP_ACTIVE,
		"in_cooldown": detection_state == DetectionState.COOLDOWN
	}

## 打印配置信息（用于调试）
func debug_print_config():
	if not config:
		print("[DEBUG] 配置为空")
		return
	
	print("[DEBUG] 塔配置信息:")
	print("  塔名: %s" % config.get_display_name())
	print("  攻击模式: %d (MELEE=0, RANGED=1)" % config.attack_mode)
	print("  攻击范围: %.0f" % config.attack_range)
	print("  索敌范围: %.0f" % config.detection_range)
	print("  前摇时长: %.2f" % config.windup_duration)
	print("  弹道场景路径: %s" % config.projectile_scene_path)
	print("  弹道类型: %d (TARGET_LOCKED=0, POSITION_FIXED=1)" % config.projectile_type)
	print("  穿透启用: %s" % str(config.pierce_enabled))
	print("  穿透数量: %d" % config.pierce_count)
	print("  特效类型: %d" % config.effect_type)

func _get_trait_damage_bonus() -> float:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if not ts or not ts.has_method("get_trait_effects_for_tower"):
		return 0.0
	var tower_type: String = ""
	if config:
		tower_type = config.tower_id
	return ts.get_trait_effects_for_tower(tower_type)
