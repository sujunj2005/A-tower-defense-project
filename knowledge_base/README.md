# Godot 4.x GDScript 知识库

> **结构更新**：2026-11-27  
> **主索引**：[按主题查找](./index.md)

## 知识库层级

**来源 → 整理 → 项目结论**

| 层级 | 目录 | 查什么 |
| --- | --- | --- |
| 来源 | `base/` | Godot 官方文档镜像、专题基础资料和原始复盘。 |
| 整理 | `cases/`、`wiki/` | 案例分析、概念、指南和主题关联。 |
| 项目结论 | `outline/` | TestMCP 的已核对约定、实现限制和验证结果。正文保留证据入口。 |

首页、主索引和关系图负责导航。`archive/` 保存历史记录。

```text
knowledge_base/
├── README.md          # 首页
├── index.md           # 主索引与引用入口
├── base/              # 来源
├── cases/             # 整理：案例分析
├── wiki/              # 整理：概念、指南与关联
├── outline/           # 项目结论，含关系图与踩坑索引
└── archive/           # 历史记录
```

## 快速导航

| 需求 | 入口 |
| --- | --- |
| 测试 | [运行方式、基线和回归用例](./index.md#testing) |
| 事件 | [筛选、选项结算和事件链](./index.md#events) |
| 项目规范 | [Godot 编码规范汇总](./outline/Godot%20编码规范汇总.md) |
| 常见踩坑 | [踩坑总索引](./outline/踩坑记录完整索引.md) |
| 来源与整理 | [Base 资料目录](./base/index.md) · [Wiki 首页](./wiki/README.md) |
| 层级与主题关联 | [知识关系图](./outline/relationship-map.md) |

---

> **维护者**: Knowledge Base Administrator
> **基于**: Godot 4.6+ 官方文档
