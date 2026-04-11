extends Node

func _ready():
	var root = get_tree().root
	print("=== Window Content Scale 枚举值验证 ===")
	print("CONTENT_SCALE_MODE_DISABLED = ", Window.CONTENT_SCALE_MODE_DISABLED)
	print("CONTENT_SCALE_MODE_CANVAS_ITEMS = ", Window.CONTENT_SCALE_MODE_CANVAS_ITEMS)
	print("CONTENT_SCALE_MODE_VIEWPORT = ", Window.CONTENT_SCALE_MODE_VIEWPORT)
	print("")
	print("CONTENT_SCALE_ASPECT_IGNORE = ", Window.CONTENT_SCALE_ASPECT_IGNORE)
	print("CONTENT_SCALE_ASPECT_KEEP = ", Window.CONTENT_SCALE_ASPECT_KEEP)
	print("CONTENT_SCALE_ASPECT_KEEP_WIDTH = ", Window.CONTENT_SCALE_ASPECT_KEEP_WIDTH)
	print("CONTENT_SCALE_ASPECT_KEEP_HEIGHT = ", Window.CONTENT_SCALE_ASPECT_KEEP_HEIGHT)
	print("CONTENT_SCALE_ASPECT_EXPAND = ", Window.CONTENT_SCALE_ASPECT_EXPAND)
	print("")
	print("=== 当前窗口设置 ===")
	print("content_scale_mode = ", root.content_scale_mode)
	print("content_scale_aspect = ", root.content_scale_aspect)
	print("content_scale_size = ", root.content_scale_size)
	print("window size = ", root.size)
