class_name ProjectileConfig
extends Resource

## ==================== 弹道类型配置 ====================

@export_group("弹道类型")
@export var projectile_type: int = 0  # 0=TARGET_LOCKED, 1=POSITION_FIXED

@export_enum("TARGET_LOCKED:0", "POSITION_FIXED:1") var movement_type: int = 0

## ==================== 基础属性 ====================

@export_group("基础属性")
@export var speed: float = 300.0  # 飞行速度（像素/秒）
@export var damage: float = 10.0
@export var damage_type: int = 0  # 0=物理，1=魔法

## ==================== 视觉类型 ====================

@export_group("视觉类型")
@export_enum("SPRITE:0", "PARTICLES:1", "BOTH:2") var visual_type: int = 0

## Sprite 配置
@export var sprite_texture: Texture2D  # 精灵贴图
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)  # 缩放
@export var sprite_modulate: Color = Color(1, 1, 1, 1)  # 颜色调制
@export var sprite_offset: Vector2 = Vector2.ZERO  # 位置偏移

## 粒子配置
@export var use_particles: bool = false  # 是否启用粒子系统
@export var particle_amount: int = 20  # 粒子数量
@export var particle_lifetime: float = 1.0  # 粒子寿命
@export var particle_emission_shape: int = 0  # 0=点，1=矩形，2=圆形，3=环
@export var particle_emission_extents: Vector2 = Vector2(10, 10)  # 发射范围
@export var particle_velocity_min: float = 50.0  # 最小速度
@export var particle_velocity_max: float = 100.0  # 最大速度
@export var particle_spread: float = 45.0  # 扩散角度
@export var particle_color: Color = Color(1, 1, 1, 1)  # 粒子颜色
@export var particle_scale: float = 1.0  # 粒子缩放

## 拖尾粒子配置
@export var use_trail_particles: bool = true  # 是否启用拖尾粒子
@export var trail_amount: int = 10  # 拖尾粒子数量
@export var trail_lifetime: float = 0.5  # 拖尾寿命
@export var trail_color: Color = Color(1, 1, 1, 0.5)  # 拖尾颜色
@export var trail_scale: float = 0.5  # 拖尾缩放

## ==================== 碰撞配置 ====================

@export_group("碰撞配置")
@export var collision_radius: float = 12.0  # 碰撞体半径

## ==================== 特效配置 ====================

@export_group("特效配置")
@export var effect_type: int = 0  # 0=NONE, 1=SPLASH, 2=PIERCE
@export var effect_radius: float = 50.0  # 特效范围
@export var effect_damage_ratio: float = 0.5  # 特效伤害比例
@export var effect_max_targets: int = 3  # 最大目标数

## ==================== 穿透配置 ====================

@export_group("穿透配置")
@export var pierce_enabled: bool = false
@export var pierce_count: int = 2
@export var pierce_damage_decay: float = 0.7

## ==================== 辅助方法 ====================

## 创建并配置粒子系统
func create_particle_system() -> GPUParticles2D:
	var particles = GPUParticles2D.new()
	particles.name = "Particles"
	
	# 设置基本参数
	particles.amount = particle_amount
	particles.lifetime = particle_lifetime
	particles.one_shot = false
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	
	# 创建粒子材质
	var material = ParticleProcessMaterial.new()
	
	# 发射形状（直接使用整数值，避免枚举兼容性问题）
	# Godot 4.x 发射形状值：
	# 0 = POINT (点)
	# 1 = SPHERE (球体) 
	# 2 = BOX (盒子)
	# 3 = RING (环)
	# 4 = CIRCLE (圆形)
	# 5 = POINT_TEXTURE (点纹理)
	match particle_emission_shape:
		0:  # 点
			material.emission_shape = 0
		1:  # 矩形（使用 BOX）
			material.emission_shape = 2
			material.emission_box_extents = Vector3(particle_emission_extents.x, particle_emission_extents.y, 0)
		2:  # 圆形
			material.emission_shape = 4
			material.emission_sphere_radius = particle_emission_extents.x
		3:  # 环
			material.emission_shape = 3
			material.emission_ring_radius = particle_emission_extents.x / 2.0
			material.emission_ring_height = particle_emission_extents.y
	
	# 速度
	material.direction = Vector3(0, -1, 0)  # 向上发射
	material.spread = particle_spread
	material.initial_velocity_min = particle_velocity_min
	material.initial_velocity_max = particle_velocity_max
	
	# 颜色
	material.color = particle_color
	
	# 缩放
	material.scale_min = particle_scale * 0.5
	material.scale_max = particle_scale * 1.5
	
	# 应用材质
	particles.process_material = material
	
	return particles

