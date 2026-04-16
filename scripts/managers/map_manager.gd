extends Node2D

const TERRAIN_SET: int = 0
const TERRAIN_GRASS: int = 0
const TERRAIN_EDGE: int = 1
const TERRAIN_ROAD: int = 2
const MARKER_SIZE: int = 200
const MARKER_RADIUS: int = 90
const LETTER_SIZE: int = 60

var map_config: MapConfig
var current_map_id: String = "map_01"

var path_points: Array[Vector2i] = []
var tower_positions: Array[Vector2i] = []
var built_towers: Dictionary = {}
var game_time: float = 0.0
var current_tower_slot_index: int = -1

var tower_slot_rects: Array[Button] = []
var tower_select_ui: TowerSelectUI
var tower_sell_ui: TowerSellUI
var game_hud: GameHUD
var tower_info_panel: PanelContainer
var tower_info_label: Label
var hovered_tower: Tower = null
var range_circle: Node2D
var highlight_rect: ColorRect
var target_info_panel: TargetInfoPanel
var _selected_tower: Tower = null
var _selected_enemy: Enemy = null

var dash_markers: Array[ColorRect] = []

var wave_manager: Node

var _tower_slot_bound_callables: Dictionary = {}
var _tower_stats_update_callables: Dictionary = {}

var _battle_active: bool = false
var _all_enemies_spawned: bool = false
var _enemies_alive: int = 0
var _kill_gold_earned: int = 0
var _wave_announcement: Label
var _wave_announcement_timer: float = 0.0
var _summon_button: Button
var _summon_progress: ProgressBar
var _summon_canvas: CanvasLayer
var _battle_timer_label: Label

var _soft_paused: bool = false
var _pause_label: Label
var _pause_canvas: CanvasLayer

var _battle_speed: float = 1.0
var _speed_buttons: Array[Button] = []

var damage_tracker: Node
var damage_stats_panel: Node


@onready var camera: Camera2D = $Camera2D
@onready var path_markers: Node2D = $PathMarkers
@onready var ground_layer: TileMapLayer = $GroundLayer

func _ready() -> void:
	_load_map_data(current_map_id)
	_initialize_game_objects()
	_setup_ui_components()
	_start_battle()

func _process(delta: float) -> void:
	if not _soft_paused and _battle_active and wave_manager:
		var is_waiting_first: bool = wave_manager._waiting_for_summon and wave_manager._is_first_wave
		if not is_waiting_first:
			game_time += delta
		_update_path_markers(delta)
		_check_battle_end()
		_update_wave_announcement(delta)
		_update_summon_button(delta)
	_update_battle_timer()
	_update_tower_hover()

func _exit_tree() -> void:
	_cleanup_signals()
	_reset_battle_speed()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			if _soft_paused:
				_resume_soft_pause()
			else:
				_start_soft_pause()
			get_viewport().set_input_as_handled()
			return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_click()

func _load_map_data(map_id: String) -> void:
	map_config = MapConfig.load_map(map_id)
	if not map_config:
		push_error("Failed to load map config: %s" % map_id)
		return
	if map_config.waypoints.size() >= 2:
		path_points = MapConfig.compute_path_from_waypoints(map_config.waypoints)
	else:
		path_points = map_config.path_points.duplicate()
	tower_positions = map_config.tower_positions.duplicate()
	EnemyConfig.set_map_config(map_config)

func _initialize_game_objects() -> void:
	_create_tile_map()
	_create_path_markers()
	_create_tower_slots()
	_create_spawn_and_base_markers()
	_initialize_camera()

func _setup_ui_components() -> void:
	_create_tower_select_ui()
	_create_game_hud()
	_create_tower_hover_ui()
	_create_battle_hud()
	_create_target_info_panel()
	_create_damage_stats()

func _start_battle() -> void:
	_battle_active = true
	_all_enemies_spawned = false
	_enemies_alive = 0
	_kill_gold_earned = 0
	_victory_scheduled = false
	var session: GameSessionData = Global.get_game_session()
	if game_hud:
		game_hud.max_base_hp = int(session.max_home_health)
		game_hud.base_hp = int(session.home_health)
		game_hud.gold = session.gold
		game_hud.update_hp(game_hud.base_hp)
		game_hud.update_gold(game_hud.gold)
	_setup_wave_manager()

