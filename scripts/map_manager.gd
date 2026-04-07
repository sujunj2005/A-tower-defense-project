extends Node2D

#region Constants

const TERRAIN_SET: int = 0
const TERRAIN_GRASS: int = 0
const TERRAIN_EDGE: int = 1
const TERRAIN_ROAD: int = 2
const MARKER_SIZE: int = 200
const MARKER_RADIUS: int = 90
const LETTER_SIZE: int = 60

#endregion

#region Variables

var map_config: MapConfig
var current_map_id: String = "map_01"

# 游戏状态
var path_points: Array[Vector2i] = []
var tower_positions: Array[Vector2i] = []
var built_towers: Dictionary = {}
var game_time: float = 0.0
var current_tower_slot_index: int = -1

# UI 组件
var tower_slot_rects: Array[Button] = []
var tower_select_ui: TowerSelectUI
var tower_sell_ui: TowerSellUI  # 🆕 出售 UI
var game_hud: GameHUD
var tower_info_panel: PanelContainer
var tower_info_label: Label
var hovered_tower: Tower = null
var range_circle: Node2D
var highlight_rect: ColorRect

# 路径标记
var dash_markers: Array[ColorRect] = []

# 敌人生成器
var enemy_spawner: EnemySpawner

# 缓存的 Callable
var _tower_slot_bound_callables: Dictionary = {}
var _tower_stats_update_callables: Dictionary = {}  # 🆕 存储塔的 stats_updated 信号绑定

#endregion

#region Node References

@onready var camera: Camera2D = $Camera2D
@onready var path_markers: Node2D = $PathMarkers
@onready var ground_layer: TileMapLayer = $GroundLayer

#endregion

#region Lifecycle Functions

func _ready() -> void:
	_load_map_data(current_map_id)
	_initialize_game_objects()
	_setup_ui_components()

func _process(delta: float) -> void:
	game_time += delta
	_update_path_markers(delta)
	_update_tower_hover()

func _exit_tree() -> void:
	_cleanup_signals()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_click()

#endregion

#region Initialization

func _load_map_data(map_id: String) -> void:
	map_config = MapConfig.load_map(map_id)
	if not map_config:
		push_error("Failed to load map config: %s" % map_id)
		return
	
	path_points = map_config.path_points.duplicate()
	tower_positions = map_config.tower_positions.duplicate()
	EnemyConfig.set_map_config(map_config)

func _initialize_game_objects() -> void:
	_create_tile_map()
	_create_path_markers()
	_create_tower_slots()
	_create_spawn_and_base_markers()
	_initialize_camera()
	_create_enemy_spawner()

func _setup_ui_components() -> void:
	_create_tower_select_ui()
	_create_game_hud()
	_create_tower_hover_ui()

#endregion

#region TileMap System

func _create_tile_map() -> void:
	if not ground_layer:
		push_error("GroundLayer not found")
		return
	
	var tile_set: TileSet = ground_layer.tile_set
	if not tile_set:
		push_error("[TileMap] GroundLayer has no TileSet!")
		return
	
	_apply_tile_map_scale()
	_apply_terrain_system()
	_apply_grid_shader()

func _apply_tile_map_scale() -> void:
	var scale_factor: float = map_config.tile_size / 48.0
	ground_layer.scale = Vector2(scale_factor, scale_factor)
	print("[TileMap] Scaling TileMapLayer by: ", scale_factor)

func _apply_terrain_system() -> void:
	var path_set: Dictionary = {}
	for point in path_points:
		path_set[point] = true
	
	var grass_cells: Array[Vector2i] = []
	var road_cells: Array[Vector2i] = []
	var edge_cells: Array[Vector2i] = []
	
	for x in range(map_config.map_width):
		for y in range(map_config.map_height):
			var coords: Vector2i = Vector2i(x, y)
			if _is_edge_cell(x, y):
				edge_cells.append(coords)
			elif path_set.has(coords):
				road_cells.append(coords)
			else:
				grass_cells.append(coords)
	
	print("[TileMap] Applying terrain sets...")
	ground_layer.set_cells_terrain_connect(grass_cells, TERRAIN_SET, TERRAIN_GRASS, false)
	ground_layer.set_cells_terrain_connect(road_cells, TERRAIN_SET, TERRAIN_ROAD, false)
	ground_layer.set_cells_terrain_connect(edge_cells, TERRAIN_SET, TERRAIN_EDGE, false)
	print("[TileMap] Map created successfully")

