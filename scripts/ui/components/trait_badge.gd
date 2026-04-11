extends HBoxContainer

signal hovered(badge: Control, trait_id: String)
signal unhovered

var _trait_id: String = ""
var _name_label: Label
var _pending_trait_id: String = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_ui()
	if _pending_trait_id != "":
		_resolve_trait_name(_pending_trait_id)
		_pending_trait_id = ""

func _build_ui() -> void:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.25, 0.9)
	style.border_color = Color(0.4, 0.4, 0.6, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(panel)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0, 1.0))
	_name_label.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(_name_label)

func setup(trait_id: String) -> void:
	_trait_id = trait_id
	if is_inside_tree():
		_resolve_trait_name(trait_id)
	else:
		_pending_trait_id = trait_id
		if _name_label:
			_name_label.text = trait_id

func _resolve_trait_name(trait_id: String) -> void:
	var ts: Node = get_node_or_null("/root/TraitSystem")
	if ts and ts.has_method("get_trait_config"):
		var config: Dictionary = ts.get_trait_config(trait_id)
		if _name_label:
			_name_label.text = config.get("name", trait_id)
	else:
		if _name_label:
			_name_label.text = trait_id

func setup_static(display_text: String) -> void:
	_trait_id = ""
	if _name_label:
		_name_label.text = display_text

func get_trait_id() -> String:
	return _trait_id

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		if _trait_id != "":
			hovered.emit(self, _trait_id)
	elif what == NOTIFICATION_MOUSE_EXIT:
		unhovered.emit()
