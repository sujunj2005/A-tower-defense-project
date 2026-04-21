# Godot 4.x 文件系统与 IO

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/io/filesystem.rst

---

## 目录

1. [文件系统概述](#1-文件系统概述)
2. [路径类型](#2-路径类型)
3. [文件操作](#3-文件操作)
4. [目录操作](#4-目录操作)
5. [JSON 解析](#5-json-解析)
6. [游戏存档](#6-游戏存档)

---

## 1. 文件系统概述

### 1.1 虚拟文件系统

Godot 使用虚拟文件系统，所有路径以 `res://` 或 `user://` 开头：

| 前缀 | 说明 |
|------|------|
| `res://` | 项目根目录（只读） |
| `user://` | 用户数据目录（可写） |

### 1.2 用户数据目录位置

| 平台 | 路径 |
|------|------|
| Windows | `%APPDATA%/Godot/app_userdata/[项目名]/` |
| macOS | `~/Library/Application Support/Godot/app_userdata/[项目名]/` |
| Linux | `~/.local/share/godot/app_userdata/[项目名]/` |
| Android | 应用专用目录 |
| iOS | 应用沙盒目录 |

---

## 2. 路径操作

### 2.1 获取路径

```gdscript
# 获取用户数据目录
var user_dir = OS.get_user_data_dir()

# 获取可执行文件目录
var exe_dir = OS.get_executable_path().get_base_dir()

# 获取项目设置路径
var config_dir = OS.get_config_dir()
```

### 2.2 路径拼接

```gdscript
var path = "user://saves".path_join("save1.dat")
# 结果：user://saves/save1.dat
```

### 2.3 检查路径存在

```gdscript
# 检查文件
if FileAccess.file_exists("user://save.dat"):
    print("文件存在")

# 检查目录
if DirAccess.dir_exists_absolute("user://saves"):
    print("目录存在")
```

---

## 3. 文件操作

### 3.1 写入文件

```gdscript
func save_data():
    var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
    if file:
        file.store_string("Hello, World!")
        file.store_32(12345)
        file.store_float(3.14)
        file.store_var({"name": "Player", "level": 5})
```

### 3.2 读取文件

```gdscript
func load_data():
    var file = FileAccess.open("user://save.dat", FileAccess.READ)
    if file:
        var text = file.get_as_text()
        var number = file.get_32()
        var float_val = file.get_float()
        var data = file.get_var()
```

### 3.3 打开模式

| 模式 | 说明 |
|------|------|
| `READ` | 只读 |
| `WRITE` | 写入（覆盖） |
| `READ_WRITE` | 读写 |
| `WRITE_READ` | 写入后可读 |

### 3.4 错误处理

```gdscript
func safe_read():
    var file = FileAccess.open("user://save.dat", FileAccess.READ)
    if file == null:
        print("打开失败：", FileAccess.get_open_error())
        return
    
    var content = file.get_as_text()
    print(content)
```

---

## 4. 目录操作

### 4.1 创建目录

```gdscript
func ensure_save_dir():
    var dir = DirAccess.open("user://")
    if dir and not dir.dir_exists("saves"):
        dir.make_dir("saves")
```

### 4.2 列出目录内容

```gdscript
func list_files(path: String):
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if not dir.current_is_dir():
                print("文件：", file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
```

### 4.3 复制和删除

```gdscript
func copy_file(from: String, to: String):
    var dir = DirAccess.open(from.get_base_dir())
    if dir:
        dir.copy(from, to)

func delete_file(path: String):
    var dir = DirAccess.open(path.get_base_dir())
    if dir:
        dir.remove(path.get_file())
```

---

## 5. JSON 解析

### 5.1 读取 JSON

```gdscript
func load_json(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var json_text = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(json_text)
        if error == OK:
            return json.data
        else:
            print("JSON 解析错误：", json.get_error_message())
    return {}
```

### 5.2 写入 JSON

```gdscript
func save_json(path: String, data: Dictionary):
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        var json_text = JSON.stringify(data, "  ")  # 带缩进
        file.store_string(json_text)
```

---

## 6. 游戏存档

### 6.1 简单存档

```gdscript
var save_path = "user://savegame.save"

func save_game():
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        var save_data = {
            "player_position": player.position,
            "player_health": player.health,
            "level": current_level
        }
        file.store_var(save_data)

func load_game():
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        if file:
            var save_data = file.get_var()
            player.position = save_data.player_position
            player.health = save_data.player_health
            current_level = save_data.level
```

### 6.2 多存档槽

```gdscript
func get_save_path(slot: int) -> String:
    return "user://saves/slot_%d.save" % slot

func save_to_slot(slot: int, data: Dictionary):
    var dir = DirAccess.open("user://")
    if dir and not dir.dir_exists("saves"):
        dir.make_dir("saves")
    
    var file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
    if file:
        file.store_var(data)
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/io/filesystem.rst`
