extends VBoxContainer

signal attributes_changed(attributes: Dictionary, total_delta: int)

const ATTR_BASE: int = 10
const ATTR_MIN: int = 0
const ATTR_MAX: int = 30

var _attributes: Dictionary = {
	"intelligence": ATTR_BASE,
	"courage": ATTR_BASE,
	"health": ATTR_BASE
}

var _attr_labels: Dictionary = {}
var _attr_minus_btns: Dictionary = {}
var _attr_plus_btns: Dictionary = {}
var _points_display: Node

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	var icons: Dictionary = {"intelligence": "🧠", "courage": "⚔", "health": "❤"}
	var names: Dictionary = {"intelligence": "ATTR_INTELLIGENCE_DISPLAY_NAME", "courage": "ATTR_COURAGE_DISPLAY_NAME", "health": "ATTR_HEALTH_DISPLAY_NAME"}
	for attr_name: String in ["intelligence", "courage", "health"]:
		var row: HBoxContainer = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 6)
		var name_label: Label = Label.new()
		name_label.text = icons.get(attr_name, "") + " " + tr(names.get(attr_name, attr_name))
		name_label.add_theme_font_size_override("font_size", 13)
		name_label.custom_minimum_size = Vector2(90, 0)
		row.add_child(name_label)
		var minus_btn: Button = Button.new()
		minus_btn.text = "-"
		minus_btn.custom_minimum_size = Vector2(28, 28)
		minus_btn.pressed.connect(_on_minus.bind(attr_name))
		row.add_child(minus_btn)
		_attr_minus_btns[attr_name] = minus_btn
		var val_label: Label = Label.new()
		val_label.text = str(_attributes[attr_name])
		val_label.add_theme_font_size_override("font_size", 15)
		val_label.custom_minimum_size = Vector2(36, 0)
		val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(val_label)
		_attr_labels[attr_name] = val_label
		var plus_btn: Button = Button.new()
		plus_btn.text = "+"
		plus_btn.custom_minimum_size = Vector2(28, 28)
		plus_btn.pressed.connect(_on_plus.bind(attr_name))
		row.add_child(plus_btn)
		_attr_plus_btns[attr_name] = plus_btn
		add_child(row)
	_update_buttons()

func setup(points_display: Node) -> void:
	_points_display = points_display

func get_attributes() -> Dictionary:
	return _attributes.duplicate()

func get_total_delta() -> int:
	var delta: int = 0
	for attr_name: String in _attributes:
		delta += _attributes[attr_name] - ATTR_BASE
	return delta

func _on_minus(attr_name: String) -> void:
	if _attributes[attr_name] <= ATTR_MIN:
		return
	_attributes[attr_name] -= 1
	_attr_labels[attr_name].text = str(_attributes[attr_name])
	_update_buttons()
	_emit_change()

func _on_plus(attr_name: String) -> void:
	if _attributes[attr_name] >= ATTR_MAX:
		return
	if _points_display and not _points_display.can_spend(1):
		return
	_attributes[attr_name] += 1
	_attr_labels[attr_name].text = str(_attributes[attr_name])
	_update_buttons()
	_emit_change()

func _update_buttons() -> void:
	for attr_name: String in _attributes:
		var minus_btn: Button = _attr_minus_btns.get(attr_name) as Button
		var plus_btn: Button = _attr_plus_btns.get(attr_name) as Button
		if minus_btn:
			minus_btn.disabled = _attributes[attr_name] <= ATTR_MIN
		if plus_btn:
			plus_btn.disabled = _attributes[attr_name] >= ATTR_MAX

func _emit_change() -> void:
	attributes_changed.emit(_attributes.duplicate(), get_total_delta())
