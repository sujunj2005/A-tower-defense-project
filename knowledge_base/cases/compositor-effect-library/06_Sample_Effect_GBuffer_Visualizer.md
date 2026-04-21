# 案例 6：Sample Effect —— G-Buffer 可视化工具

> **适用版本**: Godot 4.6+  
> **来源**: `compositor-effect-library/compositor_effects/sample_effect/`  
> **关键词**: G-Buffer可视化、通道切换、开发调试工具

---

## 一、效果说明

一个开发调试工具，将 Godot 渲染管线中的各种缓冲区（Color、Depth、Normal、Roughness）直接显示到屏幕上。通过一个下拉菜单可快速切换查看不同通道。

### 效果预览
- **Color**：正常画面颜色
- **Depth**：深度图（近白远黑）
- **Normal**：法线图（彩色编码表面朝向）
- **Roughness**：粗糙度图（黑白表示光滑/粗糙区域）

---

## 二、GLSL Compute Shader 实现

```glsl
#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_layer;
layout(set = 0, binding = 1) uniform sampler2D depth_layer;
layout(set = 0, binding = 2) uniform sampler2D normal_roughness_layer;

layout(push_constant) uniform constants {
    uint mode;    // 0=Color, 1=Depth, 2=Normal, 3=Roughness
} push_cont;

void main() {
    ivec2 store_pos = ivec2(gl_GlobalInvocationID.xy);
    ivec2 screen_size = imageSize(color_layer);

    if (push_cont.mode == 1) {
        float depth = texelFetch(depth_layer, store_pos, 0).r;
        imageStore(color_layer, store_pos, vec4(vec3(depth), 1.0));
    } else if (push_cont.mode == 2) {
        vec3 normal_roughness = texelFetch(normal_roughness_layer, store_pos, 0).rgb;
        normal_roughness.rgb = normal_roughness.rgb * 2.0 - 1.0;  // [0,1] → [-1,1]
        imageStore(color_layer, store_pos, vec4(normal_roughness.rgb, 1.0));
    } else if (push_cont.mode == 3) {
        float roughness = texelFetch(normal_roughness_layer, store_pos, 0).a;
        imageStore(color_layer, store_pos, vec4(vec3(roughness), 1.0));
    }
}
```

---

## 三、技术要点

### 3.1 Normal Buffer 解码

```glsl
vec3 normal_roughness = texelFetch(normal_roughness_layer, store_pos, 0).rgb;
normal_roughness.rgb = normal_roughness.rgb * 2.0 - 1.0;
```

Godot 将法线数据存储在 [0, 1] 范围内（GPU 友好的无符号格式），需要转换回 [-1, 1] 才能正确显示。

### 3.2 Normal Buffer 通道布局

`normal_roughness_layer` 的 RGBA 通道：
| 通道 | 内容 |
|------|------|
| R | Normal X |
| G | Normal Y |
| B | Normal Z |
| A | Roughness |

### 3.3 Mode 切换

```gdscript
@export_enum("Color", "Depth", "Normal", "Roughness") var mode := 0
```

通过 `push_cont.mode` 控制 shader 中的 if-else 分支。这是简单的运行时分支，不是编译时分支，性能开销可以忽略（仅一个 uniform 比较）。

---

## 四、GDScript 侧实现

```gdscript
@tool
extends CompositorEffect
class_name SampleEffect

@export_enum("Color", "Depth", "Normal", "Roughness") var mode := 0
var rd := RenderingServer.get_rendering_device()
var shader: RID
var pipeline: RID
var depth_sampler: RID
var normal_roughness_sampler: RID

func _init() -> void:
    needs_normal_roughness = true
    var shader_file := preload("res://compositor_effects/sample_effect/sample_effect.glsl")
    var shader_spirv := shader_file.get_spirv()
    shader = rd.shader_create_from_spirv(shader_spirv)
    pipeline = rd.compute_pipeline_create(shader)
    depth_sampler = rd.sampler_create(RDSamplerState.new())
    normal_roughness_sampler = rd.sampler_create(RDSamplerState.new())

func _render_callback(_callback_type: int, render_data: RenderData) -> void:
    var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    var size := render_scene_buffers.get_internal_size()

    if size.x == 0 or size.y == 0:
        return

    var color_layer_uniform := RDUniform.new()
    color_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
    color_layer_uniform.binding = 0
    color_layer_uniform.add_id(render_scene_buffers.get_color_layer(0))

    var depth_layer_uniform := RDUniform.new()
    depth_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
    depth_layer_uniform.binding = 1
    depth_layer_uniform.add_id(depth_sampler)
    depth_layer_uniform.add_id(render_scene_buffers.get_depth_layer(0))

    var normal_roughness_layer_uniform := RDUniform.new()
    normal_roughness_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
    normal_roughness_layer_uniform.binding = 2
    normal_roughness_layer_uniform.add_id(normal_roughness_sampler)
    normal_roughness_layer_uniform.add_id(render_scene_buffers.get_texture("forward_clustered", "normal_roughness"))

    var bindings := [color_layer_uniform, depth_layer_uniform, normal_roughness_layer_uniform]
    var uniform_set := rd.uniform_set_create(bindings, shader, 0)

    var mode_bytes := PackedByteArray()
    mode_bytes.resize(16)  # push_constant 必须是 16 字节的倍数
    mode_bytes.encode_u32(0, mode)

    var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)

    var compute_list := rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_set_push_constant(compute_list, mode_bytes, mode_bytes.size())
    rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
    rd.compute_list_end()

    rd.free_rid(uniform_set)
```

---

## 五、开发调试用途

| 查看通道 | 诊断什么 |
|---------|---------|
| **Depth** | 近/远裁剪面是否合理，物体深度排序是否正确 |
| **Normal** | 法线贴图是否正确，表面朝向是否一致 |
| **Roughness** | 材质粗糙度分布是否合理 |
| **Color** | 基准参考画面 |

建议在开发任何 G-Buffer 相关的后处理效果时，先用 Sample Effect 查看原始数据，确认格式和内容后再编写处理逻辑。

---

## 六、与本项目的关联

Sample Effect 是最实用的调试工具。在开发 CompositorEffect 时：
1. 先挂载 Sample Effect，查看 depth/normal/roughness 的原始数据
2. 确认数据格式正确后再实现具体的后处理逻辑
3. 可作为项目内置的调试工具，方便排查渲染问题

来源：`compositor-effect-library/compositor_effects/sample_effect/sample_effect.gd` + `sample_effect.glsl`
