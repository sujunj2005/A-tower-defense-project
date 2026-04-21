# Spatial 着色器实战指南

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [10D_Spatial_Shader.md](../base/shaders/10D_Spatial_Shader.md)

---

## 📚 目录

1. [Spatial 着色器概述](#1-spatial-着色器概述)
2. [渲染模式详解](#2-渲染模式详解)
3. [内置变量和参数](#3-内置变量和参数)
4. [基础光照效果](#4-基础光照效果)
5. [高级材质效果](#5-高级材质效果)
6. [顶点动画](#6-顶点动画)
7. [实战案例](#7-实战案例)

---

## 1. Spatial 着色器概述

### 1.1 什么是 Spatial 着色器

`shader_type spatial` 是 Godot 中用于**3D 渲染**的着色器类型，可应用于：
- MeshInstance3D
- CSGShape3D
- 3D 粒子系统
- 地形系统

### 1.2 基本结构

```glsl
shader_type spatial;

// 渲染模式
render_mode unshaded, cull_disabled;

// Uniforms
uniform sampler2D albedo_texture : hint_albedo;
uniform vec4 albedo_color : source_color;

void vertex() {
    // 顶点处理
}

void fragment() {
    // 片段处理
    ALBEDO = vec3(1.0, 0.0, 0.0);  // 红色
}

void light() {
    // 光照计算（可选）
}
```

### 1.3 处理器函数对比

| 函数 | 用途 | 调用频率 |
|------|------|----------|
| `vertex()` | 修改顶点位置、法线、UV | 每个顶点 |
| `fragment()` | 设置材质属性（ALBEDO/METALLIC 等） | 每个像素 |
| `light()` | 自定义光照计算 | 每个像素×每个光源 |

---

## 2. 渲染模式详解

### 2.1 常用渲染模式

```glsl
// 无光照渲染（不受光照影响）
render_mode unshaded;

// 双面渲染（不剔除背面）
render_mode cull_disabled;

// 透明混合
render_mode blend_mix, depth_draw_alpha_prepass;

// 世界坐标顶点
render_mode world_vertex_coords;

// 确保法线正确
render_mode ensure_correct_normals;
```

### 2.2 混合模式

| 模式 | 说明 | 用途 |
|------|------|------|
| `blend_mix` | Alpha 混合 | 透明物体 |
| `blend_add` | 加法混合 | 发光效果、火焰 |
| `blend_sub` | 减法混合 | 阴影 |
| `blend_mul` | 乘法混合 | 暗化效果 |

### 2.3 深度测试模式

| 模式 | 说明 |
|------|------|
| `depth_draw_alpha_prepass` | 透明预通道（推荐用于透明物体） |
| `depth_draw_never` | 禁用深度测试 |
| `depth_draw_always` | 总是深度测试 |
| `depth_draw_opaque` | 仅不透明测试 |

### 2.4 光照模式

**漫反射模式**：
- `diffuse_lambert` - Lambert（标准漫反射）
- `diffuse_toon` - Toon（卡通渲染）
- `diffuse_burley` - Burley（物理基础）

**高光模式**：
- `specular_schlick_ggx` - Schlick-GGX（PBR）
- `specular_toon` - Toon（卡通高光）
- `specular_blinn` - Blinn（传统高光）

---

## 3. 内置变量和参数

### 3.1 Vertex 函数变量

| 变量 | 类型 | 说明 | 读写 |
|------|------|------|------|
| `VERTEX` | vec3 | 顶点位置 | 可读写 |
| `NORMAL` | vec3 | 顶点法线 | 可读写 |
| `TANGENT` | vec3 | 顶点切线 | 可读写 |
| `COLOR` | vec4 | 顶点颜色 | 可读写 |
| `UV` | vec2 | UV 坐标 | 可读写 |
| `UV2` | vec2 | 第二套 UV | 可读写 |
| `BONE_INDICES` | ivec4 | 骨骼索引 | 只读 |
| `BONE_WEIGHTS` | vec4 | 骨骼权重 | 只读 |
| `INSTANCE_CUSTOM` | vec4 | 实例自定义数据 | 只读 |
| `MODELVIEW_MATRIX` | mat4 | 模型视图矩阵 | 只读 |
| `VIEW` | mat4 | 视图矩阵 | 只读 |

### 3.2 Fragment 函数变量（PBR 材质）

| 变量 | 类型 | 说明 | 范围 |
|------|------|------|------|
| `ALBEDO` | vec3 | 反照率颜色（基础颜色） | 0-1 |
| `METALLIC` | float | 金属度 | 0-1 |
| `ROUGHNESS` | float | 粗糙度 | 0-1 |
| `EMISSION` | vec3 | 发光强度 | 0+ |
| `NORMAL` | vec3 | 法线（切线空间） | -1-1 |
| `ALPHA` | float | 透明度 | 0-1 |
| `AO` | float | 环境光遮蔽 | 0-1 |
| `BACKLIGHT` | vec3 | 背光（次表面散射） | 0-1 |

### 3.3 Light 函数变量

| 变量 | 类型 | 说明 |
|------|------|------|
| `LIGHT` | Light | 光源数据结构体 |
| `ATTENUATION` | float | 光照衰减系数 |
| `DIFFUSE_LIGHT` | vec3 | 漫反射贡献 |
| `SPECULAR_LIGHT` | vec3 | 高光贡献 |
| `LIGHT_COLOR` | vec3 | 光源颜色 |
| `LIGHT_POSITION` | vec3 | 光源位置 |

---

## 4. 基础光照效果

### 4.1 标准 PBR 材质

```glsl
shader_type spatial;

uniform sampler2D albedo_texture : hint_albedo;
uniform sampler2D metallic_texture : hint_grey;
uniform sampler2D roughness_texture : hint_grey;
uniform sampler2D normal_map : hint_normal;

void fragment() {
    ALBEDO = texture(albedo_texture, UV).rgb;
    METALLIC = texture(metallic_texture, UV).r;
    ROUGHNESS = texture(roughness_texture, UV).r;
    NORMALMAP = texture(normal_map, UV).rgb;
}
```

### 4.2 发光材质

```glsl
shader_type spatial;

uniform sampler2D emission_texture : hint_black_albedo;
uniform vec4 emission_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float emission_energy : hint_range(0, 16) = 1.0;

void fragment() {
    ALBEDO = vec3(0.1, 0.1, 0.1);  // 暗色基础
    EMISSION = texture(emission_texture, UV).rgb * emission_color.rgb * emission_energy;
}
```

### 4.3 透明材质

```glsl
shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass, cull_disabled;

uniform sampler2D albedo_texture : hint_albedo;
uniform float transparency : hint_range(0, 1) = 0.5;

void fragment() {
    vec4 tex = texture(albedo_texture, UV);
    ALBEDO = tex.rgb;
    ALPHA = tex.a * transparency;
}
```

### 4.4 双面材质

```glsl
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : hint_albedo;

void fragment() {
    ALBEDO = texture(albedo_texture, UV).rgb;
}
```

---

## 5. 高级材质效果

### 5.1 水面效果

```glsl
shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass;

uniform vec4 water_color : source_color = vec4(0.0, 0.3, 0.5, 0.8);
uniform float wave_height : hint_range(0, 1) = 0.1;
uniform float wave_speed = 1.0;

void vertex() {
    // 顶点波浪
    float wave = sin(VERTEX.x * 5.0 + TIME * wave_speed) * 
                 cos(VERTEX.z * 3.0 + TIME * wave_speed) * wave_height;
    VERTEX.y += wave;
}

void fragment() {
    ALBEDO = water_color.rgb;
    ALPHA = water_color.a;
    ROUGHNESS = 0.1;
    METALLIC = 0.0;
}
```

### 5.2 溶解效果

```glsl
shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass;

uniform float dissolve_amount : hint_range(0, 1) = 0.0;
uniform vec4 dissolve_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float edge_glow : hint_range(0, 5) = 2.0;

void fragment() {
    // 使用噪声或 UV 作为溶解依据
    float noise = UV.x * UV.y;
    
    // 溶解边缘
    float edge = smoothstep(dissolve_amount - 0.1, dissolve_amount + 0.1, noise);
    
    ALBEDO = mix(dissolve_color.rgb, vec3(1.0), edge);
    ALPHA = edge;
    EMISSION = dissolve_color.rgb * (1.0 - edge) * edge_glow;
}
```

### 5.3 全息效果

```glsl
shader_type spatial;
render_mode blend_add, depth_draw_alpha_prepass, cull_disabled;

uniform vec4 hologram_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float scanline_speed = 2.0;
uniform float scanline_intensity : hint_range(0, 1) = 0.5;

void fragment() {
    // 扫描线效果
    float scanline = sin(UV.y * 50.0 - TIME * scanline_speed) * 0.5 + 0.5;
    scanline = mix(1.0 - scanline_intensity, 1.0, scanline);
    
    ALBEDO = hologram_color.rgb;
    ALPHA = scanline * 0.7;
    EMISSION = hologram_color.rgb * scanline;
}
```

### 5.4 卡通渲染（Toon Shader）

```glsl
shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec4 toon_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float toon_steps : hint_range(2, 8) = 4.0;

void fragment() {
    ALBEDO = toon_color.rgb;
    
    // 简化版卡通阴影
    float ndl = dot(NORMAL, LIGHT);
    ALBEDO = floor(ALBEDO * toon_steps) / toon_steps;
}
```

---

## 6. 顶点动画

### 6.1 旗帜飘动

```glsl
shader_type spatial;

uniform float wind_speed = 2.0;
uniform float wind_strength : hint_range(0, 1) = 0.3;

void vertex() {
    // 基于顶点位置的波浪
    float wave = sin(VERTEX.x * 5.0 + TIME * wind_speed) * wind_strength;
    VERTEX.z += wave * (1.0 - VERTEX.y);  // 底部固定
}
```

### 6.2 草地摆动

```glsl
shader_type spatial;

uniform float grass_speed = 3.0;
uniform float grass_bend : hint_range(0, 1) = 0.2;

void vertex() {
    // 草叶随风摆动
    float bend = sin(TIME * grass_speed + VERTEX.x * 10.0) * grass_bend;
    VERTEX.x += bend * VERTEX.y;  // 顶部摆动更大
}
```

### 6.3 浮动效果

```glsl
shader_type spatial;

uniform float float_speed = 1.0;
uniform float float_height : hint_range(0, 2) = 0.5;

void vertex() {
    // 整体浮动
    VERTEX.y += sin(TIME * float_speed + VERTEX.x * 2.0) * float_height;
}
```

---

## 7. 实战案例

### 7.1 能量护盾

```glsl
shader_type spatial;
render_mode blend_add, depth_draw_alpha_prepass, cull_disabled;

uniform vec4 shield_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float pulse_speed = 3.0;
uniform float pulse_intensity : hint_range(0, 2) = 1.0;

void vertex() {
    // 顶点扰动
    VERTEX += NORMAL * sin(TIME * 10.0 + UV.x * 20.0) * 0.05;
}

void fragment() {
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    pulse = pow(pulse, pulse_intensity);
    
    ALBEDO = shield_color.rgb;
    ALPHA = 0.3 + pulse * 0.3;
    EMISSION = shield_color.rgb * pulse;
}
```

### 7.2 熔岩材质

```glsl
shader_type spatial;

uniform vec4 lava_color : source_color = vec4(1.0, 0.3, 0.0, 1.0);
uniform vec4 crust_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform float flow_speed = 0.5;

void fragment() {
    // 流动效果
    vec2 uv_flow = UV;
    uv_flow.x += TIME * flow_speed;
    uv_flow.y += sin(uv_flow.x * 10.0) * 0.1;
    
    // 噪声混合
    float noise = sin(uv_flow.x * 20.0) * cos(uv_flow.y * 20.0) * 0.5 + 0.5;
    
    ALBEDO = mix(crust_color.rgb, lava_color.rgb, noise);
    EMISSION = lava_color.rgb * noise * 2.0;
    ROUGHNESS = 0.2;
}
```

### 7.3 冰材质

```glsl
shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass;

uniform vec4 ice_color : source_color = vec4(0.7, 0.9, 1.0, 0.8);
uniform float roughness : hint_range(0, 1) = 0.1;
uniform float transmission : hint_range(0, 1) = 0.9;

void fragment() {
    ALBEDO = ice_color.rgb;
    ALPHA = ice_color.a;
    ROUGHNESS = roughness;
    METALLIC = 0.0;
    // 使用透射模拟冰的折射
}
```

### 7.4 力场效果

```glsl
shader_type spatial;
render_mode blend_add, depth_draw_alpha_prepass, cull_disabled;

uniform vec4 forcefield_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float cell_size : hint_range(0.1, 2.0) = 0.5;
uniform float pulse_speed = 2.0;

void fragment() {
    // 六边形网格效果
    vec2 uv = UV * cell_size;
    vec2 grid = abs(fract(uv - 0.5) - 0.5);
    float lines = step(0.95, max(grid.x, grid.y));
    
    // 脉冲
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    
    ALBEDO = forcefield_color.rgb;
    ALPHA = lines * (0.5 + pulse * 0.5);
    EMISSION = forcefield_color.rgb * lines * pulse;
}
```

---

## 🔗 相关链接

- **Base 层来源**: [10D_Spatial_Shader.md](../base/shaders/10D_Spatial_Shader.md)
- **Wiki 概念**: 
  - [着色器核心概念](./shader-concepts.md)
  - [着色器语言参考](./shading-language-reference.md)
- **Wiki 指南**: [Canvas Item 着色器指南](./canvas-item-shader-guide.md)

---

**维护者**: Knowledge Base Administrator