func _is_edge_cell(x: int, y: int) -> bool:
	return x == 0 or x == map_config.map_width - 1 or y == 0 or y == map_config.map_height - 1

func _apply_grid_shader() -> void:
	var shader_mat: ShaderMaterial = ShaderMaterial.new()
	shader_mat.shader = AssetsManager.load_resource("res://shaders/grid_overlay.gdshader") as Shader
	ground_layer.material = shader_mat
	shader_mat.set_shader_parameter("tile_size", Vector2(map_config.tile_size, map_config.tile_size))
	shader_mat.set_shader_parameter("grid_color", Color(1.0, 1.0, 1.0, 0.5))
	shader_mat.set_shader_parameter("grid_width", 2.0)
	print("[GridShader] Applied to TileMapLayer with tile_size=", map_config.tile_size)

#endregion

#region Path Markers

func _create_path_markers() -> void:
	_clear_existing_markers()
	
	for point in path_points:
		if _is_valid_map_coordinate(point):
			var marker: ColorRect = _create_path_marker(point)
			dash_markers.append(marker)
			path_markers.add_child(marker)

func _clear_existing_markers() -> void:
	for marker in dash_markers:
		marker.queue_free()
	dash_markers.clear()

func _is_valid_map_coordinate(point: Vector2i) -> bool:
	return point.x >= 0 and point.x < map_config.map_width and point.y >= 0 and point.y < map_config.map_height

func _create_path_marker(point: Vector2i) -> ColorRect:
	var marker: ColorRect = ColorRect.new()
	marker.offset_right = 30.0
	marker.offset_bottom = 30.0
	marker.position = Vector2(point * map_config.tile_size) + Vector2(35.0, 35.0)
	marker.color = Color(1, 0.8, 0, 1.0)
	return marker

func _update_path_markers(_delta: float) -> void:
	var marker_count: int = dash_markers.size()
	for i in range(marker_count):
		var marker: ColorRect = dash_markers[i]
		var wave_phase: float = sin(game_time * 4.0 + (marker_count - i) * 0.5)
		marker.visible = (wave_phase + 1.0) / 2.0 > 0.5

#endregion

#region Spawn & Base Markers

func _create_spawn_and_base_markers() -> void:
	var spawn_sprite: Sprite2D = Sprite2D.new()
	spawn_sprite.texture = _create_spawn_marker_texture()
	spawn_sprite.position = _get_tile_center_position(map_config.spawn_point)
	add_child(spawn_sprite)
	
	var base_sprite: Sprite2D = Sprite2D.new()
	base_sprite.texture = _create_base_marker_texture()
	base_sprite.position = _get_tile_center_position(map_config.base_point)
	add_child(base_sprite)

func _get_tile_center_position(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)

