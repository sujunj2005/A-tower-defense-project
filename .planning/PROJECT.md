# Project: Life Simulator + Tower Defense Hybrid

**Engine:** Godot 4.6 (GL Compatibility)
**Platform:** PC (Windows/macOS/Linux)
**Start Date:** 2026-04-07
**Current Version:** v0.1.0

## Project Description

融合 BitLife 式文字人生模拟与塔防战斗的混合品类游戏。玩家通过事件选择驱动人生进程，事件结果影响战斗地图选择、难度和波次配置，形成"人生选择→战斗挑战→成长反馈"的核心循环。

## Core Architecture

```
Life Simulation Layer
├── Era System       — 时代背景（中国古代/现代等）
├── Age System       — 年龄推进与阶段划分
├── Event System     — 事件触发、选择、连锁
├── Option System    — 选项处理与后果应用
├── Attribute System — 五维属性（快乐/健康/智力/外貌/业力）
├── Trait System     — 特质过滤与事件权重修正
└── Ending System    — 结局判定与人生总结

Tower Defense Layer
├── Map System       — 多地图、地形、难度系统
├── Wave System      — 波次管理、敌人生成
├── Tower System     — 防御塔配置、攻击、升级
├── Economy System   — 金币经济
├── Effect System    — 特效系统（穿透、减速等）
└── Battle Rating    — 战斗评分与结算

Meta Progression Layer
├── Currency Manager  — 跨局货币管理
├── Unlock System     — 解锁树
└── Achievement System — 成就系统
```

## Key Decisions

- **D-01:** 地图数据使用 .tres Resource 格式，支持复杂嵌套结构
- **D-02:** 地图注册改为目录扫描，新增地图只需放置文件
- **D-03:** 事件选项携带 map_weights 驱动地图选择
- **D-07:** 双层难度：全局预设 × 地图参数
- **D-10:** 全局与地图难度倍率乘法叠加

## Current State

- ✅ **Milestone v0.1** (地图系统增强) — 已完成
- 📋 **Milestone v0.2** — 待规划
