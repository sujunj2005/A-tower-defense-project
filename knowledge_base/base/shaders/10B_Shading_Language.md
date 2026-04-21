# Godot 4.x 着色器语言参考

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/shaders/shader_reference/shading_language.rst

---

## 目录

1. [数据类型](#1-数据类型)
2. [变量与常量](#2-变量与常量)
3. [Uniforms](#3-uniforms)
4. [处理器函数](#4-处理器函数)
5. [内置函数](#5-内置函数)

---

## 1. 数据类型

### 1.1 基本类型
```glsl
bool b = true;
int i = 42;
float f = 3.14;
uint u = 10u;
```

### 1.2 向量/矩阵
```glsl
vec2 v = vec2(1.0, 2.0);
vec3 v = vec3(1.0, 2.0, 3.0);
vec4 v = vec4(1.0, 2.0, 3.0, 4.0);

mat2 m = mat2(1.0);     // 单位矩阵
mat3 m = mat3(1.0);
mat4 m = mat4(1.0);
```

### 1.3 采样器和纹理
```glsl
sampler2D tex;          // 2D 纹理
samplerCube tex;       // 立方体贴图
```

---

## 2. 变量与常量

```glsl
// 内置变量
vec2 UV;               // UV 坐标（fragment 中）
vec3 VERTEX;            // 顶点位置（vertex 中）
vec3 NORMAL;           // 法线
vec3 TANGENT;          // 切线
vec4 COLOR;            // 颜色
mat4 MODELVIEW_MATRIX; // 模型视图矩阵

// 自定义变量
uniform float my_var;
const float PI = 3.14159;
```

---

## 3. Uniforms

### 3.1 定义 Uniform
```glsl
shader_type canvas_item;

uniform sampler2D my_texture : hint_albedo;
uniform vec4 color : hint_color;
uniform float size : range(0, 100);
uniform int count : filter_nearest;

void fragment() {
    COLOR = texture(my_texture, UV) * color;
}
```

### 3.2 提示选项
| 提示 | 用途 |
|------|------|
| `hint_color` | 颜色选择器 |
| `hint_range(min, max)` | 范围滑块 |
| `hint_albedo` | Albedo 纹理 |
| `hint_normal` | 法线贴图 |
| `filter_nearest` / `filter_linear` | 过滤模式 |
| `repeat_enable` / `repeat_disable` | 重复 |

---

## 4. 处理器函数

### 4.1 vertex()
每个顶点调用一次，用于修改顶点位置：
```glsl
void vertex() {
    VERTEX += NORMAL * sin(TIME * 5.0) * 0.05;
}
```

### 4.2 fragment()
每个像素调用一次，用于修改颜色：
```glsl
void fragment() {
    COLOR.rgb = vec3(sin(UV.x * 50.0), 0.0, 0.0);
}
```

### 4.3 light()
每个像素×每个光源调用，用于自定义光照响应：
```glsl
void light() {
    DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION;
}
```

---

## 5. 内置函数

### 5.1 数学
```glsl
length(x), distance(a, b), normalize(x), dot(a, b), cross(a, b)
reflect(I, N), refract(I, N, eta)
sin(x), cos(x), tan(x), asin(x), acos(x), atan(x, y)
pow(x, exp), sqrt(x), abs(x), sign(x), floor(x), ceil(x), fract(x)
min(a, max), max(a, min), clamp(value, min_val, max_val)
mix(a, b, t), step(edge, x), smoothstep(edge0, edge1, x)
```

### 5.2 纹理
```glsl
texture(sampler, uv)        // 采样纹理
textureLod(sampler, uv, lod) // 指定 LOD 采样
textureSize(sampler)         // 获取纹理大小
```

### 5.3 向量操作
```glsl
dFdx(v), dFdy(v)           // 屏幕空间导数
fwidth(v)                   // 三角形宽度近似
```

---

## 参考资料
- 来源文件：`godot-docs-master/tutorials/shaders/shader_reference/shading_language.rst`