func _setup_wave_manager() -> void:
	var session: GameSessionData = Global.get_game_session()
	wave_manager = get_node_or_null("/root/WaveManager")
	if wave_manager and wave_manager.has_method("start_battle"):
		if wave_manager.has_signal("wave_started"):
			wave_manager.wave_started.connect(_on_wave_started)
		if wave_manager.has_signal("wave_completed"):
			wave_manager.wave_completed.connect(_on_wave_completed)
		if wave_manager.has_signal("all_waves_completed"):
			wave_manager.all_waves_completed.connect(_on_all_waves_completed)
		if wave_manager.has_signal("boss_wave_started"):
			wave_manager.boss_wave_started.connect(_on_boss_wave_started)
		if wave_manager.has_signal("enemy_spawn_requested"):
			wave_manager.enemy_spawn_requested.connect(_on_enemy_spawn_requested)
		if wave_manager.has_signal("summon_button_requested"):
			wave_manager.summon_button_requested.connect(_on_summon_button_requested)
		if not session.current_battle_waves.is_empty() and wave_manager.has_method("start_event_battle"):
			wave_manager.start_event_battle(session.current_battle_waves)
			Global.debug_log("WaveManager 启动事件战斗，波次：%d" % session.current_battle_waves.size())
		else:
			var stage_id: String = session.current_stage
			if stage_id == "":
				var age_sys: Node = get_node_or_null("/root/AgeSystem")
				if age_sys and age_sys.has_method("get_stage_id"):
					stage_id = age_sys.get_stage_id()
			var stage_config: Dictionary = _get_stage_config(stage_id)
			wave_manager.start_battle(stage_config)
			Global.debug_log("WaveManager 启动战斗，阶段：%s" % stage_id)
	else:
		Global.debug_log("WaveManager 不可用，战斗无法启动")

func _get_stage_config(stage_id: String) -> Dictionary:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return {}
	var stages_data: Dictionary = cm.load_json("res://data/stages.json")
	if not stages_data.has("stages"):
		return {}
	var stages: Dictionary = stages_data.stages
	if stages.has(stage_id):
		return stages[stage_id]
	return {}

func _on_wave_started(wave_number: int, total_waves: int) -> void:
	Global.debug_log("波次 %d/%d 开始" % [wave_number, total_waves])
	if game_hud:
		game_hud.update_wave(wave_number, total_waves)
	_show_wave_announcement(tr("WAVE_ANNOUNCEMENT") % [wave_number, total_waves])

func _on_enemy_spawn_requested(enemy_id: String) -> void:
	var enemy_cfg: EnemyConfig = EnemyConfig.get_config(enemy_id)
	if not enemy_cfg:
		return
	var enemy: Enemy = Enemy.new()
	enemy.initialize(enemy_cfg)
	var world_waypoints: Array[Vector2] = []
	var wps: Array[Vector2i] = map_config.waypoints if map_config.waypoints.size() >= 2 else map_config.path_points
	for point: Vector2i in wps:
		world_waypoints.append(Vector2(point * map_config.tile_size) + Vector2(map_config.tile_size / 2.0, map_config.tile_size / 2.0))
	enemy.spawn_offset = Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
	enemy.set_waypoints(world_waypoints)
	enemy.reached_base.connect(_on_enemy_reached_base)
	enemy.died.connect(_on_enemy_killed)
	add_child(enemy)
	if enemy.path_points.size() > 1:
		enemy.global_position = enemy.path_points[0]
		enemy.current_path_index = 1

func _on_wave_completed(wave_number: int) -> void:
	Global.debug_log("波次 %d 完成" % wave_number)
	var es: Node = get_node_or_null("/root/EconomySystem")
	if es and es.has_method("apply_interest"):
		var interest: int = es.apply_interest()
		if interest > 0 and game_hud:
			game_hud.add_gold(interest)

func _on_all_waves_completed() -> void:
	_all_enemies_spawned = true
	Global.debug_log("所有波次完成，等待敌人消灭")

func _on_boss_wave_started(boss_id: String) -> void:
	Global.debug_log("BOSS 波次：%s" % boss_id)

var _victory_scheduled: bool = false

func _check_battle_end() -> void:
	if not _battle_active:
		return
	if game_hud and game_hud.base_hp <= 0:
		var session: GameSessionData = Global.get_game_session()
		if session.current_battle_deadly:
			_end_battle(false)
		else:
			_end_battle(true, true)
	elif _all_enemies_spawned and get_tree().get_nodes_in_group("enemies").size() <= 0 and not _victory_scheduled:
		_victory_scheduled = true
		var cm: Node = get_node_or_null("/root/ConfigManager")
		var delay: float = 2.0
		if cm and cm.has_method("load_json"):
			var gc = cm.load_json("res://data/game_config.json")
			if gc is Dictionary and gc.has("victory_delay_seconds"):
				delay = float(gc.victory_delay_seconds)
		await get_tree().create_timer(delay).timeout
		if _battle_active:
			_end_battle(true)

