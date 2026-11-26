# P15：ConfigManager load_json 缓存机制与坑点

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | 数据/配置 |
| **严重程度** | 🟡 中 |
| **涉及文件** | `autoload/config_manager.gd` |
| **知识库关联** | [§38 数据格式不一致](../../../wiki/guides/common-pitfalls.md#38-数据格式不一致导致条件判断永远失败--中) / [§39 修改数据格式遗漏消费者](../../../wiki/guides/common-pitfalls.md#39-修改数据格式时遗漏配置文件消费者--中) |

---

## 现象

**现象 1**：修改了 `events.json` 配置文件中的某个事件数据，重新运行场景后游戏内仍显示旧数据，修改不生效。

**现象 2**：开发者在多个 Autoload 中调用了 `ConfigManager.load_json("events.json")`，担心多次调用导致重复磁盘 I/O 影响性能，试图手动缓存引用避免重复加载。

## 根因

`ConfigManager` 内部维护了一个 `_config_cache: Dictionary` 字典作为缓存：

```gdscript
# ConfigManager 内部实现（简化示意）
var _config_cache: Dictionary = {}

func load_json(file_path: String) -> Dictionary:
    if _config_cache.has(file_path):
        return _config_cache[file_path]  # 直接返回缓存，不读磁盘

    var file = FileAccess.open(file_path, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    _config_cache[file_path] = data
    return data

func reload_config(file_path: String) -> Dictionary:
    _config_cache.erase(file_path)
    return load_json(file_path)
```

**缓存机制的利弊分析**：

| 方面 | 行为 | 影响 |
|------|------|------|
| 首次调用 | 读磁盘 → 解析 JSON → 存入缓存 | 一次 I/O |
| 后续调用 | 直接从 `_config_cache` 返回 | 零 I/O，O(1) 查找 |
| 修改 JSON 后 | 缓存未自动刷新 → 返回旧数据 | **需手动 reload** |
| 多 Autoload 调用 | 共享同一缓存 → 只发生一次 I/O | **无性能问题** |

## 正确做法

### 1. 需要强制刷新时：调用 `reload_config()`

```gdscript
# 修改 JSON 文件后，需要刷新缓存
ConfigManager.reload_config("res://configs/events.json")
```

### 2. 不需要刷新时：放心多次调用 `load_json()`

```gdscript
# ✅ 多次调用 load_json 不会有性能问题
# EventSystem 调用
var events = ConfigManager.load_json("res://configs/events.json")
# MapManager 也调用
var events = ConfigManager.load_json("res://configs/events.json")
# TraitSystem 也调用
var events = ConfigManager.load_json("res://configs/events.json")
# 以上三次调用只发生一次磁盘 I/O
```

### 3. 开发期快速验证：先 `reload_config` 再读取

```gdscript
# 调试时确保读到最新数据
ConfigManager.reload_config("res://configs/events.json")
var events = ConfigManager.load_json("res://configs/events.json")
```

### 4. 批量修改 JSON 后的标准流程

```
1. Python 脚本修改 JSON 文件
2. 代码中调用 ConfigManager.reload_config("文件路径")
3. 或重启 Godot 编辑器（缓存生命周期 = 编辑器会话）
```

## 教训

1. **了解系统缓存机制后再做性能判断**：`ConfigManager` 已内置缓存层，外部不需要再手动缓存引用。凭直觉假设"多次 `load_json` = 多次磁盘 I/O"是错误的。

2. **缓存不自动刷新的机制要有清晰文档**：当修改 JSON 后游戏内不生效时，第一反应应该是检查是否有缓存层，而不是怀疑 JSON 文件没保存。

3. **单一数据源 + 唯一入口模式**：所有配置读取统一走 `ConfigManager.load_json()`，不要绕过它直接读文件，否则会破坏缓存一致性。

---

*记录时间：2026-04-30*
