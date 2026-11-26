# 游戏存档系统实战指南

> **最近核对**：2026-11-27，TestMCP 当前代码与 Godot 4.6.2

## 存档方式

| 方式 | 用途与边界 |
| --- | --- |
| JSON 文本 | 方便阅读、调试和迁移。读档时先处理文件打开和解析错误，再检查顶层类型与必需字段。JSON 数字读回后要按数据结构转换类型，`Vector2` 等引擎类型用字段表示 |
| 二进制 Variant | `store_var()` / `get_var(false)` 能保存常见 Godot 值类型。二进制格式便于序列化，文件仍可被改动。对外部存档保持对象反序列化关闭 |
| Godot 加密文件 | 使用 `FileAccess.open_encrypted_with_pass(path, mode, password)` 获取加密文件句柄，再读写内容。Godot 4.6.2 已实际验证加密文本往返。应用内所带的密码只能提高读取门槛，不能用于证明存档来自可信玩家 |

[Godot FileAccess 类参考](../../base/godot-official-docs/classes/class_fileaccess.rst) · [Godot JSON 类参考](../../base/godot-official-docs/classes/class_json.rst)

### JSON 读取示例

```gdscript
func read_save_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_warning("Save open failed: %s" % FileAccess.get_open_error())
        return {}
    var parser := JSON.new()
    var parse_error := parser.parse(file.get_as_text())
    file.close()
    if parse_error != OK:
        push_warning("Save parse failed: %s" % parser.get_error_message())
        return {}
    if not parser.data is Dictionary:
        push_warning("Save root must be a dictionary")
        return {}
    return parser.data
```

示例用空字典表示读取失败，调用方还要检查必需字段。能成功解析的 JSON 也可能是数组、数字或 `null`，直接赋给强类型 `Dictionary` 可能报错。项目的读档入口目前检查解析结果和 `player_data` 是否存在，直接使用强类型字典接收解析结果，顶层形状仍有这个缺口。[项目读档入口](../../../scripts/managers/save_system.gd)

## TestMCP 当前存档

- `SaveSystem` 用 `user://saves/save_0.sav` 至 `save_2.sav` 保存 JSON，菜单读取的是第 0 槽。顶层字段包括 `version`、`timestamp`、`player_data`、`game_session_data`、`game_state`。实际落盘路径可用 `ProjectSettings.globalize_path()` 查看。
- `PlayerSaveData` 表示跨局数据。`GameSessionData` 包含年龄、NPC、选择标记、已完成事件、当前地图、生命和累计伤害等局内数据。持久化范围由 `to_dict()` 明确决定，和是否声明 `@export` 无关。当前选图累积权重、待应用的战斗修改器以及事件解锁和锁定列表都未写入 `to_dict()`；解锁和锁定列表虽然能在 `from_dict()` 读取，当前保存仍不会写出。
- `GameSessionData.from_dict()` 对多数旧字段使用默认值，并兼容旧的塔 ID 数组形态。`birthday` 目前直接按键读取，缺少该字段的旧档需要单独覆盖。当前战斗字段记录了地图和波次等数据，场景节点、在场敌人和计时器的运行状态没有随档保存。

[存档管理器](../../../scripts/managers/save_system.gd) · [局内数据序列化](../../../scripts/bean/session_data.gd) · [跨局数据](../../../scripts/bean/save_data.gd)

## 已复现的续档缺口

| 情形 | 当前表现与检查点 |
| --- | --- |
| 保存后返回菜单，再点「继续游戏」 | 菜单场景可以已经切换，`GameState.current_state` 仍是保存前的状态。继续时传入相同状态，`change_state()` 提前返回，菜单仍留在屏幕上 |
| 存档读取成功，继续推进事件 | `load_game()` 替换 `Global.game_session` 时未发出 `session_reset`，依赖该信号更新引用的系统仍握着旧对象。本地隔离复现中，读回年龄为 9，选择标记在新会话里，`AgeSystem` 年龄仍是 6，`EventSystem` 与全局会话引用不同 |
| 写入中断或读取较早格式 | `save_game()` 直接以 `FileAccess.WRITE` 覆盖文件。当前版本字段是写入的元数据。回归验证应覆盖旧格式、写失败后的文件和场景内续玩 |

验证续档至少要走一次「保存 → 返回菜单或重启 → 继续 → 再选择一条事件」，同时对照场景、状态机、事件系统会话引用与年龄。字段往返测试可验证序列化，真实入口测试才能覆盖续玩。

[菜单继续](../../../scripts/ui/menu.gd) · [状态切换](../../../scripts/logic/game_state.gd) · [会话重置](../../../autoload/global.gd) · [读取实现](../../../scripts/managers/save_system.gd)

## 相关资源

- [存档参考材料](../../base/assets-and-io/15C_Saving_Games.md)
- [文件系统指南](filesystem-guide.md)
