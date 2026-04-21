# GDScript 代码风格指南

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01H_Style_Guide.md](../../base/gdscript-reference/01H_Style_Guide.md)

---

## 📚 概述

良好的代码风格提高代码可读性、可维护性和团队协作效率。本指南提供 GDScript 代码的完整风格规范。

---

## 🎯 核心内容

### 1. 格式化规则

#### 编码与缩进
- 使用 **LF** 换行符
- 使用 **UTF-8** 编码（无 BOM）
- 使用 **Tab** 缩进（非空格）
- 文件末尾一个空行

```gdscript
# 正确：每级一个 Tab
for i in range(10):
    print("hello")

# 错误：不一致的缩进
for i in range(10):
  print("hello")
```

#### 续行缩进
续行使用 2 级缩进：
```gdscript
# 正确
effect.interpolate_property(sprite, "transform/scale",
        sprite.get_scale(), Vector2(2.0, 2.0), 0.3,
        Tween.TRANS_QUAD, Tween.EASE_OUT)
```

数组、字典、枚举使用 1 级缩进：
```gdscript
# 正确
var party = [
    "Godot",
    "Godette",
    "Steve",
]
```

#### 尾随逗号
多行数组、字典、枚举最后一项加逗号：
```gdscript
# 正确
var array = [
    1,
    2,
    3,
]

# 错误
var array = [
    1,
    2,
    3
]
```

#### 空行
函数和类定义之间用 **2 个空行**：
```gdscript
func heal(amount):
    health += amount


func take_damage(amount):
    health -= amount
```

#### 行长度
- 保持每行 **100 字符以内**
- 尽量 **80 字符以内**

#### 一行一语句
```gdscript
# 正确
if position.x > width:
    position.x = 0

# 错误
if position.x > width: position.x = 0
```

例外：三元运算符
```gdscript
next_state = "idle" if is_on_floor() else "fall"
```

#### 布尔运算符
使用英文版本：
```gdscript
# 正确
if foo and bar or not baz:
    pass

# 错误
if foo && bar || !baz:
    pass
```

#### 注释格式
```gdscript
# 正确：注释后有空格
# This is a comment.

# 错误：注释后无空格
#This is a comment.
```

#### 空格
```gdscript
# 正确
position.x = 5
dict["key"] = 5
my_array = [4, 5, 6]
print("foo")

# 错误
position.x=5
dict ["key"] = 5
my_array = [4,5,6]
print ("foo")
```

#### 引号
优先使用双引号：
```gdscript
# 正确
print("hello world")
print("hello 'world'")  # 避免转义
print('hello "world"')  # 避免转义
```

#### 数字
```gdscript
# 正确
var float_number = 0.234
var other_float = 13.0
var hex_number = 0xfb8c0b
var large_number = 1_234_567_890

# 错误
var float_number = .234
var other_float = 13.
```

### 2. 命名约定

| 类型 | 命名风格 | 示例 |
|------|----------|------|
| 文件名 | snake_case | `yaml_parser.gd` |
| 类名 | PascalCase | `class_name YAMLParser` |
| 节点名 | PascalCase | `Camera3D`, `Player` |
| 函数 | snake_case | `func load_level():` |
| 变量 | snake_case | `var particle_effect` |
| 信号 | snake_case | `signal door_opened` |
| 常量 | CONSTANT_CASE | `const MAX_SPEED = 200` |
| 枚举名 | PascalCase | `enum Element` |
| 枚举成员 | CONSTANT_CASE | `{EARTH, WATER, AIR}` |

#### 私有成员
私有变量和函数前加下划线：
```gdscript
var _counter = 0
func _recalculate_path():
    pass
```

#### 信号命名
使用过去时：
```gdscript
signal door_opened
signal score_changed
```

### 3. 代码顺序

#### 推荐顺序
```gdscript
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. ## 文档注释

05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables

12. _static_init()
13. remaining static methods
14. overridden built-in virtual methods:
    1. _init()
    2. _enter_tree()
    3. _ready()
    4. _process()
    5. _physics_process()
    6. remaining virtual methods
15. overridden custom methods
16. remaining methods
17. inner classes
```

#### 完整示例
```gdscript
class_name StateMachine
extends Node
## Hierarchical state machine for the player.

signal state_changed(previous, new)

@export var initial_state: Node
var is_active = true:
    set = set_is_active

@onready var _state = initial_state:
    set = set_state


func _init():
    add_to_group("state_machine")


func _ready():
    state_changed.connect(_on_state_changed)
    _state.enter()


func _physics_process(delta):
    _state.physics_process(delta)


func transition_to(target_state_path, msg={}):
    if not has_node(target_state_path):
        return
    var target_state = get_node(target_state_path)
    _state.exit()
    self._state = target_state
    _state.enter(msg)


func set_is_active(value):
    is_active = value
    set_physics_process(value)


func _on_state_changed(previous, new):
    state_changed.emit()


class State:
    var foo = 0

    func _init():
        print("Hello!")
```

### 4. 静态类型

#### 显式类型
```gdscript
var health: int = 0
func heal(amount: int) -> void:
    pass
```

#### 类型推断
使用 `:=` 推断类型：
```gdscript
# 正确：类型明确
var direction := Vector3(1, 2, 3)

# 正确：类型需要显式声明
var health: int = 0  # 可能是 int 或 float

# 错误：类型冗余
var direction: Vector3 = Vector3(1, 2, 3)
```

#### get_node 类型
```gdscript
# 正确：显式类型
@onready var health_bar: ProgressBar = get_node("UI/LifeBar")

# 或使用 as 转换
@onready var health_bar := get_node("UI/LifeBar") as ProgressBar

# 错误：推断为 Node
@onready var health_bar := get_node("UI/LifeBar")
```

---

## ✅ 最佳实践

1. **统一使用 Tab 缩进** - 保持团队代码一致性
2. **遵循命名约定** - 提高代码可读性
3. **保持代码顺序** - 便于快速查找
4. **优先使用类型推断** - 简洁且类型明确
5. **使用 2 个空行分隔函数** - 清晰的视觉分隔

---

## 🔗 相关页面

### Base 层来源
- [01H_Style_Guide.md](../../base/gdscript-reference/01H_Style_Guide.md) - 完整代码风格指南

### Wiki 层相关
- [GDScript 基础语法](./gdscript-basics.md) - 基础语法
- [GDScript 代码规范](./gdscript-standards.md) - 代码规范标准
- [GDScript 静态类型指南](./gdscript-static-typing.md) - 类型注解

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
