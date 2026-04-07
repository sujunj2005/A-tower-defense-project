extends Control
class_name LoadingScreen

signal loading_screen_ready

var progress_bar: ProgressBar
var progress_label: Label

func _ready():
	setup_ui()
	loading_screen_ready.emit()
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.has_method("start_async_load"):
		scene_manager.start_async_load()

func setup_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title = Label.new()
	title.text = "加载中..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	## 修复：使用锚点布局替代硬编码坐标
	## 来源：knowledge_base/07_UI_System/07B_Size_and_Anchors_Detailed.md
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 250
	title.offset_bottom = 310
	title.offset_left = 100
	title.offset_right = -100
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	add_child(title)

	var bar_container = MarginContainer.new()
	bar_container.anchor_left = 0.5
	bar_container.anchor_top = 0.5
	bar_container.anchor_right = 0.5
	bar_container.anchor_bottom = 0.5
	bar_container.offset_left = -250
	bar_container.offset_top = 20
	bar_container.offset_right = 250
	bar_container.offset_bottom = 40
	add_child(bar_container)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(500, 20)
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.add_theme_stylebox_override("background", StyleBoxFlat.new())
	var bg_style = progress_bar.get_theme_stylebox("background") as StyleBoxFlat
	if bg_style:
		bg_style.bg_color = Color(0.3, 0.3, 0.3, 1.0)
		bg_style.set_corner_radius_all(4)
	progress_bar.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	var fill_style = progress_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		fill_style.bg_color = Color(0.2, 0.8, 0.4, 1.0)
		fill_style.set_corner_radius_all(4)
	bar_container.add_child(progress_bar)

	progress_label = Label.new()
	progress_label.text = "0%"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.anchor_left = 0.0
	progress_label.anchor_top = 0.0
	progress_label.anchor_right = 1.0
	progress_label.anchor_bottom = 1.0
	progress_label.offset_top = 25
	progress_label.add_theme_font_size_override("font_size", 16)
	progress_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	bar_container.add_child(progress_label)

func _update_progress(new_value: float) -> void:
	if progress_bar:
		progress_bar.set_value_no_signal(new_value)
	if progress_label:
		progress_label.text = "%d%%" % (new_value * 100)

func _on_load_done() -> void:
	if progress_bar:
		progress_bar.value = 1.0
	if progress_label:
		progress_label.text = "100%"
