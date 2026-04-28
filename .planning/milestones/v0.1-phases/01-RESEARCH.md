# Phase 01: 地图系统增强 - Research

**Date:** 2026-04-22
**Phase:** 01-map-system
**Status:** Research Complete

## Research Summary

本阶段需要在现有地图系统基础上实现：多样化地图、地形障碍物、难度系统，以及事件驱动的地图选择机制。研究揭示了6个关键架构缺口和完整的战斗流程链路。

## 1. 现有系统分析

### 1.1 地图数据层 (MapConfig)

**文件:** `scripts/logic/tower_defense/map_config.gd`

当前 MapConfig Resource 类包含：
- 基础字段：map_name, map_width, map_height, tile_size
- 路径字段：spawn_point, base_point, path_points, waypoints
- 塔位字段：tower_positions, max_towers
- 相机字段：camera_speed, zoom_speed, drag_speed, drag_inertia
- 纹理字段：grass/road/edge texture_path + texture_region
- 波次字段：waves, enemy_registry

**缺失字段（需新增）：**
- `era_id: String` — 时代过滤 (D-06)
- `wave_count_modifier: int` — 波次数量调整 (D-09)
- `enemy_attribute_multiplier: float` — 敌人属性倍率 (D-09)
- `tower_slot_count: int` — 可用塔位数 (D-09, 替代 max_towers)
- `map_id: String` — 自身 ID（目录扫描时从文件名推导）

**注册表问题：**
```gdscript
static var _map_registry: Dictionary = {}
static func _static_init():
    _map_registry = {
        "map_01": "res://resources/maps/map_01.tres",
        "map_test": "res://resources/maps/map_test.tres"
    }
```
硬编码注册表需改为目录扫描 (D-02)。

### 1.2 地图控制器 (MapManager)

**文件:** `scripts/managers/map_manager.gd` (1208行)

关键流程：
1. `_ready()` → 从 `Global.debug_map_id` 或硬编码 "map_01" 获取地图 ID
2. `_load_map_data()` → `MapConfig.load_map(current_map_id)` + `EnemyConfig.set_map_config()`
3. `_setup_wave_manager()` → 读取 `session.current_battle_waves`（事件战斗）或 stage 配置
4. `_on_enemy_spawn_requested()` → 创建 Enemy，`enemy.initialize(enemy_cfg)` — **无难度倍率应用**
5. `_on_enemy_reached_base()` → 读取 `_enemy.config.damage` 计算基地伤害

**关键缺口：**
- `current_map_id` 硬编码，不从 session 读取
- 无全局难度倍率应用机制
- 无地图难度参数应用机制
- 无修改器叠加机制

### 1.3 事件→战斗流程

完整链路：
```
EventUI._on_option_selected()
  → EventSystem.select_option()
    → 处理 battle_trigger (Dictionary)
    → session.current_battle_waves = trigger.waves
    → _trigger_battle() → battle_triggered.emit()
  → GameState.change_state(BATTLE)
    → SceneTransition → map.tscn
      → MapManager._ready()
        → _load_map_data("map_01")  ← 硬编码！
        → _setup_wave_manager()
```

**关键缺口：**
- EventSystem.select_option() 不处理 map_weights (D-03)
- OptionData 无 map_weights/force_map_id/battle_modifiers 字段
- GameSessionData 无 current_map_id/global_difficulty/accumulated_map_weights 字段
- 战斗触发时无地图选择逻辑

### 1.4 波次/难度系统

**WaveManager** (`scripts/logic/tower_defense/wave_manager.gd`):
- `_difficulty_multiplier` 仅影响敌人数量，不影响属性
- `start_event_battle()` 设置 `_difficulty_multiplier = 1.0`（事件战斗忽略难度）
- `_get_wave_difficulty()` 返回 `_difficulty_multiplier * wave_scale`

**Enemy** (`scripts/view/enemy/enemy.gd`):
- `initialize()` 设置 `current_health = config.max_health`
- 难度倍率必须在 initialize() 之前或之中应用

**EnemyConfig** (`scripts/logic/tower_defense/enemy_config.gd`):
- 静态 `_map_config` 引用，`set_map_config()` 合并地图的 enemy_registry
- `max_health` 和 `damage` 是需要难度倍率的关键字段

### 1.5 时代系统

**EraSystem** (`scripts/logic/life_simulation/era_system.gd`):
- `get_modified_tower_cost()` 模式可复用于难度倍率
- `current_era` 字典有 `era_id`
- 目前仅有一个时代 `china_modern`

### 1.6 会话数据

