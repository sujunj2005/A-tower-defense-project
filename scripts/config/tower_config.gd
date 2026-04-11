extends Resource
class_name TowerConfig

const AttackMode = preload("res://scripts/config/attack_types.gd").AttackMode
const ProjectileType = preload("res://scripts/config/attack_types.gd").ProjectileType
const EffectType = preload("res://scripts/config/attack_effects.gd").EffectType

@export_group("Base Info")
@export var tower_id: String = ""
@export var tower_name: String = ""
@export var tower_level: int = 1
@export var description: String = ""

@export_group("Combat Stats")
@export var damage: float = 10.0
@export var damage_type: int = 0

@export_group("Attack Mode")
@export var attack_mode: int = AttackMode.RANGED
@export var attack_range: float = 150.0

@export_group("Detection")
@export var detection_range: float = 150.0
@export var attack_speed: float = 1.0

@export_group("Attack Timing")
@export var windup_duration: float = 0.0

@export_group("Projectile Config")
@export var projectile_speed: float = 300.0
@export var projectile_scene: PackedScene
@export var projectile_scene_path: String = ""
@export var projectile_type: int = ProjectileType.POSITION_FIXED
@export var projectile_config: ProjectileConfig

@export_group("Pierce Config")
@export var pierce_enabled: bool = false
@export var pierce_count: int = 2
@export var pierce_damage_decay: float = 0.7

@export_group("Attack Effects")
@export var effect_type: int = EffectType.NONE
@export var effect_radius: float = 50.0
@export var effect_damage_ratio: float = 0.5
@export var effect_max_targets: int = 3
@export var effect_value: float = 0.0

@export_group("Economy")
@export var cost: int = 100
@export var sell_ratio: float = 0.5

@export_group("Level System")
@export var max_level: int = 10
@export var experience_curve: float = 1.5
@export var base_experience_required: int = 100
@export var damage_growth: float = 0.2
@export var attack_speed_growth: float = 0.1
@export var range_growth: float = 0.05
@export var experience_on_hit: int = 1

@export_group("Visuals")
@export var texture_path: String = ""
@export var windup_animation: String = ""
@export var attack_animation: String = ""

static var _registry: Dictionary = {}
static var _json_cache: Dictionary = {}

static func _static_init():
	_load_json_registry()

static func _load_json_registry() -> void:
	if not _json_cache.is_empty():
		return
	var file: FileAccess = FileAccess.open("res://data/towers.json", FileAccess.READ)
	if not file:
		return
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	if err != OK:
		return
	var data: Dictionary = json.data
	if not data.has("towers"):
		return
	for tower: Dictionary in data.towers:
		var tid: String = tower.get("tower_id", "")
		if tid != "":
			_json_cache[tid] = tower
			_registry[tid] = tid

static func get_tower_types() -> Array:
	if _registry.is_empty():
		_static_init()
	return _registry.keys()

static func get_config(tower_type: String) -> TowerConfig:
	if _registry.is_empty():
		_static_init()
	if _json_cache.has(tower_type):
		return _config_from_json(_json_cache[tower_type])
	return null

