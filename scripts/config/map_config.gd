extends Resource
class_name MapConfig

@export var map_name: String = "Default Map"
@export var map_width: int = 50
@export var map_height: int = 50
@export var tile_size: int = 50

@export var spawn_point: Vector2i = Vector2i(3, 25)
@export var base_point: Vector2i = Vector2i(46, 25)

@export var path_points: Array[Vector2i] = []

@export var tower_positions: Array[Vector2i] = []
@export var max_towers: int = 10

@export var camera_speed: float = 800.0
@export var zoom_speed: float = 0.2
@export var drag_speed: float = 1.5
@export var drag_inertia: float = 0.9

@export var grass_texture_path: String = "res://images/Outside_A2.png"
@export var grass_texture_region: Rect2 = Rect2(0, 0, 32, 32)

@export var road_texture_path: String = "res://images/Outside_A2.png"
@export var road_texture_region: Rect2 = Rect2(288, 0, 32, 32)

@export var edge_texture_path: String = "res://images/Outside_A2.png"
@export var edge_texture_region: Rect2 = Rect2(32, 0, 32, 32)

@export_group("Wave Configuration")
@export var waves: Array[WaveConfig] = []
@export var enemy_registry: Dictionary = {}

var _enemy_cache: Dictionary = {}

func _ready():
	_cache_enemy_configs()

func _cache_enemy_configs():
	_enemy_cache.clear()
	for enemy_id in enemy_registry.keys():
		var config = enemy_registry[enemy_id]
		if config is EnemyConfig:
			_enemy_cache[enemy_id] = config
		elif config is String:
			var path: String = config
			if ResourceLoader.exists(path):
				_enemy_cache[enemy_id] = load(path)

func get_cached_enemy_config(enemy_type: String) -> EnemyConfig:
	return _enemy_cache.get(enemy_type)

static var _map_registry: Dictionary = {}

static func _static_init():
	_map_registry = {
		"map_01": "res://resources/maps/map_01.tres"
	}

static func get_map_ids() -> Array:
	return _map_registry.keys()

static func load_map(map_id: String) -> MapConfig:
	if not _map_registry.has(map_id):
		push_error("MapConfig: Map ID '%s' not found in registry. Available: %s" % [map_id, _map_registry.keys()])
		return null
	
	var path: String = _map_registry[map_id]
	if not ResourceLoader.exists(path):
		push_error("MapConfig: Resource file not found at path: %s" % path)
		return null
	
	var resource = load(path)
	if resource == null:
		push_error("MapConfig: Failed to load resource from: %s" % path)
		return null
	
	if not (resource is MapConfig):
		push_error("MapConfig: Loaded resource is not a MapConfig instance (got %s) from: %s" % [resource.get_class(), path])
		return null
	
	return resource as MapConfig

static func register_map(map_id: String, path: String):
	_map_registry[map_id] = path
