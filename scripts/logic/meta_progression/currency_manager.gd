extends Node

signal currency_changed(currency_id: String, new_amount: int)

var player_save: PlayerSaveData

const CURRENCY_LIFE_WISDOM: String = "life_wisdom"
const CURRENCY_DESTINY_POINTS: String = "destiny_points"

func _ready() -> void:
	player_save = Global.get_player_save()

func get_currency(currency_id: String) -> int:
	return player_save.currencies.get(currency_id, 0)

func add_currency(currency_id: String, amount: int) -> void:
	if not player_save.currencies.has(currency_id):
		player_save.currencies[currency_id] = 0
	player_save.currencies[currency_id] += amount
	currency_changed.emit(currency_id, player_save.currencies[currency_id])
	Global.debug_log("货币 +%d %s，当前：%d" % [amount, currency_id, player_save.currencies[currency_id]])

func spend_currency(currency_id: String, amount: int) -> bool:
	var current: int = get_currency(currency_id)
	if current < amount:
		Global.debug_log("货币不足：%s 需要 %d，当前 %d" % [currency_id, amount, current])
		return false
	player_save.currencies[currency_id] = current - amount
	currency_changed.emit(currency_id, player_save.currencies[currency_id])
	Global.debug_log("货币 -%d %s，剩余：%d" % [amount, currency_id, player_save.currencies[currency_id]])
	return true

func can_afford(currency_id: String, amount: int) -> bool:
	return get_currency(currency_id) >= amount

func get_life_wisdom() -> int:
	return get_currency(CURRENCY_LIFE_WISDOM)

func get_destiny_points() -> int:
	return get_currency(CURRENCY_DESTINY_POINTS)

func add_life_wisdom(amount: int) -> void:
	add_currency(CURRENCY_LIFE_WISDOM, amount)

func add_destiny_points(amount: int) -> void:
	add_currency(CURRENCY_DESTINY_POINTS, amount)
