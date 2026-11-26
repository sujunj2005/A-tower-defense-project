extends Control


var _progress: float = 0.0
var _active: bool = false
var _remaining_text: String = ""

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)


func set_cooldown(remaining: float, total: float) -> void:
	if total <= 0.0:
		_active = false
		_remaining_text = ""
	else:
		_active = true
		_progress = clampf(1.0 - (remaining / total), 0.0, 1.0)
		_remaining_text = str(int(ceili(remaining)))
	queue_redraw()


func hide_cooldown() -> void:
	_active = false
	_remaining_text = ""
	queue_redraw()


func _draw() -> void:
	if not _active:
		return

	var center: Vector2 = size / 2.0
	var radius: float = min(size.x, size.y) / 2.0 - 2.0

	draw_circle(center, radius, Color(0.0, 0.0, 0.0, 0.55))

	if _progress > 0.0:
		_draw_arc_polygon(center, radius, -PI / 2.0, -PI / 2.0 + _progress * TAU, Color(1.0, 1.0, 1.0, 0.7))

	if _remaining_text != "":
		var font: Font = get_theme_default_font()
		var font_size: int = maxi(int(radius * 0.65), 10)
		var text_size: Vector2 = font.get_string_size(_remaining_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, center - text_size / 2.0, _remaining_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1.0, 1.0, 1.0, 0.95))


func _draw_arc_polygon(center: Vector2, radius: float, angle_from: float, angle_to: float, color: Color) -> void:
	var point_count: int = maxi(ceil((angle_to - angle_from) / (TAU / 64.0)), 8)
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	points.resize(point_count + 2)
	colors.resize(point_count + 2)
	points[0] = center
	colors[0] = color
	for i: int in range(point_count + 1):
		var t: float = float(i) / float(point_count)
		var angle: float = angle_from + t * (angle_to - angle_from)
		points[i + 1] = center + Vector2(cos(angle), sin(angle)) * radius
		colors[i + 1] = color
	draw_polygon(points, colors)
