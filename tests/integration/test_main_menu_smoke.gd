extends GutTest


func test_project_main_scene_initializes_its_start_button() -> void:
	var main_scene_path: String = ProjectSettings.get_setting("application/run/main_scene")
	var main_scene: PackedScene = load(main_scene_path)
	assert_not_null(main_scene, "项目配置的主场景应可加载")
	if main_scene == null:
		return

	var menu := main_scene.instantiate()
	add_child_autofree(menu)
	var start_button: Button = null
	for child in menu.find_children("*", "Button", true, false):
		var button := child as Button
		if button.text == menu.tr("BTN_START_GAME") and button.pressed.has_connections():
			start_button = button
			break

	assert_not_null(start_button, "主菜单应初始化可启动游戏的按钮")
	if start_button != null:
		assert_true(start_button.is_visible_in_tree(), "开始按钮应可见")
		assert_false(start_button.disabled, "开始按钮应可用")
