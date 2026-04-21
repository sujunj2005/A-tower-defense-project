# 图片资源导入指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 15C_Importing_Images.md](../../base/assets-and-io/15C_Importing_Images.md)  
> **重要性**: 🟡 推荐 - 2D/3D 纹理导入规范

---

## 📋 概述

Godot 支持多种图片格式，并提供了丰富的导入选项。正确的导入设置可以优化游戏性能和画质。

---

## 🎯 导入设置

### 1. 2D 纹理设置

```
导入选项:
- Filter: 启用过滤（平滑缩放）
- Repeat: 重复纹理
- Compress: 压缩（减少内存）
- HDR: 高动态范围
```

### 2. 3D 纹理设置

```
导入选项:
- Normal Map: 法线贴图
- Roughness: 粗糙度通道
- Metallic: 金属度通道
- AO: 环境光遮蔽
```

### 3. 精灵表设置

```
导入选项:
- Detect 3D: 检测深度图
- Slice: 切割精灵表
- Animation: 创建动画
```

---

## 🔧 实战技巧

### 1. 批量导入

```gdscript
# 在编辑器中右键 → 批量重新导入
# 或使用命令行
# godot --reimport
```

### 2. 纹理优化

```
优化建议:
- 使用 2 的幂次尺寸（256x256, 512x512）
- 启用压缩（VRAM 压缩）
- 适当降低分辨率（移动端）
```

---

## 🔗 相关资源

### Base 层
- [15C_Importing_Images.md](../../base/assets-and-io/15C_Importing_Images.md) - 图片导入详解

### Wiki 层
- [文件系统指南](../guides/filesystem-guide.md) - 文件操作基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
