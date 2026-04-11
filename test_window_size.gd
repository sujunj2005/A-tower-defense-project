extends Node2D

# 测试脚本：验证 canvas_items stretch 模式下获取实际窗口大小的方法

@onready var label: Label = $Label

var last_window_size: Vector2i

func _ready() -> void:
	print("=== Godot 4.x canvas_items 模式窗口大小获取测试 ===")
	print("项目设置中的视口大小：", get_tree().root.content_scale_size)
	print("DisplayServer.window_get_size(): ", DisplayServer.window_get_size())
	print("Window.size: ", get_tree().root.size)
	print("get_viewport().size: ", get_viewport().size)
	print("get_viewport().get_visible_rect().size: ", get_viewport().get_visible_rect().size)
	
	last_window_size = DisplayServer.window_get_size()
	
	if label:
		update_label()

func _process(_delta: float) -> void:
	var current_size = DisplayServer.window_get_size()
	
	# 检测窗口大小变化
	if current_size != last_window_size:
		print("\n=== 窗口大小发生变化 ===")
		print("DisplayServer.window_get_size(): ", current_size)
		print("get_viewport().get_visible_rect().size: ", get_viewport().get_visible_rect().size)
		print("get_viewport().size: ", get_viewport().size)
		last_window_size = current_size
		
		if label:
			update_label()

func update_label() -> void:
	var actual_size = get_viewport().get_visible_rect().size
	label.text = "实际渲染视口大小：%dx%d\n" % [actual_size.x, actual_size.y] + \
				 "窗口大小：%dx%d\n" % [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y] + \
				 "设计分辨率：%dx%d" % [get_tree().root.content_scale_size.x, get_tree().root.content_scale_size.y]
