# Godot 4.x Canvas Item 着色器

> 适用版本：Godot 4.x | 来源：知识库整合

---

## 目录

1. [Canvas Item 着色器概述](#1-canvas-item-着色器概述)
2. [常用内置变量](#2-常用内置变量)
3. [常见效果示例](#3-常见效果示例)

---

## 1. Canvas Item 着色器概述

`shader_type canvas_item` 用于 2D 渲染，可应用于 Sprite2D、Line2D、Polygon2D 等。

---

## 2. 常用内置变量

| 变量 | 类型 | 说明 |
|------|------|------|
| `UV` | `vec2` | 当前像素的 UV 坐标 |
| `VERTEX` | `vec2` | 当前顶点的位置 |
| `COLOR` | `vec4` | 当前像素的颜色 |
| `TIME` | `float` | 自场景开始的时间（秒） |
| `ATLAS_TEXTURE` | `sampler2D` | 图集纹理 |
| `TEXTURE` | `sampler2D` | 节点纹理 |
| `POINT_SIZE` | `float` | 点大小（Point2D） |

---

## 3. 常见效果示例

### 3.1 渐变背景
```glsl
shader_type canvas_item;

uniform vec4 from_color : source_color;
uniform vec4 to_color : source_color;

void fragment() {
    COLOR = mix(from_color, to_color, UV.x);
}
```

### 3.2 波浪效果
```glsl
shader_type canvas_item;

uniform float amplitude : hint_range(0, 100) = 10.0;
uniform float frequency : hint_range(0, 50) = 5.0;

void vertex() {
    VERTEX.y += sin(VERTEX.x * frequency + TIME * 3.0) * amplitude;
}
```

### 3.3 轮廓发光
```glsl
shader_type canvas_item;

uniform vec4 outline_color : source_color;
uniform float outline_size : hint_range(0, 10) = 2.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * outline_size;
    float outline = texture(TEXTURE, UV - size).a + texture(TEXTURE, UV + size).a;
    outline -= texture(TEXTURE, UV).a;
    COLOR = mix(outline_color, COLOR, step(0.01, outline));
}
```

### 3.4 扭曲效果
```glsl
shader_type canvas_item;

uniform float strength : hint_range(0, 10) = 1.0;

void fragment() {
    float offset = (UV.y - 0.5) * strength;
    UV.x += offset;
    COLOR = texture(TEXTURE, UV);
}
```

### 3.5 像素化效果
```glsl
shader_type canvas_item;

uniform float pixel_size : hint_range(1, 32) = 8.0;

void fragment() {
    vec2 pixelated_uv = floor(UV * pixel_size) / pixel_size;
    COLOR = texture(TEXTURE, pixelated_uv);
}
```

---
*更多效果请查看 Godot 官方着色器示例。*
