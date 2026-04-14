extends Resource
class_name TowerConfig

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

static func get_bean(tower_type: String) -> TowerBean:
	if _registry.is_empty():
		_static_init()
	if _json_cache.has(tower_type):
		return TowerBean.from_dict(_json_cache[tower_type])
	return null

static func get_config(tower_type: String) -> TowerBean:
	return get_bean(tower_type)

static func get_configs_for_stage(stage_id: String) -> Array[TowerBean]:
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
	var result: Array[TowerBean] = []
	for tid: String in available_ids:
		var cfg: TowerBean = get_bean(tid)
		if cfg:
			result.append(cfg)
	return result

static func register_tower(tower_type: String, path: String):
	_registry[tower_type] = path

static func validate_bean(bean: TowerBean) -> Dictionary:
	var warnings: Array = []
	var errors: Array = []
	if bean.detection_range < bean.attack_range:
		warnings.append("detection_range (%.0f) 应该 >= attack_range (%.0f)" % [bean.detection_range, bean.attack_range])
	if bean.pierce_enabled and bean.projectile_type != GameConfig.ProjectileType.POSITION_FIXED:
		bean.projectile_type = GameConfig.ProjectileType.POSITION_FIXED
	if bean.windup_duration < 0:
		bean.windup_duration = 0.0
	if bean.pierce_enabled and bean.pierce_count <= 0:
		warnings.append("pierce_count 应>0")
	if bean.effect_type == GameConfig.EffectType.SPLASH and bean.effect_radius <= 0:
		errors.append("SPLASH 特效必须设置 effect_radius > 0")
	return {"valid": errors.is_empty(), "warnings": warnings, "errors": errors}

static func get_damage_at_level(bean: TowerBean, level: int) -> float:
	if level < 1:
		level = 1
	return bean.damage * pow(1.0 + bean.damage_growth, level - 1)

static func get_attack_speed_at_level(bean: TowerBean, level: int) -> float:
	if level < 1:
		level = 1
	return bean.attack_speed * pow(1.0 + bean.attack_speed_growth, level - 1)

static func get_attack_range_at_level(bean: TowerBean, level: int) -> float:
	if level < 1:
		level = 1
	return bean.attack_range * pow(1.0 + bean.range_growth, level - 1)

static func get_experience_required(bean: TowerBean, level: int) -> int:
	if level < 1:
		return 0
	if level >= bean.max_level:
		return -1
	var total_exp: float = 0.0
	for i: int in range(level):
		total_exp += bean.base_experience_required * pow(bean.experience_curve, i)
	return int(total_exp)

static func get_experience_for_next_level(bean: TowerBean, current_level: int) -> int:
	if current_level < 1:
		current_level = 1
	if current_level >= bean.max_level:
		return -1
	return int(bean.base_experience_required * pow(bean.experience_curve, current_level - 1))

static func create_projectile_bean(bean: TowerBean) -> ProjectileBean:
	return ProjectileBean.from_tower_bean(bean)
