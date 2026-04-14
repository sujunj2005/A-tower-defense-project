class_name WaveEnemyBean
extends Resource

@export var enemy_type: String = ""
@export var count: int = 1
@export var delay: float = 0.0

static func from_dict(data: Dictionary) -> WaveEnemyBean:
	var bean := WaveEnemyBean.new()
	bean.enemy_type = data.get("enemy_type", "")
	bean.count = int(data.get("count", 1))
	bean.delay = float(data.get("delay", 0.0))
	return bean

func to_dict() -> Dictionary:
	return {
		"enemy_type": enemy_type,
		"count": count,
		"delay": delay
	}