func _end_battle(victory: bool, base_fallen: bool = false) -> void:
	_battle_active = false
	_reset_battle_speed()
	var session: GameSessionData = Global.get_game_session()
	session.current_battle_victory = victory
	if game_hud:
		session.home_health = float(game_hud.base_hp)
		session.gold = game_hud.gold
	var rating: String = "D"
	if victory and not base_fallen:
		var br: Node = get_node_or_null("/root/BattleRating")
		if br and br.has_method("determine_rating"):
			var health_percent: float = 1.0
			var start_hp: float = session.battle_start_health
			if start_hp < 0.0:
				start_hp = session.home_health
			if start_hp > 0.0:
				var battle_damage: float = start_hp - session.home_health
				health_percent = (start_hp - battle_damage) / start_hp
				if battle_damage <= 0.0:
					health_percent = 1.0
			rating = br.determine_rating(health_percent)
	elif base_fallen:
		rating = "D"
		session.home_health = session.max_home_health * 0.3
	session.battle_rating = rating
	var rewards: Dictionary = {"gold": 0, "tower_id": "", "rating": rating}
	var es: Node = get_node_or_null("/root/EconomySystem")
	if es and es.has_method("apply_battle_rewards"):
		rewards = es.apply_battle_rewards(rating)
	session.last_battle_rewards = rewards
	if wave_manager and wave_manager.has_method("stop_battle"):
		wave_manager.stop_battle()
	var result_text: String = tr("BATTLE_VICTORY") if victory else tr("BATTLE_DEFEAT")
	Global.debug_log("战斗结束：%s，评级：%s" % [result_text, rating])
	var es_node: Node = get_node_or_null("/root/EventSystem")
	if es_node and es_node.has_method("_check_stage_transition"):
		es_node._check_stage_transition()
	_show_battle_result(rating, victory)

func _show_battle_result(_rating: String, _victory: bool) -> void:
	GameState.change_state(GameState.State.RESULT)

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
	ground_layer.set_cells_terrain_connect(grass_cells, TERRAIN_SET, TERRAIN_GRASS, false)
	ground_layer.set_cells_terrain_connect(road_cells, TERRAIN_SET, TERRAIN_ROAD, false)
	ground_layer.set_cells_terrain_connect(edge_cells, TERRAIN_SET, TERRAIN_EDGE, false)

func _is_edge_cell(x: int, y: int) -> bool:
	return x == 0 or x == map_config.map_width - 1 or y == 0 or y == map_config.map_height - 1

func _apply_grid_shader() -> void:
	var shader_mat: ShaderMaterial = ShaderMaterial.new()
	var shader: Shader = AssetsManager.load_resource("res://shaders/grid_overlay.gdshader") as Shader
	if shader:
		shader_mat.shader = shader
		ground_layer.material = shader_mat
		shader_mat.set_shader_parameter("tile_size", Vector2(map_config.tile_size, map_config.tile_size))
		shader_mat.set_shader_parameter("grid_color", Color(1.0, 1.0, 1.0, 0.5))
		shader_mat.set_shader_parameter("grid_width", 2.0)

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
	var center: Vector2 = Vector2(MARKER_SIZE / 2.0, MARKER_SIZE / 2.0)
	for y in range(MARKER_SIZE):
		for x in range(MARKER_SIZE):
			if Vector2(x, y).distance_to(center) < MARKER_RADIUS:
				image.set_pixel(x, y, color)

func _draw_letter_S(image: Image, color: Color) -> void:
	var center: Vector2 = Vector2(MARKER_SIZE / 2.0, MARKER_SIZE / 2.0)
	var half: int = int(LETTER_SIZE / 2.0)
	var bar_height: int = int(LETTER_SIZE * 0.25)
	_draw_horizontal_bar(image, int(center.y) - half, int(center.y) - half + bar_height, center.x - half * 0.8, center.x + half * 0.8, color)
	var bar_width: float = LETTER_SIZE * 0.12
	_draw_vertical_bar(image, int(center.y) - half, int(center.y) + half, center.x - bar_width, center.x + bar_width, color)
	var bottom_offset: float = half * 0.75
	_draw_horizontal_bar(image, int(center.y) + int(bottom_offset), int(center.y) + half, center.x - half * 0.8, center.x + half * 0.8, color)

