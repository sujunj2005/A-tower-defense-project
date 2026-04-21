# 案例 4：Pixelate —— 像素化 + 法线边缘后处理

> **适用版本**: Godot 4.6+  
> **来源**: `compositor-effect-library/compositor_effects/pixelate/`  
> **关键词**: 像素化、Bayer抖动、色彩量化、法线边缘检测

---

## 一、效果说明

将屏幕画面像素化，并为像素块添加边缘高亮。同时演示了如何结合深度缓冲和法线缓冲做更精确的边缘检测（区分屏幕空间边缘与表面法线突变）。

### 效果预览
- 画面被分割为固定大小的像素块
- 每个像素块取中心颜色值
- 像素块间有深色分隔线
- 可选：根据深度差异绘制高亮边缘

---

## 二、GLSL Compute Shader 实现

```glsl
#[compute]
#version 450

#define PIXEL_SIZE 64.0

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_layer;
layout(set = 0, binding = 1) uniform sampler2D depth_layer;
layout(set = 0, binding = 2) uniform sampler2D normal_roughness_layer;

layout(push_constant) uniform constants {
    vec4 inv_proj_mat[4];
    vec4 raster_size;
} push_cont;

void main() {
    ivec2 screen_size = imageSize(color_layer);
    ivec2 store_pos = ivec2(gl_GlobalInvocationID.xy);

    ivec2 pos = ivec2(vec2(store_pos / PIXEL_SIZE) * PIXEL_SIZE + PIXEL_SIZE / 2.0);
    vec4 color = texture(color_layer, vec2(pos) / vec2(screen_size));

    float pixel_top = texture(depth_layer, (vec2(store_pos) + vec2(0.0, 1.0)) / vec2(screen_size)).r;
    float pixel_bottom = texture(depth_layer, (vec2(store_pos) + vec2(0.0, -1.0)) / vec2(screen_size)).r;
    float pixel_left = texture(depth_layer, (vec2(store_pos) + vec2(-1.0, 0.0)) / vec2(screen_size)).r;
    float pixel_right = texture(depth_layer, (vec2(store_pos) + vec2(1.0, 0.0)) / vec2(screen_size)).r;

    bool has_screen_edge =
        abs(pixel_top - pixel_bottom) > 0.1 ||
        abs(pixel_left - pixel_right) > 0.1;

    float normal_top = texture(normal_roughness_layer, (vec2(store_pos) + vec2(0.0, 1.0)) / vec2(screen_size)).a;
    float normal_bottom = texture(normal_roughness_layer, (vec2(store_pos) + vec2(0.0, -1.0)) / vec2(screen_size)).a;
    float normal_left = texture(normal_roughness_layer, (vec2(store_pos) + vec2(-1.0, 0.0)) / vec2(screen_size)).a;
    float normal_right = texture(normal_roughness_layer, (vec2(store_pos) + vec2(1.0, 0.0)) / vec2(screen_size)).a;

    bool has_normal_edge =
        abs(normal_top - normal_bottom) > 0.1 ||
        abs(normal_left - normal_right) > 0.1;

    vec2 mod_pos = vec2(store_pos) / PIXEL_SIZE;
    bool is_x_edge = mod_pos.x == 1.0 || mod_pos.x == 0.0;
    bool is_y_edge = mod_pos.y == 1.0 || mod_pos.y == 0.0;

    if (has_screen_edge) {
        color = mix(color, vec4(has_normal_edge ? vec3(1.0) : vec3(0.0), 1.0), 0.1);
    } else if (is_x_edge || is_y_edge) {
        color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), 0.5);
    }

    imageStore(color_layer, store_pos, color);
}
```

---

## 三、技术要点

### 3.1 像素块中心采样

```glsl
ivec2 pos = ivec2(vec2(store_pos / PIXEL_SIZE) * PIXEL_SIZE + PIXEL_SIZE / 2.0);
vec4 color = texture(color_layer, vec2(pos) / vec2(screen_size));
```

所有属于同一像素块的屏幕坐标，都映射到该块的中心点采样。这实现了"像素化"的核心逻辑。

