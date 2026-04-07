extends CanvasLayer
class_name GameHUD

signal gold_changed(new_gold: int)
signal hp_changed(new_hp: int, max_hp: int)
signal tower_experience_changed(tower: Tower, new_exp: int)  # 🆕 塔经验变化信号

@export_group("Game State")
@export var base_hp: int = 20
@export var max_base_hp: int = 20
@export var gold: int = 500

var panel: PanelContainer
var hp_bar: ProgressBar
var hp_label: Label
var gold_label: Label

func _ready():
	setup_ui()
	# 🆕 添加到 game_hud 组，方便敌人查找
	add_to_group("game_hud")

func setup_ui():
	var margin = MarginContainer.new()
	margin.anchor_left = 0.0
	margin.anchor_top = 0.0
	margin.anchor_right = 0.0
	margin.anchor_bottom = 0.0
	margin.offset_left = 20.0
	margin.offset_top = 20.0
	margin.offset_right = 320.0
	margin.offset_bottom = 100.0
	add_child(margin)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 80)
	margin.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var hp_container = HBoxContainer.new()
	hp_container.add_theme_constant_override("separation", 10)
	vbox.add_child(hp_container)

	var hp_icon = Label.new()
	hp_icon.text = "❤ 基地血量:"
	hp_icon.add_theme_font_size_override("font_size", 16)
	hp_container.add_child(hp_icon)

	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(150, 20)
	hp_bar.max_value = max_base_hp
	hp_bar.value = base_hp
	hp_bar.show_percentage = false
	hp_bar.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	var fill_style = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		fill_style.bg_color = Color(0.2, 0.8, 0.2)
	hp_container.add_child(hp_bar)

	hp_label = Label.new()
	hp_label.text = "%d/%d" % [base_hp, max_base_hp]
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_label.custom_minimum_size.x = 60
	hp_container.add_child(hp_label)

	var gold_container = HBoxContainer.new()
	gold_container.add_theme_constant_override("separation", 10)
	vbox.add_child(gold_container)

	var gold_icon = Label.new()
	gold_icon.text = "💰 金币:"
	gold_icon.add_theme_font_size_override("font_size", 16)
	gold_container.add_child(gold_icon)

	gold_label = Label.new()
	gold_label.text = str(gold)
	gold_label.add_theme_font_size_override("font_size", 18)
	gold_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	gold_container.add_child(gold_label)

func update_hp(value: int):
	base_hp = clampi(value, 0, max_base_hp)
	hp_bar.value = base_hp
	hp_label.text = "%d/%d" % [base_hp, max_base_hp]
	if base_hp <= max_base_hp * 0.3:
		var fill_style = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
		if fill_style:
			fill_style.bg_color = Color(0.9, 0.2, 0.2)
	elif base_hp <= max_base_hp * 0.6:
		var fill_style = hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
		if fill_style:
			fill_style.bg_color = Color(0.9, 0.7, 0.1)
	hp_changed.emit(base_hp, max_base_hp)

func update_gold(value: int):
	gold = value
	gold_label.text = str(gold)
	gold_changed.emit(gold)

func can_afford(cost: int) -> bool:
	return gold >= cost

func spend_gold(cost: int) -> bool:
	if can_afford(cost):
		gold -= cost
		gold_label.text = str(gold)
		gold_changed.emit(gold)
		return true
	return false

## 🆕 添加金币（不花费）
func add_gold(amount: int) -> void:
	gold += amount
	gold_label.text = str(gold)
	gold_changed.emit(gold)

## 🆕 给塔添加经验值
func add_tower_experience(tower: Tower, amount: int) -> void:
	if tower and is_instance_valid(tower):
		tower.add_experience(amount)
		tower_experience_changed.emit(tower, tower.current_experience)
