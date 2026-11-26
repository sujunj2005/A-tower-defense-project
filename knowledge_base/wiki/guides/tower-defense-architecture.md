---
doc_type: guide
category: tower-defense
---

# TestMCP 塔防战斗架构

**源码核对**：2026-11-27。表中源码可随 TestMCP 检出。运行验证引用项目现有记录。

## 从人生事件进入战斗

| 环节 | TestMCP 实现 | 代码依据 |
| --- | --- | --- |
| 选择事件选项 | `EventSystem.select_option()` 先结算选项。配置包含 `battle_trigger` 时准备战斗上下文，事件 UI 在后果弹窗结束后切换到战斗状态。 | [事件结算](../../../scripts/logic/life_simulation/event_system.gd) · [事件界面](../../../scripts/ui/event_ui.gd) |
| 地图与波次 | `MapConfig` 管理地图资源。`MapManager` 根据战斗上下文初始化地图，启动 `WaveManager` 并消费出怪请求。 | [地图配置](../../../scripts/logic/tower_defense/map_config.gd) · [战斗场景](../../../scenes/map.tscn) · [地图管理器](../../../scripts/managers/map_manager.gd) · [波次管理器](../../../scripts/logic/tower_defense/wave_manager.gd) |
| 建塔和攻击 | 点击塔位打开选择界面，`MapManager` 按塔类型配置检查并建塔，攻击行为由塔的攻击组件执行。 | [选塔界面](../../../scripts/ui/tower_select_ui.gd) · [建塔入口](../../../scripts/managers/map_manager.gd) · [塔攻击组件](../../../scripts/view/tower/tower_attack_component.gd) |
| 战斗结算和存档 | 战斗结算更新本局状态，经状态机进入结算或终局。`SaveSystem` 把选定的跨局和局内数据按 JSON 写入 `user://saves/`。 | [结算界面](../../../scripts/ui/result_ui.gd) · [存档管理器](../../../scripts/managers/save_system.gd) · [局内序列化](../../../scripts/bean/session_data.gd) |

## 验证记录

| 项目 | 已记录的验证结果 |
| --- | --- |
| 地图资源 | Godot 4.6.2 源码工程实测注册 7 张地图。路点展开和 TileMapLayer 坐标往返的测试条件见[地图系统记录](../../outline/地图系统踩坑记录.md)。 |
| 事件链 | Godot 4.6.2 与 GUT 9.6.0 的定向测试为 9/9。全量套件的失败、计数与测试范围见[测试基线](../../outline/Godot%20编码规范汇总.md#test-baseline)。 |
| 续档 | 已复现返回菜单后无法继续，以及读档后事件系统仍持有旧会话等问题。复现过程见[续档记录](./saving-games-guide.md#已复现的续档缺口)。 |

## 历史案例

通用正文见《GDScript Godot 4.x 游戏开发专项知识库》首页「正文索引」第 14 篇《塔防游戏案例研究》。库内路径为 `12_Tower_Defense_Case_Study/14_Tower_Defense_Case_Study.md`。

该案例记录的是历史 `tower_defense` 工程的模型、加密存档、建造弹窗和相机实现。
