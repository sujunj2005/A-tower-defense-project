# Godot 渲染系统（Base 目录）

## 📚 说明

本目录收录 Godot 4.x 渲染系统相关的官方文档和实战资料，作为渲染知识的原始信息源。

## 📦 当前收录

### 渲染基础文档
- **位置**: `./`
- **文档列表**:
  - [09A_Rendering_Basics.md](./09A_Rendering_Basics.md) - 渲染基础（多分辨率支持/拉伸模式/视口）
- **来源**: Godot 官方文档 (godot-docs-master/tutorials/rendering/)
- **大小**: ~5 KB
- **文件数**: 1 份

## 🎯 内容概览

### 1. 渲染器概述
- Forward+ / Mobile / Compatibility 三种渲染器
- 渲染器选择和适用平台

### 2. 多分辨率支持
- 基础窗口大小设置
- 运行时修改分辨率
- 显示器分辨率注意事项

### 3. 拉伸模式（Stretch Mode）
- **Disabled**: 不拉伸，1 单位=1 像素
- **Canvas Items**: 2D 元素直接拉伸，3D 不受影响
- **Viewport**: 先渲染到基础分辨率再拉伸，像素艺术推荐

### 4. 拉伸纵横比（Stretch Aspect）
- **Ignore**: 忽略纵横比，可能变形
- **Keep**: 保持纵横比，黑边
- **Keep Width**: 保持宽度，GUI/HUD 推荐
- **Keep Height**: 保持高度，横版卷轴游戏推荐
- **Expand**: 灵活扩展，最常用

### 5. 视口（Viewport）
- Viewport 节点使用
- 视口属性和应用场景
- 小地图/镜子效果/分屏游戏

## 🎮 常见配置推荐

### 像素艺术游戏
```
基础分辨率：320×180 或 640×360
拉伸模式：viewport
拉伸纵横比：keep 或 expand
缩放模式：integer
```

### 现代 2D 游戏
```
基础分辨率：1920×1080
拉伸模式：canvas_items
拉伸纵横比：expand
```

### 移动游戏
```
基础分辨率：1280×720
拉伸模式：canvas_items
拉伸纵横比：expand
```

## 📝 更新策略

- 定期从官方 godot-docs master 分支同步
- 新增渲染相关教程时补充
- 与项目使用的 Godot 版本保持同步

## 🔗 相关链接

- **Wiki 层**: [../../wiki/concepts/rendering-basics.md](../../wiki/concepts/rendering-basics.md) - 渲染基础概念摘要
- **官方文档**: https://docs.godotengine.org/en/stable/tutorials/rendering/index.html
- **中文翻译**: https://github.com/godotengine/godot-docs-zh

---

**最后更新**: 2026-04-07  
**文档版本**: Godot 4.x  
**维护者**: Knowledge Base Administrator
