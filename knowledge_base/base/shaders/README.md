# Base 层 - 着色器系统文档

> **最后更新**: 2026-04-07  
> **Godot 版本**: 4.x  
> **文档来源**: Godot 官方文档 + 知识库整合

---

## 📚 文档列表

| 文档 | 描述 | 来源 | 行数 | 重要性 |
|------|------|------|------|--------|
| [10A_Shader_Introduction.md](./10A_Shader_Introduction.md) | **着色器入门** - 着色器概述、类型、处理器函数、创建方法 | `introduction_to_shaders.rst` | ~150 行 | 🔴 必读 |
| [10B_Shading_Language.md](./10B_Shading_Language.md) | **着色器语言参考** - 数据类型、变量、uniforms、内置函数 | `shading_language.rst` | ~300 行 | 🔴 必读 |
| [10C_Canvas_Item_Shader.md](./10C_Canvas_Item_Shader.md) | **Canvas Item 着色器** - 2D 着色器变量和常见效果示例 | 知识库整合 | ~200 行 | 🟡 推荐 |
| [10D_Spatial_Shader.md](./10D_Spatial_Shader.md) | **Spatial 着色器** - 3D 着色器渲染模式、变量、材质参数 | 知识库整合 | ~250 行 | 🟡 推荐 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/shaders/)  
**大小**: ~40 KB  
**文件数**: 4 份

---

## 🎯 核心内容

### 着色器基础
- 着色器是 GPU 上运行的特殊程序
- 并行执行（逐顶点/像素）
- 7 种处理器函数（vertex/fragment/light 等）

### 着色器类型
- `spatial` - 3D 渲染
- `canvas_item` - 2D 渲染
- `particles` - 粒子系统
- `sky` - 天空渲染
- `fog` - 体积雾

### Godot 着色语言
- 基于 GLSL 的简化语言
- 支持数据类型：bool/int/float/uint/向量/矩阵/采样器
- uniforms 用于外部参数传递
- 丰富的内置函数

### Canvas Item 着色器（2D）
- 常用内置变量：UV/VERTEX/COLOR/TIME/TEXTURE
- 常见效果：渐变/波浪/轮廓发光/扭曲/像素化

### Spatial 着色器（3D）
- 渲染模式：unshaded/cull_disabled/blend_mix 等
- Vertex 函数变量：VERTEX/NORMAL/TANGENT/UV
- Fragment 函数变量：ALBEDO/METALLIC/ROUGHNESS/EMISSION
- Light 函数变量：LIGHT/ATTENUATION/DIFFUSE_LIGHT

---

## 📊 Wiki 映射

| Base 层文档 | Wiki 概念页面 | Wiki 指南页面 |
|------------|--------------|--------------|
| 10A_Shader_Introduction.md | shader-concepts.md | - |
| 10B_Shading_Language.md | shading-language-reference.md | - |
| 10C_Canvas_Item_Shader.md | - | canvas-item-shader-guide.md |
| 10D_Spatial_Shader.md | - | spatial-shader-guide.md |

---

## 🔗 相关链接

- [Wiki 概念页面 - 着色器概念](../../wiki/concepts/shader-concepts.md)
- [Wiki 概念页面 - 着色器语言参考](../../wiki/concepts/shading-language-reference.md)
- [Wiki 指南 - Canvas Item 着色器](../../wiki/guides/canvas-item-shader-guide.md)
- [Wiki 指南 - Spatial 着色器](../../wiki/guides/spatial-shader-guide.md)

---

**维护者**: Knowledge Base Administrator
