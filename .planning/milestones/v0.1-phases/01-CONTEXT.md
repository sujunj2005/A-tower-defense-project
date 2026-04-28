# Phase 1: 地图系统增强 - Context

**Gathered:** 2026-04-22
**Status:** Ready for planning

<domain>
## Phase Boundary

实现多样化的塔防地图，包含不同布局、地形和难度设置。地图由人生模拟事件选项驱动选择，而非玩家自由选择。

</domain>

<decisions>
## Implementation Decisions

### 地图数据架构

- **D-01:** 地图数据继续使用 `.tres` Resource 格式存储。地图数据包含大量嵌套结构（Array[Vector2i]、Rect2 等），不适合 xlsx 表格化，与项目其他表格型数据（enemies、towers）不同
- **D-02:** 地图注册改为目录扫描 `res://resources/maps/`，自动发现 .tres 文件并注册。事件系统通过 map_id 引用地图即可，新增地图只需放文件无需改代码
- **D-03:** 事件选项携带 `{map_id: weight}` 权重配置，玩家选择后权重累加，战斗触发时选权重最高的地图
- **D-04:** 某些事件选项可强制指定地图（force_map_id），覆盖权重累加机制
- **D-05:** 选项修改器叠加影响战斗内容——添加波次、添加小boss、添加敌人种类等。修改器从上次战斗后到本次战斗间的所有选项中收集并叠加到地图基础配置
- **D-06:** 地图需有 `era_id` 字段，与时代系统联动。只有符合当前时代背景的地图才能被事件触发。当前仅有 china_modern，但最终会有更多时代

### 难度系统

- **D-07:** 两层难度叠加：全局难度（开始游戏前选择）+ 地图难度（地图配置中参数化设定）。stages.json 的 battle_difficulty 暂不纳入
- **D-08:** 全局难度为三档预设（简单/普通/困难），每档对应一个敌人血量倍率
- **D-09:** 地图难度为参数化配置，包含三个参数：波次数量、敌人属性倍率、塔位数量。经济参数不受难度影响
- **D-10:** 全局难度与地图难度的敌人属性倍率采用乘法叠加计算（全局倍率 × 地图倍率 = 最终倍率）

### Claude's Discretion

- 地图具体布局设计（5张地图的路径形态、主题等）
- 地形类型的具体实现（MAP-02 要求的地形和障碍物细节）
- 修改器叠加的合并规则（冲突处理、优先级等）
- 全局难度三档的具体倍率数值

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 地图系统核心代码
- `scripts/logic/tower_defense/map_config.gd` — MapConfig Resource 类，地图数据模型和加载逻辑
- `scripts/managers/map_manager.gd` — MapManager 控制器，地图加载、TileMap 创建、塔位管理、战斗流程
- `scripts/bean/map/map_bean.gd` — MapBean 数据模型，from_dict/to_dict 序列化
- `resources/maps/map_01.tres` — 现有地图 Resource 示例
- `resources/maps/map_test.tres` — 测试地图 Resource

### 关联系统
- `data/stages.json` — 阶段配置，含 battle_difficulty（目前未使用）和 enemy_pool
- `scripts/logic/tower_defense/wave_config.gd` — 波次配置
- `scripts/logic/tower_defense/enemy_config.gd` — 敌人配置，含 set_map_config
- `scripts/logic/life_simulation/event_system.gd` — 事件系统，触发战斗的入口
- `scripts/bean/event_data.gd` — 事件数据模型
- `scripts/bean/option_data.gd` — 选项数据模型
- `scripts/logic/game_state.gd` — 游戏状态管理

### 配置与工具
- `config_tool.py` — 配置导入导出工具（处理 JSON/xlsx，不处理地图 .tres）
- `data/game_config.json` — 游戏全局配置

### 项目文档
- `.planning/ROADMAP.md` — 阶段1需求定义（MAP-01/02/03, MAINT-01/02/03）
- `.planning/REQUIREMENTS.md` — 完整需求列表和验收标准
- `.planning/PROJECT.md` — 项目愿景和技术上下文
- `.planning/codebase/STRUCTURE.md` — 代码库结构分析
- `.planning/codebase/CONVENTIONS.md` — 编码规范

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **MapConfig**: 已有完整的地图 Resource 类，含 waypoints、path_points、tower_positions、camera 参数等。新增字段（era_id、难度参数）可直接扩展
- **MapConfig.compute_path_from_waypoints()**: 已有 waypoints→path_points 的路径计算静态方法
- **MapConfig.load_map()**: 已有按 map_id 加载地图的静态方法，需改为目录扫描
- **MapBean**: from_dict/to_dict 序列化方法，但地图用 .tres 不用 JSON
- **TileMapLayer + Terrain System**: 已有草地/道路/边缘三种地形的 TileMap 渲染，可扩展新地形

### Established Patterns
- **Resource 模式**: 游戏配置用 Resource (.tres) + JSON (.json) 双轨制，地图属于 Resource 轨
- **Auto-loaded 单例**: 核心系统通过 autoload 注册（ConfigManager、EconomySystem 等），地图系统通过 group("map_manager") 访问
- **信号驱动**: 波次事件（wave_started/completed）、敌人事件（died/reached_base）通过信号连接
- **修改器模式**: EraSystem.get_modified_tower_cost() 已有修改器模式先例，难度倍率可复用此模式

### Integration Points
- **事件→战斗**: EventSystem 触发战斗时需传递 map_id 和修改器，当前通过 session.current_battle_waves 传递波次数据
- **MapManager._load_map()**: 地图加载入口，需支持目录扫描和 era_id 过滤
- **EnemyConfig.set_map_config()**: 敌人配置已接收地图配置，难度倍率可在此处应用
- **GameSessionData**: 会话数据，需扩展存储全局难度选择和地图权重累加

</code_context>

<specifics>
## Specific Ideas

- 地图选择机制：事件选项的权重配置是 KV 结构（K=map_id, V=weight），权重累加后选最高者。强制选项直接指定 map_id
- 修改器叠加：从上次战斗后到本次战斗间，所有选项的修改器收集并叠加到地图基础配置
- 时代过滤：地图需 era_id 字段，与 EraSystem 联动，仅当前时代的地图可被触发
- 全局难度三档预设影响敌人血量，与地图难度乘法叠加

</specifics>

<deferred>
## Deferred Ideas

- 地图布局与主题设计（5张地图的具体路径形态和主题）——可在规划阶段细化
- 地形与障碍物系统（MAP-02）——讨论时未选择此领域，但属于阶段1范围，需在规划中覆盖
- 地图解锁系统（MAP-04）——属于阶段5范围
- 地图变体和随机元素（MAP-05）——属于阶段5范围
- 程序化地图生成（MAP-06）——属于 v2 范围
- 地图编辑器（MAP-07）——属于 v2 范围

</deferred>

---

*Phase: 01-map-system*
*Context gathered: 2026-04-22*
