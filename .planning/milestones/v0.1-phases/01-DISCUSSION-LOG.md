# Phase 1: 地图系统增强 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-22
**Phase:** 01-地图系统增强
**Areas discussed:** 地图数据架构, 难度系统

---

## 地图数据架构

### 数据格式

| Option | Description | Selected |
|--------|-------------|----------|
| JSON | 与项目其他数据一致，config_tool 已支持 | |
| 继续 .tres Resource | 地图数据含大量嵌套结构，不适合 xlsx 表格化 | ✓ |
| 混合方式 | 简单用 JSON，复杂用 .tres | |

**User's choice:** 继续 .tres Resource
**Notes:** 用户指出 config_tool 正是因为无法妥善处理地图数据（单 KV 结构、列数太多）才使用 Resource 格式

### 地图注册方式

| Option | Description | Selected |
|--------|-------------|----------|
| 目录扫描 | 扫描 res://resources/maps/ 自动注册 | ✓ |
| 继续硬编码 | 在 _static_init() 添加条目 | |
| 注册表文件 | maps_registry.json 列出地图 | |

**User's choice:** 目录扫描
**Notes:** 用户支持注册表方式，但指出本游戏地图由事件选项决定而非玩家自由选择

### 事件→地图关联机制

| Option | Description | Selected |
|--------|-------------|----------|
| 事件选项直接指定 map_id | 选项携带 {map_id: weight} 权重配置 | ✓ |
| 标签匹配随机选择 | 选项指定难度/主题标签，地图系统匹配 | |
| 你决定 | Claude 自行决定 | |

**User's choice:** 事件选项直接指定（权重配置）
**Notes:** 用户详细描述了权重累加机制：选项的权重 KV 累加，战斗时选最高权重地图；某些选项可强制指定地图

### 战斗修改机制

| Option | Description | Selected |
|--------|-------------|----------|
| 修改器叠加 | 选项携带修改器叠加到地图基础配置 | ✓ |
| 战斗预设合并 | 选项指定预设 ID，预设合并 | |
| 地图变体系统 | 地图有多个变体，选项选变体 | |

**User's choice:** 修改器叠加
**Notes:** 用户还要求全局难度系数（开始游戏前选择），影响全局敌人血量

---

## 难度系统

### 难度层级

| Option | Description | Selected |
|--------|-------------|----------|
| 三层叠加 | 全局 + 地图 + 阶段 | |
| 两层叠加 | 全局 + 地图 | ✓ |
| 你决定 | Claude 自行决定 | |

**User's choice:** 两层叠加
**Notes:** stages.json 的 battle_difficulty 目前未实际使用，不纳入难度系统

### 地图难度配置方式

| Option | Description | Selected |
|--------|-------------|----------|
| 难度等级预设 | easy/normal/hard 三档 | |
| 参数化配置 | 分别设定各参数 | ✓ |
| 你决定 | Claude 自行决定 | |

**User's choice:** 参数化配置
**Notes:** 地图难度参数包含：波次数量、敌人属性倍率、塔位数量（经济参数不受影响）

### 全局难度设计

| Option | Description | Selected |
|--------|-------------|----------|
| 三档预设 | 简单/普通/困难，对应血量倍率 | ✓ |
| 自定义倍率 | 玩家输入具体倍率值 | |
| 你决定 | Claude 自行决定 | |

**User's choice:** 三档预设

### 难度叠加计算

| Option | Description | Selected |
|--------|-------------|----------|
| 乘法叠加 | 全局倍率 × 地图倍率 | ✓ |
| 加法叠加 | 全局倍率 + 地图倍率 | |
| 你决定 | Claude 自行决定 | |

**User's choice:** 乘法叠加

---

## Claude's Discretion

- 地图具体布局设计
- 地形类型具体实现
- 修改器叠加合并规则
- 全局难度三档具体倍率数值

## Deferred Ideas

- 地图布局与主题设计——可在规划阶段细化
- 地形与障碍物系统（MAP-02）——未选择讨论但属于阶段1范围
- 地图解锁系统（MAP-04）——阶段5范围
- 地图变体和随机元素（MAP-05）——阶段5范围
- 程序化地图生成（MAP-06）——v2 范围
- 地图编辑器（MAP-07）——v2 范围