func _create_spawn_marker_texture() -> Texture2D:
	var image: Image = Image.create(MARKER_SIZE, MARKER_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_circle(image, Color(1, 0, 0, 0.7))
	_draw_letter_S(image, Color.WHITE)
	return ImageTexture.create_from_image(image)

func _create_base_marker_texture() -> Texture2D:
	var image: Image = Image.create(MARKER_SIZE, MARKER_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_circle(image, Color(0, 0.4, 1, 0.7))
	_draw_letter_H(image, Color.WHITE)
	return ImageTexture.create_from_image(image)

func _draw_circle(image: Image, color: Color) -> void:
	var center: Vector2 = Vector2(MARKER_SIZE / 2, MARKER_SIZE / 2)
	for y in range(MARKER_SIZE):
		for x in range(MARKER_SIZE):
			if Vector2(x, y).distance_to(center) < MARKER_RADIUS:
				image.set_pixel(x, y, color)

func _draw_letter_S(image: Image, color: Color) -> void:
	var center: Vector2 = Vector2(MARKER_SIZE / 2, MARKER_SIZE / 2)
	var half: int = LETTER_SIZE / 2
	
	# 上横
	var bar_height: int = int(LETTER_SIZE * 0.25)
	_draw_horizontal_bar(image, center.y - half, center.y - half + bar_height, 
		center.x - half * 0.8, center.x + half * 0.8, color)
	# 中竖
	var bar_width: float = LETTER_SIZE * 0.12
	_draw_vertical_bar(image, center.y - half, center.y + half, 
		center.x - bar_width, center.x + bar_width, color)
	# 下横
	var bottom_offset: float = half * 0.75
	_draw_horizontal_bar(image, center.y + int(bottom_offset), center.y + half, 
		center.x - half * 0.8, center.x + half * 0.8, color)

func _draw_letter_H(image: Image, color: Color) -> void:
	var center: Vector2 = Vector2(MARKER_SIZE / 2, MARKER_SIZE / 2)
	var half: int = LETTER_SIZE / 2
	
	# 左竖
	_draw_vertical_bar(image, center.y - half, center.y + half, 
		center.x - half * 0.8, center.x - half * 0.3, color)
	# 右竖
	_draw_vertical_bar(image, center.y - half, center.y + half, 
		center.x + half * 0.3, center.x + half * 0.8, color)
	# 中横
	_draw_horizontal_bar(image, center.y - LETTER_SIZE * 0.1, center.y + LETTER_SIZE * 0.1, 
		center.x - half * 0.8, center.x + half * 0.8, color)

func _draw_horizontal_bar(image: Image, y_start: int, y_end: int, x_start: float, x_end: float, color: Color) -> void:
	for y in range(y_start, y_end):
		for x in range(int(x_start), int(x_end)):
			if x >= 0 and x < MARKER_SIZE and y >= 0 and y < MARKER_SIZE:
				image.set_pixel(x, y, color)

func _draw_vertical_bar(image: Image, y_start: int, y_end: int, x_start: float, x_end: float, color: Color) -> void:
	for y in range(y_start, y_end):
		for x in range(int(x_start), int(x_end)):
			if x >= 0 and x < MARKER_SIZE and y >= 0 and y < MARKER_SIZE:
				image.set_pixel(x, y, color)

#endregion

#region Tower Slots

func _create_tower_slots() -> void:
	for i in range(tower_positions.size()):
		var button: Button = _create_tower_slot_button(i)
		_connect_tower_slot_signal(button, i)
		add_child(button)
		tower_slot_rects.append(button)

func _create_tower_slot_button(index: int) -> Button:
	var pos: Vector2i = tower_positions[index]
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(100, 100)  # 使用 custom_minimum_size 而不是 offset
	button.position = Vector2(pos * map_config.tile_size)
	button.text = "塔位"
	button.tooltip_text = "点击建造防御塔"
	return button

func _connect_tower_slot_signal(button: Button, index: int) -> void:
	var bound_callable: Callable = _on_tower_slot_pressed.bind(index)
	_tower_slot_bound_callables[index] = bound_callable
	button.pressed.connect(bound_callable)

func _cleanup_signals() -> void:
	for i in range(tower_slot_rects.size()):
		if _tower_slot_bound_callables.has(i):
			tower_slot_rects[i].pressed.disconnect(_tower_slot_bound_callables[i])
	_tower_slot_bound_callables.clear()
	
	# 🆕 清理所有塔的 stats_updated 信号连接
	for tower in _tower_stats_update_callables.keys():
		if is_instance_valid(tower) and tower.has_signal("stats_updated"):
			tower.stats_updated.disconnect(_tower_stats_update_callables[tower])
	_tower_stats_update_callables.clear()

func _on_tower_slot_pressed(slot_index: int) -> void:
	if built_towers.has(slot_index):
		return
	current_tower_slot_index = slot_index
	var world_pos: Vector2 = _get_tile_center_position(tower_positions[slot_index])
	tower_select_ui.show_at_position(world_pos)

#endregion

#region Tower Building

func build_tower(slot_index: int, tower_type: String) -> void:
	var tower_config: TowerConfig = TowerConfig.get_config(tower_type)
	if not tower_config or not game_hud.can_afford(tower_config.cost):
		return
	
	var tower: Tower = Tower.new()
	tower.position = _get_tile_center_position(tower_positions[slot_index])
	tower.z_index = 10
	add_child(tower)
	tower.initialize(tower_config)
	
	# 🆕 连接塔的悬停信号到 UI
	if tower_select_ui:
		tower.mouse_hover_started.connect(tower_select_ui._on_tower_mouse_hover_started)
		tower.mouse_hover_ended.connect(tower_select_ui._on_tower_mouse_hover_ended)
	
	# 🆕 连接塔的点击信号到出售 UI
	if tower_sell_ui:
		tower.mouse_clicked.connect(_on_tower_mouse_clicked)
	
	# 🆕 连接塔的属性更新信号到 UI 刷新
	if hovered_tower == tower:
		var stats_update_callable: Callable = _on_tower_stats_updated.bind(tower)
		_tower_stats_update_callables[tower] = stats_update_callable
		tower.stats_updated.connect(stats_update_callable)
	
	built_towers[slot_index] = tower
	_hide_tower_slot(slot_index)
	game_hud.spend_gold(tower_config.cost)

func _hide_tower_slot(slot_index: int) -> void:
	if slot_index < tower_slot_rects.size():
		tower_slot_rects[slot_index].visible = false

## 🆕 显示塔位
func _show_tower_slot(slot_index: int) -> void:
	if slot_index < tower_slot_rects.size():
		tower_slot_rects[slot_index].visible = true

#endregion

#region Tower Select UI

func _create_tower_select_ui() -> void:
	tower_select_ui = TowerSelectUI.new()
	tower_select_ui.visible = false
	tower_select_ui.z_index = 100
	add_child(tower_select_ui)
	tower_select_ui.tower_selected.connect(_on_tower_selected)
	tower_select_ui.cancel_pressed.connect(_on_tower_select_cancel)
	
	# 🆕 创建出售 UI
	_create_tower_sell_ui()

func _on_tower_selected(tower_type: String) -> void:
	if current_tower_slot_index < 0:
		return
	
	var tower_config: TowerConfig = TowerConfig.get_config(tower_type)
	if not tower_config:
		return
	
	if not game_hud.can_afford(tower_config.cost):
		_show_insufficient_gold_warning(tower_type)
	else:
		_complete_tower_building(tower_type)

func _show_insufficient_gold_warning(tower_type: String) -> void:
	tower_select_ui.show_not_enough_gold(tower_type)
	tower_select_ui.is_locked = false
	if camera.has_method("shake"):
		camera.shake(5.0, 0.3)

func _complete_tower_building(tower_type: String) -> void:
	build_tower(current_tower_slot_index, tower_type)
	current_tower_slot_index = -1
	tower_select_ui.is_panel_visible = false  # 使用内嵌 get/set 而不是直接设置 visible

func _on_tower_select_cancel() -> void:
	current_tower_slot_index = -1

## 🆕 创建防御塔出售 UI
func _create_tower_sell_ui() -> void:
	tower_sell_ui = TowerSellUI.new()
	tower_sell_ui.visible = false
	add_child(tower_sell_ui)
	tower_sell_ui.tower_sold.connect(_on_tower_sold)
	tower_sell_ui.sell_cancelled.connect(_on_tower_sell_cancelled)

## 🆕 防御塔出售处理
func _on_tower_sold(tower: Tower) -> void:
	if not tower or not tower.config:
		return
	
	# 🆕 清理 stats_updated 信号连接
	if _tower_stats_update_callables.has(tower):
		tower.stats_updated.disconnect(_tower_stats_update_callables[tower])
		_tower_stats_update_callables.erase(tower)
	
	# 计算出售价格
	var sell_price = int(tower.config.cost * tower.config.sell_ratio)
	
	# 返还金币
	if game_hud and game_hud.has_method("add_gold"):
		game_hud.add_gold(sell_price)
	
	# 从 built_towers 中移除
	for slot_index in built_towers.keys():
		if built_towers[slot_index] == tower:
			built_towers.erase(slot_index)
			# 🆕 显示塔位，允许再次建造
			_show_tower_slot(slot_index)
			break
	
	# 销毁塔
	tower.queue_free()
	
	print("[MapManager] 出售防御塔：%s，返还金币：%d" % [tower.config.tower_name, sell_price])

## 🆕 防御塔出售取消
func _on_tower_sell_cancelled() -> void:
	# 可以在这里添加取消后的逻辑
	pass

## 🆕 防御塔鼠标点击处理
func _on_tower_mouse_clicked(tower: Tower) -> void:
	print("[MapManager] 收到塔的点击信号：%s" % tower.config.tower_name if tower.config else "未知塔")
	if tower_sell_ui:
		print("[MapManager] 显示出售 UI")
		tower_sell_ui.show_for_tower(tower)
	else:
		print("[MapManager] tower_sell_ui 为空！")

## 🆕 防御塔属性更新处理 (修复升级面板不更新的 bug)
func _on_tower_stats_updated(tower: Tower) -> void:
	if hovered_tower == tower and tower_info_panel and tower_info_panel.visible:
		# 实时更新面板信息
		_show_tower_info(tower)
		print("[MapManager] 更新塔的信息面板：%s (Lv.%d)" % [tower.config.tower_name if tower.config else "未知", tower.current_level])

func _handle_left_click() -> void:
	if tower_select_ui and tower_select_ui.visible:
		var local_pos: Vector2 = tower_select_ui.get_local_mouse_position()
		var panel_rect: Rect2 = Rect2(tower_select_ui.panel.position, tower_select_ui.panel.size)
		if not panel_rect.has_point(local_pos):
			tower_select_ui.close_panel()
			current_tower_slot_index = -1

#endregion

#region Camera & HUD

func _initialize_camera() -> void:
	if camera.has_method("initialize"):
		camera.initialize(map_config)

func _create_game_hud() -> void:
	game_hud = GameHUD.new()
	add_child(game_hud)

#endregion

#region Tower Hover UI

func _create_tower_hover_ui() -> void:
	range_circle = Node2D.new()
	range_circle.z_index = 9
	range_circle.visible = false
	add_child(range_circle)
	
	highlight_rect = ColorRect.new()
	highlight_rect.size = Vector2(map_config.tile_size, map_config.tile_size)
	highlight_rect.color = Color(1, 1, 0.5, 0.3)
	highlight_rect.z_index = 9
	highlight_rect.visible = false
	add_child(highlight_rect)
	
	_create_tower_info_panel()

func _create_tower_info_panel() -> void:
	tower_info_panel = PanelContainer.new()
	tower_info_panel.visible = false
	tower_info_panel.z_index = 200
	_setup_panel_anchors(tower_info_panel)
	_setup_panel_style(tower_info_panel)
	add_child(tower_info_panel)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	tower_info_panel.add_child(vbox)
	
	tower_info_label = Label.new()
	tower_info_label.add_theme_font_size_override("font_size", 14)
	tower_info_label.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(tower_info_label)

func _setup_panel_anchors(panel: PanelContainer) -> void:
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -100
	panel.offset_top = -50
	panel.offset_right = 100
	panel.offset_bottom = 50

func _setup_panel_style(panel: PanelContainer) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = Color(0.8, 0.7, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)

func _update_tower_hover() -> void:
	if tower_select_ui and tower_select_ui.visible:
		_hide_tower_hover_ui()
		return
	
	var mouse_world_pos: Vector2 = get_global_mouse_position()
	var found_tower: Tower = _find_tower_at_position(mouse_world_pos)
	
	if found_tower != hovered_tower:
		hovered_tower = found_tower
		if hovered_tower:
			_show_tower_hover_ui(hovered_tower)
		else:
			_hide_tower_hover_ui()
	elif hovered_tower:
		_update_tower_info_position()

func _find_tower_at_position(mouse_pos: Vector2) -> Tower:
	var tile_size_half: float = map_config.tile_size / 2.0
	var tile_size_full: float = map_config.tile_size
	
	for slot_index in built_towers.keys():
		var tower: Tower = built_towers[slot_index]
		var tower_rect: Rect2 = Rect2(
			tower.position - Vector2(tile_size_half, tile_size_half),
			Vector2(tile_size_full, tile_size_full)
		)
		if tower_rect.has_point(mouse_pos):
			return tower
	return null

func _show_tower_hover_ui(tower: Tower) -> void:
	if not tower or not tower.config:
		return
	
	# 🆕 连接 stats_updated 信号 (如果还没有连接)
	if not _tower_stats_update_callables.has(tower):
		var stats_update_callable: Callable = _on_tower_stats_updated.bind(tower)
		_tower_stats_update_callables[tower] = stats_update_callable
		tower.stats_updated.connect(stats_update_callable)
	
	_show_highlight_rect(tower)
	_show_range_circle(tower)
	_show_tower_info(tower)

func _show_highlight_rect(tower: Tower) -> void:
	highlight_rect.position = tower.position - Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0)
	highlight_rect.visible = true

func _show_range_circle(tower: Tower) -> void:
	range_circle.position = tower.position
	range_circle.visible = true
	_clear_range_circle()
	_draw_attack_range_circle(tower.config.attack_range)

func _clear_range_circle() -> void:
	for child in range_circle.get_children():
		child.queue_free()

func _draw_attack_range_circle(attack_range: float) -> void:
	# 创建填充的半透明圆形区域（替代原来的 Line2D 空心圆）
	var circle_area: ColorRect = ColorRect.new()
	circle_area.color = Color(1, 0.3, 0.3, 0.15)  # 半透明红色
	circle_area.size = Vector2(attack_range * 2, attack_range * 2)
	circle_area.position = Vector2(-attack_range, -attack_range)  # 居中
	circle_area.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不阻挡鼠标事件
	
	# 使用 ShaderMaterial 实现圆形裁剪（只显示圆形区域）
	var shader_material = ShaderMaterial.new()
	shader_material.shader = AssetsManager.load_resource("res://shaders/circle_mask.gdshader") as Shader
	circle_area.material = shader_material
	
	range_circle.add_child(circle_area)
	
	# 可选：保留边缘线以增强可见性
	var edge_line: Line2D = Line2D.new()
	edge_line.default_color = Color(1, 0.3, 0.3, 0.4)
	edge_line.width = 2.0
	var circle_points: int = 64
	for i in range(circle_points + 1):
		var angle: float = (float(i) / float(circle_points)) * TAU
		var point: Vector2 = Vector2(cos(angle), sin(angle)) * attack_range
		edge_line.add_point(point)
	range_circle.add_child(edge_line)

func _show_tower_info(tower: Tower) -> void:
	if not tower.config:
		return
	var cfg: TowerConfig = tower.config
	# 🐛 修复：使用塔的 current_level 而不是配置的 tower_level
	var info: String = "%s (Lv.%d)\n" % [cfg.tower_name, tower.current_level]
	info += "━━━━━━━━━━━━━━━\n"
	info += "⚔ 伤害：%.0f\n" % cfg.damage
	info += "🎯 射程：%.0f\n" % cfg.attack_range
	info += "⚡ 攻速：%.1f/s" % cfg.attack_speed
	tower_info_label.text = info
	tower_info_panel.visible = true
	_update_tower_info_position()

func _update_tower_info_position() -> void:
	if not hovered_tower:
		return
	var tile_size_half: float = map_config.tile_size / 2.0
	var screen_pos: Vector2 = hovered_tower.position + Vector2(0, tile_size_half + 15)
	tower_info_panel.position = screen_pos

func _hide_tower_hover_ui() -> void:
	if hovered_tower and _tower_stats_update_callables.has(hovered_tower):
		hovered_tower.stats_updated.disconnect(_tower_stats_update_callables[hovered_tower])
		_tower_stats_update_callables.erase(hovered_tower)
	hovered_tower = null
	highlight_rect.visible = false
	range_circle.visible = false
	tower_info_panel.visible = false

#endregion

#region Enemy Spawner

func _create_enemy_spawner() -> void:
	enemy_spawner = EnemySpawner.new()
	enemy_spawner.initialize(map_config, self)
	add_child(enemy_spawner)
	enemy_spawner.enemy_reached_base.connect(_on_enemy_reached_base)

func _on_enemy_reached_base(enemy: Enemy) -> void:
	if game_hud and game_hud.base_hp > 0:
		game_hud.update_hp(game_hud.base_hp - 1)

#endregion
