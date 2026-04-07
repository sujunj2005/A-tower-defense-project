shader_type canvas_item;

// 网格边框自定义设置 
uniform vec4 grid_color: source_color = vec4(1.0, 1.0, 1.0, 0.5); // 边框颜色 + 透明度 
uniform float grid_width: hint_range(0.0, 10.0) = 2.0; // 边框线宽度（像素）
uniform vec2 tile_size = vec2(96.0, 96.0); // 必须和 TileMap 的 cell_size 完全一致

// 从顶点函数传递世界坐标到片段函数
varying vec2 v_world_pos;

void vertex() {
	// 传递顶点的世界坐标（考虑了节点的位置和缩放）
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// v_world_pos 是世界空间坐标（像素）
	// 计算在瓦片内的局部坐标
	vec2 tile_local = mod(v_world_pos, tile_size);
	
	// 检查是否在边框线上
	float dist_to_left = tile_local.x;
	float dist_to_right = tile_size.x - tile_local.x;
	float dist_to_top = tile_local.y;
	float dist_to_bottom = tile_size.y - tile_local.y;
	
	bool is_grid_line = (dist_to_left < grid_width) || 
					   (dist_to_right < grid_width) ||
					   (dist_to_top < grid_width) || 
					   (dist_to_bottom < grid_width);
	
	if (is_grid_line) {
		COLOR = grid_color;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
