---
doc_type: guide
category: steam
---

# TestMCP Steam 接入状态

**源码核对**：2026-11-27，检查项目配置、导出预设和运行时代码。

## 当前实现

| 检查项 | 记录 |
| --- | --- |
| 发行配置 | 当前配置为 Windows Desktop。Steamworks 集成状态为待接入。 |
| 本地成就 | `AchievementSystem` 读取 `data/achievements.json`，把达成的 ID 记入 `PlayerSaveData.achievements` 并发出 `achievement_unlocked`。 |
| 验证范围 | 本次依据为配置与代码。Steam 客户端初始化、成就上传及到账验证待接入后执行。 |

[项目配置](../../../project.godot) · [导出预设](../../../export_presets.cfg) · [成就配置](../../../data/achievements.json) · [本地成就实现](../../../scripts/logic/meta_progression/achievement_system.gd) · [跨局存档](../../../scripts/bean/save_data.gd)

## 通用资料

通用正文见《GDScript Godot 4.x 游戏开发专项知识库》首页「正文索引」第 12 篇《Steam 平台对接》。库内路径为 `10_Steam_Integration/12_Steam_Platform_Integration.md`。

联机接入另见[项目联机状态](./multiplayer-networking-guide.md)。
