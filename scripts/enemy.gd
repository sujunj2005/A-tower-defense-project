extends Node2D
class_name Enemy

signal died(enemy: Enemy)
signal reached_base(enemy: Enemy)

var config: EnemyConfig
var current_health: float
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var enemy_sprite: Sprite2D
var health_bar: ProgressBar  # 🆕 血条 UI

## 🆕 V2.1 新增：特效状态变量
var base_move_speed: float = 0.0  # 基础移动速度（用于减速效果恢复）
var slow_timer: float = 0.0  # 减速计时器
var slow_amount: float = 0.0  # 减速比例（0.0-1.0）
var is_slowed: bool = false  # 是否正在被减速

## 🆕 V2.1 新增：持续伤害(DOT)状态
var dot_damage_per_second: float = 0.0  # DOT每秒伤害
var dot_timer: float = 0.0  # DOT计时器
var dot_duration: float = 0.0  # DOT总持续时间
var dot_elapsed: float = 0.0  # DOT已持续时间
var dot_damage_type: int = 0  # DOT伤害类型
var is_dot_active: bool = false  # DOT是否激活

## 🆕 V2.1 新增：击退状态
var knockback_velocity: Vector2 = Vector2.ZERO  # 击退速度向量
var knockback_duration: float = 0.0  # 击退持续时间
var knockback_timer: float = 0.0  # 击退计时器
var is_being_knocked_back: bool = false  # 是否正在被击退

## 🆕 伤害追踪系统（用于经验分配）
var damage_dealers: Dictionary = {}  # {tower: total_damage}
var last_hit_tower: Node2D = null  # 最后一次造成伤害的塔

func _ready() -> void:
	add_to_group("enemies")

func initialize(enemy_config: EnemyConfig) -> void:
	config = enemy_config
	current_health = config.max_health
	base_move_speed = config.move_speed  # 🆕 记录基础速度
	
	setup_sprite()
	setup_health_bar()  # 🆕 创建血条

func setup_sprite() -> void:
	if not config:
		push_error("[Enemy] 配置为空！")
		return
	
	enemy_sprite = Sprite2D.new()

	if config.texture_path != "":
		# 使用 AssetsManager 加载纹理
		var texture = AssetsManager.load_image(config.texture_path) as Texture2D
		if texture:
			enemy_sprite.texture = texture
		else:
			push_error("[Enemy] 加载纹理失败：%s" % config.texture_path)
	else:
		print("[Enemy] 纹理路径为空")
	
	enemy_sprite.scale = Vector2(0.5, 0.5)
	enemy_sprite.z_index = 5
	add_child(enemy_sprite)

func setup_health_bar() -> void:
	# 🆕 创建血条 UI（在怪物头顶）
	var health_bar_container = MarginContainer.new()
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
	
	# 设置血条背景样式
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	bg_style.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("background", bg_style)
	
	# 设置血条填充样式
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.2, 1.0)  # 绿色血条
	fill_style.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("fill", fill_style)
	
	health_bar_container.add_child(health_bar)

func set_path(points: Array[Vector2]) -> void:
	path_points = points
	current_path_index = 0
	if path_points.size() > 0:
		global_position = path_points[0]

func _process(delta: float) -> void:
	# 🆕 更新特效状态
	update_effect_states(delta)

	# 正常路径移动逻辑
	if path_points.is_empty():
		return

	if current_path_index >= path_points.size():
		reached_base.emit(self)
		queue_free()
		return

	var target_pos = path_points[current_path_index]
	var direction = (target_pos - global_position).normalized()

	# 🆕 获取实际移动速度（考虑减速效果）
	var actual_speed = get_effective_move_speed()
	var move_distance = actual_speed * delta

	if global_position.distance_to(target_pos) <= move_distance:
		global_position = target_pos
		current_path_index += 1
	else:
		global_position += direction * move_distance

## 🆕 V2.1 新增：更新所有特效状态
func update_effect_states(delta: float) -> void:
	# 更新减速状态
	update_slow_effect(delta)

	# 更新 DOT 状态
	update_dot_effect(delta)

	# 更新击退状态
	update_knockback_effect(delta)

## ==================== 🆕 特效接收接口 ====================

## 应用减速效果
## speed_reduction: 减速比例 (0.0-1.0), 例如 0.3 表示降低 30% 速度
## duration: 持续时间（秒）
func apply_slow(speed_reduction: float, duration: float) -> void:
	if not config:
		return
	
	# 确保减速比例在合理范围内
	speed_reduction = clampf(speed_reduction, 0.0, 0.95)  # 最大降低 95%，避免完全停止
	
	slow_amount = speed_reduction
	slow_timer = duration
	is_slowed = true

## 更新减速效果计时器
func update_slow_effect(delta: float) -> void:
	if not is_slowed:
		return

	slow_timer -= delta
	if slow_timer <= 0:
		# 减速结束，恢复正常速度
		is_slowed = false
		slow_amount = 0.0
		slow_timer = 0.0
		#print("[敌人 %s] 减速效果结束" % [config.enemy_name if config else "未知"])

