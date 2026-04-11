extends Resource
class_name EnemyConfig

@export_group("Base Info")
@export var enemy_id: String = ""
@export var enemy_name: String = ""
@export var description: String = ""
@export var enemy_type: String = ""
@export var tier: String = ""

@export_group("Combat Stats")
@export var max_health: float = 100.0
@export var move_speed: float = 100.0
@export var physical_resistance: float = 0.0
@export var magical_resistance: float = 0.0
@export var armor: int = 0
@export var damage: int = 5
@export var attack_speed: float = 1.0
@export var attack_range: float = 20.0

@export_group("Rewards")
@export var gold_drop: int = 10
@export var experience_drop: int = 5

@export_group("Abilities")
@export var special_abilities: Array[Dictionary] = []

@export_group("Spawning")
@export var spawn_stages: Array[String] = []
@export var spawn_waves: Array[int] = []
@export var spawn_weight: int = 50

@export_group("Visuals")
@export var texture_path: String = ""

static var _registry: Dictionary = {}
static var _json_cache: Dictionary = {}
static var _map_config: MapConfig

static func _static_init():
	_load_json_registry()

static func _load_json_registry() -> void:
	if not _json_cache.is_empty():
		return
	var file: FileAccess = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if not file:
		return
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	if err != OK:
		return
	var data: Dictionary = json.data
	if not data.has("enemies"):
		return
	for enemy: Dictionary in data.enemies:
		var eid: String = enemy.get("enemy_id", "")
		if eid != "":
			_json_cache[eid] = enemy
			_registry[eid] = eid

static func set_map_config(map_config: MapConfig):
	_map_config = map_config
	if map_config:
		map_config._cache_enemy_configs()
		for key: String in map_config.enemy_registry:
			if not _registry.has(key):
				_registry[key] = map_config.enemy_registry[key]

static func get_enemy_types() -> Array:
	if _registry.is_empty():
		_static_init()
	return _registry.keys()

static func get_config(query_id: String) -> EnemyConfig:
	if _registry.is_empty():
		_static_init()
	if _json_cache.has(query_id):
		return _config_from_json(_json_cache[query_id])
	if _map_config and _map_config._enemy_cache.has(query_id):
		return _map_config._enemy_cache[query_id]
	return null

static func _config_from_json(data: Dictionary) -> EnemyConfig:
	var config: EnemyConfig = EnemyConfig.new()
	config.enemy_id = data.get("enemy_id", "")
	config.enemy_name = data.get("enemy_name", "")
	config.enemy_type = data.get("enemy_type", "")
	config.tier = data.get("tier", "")
	config.description = data.get("description", "")
	var stats: Dictionary = data.get("stats", {})
	config.max_health = float(stats.get("health", 100))
	config.move_speed = float(stats.get("speed", 100))
	config.armor = int(stats.get("armor", 0))
	config.damage = int(stats.get("damage", 5))
	config.attack_speed = float(stats.get("attack_speed", 1.0))
	config.attack_range = float(stats.get("attack_range", 20))
	var armor_type: String = stats.get("armor_type", "none")
	match armor_type:
		"light":
			config.physical_resistance = 0.1
		"medium":
			config.physical_resistance = 0.2
		"heavy":
			config.physical_resistance = 0.35
		_:
			config.physical_resistance = 0.0
	config.gold_drop = int(data.get("kill_reward_gold", 10))
	config.special_abilities = []
	var abilities: Array = data.get("special_abilities", [])
	for ab: Dictionary in abilities:
		config.special_abilities.append(ab)
	config.spawn_stages = []
	for s: String in data.get("spawn_stages", []):
		config.spawn_stages.append(s)
	config.spawn_waves = []
	for w: int in data.get("spawn_waves", []):
		config.spawn_waves.append(w)
	config.spawn_weight = int(data.get("spawn_weight", 50))
	var enemy_idx: int = config.enemy_id.hash() % 16
	var row: int = floori(enemy_idx / 4.0)
	var col: int = enemy_idx % 4
	config.texture_path = "res://images/enemies/marble_%d_%d.png" % [row, col]
	return config

static func get_enemies_for_stage(stage_id: String) -> Array[Dictionary]:
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
	if stages.has(stage_id):
		return stages[stage_id].get("enemy_pool", [])
	return []

static func register_enemy(reg_id: String, path: String):
	_registry[reg_id] = path
