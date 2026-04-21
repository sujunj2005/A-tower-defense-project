# 案例 5：Ray Tracing —— 蒙特卡洛路径追踪

> **适用版本**: Godot 4.6+  
> **来源**: `compositor-effect-library/compositor_effects/ray_tracing/`  
> **关键词**: Compute Shader、路径追踪、PCG随机数、蒙特卡洛、天空盒采样

---

## 一、效果说明

在 CompositorEffect 中实现完整的蒙特卡洛路径追踪渲染。不是传统的光栅化，而是在 GPU 上逐像素发射光线、与球体相交、计算反射弹跳、累积采样。这是整个库中技术含量最高的效果。

### 效果预览
- 画面中渲染多个可配置的球体
- 球体有反射、高光、颜色属性
- 支持最多 5 次光线反弹
- 128 次采样逐帧累积，画面从噪点逐渐收敛
- 可调节球体半径、位置、颜色、材质参数
- 背景使用天空盒全景图

---

## 二、GLSL Compute Shader 实现

### 2.1 Push Constant 定义

```glsl
layout(push_constant) uniform constants {
    vec4 inv_proj_mat[4];    // 逆投影矩阵
    vec4 raster_size;        // 屏幕尺寸
    float sphere_positions[64]; // 16个球体 × 4 (xyz + padding)
    float sphere_colors[80];    // 16个球体 × 5 (rgb + roughness + metallic)
    float sphere_radii[16];     // 16个球体半径
    uint samples;               // 当前采样数
} push_cont;
```

### 2.2 光线结构

```glsl
struct Ray {
    vec3 origin;
    vec3 direction;
    vec3 color;
};
```

### 2.3 伪随机数生成（PCG）

```glsl
uint wang_hash(inout uint seed) {
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}

float random_float(inout uint seed) {
    return float(wang_hash(seed)) / float(0xffffffffu);
}

vec3 random_in_unit_sphere(inout uint seed) {
    float phi = random_float(seed) * 2.0 * PI;
    float cos_theta = 2.0 * random_float(seed) - 1.0;
    float u = random_float(seed);
    float theta = sqrt(1.0 - u * u);
    return vec3(theta * cos(phi), theta * sin(phi), cos_theta);
}
```

### 2.4 光线-球体相交检测

```glsl
float ray_sphere_intersect(vec3 ro, vec3 rd, vec3 pos, float rad) {
    vec3 p = pos - ro;
    float c = dot(p, p) - rad * rad;
    if (c <= 0.0) return c;
    float b = dot(p, rd);
    if (b < 0.0) return -1.0;
    float disc = b * b - c;
    if (disc < 0.0) return -1.0;
    return sqrt(disc);
}
```

### 2.5 材质颜色计算

```glsl
vec3 sphere_color(float metallic, float roughness, vec3 normal, vec3 light_dir, vec3 view_dir, vec3 color) {
    float ks = metallic * (1.0 - roughness);
    vec3 kd = (1.0 - metallic) * color;

    float specular = pow(max(dot(reflect(-view_dir, normal), light_dir), 0.0), 16.0);
    float diffuse = max(dot(normal, light_dir), 0.0);

    return color * kd * diffuse + specular * ks;
}
```

### 2.6 主渲染逻辑（关键路径）

