extends PanelContainer
class_name TowerSellUI

signal tower_sold(tower: Tower)
signal sell_cancelled()

var current_tower: Tower = null
var panel: PanelContainer
var tower_name_label: Label
var sell_price_label: Label
var ratio_label: Label
var confirm_button: Button
var cancel_button: Button
var attack_toggle: CheckButton
var attack_label: Label

func _ready():
	visible = false
	setup_ui()

func setup_ui():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style.border_color = Color(0.8, 0.7, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	add_theme_stylebox_override("panel", style)
	
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -150
	offset_top = -120
	offset_right = 150
	offset_bottom = 120
	z_index = 1000
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	add_child(vbox)
	
	tower_name_label = Label.new()
	tower_name_label.text = ""
	tower_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tower_name_label.add_theme_font_size_override("font_size", 18)
	tower_name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(tower_name_label)
	
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	var price_hbox = HBoxContainer.new()
	price_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(price_hbox)
	
	var price_label = Label.new()
	price_label.text = tr("SELL_PRICE_LABEL")
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color(1, 1, 1))
	price_hbox.add_child(price_label)
	
	sell_price_label = Label.new()
	sell_price_label.text = "50"
	sell_price_label.add_theme_font_size_override("font_size", 16)
	sell_price_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	price_hbox.add_child(sell_price_label)
	
	ratio_label = Label.new()
	ratio_label.text = tr("SELL_RATIO") % 50
	ratio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ratio_label.add_theme_font_size_override("font_size", 12)
	ratio_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(ratio_label)
	
	var toggle_container = HBoxContainer.new()
	toggle_container.alignment = BoxContainer.ALIGNMENT_CENTER
	toggle_container.add_theme_constant_override("separation", 10)
	vbox.add_child(toggle_container)
	
	attack_label = Label.new()
	attack_label.text = tr("TOWER_ATTACK_TOGGLE")
	attack_label.add_theme_font_size_override("font_size", 14)
	attack_label.add_theme_color_override("font_color", Color(1, 1, 1))
	toggle_container.add_child(attack_label)
	
	attack_toggle = CheckButton.new()
	attack_toggle.button_pressed = true
	attack_toggle.pressed.connect(_on_attack_toggle_changed)
	toggle_container.add_child(attack_toggle)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(button_hbox)
	
	confirm_button = Button.new()
	confirm_button.text = tr("BTN_SELL")
	confirm_button.custom_minimum_size = Vector2(80, 35)
	var confirm_style = StyleBoxFlat.new()
	confirm_style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	confirm_style.set_corner_radius_all(6)
	confirm_style.set_content_margin_all(8)
	confirm_button.add_theme_stylebox_override("normal", confirm_style)
	var confirm_hover_style = StyleBoxFlat.new()
	confirm_hover_style.bg_color = Color(0.3, 0.7, 0.3, 1.0)
	confirm_hover_style.set_corner_radius_all(6)
	confirm_button.add_theme_stylebox_override("hover", confirm_hover_style)
	confirm_button.pressed.connect(_on_confirm_sell)
	button_hbox.add_child(confirm_button)
	
	cancel_button = Button.new()
	cancel_button.text = tr("BTN_CANCEL")
	cancel_button.custom_minimum_size = Vector2(80, 35)
	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.6, 0.2, 0.2, 0.9)
	cancel_style.set_corner_radius_all(6)
	cancel_style.set_content_margin_all(8)
	cancel_button.add_theme_stylebox_override("normal", cancel_style)
	var cancel_hover_style = StyleBoxFlat.new()
	cancel_hover_style.bg_color = Color(0.7, 0.3, 0.3, 1.0)
	cancel_hover_style.set_corner_radius_all(6)
	cancel_button.add_theme_stylebox_override("hover", cancel_hover_style)
	cancel_button.pressed.connect(_on_cancel)
	button_hbox.add_child(cancel_button)

func show_for_tower(tower: Tower):
	current_tower = tower
	if not tower or not tower.config:
		hide()
		return
	
	tower_name_label.text = tower.config.get_display_name()
	
	var sell_price: int = _calculate_sell_price(tower)
	sell_price_label.text = tr("SELL_GOLD") % sell_price
	
	var ratio_pct: int = int(tower.config.sell_ratio * 100.0)
	ratio_label.text = tr("SELL_RATIO") % ratio_pct
	
	if attack_toggle:
		attack_toggle.button_pressed = tower.is_attack_enabled
	
	visible = true
	global_position = tower.global_position + Vector2(0, -50)

func _calculate_sell_price(tower: Tower) -> int:
	var base_cost: int = tower.config.cost
	var level_bonus: float = 1.0 + float(tower.current_level - 1) * 0.1
	return int(float(base_cost) * tower.config.sell_ratio * level_bonus)

func hide_ui():
	visible = false
	current_tower = null

func _on_confirm_sell():
	if current_tower:
		tower_sold.emit(current_tower)
	hide_ui()

func _on_cancel():
	sell_cancelled.emit()
	hide_ui()

func _on_attack_toggle_changed() -> void:
	if not current_tower:
		return
	current_tower.is_attack_enabled = attack_toggle.button_pressed
	if not attack_toggle.button_pressed:
		current_tower.modulate = Color(1, 1, 1, 0.5)
	else:
		current_tower.modulate = Color(1, 1, 1, 1)
