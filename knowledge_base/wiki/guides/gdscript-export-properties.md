# GDScript 导出属性指南

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [01F_Export_Properties.md](../../base/gdscript-reference/01F_Export_Properties.md)

---

## 📚 概述

导出属性允许在 Godot 编辑器中检查和修改脚本变量。本指南详细介绍各种导出选项和最佳实践。

---

## 🎯 核心内容

### 1. 导出属性基础

#### 基本语法
```gdscript
@export var number: int = 5
@export var speed: float = 10.0
@export var player_name: String = "Hero"
@export var damage := 25.0  # 自动推断为 float
@export var health: int   # 无默认值需指定类型
```

#### 导出规则
- 导出变量必须初始化为常量表达式，或指定类型
- 即使脚本不在编辑器中运行，导出属性仍可编辑
- getter/setter 只在 `@tool` 模式下生效

### 2. 分组导出

#### 导出组和子组
```gdscript
@export_group("Combat")
@export var damage: int = 10

@export_subgroup("Advanced")
@export var critical_chance: float = 0.1

@export_group("")  # 退出当前组
```

#### 导出分类
```gdscript
@export_category("Main Category")
@export var number = 3

@export_category("Extra Category")
@export var flag = false
```

> **⚠️ 踩坑点**: 分类会打破基于类继承的属性组织，使用时需谨慎。

### 3. 路径字符串导出

```gdscript
@export_file("*.tscn") var level_path: String
@export_dir var save_dir: String
@export_multiline var description: String
```

### 4. 范围限制导出

#### 整数/浮点范围
```gdscript
@export_range(0, 20) var health: int
@export_range(0.0, 1.0) var volume: float
@export_range(0, 100, 5) var score: int  # 带步进
```

#### 范围提示
```gdscript
@export_range(0, 100, 1, "or_less", "or_greater") var value: int
@export_range(0, 360, 0.1, "radians_as_degrees") var angle: float
@export_range(0, 100, 1, "suffix:m") var distance: int
```

### 5. 颜色/节点/资源导出

#### 颜色
```gdscript
@export var color: Color
@export_color_no_alpha var solid_color: Color
```

#### 节点
```gdscript
@export var sprite: Sprite2D
@export_node_path("Button") var button_path: NodePath
```

#### 资源
```gdscript
@export var texture: Texture2D
@export var font: Font
@export var scenes: Array[PackedScene] = []
```

> **⚠️ 踩坑点**: `@export` 的资源会在场景加载时一起加载。对于大型场景，使用 `@export_file` 延迟加载。

### 6. 位标志/枚举/数组导出

#### 位标志
```gdscript
@export_flags("Fire", "Water", "Earth", "Wind") var spell_elements: int = 0
@export_flags_2d_physics var layers_2d_physics: int
```

#### 枚举
```gdscript
enum CharacterClass { WARRIOR, MAGE, ROGUE }
@export var character_class: CharacterClass

@export_enum("Warrior", "Magician", "Thief") var character_int: int
@export_enum("Rebecca", "Mary") var name: String = "Rebecca"
```

#### 数组
```gdscript
@export var items: Array = [1, 2, 3]
@export var scores: Array[int] = [10, 20, 30]
@export var textures: Array[Texture] = []
```

### 7. 高级导出

#### @export_storage / @export_custom
```gdscript
@export_storage var hidden_var  # 存储，不显示
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var altitude: float
```

#### @export_tool_button
```gdscript
@tool
@export_tool_button("Hello") var hello_action = hello

func hello():
    print("Hello world!")
```

#### setter 中处理
```gdscript
@export var health: int = 100:
    set(value):
        health = clamp(value, 0, max_health)
        update_health_display()
```

> **⚠️ 踩坑点**: 在 `_init()` 中读取导出变量返回默认值，检查器值在对象构造后才设置。应在 `_ready()` 或 setter 中读取。

---

## ✅ 最佳实践

1. **使用分组组织属性** - 提高编辑器可读性
2. **使用范围限制** - 防止无效值
3. **延迟加载大型资源** - 使用 `@export_file` 而非 `@export`
4. **使用 setter 验证值** - 确保数据有效性
5. **合理使用位标志** - 适合多选场景

---

## 🔗 相关页面

### Base 层来源
- [01F_Export_Properties.md](../../base/gdscript-reference/01F_Export_Properties.md) - 完整导出属性文档

### Wiki 层相关
- [GDScript 基础语法](./gdscript-basics.md) - 基础语法
- [GDScript 类型系统](./gdscript-types.md) - 类型和变量
- [GDScript 代码规范](./gdscript-standards.md) - 代码风格

### 实体页面
- [防御塔实体设计](../entities/tower.md) - 导出属性实战
- [敌人实体设计](../entities/enemy.md) - 导出属性实战

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**来源版本**: Godot 4.x