func _draw_letter_H(image: Image, color: Color) -> void:
	var center: Vector2 = Vector2(MARKER_SIZE / 2.0, MARKER_SIZE / 2.0)
	var half: int = int(LETTER_SIZE / 2.0)
	_draw_vertical_bar(image, int(center.y) - half, int(center.y) + half, center.x - half * 0.8, center.x - half * 0.3, color)
	_draw_vertical_bar(image, int(center.y) - half, int(center.y) + half, center.x + half * 0.3, center.x + half * 0.8, color)
	_draw_horizontal_bar(image, int(center.y - LETTER_SIZE * 0.1), int(center.y + LETTER_SIZE * 0.1), center.x - half * 0.8, center.x + half * 0.8, color)

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

func _create_tower_slots() -> void:
	for i in range(tower_positions.size()):
		var button: Button = _create_tower_slot_button(i)
		_connect_tower_slot_signal(button, i)
		add_child(button)
		tower_slot_rects.append(button)

func _create_tower_slot_button(index: int) -> Button:
	var pos: Vector2i = tower_positions[index]
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(100, 100)
	button.position = Vector2(pos * map_config.tile_size)
	button.text = tr("TOWER_SLOT")
	button.tooltip_text = tr("TOWER_SLOT_TOOLTIP")
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

func build_tower(slot_index: int, tower_type: String) -> void:
	var tower_config: TowerBean = TowerConfig.get_config(tower_type)
	if not tower_config:
		return
	var session: GameSessionData = Global.get_game_session()
	if not _can_place_tower(tower_type, session):
		_show_tower_limit_warning(tower_type)
		return
	var actual_cost: int = _get_modified_cost(tower_config.cost)
	if not game_hud.can_afford(actual_cost):
		return
	var tower: Tower = Tower.new()
	tower.position = _get_tile_center_position(tower_positions[slot_index])
	tower.z_index = 10
	tower.set_meta("slot_index", slot_index)
	add_child(tower)
	tower.initialize(tower_config)
	if tower_select_ui:
		tower.mouse_hover_started.connect(tower_select_ui._on_tower_mouse_hover_started)
		tower.mouse_hover_ended.connect(tower_select_ui._on_tower_mouse_hover_ended)
	if tower_sell_ui:
		tower.mouse_clicked.connect(_on_tower_mouse_clicked)
	if hovered_tower == tower:
		var stats_update_callable: Callable = _on_tower_stats_updated.bind(tower)
		_tower_stats_update_callables[tower] = stats_update_callable
		tower.stats_updated.connect(stats_update_callable)
	built_towers[slot_index] = tower
	_hide_tower_slot(slot_index)
	game_hud.spend_gold(actual_cost)

func _can_place_tower(tower_type: String, session: GameSessionData) -> bool:
	if not session.towers.has(tower_type):
		return false
	var max_count: int = session.towers[tower_type]
	if max_count < 0:
		return true
	var placed: int = 0
	for t: Node in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(t) or not t.has_meta("tower_id"):
			continue
		if str(t.get_meta("tower_id")) == tower_type:
			placed += 1
	return placed < max_count

func _show_tower_limit_warning(tower_type: String) -> void:
	var config: TowerBean = TowerConfig.get_config(tower_type)
	var tname: String = config.get_display_name() if config else tower_type
	Global.debug_log("[建塔] %s 已达摆放上限" % tname)
	var viewport: Viewport = get_viewport()
	if not viewport:
		return
	var screen_size: Vector2 = viewport.get_visible_rect().size
	var border: ColorRect = ColorRect.new()
	border.color = Color(1.0, 0.0, 0.0, 0.0)
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.z_index = 100
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	canvas_layer.add_child(border)
	var tween: Tween = create_tween()
	tween.tween_property(border, "color", Color(1.0, 0.0, 0.0, 0.35), 0.08)
	tween.tween_property(border, "color", Color(1.0, 0.0, 0.0, 0.0), 0.3)
	tween.tween_callback(canvas_layer.queue_free)
	var shake_tween: Tween = create_tween()
	var orig_pos: Vector2 = position
	for i in range(4):
		var offset: Vector2 = Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
		shake_tween.tween_property(self, "position", orig_pos + offset, 0.03)
	shake_tween.tween_property(self, "position", orig_pos, 0.03)

func _get_modified_cost(base_cost: int) -> int:
	var era_sys: Node = get_node_or_null("/root/EraSystem")
	if era_sys and era_sys.has_method("get_modified_tower_cost"):
		return era_sys.get_modified_tower_cost(base_cost)
	return base_cost

func _hide_tower_slot(slot_index: int) -> void:
	if slot_index < tower_slot_rects.size():
		tower_slot_rects[slot_index].visible = false

