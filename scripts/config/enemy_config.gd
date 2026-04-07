extends Resource
class_name EnemyConfig

@export_group("Base Info")
@export var enemy_id: String = ""
@export var enemy_name: String = ""
@export var description: String = ""

@export_group("Combat Stats")
@export var max_health: float = 100.0
@export var move_speed: float = 100.0
@export var physical_resistance: float = 0.0
@export var magical_resistance: float = 0.0

@export_group("Rewards")  # 🆕 新增：掉落奖励配置
@export var gold_drop: int = 10  # 击杀掉落金钱
@export var experience_drop: int = 5  # 击杀掉落经验值

@export_group("Visuals")
@export var texture_path: String = ""

static var _registry: Dictionary = {}
static var _map_config: MapConfig
static var debug_messages: Array[String] = []  # 🆕 全局调试信息

static func set_map_config(map_config: MapConfig):
	_map_config = map_config
	if map_config:
		map_config._cache_enemy_configs()
		_registry = map_config.enemy_registry
	else:
		_registry = {
			"heavy_armor": "res://resources/enemies/heavy_armor.tres",
			"magic_shield": "res://resources/enemies/magic_shield.tres"
		}

static func get_enemy_types() -> Array:
	return _registry.keys()

static func get_config(enemy_type: String) -> EnemyConfig:
	if _map_config and _map_config._enemy_cache.has(enemy_type):
		return _map_config._enemy_cache[enemy_type]
	
	if not _registry.has(enemy_type):
		return null
	
	var config = _registry[enemy_type]
	if config is EnemyConfig:
		return config
	elif config is Resource:
		if config is EnemyConfig:
			return config as EnemyConfig
		else:
			return null
	elif config is String:
		var path: String = config
		if not ResourceLoader.exists(path):
			return null
		return load(path) as EnemyConfig
	
	return null

static func register_enemy(enemy_type: String, path: String):
	_registry[enemy_type] = path
