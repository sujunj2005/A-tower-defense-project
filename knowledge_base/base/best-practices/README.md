# Base 层 - 最佳实践（精简速查版）

**位置**: `base/best-practices/`

**来源**: Godot 官方文档 + 实战经验  
**最后更新**: 2026-04-07  
**文档数**: 6 份

> **📚 版本说明**：  
> - 📙 **精简速查版**（本目录）：适合快速查阅核心要点  
> - 📘 **完整深度版**：需要系统学习？查看 [code-standards 目录](../practical-experiences/code-standards/)

---

## 📄 文档列表

### 通用最佳实践

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [16A_Scene_Organization.md](./16A_Scene_Organization.md) | **场景组织** - 场景结构设计、节点组织 | 🔴 必读 |
| [16B_Data_Preferences.md](./16B_Data_Preferences.md) | **数据偏好** - 数据驱动设计、资源配置 | 🟡 推荐 |
| [16C_Logic_Preferences.md](./16C_Logic_Preferences.md) | **逻辑偏好** - 代码组织、逻辑分离 | 🟡 推荐 |

### 大型项目避坑速查（🆕 精简版）

| 文档 | 描述 | 版本 | 完整版链接 |
|------|------|------|-----------|
| [20A_Godot_Large_Project_Pitfalls_Deep_Dive.md](./20A_Godot_Large_Project_Pitfalls_Deep_Dive.md) | **大型项目深度避坑指南（精简速查版）** | v1.0 | [完整深度版](../practical-experiences/code-standards/20A_Godot_Large_Project_Pitfalls_Deep_Dive.md) |
| [20B_Godot_Pitfalls_Verification_Guidelines.md](./20B_Godot_Pitfalls_Verification_Guidelines.md) | **避坑验证准则（精简指南版）** | v1.0 | [完整系统版](../practical-experiences/code-standards/20B_Godot_Pitfalls_Verification_Guidelines.md) |
| [20C_Godot_Best_Practices_Quick_Reference.md](./20C_Godot_Best_Practices_Quick_Reference.md) | **最佳实践速查（精简速查版）** | v1.0 | [详细实践版](../practical-experiences/code-standards/20C_Godot_Best_Practices_Quick_Reference.md) |

---

## 📊 统计信息

- **文档总数**: 6 份（3 份通用 + 3 份速查）
- **总字数**: ~45,000+
- **适用版本**: Godot 4.x

---

## 🎯 核心内容

### 场景组织
- 场景拆分原则
- 节点层级设计
- 场景复用技巧
- 预制件使用

### 数据偏好
- 数据驱动设计
- 自定义资源
- 配置数据分离
- 数据表管理

### 逻辑偏好
- 代码组织模式
- 逻辑与表现分离
- 组件化设计
- 代码复用技巧

### 大型项目避坑（速查）
- 负向缩放翻转问题
- Position vs Offset 混淆
- preload 内存管理
- 屏幕外性能优化
- 分辨率与缩放设置
- 静态类型使用
- .tres 文件注释问题

---

## 🔗 Wiki 层映射

- 指南页面：*待创建* - Godot 最佳实践指南

---

**维护者**: Knowledge Base Administrator