func _show_tower_slot(slot_index: int) -> void:
	if slot_index < tower_slot_rects.size():
		tower_slot_rects[slot_index].visible = true

func _create_tower_select_ui() -> void:
	tower_select_ui = TowerSelectUI.new()
	tower_select_ui.visible = false
	tower_select_ui.z_index = 100
	add_child(tower_select_ui)
	tower_select_ui.tower_selected.connect(_on_tower_selected)
	tower_select_ui.cancel_pressed.connect(_on_tower_select_cancel)
	_create_tower_sell_ui()

func _on_tower_selected(tower_type: String) -> void:
	if current_tower_slot_index < 0:
		return
	var tower_config: TowerBean = TowerConfig.get_config(tower_type)
	if not tower_config:
		return
	var actual_cost: int = _get_modified_cost(tower_config.cost)
	if not game_hud.can_afford(actual_cost):
		_show_insufficient_gold_warning(tower_type)
	else:
		_complete_tower_building(tower_type)

func _show_insufficient_gold_warning(tower_type: String) -> void:
	tower_select_ui.show_not_enough_gold(tower_type)
	tower_select_ui.is_locked = false
	if camera and camera.has_method("shake"):
		camera.shake(5.0, 0.3)

func _complete_tower_building(tower_type: String) -> void:
	build_tower(current_tower_slot_index, tower_type)
	current_tower_slot_index = -1
	tower_select_ui.is_panel_visible = false

func _on_tower_select_cancel() -> void:
	current_tower_slot_index = -1

func _create_tower_sell_ui() -> void:
	tower_sell_ui = TowerSellUI.new()
	tower_sell_ui.visible = false
	add_child(tower_sell_ui)
	tower_sell_ui.tower_sold.connect(_on_tower_sold)
	tower_sell_ui.sell_cancelled.connect(_on_tower_sell_cancelled)

func _on_tower_sold(tower: Tower) -> void:
	if not tower or not tower.config:
		return
	if _tower_stats_update_callables.has(tower):
		tower.stats_updated.disconnect(_tower_stats_update_callables[tower])
		_tower_stats_update_callables.erase(tower)
	if damage_tracker:
		damage_tracker.mark_tower_sold(tower)
	var base_cost: int = tower.config.cost
	var level_bonus: float = 1.0 + float(tower.current_level - 1) * 0.1
	var sell_price: int = int(float(base_cost) * tower.config.sell_ratio * level_bonus)
	if game_hud and game_hud.has_method("add_gold"):
		game_hud.add_gold(sell_price)
	var session: GameSessionData = Global.get_game_session()
	var tower_type: String = tower.config.tower_id
	for slot_index in built_towers.keys():
		if built_towers[slot_index] == tower:
			built_towers.erase(slot_index)
			_show_tower_slot(slot_index)
			break
	tower.queue_free()

func _on_tower_sell_cancelled() -> void:
	pass

func _on_tower_mouse_clicked(tower: Tower) -> void:
	_clear_selection()
	_selected_tower = tower
	tower.set_selected(true)
	if target_info_panel:
		target_info_panel.show_tower_info(tower)

func _on_tower_stats_updated(tower: Tower) -> void:
	if hovered_tower == tower and tower_info_panel and tower_info_panel.visible:
		_show_tower_info(tower)

func _handle_left_click() -> void:
	if tower_select_ui and tower_select_ui.visible:
		var local_pos: Vector2 = tower_select_ui.get_local_mouse_position()
		var panel_rect: Rect2 = Rect2(tower_select_ui.panel.position, tower_select_ui.panel.size)
		if not panel_rect.has_point(local_pos):
			tower_select_ui.close_panel()
			current_tower_slot_index = -1
		return
	var clicked_enemy: Enemy = _find_enemy_at_position(get_global_mouse_position())
	if clicked_enemy:
		_clear_selection()
		_selected_enemy = clicked_enemy
		clicked_enemy.set_selected(true)
		if target_info_panel:
			target_info_panel.show_enemy_info(clicked_enemy)
		return
	if target_info_panel and target_info_panel.visible:
		var panel_rect: Rect2 = Rect2(target_info_panel.global_position, target_info_panel.size)
		if not panel_rect.has_point(get_global_mouse_position()):
			_clear_selection()
			target_info_panel.hide_panel()

func _initialize_camera() -> void:
	if camera and camera.has_method("initialize"):
		camera.initialize(map_config)

func _create_game_hud() -> void:
	game_hud = GameHUD.new()
	add_child(game_hud)