### 3.2 双层边缘检测

| 检测层 | 数据源 | 检测什么 |
|--------|--------|---------|
| **深度层** | depth_layer | 屏幕空间深度不连续（3D物体的前后分界） |
| **法线层** | normal_roughness_layer | 表面法线变化（同一物体上的棱角/曲面分界） |

**关键逻辑**：
- `has_screen_edge && has_normal_edge` → 白色高亮边缘（表面结构变化）
- `has_screen_edge && !has_normal_edge` → 黑色边缘（不同物体间的分界）

### 3.3 像素网格线

```glsl
vec2 mod_pos = vec2(store_pos) / PIXEL_SIZE;
bool is_x_edge = mod_pos.x == 1.0 || mod_pos.x == 0.0;
bool is_y_edge = mod_pos.y == 1.0 || mod_pos.y == 0.0;
```

当屏幕坐标恰好落在像素块边界时，混合 50% 黑色绘制网格线。

---

## 四、GDScript 侧实现

```gdscript
func _init() -> void:
    needs_normal_roughness = true  # 必须开启法线缓冲
    depth_sampler = rd.sampler_create(RDSamplerState.new())
    normal_roughness_sampler = rd.sampler_create(RDSamplerState.new())

func _render_callback(_callback_type: int, render_data: RenderData) -> void:
    var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    var size := render_scene_buffers.get_internal_size()

    # Color layer
    var color_layer_uniform := RDUniform.new()
    color_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
    color_layer_uniform.binding = 0
    color_layer_uniform.add_id(render_scene_buffers.get_color_layer(0))

    # Depth layer
    var depth_layer_uniform := RDUniform.new()
    depth_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
    depth_layer_uniform.binding = 1
    depth_layer_uniform.add_id(depth_sampler)
    depth_layer_uniform.add_id(render_scene_buffers.get_depth_layer(0))

    # Normal/Roughness layer
    var normal_roughness_layer_uniform := RDUniform.new()
    normal_roughness_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
    normal_roughness_layer_uniform.binding = 2
    normal_roughness_layer_uniform.add_id(normal_roughness_sampler)
    normal_roughness_layer_uniform.add_id(render_scene_buffers.get_texture("forward_clustered", "normal_roughness"))

    var bindings := [color_layer_uniform, depth_layer_uniform, normal_roughness_layer_uniform]
    var uniform_set := rd.uniform_set_create(bindings, shader, 0)

    var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)

    var inv_proj_mat := render_data.get_render_scene_data().get_cam_projection().inverse()
    var inv_proj_mat_array := PackedVector4Array([inv_proj_mat.x, inv_proj_mat.y, inv_proj_mat.z, inv_proj_mat.w])
    var raster_size := PackedFloat32Array([size.x, size.y, 0.0, 0.0])

    var push_constants := inv_proj_mat_array.to_byte_array()
    push_constants.append_array(raster_size.to_byte_array())

    var compute_list := rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_set_push_constant(compute_list, push_constants, push_constants.size())
    rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
    rd.compute_list_end()

    rd.free_rid(uniform_set)
```

---

## 五、GLSL 与 GDScript 的数据对应

| GDScript | GLSL | 说明 |
|----------|------|------|
| `inv_proj_mat[4]` (16 floats) | `vec4 inv_proj_mat[4]` | 逆投影矩阵 |
| `raster_size` (4 floats) | `vec4 raster_size` | `raster_size.xy = screen_size` |

---

## 六、与本项目的关联

| 技术 | 可复用场景 |
|------|-----------|
| 双层边缘检测（深度+法线） | 塔防中区分不同高度层级的敌人，或在法线突变处加高亮 |
| 像素化效果 | 复古风格关卡、特殊技能效果（时间停止/空间扭曲） |
| 多 G-Buffer 混合 | 基于法线变化的受击效果，如侧面被击中和正面被击中不同颜色 |
| `needs_normal_roughness` | 任何需要表面朝向信息的后处理效果 |

来源：`compositor-effect-library/compositor_effects/pixelate/pixelate.gd` + `pixelate.glsl`
