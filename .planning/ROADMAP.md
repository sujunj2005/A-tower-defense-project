# Roadmap: Life Simulator + Tower Defense

## Milestone v0.1 — 地图系统增强 ✅ COMPLETED

**Date Range:** 2026-04-07 → 2026-04-22
**Commits:** 795200d → df14c55 (11 commits)
**Status:** ✅ All 6 phases completed

| Phase | Description | Status | Evidence Commit |
|-------|-------------|--------|-----------------|
| 01-01 | MapConfig 扩展（era_id、难度参数、目录扫描） | ✅ | 795200d |
| 01-02 | 5 张新地图（school/office/hospital/home/street） | ✅ | ea05fd6 |
| 01-03 | 双层难度系统（全局预设 × 地图参数） | ✅ | 9da54bb |
| 01-04 | 事件驱动地图选择（权重累加 + 时代过滤） | ✅ | 654aa38 |
| 01-05 | SessionData/OptionData 扩展（地图字段） | ✅ | a8fb90c |
| 01-06 | 国际化 + 知识库 + 配置工具 | ✅ | b4db0f9, 41db47d |

### Deliverables

- ✅ 7 张地图（map_01, map_test, map_school, map_office, map_hospital, map_home, map_street）
- ✅ 双层难度系统（3 档全局 × 地图参数化）
- ✅ 事件驱动地图选择（map_weights + force_map_id）
- ✅ 完整 i18n 支持（zh/en）
- ✅ 知识库文档 + 踩坑记录
- ✅ 配置工具更新

### Architecture Decisions (D-01 ~ D-10)

- 地图使用 .tres Resource 格式
- 目录扫描自动注册地图
- 事件选项驱动地图选择
- 全局难度与地图难度乘法叠加
- 地图与时代系统联动（era_id）

---

## Milestone v0.2 — 待规划

**Next steps:**
- [ ] 定义 v0.2 目标（建议：事件系统增强 / 关系系统 / 职业系统）
- [ ] 创建 `.planning/phases/02-*/` 目录
- [ ] 执行 discuss → plan → execute 流程
