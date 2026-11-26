# Godot 4.x 游戏存档系统

> 适用版本：Godot 4.x | 来源：知识库整合

---

## 目录

1. [存档概述](#1-存档概述)
2. [简单存档](#2-简单存档)
3. [多存档槽](#3-多存档槽)
4. [加密存档](#4-加密存档)
5. [自动存档](#5-自动存档)

---

## 1. 存档概述

### 1.1 存储位置

使用 `user://` 目录存储存档数据：

| 平台 | 路径 |
|------|------|
| Windows | `%APPDATA%/Godot/app_userdata/[项目名]/` |
| macOS | `~/Library/Application Support/Godot/app_userdata/[项目名]/` |
| Linux | `~/.local/share/godot/app_userdata/[项目名]/` |

### 1.2 存档格式选择

| 格式 | 优点 | 缺点 |
|------|------|------|
| JSON | 可读、易调试 | 可被玩家修改 |
| ConfigFile | Godot 原生支持 | 结构较复杂 |
| 二进制 | 支持 Godot 内置值类型、较紧凑 | 需要专门工具读取，数据仍可能被改动 |

---

## 2. 简单存档

### 2.1 使用 var 存储

```gdscript
const SAVE_PATH = "user://save.dat"

var player_data = {
    "name": "Hero",
    "level": 5,
    "health": 100,
    "position": Vector2(100, 200)
}

func save_game():
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_var(player_data)

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        player_data = file.get_var()
        return true
    return false
```

### 2.2 使用 JSON

```gdscript
const SAVE_PATH = "user://save.json"

func save_json(data: Dictionary):
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data, "\t"))

func load_json() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var json = JSON.new()
        var error = json.parse(file.get_as_text())
        if error == OK:
            if json.data is Dictionary:
                return json.data
    return {}
```

---

## 3. 多存档槽

### 3.1 实现

```gdscript
const SAVE_DIR = "user://saves/"

func get_save_path(slot: int) -> String:
    return SAVE_DIR + "slot_%d.json" % slot

func save_slot(slot: int, data: Dictionary):
    ensure_dir()
    save_json(get_save_path(slot), data)

func load_slot(slot: int) -> Dictionary:
    return load_json(get_save_path(slot))

func has_save(slot: int) -> bool:
    return FileAccess.file_exists(get_save_path(slot))

func delete_slot(slot: int):
    var path = get_save_path(slot)
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)

func ensure_dir():
    var dir = DirAccess.open("user://")
    if dir and not dir.dir_exists("saves"):
        dir.make_dir("saves")
```

---

## 4. 加密存档

### 4.1 使用 Godot 的加密文件接口

```gdscript
func save_encrypted_text(path: String, text: String, password: String) -> bool:
    var file := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, password)
    if file == null:
        return false
    var stored := file.store_string(text)
    file.close()
    return stored

func read_encrypted_text(path: String, password: String) -> String:
    var file := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
    if file == null:
        return ""
    var text := file.get_as_text()
    file.close()
    return text
```

Godot 4.6.2 已验证该接口能往返读写加密文本。读取 JSON 时再校验解析结果和数据形状。若空字符串本身是有效存档，可让调用方另收读取是否成功的状态。[FileAccess 类参考](../godot-official-docs/classes/class_fileaccess.rst)

---

## 5. 自动存档

### 5.1 触发条件

```gdscript
var auto_save_interval := 60.0
var auto_save_timer := 0.0

func _process(delta):
    auto_save_timer += delta
    if auto_save_timer >= auto_save_interval:
        auto_save_timer = 0
        auto_save()

func auto_save():
    save_current_slot()
    print("游戏已自动保存")
```

### 5.2 存档时机建议

| 时机 | 说明 |
|------|------|
| 关卡完成 | 通过关卡后 |
| 进入新区域 | 场景切换前 |
| 设置变更 | 选项改变后 |
| 定时 | 每 N 分钟 |

---

## 参考资料

本文档内容基于 Godot 官方文档和最佳实践整理。
