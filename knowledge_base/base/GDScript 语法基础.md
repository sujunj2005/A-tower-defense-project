# GDScript 语法基础

Godot 4.x 专属脚本语言的核心语法参考。

## 1. 变量与类型

```gdscript
# 基本类型声明
var health: int = 100
var name_str: String = "Player"
var is_alive: bool = true
var speed: float = 200.0
var position: Vector2 = Vector2.ZERO
var color: Color = Color.WHITE

# 类型推断
var inferred_int := 42       # int
var inferred_str := "hello"  # String
var inferred_arr := [1, 2]   # Array

# 导出变量（编辑器可见）
@export var max_health: int = 100
@export_range(0, 100) var volume: int = 50
@export_file("*.json") var data_file: String
```

## 2. 常量与枚举

```gdscript
const MAX_SPEED := 500.0
const GRAVITY := 980.0

enum State { IDLE, RUNNING, JUMPING, DEAD }
var current_state: State = State.IDLE
```

## 3. 控制流

```gdscript
# if-elif-else
if health <= 0:
    die()
elif health < 30:
    show_warning()
else:
    attack()

# match（模式匹配）
match current_state:
    State.IDLE:
        play_idle_animation()
    State.RUNNING:
        play_run_animation()
    _:
        push_warning("Unknown state")

# for 循环
for i in range(10):
    print(i)

for child in get_children():
    child.queue_free()

# while 循环
while health > 0 and enemies_remaining > 0:
    process_turn()
```

## 4. 数组与字典

```gdscript
# 数组
var items: Array[int] = [1, 2, 3]
items.append(4)
items.erase(2)
for item in items:
    print(item)

# 字典
var player: Dictionary = {
    "name": "Hero",
    "level": 5,
    "items": ["sword", "shield"]
}
player["gold"] = 100
if player.has("exp"):
    print(player["exp"])
```

## 5. 函数

```gdscript
# 基本函数
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

# 返回值
func get_display_name() -> String:
    return name_str + " Lv." + str(level)

# 默认参数
func move(direction: Vector2, speed: float = 200.0) -> void:
    position += direction * speed * delta

# 静态函数
static func create_enemy(type: String) -> Enemy:
    var enemy := Enemy.new()
    enemy.type = type
    return enemy
```

## 6. 类与继承

```gdscript
# 类名声明（必须放在文件第一行可执行代码）
class_name Player
extends CharacterBody2D

# 构造函数
func _init(start_health: int = 100) -> void:
    health = start_health

# 虚函数重写
func _ready() -> void:
    super._ready()  # 调用父类方法
    setup_ui()
```

## 7. 信号

```gdscript
# 声明
signal health_changed(new_health: int)
signal died

# 发射
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        died.emit()

# 连接
func _ready() -> void:
    player.health_changed.connect(_on_health_changed)
```

## 8. 常用工具函数

```gdscript
# 打印
print("debug info")
push_warning("something wrong")
push_error("critical error")

# 随机
var r := randi() % 100       # 0-99
var f := randf()             # 0.0-1.0
var arr := [1, 2, 3]
arr.shuffle()
```

## 参考来源

- Godot 4.x 官方文档：GDScript reference
- 项目 `scripts/bean/option_data.gd` — 典型 Bean 类示例
- 项目 `scripts/ui/event_ui.gd` — UI 脚本示例
