extends CanvasLayer

## 过渡完成信号
signal transition_completed

## 过渡时间
@export var fade_duration: float = 0.5

## 颜色（默认黑色）
@export var fade_color: Color = Color(0, 0, 0, 1)

var _color_rect: ColorRect
var _tween: Tween = null

func _ready() -> void:
	layer = 100
	_create_fade_overlay()
	hide()

func _create_fade_overlay() -> void:
	_color_rect = ColorRect.new()
	_color_rect.color = fade_color
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_color_rect)

## 淡入场景
func fade_in() -> void:
	show()
	_color_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 1.0)
	
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(_color_rect, "color:a", 0.0, fade_duration)
	_tween.tween_callback(_on_fade_in_completed)

## 淡出场景
func fade_out() -> void:
	show()
	_color_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(_color_rect, "color:a", 1.0, fade_duration)
	_tween.tween_callback(_on_fade_out_completed)

func _on_fade_in_completed() -> void:
	hide()
	transition_completed.emit()

func _on_fade_out_completed() -> void:
	transition_completed.emit()

## 场景切换过渡（淡出→切换→淡入）
func transition_to_scene(scene_path: String) -> void:
	fade_out()
	await transition_completed
	
	# 切换场景
	get_tree().change_scene_to_file(scene_path)
	
	fade_in()
	await transition_completed
