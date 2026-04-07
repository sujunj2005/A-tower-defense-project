extends Node

## 窗口最小尺寸常量（PRD要求：800x600）
const MIN_WINDOW_SIZE := Vector2i(800, 600)

signal progress_change(progress: float)
signal load_done
signal scene_loaded

var _target_scene: String = ""
var _progress: Array = []
var _use_sub_threads: bool = true
var _last_window_size: Vector2i = Vector2i.ZERO

func _ready():
	## ✅ 强制设置Stretch模式（绕过Godot 4.4+ regression bug #106496）
	## 来源：Godot官方文档 - Window.content_scale_mode
	## 原因：project.godot中的stretch配置在4.4+版本可能不生效，
	## 需要通过运行时API显式设置才能保证窗口缩放适配正常工作
	_force_stretch_mode()

	## 设置窗口最小尺寸保护（任务D：可选增强）
	## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §2多分辨率支持
	_setup_window_min_size()
	
	## 初始化窗口大小记录
	## 修复：使用 DisplayServer.window_get_size() 获取实际操作系统窗口大小
	## 来源：Godot 4.6 API - DisplayServer.window_get_size() 返回实际窗口系统大小
	_last_window_size = DisplayServer.window_get_size()
	
	## 启动窗口大小监控（使用_process更可靠）
	set_process(true)

func _force_stretch_mode() -> void:
	## 强制设置分辨率自适应拉伸模式
	var root_window = get_tree().root
	if root_window:
		## 设置基础设计分辨率（关键！）
		## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §2多分辨率支持
		## 说明：定义游戏的基础分辨率，stretch模式会基于此值进行缩放
		root_window.content_scale_size = Vector2i(1024, 768)
		
		## 设置拉伸模式为canvas_items（2D元素直接以目标分辨率渲染）
		## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §3.2 Canvas Items
		## 优势：可以正确获取实际窗口大小，避免视口大小与实际窗口大小混淆
		root_window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		
		## 设置纵横比保持策略为expand（自由缩放，充满整个窗口）
		## 来源：knowledge_base/09_Rendering/09A_Rendering_Basics.md §4.5 Expand
		## 优势：窗口可以自由缩放，充满整个窗口空间
		root_window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
		
		## 启用高DPI支持（解决高分辨率显示器模糊问题）
		# root_window.use_hidpi = true  # 注意：此属性在Godot 4.6中可能不存在或已移除

		print("[StretchMode] 强制设置完成:")
		print("  - content_scale_size: ", root_window.content_scale_size)
		print("  - content_scale_mode: ", root_window.content_scale_mode)
		print("  - content_scale_aspect: ", root_window.content_scale_aspect)
		print("  - window size: ", root_window.size)

func _setup_window_min_size() -> void:
	## 配置窗口最小尺寸
	## 注意：不再使用size_changed信号，改用_notification监听窗口变化
	var root_window = get_tree().root
	if root_window:
		## 设置窗口最小尺寸为800x600
		root_window.min_size = MIN_WINDOW_SIZE

func _on_window_size_changed() -> void:
	## 窗口大小变化回调，确保不小于最小尺寸
	var current_size = DisplayServer.window_get_size()
	print("[WindowSize] 窗口大小变化：", current_size)
	
	var root_window = get_tree().root
	if root_window:
		if current_size.x < MIN_WINDOW_SIZE.x or current_size.y < MIN_WINDOW_SIZE.y:
			print("窗口尺寸 %s 小于最小要求 %s，自动调整" % [current_size, MIN_WINDOW_SIZE])
			root_window.size = Vector2i(
				max(current_size.x, MIN_WINDOW_SIZE.x),
				max(current_size.y, MIN_WINDOW_SIZE.y)
			)

func goto_scene(scene_path: String) -> void:
	_target_scene = scene_path
	set_process(true)
	
	# 先清理旧场景（防止菜单等残留）
	if get_tree().current_scene:
		var old_scene = get_tree().current_scene
		get_tree().current_scene = null
		old_scene.queue_free()
	
	var loading_scene = load("res://scenes/loading.tscn")
	if not loading_scene:
		push_error("Failed to load loading scene")
		return
	var instance = loading_scene.instantiate()
	if instance.has_signal("loading_screen_ready"):
		progress_change.connect(instance._update_progress)
		load_done.connect(instance._on_load_done)
	get_tree().root.add_child(instance)
	get_tree().current_scene = instance
	get_tree().current_scene.emit_signal("tree_entered")

func goto_game(map_id: String = "map_01") -> void:
	_target_scene = "res://scenes/main.tscn"
	set_process(true)
	
	# 先清理旧场景（防止菜单等残留）
	if get_tree().current_scene:
		var old_scene = get_tree().current_scene
		get_tree().current_scene = null
		old_scene.queue_free()
	
	var loading_scene = load("res://scenes/loading.tscn")
	if not loading_scene:
		push_error("Failed to load loading scene")
		return
	var instance = loading_scene.instantiate()
	if map_id != "map_01":
		instance.set_meta("target_map_id", map_id)
	if instance.has_signal("loading_screen_ready"):
		progress_change.connect(instance._update_progress)
		load_done.connect(instance._on_load_done)
	get_tree().root.add_child(instance)
	get_tree().current_scene = instance
	get_tree().current_scene.emit_signal("tree_entered")

func start_async_load() -> void:
	if _target_scene == "":
		return
	var state = ResourceLoader.load_threaded_request(_target_scene, "", _use_sub_threads)
	if state == OK:
		set_process(true)
	else:
		push_error("Failed to start async load: %s" % _target_scene)

func _process(_delta: float) -> void:
	## 持续监控窗口大小变化
	_check_window_size()
	
	## 异步加载处理
	if _target_scene == "":
		return
	
	var status = ResourceLoader.load_threaded_get_status(_target_scene, _progress)
	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, \
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Async load failed: %s" % _target_scene)
			set_process(false)
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_change.emit(_progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_resource = ResourceLoader.load_threaded_get(_target_scene)
			progress_change.emit(1.0)
			load_done.emit()
			if loaded_resource is PackedScene:
				get_tree().change_scene_to_packed(loaded_resource)
			else:
				get_tree().change_scene_to_file(_target_scene)
			_target_scene = ""
			set_process(false)
			scene_loaded.emit()

func return_to_main_menu() -> void:
	_target_scene = ""
	get_tree().change_scene_to_file("res://scenes/menu.tscn")



func _check_window_size() -> void:
	## 持续监控窗口大小变化（比信号更可靠）
	## 修复：使用 DisplayServer.window_get_size() 获取实际操作系统窗口大小
	## 来源：Godot 4.6 API - DisplayServer.window_get_size() 返回实际窗口系统大小
	var current_size = DisplayServer.window_get_size()
	
	## 检测窗口大小变化
	var size_changed = current_size != _last_window_size
	
	if size_changed:
		_last_window_size = current_size
		print("[WindowSize] 检测到窗口大小变化：", current_size)
		_on_window_size_changed()