func _create_damage_stats() -> void:
	var tracker_script: GDScript = load("res://scripts/logic/battle/damage_tracker.gd")
	damage_tracker = Node.new()
	damage_tracker.name = "DamageTracker"
	damage_tracker.set_script(tracker_script)
	add_child(damage_tracker)
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 35
	add_child(canvas)
	var panel_script: GDScript = load("res://scripts/ui/damage_stats_panel.gd")
	damage_stats_panel = Control.new()
	damage_stats_panel.name = "DamageStatsPanel"
	damage_stats_panel.set_script(panel_script)
	canvas.add_child(damage_stats_panel)
	damage_stats_panel.setup(damage_tracker)

func _create_target_info_panel() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 30
	add_child(canvas)
	target_info_panel = TargetInfoPanel.new()
	canvas.add_child(target_info_panel)
	target_info_panel.sell_tower_requested.connect(_on_tower_sold)

func _find_enemy_at_position(mouse_pos: Vector2) -> Enemy:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var closest: Enemy = null
	var closest_dist: float = 40.0
	for enemy_node: Node in enemies:
		if not is_instance_valid(enemy_node) or not enemy_node is Enemy:
			continue
		var enemy: Enemy = enemy_node as Enemy
		var dist: float = mouse_pos.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = enemy
	return closest

func _clear_selection() -> void:
	if _selected_tower and is_instance_valid(_selected_tower):
		_selected_tower.set_selected(false)
	_selected_tower = null
	if _selected_enemy and is_instance_valid(_selected_enemy):
		_selected_enemy.set_selected(false)
	_selected_enemy = null

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
	if hovered_tower and not is_instance_valid(hovered_tower):
		hovered_tower = null
		_hide_tower_hover_ui()
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

func remove_built_tower(tower: Tower) -> void:
	for slot_index in built_towers.keys():
		if built_towers[slot_index] == tower:
			built_towers.erase(slot_index)
			break
	if hovered_tower == tower:
		hovered_tower = null
		_hide_tower_hover_ui()

func _start_soft_pause() -> void:
	_soft_paused = true
	Global.soft_paused = true
	if not _pause_canvas:
		_pause_canvas = CanvasLayer.new()
		_pause_canvas.layer = 200
		add_child(_pause_canvas)
		_pause_label = Label.new()
		_pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_pause_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		_pause_label.add_theme_font_size_override("font_size", 64)
		_pause_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
		_pause_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		_pause_label.add_theme_constant_override("shadow_offset_x", 3)
		_pause_label.add_theme_constant_override("shadow_offset_y", 3)
		_pause_canvas.add_child(_pause_label)
	_pause_label.text = tr("PAUSED")
	_pause_label.visible = true
	Global.debug_log("[软暂停] 游戏已暂停")

func _resume_soft_pause() -> void:
	_soft_paused = false
	Global.soft_paused = false
	if _pause_label:
		_pause_label.visible = false
	Global.debug_log("[软暂停] 游戏已恢复")

func build_ruins_at_slot(slot_index: int) -> void:
	var tower_config: TowerBean = TowerConfig.get_config("tower_ruins")
	if not tower_config:
		Global.debug_log("[废墟] tower_ruins 配置不存在！")
		return
	var tower: Tower = Tower.new()
	tower.position = _get_tile_center_position(tower_positions[slot_index])
	tower.z_index = 10
	tower.set_meta("slot_index", slot_index)
	add_child(tower)
	tower.initialize(tower_config)
	Global.debug_log("[废墟] 在 slot %d 创建废墟塔，纹理路径=%s" % [slot_index, tower_config.texture_path])
	if tower_select_ui:
		tower.mouse_hover_started.connect(tower_select_ui._on_tower_mouse_hover_started)
		tower.mouse_hover_ended.connect(tower_select_ui._on_tower_mouse_hover_ended)
	if tower_sell_ui:
		tower.mouse_clicked.connect(_on_tower_mouse_clicked)
	built_towers[slot_index] = tower

func _find_tower_at_position(mouse_pos: Vector2) -> Tower:
	var tile_size_half: float = map_config.tile_size / 2.0
	var tile_size_full: float = map_config.tile_size
	var invalid_slots: Array = []
	for slot_index in built_towers.keys():
		var tower_ref = built_towers.get(slot_index)
		if tower_ref == null or not is_instance_valid(tower_ref):
			invalid_slots.append(slot_index)
			continue
		var tower: Tower = tower_ref as Tower
		if tower == null:
			invalid_slots.append(slot_index)
			continue
		var tower_rect: Rect2 = Rect2(tower.position - Vector2(tile_size_half, tile_size_half), Vector2(tile_size_full, tile_size_full))
		if tower_rect.has_point(mouse_pos):
			return tower
	for slot in invalid_slots:
		built_towers.erase(slot)
	return null

