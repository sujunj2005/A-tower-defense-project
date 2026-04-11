extends Area2D
class_name Projectile

# 引入枚举类型
const ProjectileType = preload("res://scripts/config/attack_types.gd").ProjectileType
const EffectType = preload("res://scripts/config/attack_effects.gd").EffectType

## ==================== 公共属性 ====================

## 弹道基础属性
var damage: float = 10.0
var damage_type: int = 0  # 0=物理，1=魔法
var speed: float = 300.0  # 飞行速度（像素/秒）
var source_tower: Tower = null  # 来源塔引用

## 弹道类型相关
var projectile_type: int = ProjectileType.POSITION_FIXED  # 弹道类型
var target_ref: WeakRef = null  # 目标弱引用（TARGET_LOCKED 用）
var target_position: Vector2 = Vector2.ZERO  # 固定终点坐标（POSITION_FIXED 用）
var start_position: Vector2 = Vector2.ZERO  # 发射位置

## 穿透系统（PIERCE）
var pierce_enabled: bool = false
var pierce_count: int = 2  # 最大穿透数
var pierce_damage_decay: float = 0.7  # 衰减系数
var current_pierce_count: int = 0  # 已穿透数
var hit_enemies: Array = []  # 已命中敌人列表（避免重复）

## 特效配置
var effect_type: int = EffectType.NONE
var effect_radius: float = 50.0
var effect_damage_ratio: float = 0.5
var effect_max_targets: int = 3

## 状态标志
var is_active: bool = false
var has_hit_target: bool = false

## 视觉组件
var sprite: Sprite2D
var particles: GPUParticles2D
var trail_particles: GPUParticles2D

## 配置对象
var config: ProjectileConfig = null  # ProjectileConfig 配置

## 命中阈值（距离小于此值视为命中）
const HIT_THRESHOLD: float = 5.0

## 最大飞行距离（超过此距离自动销毁）
const MAX_TRAVEL_DISTANCE: float = 2000.0

signal hit_target(target: Node2D, damage: float)
signal projectile_destroyed(projectile: Projectile)

func _ready():
	# 设置碰撞层（用于碰撞检测）
	collision_layer = 2  # 弹道层
	collision_mask = 4   # 敌人群组层
	monitoring = true
	monitorable = true

	# 连接信号
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	# 根据配置初始化视觉和属性
	if config:
		setup_from_config()
	else:
		setup_default_visual()

func _process(delta):
	if not is_active:
		return
	
	match projectile_type:
		ProjectileType.TARGET_LOCKED:
			update_target_locked_movement(delta)
		ProjectileType.POSITION_FIXED:
			update_position_fixed_movement(delta)

	# 检查是否超过最大飞行距离
	if global_position.distance_to(start_position) > MAX_TRAVEL_DISTANCE:
		on_max_distance_reached()

## ==================== 初始化方法 ====================

## 🆕 设置目标（由 TowerAttackComponent 调用）
func set_target(target: Node2D, dmg: float) -> void:
	if not target or not is_instance_valid(target):
		push_error("[弹道] 目标无效！")
		return
	
	damage = dmg
	target_ref = weakref(target)
	target_position = target.global_position
	start_position = global_position
	# 使用配置中的弹道类型，如果没有配置则默认为 POSITION_FIXED
	is_active = true

## 初始化弹道参数（由 TowerAttackComponent 调用）
func setup(setup_data: Dictionary) -> void:
	damage = setup_data.get("damage", 10.0)
	damage_type = setup_data.get("damage_type", 0)
	speed = setup_data.get("speed", 300.0)
	source_tower = setup_data.get("source_tower", null)

	projectile_type = setup_data.get("projectile_type", ProjectileType.POSITION_FIXED)

	var target = setup_data.get("target", null)
	if target and is_instance_valid(target):
		if projectile_type == ProjectileType.TARGET_LOCKED:
			# 目标锁定型：保存弱引用
			target_ref = weakref(target)
		else:
			# 坐标指定型：记录固定坐标
			target_position = target.global_position

	# 记录发射位置
	start_position = global_position

	# 穿透配置
	pierce_enabled = setup_data.get("pierce_enabled", false)
	pierce_count = setup_data.get("pierce_count", 2)
	pierce_damage_decay = setup_data.get("pierce_damage_decay", 0.7)

	effect_type = setup_data.get("effect_type", EffectType.NONE)
	effect_radius = setup_data.get("effect_radius", 50.0)
	effect_damage_ratio = setup_data.get("effect_damage_ratio", 0.5)
	effect_max_targets = setup_data.get("effect_max_targets", 3)

	# 激活弹道
	is_active = true
	current_pierce_count = 0
	hit_enemies.clear()
	has_hit_target = false

	print("[弹道] 初始化完成, 类型=%s, 伤害=%.0f, 速度=%.0f" % [
		"TARGET_LOCKED" if projectile_type == ProjectileType.TARGET_LOCKED else "POSITION_FIXED",
		damage,
		speed
	])

