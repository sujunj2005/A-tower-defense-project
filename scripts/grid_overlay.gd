extends Node2D

var shader_material: ShaderMaterial
var map_config: MapConfig
var selected_tile_coord: Vector2i = Vector2i(-1, -1)
var mesh_instance: MeshInstance2D

func _ready():
	mesh_instance = MeshInstance2D.new()
	add_child(mesh_instance)
	
	var mesh = QuadMesh.new()
	mesh.size = Vector2(2880, 2880)
	mesh_instance.mesh = mesh
	
	material = ShaderMaterial.new()
	material.shader = AssetsManager.load_resource("res://shaders/grid_overlay.gdshader")
	shader_material = material
	mesh_instance.material = material
	
	z_index = 100

func initialize(config: MapConfig):
	map_config = config
	update_shader_params()

func update_shader_params():
	if not shader_material or not map_config:
		return
	
	var map_pixel_size = Vector2(map_config.map_width * map_config.tile_size, map_config.map_height * map_config.tile_size)
	
	if mesh_instance and mesh_instance.mesh:
		var mesh = mesh_instance.mesh as QuadMesh
		mesh.size = map_pixel_size
	
	shader_material.set_shader_parameter("map_size", Vector2(map_config.map_width, map_config.map_height))
	shader_material.set_shader_parameter("tile_size", float(map_config.tile_size))
	shader_material.set_shader_parameter("grid_color", Color(0.3, 0.3, 0.3, 0.8))
	shader_material.set_shader_parameter("grid_width", 2.0)
	shader_material.set_shader_parameter("highlight_color", Color(1.0, 1.0, 0.0, 0.8))
	shader_material.set_shader_parameter("highlight_width", 4.0)
	shader_material.set_shader_parameter("selected_tile", Vector2(selected_tile_coord))
	shader_material.set_shader_parameter("show_grid", true)

func set_selected_tile(coords: Vector2i):
	selected_tile_coord = coords
	if shader_material:
		shader_material.set_shader_parameter("selected_tile", Vector2(coords))

func clear_selection():
	selected_tile_coord = Vector2i(-1, -1)
	if shader_material:
		shader_material.set_shader_parameter("selected_tile", Vector2(-1, -1))

func set_grid_visible(visible: bool):
	if shader_material:
		shader_material.set_shader_parameter("show_grid", visible)
