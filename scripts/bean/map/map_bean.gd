class_name MapBean
extends Resource

@export var map_name: String = "Default Map"
@export var map_width: int = 50
@export var map_height: int = 50
@export var tile_size: int = 50
@export var spawn_point: Vector2i = Vector2i(3, 25)
@export var base_point: Vector2i = Vector2i(46, 25)
@export var path_points: Array[Vector2i] = []
@export var tower_positions: Array[Vector2i] = []
@export var max_towers: int = 10
@export var camera_speed: float = 800.0
@export var zoom_speed: float = 0.2
@export var drag_speed: float = 1.5
@export var drag_inertia: float = 0.9
@export var grass_texture_path: String = "res://images/Outside_A2.png"
@export var grass_texture_region: Rect2 = Rect2(0, 0, 32, 32)
@export var road_texture_path: String = "res://images/Outside_A2.png"
@export var road_texture_region: Rect2 = Rect2(288, 0, 32, 32)
@export var edge_texture_path: String = "res://images/Outside_A2.png"
@export var edge_texture_region: Rect2 = Rect2(32, 0, 32, 32)

static func from_dict(data: Dictionary) -> MapBean:
	var bean := MapBean.new()
	bean.map_name = data.get("map_name", "Default Map")
	bean.map_width = int(data.get("map_width", 50))
	bean.map_height = int(data.get("map_height", 50))
	bean.tile_size = int(data.get("tile_size", 50))
	return bean

func to_dict() -> Dictionary:
	return {
		"map_name": map_name,
		"map_width": map_width,
		"map_height": map_height,
		"tile_size": tile_size,
		"spawn_point": [spawn_point.x, spawn_point.y],
		"base_point": [base_point.x, base_point.y],
		"max_towers": max_towers
	}