## 从配置初始化弹道
func setup_from_config():
	if not config:
		return
	
	# 设置基础属性
	damage = config.damage
	damage_type = config.damage_type
	speed = config.speed
	projectile_type = config.movement_type
	
	# 设置穿透配置
	pierce_enabled = config.pierce_enabled
	pierce_count = config.pierce_count
	pierce_damage_decay = config.pierce_damage_decay
	
	# 设置特效配置
	effect_type = config.effect_type
	effect_radius = config.effect_radius
	effect_damage_ratio = config.effect_damage_ratio
	effect_max_targets = config.effect_max_targets
	
	# 设置碰撞体半径
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape is CollisionShape2D:
		var shape = CircleShape2D.new()
		shape.radius = config.collision_radius
		collision_shape.shape = shape
	
	# 创建视觉组件
	config.setup_visuals(self)

## 设置默认视觉外观（占位，实际外观由场景文件提供）
func setup_default_visual():
	# 注意：实际视觉外观应由具体的弹道场景文件（.tscn）提供
	# 本方法仅作为后备方案，使用简单的 ColorRect 作为占位
	# 由于场景文件已经有 Sprite2D，此方法不需要再创建视觉元素
	# 保持 sprite = null 让场景中的 Sprite2D 生效
	sprite = null  # 禁用 sprite 引用，使用场景中的 Sprite2D
	
	# 如果场景中的 Sprite2D 没有 texture，添加一个圆形作为可见形状
	var sprite_node = get_node_or_null("Sprite2D")
	if sprite_node and sprite_node is Sprite2D:
		if sprite_node.texture == null:
			# 创建一个圆形作为可见形状
			var circle = Polygon2D.new()
			circle.name = "Circle"
			circle.color = Color(1.0, 1.0, 0.0, 1.0)  # 黄色
			var points = []
			var radius = 12.0
			for i in range(16):
				var angle = (i / 16.0) * TAU
				points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
			circle.polygon = points
			sprite_node.add_child(circle)

## ==================== 运动更新方法 ====================

## TARGET_LOCKED 模式：动态追踪目标
func update_target_locked_movement(delta: float):
	# 获取实际目标
	var actual_target = get_actual_target()
	if not actual_target:
		# 目标已失效，销毁弹道
		destroy()
		return

	# 🎯 动态计算方向向量（每帧更新！）
	var direction = (actual_target.global_position - global_position).normalized()

	# 移动弹道
	var previous_position = global_position
	global_position += direction * speed * delta

	# 更新朝向（可选：让弹道面向移动方向）
	rotation = direction.angle()

	# 检测是否命中目标（基于距离阈值）
	if global_position.distance_to(actual_target.global_position) < HIT_THRESHOLD:
		on_hit_target(actual_target)

## POSITION_FIXED 模式：沿固定方向飞行
func update_position_fixed_movement(delta: float):
	# 方向固定不变
	var direction = (target_position - start_position).normalized()

	# 移动弹道
	var previous_position = global_position
	global_position += direction * speed * delta

	# 更新朝向
	rotation = direction.angle()

	# 🆕 检测是否命中路径上的敌人（使用 Area2D 的碰撞检测）
	check_enemy_collision()

	# 检测是否到达目标点
	if global_position.distance_to(target_position) < HIT_THRESHOLD:
		on_reach_target()
		return

	# 🆕 PIERCE 检测（射线检测路径上的敌人）
	if pierce_enabled and current_pierce_count < pierce_count:
		check_pierce_collision(previous_position, global_position)

## 检测敌人碰撞（POSITION_FIXED 模式使用）
func check_enemy_collision():
	# 获取重叠的敌人
	var enemies = get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemies"):
			on_hit_target(enemy)
			return
	
	# 也检查 Area2D 类型的敌人
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies"):
			# 从 Area2D 获取敌人节点（通常是父节点）
			var enemy = area if area is Node2D else area.get_parent()
			if enemy and enemy.is_in_group("enemies"):
				on_hit_target(enemy)
				return

## 信号处理：Area2D 进入
func _on_area_entered(area: Area2D):
	if area.is_in_group("enemies"):
		on_hit_target(area if area is Node2D else area.get_parent())

## 信号处理：Body 进入
func _on_body_entered(body: Node):
	if body.is_in_group("enemies"):
		on_hit_target(body)

## ==================== 碰撞与命中处理 ====================

## 获取实际目标（从弱引用中获取）
func get_actual_target() -> Node2D:
	if not target_ref:
		return null
	return target_ref.get_ref() if target_ref.get_ref() else null

## 命中目标处理（TARGET_LOCKED使用）
func on_hit_target(target: Node2D):
	if has_hit_target or not is_instance_valid(target):
		return

	has_hit_target = true

	# 造成伤害
	deal_damage_to_target(target, damage)

	# 发射信号
	hit_target.emit(target, damage)

	# 触发特效
	trigger_effects(target)

	# 销毁弹道
	destroy()

