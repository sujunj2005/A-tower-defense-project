# Godot 4.x 知识库 Wiki

> **版本**: 1.3 | **最后更新**: 2026-04-11 | **适用 Godot 版本**: 4.x（4.6+）

---

## 📚 欢迎使用 Godot 知识库 Wiki

本 Wiki 是基于实战经验整理的结构化知识集合，旨在帮助开发者快速掌握 Godot 4.x 游戏开发的核心技能和最佳实践。

---

## 🎯 快速导航

### 按知识类别浏览

| 类别 | 说明 | 文档数 |
|------|------|--------|
| [实体页面](./entities/) | 游戏实体详解（Enemy, Tower, Projectile 等） | 4 |
| [概念页面](./concepts/) | 核心概念和系统（攻击系统、移动系统等） | 26 |
| [指南页面](./guides/) | 开发指南和教程（快速入门、优化指南等） | 23 |
| [对比分析](./comparisons/) | 技术方案对比（攻击方式对比、加载方式对比等） | 3 |
| [概述页面](./overviews/) | 领域概述和导论 | 3 |

---

## 🔥 热门主题

### 新手必读

1. **[开发快速入门](./guides/gdscript-static-typing.md)** - GDScript 静态类型入门
2. **[GDScript 代码规范](./concepts/gdscript-standards.md)** - 编写高质量 GDScript 代码
3. **[常见踩坑避雷](./guides/common-pitfalls.md)** - 39 个常见陷阱及解决方案

### 进阶提升

1. **[塔防游戏架构设计](./guides/tower-defense-architecture.md)** - 完整的游戏架构案例
2. **[性能优化实战](./guides/performance-optimization-guide.md)** - CPU/GPU 优化技巧
3. **[攻击系统设计](./concepts/attack-system.md)** - 近战/远程攻击实现

---

## 📖 知识体系

### 基础层（Base Layer）

我们的知识建立在以下原始资料基础上：

- **Godot 官方文档** - 完整的技术参考和教程
- **实战经验汇编** - 来自 tower_defense 项目的第一手经验
  - 踩坑案例（8 份文档）
  - 代码规范（1 份文档）
  - 案例研究（1 份文档）
  - 优化技巧（3 份文档）

### Wiki 层（Wiki Layer）

基于 Base 层资料整理而成的结构化知识：

- **实体页面** - 具体游戏对象的详细说明
- **概念页面** - 抽象概念和系统架构
- **指南页面** - 操作指南和最佳实践
- **对比分析** - 不同技术方案的对比
- **概述页面** - 领域知识的整体概览

### 架构层（Architecture Layer）

[查看完整索引和日志](../architecture/)

---

## 🎓 学习路径推荐

### 初级开发者（0-6 个月）

```
1. [开发快速入门](./guides/gdscript-static-typing.md)
   ↓
2. [GDScript 代码规范](./concepts/gdscript-standards.md)
   ↓
3. [常见踩坑避雷](./guides/common-pitfalls.md)
   ↓
4. [核心概念学习](./concepts/) - 选择感兴趣的系统深入学习
```

### 中级开发者（6-12 个月）

```
1. [塔防游戏架构](./guides/tower-defense-architecture.md)
   ↓
2. [性能优化实战](./guides/performance-optimization-guide.md)
   ↓
3. [专题研究](./concepts/) - 根据项目需求选择
```

### 高级开发者（1 年+）

```
1. [对比分析](./comparisons/) - 技术方案选型参考
   ↓
2. [实战案例](./guides/tower-defense-architecture.md) - 架构设计参考
   ↓
3. [贡献知识](../architecture/log.md) - 分享经验，反哺社区
```

---

## 📊 知识地图

```
Godot 4.x 游戏开发
│
├─ 核心系统
│  ├─ 节点系统
│  ├─ 场景树
│  ├─ 资源管理
│  └─ 信号机制
│
├─ 游戏实体
│  ├─ 敌人 (Enemy)
│  ├─ 防御塔 (Tower)
│  ├─ 子弹/投射物 (Projectile)
│  └─ 玩家 (Player)
│
├─ 功能系统
│  ├─ 攻击系统
│  ├─ 移动系统
│  ├─ 经济系统
│  ├─ UI 系统
│  └─ 存档系统
│
├─ 性能优化
│  ├─ CPU 优化
│  ├─ GPU 优化
│  └─ 内存管理
│
└─ 最佳实践
   ├─ 代码规范
   ├─ 设计模式
   └─ 踩坑记录
```

---

## 🔍 使用技巧

### 搜索知识

1. **按关键词搜索**: 使用 IDE 的全局搜索功能（Ctrl+Shift+F）
2. **按类别浏览**: 通过上方的分类导航快速定位
3. **查看索引**: [完整索引](../architecture/index.md) 提供所有页面的详细列表

### 引用资料

所有 Wiki 页面都标注了资料来源，确保知识的可追溯性：
- 引用官方文档时会注明来源路径
- 引用实战经验时会标注来自哪个案例

### 持续更新

知识库持续更新中，查看 [更新日志](../architecture/log.md) 了解最新动态。

---

## 🤝 贡献指南

欢迎贡献知识！贡献方式：
1. 发现新问题 → 记录到踩坑案例
2. 总结新经验 → 添加到最佳实践
3. 完成新项目 → 整理为案例研究

---

## 📞 相关资源

- **Base 层（原始资料）**: [../base/](../base/)
- **Architecture 层（索引和日志）**: [../architecture/](../architecture/)
- **原始知识库**: [../../knowledge_base/](../../knowledge_base/)

---

**最后更新**: 2026-04-11（资源引用与数据一致性踩坑 + 编码规范第14章同步）  
**维护者**: Knowledge Base Administrator  
**许可**: MIT
