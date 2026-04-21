# 游戏存档系统实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 15B_Saving_Games.md](../../base/assets-and-io/15B_Saving_Games.md)  
> **重要性**: 🔴 必读 - 完整的存档系统实现

---

## 📋 概述

本指南提供完整的游戏存档系统实现方案，包括数据序列化、存档管理、云存档等。

---

## 🎯 存档方式

### 1. 二进制存档（推荐）

```gdscript
# 快速、紧凑、不易篡改
func save_binary(data: Dictionary, filename: String):
    var file = FileAccess.open(filename, FileAccess.WRITE)
    file.store_var(data)  # 自动序列化
    file.close()

func load_binary(filename: String) -> Dictionary:
    var file = FileAccess.open(filename, FileAccess.READ)
    var data = file.get_var()
    file.close()
    return data
```

### 2. JSON 存档

```gdscript
# 可读性强，易于调试
func save_json(data: Dictionary, filename: String):
    var json_string = JSON.stringify(data, "  ")  # 缩进 2 空格
    var file = FileAccess.open(filename, FileAccess.WRITE)
    file.store_string(json_string)
    file.close()

func load_json(filename: String) -> Dictionary:
    var file = FileAccess.open(filename, FileAccess.READ)
    var json_string = file.get_as_text()
    var json = JSON.parse_string(json_string)
    file.close()
    return json
```

### 3. 加密存档

```gdscript
# 防止篡改
func save_encrypted(data: Dictionary, filename: String, password: String):
    var json_string = JSON.stringify(data)
    var encrypted = XORCrypt.encrypt(json_string, password)
    var file = FileAccess.open(filename, FileAccess.WRITE)
    file.store_buffer(encrypted)
    file.close()

func load_encrypted(filename: String, password: String) -> Dictionary:
    var file = FileAccess.open(filename, FileAccess.READ)
    var encrypted = file.get_buffer(file.get_length())
    var json_string = XORCrypt.decrypt(encrypted, password)
    file.close()
    return JSON.parse_string(json_string)
```

---

## 🔧 完整存档系统

```gdscript
class_name SaveManager
extends Node

signal game_saved
signal game_loaded

var current_save_slot: int = 1
var save_directory: String = "user://saves/"

func _ready():
    DirAccess.make_dir_recursive_absolute(save_directory)

func save_game(data: Dictionary, slot: int = current_save_slot):
    var filename = "%ssave_%d.dat" % [save_directory, slot]
    
    # 添加元数据
    var save_data = {
        "version": 1,
        "timestamp": Time.get_unix_time_from_system(),
        "playtime": Engine.get_physics_frames() / 60.0,
        "data": data
    }
    
    # 保存
    var file = FileAccess.open(filename, FileAccess.WRITE)
    file.store_var(save_data)
    file.close()
    
    emit_signal("game_saved")

func load_game(slot: int = current_save_slot) -> Dictionary:
    var filename = "%ssave_%d.dat" % [save_directory, slot]
    
    if not FileAccess.file_exists(filename):
        return {}
    
    var file = FileAccess.open(filename, FileAccess.READ)
    var save_data = file.get_var()
    file.close()
    
    emit_signal("game_loaded")
    return save_data["data"]

func get_save_info(slot: int) -> Dictionary:
    var filename = "%ssave_%d.dat" % [save_directory, slot]
    
    if not FileAccess.file_exists(filename):
        return {}
    
    var file = FileAccess.open(filename, FileAccess.READ)
    var save_data = file.get_var()
    file.close()
    
    return {
        "exists": true,
        "timestamp": save_data["timestamp"],
        "playtime": save_data["playtime"],
        "version": save_data["version"]
    }

func delete_save(slot: int):
    var filename = "%ssave_%d.dat" % [save_directory, slot]
    if FileAccess.file_exists(filename):
        DirAccess.remove_absolute(filename)
```

---

## 🔗 相关资源

### Base 层
- [15B_Saving_Games.md](../../base/assets-and-io/15B_Saving_Games.md) - 游戏存档详解

### Wiki 层
- [文件系统指南](../guides/filesystem-guide.md) - 文件操作基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
