extends Node2D

var current_health: float = 100.0
var max_health: float = 100.0

func _ready():
	add_to_group("enemies")

func take_damage(amount: float, damage_type: int):
	current_health -= amount
	print("[TestEnemy] 受到 %.0f 点伤害，剩余生命值: %.0f" % [amount, current_health])
	if current_health <= 0:
		print("[TestEnemy] 敌人死亡")
		queue_free()

func get_current_health() -> float:
	return current_health
