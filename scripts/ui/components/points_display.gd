extends HBoxContainer

const TOTAL_POINTS: int = 20

signal points_changed(remaining: int)

var _remaining: int = TOTAL_POINTS
var _spent: int = 0

var _total_label: Label
var _spent_label: Label
var _remaining_label: Label

func _ready() -> void:
	add_theme_constant_override("separation", 8)
	_total_label = Label.new()
	_total_label.text = tr("LIFE_CHOICE_POINTS_TOTAL") + "：%d" % TOTAL_POINTS
	_total_label.add_theme_font_size_override("font_size", 13)
	add_child(_total_label)
	_spent_label = Label.new()
	_spent_label.text = tr("LIFE_CHOICE_POINTS_SPENT") + "：0"
	_spent_label.add_theme_font_size_override("font_size", 13)
	add_child(_spent_label)
	_remaining_label = Label.new()
	_remaining_label.text = tr("LIFE_CHOICE_POINTS_REMAINING") + "：%d" % TOTAL_POINTS
	_remaining_label.add_theme_font_size_override("font_size", 13)
	_update_color()
	add_child(_remaining_label)

func get_remaining() -> int:
	return _remaining

func get_total() -> int:
	return TOTAL_POINTS

func recalculate(family_cost: int, trait_costs: Array[int], attribute_delta: int) -> void:
	var trait_total: int = 0
	for c: int in trait_costs:
		trait_total += c
	_spent = family_cost + trait_total + attribute_delta
	_remaining = TOTAL_POINTS - _spent
	_spent_label.text = tr("LIFE_CHOICE_POINTS_SPENT") + "：%d" % _spent
	_remaining_label.text = tr("LIFE_CHOICE_POINTS_REMAINING") + "：%d" % _remaining
	_update_color()
	points_changed.emit(_remaining)

func can_spend(amount: int) -> bool:
	return _remaining - amount >= 0

func _update_color() -> void:
	if _remaining >= 5:
		_remaining_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	elif _remaining >= 1:
		_remaining_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	elif _remaining == 0:
		_remaining_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
	else:
		_remaining_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