```glsl
#define BOUNCES 5

void main() {
    ivec2 screen_size = ivec2(raster_size.xy);
    ivec2 store_pos = ivec2(gl_GlobalInvocationID.xy);
    uint seed = uint(store_pos.x + store_pos.y * 1024);

    // 1. 从像素坐标生成光线
    vec3 ray_pos = vec3(0.0);
    vec3 ray_dir = vec3(vec2(store_pos) / screen_size * 2.0 - 1.0, 1.0);
    ray_dir = vec3(inv_proj_mat[0].x, inv_proj_mat[1].y, inv_proj_mat[2].z) * ray_dir;
    ray_dir = normalize(ray_dir);

    vec3 final_color = vec3(0.0);

    // 2. 多次反弹追踪
    for (int bounce = 0; bounce < BOUNCES; bounce++) {
        float closest_dist = -1.0;
        int closest_sphere = -1;

        // 3. 遍历所有球体找最近交点
        for (int i = 0; i < 16; i++) {
            float d = ray_sphere_intersect(ray_pos, ray_dir,
                vec3(push_cont.sphere_positions[i * 4],
                     push_cont.sphere_positions[i * 4 + 1],
                     push_cont.sphere_positions[i * 4 + 2]),
                push_cont.sphere_radii[i]);
            if ((d > 0.0 && d < closest_dist) || closest_dist == -1.0) {
                closest_dist = d;
                closest_sphere = i;
            }
        }

        // 4. 命中球体：计算颜色、反射
        if (closest_dist >= 0.0) {
            vec3 hit_pos = ray_pos + ray_dir * closest_dist;
            vec3 normal = normalize(hit_pos - vec3(
                push_cont.sphere_positions[closest_sphere * 4],
                push_cont.sphere_positions[closest_sphere * 4 + 1],
                push_cont.sphere_positions[closest_sphere * 4 + 2]));

            vec3 light_dir = normalize(vec3(1.0) - hit_pos);
            vec3 color = sphere_color(
                push_cont.sphere_colors[closest_sphere * 5 + 4],  // metallic
                push_cont.sphere_colors[closest_sphere * 5 + 3],  // roughness
                normal, light_dir, -ray_dir,
                vec3(push_cont.sphere_colors[closest_sphere * 5],
                     push_cont.sphere_colors[closest_sphere * 5 + 1],
                     push_cont.sphere_colors[closest_sphere * 5 + 2]));

            final_color += ray.color * color;
            ray.color *= color;
            ray_pos = hit_pos;
            ray_dir = reflect(ray_dir, normal);
        } else {
            // 5. 未命中：采样天空盒
            final_color += ray.color * texture(sky_sampler, ray_dir).rgb;
            break;
        }
    }

    // 6. 累积采样（蒙特卡洛）
    if (push_cont.samples > 0) {
        vec3 old_color = imageLoad(color_layer, store_pos).rgb;
        final_color = mix(old_color, final_color, 1.0 / float(push_cont.samples));
    }
    imageStore(color_layer, store_pos, vec4(final_color, 1.0));
}
```

---

## 三、技术要点

### 3.1 蒙特卡洛积分

每帧发射一条光线，采样数递增。第 N 帧的累积公式：

```
color_N = mix(color_{N-1}, current_sample, 1.0/N)
```

N 越大，画面越平滑。128 次采样后画面基本收敛。

### 3.2 PCG 随机数

使用 Wang Hash 作为伪随机数生成器，以屏幕坐标为种子。好处：
- 同一像素始终生成相同的随机序列（确定性）
- 相邻像素的随机数不相关
- 无状态存储开销

### 3.3 Push Constant 数据结构

```glsl
// 球体位置：vec4 对齐
float sphere_positions[64]; // 16 球 × 4 = 64

// 球体颜色+材质：vec4 + vec1
float sphere_colors[80]; // 16 球 × 5 = 80

// 半径
float sphere_radii[16];  // 16 球
```

GDScript 侧通过 `ByteArrayHelper.array_to_bytes()` 构建对应数据结构。

### 3.4 天空盒全景采样

```gdscript
var sky_panorama := RenderingServer.environment_bake_panorama(
    render_data.get_environment(), false, 1.0, 1024, 512)
var sky_panorama_texture := ComputeHelper.rd.texture_create_from_image(sky_panorama)
```

从当前 Environment 烘焙天空盒全景图，转为纹理供 compute shader 采样。

### 3.5 编辑器热重载

```gdscript
@export_tool_button("Reload Shader", "Reload") var reload_button := reload_shader

func reload_shader() -> void:
    var shader_file: RDShaderFile = load("res://compositor_effects/ray_tracing/ray_tracing.glsl")
    var shader_spirv := shader_file.get_spirv()
    rd.free_rid(pipeline)
    rd.free_rid(shader)
    shader = rd.shader_create_from_spirv(shader_spirv)
    pipeline = rd.compute_pipeline_create(shader)
```

