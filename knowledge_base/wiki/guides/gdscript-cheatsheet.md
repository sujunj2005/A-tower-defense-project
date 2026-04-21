# GDScript 速查表

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 19A_GDScript_Cheatsheet.md](../../base/quick-reference/19A_GDScript_Cheatsheet.md)  
> **重要性**: 🔴 必读 - 快速查询手册

---

## 📋 概述

本速查表包含 GDScript 开发的常用语法和模式，适合快速查阅。

---

## 🎯 基础语法

### 变量和数据类型

```gdscript
# 变量声明
var name: String = "Player"
var age: int = 25
var health: float = 100.0
var is_alive: bool = true

# 类型推断
var message = "Hello"  # 自动推断为 String

# 常量
const MAX_HEALTH = 100
const GRAVITY = -9.8

# 枚举
enum State { IDLE, WALK, RUN, JUMP }
var current_state: State = State.IDLE
```

### 控制结构

```gdscript
# 条件语句
if health > 50:
    print("健康")
elif health > 20:
    print("受伤")
else:
    print("危险")

# 匹配语句（switch）
match current_state:
    State.IDLE:
        play_idle()
    State.WALK, State.RUN:
        play_movement()
    _:
        play_other()

# 循环
for i in range(10):
    print(i)

for i in range(5, 10):
    print(i)  # 5 到 9

for i in range(0, 10, 2):
    print(i)  # 0, 2, 4, 6, 8

while is_running:
    process()
    if should_stop:
        break
```

---

## 🎯 常用函数

### 数学函数

```gdscript
# 基本运算
abs(-5)           # 5
ceil(3.2)         # 4
floor(3.8)        # 3
round(3.5)        # 4
sign(-5)          # -1

# 三角函数
sin(deg_to_rad(45))
cos(deg_to_rad(45))
atan2(y, x)

# 插值
lerp(0, 100, 0.5)        # 50
lerp_angle(0, TAU, 0.5)  # 角度插值

# 限制
clamp(150, 0, 100)       # 100
min(5, 10)               # 5
max(5, 10)               # 10
```

### 字符串函数

```gdscript
var text = "Hello, World!"

text.length()              # 13
text.to_upper()            # "HELLO, WORLD!"
text.to_lower()            # "hello, world!"
text.substr(0, 5)          # "Hello"
text.replace("World", "GDScript")  # "Hello, GDScript!"
text.split(", ")           # ["Hello", "World!"]
```

### 数组和字典

```gdscript
# 数组
var arr = [1, 2, 3]
arr.append(4)
arr.remove_at(0)
arr.size()
arr.has(2)
arr.find(2)
arr.shuffle()

# 字典
var dict = {"key": "value", "count": 42}
dict.keys()
dict.values()
dict.has("key")
dict.size()
dict.erase("key")
```

---

## 🎯 信号

```gdscript
# 定义信号
signal health_changed(new_value)
signal player_died

# 发射信号
emit_signal("health_changed", 80)
health_changed.emit(80)  # GDScript 4.x

# 连接信号
health_changed.connect(_on_health_changed)

# 断开连接
health_changed.disconnect(_on_health_changed)

# 回调函数
func _on_health_changed(new_value):
    update_health_bar(new_value)
```

---

## 🎯 节点操作

```gdscript
# 获取节点
var player = $Player
var sprite = $Player/Sprite2D

# 获取节点（代码方式）
var player = get_node("Player")
var sprite = get_node_or_null("Player/Sprite2D")

# 场景树
get_tree().change_scene_to_file("res://level2.tscn")
get_tree().quit()
get_tree().get_nodes_in_group("enemies")

# 调用方法
call("method_name")
call_deferred("method_name")
set("property", value)
get("property")
```

---

## 🔗 相关资源

### Base 层
- [19A_GDScript_Cheatsheet.md](../../base/quick-reference/19A_GDScript_Cheatsheet.md) - GDScript 速查表
- [19B_Common_Patterns.md](../../base/quick-reference/19B_Common_Patterns.md) - 常用模式
- [19C_API_Commonly_Used.md](../../base/quick-reference/19C_API_Commonly_Used.md) - 常用 API

### Wiki 层
- [常用模式指南](../guides/common-patterns-guide.md) - GDScript 设计模式
- [常用 API 参考](../guides/api-commonly-used.md) - Godot API 速查

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
