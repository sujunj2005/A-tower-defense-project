class_name WaveBean
extends Resource

@export var wave_number: int = 1
@export var wave_name: String = "Wave 1"
@export var start_delay: float = 3.0
@export var spawn_interval: float = 1.5
@export var enemies: Array[Dictionary] = []

static func from_dict(data: Dictionary) -> WaveBean:
	var bean := WaveBean.new()
	bean.wave_number = int(data.get("wave_number", 1))
	bean.wave_name = data.get("wave_name", "Wave %d" % bean.wave_number)
	bean.start_delay = float(data.get("start_delay", 3.0))
	bean.spawn_interval = float(data.get("spawn_interval", 1.5))
	bean.enemies = data.get("enemies", [])
	return bean

func to_dict() -> Dictionary:
	return {
		"wave_number": wave_number,
		"wave_name": wave_name,
		"start_delay": start_delay,
		"spawn_interval": spawn_interval,
		"enemies": enemies
	}
