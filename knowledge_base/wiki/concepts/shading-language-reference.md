# Godot 着色器语言参考

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [10B_Shading_Language.md](../base/shaders/10B_Shading_Language.md)

---

## 📚 目录

1. [数据类型详解](#1-数据类型详解)
2. [变量与常量](#2-变量与常量)
3. [运算符](#3-运算符)
4. [控制流](#4-控制流)
5. [内置函数](#5-内置函数)
6. [渲染模式](#6-渲染模式)

---

## 1. 数据类型详解

### 1.1 标量类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `bool` | 布尔值 | `bool b = true;` |
| `int` | 有符号整数 | `int i = 42;` |
| `float` | 浮点数 | `float f = 3.14;` |
| `uint` | 无符号整数 | `uint u = 10u;` |

### 1.2 向量类型

**向量构造**：
```glsl
vec2 v2 = vec2(1.0, 2.0);        // 2D 向量
vec3 v3 = vec3(1.0, 2.0, 3.0);   // 3D 向量
vec4 v4 = vec4(1.0, 2.0, 3.0, 4.0);  // 4D 向量

// 从标量构造
vec3 v = vec3(1.0);              // vec3(1.0, 1.0, 1.0)

// 混合构造
vec3 v = vec3(vec2(1.0, 2.0), 3.0);  // vec3(1.0, 2.0, 3.0)
```

**向量分量访问**：
```glsl
vec4 v = vec4(1.0, 2.0, 3.0, 4.0);

// xyzw 访问（空间向量）
float x = v.x;        // 1.0
vec3 xyz = v.xyz;     // vec3(1.0, 2.0, 3.0)

// rgba 访问（颜色向量）
float r = v.r;        // 1.0
vec3 rgb = v.rgb;     // vec3(1.0, 2.0, 3.0)

// stpq 访问（纹理坐标）
float s = v.s;        // 1.0
vec2 st = v.st;       // vec2(1.0, 2.0)
```

### 1.3 矩阵类型

```glsl
mat2 m2 = mat2(1.0);           // 2x2 单位矩阵
mat3 m3 = mat3(1.0);           // 3x3 单位矩阵
mat4 m4 = mat4(1.0);           // 4x4 单位矩阵

// 矩阵乘法
vec3 result = m3 * v3;
mat4 combined = m4_1 * m4_2;
```

### 1.4 采样器类型

| 类型 | 说明 | 用途 |
|------|------|------|
| `sampler2D` | 2D 纹理采样器 | 2D 纹理采样 |
| `samplerCube` | 立方体贴图采样器 | 环境贴图、天空盒 |
| `sampler3D` | 3D 纹理采样器 | 体积纹理 |

---

## 2. 变量与常量

### 2.1 变量声明

```glsl
// 局部变量
float local_var = 5.0;

// Uniform 变量（外部参数）
uniform float speed = 1.0;
uniform vec4 color : source_color;

// 常量
const float PI = 3.14159265359;
const int MAX_LIGHTS = 8;
```

### 2.2 内置变量

**Vertex 函数**：
```glsl
void vertex() {
    VERTEX += NORMAL * 0.1;     // 修改顶点位置
    COLOR = vec4(1.0, 0.0, 0.0, 1.0);  // 设置顶点颜色
}
```

**Fragment 函数**：
```glsl
void fragment() {
    COLOR = texture(TEXTURE, UV);  // 设置像素颜色
}
```

---

## 3. 运算符

### 3.1 算术运算符

```glsl
float a = 5.0, b = 2.0;

a + b;    // 加法：7.0
a - b;    // 减法：3.0
a * b;    // 乘法：10.0
a / b;    // 除法：2.5
a % b;    // 取模：1.0
-a;       // 取负：-5.0
```

### 3.2 比较运算符

```glsl
a == b;   // 等于
a != b;   // 不等于
a < b;    // 小于
a > b;    // 大于
a <= b;   // 小于等于
a >= b;   // 大于等于
```

### 3.3 逻辑运算符

```glsl
bool x = true, y = false;

x && y;   // 逻辑与：false
x || y;   // 逻辑或：true
!x;       // 逻辑非：false
```

### 3.4 向量运算

```glsl
vec3 a = vec3(1.0, 2.0, 3.0);
vec3 b = vec3(4.0, 5.0, 6.0);

// 分量运算
vec3 result = a + b;           // vec3(5.0, 7.0, 9.0)

// 点积
float dot_result = dot(a, b);  // 1*4 + 2*5 + 3*6 = 32.0

// 叉积
vec3 cross_result = cross(a, b);

// 归一化
vec3 normalized = normalize(a);

// 长度
float len = length(a);
```

---

## 4. 控制流

### 4.1 条件语句

```glsl
void fragment() {
    if (UV.x > 0.5) {
        COLOR = vec4(1.0, 0.0, 0.0, 1.0);
    } else {
        COLOR = vec4(0.0, 1.0, 0.0, 1.0);
    }
}
```

### 4.2 循环语句

```glsl
void fragment() {
    vec3 color = vec3(0.0);
    
    // for 循环
    for (int i = 0; i < 10; i++) {
        color += vec3(0.1);
    }
    
    // while 循环
    int j = 0;
    while (j < 5) {
        color += vec3(0.05);
        j++;
    }
}
```

### 4.3 ⚠️ 循环限制

- 循环次数必须是**编译时常量**或**有明确上限**
- 避免无限循环
- 移动平台对循环次数有限制

---

## 5. 内置函数

### 5.1 数学函数

| 函数 | 说明 | 示例 |
|------|------|------|
| `sin(x)` | 正弦 | `sin(TIME)` |
| `cos(x)` | 余弦 | `cos(TIME * 2.0)` |
| `tan(x)` | 正切 | `tan(angle)` |
| `asin(x)` | 反正弦 | `asin(value)` |
| `acos(x)` | 反余弦 | `acos(value)` |
| `atan(y, x)` | 反正切 | `atan(UV.y, UV.x)` |
| `pow(x, y)` | 幂运算 | `pow(color, vec3(2.2))` |
| `exp(x)` | 指数 | `exp(value)` |
| `log(x)` | 自然对数 | `log(value)` |
| `sqrt(x)` | 平方根 | `sqrt(distance)` |
| `abs(x)` | 绝对值 | `abs(value)` |
| `sign(x)` | 符号 | `sign(value)` |

### 5.2 范围函数

| 函数 | 说明 | 示例 |
|------|------|------|
| `min(a, b)` | 最小值 | `min(5.0, 3.0)` → 3.0 |
| `max(a, b)` | 最大值 | `max(5.0, 3.0)` → 5.0 |
| `clamp(x, min, max)` | 限制范围 | `clamp(10.0, 0.0, 1.0)` → 1.0 |
| `mix(a, b, t)` | 线性插值 | `mix(0.0, 1.0, 0.5)` → 0.5 |
| `step(edge, x)` | 阶跃函数 | `step(0.5, UV.x)` |
| `smoothstep(edge0, edge1, x)` | 平滑阶跃 | `smoothstep(0.0, 1.0, UV.x)` |

### 5.3 向量函数

| 函数 | 说明 | 示例 |
|------|------|------|
| `length(v)` | 向量长度 | `length(vec3(1,2,2))` → 3.0 |
| `normalize(v)` | 归一化 | `normalize(vec3(1,0,0))` |
| `dot(a, b)` | 点积 | `dot(a, b)` |
| `cross(a, b)` | 叉积（3D） | `cross(a, b)` |
| `reflect(i, n)` | 反射 | `reflect(view, normal)` |
| `refract(i, n, eta)` | 折射 | `refract(view, normal, 1.5)` |
| `faceforward(n, i, ng)` | 面向 | `faceforward(normal, view, normal)` |

### 5.4 纹理函数

```glsl
// 基本采样
texture(tex, uv);

// 带 LOD 采样
textureLod(tex, uv, lod);

// 带偏导采样
textureGrad(tex, uv, dPdx, dPdy);

// 投影采样
textureProj(tex, proj_uv);
```

### 5.5 导数函数（Fragment 中）

| 函数 | 说明 | 用途 |
|------|------|------|
| `dFdx(p)` | x 方向偏导 | 计算梯度 |
| `dFdy(p)` | y 方向偏导 | 计算梯度 |
| `fwidth(p)` | 绝对导数和 | 抗锯齿 |

---

## 6. 渲染模式

### 6.1 常用渲染模式

```glsl
// 不透明无光照
render_mode unshaded, cull_disabled;

// 透明混合
render_mode blend_mix, depth_draw_alpha_prepass;

// 世界坐标顶点
render_mode world_vertex_coords;

// 确保法线正确
render_mode ensure_correct_normals;
```

### 6.2 渲染模式分类

**混合模式**：
- `blend_mix` - Alpha 混合
- `blend_add` - 加法混合
- `blend_sub` - 减法混合
- `blend_mul` - 乘法混合

**剔除模式**：
- `cull_disabled` - 不剔除（双面）
- `cull_clockwise` - 剔除顺时针
- `cull_counter_clockwise` - 剔除逆时针

**深度测试**：
- `depth_draw_alpha_prepass` - 透明预通道
- `depth_draw_never` - 禁用深度测试
- `depth_draw_always` - 总是深度测试

**光照模式**：
- `unshaded` - 无光照
- `vertex_lighting` - 顶点光照
- `diffuse_lambert` - Lambert 漫反射
- `diffuse_toon` - Toon 漫反射
- `specular_schlick_ggx` - Schlick-GGX 高光

---

## 🔗 相关链接

- **Base 层来源**: [10B_Shading_Language.md](../base/shaders/10B_Shading_Language.md)
- **Wiki 概念**: [着色器核心概念](./shader-concepts.md)
- **Wiki 指南**: 
  - [Canvas Item 着色器指南](./canvas-item-shader-guide.md)
  - [Spatial 着色器指南](./spatial-shader-guide.md)

---

**维护者**: Knowledge Base Administrator