**GameSessionData** (`scripts/bean/session_data.gd`):
- 有：era_id, current_stage, current_battle_waves, current_battle_id, current_battle_deadly
- **缺失**：current_map_id, global_difficulty, accumulated_map_weights, pending_battle_modifiers

## 2. 架构缺口与实现路径

### 缺口 1: 地图注册表动态化 (D-02)

**当前:** `_static_init()` 硬编码 2 个地图
**目标:** 扫描 `res://resources/maps/` 目录自动注册

**实现路径:**
- 替换 `_static_init()` 为 `_scan_maps_directory()` 方法
- 使用 `DirAccess.open("res://resources/maps/")` 扫描 .tres 文件
- 从文件名推导 map_id（如 `map_school.tres` → `map_school`）
- 验证加载的 Resource 是 MapConfig 类型
- 保留 `register_map()` 供动态注册

### 缺口 2: 事件选项地图权重 (D-03, D-04, D-05)

**当前:** OptionData 仅有 `battle_trigger: Variant`
**目标:** 选项携带 map_weights, force_map_id, battle_modifiers

**实现路径:**
- OptionData 新增字段：
  - `map_weights: Dictionary = {}` — {map_id: weight}
  - `force_map_id: String = ""` — 强制地图
  - `battle_modifiers: Array[Dictionary] = []` — 修改器列表
- EventSystem.select_option() 处理权重累加：
  - 遍历 map_weights，累加到 session.accumulated_map_weights
  - 存储 battle_modifiers 到 session.pending_battle_modifiers
- 战斗触发时选图逻辑：
  - 有 force_map_id → 直接使用
  - 否则 → 从 accumulated_map_weights 选最高权重
  - era_id 过滤：仅选当前时代的地图
  - 选图后清空 accumulated_map_weights

### 缺口 3: 难度系统 (D-07, D-08, D-09, D-10)

**当前:** WaveManager._difficulty_multiplier 仅影响敌人数量
**目标:** 两层难度叠加（全局 × 地图），影响敌人属性

**实现路径:**
- MapConfig 新增难度参数：
  - `wave_count_modifier: int = 0` — 额外波次
  - `enemy_attribute_multiplier: float = 1.0` — 敌人属性倍率
  - `tower_slot_count: int = -1` — 塔位数（-1 = 使用 max_towers）
- 全局难度配置（game_config.json 或新文件）：
  ```json
  {
    "difficulty_presets": {
      "easy": {"enemy_health_multiplier": 0.8, "enemy_damage_multiplier": 0.8},
      "normal": {"enemy_health_multiplier": 1.0, "enemy_damage_multiplier": 1.0},
      "hard": {"enemy_health_multiplier": 1.5, "enemy_damage_multiplier": 1.3}
    }
  }
  ```
- GameSessionData 新增 `global_difficulty: String = "normal"`
- 敌人属性计算：`final_health = base_health × global_multiplier × map_multiplier`
- 应用点：MapManager._on_enemy_spawn_requested() 中，在 enemy.initialize() 后修改属性

### 缺口 4: 地图与时代关联 (D-06)

**当前:** MapConfig 无 era_id 字段
**目标:** 地图按时代过滤

**实现路径:**
- MapConfig 新增 `era_id: String = ""`
- 地图选择时过滤：仅 era_id 匹配当前时代（或 era_id 为空表示通用）的地图可选
- EraSystem 提供当前 era_id

### 缺口 5: 地形扩展 (MAP-02)

**当前:** TileSet 仅有 3 种地形（grass, edge, road）
**目标:** 支持不同地形和障碍物

**实现路径:**
- 扩展 TileSet 添加新地形类型（如水、沙地、山地等）
- MapConfig 可选字段 `obstacles: Array[Dictionary]` — 障碍物位置和类型
- 障碍物影响：不可放塔、敌人绕行、减速等
- MapManager._create_tile_map() 扩展以渲染新地形

### 缺口 6: 5 张新地图内容 (MAP-01)

**当前:** 仅 map_01（S 弯道）和 map_test（测试用）
**目标:** 至少 5 个不同类型的地图

**地图设计方向（与人生阶段主题关联）：**
1. **map_school** — 学校主题，直线+弯道，童年/青年阶段
2. **map_office** — 办公室主题，格子间路径，青年/中年阶段
3. **map_hospital** — 医院主题，迷宫式路径，中年/老年阶段
4. **map_home** — 家庭主题，环形路径，通用
5. **map_street** — 街道主题，多岔路，青年/中年阶段

