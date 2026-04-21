# 案例 3：Outline —— 基于深度缓冲的边缘检测

> **适用版本**: Godot 4.6+  
> **来源**: `compositor-effect-library/compositor_effects/outline/`  
> **关键词**: 边缘检测、深度差分、G-Buffer

---

## 一、效果说明

在 3D 场景渲染完成后，通过深度缓冲（Depth Buffer）的差异检测物体边缘，在物体周围绘制轮廓线。这是一种经典的后处理描边技术，性能开销极低。

### 效果预览
- 物体边缘呈现深色描边
- 支持可配置的描边颜色、半径、深度阈值
- 对背景天空可单独启用描边

---

## 二、GLSL Compute Shader 实现

```glsl
#[compute]
#version 450

#define RADIUS 2.0

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_layer;
layout(set = 0, binding = 1) uniform sampler2D depth_layer;

layout(push_constant) uniform constants {
    vec4 inv_proj_mat[4];
    vec4 raster_size;
} push_cont;

void main() {
    ivec2 screen_size = imageSize(color_layer);
    ivec2 store_pos = ivec2(gl_GlobalInvocationID.xy);
    vec4 old_color = imageLoad(color_layer, store_pos);
    vec2 depth_size = vec2(textureSize(depth_layer, 0));
    float depth_threshold = push_cont.inv_proj_mat[2].y * 0.01;

    #define DEPTH_SAMPLE(X, Y) texelFetch(depth_layer, clamp(ivec2(store_pos + vec2(X, Y) * RADIUS), ivec2(0), ivec2(depth_size) - 1), 0).r

    float center_depth = DEPTH_SAMPLE(0, 0);
    float top_depth = DEPTH_SAMPLE(0, 1);
    float bottom_depth = DEPTH_SAMPLE(0, -1);
    float left_depth = DEPTH_SAMPLE(-1, 0);
    float right_depth = DEPTH_SAMPLE(1, 0);

    bool depth_edge =
        abs(center_depth - top_depth) > depth_threshold ||
        abs(center_depth - bottom_depth) > depth_threshold ||
        abs(center_depth - left_depth) > depth_threshold ||
        abs(center_depth - right_depth) > depth_threshold;

    if (depth_edge) {
        imageStore(color_layer, store_pos, vec4(push_cont.inv_proj_mat[1].xy, 0.0, 1.0));
    } else {
        imageStore(color_layer, store_pos, old_color);
    }
}
```

---

## 三、技术要点

### 3.1 采样策略：十字形邻域

```glsl
#define RADIUS 2.0
```

使用半径为 2 的十字形采样（上、下、左、右各偏移 RADIUS 像素），而非 3x3 方形采样。优势：
- 只需 5 次纹理采样（中心 + 四方向），而非 9 次
- 对角方向边缘检测略弱但视觉上可接受
- 性能比 3x3 核低约 44%

### 3.2 自适应深度阈值

```glsl
float depth_threshold = push_cont.inv_proj_mat[2].y * 0.01;
```

不写死阈值，而是从相机投影矩阵推导。`inv_proj_mat[2].y` 是投影矩阵的逆矩阵的 (2,1) 元素，与近裁剪面相关。近裁剪面越小、阈值越大，确保在不同相机配置下阈值始终合理。

### 3.3 安全采样边界

```glsl
texelFetch(depth_layer, clamp(ivec2(store_pos + vec2(X, Y) * RADIUS), ivec2(0), ivec2(depth_size) - 1), 0).r
```

使用 `clamp` 防止屏幕边缘采样越界。这是 GPU 后处理的常见做法，避免黑色边框伪影。

### 3.4 深度不连续检测

```glsl
bool depth_edge =
    abs(center_depth - top_depth) > depth_threshold ||
    abs(center_depth - bottom_depth) > depth_threshold ||
    abs(center_depth - left_depth) > depth_threshold ||
    abs(center_depth - right_depth) > depth_threshold;
```

当中心像素深度与相邻像素深度差超过阈值时，判定为边缘。`||` 连接四个方向，任一方向有深度跳变即描边。

---

## 四、GDScript 侧实现

```gdscript
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

    var bindings := [color_layer_uniform, depth_layer_uniform]
    var uniform_set := rd.uniform_set_create(bindings, shader, 0)

    var groups := Vector3i((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1)

    var inv_proj_mat := render_data.get_render_scene_data().get_cam_projection().inverse()
    var inv_proj_mat_array := PackedVector4Array([inv_proj_mat.x, inv_proj_mat.y, inv_proj_mat.z, inv_proj_mat.w])
    var push_constants := inv_proj_mat_array.to_byte_array()

    var compute_list := rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_set_push_constant(compute_list, push_constants, push_constants.size())
    rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
    rd.compute_list_end()

    rd.free_rid(uniform_set)
```

---

## 五、应用场景

| 场景 | 说明 |
|------|------|
| 卡通渲染 | 给 3D 模型加黑色描边，类似漫画/动漫风格 |
| 塔防游戏 | 描边突出敌方单位，增强战场清晰度 |
| 建筑可视化 | 强调建筑结构边缘 |
| 教育/演示 | 帮助识别场景深度不连续区域 |

---

## 六、与本项目的关联

塔防项目中可以用此技术：
- **敌方单位描边**：在大量敌人聚集时仍保持清晰辨识度
- **防御塔选中高亮**：选中防御塔时添加描边
- **范围指示器边缘**：攻击范围边缘深度描边
- **命中效果**：击中敌方单位时短暂改变描边颜色

来源：`compositor-effect-library/compositor_effects/outline/outline.gd` + `outline.glsl`
