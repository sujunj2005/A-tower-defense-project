# Godot 4.x 着色器入门

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/shaders/introduction_to_shaders.rst

---

## 目录

1. [着色器概述](#1-着色器概述)
2. [着色器类型](#2-着色器类型)
3. [处理器函数](#3-处理器函数)
4. [创建着色器](#4-创建着色器)

---

## 1. 着色器概述

### 1.1 什么是着色器

着色器是在 GPU（图形处理单元）上运行的**特殊程序**，用于控制几何体和像素的绘制方式。

### 1.2 特点

- **并行执行**：GPU 可以同时运行数千条指令
- **逐顶点/像素运行**：每个顶点和像素独立处理
- **无法跨帧存储数据**：不能在帧之间保存状态
- **编程思维不同**：需要与传统编程不同的思维方式

### 1.3 示例对比

```gdscript
# GDScript - 串行处理
for x in range(width):
    for y in range(height):
        set_color(x, y, some_color)

# 着色器 - 并行处理（每个像素自动执行）
void fragment() {
    COLOR = some_color;
}
```

---

## 2. 着色器类型

Godot 使用基于 GLSL 的简化着色语言：

| shader_type | 用途 |
|-------------|------|
| `spatial` | 3D 渲染 |
| `canvas_item` | 2D 渲染 |
| `particles` | 粒子系统 |
| `sky` | 天空渲染 |
| `fog` | 体积雾 |

```glsl
shader_type spatial;      // 3D
shader_type canvas_item;  // 2D
```

---

## 3. 处理器函数

Godot 着色器有 7 个处理器函数：

| 函数 | 运行时机 | 适用类型 |
|------|----------|----------|
| `vertex()` | 每个顶点 | spatial, canvas_item |
| `fragment()` | 每个像素 | spatial, canvas_item |
| `light()` | 每个像素×每个光源 | spatial, canvas_item |
| `start()` | 粒子生成时 | particles |
| `process()` | 每帧每个粒子 | particles |
| `sky()` | 天空渲染时 | sky |
| `fog()` | 体积雾体素 | fog |

> **踩坑点**：`light()` 函数在以下情况不运行：
> - 启用了 `vertex_lighting` 渲染模式
> - 项目设置中启用了 Force Vertex Shading（移动平台默认启用）

---

## 4. 创建着色器

### 4.1 在编辑器中创建

1. 创建 Shader 资源
2. 选择 shader_type
3. 编写着色器代码

### 4.2 基础示例

```glsl
// 2D 着色器 - 纯色
shader_type canvas_item;

void fragment() {
    COLOR = vec4(1.0, 0.0, 0.0, 1.0);  // 红色
}

// 2D 着色器 - 渐变
shader_type canvas_item;

uniform vec4 color_from : source_color;
uniform vec4 color_to : hint_color;

void fragment() {
    COLOR = mix(color_from, color_to, UV.x);
}
```

### 4.3 应用到节点

将 Shader 材质赋值给节点的 Material 属性。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/shaders/introduction_to_shaders.rst`
