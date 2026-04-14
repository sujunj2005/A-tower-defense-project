class_name EnemyBean
extends Resource

@export var enemy_id: String = ""
@export var enemy_name: String = ""
@export var description: String = ""
@export var enemy_type: String = ""
@export var tier: String = ""
@export var max_health: float = 100.0
@export var move_speed: float = 100.0
@export var physical_resistance: float = 0.0
@export var magical_resistance: float = 0.0
@export var armor: int = 0
@export var damage: int = 5
@export var attack_speed: float = 1.0
@export var attack_range: float = 20.0
@export var gold_drop: int = 10
@export var experience_drop: int = 5
@export var special_abilities: Array[Dictionary] = []
@export var spawn_stages: Array[String] = []
@export var spawn_waves: Array[int] = []
@export var spawn_weight: int = 50
@export var texture_path: String = ""

static func from_dict(data: Dictionary) -> EnemyBean:
	var bean := EnemyBean.new()
	bean.enemy_id = data.get("enemy_id", "")
	bean.enemy_name = data.get("enemy_name", "")
	bean.enemy_type = data.get("enemy_type", "")
	bean.tier = data.get("tier", "")
	bean.description = data.get("description", "")
	var stats: Dictionary = data.get("stats", {})
	bean.max_health = float(stats.get("health", 100))
	bean.move_speed = float(stats.get("speed", 100))
	bean.armor = int(stats.get("armor", 0))
	bean.damage = int(stats.get("damage", 5))
	bean.attack_speed = float(stats.get("attack_speed", 1.0))
	bean.attack_range = float(stats.get("attack_range", 20))
	var armor_type: String = stats.get("armor_type", "none")
	match armor_type:
		"light":
			bean.physical_resistance = 0.1
		"medium":
			bean.physical_resistance = 0.2
		"heavy":
			bean.physical_resistance = 0.35
		_:
			bean.physical_resistance = 0.0
	bean.gold_drop = int(data.get("kill_reward_gold", 10))
	bean.special_abilities = []
	for ab: Dictionary in data.get("special_abilities", []):
		bean.special_abilities.append(ab)
	bean.spawn_stages = []
	for s: String in data.get("spawn_stages", []):
		bean.spawn_stages.append(s)
	bean.spawn_waves = []
	for w: int in data.get("spawn_waves", []):
		bean.spawn_waves.append(w)
	bean.spawn_weight = int(data.get("spawn_weight", 50))
	var enemy_idx: int = bean.enemy_id.hash() % 16
	var row: int = floori(enemy_idx / 4.0)
	var col: int = enemy_idx % 4
	bean.texture_path = "res://images/enemies/marble_%d_%d.png" % [row, col]
	return bean

func to_dict() -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"enemy_name": enemy_name,
		"enemy_type": enemy_type,
		"tier": tier,
		"description": description,
		"max_health": max_health,
		"move_speed": move_speed,
		"armor": armor,
		"damage": damage,
		"gold_drop": gold_drop,
		"spawn_weight": spawn_weight,
		"texture_path": texture_path
	}
