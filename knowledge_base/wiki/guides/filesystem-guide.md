# 文件系统与资源管理指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 15A_File_System.md](../../base/assets-and-io/15A_File_System.md), [15B_Saving_Games.md](../../base/assets-and-io/15B_Saving_Games.md)  
> **重要性**: 🔴 必读 - 文件操作完整指南

---

## 📋 概述

本指南涵盖 Godot 中的文件系统访问、资源导入、数据持久化等 I/O 操作。

---

## 🎯 核心概念

### 1. 路径类型

**res://**: 项目资源目录（只读，导出后不可访问）
**user://**: 用户数据目录（可读写，用于存档）

```gdscript
# 项目资源路径
var resource_path = "res://scenes/player.tscn"

# 用户数据路径
var save_path = "user://savegame.dat"
```

### 2. 文件系统访问

```gdscript
# 检查文件是否存在
var dir = DirAccess.open("res://")
if dir.file_exists("data.txt"):
    print("文件存在")

# 列出目录内容
dir.list_dir_begin()
var file_name = dir.get_next()
while file_name != "":
    print(file_name)
    file_name = dir.get_next()

# 创建目录
dir.make_dir("user://saves")

# 删除文件
dir.remove("user://old_save.dat")
```

### 3. 文件读写

```gdscript
# 写入文件
var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
file.store_string("Hello, World!")
file.store_var(42)  # 存储变量
file.store_line("Line 1")  # 自动换行
file.close()

# 读取文件
file = FileAccess.open("user://save.dat", FileAccess.READ)
var content = file.get_as_text()  # 读取全部
var line = file.get_line()  # 读取一行
var value = file.get_var()  # 读取变量
file.close()
```

---

## 🔧 实战技巧

### 1. JSON 数据

```gdscript
# 写入 JSON
var data = {
    "player_name": "Hero",
    "level": 5,
    "position": Vector2(100, 200)
}

var json_string = JSON.stringify(data)
var file = FileAccess.open("user://save.json", FileAccess.WRITE)
file.store_string(json_string)
file.close()

# 读取 JSON
file = FileAccess.open("user://save.json", FileAccess.READ)
json_string = file.get_as_text()
var json = JSON.parse_string(json_string)
print(json["player_name"])
```

### 2. 存档系统

```gdscript
class_name SaveSystem

static func save_game(player: Node, filename: String = "user://save.dat"):
    var file = FileAccess.open(filename, FileAccess.WRITE)
    var data = {
        "position": player.position,
        "health": player.health,
        "inventory": player.inventory
    }
    file.store_var(data)
    file.close()

static func load_game(player: Node, filename: String = "user://save.dat"):
    if not FileAccess.file_exists(filename):
        return false
    
    var file = FileAccess.open(filename, FileAccess.READ)
    var data = file.get_var()
    player.position = data["position"]
    player.health = data["health"]
    player.inventory = data["inventory"]
    file.close()
    return true
```

---

## 🔗 相关资源

### Base 层
- [15A_File_System.md](../../base/assets-and-io/15A_File_System.md) - 文件系统详解
- [15B_Saving_Games.md](../../base/assets-and-io/15B_Saving_Games.md) - 游戏存档
- [15C_Importing_Images.md](../../base/assets-and-io/15C_Importing_Images.md) - 图片导入
- [15D_Background_Loading.md](../../base/assets-and-io/15D_Background_Loading.md) - 后台加载

### Wiki 层
- [图片导入指南](../guides/importing-images-guide.md) - 图片资源导入
- [游戏存档指南](../guides/saving-games-guide.md) - 存档系统实现
- [后台加载指南](../guides/background-loading-guide.md) - 资源异步加载

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
