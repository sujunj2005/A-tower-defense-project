extends CanvasLayer

var _tooltip: Node = null

func _ready() -> void:
	layer = 100
	_tooltip = load("res://scripts/ui/components/trait_tooltip.gd").new()
	_tooltip.name = "TraitTooltip"
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tooltip)

func show_trait_tooltip(trait_id: String, pos: Vector2) -> void:
	if _tooltip and _tooltip.has_method("setup"):
		_tooltip.setup(trait_id)
		_tooltip.show_at(pos)

func show_static_tooltip(title: String, description: String, pos: Vector2) -> void:
	if _tooltip and _tooltip.has_method("setup_static"):
		_tooltip.setup_static(title, description)
		_tooltip.show_at(pos)

func hide_tooltip() -> void:
	if _tooltip and _tooltip.has_method("hide_tooltip"):
		_tooltip.hide_tooltip()
