# GUT 测试框架踩坑记录

> **适用版本**: Godot 4.x + GUT v9.6.0+  
> **最后更新**: 2026-04-09  
> **来源**: Layer 2-4 测试调试过程  
> **重要性**: 🔴 必读 - GUT 测试开发必读

---

## 目录

1. [§32 GUT 测试运行器模式导致框架挂起](#32-gut-测试运行器模式导致框架挂起-🔴-高)
2. [§33 before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起](#33-before_eachafter_each-修改-autoload-全局引用导致-gut-挂起-🔴-高)
3. [§34 watch_signals() 在 Autoload 实例上导致 GUT 挂起](#34-watch_signals-在-autoload-实例上导致-gut-挂起-🔴-高)
4. [§35 测试中引用了不存在的类属性](#35-测试中引用了不存在的类属性-🟡-中)
5. [§36 select_option() 第二个参数类型错误](#36-select_option-第二个参数类型错误-🟡-中)

---

## §32 GUT 测试运行器模式导致框架挂起 🔴 高

**问题**: 使用 `gut.add_script()` + `gut.test_scripts()` 模式运行 GUT 测试时，测试框架会在 `gut.gd:818 _test_the_scripts` 处无限挂起，无法完成测试。

**根因**: GUT 框架在 Godot 4.x 中，`add_script()` + `test_scripts()` 的调用流程与 `GutConfig` + `run_tests()` 不同，前者在某些场景下（特别是涉及 Autoload 的测试）会导致内部状态异常。

**解决方案**: 必须使用 `GutConfig` + `run_tests()` 模式，即：

```gdscript
# ❌ 错误：使用 add_script + test_scripts 模式
var gut = load("res://addons/gut/gut.gd").new()
add_child(gut)
gut.add_script("res://tests/unit/test_xxx.gd")
gut.test_scripts()  # 会导致框架挂起！

# ✅ 正确：使用 GutConfig + run_tests 模式
var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

var gut: Object
var gut_config: Object

func _ready() -> void:
    gut = Gut.new()
    add_child(gut)
    gut_config = GutConfig.new()
    var config_result = gut_config._load_options_from_config_file(
        "res://.gutconfig_xxx.json",
        gut_config.options
    )
    if config_result != 1:
        push_error("加载 GUT 配置文件失败")
        return
    gut_config._apply_options(gut_config.options, gut)
    gut.end_run.connect(_on_gut_end_run)
    gut.run_tests()  # 关键：用 run_tests() 而非 test_scripts()
```

**配置文件格式**（.gutconfig_xxx.json）：

```json
{
  "tests": ["res://tests/unit/test_xxx.gd"],
  "prefix": "test_",
  "suffix": ".gd",
  "log_level": 1,
  "should_exit": false,
  "should_exit_on_success": false,
  "should_maximize": false,
  "hide_orphans": false,
  "disable_colors": false
}
```

**来源**: Layer 2-4 测试调试过程

---

## §33 before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起 🔴 高

**问题**: 在 GUT 测试的 `before_each()` 中替换 `Global.game_session` 为新的 `GameSessionData` 实例，并在 `after_each()` 中恢复，会导致 GUT 测试框架挂起。

**根因**: Autoload 单例（如 `EventSystem`）在 `_ready()` 中通过 `session = Global.get_game_session()` 获取引用。如果测试中替换了 `Global.game_session` 对象本身（而非修改其属性），Autoload 持有的 `session` 引用仍指向旧对象，导致状态不一致。同时，GUT 框架对全局 Autoload 状态的变更非常敏感，替换整个对象会触发框架内部异常。

**解决方案**:

1. **不要替换 Autoload 引用的对象本身**，而是直接操作 Autoload 持有的引用（如 `EventSystem.session`）

2. 在每个测试函数内手动保存和恢复被修改的字段值：

```gdscript
# ❌ 错误：替换 Autoload 引用的对象本身
func before_each() -> void:
    _old_session = Global.game_session
    Global.game_session = GameSessionData.new()  # 导致 GUT 挂起！

func after_each() -> void:
    Global.game_session = _old_session

# ✅ 正确：直接操作 Autoload 持有的引用字段
func test_something() -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    # ... 执行测试 ...
    session.gold = old_gold  # 恢复
```

3. 对于不依赖 Autoload 的纯数据类（如 `GameSessionData`），直接用 `.new()` 创建独立实例测试：

```gdscript
# ✅ 推荐：纯数据类直接创建独立实例
func test_session_gold() -> void:
    var session: GameSessionData = GameSessionData.new()
    session.gold = 100
    assert_eq(session.gold, 100, "金币应正确设置")
```

**来源**: Layer 2-4 测试调试过程

---

## §34 watch_signals() 在 Autoload 实例上导致 GUT 挂起 🔴 高

**问题**: 在 GUT 测试中对 Autoload 单例（如 `EventSystem`、`AgeSystem`）调用 `watch_signals()` 会导致测试框架无限挂起。

**根因**: GUT 的 `watch_signals()` 机制需要对目标对象进行信号监听注册，但 Autoload 单例的生命周期由 Godot 引擎管理，与测试框架的生命周期不一致，导致信号监听无法正常清理。

**解决方案**: 避免对 Autoload 实例使用 `watch_signals()` 和 `assert_signal_emitted()`，改为基于状态的断言（检查 Autoload 持有的 session 数据变化来间接验证信号效果）。

```gdscript
# ❌ 错误：对 Autoload 使用 watch_signals
func test_event_system() -> void:
    watch_signals(EventSystem)  # 导致 GUT 挂起！
    EventSystem.select_option(event_data, option)
    assert_signal_emitted(EventSystem, "option_selected")

# ✅ 正确：基于状态的断言
func test_event_system() -> void:
    var session: GameSessionData = EventSystem.session
    var old_gold: int = session.gold
    EventSystem.select_option(event_data, gold_option)
    assert_gt(session.gold, old_gold, "选择金币选项后金币应增加")
```

**来源**: Layer 2-4 测试调试过程

---

## §35 测试中引用了不存在的类属性 🟡 中

**问题**: 测试文件 `test_session_data_extended.gd` 中使用了 `session.owned_towers` 字段，但 `GameSessionData` 类中实际没有 `owned_towers` 属性（只有 `towers: Array[Dictionary]`）。

**根因**: 编写测试时未对照实际类定义，凭记忆假设了字段名。

**解决方案**: 编写测试前必须先读取被测类的源码，确认所有属性名和方法签名。对于 `GameSessionData`，塔数据存储在 `towers: Array[Dictionary]` 中，每项为 `{"tower_id": "xxx", "count": N}` 格式。

```gdscript
# ❌ 错误：凭记忆假设字段名
func test_towers() -> void:
    assert_eq(session.owned_towers.size(), 0)  # owned_towers 不存在！

# ✅ 正确：先确认类定义再编写测试
# GameSessionData 中的实际定义：
# var towers: Array[Dictionary] = []
# 每项格式：{"tower_id": "xxx", "count": N}
func test_towers() -> void:
    assert_eq(session.towers.size(), 0, "初始塔列表应为空")
    session.towers.append({"tower_id": "archer", "count": 1})
    assert_eq(session.towers.size(), 1, "添加后塔列表应有1项")
```

**来源**: Layer 2-4 测试调试过程

---

## §36 select_option() 第二个参数类型错误 🟡 中

**问题**: 调用 `EventSystem.select_option(event_data, 0)` 时传入 int 索引作为第二个参数，但实际签名要求 Dictionary 类型的 option 对象。

**根因**: `select_option(event: Dictionary, option: Dictionary)` 的第二个参数是完整的选项数据对象，不是选项索引。

**解决方案**: 传入实际的选项 Dictionary：

```gdscript
# ❌ 错误：传入 int 索引
EventSystem.select_option(event_data, 0)  # 第二个参数类型错误！

# ✅ 正确：传入完整的选项 Dictionary
var option: Dictionary = {"option_id": "A", "text": "选项A"}
EventSystem.select_option(event_data, option)

# ✅ 从事件数据中获取选项
var options: Array = event_data.get("options", [])
if options.size() > 0:
    EventSystem.select_option(event_data, options[0])
```

**来源**: Layer 2-4 测试调试过程

---

## 📊 严重性统计

| 严重性 | 数量 | 章节 |
|--------|------|------|
| 🔴 **高** | 3 | §32, §33, §34 |
| 🟡 **中** | 2 | §35, §36 |
| **总计** | **5** | §32-§36 |

---

## 🔗 相关文档

### Base 层相关文档
- [Godot_4x_Autoload_Pitfalls.md](./Godot_4x_Autoload_Pitfalls.md) - Autoload 单例踩坑（含 §30 GUT API 陷阱）
- [GDScript_Setter_Getter_Dual_State_Pitfall.md](./GDScript_Setter_Getter_Dual_State_Pitfall.md) - 内嵌 get/set 双重状态踩坑（§26）
- [19_Pitfall_Records.md](./19_Pitfall_Records.md) - 常见踩坑记录总览
- [GDScript_Code_Standards.md](../code-standards/GDScript_Code_Standards.md) - GDScript 代码规范标准

### Wiki 层相关文档
- [常见踩坑避雷指南](../../wiki/guides/common-pitfalls.md)
- [GDScript 代码规范](../../wiki/concepts/gdscript-standards.md)

---

**文档版本**: 1.0  
**最后更新**: 2026-04-09  
**维护者**: Knowledge Base Administrator  
**来源**: Layer 2-4 测试调试过程
