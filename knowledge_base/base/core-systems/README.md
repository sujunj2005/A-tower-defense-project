# Base 层 - Godot 核心系统文档

> **最后更新**: 2026-04-07  
> **来源**: Godot 官方文档  
> **适用版本**: Godot 4.x

---

## 📚 文档概述

本目录包含 Godot 4.x 核心系统的原始文档，是 Wiki 层相关知识页面的信息来源。

---

## 📄 文档列表

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [02A_Node_Operations.md](./02A_Node_Operations.md) | 节点操作与场景实例化 | `nodes_and_scene_instances.rst` | 🔴 必读 |
| [02B_Scene_Tree.md](./02B_Scene_Tree.md) | 场景树系统 | `scene_tree.rst` | 🔴 必读 |
| [02C_Resources.md](./02C_Resources.md) | 资源系统 | `resources.rst` | 🔴 必读 |
| [02D_Autoload_Singletons.md](./02D_Autoload_Singletons.md) | 自动加载单例 | `singletons_autoload.rst` | 🔴 必读 |

---

## 📊 统计信息

| 项目 | 数值 |
|------|------|
| 文档总数 | 4 份 |
| 来源 | Godot 官方文档 |
| 总字数 | ~15,000+ |
| Wiki 层映射页面 | 4 页 |

---

## 🔗 Wiki 层映射

这些 Base 层文档已整合到 Wiki 层：

### 概念页面 (concepts/)

| Wiki 页面 | Base 层来源 | 描述 |
|----------|------------|------|
| [scene-tree.md](../../wiki/concepts/scene-tree.md) | [02B_Scene_Tree.md](./02B_Scene_Tree.md) | 场景树概念 |
| [resources-system.md](../../wiki/concepts/resources-system.md) | [02C_Resources.md](./02C_Resources.md) | 资源系统概念 |
| [autoload-singletons.md](../../wiki/concepts/autoload-singletons.md) | [02D_Autoload_Singletons.md](./02D_Autoload_Singletons.md) | 单例模式概念 |

### 指南页面 (guides/)

| Wiki 页面 | Base 层来源 | 描述 |
|----------|------------|------|
| [node-operations-guide.md](../../wiki/guides/node-operations-guide.md) | [02A_Node_Operations.md](./02A_Node_Operations.md) | 节点操作指南 |

---

## 🎯 使用建议

### 学习路径

```
1. [场景树](./02B_Scene_Tree.md) - 理解 Godot 的节点树结构
   ↓
2. [节点操作](./02A_Node_Operations.md) - 学习如何获取/创建/删除节点
   ↓
3. [资源系统](./02C_Resources.md) - 理解数据容器和资源共享
   ↓
4. [自动加载单例](./02D_Autoload_Singletons.md) - 实现跨场景全局状态
```

### 快速查找

- **获取节点**: [02A_Node_Operations.md](./02A_Node_Operations.md#1-获取节点)
- **场景切换**: [02B_Scene_Tree.md](./02B_Scene_Tree.md#5-切换场景)
- **加载资源**: [02C_Resources.md](./02C_Resources.md#3-加载资源)
- **创建单例**: [02D_Autoload_Singletons.md](./02D_Autoload_Singletons.md#2-创建-autoload)

---

## ⚠️ 注意事项

1. **Base 层是不可变的原始信息源**，不要直接修改本文档
2. 所有 Wiki 层页面都应该引用 Base 层来源
3. 发现错误应追溯到原始 Godot 文档进行验证

---

## 🔗 相关链接

- **Base 层首页**: [../](../)
- **Wiki 层首页**: [../../wiki/](../../wiki/)
- **Architecture 层索引**: [../../architecture/index.md](../../architecture/index.md)

---

**维护者**: Knowledge Base Administrator  
**文档版本**: 1.0
