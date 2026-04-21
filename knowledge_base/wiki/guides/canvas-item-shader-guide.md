# Canvas Item 着色器实战指南

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.6+  
> **来源**: [10C_Canvas_Item_Shader.md](../base/shaders/10C_Canvas_Item_Shader.md)

---

## 📚 目录

1. [Canvas Item 着色器概述](#1-canvas-item-着色器概述)
2. [内置变量详解](#2-内置变量详解)
3. [渐变效果](#3-渐变效果)
4. [波浪和扭曲效果](#4-波浪和扭曲效果)
5. [轮廓和发光效果](#5-轮廓和发光效果)
6. [像素化和后期处理](#6-像素化和后期处理)
7. [实战案例](#7-实战案例)

---

## 1. Canvas Item 着色器概述

### 1.1 什么是 Canvas Item 着色器

`shader_type canvas_item` 是 Godot 中用于**2D 渲染**的着色器类型，可应用于：
- Sprite2D
- Line2D
- Polygon2D
- Control 节点（ColorRect、TextureRect 等）
- ParticleProcessMaterial

### 1.2 基本结构

```glsl
shader_type canvas_item;

// 定义 uniforms
uniform vec4 color : source_color;
uniform float speed = 1.0;

void vertex() {
    // 顶点处理（可选）
}

void fragment() {
    // 像素处理（必需）
    COLOR = vec4(1.0, 0.0, 0.0, 1.0);  // 红色
}
```

---

## 2. 内置变量详解

### 2.1 Fragment 函数可用变量

| 变量 | 类型 | 说明 | 读写 |
|------|------|------|------|
| `UV` | vec2 | 当前像素的 UV 坐标（0-1） | 可读写 |
| `VERTEX` | vec2 | 当前顶点的位置 | 可读写 |
| `COLOR` | vec4 | 当前像素的颜色 | 可读写 |
| `TIME` | float | 自场景开始的时间（秒） | 只读 |
| `TEXTURE` | sampler2D | 节点纹理 | 只读 |
| `ATLAS_TEXTURE` | sampler2D | 图集纹理 | 只读 |
| `TEXTURE_PIXEL_SIZE` | vec2 | 纹理像素大小 | 只读 |
| `SCREEN_UV` | vec2 | 屏幕 UV 坐标 | 只读 |
| `SCREEN_TEXTURE` | sampler2D | 屏幕纹理 | 只读 |

### 2.2 使用示例

```glsl
void fragment() {
    // 获取纹理颜色
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 使用 UV 坐标
    vec3 gradient = vec3(UV.x, UV.y, 0.0);
    
    // 使用时间
    float wave = sin(TIME * 2.0);
    
    COLOR = tex_color;
}
```

---

## 3. 渐变效果

### 3.1 线性渐变

```glsl
shader_type canvas_item;

uniform vec4 from_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 to_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);

void fragment() {
    // 水平渐变
    COLOR = mix(from_color, to_color, UV.x);
}
```

### 3.2 径向渐变

```glsl
shader_type canvas_item;

uniform vec4 center_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // 计算到中心的距离
    float dist = length(UV - vec2(0.5));
    
    // 径向渐变
    COLOR = mix(center_color, edge_color, dist * 2.0);
}
```

### 3.3 彩虹渐变

```glsl
shader_type canvas_item;

void fragment() {
    // HSV to RGB 转换
    vec3 hsv = vec3(UV.x * 6.0, 1.0, 1.0);
    vec3 rgb = hsv2rgb(hsv);
    
    COLOR = vec4(rgb, 1.0);
}

vec3 hsv2rgb(vec3 hsv) {
    vec3 p = abs(fract(hsv.xxx + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
    return hsv.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), hsv.y);
}
```

---

## 4. 波浪和扭曲效果

### 4.1 波浪效果（顶点着色器）

```glsl
shader_type canvas_item;

uniform float amplitude : hint_range(0, 100) = 10.0;
uniform float frequency : hint_range(0, 50) = 5.0;
uniform float speed = 3.0;

void vertex() {
    // 修改顶点的 Y 位置
    VERTEX.y += sin(VERTEX.x * frequency + TIME * speed) * amplitude;
}
```

### 4.2 水波扭曲（片段着色器）

```glsl
shader_type canvas_item;

uniform float strength : hint_range(0, 10) = 1.0;
uniform float speed = 2.0;

void fragment() {
    // 创建扭曲效果
    float offset = sin(UV.y * 10.0 + TIME * speed) * strength * 0.01;
    UV.x += offset;
    
    COLOR = texture(TEXTURE, UV);
}
```

### 4.3 热浪扭曲

```glsl
shader_type canvas_item;

uniform float distortion_strength : hint_range(0, 10) = 2.0;
uniform float speed = 5.0;

void fragment() {
    vec2 uv_offset = UV;
    
    // 多层噪声叠加
    float noise1 = sin(UV.y * 20.0 + TIME * speed) * 0.5;
    float noise2 = sin(UV.y * 30.0 - TIME * speed * 0.7) * 0.25;
    
    uv_offset.x += (noise1 + noise2) * distortion_strength * 0.01;
    
    COLOR = texture(TEXTURE, uv_offset);
}
```

---

## 5. 轮廓和发光效果

### 5.1 轮廓效果

```glsl
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_size : hint_range(0, 10) = 2.0;

void fragment() {
    vec2 ps = TEXTURE_PIXEL_SIZE * outline_size;
    
    // 采样周围像素的 alpha
    float outline = texture(TEXTURE, UV - ps).a + 
                    texture(TEXTURE, UV + ps).a +
                    texture(TEXTURE, UV + vec2(ps.x, -ps.y)).a +
                    texture(TEXTURE, UV + vec2(-ps.x, ps.y)).a;
    
    outline -= texture(TEXTURE, UV).a * 4.0;
    
    // 混合轮廓色和原色
    COLOR = mix(outline_color, texture(TEXTURE, UV), step(0.01, outline));
}
```

### 5.2 发光效果（Glow）

```glsl
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float glow_strength : hint_range(0, 10) = 3.0;
uniform float glow_radius : hint_range(1, 20) = 5.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;
    
    // 简单的发光效果
    vec2 ps = TEXTURE_PIXEL_SIZE;
    float glow = 0.0;
    
    for (float x = -glow_radius; x <= glow_radius; x++) {
        for (float y = -glow_radius; y <= glow_radius; y++) {
            glow += texture(TEXTURE, UV + vec2(x, y) * ps).a;
        }
    }
    
    glow = glow / (glow_radius * glow_radius * 4.0 + 1.0);
    glow *= glow_strength;
    
    COLOR = mix(glow_color, tex_color, alpha);
    COLOR.rgb += glow_color.rgb * glow;
}
```

### 5.3 描边效果（距离场）

```glsl
shader_type canvas_item;

uniform vec4 stroke_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float stroke_width : hint_range(0, 10) = 2.0;

void fragment() {
    float dist = texture(TEXTURE, UV).a;
    float edge = smoothstep(0.5 - stroke_width * 0.01, 0.5 + stroke_width * 0.01, dist);
    
    COLOR = mix(stroke_color, texture(TEXTURE, UV), edge);
}
```

---

## 6. 像素化和后期处理

### 6.1 像素化效果

```glsl
shader_type canvas_item;

uniform float pixel_size : hint_range(1, 32) = 8.0;

void fragment() {
    // 将 UV 坐标离散化
    vec2 pixelated_uv = floor(UV * pixel_size) / pixel_size;
    
    COLOR = texture(TEXTURE, pixelated_uv);
}
```

### 6.2 灰度效果

```glsl
shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 计算亮度
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    COLOR = vec4(vec3(gray), tex_color.a);
}
```

### 6.3 反色效果

```glsl
shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 反色
    COLOR = vec4(1.0 - tex_color.rgb, tex_color.a);
}
```

### 6.4 色相旋转

```glsl
shader_type canvas_item;

uniform float hue_rotation : hint_range(0, 6.28) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // RGB to HSV
    vec3 hsv = rgb2hsv(tex_color.rgb);
    
    // 旋转色相
    hsv.x += hue_rotation;
    
    // HSV to RGB
    COLOR = vec4(hsv2rgb(hsv), tex_color.a);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

---

## 7. 实战案例

### 7.1 闪烁效果

```glsl
shader_type canvas_item;

uniform float blink_speed = 5.0;
uniform float blink_intensity : hint_range(0, 1) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 使用 sin 函数创建闪烁
    float blink = sin(TIME * blink_speed) * 0.5 + 0.5;
    blink = mix(1.0 - blink_intensity, 1.0, blink);
    
    COLOR = tex_color * blink;
}
```

### 7.2 溶解效果

```glsl
shader_type canvas_item;

uniform float dissolve_amount : hint_range(0, 1) = 0.0;
uniform float edge_softness : hint_range(0, 1) = 0.1;
uniform vec4 edge_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 使用 UV.y 作为溶解进度
    float dissolve = smoothstep(dissolve_amount - edge_softness, 
                                dissolve_amount + edge_softness, UV.y);
    
    // 边缘发光
    float edge = smoothstep(dissolve_amount - edge_softness * 2.0,
                           dissolve_amount, UV.y);
    edge *= smoothstep(dissolve_amount, dissolve_amount + edge_softness * 2.0, UV.y);
    
    COLOR = mix(edge_color, tex_color, dissolve);
    COLOR.rgb += edge_color.rgb * edge * 2.0;
}
```

### 7.3 扫描线效果

```glsl
shader_type canvas_item;

uniform float scanline_speed = 1.0;
uniform float scanline_intensity : hint_range(0, 1) = 0.3;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 创建扫描线
    float scanline = sin(UV.y * 100.0 - TIME * scanline_speed) * 0.5 + 0.5;
    scanline = mix(1.0 - scanline_intensity, 1.0, scanline);
    
    COLOR = tex_color * scanline;
}
```

### 7.4 护盾效果

```glsl
shader_type canvas_item;

uniform vec4 shield_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float shield_strength : hint_range(0, 1) = 0.5;
uniform float pulse_speed = 2.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 脉冲效果
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    
    // 混合护盾色
    vec3 shield = mix(tex_color.rgb, shield_color.rgb, shield_strength * pulse);
    
    COLOR = vec4(shield, tex_color.a);
}
```

---

## 🔗 相关链接

- **Base 层来源**: [10C_Canvas_Item_Shader.md](../base/shaders/10C_Canvas_Item_Shader.md)
- **Wiki 概念**: 
  - [着色器核心概念](./shader-concepts.md)
  - [着色器语言参考](./shading-language-reference.md)
- **Wiki 指南**: [Spatial 着色器指南](./spatial-shader-guide.md)

---

**维护者**: Knowledge Base Administrator
