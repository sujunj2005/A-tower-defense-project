# Godot 4.x Autoload 单例踩坑记录（§27-§31）

> **适用版本**: Godot 4.x（特别是 4.6+）
> **创建日期**: 2026-04-09
> **来源**: tower_defense 项目实战经验
> **重要性**: 🔴 必读 - Autoload 单例开发必知陷阱

---

## §27 Autoload 脚本禁止 class_name 声明 🔴 高

**问题**: Autoload 脚本添加 `class_name` 会导致 "Class 'XXX' hides an autoload singleton" 编译错误

**原因**: Autoload 注册名本身就是全局标识符，再声明 class_name 会产生命名冲突。Godot 将 Autoload 名称注册为全局变量，同时 class_name 也会注册为全局类名，两者指向同一脚本但使用不同的标识符机制，导致冲突。

**解决方案**: 移除所有 Autoload 脚本的 `class_name` 声明，Autoload 名称即全局变量名

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

**影响范围**: 所有 Autoload 单例脚本

**注意事项**:
- 移除 `class_name` 后，该 Autoload 类型不能作为类型注解使用（如 `var x: Global` 会报错）
- 需要引用 Autoload 类型时，使用 `Object` 类型或不写类型注解
- 移除 `class_name` 后，跨脚本枚举引用需用整数值+注释替代

---

## §28 Autoload 单例间互访不能用 Global.get_node() 🔴 高

**问题**: 使用 `Global.get_node("ConfigManager")` 访问其他 Autoload 单例会报 "Node not found" 错误

**原因**: Godot 4.x 中所有 Autoload 都挂载在 `/root/` 下，互为兄弟节点，不是 Global 的子节点。`get_node()` 是相对路径查找，在 Global 节点下找不到 ConfigManager，因为它们是同级关系。

**解决方案**: 直接使用 Autoload 注册名称作为全局变量访问

```gdscript
# ❌ 错误：通过 Global.get_node() 访问兄弟 Autoload
config_manager = Global.get_node("ConfigManager") as ConfigManager  # Node not found!

# ✅ 正确：直接使用 Autoload 全局名称
config_manager = ConfigManager  # Autoload 名称即全局变量

# ✅ 正确：也可以通过 /root/ 路径访问（不推荐，冗长）
config_manager = get_node("/root/ConfigManager")
```

**节点树结构说明**:
```
/root
  ├── Global          ← Autoload，/root 的子节点
  ├── ConfigManager   ← Autoload，/root 的子节点
  ├── AgeSystem       ← Autoload，/root 的子节点
  └── ...             ← 都是兄弟关系，不是父子关系
```

**关键理解**:
- Autoload 节点都是 `/root` 的直接子节点
- Autoload 之间是兄弟关系，不是父子关系
- `Global.get_node("ConfigManager")` 会在 Global 的子节点中查找，自然找不到
- Autoload 注册名称自动成为全局变量，直接使用即可

---

## §29 trait 是 GDScript 4.x 保留关键字 🟡 中

**问题**: 使用 `trait` 作为变量名会导致解析错误 "Expected loop variable name after 'for'"

**原因**: `trait` 在 GDScript 4.x 中是系统保留关键字（为未来特性预留）。虽然当前版本未实现 trait 功能，但关键字已被保留，不能用作标识符。

**解决方案**: 使用 `trait_item`、`trait_data` 等替代命名

```gdscript
# ❌ 错误：trait 是保留关键字
for trait in initial_res.traits:
    session.traits.append(trait)

# ✅ 正确：使用替代命名
for trait_item in initial_res.traits:
    session.traits.append(trait_item)
```

**其他已知保留关键字**:
- `trait` - 为未来 trait 特性预留
- 避免使用可能成为未来关键字的标识符

**最佳实践**:
- 如果变量名在编辑器中显示异常高亮或解析错误，检查是否使用了保留关键字
- 使用语义化的替代命名（如 `trait_data`、`trait_type`、`trait_item`）

---

## §30 GUT 测试框架 API 陷阱 🟡 中

**问题1**: `summary.get_test_count()` 不存在，运行时报 "Nonexistent function"

**问题2**: `var gut: Gut` 类型声明报错 '"Gut" is a variable but does not contain a type'

**问题3**: Lambda 回调方式验证信号不可靠，测试断言失败

**原因1**: GUT 测试框架的 API 在不同版本间有较大变化，`get_test_count()` 是旧版 API，v9.6.0+ 已移除

**原因2**: Gut 是通过 Autoload 加载的，没有 `class_name` 声明（参见 §27），因此不能作为类型注解使用

**原因3**: Lambda 回调的执行时机不确定，信号可能在断言检查之后才触发回调

**解决方案**:

### 30.1 正确获取测试统计信息

```gdscript
# ❌ 错误：不存在的 API
var total_tests = summary.get_test_count()

# ✅ 正确：GUT v9.6.0+ 正确 API
var totals = gut.get_summary().get_totals(gut)
var total_tests: int = totals.tests
var passed_tests: int = totals.passing_tests
var failed_tests: int = totals.failing_tests
```