在编辑器中一键重新编译 shader，无需重启场景。

---

## 四、GDScript 侧完整实现

```gdscript
@tool
extends CompositorEffect
class_name RayTracingEffect

const ComputeHelper := preload("res://addons/compute_shader_plus/compute_helper.gd")
const ImageUniform := preload("res://addons/compute_shader_plus/uniforms/image_uniform.gd")
const SamplerUniform := preload("res://addons/compute_shader_plus/uniforms/sampler_uniform.gd")
const ByteArrayHelper := preload("res://addons/compute_shader_plus/byte_array_helper.gd")

@export_range(1, 1024, 1, "or_greater") var samples := 128
@export var sphere_radii: Array[float] = [1.0, 1.0]
@export var sphere_positions: Array[Vector3] = [Vector3(0.0, 2.0, -5.0), Vector3(2.0, 0.0, -5.0)]
@export var sphere_colors: Array[Color] = [Color.RED, Color.BLUE]
@export var sphere_roughness: Array[float] = [0.0, 1.0]
@export var sphere_metallic: Array[float] = [1.0, 0.0]

var rd := ComputeHelper.rd
var compute_shader: ComputeHelper
var color_image_uniform: ImageUniform
var depth_sampler: SamplerUniform
var sky_panorama_texture: RID
var sky_sampler: SamplerUniform
var version: int = Engine.get_version_info()["minor"]

func _init() -> void:
    compute_shader = ComputeHelper.create("res://compositor_effects/ray_tracing/ray_tracing.glsl")
    depth_sampler = SamplerUniform.new()
    sky_sampler = SamplerUniform.new()
    compute_shader.add_uniform_array([depth_sampler, sky_sampler])

func _render_callback(_callback_type: int, render_data: RenderData) -> void:
    var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    var size := render_scene_buffers.get_internal_size()

    var push_constants := create_push_constants(size, render_data.get_render_scene_data())
    var work_groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)
    compute_shader.run(work_groups, push_constants)

func create_push_constants(size: Vector2i, render_scene_data: RenderSceneData) -> PackedByteArray:
    var inv_proj_mat := render_scene_data.get_cam_projection().inverse()
    var inv_proj_mat_array := PackedVector4Array([inv_proj_mat.x, inv_proj_mat.y, inv_proj_mat.z, inv_proj_mat.w])
    var raster_size := PackedFloat32Array([size.x, size.y, 0.0, 0.0])

    var push_constants := inv_proj_mat_array.to_byte_array()
    push_constants.append_array(raster_size.to_byte_array())
    push_constants.append_array(ByteArrayHelper.array_to_bytes(sphere_positions))
    push_constants.append_array(ByteArrayHelper.array_to_bytes(sphere_colors))
    push_constants.append_array(ByteArrayHelper.array_to_bytes(sphere_radii))

    if version < 4:
        push_constants.append_array(PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0]))
        push_constants.append_array(PackedUInt32Array([samples]).to_byte_array())
    else:
        push_constants.append_array(PackedUInt32Array([0, samples]).to_byte_array())

    return push_constants

@export_tool_button("Reload Shader", "Reload") var reload_button := reload_shader
```

---

## 五、与本项目的关联

| 技术 | 可复用场景 |
|------|-----------|
| 路径追踪思想 | 离线渲染高质量过场动画、截图 |
| PCG 随机数 | 弹幕散射、粒子效果、随机事件 |
| 天空盒烘焙 | 动态天气系统中的天空变化 |
| 编辑器热重载 | 所有 shader 开发调试效率提升 |
| Push Constant 结构体 | 大量 GPU 数据传递场景（敌人位置数组等） |

来源：`compositor-effect-library/compositor_effects/ray_tracing/ray_tracing.gd` + `ray_tracing.glsl`
