extends PanelContainer
class_name EnemyInfoPanel

var _current_enemy: Enemy = null
var _info_label: RichTextLabel
var _title_label: Label
var _close_button: Button
var _effect_timer_container: HBoxContainer
var _effect_timer_items: Dictionary = {}

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if visible and _current_enemy and is_instance_valid(_current_enemy):
			_title_label.text = "👹 " + _current_enemy.config.get_display_name()
			_info_label.text = _build_enemy_info_text(_current_enemy)

func _ready() -> void:
	visible = false
	_setup_ui()

func _setup_ui() -> void:
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = 20.0
	offset_right = -20.0
	offset_top = -210.0
	offset_bottom = -10.0

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_color = Color(0.8, 0.3, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	var header: HBoxContainer = HBoxContainer.new()
	vbox.add_child(header)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 15)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)

	_close_button = Button.new()
	_close_button.text = "✕"
	_close_button.custom_minimum_size = Vector2(24, 24)
	_close_button.add_theme_font_size_override("font_size", 12)
	_close_button.pressed.connect(hide_panel)
	header.add_child(_close_button)

	_info_label = RichTextLabel.new()
	_info_label.bbcode_enabled = true
	_info_label.fit_content = true
	_info_label.scroll_following = false
	_info_label.custom_minimum_size = Vector2(0, 85)
	_info_label.add_theme_font_size_override("normal_font_size", 13)
	_info_label.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9, 1.0))
	vbox.add_child(_info_label)

	_effect_timer_container = HBoxContainer.new()
	_effect_timer_container.add_theme_constant_override("separation", 6)
	_effect_timer_container.visible = false
	vbox.add_child(_effect_timer_container)
	_setup_effect_timer_items()

func show_enemy_info(enemy: Enemy) -> void:
	if not enemy or not enemy.config:
		return
	_current_enemy = enemy
	_title_label.text = "👹 " + enemy.config.get_display_name()
	_info_label.text = _build_enemy_info_text(enemy)
	visible = true

func hide_panel() -> void:
	visible = false
	_current_enemy = null

func get_current_enemy() -> Enemy:
	return _current_enemy

func _build_enemy_info_text(enemy: Enemy) -> String:
	var cfg: EnemyConfig = enemy.config
	var text: String = ""
	text += tr("ENEMY_HP") % [max(0.0, enemy.current_health), cfg.max_health]
	var eff_speed: float = enemy.get_effective_move_speed() if enemy.has_method("get_effective_move_speed") else enemy.base_move_speed
	text += "    " + tr("ENEMY_SPEED") % eff_speed
	if enemy.is_slowed and eff_speed < enemy.base_move_speed:
		text += " (%.0f%%)" % (eff_speed / enemy.base_move_speed * 100.0)
	text += "    " + tr("ENEMY_DAMAGE") % cfg.damage
	text += "    " + tr("ENEMY_GOLD") % cfg.gold_drop
	var phys_res: float = cfg.physical_resistance * 100.0
	var mag_res: float = cfg.magical_resistance * 100.0
	text += "\n" + tr("ENEMY_PHYS_RES") % phys_res
	text += "    " + tr("ENEMY_MAG_RES") % mag_res
	if enemy.is_slowed:
		text += "\n" + tr("ENEMY_SLOWED") % [enemy.slow_amount * 100.0, enemy.slow_timer]
	if enemy.is_dot_active:
		text += "\n" + tr("ENEMY_DOT") % [enemy.dot_damage_per_second, max(0.0, enemy.dot_duration - enemy.dot_elapsed)]
	if enemy.is_stunned:
		text += "\n" + tr("ENEMY_STUNNED") % enemy.stun_timer
	if enemy.is_silenced:
		text += "\n" + tr("ENEMY_SILENCED") % enemy.silence_timer
	if enemy.is_confused:
		text += "\n" + tr("ENEMY_CONFUSED") % enemy.confusion_timer
	if enemy.armor_break_timer > 0:
		text += "\n" + tr("ENEMY_ARMOR_BROKEN") % [enemy.armor_break_amount * 100.0, enemy.armor_break_timer]
	if enemy.debuff_timer > 0:
		text += "\n" + tr("ENEMY_DEBUFF") % [enemy.debuff_amount * 100.0, enemy.debuff_timer]
	return text