## 到达目标点处理（POSITION_FIXED使用，未命中任何敌人时）
func on_reach_target():
	if not has_hit_target:
		# 未命中任何敌人，播放未命中特效（可选）
		print("[弹道] 到达目标点但未命中任何敌人")

	# 销毁弹道
	destroy()

## PIERCE穿透碰撞检测
func check_pierce_collision(from_pos: Vector2, to_pos: Vector2):
	if not pierce_enabled or current_pierce_count >= pierce_count:
		return

	# 使用物理空间进行射线检测
	var space_state = get_world_2d().direct_space_state
	if not space_state:
		return

	# 设置射线查询参数
	var query = PhysicsRayQueryParameters2D.create(from_pos, to_pos)
	query.collision_mask = 2  # 假设敌人在第2层（根据项目实际情况调整）
	query.exclude = [self]  # 排除自身

	var result = space_state.intersect_ray(query)
	if result:
		var hit_enemy = result.collider as Node2D
		if hit_enemy and is_instance_valid(hit_enemy):
			# 检查是否已命中过该敌人
			if not hit_enemy in hit_enemies:
				# 命中新敌人
				on_pierce_hit(hit_enemy, result.position)

## 处理穿透命中
func on_pierce_hit(enemy: Node2D, hit_position: Vector2):
	# 记录已命中的敌人
	hit_enemies.append(enemy)
	current_pierce_count += 1

	# 计算穿透衰减后的伤害
	var actual_damage = calculate_pierce_damage(damage, current_pierce_count - 1)

	# 造成伤害
	deal_damage_to_target(enemy, actual_damage)

	# 发射信号
	hit_target.emit(enemy, actual_damage)

	# 播放穿透特效（可在 hit_position 处生成粒子效果）
	play_pierce_effect(hit_position)

## ==================== 伤害计算 ====================

## 对目标造成伤害
func deal_damage_to_target(target: Node2D, amount: float):
	if not target or not is_instance_valid(target):
		return

	if target.has_method("take_damage"):
		# 🆕 传递攻击者信息（使用 source_tower，需要检查是否有效）
		if source_tower and is_instance_valid(source_tower):
			target.take_damage(amount, damage_type, source_tower)
		else:
			# 塔已被销毁，不记录伤害来源
			target.take_damage(amount, damage_type, null)
	else:
		print("[警告] 目标不支持 take_damage 方法")

## 计算穿透伤害衰减
## current_hit_index: 当前命中索引（从0开始，0=第一个目标）
func calculate_pierce_damage(base_damage: float, current_hit_index: int) -> float:
	"""
	穿透伤害衰减公式:
	第n个目标的伤害 = base_damage * (decay_rate ^ current_hit_index)

	示例: base_damage=20, decay_rate=0.7, pierce_count=3
	- 第1个目标(index=0): 20 * 0.7^0 = 20.0 (100%)
	- 第2个目标(index=1): 20 * 0.7^1 = 14.0 (70%)
	- 第3个目标(index=2): 20 * 0.7^2 = 9.8  (49%)
	"""
	var multiplier = pow(pierce_damage_decay, current_hit_index)
	return base_damage * multiplier

## ==================== 特效处理 ====================

## 触发命中特效
func trigger_effects(_primary_target: Node2D):
	match effect_type:
		EffectType.SPLASH:
			apply_splash_effect_at(_primary_target.global_position)
		EffectType.PIERCE:
			pass  # PIERCE已在check_pierce_collision中处理
		_:
			pass  # 其他特效由TowerAttackComponent处理

## 在指定位置应用 AOE 爆炸效果
func apply_splash_effect_at(center_pos: Vector2):
	var splash_damage = damage * effect_damage_ratio
	var enemies_hit = 0
	
	# 🆕 获取攻击者（使用 source_tower）
	var attacker: Node2D = source_tower if source_tower and is_instance_valid(source_tower) else null

	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = center_pos.distance_to(enemy.global_position)
		if distance <= effect_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(splash_damage, damage_type, attacker)
				enemies_hit += 1
			
			if enemies_hit >= effect_max_targets:
				break

## 播放穿透视觉效果（占位方法，可被子类重写）
func play_pierce_effect(_position: Vector2):
	# TODO: 可在此处添加粒子效果或音效
	pass

## ==================== 生命周期管理 ====================

## 销毁弹道
func destroy():
	if not is_active:
		return

	is_active = false
	projectile_destroyed.emit(self)

	# 从场景树移除并释放
	queue_free()

## 达到最大飞行距离
func on_max_distance_reached():
	destroy()

## 清理资源
func _exit_tree():
	# 清理弱引用等资源
	target_ref = null
	hit_enemies.clear()
