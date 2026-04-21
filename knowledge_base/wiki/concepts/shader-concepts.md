# 着色器核心概念

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [10A_Shader_Introduction.md](../base/shaders/10A_Shader_Introduction.md), [10B_Shading_Language.md](../base/shaders/10B_Shading_Language.md)

---

## 📚 目录

1. [着色器概述](#1-着色器概述)
2. [着色器类型](#2-着色器类型)
3. [处理器函数](#3-处理器函数)
4. [着色器语言基础](#4-着色器语言基础)
5. [Uniforms 系统](#5-uniforms 系统)
6. [内置变量](#6-内置变量)

---

## 1. 着色器概述

### 1.1 什么是着色器

着色器是在**GPU（图形处理单元）**上运行的**特殊程序**，用于控制几何体和像素的绘制方式。

**核心特点**：
- ✅ **并行执行**：GPU 可同时运行数千条指令
- ✅ **逐顶点/像素运行**：每个顶点和像素独立处理
- ✅ **无跨帧存储**：无法在帧之间保存状态
- ✅ **编程思维不同**：需要与传统编程不同的思维方式

### 1.2 GDScript vs 着色器

```gdscript
# GDScript - 串行处理
for x in range(width):
    for y in range(height):
        set_color(x, y, some_color)
```

```glsl
# 着色器 - 并行处理（每个像素自动执行）
void fragment() {
    COLOR = some_color;
}
```

---

## 2. 着色器类型

Godot 使用基于**GLSL**的简化着色语言，通过 `shader_type` 指定类型：

| shader_type | 用途 | 适用场景 |
|-------------|------|----------|
| `spatial` | 3D 渲染 | MeshInstance3D、3D 物体 |
| `canvas_item` | 2D 渲染 | Sprite2D、Line2D、Polygon2D、Control |
| `particles` | 粒子系统 | GPUParticles2D/3D |
| `sky` | 天空渲染 | 天空盒、环境背景 |
| `fog` | 体积雾 | 体积雾效果 |

**示例**：
```glsl
shader_type spatial;      // 3D 着色器
shader_type canvas_item;  // 2D 着色器
```

---

## 3. 处理器函数

Godot 着色器有**7 个处理器函数**，在不同时机调用：

| 函数 | 运行时机 | 适用类型 | 说明 |
|------|----------|----------|------|
| `vertex()` | 每个顶点 | spatial, canvas_item | 修改顶点位置 |
| `fragment()` | 每个像素 | spatial, canvas_item | 修改像素颜色 |
| `light()` | 每个像素×每个光源 | spatial, canvas_item | 计算光照贡献 |
| `start()` | 粒子生成时 | particles | 初始化粒子 |
| `process()` | 每帧每个粒子 | particles | 更新粒子状态 |
| `sky()` | 天空渲染时 | sky | 渲染天空 |
| `fog()` | 体积雾体素 | fog | 渲染体积雾 |

### 3.1 函数执行顺序

```
Vertex 阶段 → Fragment 阶段 → Light 阶段（如果有光照）
```

### 3.2 ⚠️ 踩坑点

`light()` 函数在以下情况**不运行**：
- 启用了 `vertex_lighting` 渲染模式
- 项目设置中启用了 **Force Vertex Shading**（移动平台默认启用）

---

## 4. 着色器语言基础

### 4.1 数据类型

**基本类型**：
```glsl
bool b = true;
int i = 42;
float f = 3.14;
uint u = 10u;
```

**向量/矩阵**：
```glsl
vec2 v2 = vec2(1.0, 2.0);
vec3 v3 = vec3(1.0, 2.0, 3.0);
vec4 v4 = vec4(1.0, 2.0, 3.0, 4.0);

mat2 m2 = mat2(1.0);     // 2x2 单位矩阵
mat3 m3 = mat3(1.0);     // 3x3 单位矩阵
mat4 m4 = mat4(1.0);     // 4x4 单位矩阵
```

**采样器和纹理**：
```glsl
sampler2D tex2D;          // 2D 纹理
samplerCube texCube;      // 立方体贴图
sampler3D tex3D;          // 3D 纹理
```

### 4.2 向量操作

```glsl
vec3 v = vec3(1.0, 2.0, 3.0);

// 分量访问
float x = v.x;           // 1.0
vec2 xy = v.xy;          // vec2(1.0, 2.0)

// 运算
vec3 result = v * 2.0;   // vec3(2.0, 4.0, 6.0)
float dot_result = dot(v, v);  // 点积
vec3 cross_result = cross(v1, v2);  // 叉积
```

---

## 5. Uniforms 系统

### 5.1 什么是 Uniforms

Uniforms 是**从外部传递参数**给着色器的变量，可在 Godot 编辑器中调整。

### 5.2 定义 Uniform

```glsl
shader_type canvas_item;

uniform sampler2D my_texture : hint_albedo;
uniform vec4 color : source_color;
uniform float size : hint_range(0, 100);
uniform int count : filter_nearest;

void fragment() {
    COLOR = texture(my_texture, UV) * color;
}
```

### 5.3 常用提示（Hints）

| 提示 | 用途 | 示例 |
|------|------|------|
| `hint_color` / `source_color` | 颜色选择器 | `uniform vec4 color : source_color;` |
| `hint_range(min, max)` | 范围滑块 | `uniform float size : hint_range(0, 100);` |
| `hint_albedo` | Albedo 纹理选择 | `uniform sampler2D tex : hint_albedo;` |
| `hint_normal` | 法线贴图选择 | `uniform sampler2D normal : hint_normal;` |
| `filter_nearest` / `filter_linear` | 纹理过滤模式 | `uniform int filter : filter_nearest;` |
| `repeat_enable` / `repeat_disable` | 纹理重复 | `uniform sampler2D tex : repeat_enable;` |

---

## 6. 内置变量

### 6.1 Vertex 函数内置变量

| 变量 | 类型 | 说明 | 读写 |
|------|------|------|------|
| `VERTEX` | vec3/vec2 | 顶点位置 | 可读写 |
| `NORMAL` | vec3 | 顶点法线 | 可读写 |
| `TANGENT` | vec3 | 顶点切线 | 可读写 |
| `COLOR` | vec4 | 顶点颜色 | 可读写 |
| `UV` | vec2 | UV 坐标 | 可读写 |
| `UV2` | vec2 | 第二套 UV | 可读写 |
| `INSTANCE_CUSTOM` | vec4 | 实例自定义数据 | 只读 |
| `MODELVIEW_MATRIX` | mat4 | 模型视图矩阵 | 只读 |
| `VIEW` | mat4 | 视图矩阵 | 只读 |

### 6.2 Fragment 函数内置变量（Spatial）

| 变量 | 类型 | 说明 |
|------|------|------|
| `ALBEDO` | vec3 | 反照率颜色（基础颜色） |
| `METALLIC` | float | 金属度（0-1） |
| `ROUGHNESS` | float | 粗糙度（0-1） |
| `EMISSION` | vec3 | 发光强度 |
| `NORMAL` | vec3 | 法线（切线空间） |
| `ALPHA` | float | 透明度 |
| `AO` | float | 环境光遮蔽 |

### 6.3 Fragment 函数内置变量（Canvas Item）

| 变量 | 类型 | 说明 |
|------|------|------|
| `UV` | vec2 | 当前像素的 UV 坐标 |
| `VERTEX` | vec2 | 当前顶点的位置 |
| `COLOR` | vec4 | 当前像素的颜色 |
| `TIME` | float | 自场景开始的时间（秒） |
| `TEXTURE` | sampler2D | 节点纹理 |
| `ATLAS_TEXTURE` | sampler2D | 图集纹理 |

### 6.4 Light 函数内置变量

| 变量 | 类型 | 说明 |
|------|------|------|
| `LIGHT` | Light | 光源数据结构体 |
| `ATTENUATION` | float | 光照衰减系数 |
| `DIFFUSE_LIGHT` | vec3 | 漫反射贡献 |
| `SPECULAR_LIGHT` | vec3 | 高光贡献 |

---

## 🔗 相关链接

- **Base 层来源**:
  - [10A_Shader_Introduction.md](../base/shaders/10A_Shader_Introduction.md) - 着色器入门
  - [10B_Shading_Language.md](../base/shaders/10B_Shading_Language.md) - 着色器语言参考
- **Wiki 指南**:
  - [Canvas Item 着色器指南](./canvas-item-shader-guide.md) - 2D 着色器实战
  - [Spatial 着色器指南](./spatial-shader-guide.md) - 3D 着色器实战

---

**维护者**: Knowledge Base Administrator
