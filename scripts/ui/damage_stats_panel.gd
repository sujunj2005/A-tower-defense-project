extends Control

const PANEL_WIDTH: float = 260.0
const ANIM_DURATION: float = 0.25

var tracker: Node = null
var is_open: bool = false
var _tween: Tween = null

var _panel_bg: PanelContainer
var _content_vbox: VBoxContainer
var _total_label: Label
var _list_container: VBoxContainer
var _toggle_btn: Button
var _click_overlay: ColorRect

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if is_open:
			_refresh_list()

func _ready() -> void:
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = -PANEL_WIDTH - 40.0
	offset_right = 0.0
	offset_top = 0.0
	offset_bottom = 0.0
	_setup_ui()
	_close_instant()

func setup(damage_tracker: Node) -> void:
	tracker = damage_tracker
	if tracker and tracker.has_signal("damage_updated"):
		tracker.damage_updated.connect(_on_damage_updated)

func _setup_ui() -> void:
	_click_overlay = ColorRect.new()
	_click_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_click_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_click_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_click_overlay)
	_click_overlay.gui_input.connect(_on_overlay_input)

	_toggle_btn = Button.new()
	_toggle_btn.text = "◀"
	_toggle_btn.add_theme_font_size_override("font_size", 20)
	_toggle_btn.custom_minimum_size = Vector2(36, 60)
	_toggle_btn.anchor_left = 0.0
	_toggle_btn.anchor_top = 0.5
	_toggle_btn.anchor_right = 0.0
	_toggle_btn.anchor_bottom = 0.5
	_toggle_btn.offset_left = 0.0
	_toggle_btn.offset_top = -30.0
	_toggle_btn.offset_right = 36.0
	_toggle_btn.offset_bottom = 30.0
	var btn_style: StyleBoxFlat = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.15, 0.25, 0.9)
	btn_style.border_color = Color(0.6, 0.5, 0.3, 1.0)
	btn_style.border_width_left = 2
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 2
	btn_style.set_corner_radius_all(6)
	btn_style.set_content_margin_all(4)
	_toggle_btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover: StyleBoxFlat = btn_style.duplicate()
	btn_hover.bg_color = Color(0.25, 0.25, 0.4, 1.0)
	_toggle_btn.add_theme_stylebox_override("hover", btn_hover)
	_toggle_btn.pressed.connect(_on_toggle_pressed)
	add_child(_toggle_btn)

	_panel_bg = PanelContainer.new()
	_panel_bg.anchor_left = 0.0
	_panel_bg.anchor_top = 0.0
	_panel_bg.anchor_right = 1.0
	_panel_bg.anchor_bottom = 1.0
	_panel_bg.offset_left = 36.0
	_panel_bg.offset_right = 0.0
	_panel_bg.offset_top = 0.0
	_panel_bg.offset_bottom = 0.0
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.18, 0.92)
	panel_style.border_color = Color(0.6, 0.5, 0.3, 0.8)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 0
	panel_style.border_width_bottom = 2
	panel_style.set_corner_radius_all(0)
	panel_style.set_content_margin_all(10)
	_panel_bg.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel_bg)

	_content_vbox = VBoxContainer.new()
	_content_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content_vbox.offset_left = 10
	_content_vbox.offset_right = -10
	_content_vbox.offset_top = 10
	_content_vbox.offset_bottom = -10
	_content_vbox.add_theme_constant_override("separation", 6)
	_panel_bg.add_child(_content_vbox)

	var title: Label = Label.new()
	title.text = tr("DAMAGE_STATS")
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content_vbox.add_child(title)

	var sep0: HSeparator = HSeparator.new()
	_content_vbox.add_child(sep0)

	_total_label = Label.new()
	_total_label.text = tr("TOTAL_DAMAGE_INT") % 0
	_total_label.add_theme_font_size_override("font_size", 14)
	_total_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5, 1.0))
	_content_vbox.add_child(_total_label)

	var sep1: HSeparator = HSeparator.new()
	_content_vbox.add_child(sep1)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content_vbox.add_child(scroll)

	_list_container = VBoxContainer.new()
	_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_container.add_theme_constant_override("separation", 3)
	scroll.add_child(_list_container)

func _on_toggle_pressed() -> void:
	if is_open:
		close()
	else:
		open()

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()

func open() -> void:
	if is_open:
		return
	is_open = true
	_refresh_list()
	_click_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_click_overlay.color = Color(0.0, 0.0, 0.0, 0.3)
	_toggle_btn.text = "▶"
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "offset_left", -PANEL_WIDTH - 40.0, ANIM_DURATION).set_ease(Tween.EASE_OUT)

func close() -> void:
	if not is_open:
		return
	is_open = false
	_click_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_click_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_toggle_btn.text = "◀"
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "offset_left", -40.0, ANIM_DURATION).set_ease(Tween.EASE_IN)

func _close_instant() -> void:
	is_open = false
	offset_left = -40.0
	_click_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_click_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_toggle_btn.text = "◀"

func _on_damage_updated() -> void:
	if is_open:
		_refresh_list()

func _refresh_list() -> void:
	if not tracker:
		return
	for child: Node in _list_container.get_children():
		child.queue_free()
	var records: Array[Dictionary] = tracker.get_records()
	var total: float = tracker.get_total_damage()
	_total_label.text = tr("TOTAL_DAMAGE") % total
	if records.is_empty():
		var empty: Label = Label.new()
		empty.text = tr("NO_DATA")
		empty.add_theme_font_size_override("font_size", 12)
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_list_container.add_child(empty)
		return
	for rec: Dictionary in records:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		_list_container.add_child(row)
		var name_label: Label = Label.new()
		var display_name: String = rec["tower_name"]
		if rec.has("level"):
			display_name += " Lv.%d" % rec["level"]
		if rec["is_sold"]:
			display_name += tr("TOWER_SOLD")
		name_label.text = display_name
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0) if rec["is_sold"] else Color(0.9, 0.9, 0.9, 1.0))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var dmg_label: Label = Label.new()
		dmg_label.text = "%.0f" % rec["total_damage"]
		dmg_label.add_theme_font_size_override("font_size", 12)
		dmg_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3, 1.0))
		dmg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		dmg_label.custom_minimum_size.x = 55.0
		row.add_child(dmg_label)