### 30.2 正确声明 Gut 变量类型

```gdscript
# ❌ 错误：Gut 作为类型
var gut: Gut  # "Gut" is a variable but does not contain a type

# ✅ 正确：使用 Object 类型
var gut: Object = load("res://addons/gut/gut.gd").new()
```

### 30.3 正确验证信号发射

```gdscript
# ❌ 错误：Lambda 回调验证信号
var signal_received = false
battle_manager.home_health_changed.connect(func(_v): signal_received = true)
assert_true(signal_received)  # 不可靠

# ✅ 正确：使用 GUT 内置信号监控
watch_signals(battle_manager)
assert_signal_emitted(battle_manager, "home_health_changed")
```

### 30.4 获取失败测试详情

```gdscript
# ✅ 正确：获取失败测试详情
func _print_failed_tests(gut: Object) -> void:
    var tc = gut.get_test_collector()
    for s in tc.scripts:
        for t in s.tests:
            if t.was_run and not t.is_passing():
                print("  - %s: %s" % [t.name, str(t.fail_texts)])
```

**GUT API 版本对照**:

| API | 旧版本 | v9.6.0+ |
|-----|--------|---------|
| 获取测试总数 | `summary.get_test_count()` | `gut.get_summary().get_totals(gut).tests` |
| 获取通过数 | `summary.get_pass_count()` | `gut.get_summary().get_totals(gut).passing_tests` |
| 获取失败数 | `summary.get_fail_count()` | `gut.get_summary().get_totals(gut).failing_tests` |
| Gut 类型声明 | `var gut: Gut` | `var gut: Object` |
| 信号验证 | Lambda 回调 | `watch_signals()` + `assert_signal_emitted()` |

---

## §31 := 类型推断限制与 .godot 缓存问题 🟡 中

**问题1**: `:=` 类型推断在右侧类型不明确时报错 "Cannot infer the type of variable"

**问题2**: 恢复 class_name 后报 "hides a global script class" 缓存错误

**原因1**: `:=` 要求右侧表达式的类型在编译时可确定。当函数返回 Variant 或类型不明确时，编译器无法推断变量类型

**原因2**: Godot 的 `.godot` 目录缓存了旧的类注册信息。删除 class_name 后又恢复，缓存中的旧注册信息与新的 class_name 冲突

**解决方案**:

### 31.1 类型推断限制

```gdscript
# ❌ 错误：右侧类型不明确时使用 :=
var total_tests := summary.get_test_count()  # Cannot infer type

# ✅ 正确：显式类型声明
var total_tests: int = totals.tests

# ✅ 正确：右侧类型明确时可以使用 :=
var health := 100           # int，类型明确
var speed := 5.0            # float，类型明确
var name := "Player"        # String，类型明确
var node := get_node("X")   # Node，返回类型明确

# ❌ 错误：返回 Variant 的函数
var result := some_dict.get("key")  # Variant，无法推断

# ✅ 正确：显式类型声明或 as 转换
var result: String = some_dict.get("key", "")
var result := some_dict.get("key") as String
```

### 31.2 .godot 缓存问题

```bash
# 缓存问题解决方案：删除 .godot 目录后重新打开项目
# 项目根目录/.godot/ ← 删除此目录，Godot 会自动重建
```

**注意事项**:
- 删除 `.godot` 目录后，Godot 重新打开项目时会重建缓存，可能需要较长时间
- 删除前确保没有未保存的修改
- 此方法可解决大多数与类注册、缓存相关的编译错误

**何时使用 := 类型推断**:

| 场景 | 是否使用 := | 原因 |
|------|-----------|------|
| 字面量赋值 | ✅ 使用 | 类型明确 |
| 内置类型函数返回值 | ✅ 使用 | 返回类型明确 |
| 自定义函数返回值 | ⚠️ 谨慎 | 需确认返回类型 |
| Dictionary.get() | ❌ 不使用 | 返回 Variant |
| load() / preload() | ⚠️ 谨慎 | 返回 Variant |
| get_node() | ✅ 可用 | 返回 Node |

---

## 📊 严重性统计

| 严重性 | 数量 | 章节 |
|--------|------|------|
| 🔴 **高** | 2 | §27, §28 |
| 🟡 **中** | 3 | §29, §30, §31 |

---

## 🔗 相关文档

### 本项目知识库
- [踩坑记录完整索引](../../../踩坑记录完整索引.md)
- [GDScript 编码规范汇总](../../../Godot%20编码规范汇总.md)
- [Autoload 单例概念](../../wiki/concepts/autoload-singletons.md)
- [常见踩坑避雷指南](../../wiki/guides/common-pitfalls.md)
- [GDScript 代码规范](../../wiki/concepts/gdscript-standards.md)

### Base 层相关文档
- [19_Pitfall_Records.md](./19_Pitfall_Records.md)
- [GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md)
- [GDScript_Code_Standards.md](../code-standards/GDScript_Code_Standards.md)

---

**文档版本**: 1.0
**创建日期**: 2026-04-09
**维护者**: Knowledge Base Administrator
**来源**: tower_defense 项目实战经验