## 获取实际移动速度（考虑减速效果）
func get_effective_move_speed() -> float:
	if not config:
		return 0.0

	# 如果正在被击退，返回击退速度
	if is_being_knocked_back:
		return knockback_velocity.length()

	# 如果正在被减速，应用减速比例
	if is_slowed:
		return base_move_speed * (1.0 - slow_amount)

	# 正常速度
	return base_move_speed

## 应用持续伤害 (DOT) 效果
## damage_per_sec: 每秒造成的伤害
## duration: 总持续时间（秒）
## damage_type: 伤害类型 (0=物理，1=魔法)
## source_tower: 施加 DOT 的防御塔（用于经验分配）
func apply_dot(damage_per_sec: float, duration: float, damage_type: int = 0, source_tower: Node2D = null) -> void:
	if not config:
		return
	
	dot_damage_per_second = damage_per_sec
	dot_duration = duration
	dot_elapsed = 0.0
	dot_timer = 1.0  # 每秒造成一次伤害
	dot_damage_type = damage_type
	is_dot_active = true
	
	# 🆕 记录 DOT 施加者（用于后续 DOT 伤害的经验分配）
	if source_tower and source_tower is Tower:
		if not damage_dealers.has(source_tower):
			damage_dealers[source_tower] = 0.0

## 更新 DOT 效果计时器
func update_dot_effect(delta: float) -> void:
	if not is_dot_active or not config:
		return

	dot_elapsed += delta
	dot_timer -= delta

	# 每秒造成一次伤害
	if dot_timer <= 0:
		dot_timer = 1.0  # 重置为 1 秒
		# 🆕 查找施加 DOT 的塔（从 damage_dealers 中找第一个有 DOT 伤害记录的）
		var dot_applier: Node2D = null
		if damage_dealers.size() > 0:
			# 简单处理：使用最后造成伤害的塔（假设 DOT 来自它）
			dot_applier = last_hit_tower
		take_damage(dot_damage_per_second, dot_damage_type, dot_applier)
		#print("[敌人 %s] DOT 伤害 %.0f" % [config.enemy_name, dot_damage_per_second])

	# 检查DOT是否结束
	if dot_elapsed >= dot_duration:
		is_dot_active = false
		dot_damage_per_second = 0.0
		dot_elapsed = 0.0
		print("[敌人 %s] DOT效果结束" % [config.enemy_name if config else "未知"])

## 应用击退效果
## direction: 击退方向（单位向量）
## distance: 击退距离（像素）
func apply_knockback(direction: Vector2, distance: float) -> void:
	if not config:
		return
	
	# 计算击退速度（在 0.3 秒内完成击退）
	var knockback_time: float = 0.3
	knockback_velocity = direction * distance / knockback_time
	knockback_duration = knockback_time
	knockback_timer = knockback_time
	is_being_knocked_back = true

## 更新击退效果
func update_knockback_effect(delta: float) -> void:
	if not is_being_knocked_back:
		return

	knockback_timer -= delta

	# 应用击退位移
	global_position += knockback_velocity * delta

	if knockback_timer <= 0:
		# 击退结束
		is_being_knocked_back = false
		knockback_velocity = Vector2.ZERO
		knockback_timer = 0.0
		#print("[敌人 %s] 击退结束" % [config.enemy_name if config else "未知"])

## ==================== 原有功能（保持不变）====================

func take_damage(amount: float, damage_type: int, attacker: Node2D = null) -> void:
	if not config:
		return
	
	# 🆕 播放被击中动画
	_play_hit_animation()
	
	var resistance: float
	if damage_type == DamageTypes.Type.PHYSICAL:
		resistance = config.physical_resistance
	else:
		resistance = config.magical_resistance
	
	var actual_damage: float = amount * (1.0 - resistance)
	current_health -= actual_damage
	
	# 🆕 记录伤害来源并给予微量经验
	if attacker and attacker is Tower:
		if not damage_dealers.has(attacker):
			damage_dealers[attacker] = 0.0
		damage_dealers[attacker] += actual_damage
		last_hit_tower = attacker
		
		# 🆕 调试输出
		print("[伤害记录] %s 对 %s 造成 %.1f 伤害，累计 %.1f" % [attacker.config.tower_name, config.enemy_name, actual_damage, damage_dealers[attacker]])
		
		# 🆕 每次造成伤害获得微量经验（1 点）
		if attacker.config and attacker.config.experience_on_hit > 0:
			attacker.add_experience(attacker.config.experience_on_hit)
	else:
		# 🆕 没有攻击者（塔已被销毁），只造成伤害不记录
		pass  # 伤害已经计算，不需要额外处理
	
	# 更新血条显示
	update_health_bar()
	
	if current_health <= 0:
		die()