func _show_tower_hover_ui(tower: Tower) -> void:
	if not tower or not tower.config:
		return
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
	var circle_area: ColorRect = ColorRect.new()
	circle_area.color = Color(1, 0.3, 0.3, 0.15)
	circle_area.size = Vector2(attack_range * 2, attack_range * 2)
	circle_area.position = Vector2(-attack_range, -attack_range)
	circle_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	var shader: Shader = AssetsManager.load_resource("res://shaders/circle_mask.gdshader") as Shader
	if shader:
		shader_material.shader = shader
		circle_area.material = shader_material
	range_circle.add_child(circle_area)
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
	var cfg: TowerBean = tower.config
	var base_damage: float = cfg.damage
	var base_attack_speed: float = cfg.attack_speed
	var base_range: float = cfg.attack_range
	var ts: Node = get_node_or_null("/root/TraitSystem")
	var damage_bonus: float = 0.0
	var attack_speed_bonus: float = 0.0
	if ts and ts.has_method("get_trait_effects_for_tower"):
		damage_bonus = ts.get_trait_effects_for_tower(cfg.tower_id)
	if ts and ts.has_method("get_attack_speed_bonus_for_tower"):
		attack_speed_bonus = ts.get_attack_speed_bonus_for_tower(cfg.tower_id)
	var final_damage: float = base_damage * (1.0 + damage_bonus)
	var final_attack_speed: float = base_attack_speed * (1.0 + attack_speed_bonus)
	var info: String = "%s (Lv.%d)\n" % [cfg.tower_name, tower.current_level]
	info += "━━━━━━━━━━━━━━━\n"
	info += tr("TOWER_INFO_DAMAGE") % final_damage
	if damage_bonus > 0.0:
		info += " (+%.0f%%)" % (damage_bonus * 100.0)
	info += "\n"
	info += tr("TOWER_INFO_RANGE") % base_range + "\n"
	info += tr("TOWER_INFO_SPEED") % final_attack_speed
	if attack_speed_bonus > 0.0:
		info += " (+%.0f%%)" % (attack_speed_bonus * 100.0)
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

func _on_enemy_reached_base(_enemy: Node2D) -> void:
	if game_hud and game_hud.base_hp > 0:
		var base_damage: float = 1.0
		if _enemy is Enemy and _enemy.config:
			base_damage = float(_enemy.config.damage)
		var ts: Node = get_node_or_null("/root/TraitSystem")
		if ts and ts.has_method("get_damage_reduction"):
			base_damage = base_damage * (1.0 - ts.get_damage_reduction())
		var actual_damage: int = maxi(int(ceilf(base_damage)), 1)
		game_hud.update_hp(game_hud.base_hp - actual_damage)
	if wave_manager and wave_manager.has_method("_on_enemy_reached_base"):
		wave_manager._on_enemy_reached_base(_enemy as Enemy)

func _on_enemy_killed(enemy: Node2D) -> void:
	var base_reward: int = 0
	if enemy is Enemy:
		var enemy_unit: Enemy = enemy as Enemy
		if enemy_unit.config and enemy_unit.config.gold_drop > 0:
			base_reward = enemy_unit.config.gold_drop
	if base_reward <= 0:
		base_reward = 5
	var gold_bonus: float = 0.0
	var es: Node = get_node_or_null("/root/EraSystem")
	if es and es.has_method("get_family_modifier"):
		gold_bonus = es.get_family_modifier("gold_bonus")
	var final_reward: int = int(float(base_reward) * (1.0 + gold_bonus))
	_kill_gold_earned += final_reward
	if game_hud:
		game_hud.add_gold(final_reward)
	if gold_bonus > 0.0:
		Global.debug_log("[金币分配] 击杀奖励 %d×(1+%.0f%%)=%d" % [base_reward, gold_bonus * 100.0, final_reward])
	if wave_manager and wave_manager.has_method("_on_enemy_died"):
		wave_manager._on_enemy_died(enemy as Enemy)

