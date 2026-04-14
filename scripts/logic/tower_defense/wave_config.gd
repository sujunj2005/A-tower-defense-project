extends Resource
class_name WaveConfig

@export var wave_number: int = 1
@export var wave_name: String = "Wave 1"
@export var start_delay: float = 3.0
@export var spawn_interval: float = 1.5
@export var enemies: Array[WaveEnemyConfig] = []