## 🆕 播放被击中动画（闪白效果）
func _play_hit_animation() -> void:
	if not enemy_sprite:
		return
	
	# 使用 Tween 实现简单的闪白效果（模拟受击反馈）
	var tween: Tween = create_tween()
	
	# 保存原始颜色
	var original_color: Color = enemy_sprite.modulate
	
	# 快速闪白 → 红色 → 恢复原始颜色
	tween.tween_property(enemy_sprite, "modulate", Color(3, 3, 3, 1), 0.05)    # 闪白（高亮）
	tween.tween_property(enemy_sprite, "modulate", Color(2, 0.2, 0.2, 1), 0.08) # 红色（受伤）
	tween.tween_property(enemy_sprite, "modulate", original_color, 0.07)        # 恢复原始颜色

func update_health_bar() -> void:
	# 🆕 更新血条显示
	if health_bar:
		health_bar.value = current_health
		# 🆕 根据血量比例改变血条颜色
		var health_ratio = current_health / config.max_health
		if health_ratio > 0.6:
			health_bar.get_theme_stylebox("fill").bg_color = Color(0.2, 0.8, 0.2, 1.0)  # 绿色
		elif health_ratio > 0.3:
			health_bar.get_theme_stylebox("fill").bg_color = Color(0.8, 0.8, 0.2, 1.0)  # 黄色
		else:
			health_bar.get_theme_stylebox("fill").bg_color = Color(0.8, 0.2, 0.2, 1.0)  # 红色

func die() -> void:
	# 🆕 发放击杀奖励
	if config and config.gold_drop > 0:
		# 查找 game_hud
		var game_hud = get_node_or_null("/root/MapManager/GameHUD")
		if not game_hud:
			game_hud = get_tree().get_first_node_in_group("game_hud")
		
		if game_hud:
			# 发放金币
			if game_hud.has_method("add_gold"):
				game_hud.add_gold(config.gold_drop)
				print("[Enemy] 发放金币：%d" % config.gold_drop)  # 🆕 调试输出
			
			# 🆕 按伤害分配经验值
			if damage_dealers.size() > 0:
				distribute_experience(game_hud)
			else:
				# 如果没有伤害记录，平均分配给所有塔
				var towers = get_tree().get_nodes_in_group("towers")
				if towers.size() > 0 and game_hud.has_method("add_tower_experience"):
					var exp_per_tower: float = float(config.experience_drop) / float(towers.size())
					for tower in towers:
						if tower is Tower:
							tower.add_experience(int(exp_per_tower))
							print("[Enemy] 平均分配经验：%d" % int(exp_per_tower))  # 🆕 调试输出
	
	died.emit(self)
	queue_free()

## 🆕 按伤害比例分配经验值
func distribute_experience(game_hud: Node) -> void:
	if not game_hud or not game_hud.has_method("add_tower_experience"):
		return
	
	var total_damage = 0.0
	for tower in damage_dealers:
		total_damage += damage_dealers[tower]
	
	if total_damage <= 0:
		print("[经验分配] 没有伤害记录，total_damage = 0")
		return
	
	# 🆕 调试输出：显示伤害记录
	print("[经验分配] damage_dealers 数量：%d" % damage_dealers.size())
	for tower in damage_dealers:
		if is_instance_valid(tower) and tower.config:
			var damage_ratio = damage_dealers[tower] / total_damage
			print("[经验分配]   - %s: 累计伤害 %.1f (占总伤害 %.1f%%)" % [tower.config.tower_name, damage_dealers[tower], damage_ratio * 100])
	
	var last_hitter = last_hit_tower
	var killing_bonus = 0.2  # 击杀奖励 20%
	var participation_bonus = 0.1  # 参与奖励 10%
	
	# 计算基础经验池（总经验的 80% 按伤害比例分配）
	var damage_pool = float(config.experience_drop) * 0.8
	# 最后一击奖励池（20%）
	var killing_bonus_pool = float(config.experience_drop) * killing_bonus
	
	for tower in damage_dealers:
		if not is_instance_valid(tower):
			print("[经验分配] 跳过无效塔实例")
			continue
		
		var damage_ratio = damage_dealers[tower] / total_damage
		var exp_reward = 0.0
		
		# 按伤害比例分配基础经验
		exp_reward += damage_pool * damage_ratio
		
		# 最后一击奖励
		if tower == last_hitter:
			exp_reward += killing_bonus_pool
		
		# 参与奖励（只要造成伤害就有）
		if damage_ratio > 0.05:  # 至少造成 5% 伤害
			exp_reward += float(config.experience_drop) * participation_bonus
		
		# 确保至少获得 1 点经验
		if exp_reward > 0:
			tower.add_experience(int(max(1, exp_reward)))
			print("[经验分配] %s 获得经验 %d (伤害占比 %.1f%%)" % [tower.config.tower_name if tower.config else "未知塔", int(exp_reward), damage_ratio * 100])

func get_current_health() -> float:
	return current_health

## 🆕 获取当前特效状态信息（用于调试和UI显示）
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