func _create_battle_hud() -> void:
	_summon_canvas = CanvasLayer.new()
	_summon_canvas.layer = 25
	add_child(_summon_canvas)
	_summon_button = Button.new()
	_summon_button.text = tr("BTN_SUMMON")
	_summon_button.custom_minimum_size = Vector2(140, 50)
	_summon_button.add_theme_font_size_override("font_size", 18)
	_summon_button.visible = false
	_summon_button.position = Vector2(20, 200)
	_summon_button.pressed.connect(_on_summon_pressed)
	_summon_canvas.add_child(_summon_button)
	_summon_progress = ProgressBar.new()
	_summon_progress.custom_minimum_size = Vector2(140, 12)
	_summon_progress.position = Vector2(20, 255)
	_summon_progress.max_value = 100.0
	_summon_progress.value = 100.0
	_summon_progress.visible = false
	_summon_canvas.add_child(_summon_progress)
	_battle_timer_label = Label.new()
	_battle_timer_label.add_theme_font_size_override("font_size", 20)
	_battle_timer_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	_battle_timer_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_battle_timer_label.add_theme_constant_override("shadow_offset_x", 2)
	_battle_timer_label.add_theme_constant_override("shadow_offset_y", 2)
	_battle_timer_label.position = Vector2(20, 160)
	_battle_timer_label.text = "00:00"
	_summon_canvas.add_child(_battle_timer_label)

	var speed_container: HBoxContainer = HBoxContainer.new()
	speed_container.position = Vector2(20, 270)
	speed_container.add_theme_constant_override("separation", 4)
	var speeds: Array[float] = [1.0, 2.0, 4.0]
	var speed_labels: Array[String] = ["1x", "2x", "4x"]
	for idx: int in range(speeds.size()):
		var btn: Button = Button.new()
		btn.text = speed_labels[idx]
		btn.custom_minimum_size = Vector2(44, 32)
		btn.add_theme_font_size_override("font_size", 14)
		btn.toggle_mode = true
		if idx == 0:
			btn.button_pressed = true
		btn.pressed.connect(_on_speed_button_pressed.bind(idx))
		speed_container.add_child(btn)
		_speed_buttons.append(btn)
	_summon_canvas.add_child(speed_container)

func _on_summon_button_requested(show: bool, countdown: float, is_first_wave: bool) -> void:
	if _summon_button:
		_summon_button.visible = show
	if _summon_progress:
		_summon_progress.visible = show and not is_first_wave
		if show and not is_first_wave:
			_summon_progress.max_value = countdown
			_summon_progress.value = countdown

func _update_summon_button(delta: float) -> void:
	if not _summon_progress:
		return
	if wave_manager and "_summon_countdown" in wave_manager:
		_summon_progress.value = wave_manager._summon_countdown

func _update_battle_timer() -> void:
	if not _battle_timer_label:
		return
	var minutes: int = int(game_time) / 60
	var seconds: int = int(game_time) % 60
	_battle_timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_summon_pressed() -> void:
	if wave_manager and wave_manager.has_method("force_start_next_wave"):
		wave_manager.force_start_next_wave()

func _on_speed_button_pressed(idx: int) -> void:
	var speeds: Array[float] = [1.0, 2.0, 4.0]
	if idx < 0 or idx >= speeds.size():
		return
	_battle_speed = speeds[idx]
	Engine.time_scale = _battle_speed
	for i: int in range(_speed_buttons.size()):
		_speed_buttons[i].button_pressed = (i == idx)
	Global.debug_log("[速度] 战斗速度设为 %.0fx" % _battle_speed)

func _reset_battle_speed() -> void:
	_battle_speed = 1.0
	Engine.time_scale = 1.0
	for i: int in range(_speed_buttons.size()):
		if _speed_buttons[i]:
			_speed_buttons[i].button_pressed = (i == 0)

func _show_wave_announcement(text: String) -> void:
	if not _wave_announcement:
		var canvas: CanvasLayer = CanvasLayer.new()
		canvas.layer = 50
		add_child(canvas)
		_wave_announcement = Label.new()
		_wave_announcement.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_wave_announcement.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_wave_announcement.add_theme_font_size_override("font_size", 36)
		_wave_announcement.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		_wave_announcement.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		_wave_announcement.add_theme_constant_override("shadow_offset_x", 3)
		_wave_announcement.add_theme_constant_override("shadow_offset_y", 3)
		_wave_announcement.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		_wave_announcement.offset_top = -120
		canvas.add_child(_wave_announcement)
	_wave_announcement.text = text
	_wave_announcement.modulate = Color(1, 1, 1, 1)
	_wave_announcement.visible = true
	_wave_announcement_timer = 2.5

func _update_wave_announcement(delta: float) -> void:
	if _wave_announcement_timer <= 0:
		return
	_wave_announcement_timer -= delta
	if _wave_announcement_timer <= 0.5 and _wave_announcement:
		_wave_announcement.modulate = Color(1, 1, 1, _wave_announcement_timer / 0.5)
	if _wave_announcement_timer <= 0 and _wave_announcement:
		_wave_announcement.visible = false
