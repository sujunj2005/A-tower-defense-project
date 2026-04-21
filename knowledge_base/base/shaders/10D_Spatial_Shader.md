# Godot 4.x Spatial 着色器

> 适用版本：Godot 4.x | 来源：知识库整合

---

## 目录

1. [Spatial 着色器概述](#1-spatial-着色器概述)
2. [渲染模式](#2-渲染模式)
3. [常用内置变量](#3-常用内置变量)
4. [材质参数](#4-材质参数)

---

## 1. Spatial 着色器概述

`shader_type spatial` 用于 3D 渲染，应用于 MeshInstance3D 等 3D 物体。

---

## 2. 渲染模式

```glsl
render_mode unshaded, cull_disabled;           // 无光照、不剔除背面
render_mode blend_mix, depth_draw_alpha_prepass;  // 混合、透明预通道
render_mode world_vertex_coords;                 // 世界坐标顶点
render_mode ensure_correct_normals;              // 确保法线正确
```

**常用模式：**
| 模式 | 说明 |
|------|------|
| `unshaded` | 不受光照影响 |
| `cull_disabled` | 双面显示 |
| `blend_mix` | Alpha 混合 |
| `depth_draw_alpha_prepass` | 深度预通过 |
| `diffuse_lambert`, `diffuse_toon`, `diffuse_burley` | 漫反射模式 |
| `specular_schlick_ggx`, `specular_toon`, `specular_blinn` | 高光模式 |

---

## 3. 常用内置变量

### 3.1 Vertex 函数
| 变量 | 类型 | 说明 |
|------|------|------|
| `VERTEX` | `vec3` | 顶点位置 |
| `NORMAL` | `vec3` | 顶点法线 |
| `TANGENT` | `vec3` | 顶点切线 |
| `COLOR` | `vec4` | 顶点颜色 |
| `UV` | `vec2` | UV 坐标 |
| `UV2` | `vec2` | 第二套 UV |
| `BONE_INDICES` | `ivec4` | 骨骼索引 |
| `BONE_WEIGHTS` | `vec4` | 骨骼权重 |
| `INSTANCE_CUSTOM` | `vec4` | 实例自定义数据 |
| `POSITION` | `vec3` | 视空间位置（只读） |
| `VIEW` | `mat4` | 视图矩阵（只读） |
| `MODELVIEW_MATRIX` | `mat4` | 模型视图矩阵（只读） |

### 3.2 Fragment 函数
| 变量 | 类型 | 说明 |
|------|------|------|
| `ALBEDO` | `vec3` | 反照率颜色 |
| `METALLIC` | `float` | 金属度 |
| `ROUGHNESS` | `float` | 粗糙度 |
| `EMISSION` | `vec3` | 发光强度 |
| `NORMAL` | `vec3` | 法线（切线空间） |
| `NORMAL_MAP` | `vec3` | 法线贴图 |
| `NORMALMAP_DEPTH` | `float` | 法线贴图深度 |
| `ALPHA` | `float` | 透明度 |
| `AO` | `float` | 环境光遮蔽 |
| `AO_LIGHT_AFFECT` | `float | AO 对光照影响 |
| `BACKLIGHT` | `vec3 | 背光 |

### 3.3 Light 函数
| 变量 | 类型 | 说明 |
|------|------|------|
| `LIGHT` | `Light` | 光源数据结构体 |
| `ATTENUATION` | `float` | 衰减系数 |
| `DIFFUSE_LIGHT` | `vec3` | 漫反射贡献 |
| `SPECULAR_LIGHT` | `vec3 | 高光贡献 |

---

## 4. 材质参数

```glsl
// 标准材质参数
uniform sampler2D albedo_texture : hint_albedo;
uniform vec4 albedo_color : source_color;
uniform float metallic : hint_range(0, 1);
uniform float roughness : hint_range(0, 1);
uniform sampler2D normal_map : hint_normal;
uniform sampler2D emission_texture : hint_black_albedo;
uniform vec4 emission_color : source_color;
uniform float emission_energy : hint_range(0, 16);
uniform float ao_strength : hint_range(0, 8);
uniform float point_size : hint_range(0, 128);

void fragment() {
    ALBEDO = texture(albedo_texture, UV).rgb * albedo_color.rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    NORMAL_MAP = texture(normal_map, UV).xyz;
    EMISSION = texture(emission_texture, UV).rgb * emission_color.rgb * emission_energy;
    AO = ao_strength;
}
```

---
*更多详情请查看 Godot 官方 Spatial Shader 文档。*