## 创建拖尾粒子系统
func create_trail_particles() -> GPUParticles2D:
	var trail = GPUParticles2D.new()
	trail.name = "TrailParticles"
	
	# 设置基本参数
	trail.amount = trail_amount
	trail.lifetime = trail_lifetime
	trail.one_shot = false
	trail.explosiveness = 0.0
	trail.randomness = 0.3
	
	# 创建粒子材质
	var material = ParticleProcessMaterial.new()
	
	# 发射形状（点）
	material.emission_shape = 0  # EMISSION_SHAPE_POINT
	
	# 速度（向后）
	material.direction = Vector3(0, 1, 0)  # 向下（与运动方向相反）
	material.spread = 30.0
	material.initial_velocity_min = particle_velocity_min * 0.5
	material.initial_velocity_max = particle_velocity_max * 0.5
	
	# 颜色
	material.color = trail_color
	
	# 缩放
	material.scale_min = trail_scale * 0.5
	material.scale_max = trail_scale * 1.5
	
	# 应用材质
	trail.process_material = material
	
	return trail

## 从配置创建视觉组件
func setup_visuals(node: Node2D) -> void:
	# 获取场景中的现有节点
	var sprite_node = node.get_node_or_null("Sprite2D")
	var particles_node = node.get_node_or_null("GPUParticles2D")
	var trail_node = node.get_node_or_null("TrailParticles")
	
	# 创建/配置 Sprite（如果需要）
	if visual_type == 0 or visual_type == 2:  # SPRITE 或 BOTH
		if sprite_texture and sprite_node:
			sprite_node.texture = sprite_texture
			sprite_node.scale = sprite_scale
			sprite_node.modulate = sprite_modulate
			sprite_node.position = sprite_offset
	elif sprite_node:
		# 隐藏 Sprite
		sprite_node.visible = false
	
	# 创建/配置粒子系统（如果需要）
	if visual_type == 1 or visual_type == 2:  # PARTICLES 或 BOTH
		if use_particles and particles_node:
			configure_particle_system(particles_node)
		elif particles_node:
			particles_node.visible = false
		
		if use_trail_particles and trail_node:
			configure_trail_particles(trail_node)
		elif trail_node:
			trail_node.visible = false

## 配置粒子系统
func configure_particle_system(particles: GPUParticles2D) -> void:
	particles.amount = particle_amount
	particles.lifetime = particle_lifetime
	particles.one_shot = false
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	
	# 创建或获取粒子材质
	var material: ParticleProcessMaterial
	if particles.process_material:
		material = particles.process_material as ParticleProcessMaterial
	else:
		material = ParticleProcessMaterial.new()
		particles.process_material = material
	
	# 发射形状（使用整数值）
	# Godot 4.x 发射形状值：
	# 0 = POINT (点)
	# 1 = SPHERE (球体)
	# 2 = BOX (盒子)
	# 3 = RING (环)
	# 4 = CIRCLE (圆形)
	# 5 = POINT_TEXTURE (点纹理)
	match particle_emission_shape:
		0:  # 点
			material.emission_shape = 0
		1:  # 矩形（使用 BOX）
			material.emission_shape = 2
			material.emission_box_extents = Vector3(particle_emission_extents.x, particle_emission_extents.y, 0)
		2:  # 圆形
			material.emission_shape = 4
			material.emission_sphere_radius = particle_emission_extents.x
		3:  # 环
			material.emission_shape = 3
			material.emission_ring_radius = particle_emission_extents.x / 2.0
			material.emission_ring_height = particle_emission_extents.y
	
	# 速度
	material.direction = Vector3(0, -1, 0)  # 向上发射
	material.spread = particle_spread
	material.initial_velocity_min = particle_velocity_min
	material.initial_velocity_max = particle_velocity_max
	
	# 颜色
	material.color = particle_color
	
	# 缩放
	material.scale_min = particle_scale * 0.5
	material.scale_max = particle_scale * 1.5

## 配置拖尾粒子系统
func configure_trail_particles(trail: GPUParticles2D) -> void:
	trail.amount = trail_amount
	trail.lifetime = trail_lifetime
	trail.one_shot = false
	trail.explosiveness = 0.0
	trail.randomness = 0.3
	
	# 创建或获取粒子材质
	var material: ParticleProcessMaterial
	if trail.process_material:
		material = trail.process_material as ParticleProcessMaterial
	else:
		material = ParticleProcessMaterial.new()
		trail.process_material = material
	
	# 发射形状（点）
	material.emission_shape = 0  # EMISSION_SHAPE_POINT
	
	# 速度（向后）
	material.direction = Vector3(0, 1, 0)  # 向下（与运动方向相反）
	material.spread = 30.0
	material.initial_velocity_min = particle_velocity_min * 0.5
	material.initial_velocity_max = particle_velocity_max * 0.5
	
	# 颜色
	material.color = trail_color
	
	# 缩放
	material.scale_min = trail_scale * 0.5
	material.scale_max = trail_scale * 1.5
