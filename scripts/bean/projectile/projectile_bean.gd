class_name ProjectileBean
extends Resource

@export var projectile_type: int = 0
@export var movement_type: int = 0
@export var speed: float = 300.0
@export var damage: float = 10.0
@export var damage_type: int = 0
@export var collision_radius: float = 12.0
@export var effect_type: int = 0
@export var effect_radius: float = 50.0
@export var effect_damage_ratio: float = 0.5
@export var effect_max_targets: int = 3
@export var pierce_enabled: bool = false
@export var pierce_count: int = 2
@export var pierce_damage_decay: float = 0.7
@export var sprite_modulate: Color = Color(1, 1, 1, 1)
@export var trail_color: Color = Color(1, 1, 1, 0.5)
@export var use_trail_particles: bool = true
@export var trail_amount: int = 10
@export var trail_lifetime: float = 0.5
@export var trail_scale: float = 0.5

static func from_tower_bean(bean: TowerBean) -> ProjectileBean:
	var pbean := ProjectileBean.new()
	if bean.attack_mode != GameConfig.AttackMode.RANGED:
		return pbean
	pbean.projectile_type = GameConfig.ProjectileType.TARGET_LOCKED
	pbean.movement_type = 0
	pbean.speed = bean.projectile_speed
	pbean.damage = bean.damage
	pbean.damage_type = bean.damage_type
	pbean.effect_type = bean.effect_type
	pbean.effect_radius = bean.effect_radius
	pbean.effect_damage_ratio = bean.effect_damage_ratio
	pbean.effect_max_targets = bean.effect_max_targets
	pbean.pierce_enabled = bean.pierce_enabled
	pbean.pierce_count = bean.pierce_count
	pbean.pierce_damage_decay = bean.pierce_damage_decay
	pbean.collision_radius = 12.0
	if bean.damage_type == GameConfig.DamageType.MAGICAL:
		pbean.sprite_modulate = Color(0.4, 0.6, 1.0, 1.0)
		pbean.trail_color = Color(0.3, 0.5, 1.0, 0.5)
		pbean.use_trail_particles = true
		pbean.trail_amount = 8
		pbean.trail_lifetime = 0.3
		pbean.trail_scale = 0.4
	else:
		pbean.sprite_modulate = Color(1.0, 0.6, 0.3, 1.0)
		pbean.trail_color = Color(1.0, 0.4, 0.2, 0.5)
		pbean.use_trail_particles = true
		pbean.trail_amount = 6
		pbean.trail_lifetime = 0.25
		pbean.trail_scale = 0.3
	return pbean

func to_dict() -> Dictionary:
	return {
		"projectile_type": projectile_type,
		"speed": speed,
		"damage": damage,
		"damage_type": damage_type,
		"collision_radius": collision_radius,
		"effect_type": effect_type,
		"pierce_enabled": pierce_enabled,
		"pierce_count": pierce_count
	}