func _setup_effect_timer_items() -> void:
	var defs := [
		["slow", "res://images/status_icons/status_slow.png"],
		["dot", "res://images/status_icons/status_dot.png"],
		["stun", "res://images/status_icons/status_stun.png"],
		["silence", "res://images/status_icons/status_silence.png"],
		["confusion", "res://images/status_icons/status_confusion.png"],
		["armor_break", "res://images/status_icons/status_armor_break.png"],
		["debuff", "res://images/status_icons/status_debuff.png"]
	]
	for item: Array in defs:
		var key: String = item[0]
		var icon_path: String = item[1]
		var hbox := HBoxContainer.new()
		hbox.visible = false
		hbox.add_theme_constant_override("separation", 2)
		var icon_tex := AssetsManager.load_image(icon_path) as Texture2D
		if icon_tex:
			var icon := TextureRect.new()
			icon.texture = icon_tex
			icon.custom_minimum_size = Vector2(14, 14)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			hbox.add_child(icon)
		var timer_lbl := Label.new()
		timer_lbl.add_theme_font_size_override("font_size", 11)
		timer_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
		hbox.add_child(timer_lbl)
		_effect_timer_container.add_child(hbox)
		_effect_timer_items[key] = {"container": hbox, "label": timer_lbl}

func _update_effect_timers(enemy: Enemy) -> void:
	if not _effect_timer_container or not enemy:
		return
	var has_any := false
	if _effect_timer_items.has("slow"):
		var item: Dictionary = _effect_timer_items["slow"]
		item["container"].visible = enemy.is_slowed
		if enemy.is_slowed:
			has_any = true
			item["label"].text = "%.1fs" % enemy.slow_timer
	if _effect_timer_items.has("dot"):
		var item: Dictionary = _effect_timer_items["dot"]
		item["container"].visible = enemy.is_dot_active
		if enemy.is_dot_active:
			has_any = true
			item["label"].text = "%.1fs" % max(0.0, enemy.dot_duration - enemy.dot_elapsed)
	if _effect_timer_items.has("stun"):
		var item: Dictionary = _effect_timer_items["stun"]
		item["container"].visible = enemy.is_stunned
		if enemy.is_stunned:
			has_any = true
			item["label"].text = "%.1fs" % enemy.stun_timer
	if _effect_timer_items.has("silence"):
		var item: Dictionary = _effect_timer_items["silence"]
		item["container"].visible = enemy.is_silenced
		if enemy.is_silenced:
			has_any = true
			item["label"].text = "%.1fs" % enemy.silence_timer
	if _effect_timer_items.has("confusion"):
		var item: Dictionary = _effect_timer_items["confusion"]
		item["container"].visible = enemy.is_confused
		if enemy.is_confused:
			has_any = true
			item["label"].text = "%.1fs" % enemy.confusion_timer
	if _effect_timer_items.has("armor_break"):
		var item: Dictionary = _effect_timer_items["armor_break"]
		item["container"].visible = enemy.armor_break_timer > 0
		if enemy.armor_break_timer > 0:
			has_any = true
			item["label"].text = "%.1fs" % enemy.armor_break_timer
	if _effect_timer_items.has("debuff"):
		var item: Dictionary = _effect_timer_items["debuff"]
		item["container"].visible = enemy.debuff_timer > 0
		if enemy.debuff_timer > 0:
			has_any = true
			item["label"].text = "%.1fs" % enemy.debuff_timer
	_effect_timer_container.visible = has_any

func _process(_delta: float) -> void:
	if visible and _current_enemy and is_instance_valid(_current_enemy):
		_info_label.text = _build_enemy_info_text(_current_enemy)
		_update_effect_timers(_current_enemy)
	elif visible and not is_instance_valid(_current_enemy):
		hide_panel()
