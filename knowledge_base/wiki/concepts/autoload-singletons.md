# 单例模式（Autoload Singletons）

> **最后更新**: 2026-04-09  
> **来源**: [02D_Autoload_Singletons.md](../../base/core-systems/02D_Autoload_Singletons.md), [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md)  
> **适用版本**: Godot 4.x

---

## 📚 概念概述

**Autoload 单例** 是 Godot 提供的全局状态管理方案，用于存储跨场景的信息。

---

## 🤔 为什么需要单例

场景系统无法存储跨场景的信息（如玩家分数、库存）。

**解决方案对比**:

| 方案 | 优点 | 缺点 |
|------|------|------|
| 主场景加载其他场景 | 简单 | 无法单独运行子场景 |
| 存储到磁盘 | 持久化 | 频繁读写效率低 |
| **Autoload 单例** | ✅ 始终加载、可访问全局变量 | 需谨慎使用 |

---

## ✨ Autoload 特点

- ✅ 始终加载，无论当前运行哪个场景
- ✅ 可存储全局变量
- ✅ 可处理场景切换
- ✅ 类似单例模式

---

## 🛠️ 创建 Autoload

### 步骤

1. 创建脚本（继承自 `Node`）
2. **项目 → 项目设置 → 全局 → 自动加载**
3. 添加脚本，设置名称

### 设置界面

| 字段 | 说明 |
|------|------|
| 名称 | 节点名称，也是访问名称 |
| 路径 | 脚本或场景路径 |
| 启用 | 是否可直接访问 |

---

## 💻 使用 Autoload

### 直接访问

```gdscript
# 直接使用名称访问
PlayerVariables.health -= 10
```

### 通过路径访问

```gdscript
# 通过 /root/名称 访问
get_node("/root/PlayerVariables").health -= 10
```

### 场景树中的位置

Autoload 节点位于根视口下，其他场景之前：

```
/root
├── PlayerVariables (Autoload)
├── GameManager (Autoload)
└── CurrentScene
```

> **踩坑点**：Autoload 不能使用 `free()` 或 `queue_free()` 删除，否则引擎崩溃。

---

## 🔄 自定义场景切换器

### 创建全局脚本

```gdscript
# global.gd
extends Node

var current_scene = null

func _ready():
    var root = get_tree().root
    current_scene = root.get_child(-1)

func goto_scene(path):
    _deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
    current_scene.free()
    var s = ResourceLoader.load(path)
    current_scene = s.instantiate()
    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene
```

### 使用场景切换器

```gdscript
# scene_1.gd
func _on_button_pressed():
    Global.goto_scene("res://scene_2.tscn")
```

> **踩坑点**：不要在信号回调中直接删除当前场景，使用 `call_deferred()` 延迟执行。

---

## 🚨 Autoload 编码规范 🆕

### 1. 禁止 class_name 声明 🔴 强制

Autoload 脚本不得声明 `class_name`。Autoload 注册名本身就是全局标识符，再声明 `class_name` 会产生命名冲突，导致 "Class 'XXX' hides an autoload singleton" 编译错误。

```gdscript
# ❌ 错误：Autoload 脚本中声明 class_name
# res://autoload/global.gd
class_name Global  # 报错：Class "Global" hides an autoload singleton
extends Node

# ✅ 正确：Autoload 脚本不声明 class_name
# res://autoload/global.gd
extends Node
# "Global" 已通过 Autoload 注册成为全局标识符
```

### 2. 直接名称访问 🔴 强制

Autoload 间互访直接使用注册名称，禁止 `Global.get_node("XXX")`。所有 Autoload 都挂载在 `/root/` 下，互为兄弟节点，不是父子关系。

```gdscript
# ❌ 错误：通过 Global.get_node() 访问兄弟 Autoload
config_manager = Global.get_node("ConfigManager") as ConfigManager  # Node not found!

# ✅ 正确：直接使用 Autoload 全局名称
config_manager = ConfigManager  # Autoload 名称即全局变量

# ✅ 正确：也可以通过 /root/ 路径访问（不推荐，冗长）
config_manager = get_node("/root/ConfigManager")
```

### 3. 类型注解适配 🟡 建议

移除 class_name 后，Autoload 名称不再是类型标识符，不能用于类型注解。

```gdscript
# ❌ 错误：Autoload 移除 class_name 后不能用作类型
var config_manager: ConfigManager  # 报错："ConfigManager" is not a type

# ✅ 正确：使用 Object 类型
var config_manager: Object = ConfigManager

# ✅ 正确：不写类型注解（依赖推断）
var config_manager = ConfigManager
```

### 4. 枚举引用适配 🟡 建议

移除 class_name 后，其他脚本无法通过类名访问枚举。使用整数值+注释或常量映射替代。

```gdscript
# ❌ 错误：跨脚本引用 Autoload 枚举
var current_stage: int = AgeSystem.Stage.OLD_AGE  # AgeSystem 无 class_name

# ✅ 正确：使用整数值 + 注释
var current_stage: int = 3  # Stage.OLD_AGE

# ✅ 正确：在 Autoload 中导出常量映射
# age_system.gd (Autoload)
const STAGE_OLD_AGE: int = 3   # Stage.OLD_AGE

# 其他脚本中使用
var current_stage: int = AgeSystem.STAGE_OLD_AGE
```

### 5. 保留关键字避让 🟡 建议

禁止使用 `trait` 等系统保留关键字作为变量名。`trait` 在 GDScript 4.x 中是为未来特性预留的关键字。

```gdscript
# ❌ 错误：trait 是保留关键字
for trait in initial_res.traits:
    session.traits.append(trait)

# ✅ 正确：使用替代命名
for trait_item in initial_res.traits:
    session.traits.append(trait_item)
```

**详细踩坑记录**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md)

---

## 🔗 相关概念

- [场景树](./scene-tree.md) - 节点树结构和根视口
- [资源系统](./resources-system.md) - 加载场景资源
- [节点操作指南](../guides/node-operations-guide.md) - 节点获取和删除

---

## 📖 来源引用

本文档内容基于 Base 层原始文档整理：
- **来源**: [02D_Autoload_Singletons.md](../../base/core-systems/02D_Autoload_Singletons.md)
- **来源**: [Godot_4x_Autoload_Pitfalls.md](../../base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md)
- **原始来源**: `godot-docs-master/tutorials/scripting/singletons_autoload.rst`

---

**维护者**: Knowledge Base Administrator  
**文档版本**: 1.1
