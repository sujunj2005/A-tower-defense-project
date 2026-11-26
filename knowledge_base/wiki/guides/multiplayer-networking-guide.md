---
doc_type: guide
category: multiplayer
---

# TestMCP 多人联机状态

**源码核对**：2026-11-27，检查项目配置、场景、运行时代码和现有测试入口。

## 当前实现

- 主菜单进入本地状态机，事件、战斗和存档围绕本地 `GameSessionData` 运作。
- ENet、Steam P2P 和节点同步均处于待接入状态。双端连接、断线重连和状态同步仍待联调。

[项目配置](../../../project.godot) · [本地状态机](../../../scripts/logic/game_state.gd) · [局内数据](../../../scripts/bean/session_data.gd) · [项目测试记录](../../outline/Godot%20编码规范汇总.md#test-baseline)

## 通用资料

通用正文见《GDScript Godot 4.x 游戏开发专项知识库》首页「正文索引」第 13 篇《多人联机网络编程》。库内路径为 `11_Multiplayer_Networking/13_Multiplayer_Networking.md`。

[Godot 官方高层多人网络参考](../../base/godot-official-docs/tutorials/networking/high_level_multiplayer.rst) · [项目 Steam 接入状态](./steam-platform-integration-guide.md)