## 3. 修改器叠加机制 (D-05)

### 修改器类型

```gdscript
# battle_modifier 结构
{
    "type": "add_waves",           # 添加波次
    "value": 2                     # 额外2波
}
{
    "type": "add_enemy_type",      # 添加敌人种类
    "enemy_id": "enemy_boss_midlife",
    "wave": 3                      # 第3波出现
}
{
    "type": "add_mini_boss",       # 添加小boss
    "enemy_id": "enemy_exam_boss",
    "wave": -1                     # 最后一波
}
```

### 叠加规则

- 同类型修改器：数值累加（add_waves 的 value 相加）
- 敌人添加：按 wave 分组，不重复
- 应用时机：MapManager._setup_wave_manager() 中，在创建波次配置后叠加

## 4. 国际化需求 (MAINT-02)

### 需新增的翻译键

```
MAP_NAME_MAP_SCHOOL, MAP_NAME_MAP_OFFICE, MAP_NAME_MAP_HOSPITAL, MAP_NAME_MAP_HOME, MAP_NAME_MAP_STREET
MAP_DESC_MAP_SCHOOL, MAP_DESC_MAP_OFFICE, ...
DIFFICULTY_EASY, DIFFICULTY_NORMAL, DIFFICULTY_HARD
GLOBAL_DIFFICULTY_SELECT, GLOBAL_DIFFICULTY_DESC
TERRAIN_WATER, TERRAIN_SAND, TERRAIN_MOUNTAIN
OBSTACLE_ROCK, OBSTACLE_TREE
```

### 现有相关键

translations.csv 已有：TYPE_DIFFICULTY, UNLOCK_DIFFICULTY_EASY/HARD/HELL

## 5. 配置工具影响 (MAINT-03)

### config_tool.py 现状

- 处理 JSON↔xlsx 转换
- 不处理 .tres 地图文件（D-01 确认继续用 .tres）
- CONFIG_FILES 列表不含地图

### 需要的变更

- 无需修改 config_tool.py 处理 .tres 文件
- 但需确保 game_config.json 中的 difficulty_presets 可被工具管理
- options.json 需新增 map_weights/force_map_id/battle_modifiers 字段支持

## 6. 知识库状态 (MAINT-01)

### 当前状态

知识库目录 (`knowledge_base/`) 不存在。项目 rules 引用了 `./knowledge_base/` 路径，但实际未创建。

### 需要的行动

- 创建 knowledge_base 目录结构
- 将地图系统开发中的踩坑记录写入
- 更新编码规范（如有新规范）

## 7. 关键依赖与风险

### 依赖关系

1. **MapConfig 扩展** → 所有其他功能的前置
2. **目录扫描注册** → 新地图可被发现的前置
3. **GameSessionData 扩展** → 地图选择和难度传递的前置
4. **OptionData 扩展** → 事件驱动地图选择的前置
5. **EventSystem 修改** → 权重累加和修改器收集的前置
6. **MapManager 修改** → 难度倍率应用的前置
7. **新地图 .tres 创建** → 可在 MapConfig 扩展后并行进行

### 风险

1. **Enemy 属性修改时机** — 在 initialize() 后修改可能遗漏某些初始化逻辑，需确认 Enemy 的属性读取时机
2. **权重累加清空时机** — 战斗触发后需清空，但异常退出可能导致脏数据
3. **目录扫描性能** — 每次调用 load_map 都扫描目录？还是启动时扫描一次缓存？
4. **TileSet 扩展** — 新地形需要美术资源，当前仅有 Outside_A2.png

## 8. 验证架构

### 测试策略

- **单元测试**: MapConfig.compute_path_from_waypoints(), 目录扫描逻辑, 权重选择逻辑, 难度倍率计算
- **集成测试**: 完整战斗流程（事件选择→地图选择→难度应用→战斗结束）
- **场景测试**: 每张新地图的加载和渲染

### 验收标准映射

| 需求 | 验证方式 |
|------|----------|
| MAP-01: 5个不同类型地图 | 5个 .tres 文件存在且可加载 |
| MAP-02: 不同地形和障碍物 | TileSet 有 3+ 种地形，地图有障碍物配置 |
| MAP-03: 地图难度设置 | 难度参数影响敌人属性和波次 |
| MAINT-01: 知识库更新 | knowledge_base/ 有地图系统踩坑记录 |
| MAINT-02: 国际化完整 | 所有地图相关文本有翻译键 |
| MAINT-03: 配置工具可用 | game_config.json 的难度配置可导入导出 |

---

## RESEARCH COMPLETE
