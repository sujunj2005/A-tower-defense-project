# 案例 2：CompositorEffect 基础架构与 G-Buffer 提取

> **适用版本**: Godot 4.6+  
> **来源**: `compositor-effect-library/compositor_effects/outline/` + `pixelate/` + `sample_effect/`  
> **重要性**: 🔴 必读 — CompositorEffect 是所有后处理效果的基础

---

## 一、CompositorEffect 是什么

`CompositorEffect` 是 Godot 4.x 引入的后处理效果系统。它允许在渲染管线中注入自定义计算着色器，对已渲染的帧缓冲区进行后处理操作。

### 核心特性
- 通过 `@tool` 标记，效果在编辑器中即可预览
- 继承 `CompositorEffect` 并实现 `_render_callback`
- 直接读写渲染服务器的帧缓冲区（color、depth、normal 等）
- 支持通过 `needs_normal_roughness`、`needs_motion_vectors` 请求额外 G-Buffer

---

## 二、基本模板

```gdscript
@tool
extends CompositorEffect
class_name MyEffect

var rd := RenderingServer.get_rendering_device()
var shader: RID
var pipeline: RID

func _init() -> void:
    var shader_file := preload("my_effect.glsl")
    var shader_spirv := shader_file.get_spirv()
    shader = rd.shader_create_from_spirv(shader_spirv)
    pipeline = rd.compute_pipeline_create(shader)

func _render_callback(_callback_type: int, render_data: RenderData) -> void:
    var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    var size := render_scene_buffers.get_internal_size()

    if size.x == 0 or size.y == 0:
        return

    var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)
    var uniform_set := rd.uniform_set_create(bindings, shader, 0)
    var compute_list := rd.compute_list_begin()

    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
    rd.compute_list_end()

    rd.free_rid(uniform_set)
```

---

## 三、G-Buffer 提取

### 3.1 Color Buffer

```gdscript
render_scene_buffers.get_color_layer(0)
```

- 返回 `RID`，指向当前帧的颜色缓冲区
- 在 GLSL 中对应 `image2D` 类型（读写纹理）
- 格式通常为 `rgba16f`

### 3.2 Depth Buffer

```gdscript
render_scene_buffers.get_depth_layer(0)
```

- 返回 `RID`，指向深度缓冲区
- 需要配合 `RDSamplerState` 创建 sampler
- 在 GLSL 中通过 `sampler2D` 采样，读取 `.r` 通道

### 3.3 Normal + Roughness Buffer

```gdscript
# 1. 在 _init() 中声明需要此缓冲区
needs_normal_roughness = true

# 2. 在 _render_callback 中提取
render_scene_buffers.get_texture("forward_clustered", "normal_roughness")
```

> **注意**：`normal_roughness` 缓冲区仅在 `needs_normal_roughness = true` 时才可用。

### 3.4 创建 Sampler

```gdscript
depth_sampler = rd.sampler_create(RDSamplerState.new())
normal_roughness_sampler = rd.sampler_create(RDSamplerState.new())
```

### 3.5 Push Constant 传递相机矩阵

```gdscript
var inv_proj_mat := render_data.get_render_scene_data().get_cam_projection().inverse()
var inv_proj_mat_array := PackedVector4Array([inv_proj_mat.x, inv_proj_mat.y, inv_proj_mat.z, inv_proj_mat.w])
var raster_size := PackedFloat32Array([size.x, size.y, 0.0, 0.0])

var push_constants := inv_proj_mat_array.to_byte_array()
push_constants.append_array(raster_size.to_byte_array())
```

---

## 四、完整 Uniform 绑定示例

```gdscript
func _render_callback(_callback_type: int, render_data: RenderData) -> void:
    var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    var size := render_scene_buffers.get_internal_size()

    # 1. Color layer (image2D, 读写)
    var color_layer_uniform := RDUniform.new()
    color_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
    color_layer_uniform.binding = 0
    color_layer_uniform.add_id(render_scene_buffers.get_color_layer(0))

    # 2. Depth layer (sampler2D, 只读采样)
    var depth_layer_uniform := RDUniform.new()
    depth_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
    depth_layer_uniform.binding = 1
    depth_layer_uniform.add_id(depth_sampler)
    depth_layer_uniform.add_id(render_scene_buffers.get_depth_layer(0))

    # 3. Normal/Roughness layer (sampler2D, 只读采样)
    var normal_roughness_layer_uniform := RDUniform.new()
    normal_roughness_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
    normal_roughness_layer_uniform.binding = 2
    normal_roughness_layer_uniform.add_id(normal_roughness_sampler)
    normal_roughness_layer_uniform.add_id(render_scene_buffers.get_texture("forward_clustered", "normal_roughness"))

    var bindings: Array[RDUniform] = [
        color_layer_uniform,
        depth_layer_uniform,
        normal_roughness_layer_uniform
    ]
```

---

## 五、Uniform 类型对照表

| GDScript Uniform Type | GLSL 对应 | 用途 |
|----------------------|-----------|------|
| `UNIFORM_TYPE_IMAGE` | `uniform image2D` | 读写纹理（imageLoad/imageStore） |
| `UNIFORM_TYPE_SAMPLER_WITH_TEXTURE` | `uniform sampler2D` | 只读采样（texture） |
| `UNIFORM_TYPE_UNIFORM_BUFFER` | `uniform Buffer { ... }` | 统一数据块 |

---

## 六、Work Group 计算

```gdscript
var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)
```

- 对应 GLSL 的 `local_size_x = 8, local_size_y = 8`
- 公式：`(size - 1) / 8 + 1` 实现向上取整除法
- 确保每个像素都有一个工作项处理

---

## 七、编辑器工具集成

```gdscript
# 1. 编辑器内可预览
@tool
extends CompositorEffect

# 2. 枚举参数可视化切换
@export_enum("Color", "Depth", "Normal", "Roughness") var mode := 0

# 3. 热重载按钮
@export_tool_button("Reload Shader", "Reload") var reload_button := reload_shader
```

---

## 八、场景配置

在 `.tscn` 场景文件中，CompositorEffect 通过 `Compositor` 资源挂载：

```gdscene
[sub_resource type="CompositorEffect" id="CompositorEffect_xxx"]
enabled = true
effect_callback_type = 4
needs_normal_roughness = true
script = ExtResource("x_xxx")

[sub_resource type="Compositor" id="Compositor_xxx"]
compositor_effects = Array[CompositorEffect]([SubResource("CompositorEffect_xxx")])

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_xxx")
compositor = SubResource("Compositor_xxx")
```

来源：`compositor-effect-library/compositor_effects/outline/outline.gd`、`sample_effect.gd`
