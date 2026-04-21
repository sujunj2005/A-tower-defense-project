# GDScript Godot 4.x 导出属性

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/scripting/gdscript/gdscript_exports.rst

---

## 目录

1. [导出属性基础](#1-导出属性基础)
2. [分组导出](#2-分组导出)
3. [路径字符串导出](#3-路径字符串导出)
4. [范围限制导出](#4-范围限制导出)
5. [颜色/节点/资源导出](#5-颜色节点资源导出)
6. [位标志/枚举/数组导出](#6-位标志枚举数组导出)
7. [高级导出](#7-高级导出)

---

## 1. 导出属性基础

### 1.1 基本语法

```gdscript
@export var number: int = 5
@export var speed: float = 10.0
@export var player_name: String = "Hero"
@export var damage := 25.0  # 自动推断为 float
@export var health: int   # 无默认值需指定类型
```

### 1.2 导出规则

- 导出变量必须初始化为常量表达式，或指定类型
- 即使脚本不在编辑器中运行，导出属性仍可编辑
- getter/setter 只在 `@tool` 模式下生效

---

## 2. 分组导出

### 2.1 导出组和子组

```gdscript
@export_group("Combat")
@export var damage: int = 10

@export_subgroup("Advanced")
@export var critical_chance: float = 0.1

@export_group("")  # 退出当前组
```

### 2.2 导出分类

```gdscript
@export_category("Main Category")
@export var number = 3

@export_category("Extra Category")
@export var flag = false
```

> **踩坑点**：分类会打破基于类继承的属性组织，使用时需谨慎。

---

## 3. 路径字符串导出

```gdscript
@export_file("*.tscn") var level_path: String
@export_dir var save_dir: String
@export_multiline var description: String
```

---

## 4. 范围限制导出

### 4.1 整数/浮点范围

```gdscript
@export_range(0, 20) var health: int
@export_range(0.0, 1.0) var volume: float
@export_range(0, 100, 5) var score: int  # 带步进
```

### 4.2 范围提示

```gdscript
@export_range(0, 100, 1, "or_less", "or_greater") var value: int
@export_range(0, 360, 0.1, "radians_as_degrees") var angle: float
@export_range(0, 100, 1, "suffix:m") var distance: int
```

---

## 5. 颜色/节点/资源导出

### 5.1 颜色

```gdscript
@export var color: Color
@export_color_no_alpha var solid_color: Color
```

### 5.2 节点

```gdscript
@export var sprite: Sprite2D
@export_node_path("Button") var button_path: NodePath
```

### 5.3 资源

```gdscript
@export var texture: Texture2D
@export var font: Font
@export var scenes: Array[PackedScene] = []
```

> **踩坑点**：`@export` 的资源会在场景加载时一起加载。对于大型场景，使用 `@export_file` 延迟加载。

---

## 6. 位标志/枚举/数组导出

### 6.1 位标志

```gdscript
@export_flags("Fire", "Water", "Earth", "Wind") var spell_elements: int = 0
@export_flags_2d_physics var layers_2d_physics: int
```

### 6.2 枚举

```gdscript
enum CharacterClass { WARRIOR, MAGE, ROGUE }
@export var character_class: CharacterClass

@export_enum("Warrior", "Magician", "Thief") var character_int: int
@export_enum("Rebecca", "Mary") var name: String = "Rebecca"
```

### 6.3 数组

```gdscript
@export var items: Array = [1, 2, 3]
@export var scores: Array[int] = [10, 20, 30]
@export var textures: Array[Texture] = []
```

---

## 7. 高级导出

### 7.1 @export_storage / @export_custom

```gdscript
@export_storage var hidden_var  # 存储，不显示
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var altitude: float
```

### 7.2 @export_tool_button

```gdscript
@tool
@export_tool_button("Hello") var hello_action = hello

func hello():
    print("Hello world!")
```

### 7.3 setter 中处理

```gdscript
@export var health: int = 100:
    set(value):
        health = clamp(value, 0, max_health)
        update_health_display()
```

> **踩坑点**：在 `_init()` 中读取导出变量返回默认值，检查器值在对象构造后才设置。应在 `_ready()` 或 setter 中读取。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/scripting/gdscript/gdscript_exports.rst`