static func _config_from_json(data: Dictionary) -> TowerConfig:
	var config: TowerConfig = TowerConfig.new()
	config.tower_id = data.get("tower_id", "")
	config.tower_name = data.get("tower_name", "")
	config.description = data.get("description", "")
	config.attack_mode = AttackMode.RANGED
	var attack_mode_str: String = data.get("attack_mode", "ranged")
	match attack_mode_str:
		"melee":
			config.attack_mode = AttackMode.MELEE
		"none":
			config.attack_mode = AttackMode.NONE
		_:
			config.attack_mode = AttackMode.RANGED
	var stats: Dictionary = data.get("stats", {})
	config.damage = float(stats.get("damage", 10))
	config.attack_speed = float(stats.get("attack_speed", 1.0))
	config.attack_range = float(stats.get("range", 150))
	if config.attack_mode != AttackMode.RANGED and config.attack_mode != AttackMode.MELEE:
		pass
	elif config.attack_range < 150.0:
		config.attack_range = 150.0
	if config.attack_mode == AttackMode.MELEE:
		config.detection_range = config.attack_range + 60.0
	else:
		config.detection_range = config.attack_range + 30.0
	config.projectile_speed = float(stats.get("projectile_speed", 300))
	var dmg_type: String = stats.get("damage_type", "physical")
	config.damage_type = 1 if dmg_type == "magic" else 0
	var cost_data: Dictionary = data.get("cost", {})
	config.cost = int(cost_data.get("build_cost", 100))
	config.sell_ratio = float(cost_data.get("sell_ratio", 0.5))
	var upgrade: Dictionary = data.get("upgrade_per_level", {})
	config.max_level = int(upgrade.get("max_level", 10))
	config.damage_growth = float(upgrade.get("damage_increase", 0.1))
	config.attack_speed_growth = float(upgrade.get("attack_speed_increase", 0.05))
	var special: Dictionary = data.get("special_effect", {})
	var effect_type_str: String = special.get("type", "")
	match effect_type_str:
		"slow":
			config.effect_type = EffectType.SLOW
			config.effect_value = float(special.get("value", 0.2))
		"dot", "burn":
			config.effect_type = EffectType.DOT
			config.effect_value = float(special.get("value", 5.0))
		"splash", "aoe":
			config.effect_type = EffectType.SPLASH
			config.effect_radius = float(special.get("radius", 50.0))
		"crit":
			config.effect_type = EffectType.NONE
			config.effect_value = float(special.get("multiplier", 2.0))
		"pierce":
			config.pierce_enabled = true
			config.pierce_count = int(special.get("count", 2))
			config.pierce_damage_decay = float(special.get("decay", 0.7))
		_:
			config.effect_type = EffectType.NONE
	if config.attack_mode == AttackMode.RANGED:
		var pconfig: ProjectileConfig = ProjectileConfig.new()
		pconfig.projectile_type = ProjectileType.TARGET_LOCKED
		pconfig.movement_type = 0
		pconfig.speed = config.projectile_speed
		pconfig.damage = config.damage
		pconfig.damage_type = config.damage_type
		pconfig.effect_type = config.effect_type
		pconfig.effect_radius = config.effect_radius
		pconfig.effect_damage_ratio = config.effect_damage_ratio
		pconfig.effect_max_targets = config.effect_max_targets
		pconfig.pierce_enabled = config.pierce_enabled
		pconfig.pierce_count = config.pierce_count
		pconfig.pierce_damage_decay = config.pierce_damage_decay
		pconfig.collision_radius = 12.0
		if config.damage_type == 1:
			pconfig.sprite_modulate = Color(0.4, 0.6, 1.0, 1.0)
			pconfig.trail_color = Color(0.3, 0.5, 1.0, 0.5)
			pconfig.use_trail_particles = true
			pconfig.trail_amount = 8
			pconfig.trail_lifetime = 0.3
			pconfig.trail_scale = 0.4
		else:
			pconfig.sprite_modulate = Color(1.0, 0.6, 0.3, 1.0)
			pconfig.trail_color = Color(1.0, 0.4, 0.2, 0.5)
			pconfig.use_trail_particles = true
			pconfig.trail_amount = 6
			pconfig.trail_lifetime = 0.25
			pconfig.trail_scale = 0.3
		config.projectile_config = pconfig
	var tower_idx: int = config.tower_id.hash() % 16
	var t_row: int = floori(tower_idx / 4.0)
	var t_col: int = tower_idx % 4
	config.texture_path = "res://images/towers/Black - Plastic 1 128x128-%d-%d.png" % [t_row, t_col]
	return config

static func get_configs_for_stage(stage_id: String) -> Array[TowerConfig]:
	if _json_cache.is_empty():
		_static_init()
	var cm: Node = Engine.get_main_loop().root.get_node_or_null("ConfigManager")
	if not cm:
		return []
	var stages_data: Dictionary = {}
	if cm.has_method("load_json"):
		stages_data = cm.load_json("res://data/stages.json")
	if not stages_data.has("stages"):
		return []
	var stages: Dictionary = stages_data.stages
	var available_ids: Array = []
	if stages.has(stage_id):
		available_ids = stages[stage_id].get("available_towers", [])
	var result: Array[TowerConfig] = []
	for tid: String in available_ids:
		var cfg: TowerConfig = get_config(tid)
		if cfg:
			result.append(cfg)
	return result

static func register_tower(tower_type: String, path: String):
	_registry[tower_type] = path

func validate() -> Dictionary:
	var warnings: Array = []
	var errors: Array = []
	if detection_range < attack_range:
		warnings.append("detection_range (%.0f) 应该 >= attack_range (%.0f)" % [detection_range, attack_range])
	if attack_mode == AttackMode.RANGED and projectile_scene == null and projectile_scene_path == "":
		pass
	if pierce_enabled and projectile_type != ProjectileType.POSITION_FIXED:
		projectile_type = ProjectileType.POSITION_FIXED
	if windup_duration < 0:
		windup_duration = 0.0
	if pierce_enabled and pierce_count <= 0:
		warnings.append("pierce_count 应>0")
	if effect_type == EffectType.SPLASH and effect_radius <= 0:
		errors.append("SPLASH 特效必须设置 effect_radius > 0")
	return {"valid": errors.is_empty(), "warnings": warnings, "errors": errors}

func init_projectile_scene() -> void:
	if projectile_scene == null and projectile_scene_path != "":
		var loaded_scene: PackedScene = load(projectile_scene_path) as PackedScene
		if loaded_scene:
			projectile_scene = loaded_scene

func get_experience_required(level: int) -> int:
	if level < 1:
		return 0
	if level >= max_level:
		return -1
	var total_exp: float = 0.0
	for i: int in range(level):
		total_exp += base_experience_required * pow(experience_curve, i)
	return int(total_exp)

func get_experience_for_next_level(current_level: int) -> int:
	if current_level < 1:
		current_level = 1
	if current_level >= max_level:
		return -1
	return int(base_experience_required * pow(experience_curve, current_level - 1))

func get_damage_at_level(level: int) -> float:
	if level < 1:
		level = 1
	return damage * pow(1.0 + damage_growth, level - 1)

func get_attack_speed_at_level(level: int) -> float:
	if level < 1:
		level = 1
	return attack_speed * pow(1.0 + attack_speed_growth, level - 1)

func get_attack_range_at_level(level: int) -> float:
	if level < 1:
		level = 1
	return attack_range * pow(1.0 + range_growth, level - 1)
