extends Camera2D
class_name CameraController

## 基础分辨率常量（与project.godot中配置一致）
## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §2多分辨率支持
const BASE_RESOLUTION := Vector2i(1024, 768)

var config: MapConfig

var camera_zoom: float = 1.0
var camera_target_zoom: float = 1.0
var camera_position: Vector2 = Vector2.ZERO
var camera_target_position: Vector2 = Vector2.ZERO

var is_dragging: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO
var drag_velocity: Vector2 = Vector2.ZERO

var shake_intensity: float = 0.0
var shake_timer: float = 0.0

func _ready():
	pass

func _unhandled_input(event):
	if not config:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				last_mouse_position = event.position
			else:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera_target_zoom *= (1.0 + config.zoom_speed)
			clamp_zoom()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera_target_zoom /= (1.0 + config.zoom_speed)
			clamp_zoom()
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_delta = (event.position - last_mouse_position) / camera_zoom * config.drag_speed
		drag_velocity = mouse_delta
		camera_target_position -= mouse_delta
		camera_position = camera_target_position
		last_mouse_position = event.position

func _process(delta):
	if not config:
		return

	handle_input(delta)
	update_camera(delta)

func setup_camera():
	var map_size = Vector2(config.map_width * config.tile_size, config.map_height * config.tile_size)
	limit_left = 0
	limit_top = 0
	limit_right = int(map_size.x)
	limit_bottom = int(map_size.y)

	var initial_pos = map_size / 2.0
	camera_position = initial_pos
	camera_target_position = initial_pos
	position = camera_position

	camera_target_zoom = get_max_zoom()
	camera_zoom = camera_target_zoom
	zoom = Vector2(camera_zoom, camera_zoom)

	make_current()

## 获取设计分辨率的视口大小
## 在canvas_items+expand模式下，Camera2D应始终基于设计分辨率计算
## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §3拉伸模式
## 修复说明：原方法使用get_canvas_transform().get_scale()做除法，该值已包含相机zoom，
## 导致与update_camera()中的/camera_zoom形成双重除法错误（zoom²）
## 改为直接返回设计分辨率常量，最稳定且符合Godot引擎设计原理
func _get_design_viewport_size() -> Vector2:
	## 方案A：直接返回常量（推荐，最稳定）
	## 原理：在canvas_items模式下，引擎内部已经处理了拉伸，
	## Camera2D的所有计算都应该基于设计分辨率
	return Vector2(BASE_RESOLUTION)

	## 备选方案B：如果需要动态获取，使用以下代码（当前未启用）
	# var viewport = get_viewport()
	# if viewport and viewport.has_method("get_content_size"):
	#     return viewport.get_content_size()
	# return Vector2(BASE_RESOLUTION)

func get_max_zoom() -> float:
	## 使用设计分辨率视口大小（已修复双重除法bug）
	## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §3拉伸模式
	## 修复说明：原方法调用_get_effective_viewport_size()返回的值已包含zoom转换，
	## 现在改为使用_get_design_viewport_size()直接返回设计分辨率，逻辑更清晰
	var viewport_size = _get_design_viewport_size()
	var map_size = Vector2(config.map_width * config.tile_size, config.map_height * config.tile_size)
	return min(viewport_size.x / map_size.x, viewport_size.y / map_size.y)

func get_min_zoom() -> float:
	return 1.0

func handle_input(delta: float):
	if not config:
		return

	var move_dir = Vector2.ZERO

	if Input.is_key_pressed(KEY_A):
		move_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		move_dir.x += 1.0
	if Input.is_key_pressed(KEY_W):
		move_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		move_dir.y += 1.0

	if move_dir.length() > 0:
		move_dir = move_dir.normalized()
		camera_target_position += move_dir * config.camera_speed * delta / camera_zoom

func clamp_zoom():
	var min_z = get_min_zoom()
	var max_z = get_max_zoom()
	camera_target_zoom = clamp(camera_target_zoom, max_z, min_z)

func update_camera(delta: float):
	if shake_timer > 0:
		shake_timer -= delta
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		position = camera_position + shake_offset
		zoom = Vector2(camera_zoom, camera_zoom)
		return

	if not is_dragging and drag_velocity.length() > 0.5:
		camera_target_position -= drag_velocity
		drag_velocity *= config.drag_inertia
		if drag_velocity.length() < 0.5:
			drag_velocity = Vector2.ZERO

	camera_position = camera_position.move_toward(camera_target_position, config.camera_speed * delta / camera_zoom)
	camera_zoom = lerpf(camera_zoom, camera_target_zoom, 10.0 * delta)

	var map_size = Vector2(config.map_width * config.tile_size, config.map_height * config.tile_size)
	## ✅ 修复：使用设计分辨率视口大小，并正确考虑zoom
	## 修复说明（P0 Bug）：
	## 原代码：var viewport_size = _get_effective_viewport_size() / camera_zoom
	## 错误链路：
	##   1. _get_effective_viewport_size() 内部用 get_canvas_transform().get_scale() 做除法
	##      该scale值已包含相机zoom（例如zoom=2时，scale=2）
	##   2. 外层又 / camera_zoom（再除以2）
	##   3. 结果：viewport_size被除以了 zoom²（4倍），严重偏小
	##
	## 正确做法：
	##   1. _get_design_viewport_size() 返回设计分辨率（1024x768），不含任何运行时变换
	##   2. 手动 / camera_zoom 获取当前缩放下的实际可视区域大小
	##   3. 这样viewport_size的计算准确，边界限制合理
	var base_viewport_size = _get_design_viewport_size()
	var viewport_size = base_viewport_size / camera_zoom

	camera_target_position.x = clamp(camera_target_position.x, viewport_size.x / 2.0, map_size.x - viewport_size.x / 2.0)
	camera_target_position.y = clamp(camera_target_position.y, viewport_size.y / 2.0, map_size.y - viewport_size.y / 2.0)
	camera_position.x = clamp(camera_position.x, viewport_size.x / 2.0, map_size.x - viewport_size.x / 2.0)
	camera_position.y = clamp(camera_position.y, viewport_size.y / 2.0, map_size.y - viewport_size.y / 2.0)

	position = camera_position
	zoom = Vector2(camera_zoom, camera_zoom)

func initialize(map_config: MapConfig):
	config = map_config
	setup_camera()

func shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_timer = duration
