# Godot 4.x 游戏系统实战踩坑记录

> **适用版本**: Godot 4.x（特别是 4.6+）
> **最后更新**: 2026-04-14
> **来源**: tower_defense 项目实战经验
> **重要性**: 🔴 必读 - 游戏系统开发常见陷阱

---

## 目录

- [§40 Tooltip遮挡触发元素导致闪烁循环](#40-tooltip遮挡触发元素导致闪烁循环-🟡-中)
- [§41 场景切换绕过导致UI不更新](#41-场景切换绕过导致ui不更新-🔴-高)
- [§42 分裂/召唤敌人未被计入存活数](#42-分裂召唤敌人未被计入存活数-🟡-中)
- [§43 字典中保留已释放节点引用导致freed instance报错](#43-字典中保留已释放节点引用导致freed-instance报错-🔴-高)
- [§44 击退效果与路径移动冲突](#44-击退效果与路径移动冲突-🟡-中)
- [§45 事件/战斗奖励重复显示](#45-事件战斗奖励重复显示-🟡-中)
- [§46 词条效果字段名不一致](#46-词条效果字段名不一致-🟡-中)
- [§47 UI计数显示语义错误——"已放置/最大"vs"剩余可放/最大"](#47-ui计数显示语义错误已放置最大vs剩余可放最大-🟡-中)
- [§48 变量命名与GDScript内置标识符冲突](#48-变量命名与gdscript内置标识符冲突-🟡-中)
- [§49 已满的塔从UI消失而非变灰](#49-已满的塔从ui消失而非变灰-🟡-中)
- [§50 调试误判——在正确的逻辑上反复修改](#50-调试误判在正确的逻辑上反复修改-🟢-低)
- [§51 节点被移出场景树后调用get_node_or_null报错](#51-节点被移出场景树后调用get_node_or_null报错-🔴-高)
- [§52 以freed对象为key的Dictionary遍历崩溃](#52-以freed对象为key的dictionary遍历崩溃-🔴-高)
- [§53 怪物路径偏移不能用侧向力实现](#53-怪物路径偏移不能用侧向力实现-🟡-中)
- [§54 分裂/召唤怪偏移需叠加父怪偏移](#54-分裂召唤怪偏移需叠加父怪偏移-🟡-中)
- [§55 怪出生时current_path_index应从1开始](#55-怪出生时current_path_index应从1开始-🟡-中)
- [§56 实际生成路径可能与预期不同](#56-实际生成路径可能与预期不同-🟡-中)
- [§57 Dictionary.has()对null值返回true](#57-dictionaryhas对null值返回true-🟡-中)
- [§58 老年阶段不应无条件触发终局](#58-老年阶段不应无条件触发终局-🔴-高)
- [§81 暴击特效不应作为额外伤害实例](#81-暴击特效不应作为额外伤害实例-🔴-高)
- [§82 debuff_amount设置但未使用导致效果不生效](#82-debuff_amount设置但未使用导致效果不生效-🟡-中)
- [§83 翻译键不匹配导致格式化报错](#83-翻译键不匹配导致格式化报错-🔴-高)
- [§84 终局状态机被UI回调覆盖](#84-终局状态机被ui回调覆盖-🔴-高)
- [§85 ParticleProcessMaterial.color_ramp类型限制](#85-particleprocessmaterialcolor_ramp类型限制-🟡-中)

---

## §40 Tooltip遮挡触发元素导致闪烁循环 🟡 中

**问题**: 词条悬停tooltip出现后立即消失，反复闪烁

**根因**: tooltip定位在badge上方，遮挡了badge，导致badge触发MOUSE_EXIT -> tooltip消失 -> 鼠标重新进入badge -> tooltip又出现 -> 循环闪烁

**踩坑过程**:
1. 词条badge添加了mouse_entered/mouse_exited信号
2. mouse_entered时创建tooltip并定位在badge上方
3. tooltip出现后遮挡了badge
4. badge触发mouse_exited，tooltip消失
5. 鼠标重新进入badge，tooltip又出现
6. 形成闪烁循环

**解决方案**:

```gdscript
# ❌ 错误：tooltip遮挡触发元素
# tooltip 出现在 badge 上方，鼠标进入 tooltip 区域时 badge 触发 MOUSE_EXIT
# tooltip 消失 -> 鼠标重新进入 badge -> tooltip 又出现 -> 循环闪烁

# ✅ 正确：tooltip 及其所有子节点设置 mouse_filter = IGNORE
func _create_tooltip(text: String) -> PanelContainer:
    var tooltip: PanelContainer = PanelContainer.new()
    tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var label: Label = Label.new()
    label.text = text
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 子节点也必须设置
    tooltip.add_child(label)
    return tooltip

# ✅ 动态创建的悬浮组件，递归设置所有子节点
func _set_mouse_filter_ignore_recursive(node: Node) -> void:
    if node is Control:
        node.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for child in node.get_children():
        _set_mouse_filter_ignore_recursive(child)
```

**规范**: 所有动态创建的悬浮UI组件，必须设置 `mouse_filter = MOUSE_FILTER_IGNORE`，避免遮挡触发元素

**相关规范**: [Godot 编码规范汇总 - 15.3 悬浮UI组件设置mouse_filter=IGNORE](../../../Godot%20编码规范汇总.md#153-悬浮-ui-组件设置-mouse_filterignore-🟡-建议)

---

## §41 场景切换绕过导致UI不更新 🔴 高

**问题**: 战斗结算面板始终显示旧内容，修改result_ui.gd无效

**根因**: map_manager._show_battle_result()创建了简单面板并2.5秒后自动跳转State.STAGE，完全绕过了result_ui.gd的完整结算面板

**踩坑过程**:
1. 实现了result_ui.gd的完整结算面板
2. 战斗结束后结算面板始终显示旧内容
3. 排查发现map_manager中有独立的_show_battle_result()方法
4. 该方法创建了简单面板，2.5秒后直接跳转State.STAGE
5. 完全绕过了result_ui.gd的完整结算逻辑

**解决方案**:

```gdscript
# ❌ 错误：map_manager 中独立实现场景切换逻辑
func _show_battle_result():
    var panel = Panel.new()
    # ... 创建简单面板 ...
    await get_tree().create_timer(2.5).timeout
    GameState.change_state(State.STAGE)  # 绕过了 result_ui.gd！

# ✅ 正确：统一入口，让 result_ui.gd 处理完整结算
func _show_battle_result():
    GameState.change_state(State.RESULT)  # 由 result_ui.gd 处理完整结算
```

**规范**: 场景切换逻辑必须统一入口，避免多处独立实现相同功能导致绕过

**相关规范**: [Godot 编码规范汇总 - 15.5 场景切换逻辑统一入口](../../../Godot%20编码规范汇总.md#155-场景切换逻辑统一入口-🔴-强制)

---

## §42 分裂/召唤敌人未被计入存活数 🟡 中

**问题**: 多波怪同时在场时，战斗结算提前弹出

**根因**: 手动维护 `_enemies_alive` 计数器，但分裂/召唤的敌人没有增加计数，也没有连接died/reached_base信号

**踩坑过程**:
1. 使用 `_enemies_alive` 计数器跟踪存活敌人
2. 敌人被击杀时 `_enemies_alive -= 1`
3. 当 `_enemies_alive <= 0` 时触发波次完成
4. 分裂敌人创建时没有走 `_on_enemy_spawned()`，计数器未增加
5. 分裂敌人死亡时仍然减少计数器
6. 导致计数器提前归零，战斗结算提前弹出

**解决方案**:

```gdscript
# ❌ 错误：手动维护计数器，分裂/召唤的敌人未计入
var _enemies_alive: int = 0

func _on_enemy_spawned():
    _enemies_alive += 1  # 分裂/召唤的敌人不会走这里

func _on_enemy_died():
    _enemies_alive -= 1
    if _enemies_alive <= 0:
        _on_wave_complete()  # 提前弹出结算！

# ✅ 正确：使用 group 动态查询存活敌人数量
func get_alive_enemy_count() -> int:
    return get_tree().get_nodes_in_group("enemies").size()

# ✅ 分裂/召唤的敌人自动加入 group 并连接信号
func _spawn_split_enemy(pos: Vector2) -> void:
    var enemy: CharacterBody2D = enemy_scene.instantiate()
    enemy.add_to_group("enemies")  # 自动计入
    enemy.died.connect(_on_enemy_died)
    enemy.reached_base.connect(_on_enemy_reached_base)
    enemy.global_position = pos
    add_child(enemy)
```

**规范**: 优先使用group动态查询而非手动维护计数器；动态创建的实体必须正确连接生命周期信号

**相关规范**: [Godot 编码规范汇总 - 15.1 动态敌人管理使用group而非手动计数](../../../Godot%20编码规范汇总.md#151-动态敌人管理使用-group-而非手动计数-🟡-建议)

---

## §43 字典中保留已释放节点引用导致freed instance报错 🔴 高

**问题**: `Trying to assign invalid previously freed instance` 报错

**根因**: 怪物技能摧毁防御塔后，built_towers字典中仍保留已queue_free()的塔引用；直接用 `var tower: Tower = dict[key]` 赋值时触发错误

**踩坑过程**:
1. 防御塔被怪物技能摧毁，调用 `tower.queue_free()`
2. built_towers字典中仍保留该塔的引用
3. 后续代码通过 `built_towers[key]` 访问
4. `var tower: Tower = built_towers[key]` 赋值时触发 freed instance 错误
5. hovered_tower等缓存引用同样存在此问题

**解决方案**:

```gdscript
# ❌ 错误：直接用 [] 访问字典，赋值时触发 freed instance 错误
var tower: Tower = built_towers[key]  # 如果 tower 已 freed，赋值报错！

# ✅ 正确方案 1：使用 .get() 获取引用，先检查 is_instance_valid() 再类型转换
var tower_ref = built_towers.get(key)
if is_instance_valid(tower_ref):
    var tower: Tower = tower_ref as Tower
    tower.do_something()

# ✅ 正确方案 2：塔被摧毁时同步从字典中移除引用
func _on_tower_destroyed(tower: Tower) -> void:
    var key: String = _get_tower_key(tower)
    built_towers.erase(key)

# ✅ 正确方案 3：hovered_tower 加 is_instance_valid() 保护
func _process(delta: float) -> void:
    if is_instance_valid(hovered_tower):
        hovered_tower.show_info()
```

**规范**: 缓存节点引用的字典/数组，必须在节点释放时同步清理；访问前必须用 `is_instance_valid()` 检查；用 `.get()` 而非 `[]` 访问避免赋值时触发错误

**相关规范**: [Godot 编码规范汇总 - 15.2 缓存节点引用必须同步清理](../../../Godot%20编码规范汇总.md#152-缓存节点引用必须同步清理-🔴-强制)

---

## §44 击退效果与路径移动冲突 🟡 中

**问题**: 敌人被击退后不按固定路径行动

**根因**: 击退效果直接修改global_position，但_process中同时计算路径移动，击退期间敌人同时被击退和沿路径移动

**踩坑过程**:
1. 敌人沿PathFollow2D路径移动
2. 被击退时直接修改 global_position
3. _process 中仍在计算路径移动
4. 击退期间敌人同时被击退和沿路径移动
5. 导致击退效果不自然，敌人位置异常

**解决方案**:

```gdscript
# ❌ 错误：击退和路径移动同时执行
func _process(delta: float):
    _move_along_path(delta)  # 路径移动
    # 击退效果也在修改 global_position，两者冲突！

func apply_knockback(direction: Vector2, force: float):
    # 直接修改 global_position，但 _process 还在移动
    global_position += direction * force

# ✅ 正确：击退期间跳过路径移动
var is_being_knocked_back: bool = false

func _process(delta: float) -> void:
    if is_being_knocked_back:
        return  # 击退期间跳过路径移动
    _move_along_path(delta)

func apply_knockback(direction: Vector2, force: float) -> void:
    is_being_knocked_back = true
    var tween: Tween = create_tween()
    tween.tween_property(self, "global_position", global_position + direction * force, 0.3)
    tween.tween_callback(func(): is_being_knocked_back = false)
```

**规范**: 位移效果（击退、拉拽等）与常规移动逻辑必须互斥，不能同时执行

**相关规范**: [Godot 编码规范汇总 - 15.4 位移效果与常规移动互斥](../../../Godot%20编码规范汇总.md#154-位移效果与常规移动互斥-🟡-建议)

---

## §45 事件/战斗奖励重复显示 🟡 中

**问题**: 战斗结算面板显示了事件选择时获得的词条和防御塔

**根因**: session.last_event_traits和last_event_towers记录了事件选择时的奖励，战斗结算面板读取了这些数据

**踩坑过程**:
1. 事件选择阶段，session记录了last_event_traits和last_event_towers
2. 战斗结算面板显示奖励时，读取了last_event_traits和last_event_towers
3. 导致战斗结算面板重复显示事件阶段的奖励
4. 玩家困惑：为什么战斗结算显示了事件阶段的词条

**解决方案**:

```gdscript
# ❌ 错误：战斗结算面板读取事件奖励数据
func _show_battle_result():
    for trait in session.last_event_traits:  # 这是事件阶段的奖励！
        _add_trait_display(trait)
    for tower in session.last_event_towers:  # 这也是事件阶段的！
        _add_tower_display(tower)

# ✅ 正确：战斗结算只显示战斗获得的奖励
func _show_battle_result():
    var rewards: Dictionary = session.last_battle_rewards
    var gold: int = rewards.get("gold", 0)
    _add_gold_display(gold)
    var towers: Array = rewards.get("towers", [])
    for tower in towers:
        _add_tower_display(tower)
    # 不再读取 last_event_traits / last_event_towers
```

**规范**: 不同阶段的奖励数据必须分开存储和展示，避免跨阶段重复显示

**相关规范**: [Godot 编码规范汇总 - 15.6 不同阶段奖励数据分开存储](../../../Godot%20编码规范汇总.md#156-不同阶段奖励数据分开存储-🟡-建议)

---

## §46 词条效果字段名不一致 🟡 中

**问题**: tower_damage_bonus类词条显示"塔伤害+0"而非"塔伤害+15%"

**根因**: traits.json中tower_damage_bonus类型使用 `tower_damage_bonus` 字段名存储值（如0.15），而_format_effect只读取 `value` 字段

**踩坑过程**:
1. traits.json中定义了多种效果类型
2. tower_damage_bonus类型使用 `tower_damage_bonus` 字段名存储数值
3. _format_effect函数假设所有效果都用 `value` 字段
4. 读取tower_damage_bonus时，`effect.get("value", 0)` 返回0
5. 显示"塔伤害+0%"而非"塔伤害+15%"

**解决方案**:

```gdscript
# ❌ 错误：假设所有效果都用 value 字段
func _format_effect(effect: Dictionary) -> String:
    var val: float = effect.get("value", 0)  # tower_damage_bonus 类型没有 value 字段！
    return "塔伤害+%.0f%%" % (val * 100)  # 显示 "塔伤害+0%"

# ✅ 正确：根据 effect type 读取对应字段
func _format_effect(effect: Dictionary) -> String:
    var effect_type: String = effect.get("type", "")
    # 优先读取类型特定字段，回退到 value
    var val: float = effect.get(effect_type, effect.get("value", 0))
    match effect_type:
        "tower_damage_bonus":
            return "塔伤害+%.0f%%" % (val * 100)
        "tower_attack_speed_bonus":
            return "攻速+%.0f%%" % (val * 100)
        _:
            return str(val)
```

**规范**: 效果格式化函数必须根据effect type读取对应字段，不能假设所有效果都用value字段

**相关规范**: [Godot 编码规范汇总 - 15.7 效果格式化按type读取对应字段](../../../Godot%20编码规范汇总.md#157-效果格式化按-type-读取对应字段-🟡-建议)

---

## §47 UI计数显示语义错误——"已放置/最大"vs"剩余可放/最大" 🟡 中

**问题**: 防御塔选择界面显示 "0/1"、"0/2"，用户认为没放塔时应该显示 "1/1"、"2/2"

**根因**: 计数逻辑本身正确，但显示格式用了 `placed/max`（已放置数/最大数），而用户期望的是 `remaining/max`（剩余可放数/最大数）

**踩坑过程**:
1. 防御塔有数量限制（如最多1个、最多2个）
2. UI 显示 `"%d/%d" % [tower_placed, tower_max]`，即 "0/1"、"0/2"
3. 用户困惑：没放塔时显示 "0/1"，感觉像是"0个可用"
4. 用户期望：没放塔时应该显示 "1/1"（还能放1个，总共1个位置）
5. 调试过程中误以为是计数逻辑错误，反复修改 get_nodes_in_group + get_meta 的实现

**解决方案**:

```gdscript
# ❌ 错误：显示"已放置/最大"，语义与用户心智模型不符
var tower_placed: int = get_tree().get_nodes_in_group("towers").size()
count_label.text = "%d/%d" % [tower_placed, tower_max]
# 结果：0/1, 0/2 → 用户理解为"0个可用"

# ✅ 正确：显示"剩余可放/最大"，语义与用户心智模型一致
var tower_placed: int = get_tree().get_nodes_in_group("towers").size()
var tower_remaining: int = tower_max - tower_placed
count_label.text = "%d/%d" % [tower_remaining, tower_max]
# 结果：1/1, 2/2 → 用户理解为"还能放1个，总共1个位置"
```

**规范**: UI显示的数字语义必须与用户心智模型一致。"还可以放几个"比"已经放了几个"更有用

**相关规范**: [Godot 编码规范汇总 - 15.9 UI计数显示使用"剩余/最大"格式](../../../Godot%20编码规范汇总.md#159-ui计数显示使用剩余最大格式-🟡-建议)

---

## §48 变量命名与GDScript内置标识符冲突 🟡 中

**问题**: Godot 控制台报 `SHADOWED_GLOBAL_IDENTIFIER` 警告，如 `var range`、`var color`、`var name`、`var size`、`var text`

**根因**: GDScript 有大量内置函数/类/常量（range、color、name、size、text等），局部变量同名会遮蔽全局标识符

**踩坑过程**:
1. 代码中使用 `var range = 100` 定义攻击范围
2. Godot 控制台报 SHADOWED_GLOBAL_IDENTIFIER 警告
3. 同类问题出现在 `var color`、`var name`、`var size`、`var text` 等变量
4. 虽然功能不受影响，但警告污染控制台输出，且可能引发意外行为

**解决方案**:

```gdscript
# ❌ 错误：使用与GDScript内置标识符同名的变量
var range: float = 100.0       # 遮蔽内置函数 range()
var color: Color = Color.RED   # 遮蔽内置类 Color
var name: String = "tower"     # 遮蔽内置属性 name
var size: Vector2 = Vector2(32, 32)  # 遮蔽内置属性 size
var text: String = "hello"     # 遮蔽内置属性 text

# ✅ 正确：使用语义更明确的名称
var attack_range: float = 100.0       # 攻击范围
var fill_color: Color = Color.RED     # 填充颜色
var display_name: String = "tower"    # 显示名称
var img_size: Vector2 = Vector2(32, 32)  # 图片尺寸
var attr_text: String = "hello"       # 属性文本
```

**常见冲突标识符及推荐替代命名**:

| 冲突标识符 | 推荐替代 | 场景 |
|-----------|---------|------|
| `range` | `attack_range`, `detect_range` | 攻击/检测范围 |
| `color` | `fill_color`, `growth_color` | 填充/生长颜色 |
| `name` | `display_name`, `era_name` | 显示/时代名称 |
| `size` | `img_size`, `cell_size` | 图片/格子尺寸 |
| `text` | `attr_text`, `label_text` | 属性/标签文本 |
| `type` | `enemy_type`, `item_type` | 敌人/物品类型 |
| `value` | `damage_value`, `score_value` | 伤害/分数值 |
| `key` | `config_key`, `dict_key` | 配置/字典键 |
| `step` | `move_step`, `anim_step` | 移动/动画步长 |
| `count` | `enemy_count`, `item_count` | 敌人/物品计数 |
| `data` | `config_data`, `save_data` | 配置/存档数据 |
| `result` | `battle_result`, `query_result` | 战斗/查询结果 |
| `error` | `load_error`, `parse_error` | 加载/解析错误 |
| `input` | `player_input`, `user_input` | 玩家/用户输入 |
| `output` | `log_output`, `calc_output` | 日志/计算输出 |
| `object` | `target_object`, `game_object` | 目标/游戏对象 |
| `signal` | `custom_signal`, `event_signal` | 自定义/事件信号 |
| `method` | `callback_method`, `api_method` | 回调/API方法 |
| `function` | `handler_function`, `util_function` | 处理/工具函数 |
| `class` | `enemy_class`, `item_class` | 敌人/物品类别 |
| `load` | `scene_load`, `asset_load` | 场景/资源加载 |
| `string` | `format_string`, `search_string` | 格式/搜索字符串 |
| `position` | `spawn_position`, `target_position` | 生成/目标位置 |
| `scale` | `damage_scale`, `time_scale` | 伤害/时间缩放 |
| `rotation` | `facing_rotation`, `spin_rotation` | 朝向/旋转角度 |

**规范**: 局部变量命名必须避免与GDScript内置标识符冲突，使用更具体的语义化名称。Godot 会在控制台报 SHADOWED_GLOBAL_IDENTIFIER 警告，必须修复

**相关规范**: [Godot 编码规范汇总 - 2.1.3 变量命名禁止与内置标识符冲突](../../../Godot%20编码规范汇总.md#213-变量命名禁止与内置标识符冲突-🔴-强制)

---

## §49 已满的塔从UI消失而非变灰 🟡 中

**问题**: 数量限制的防御塔放满后从选择界面消失

**根因**: load_tower_configs() 中有 `if placed < max_count` 过滤条件，放满的塔不加入列表

**踩坑过程**:
1. 防御塔有数量限制（如最多1个、最多2个）
2. 放满后在选择界面找不到该塔
3. 用户困惑：之前能选的塔去哪了？
4. 排查发现 load_tower_configs() 中有过滤条件 `if placed < max_count`
5. 放满的塔直接不加入列表，导致从界面消失

**解决方案**:

```gdscript
# ❌ 错误：放满的塔从列表中移除
func load_tower_configs() -> void:
    for tower_config in tower_configs:
        var placed: int = _get_placed_count(tower_config.tower_id)
        if placed < tower_config.max_count:  # 放满的塔不加入列表
            _add_tower_button(tower_config)

# ✅ 正确：所有塔始终显示，已满的塔变灰禁用
func load_tower_configs() -> void:
    for tower_config in tower_configs:
        var placed: int = _get_placed_count(tower_config.tower_id)
        var is_full: bool = placed >= tower_config.max_count
        var button: Button = _add_tower_button(tower_config)
        if is_full:
            button.disabled = true           # 禁用按钮
            button.modulate = Color(0.5, 0.5, 0.5, 1.0)  # 变灰

# ✅ 更新时也保持一致
func update_tower_counts() -> void:
    for tower_config in tower_configs:
        var placed: int = _get_placed_count(tower_config.tower_id)
        var is_full: bool = placed >= tower_config.max_count
        var button: Button = _get_tower_button(tower_config.tower_id)
        if button:
            button.disabled = is_full
            button.modulate = Color(0.5, 0.5, 0.5, 1.0) if is_full else Color.WHITE
```

**规范**: UI中"不可用"的选项应该变灰禁用而非消失，保持用户对完整选项的认知

**相关规范**: [Godot 编码规范汇总 - 15.9 UI计数显示使用"剩余/最大"格式](../../../Godot%20编码规范汇总.md#159-ui计数显示使用剩余最大格式-🟡-建议)

---

## §50 调试误判——在正确的逻辑上反复修改 🟢 低

**问题**: 之前多次尝试用 get_nodes_in_group("towers") + get_meta("tower_id") 计数，但始终显示0，误以为是计数逻辑问题

**根因**: 实际根因是显示语义错误（§47），不是计数逻辑问题。但调试过程中发现 group + meta 方式本身是可行的

**踩坑过程**:
1. 用户反馈防御塔计数显示 "0/1"
2. 开发者认为是 get_nodes_in_group + get_meta 计数方式有问题
3. 反复修改计数逻辑实现，尝试不同方案
4. 最终发现计数逻辑本身是正确的，问题在于显示格式用了 "已放置/最大" 而非 "剩余/最大"
5. 用户期望看到 "1/1"（剩余1个/总共1个），而非 "0/1"（已放0个/总共1个）

**解决方案**:

```gdscript
# ❌ 错误的调试方向：反复修改正确的计数逻辑
# 尝试1：换一种 group 查询方式
# 尝试2：换一种 meta 读取方式
# 尝试3：改用字典缓存计数
# ... 以上都是正确的逻辑，问题不在计数

# ✅ 正确的调试方向：先确认"正确行为"的定义
# 1. 问清楚"期望显示什么" → "1/1" 而非 "0/1"
# 2. 确认计数逻辑是否正确 → 放了0个塔，计数为0，逻辑正确
# 3. 确认显示格式是否正确 → "0/1" 表示"已放0个/总共1个"，但用户期望"剩余1个/总共1个"
# 4. 修改显示格式 → "剩余/最大"
```

**规范**: 调试bug时先确认"正确行为"的定义，避免在正确的逻辑上反复修改。先问清楚"期望显示什么"再动手

**相关规范**: [Godot 编码规范汇总 - 15.10 调试前确认"正确行为"定义](../../../Godot%20编码规范汇总.md#1510-调试前确认正确行为定义-🟡-建议)

---

## §51 节点被移出场景树后调用get_node_or_null报错 🔴 高

**问题**: `Can't use get_node() with absolute paths from outside the active scene tree`

**根因**: `select_option()`可能触发状态切换（如进入BATTLE），导致当前UI节点被移出场景树，后续的`get_node_or_null("/root/...")`调用报错

**踩坑过程**:
1. event_ui.gd中_on_option_pressed()调用EventSystem.select_option()
2. select_option()内部触发状态切换，当前UI场景被移出场景树
3. select_option()返回后，代码继续执行get_node_or_null("/root/...")
4. 由于当前节点已不在场景树中，get_node_or_null报错

**解决方案**:

```gdscript
# ❌ 错误：场景切换调用后继续访问节点
func _on_option_pressed():
    EventSystem.select_option(event_data, option)  # 可能触发场景切换
    var node = get_node_or_null("/root/SomeNode")  # 报错！当前节点已不在场景树

# ✅ 正确：在可能触发场景切换的调用之后，加is_inside_tree()检查
func _on_option_pressed():
    EventSystem.select_option(event_data, option)
    if not is_inside_tree():
        return
    var node = get_node_or_null("/root/SomeNode")
```

**规范**: 可能触发场景切换的调用（如select_option()、change_state()等）后，节点可能被移出场景树，后续的get_node_or_null()、get_tree()等调用前必须检查is_inside_tree()

**来源**: event_ui.gd _on_option_pressed()

**相关规范**: [Godot 编码规范汇总 - 16.2 可能触发场景切换的调用后必须检查is_inside_tree()](../../../Godot%20编码规范汇总.md#162-可能触发场景切换的调用后必须检查is_inside_tree-🔴-强制)

---

## §52 以freed对象为key的Dictionary遍历崩溃 🔴 高

**问题**: `Attempted to next an invalid (previously freed?) object instance into a 'TypedDictionary.Key'`

**根因**: `damage_dealers: Dictionary`以Tower对象为key，当Tower被释放后遍历该Dictionary时，GDScript内部类型验证失败

**踩坑过程**:
1. enemy.gd中用`damage_dealers: Dictionary`记录对怪物造成伤害的防御塔
2. Tower对象作为Dictionary的key，伤害值作为value
3. 防御塔被摧毁后调用queue_free()
4. 遍历damage_dealers时，GDScript尝试对freed对象做类型验证
5. 触发`Attempted to next an invalid (previously freed?) object instance`崩溃

**解决方案**:

```gdscript
# ❌ 错误：以对象实例作为Dictionary的key
var damage_dealers: Dictionary = {}  # key = Tower对象
damage_dealers[tower] = 100.0
# Tower被释放后遍历 → 崩溃！

# ✅ 正确：用Array[Dictionary]存储，不以对象为key
var damage_dealers: Array[Dictionary] = []
damage_dealers.append({"tower": tower_ref, "damage": 100.0})

# ✅ 遍历时用is_instance_valid()过滤
for entry in damage_dealers:
    if is_instance_valid(entry["tower"]):
        var tower: Tower = entry["tower"] as Tower
        tower.do_something()
```

**规范**: 不要以对象实例作为Dictionary的key，改用`Array[Dictionary]`存储，如`{"tower": tower_ref, "damage": 100.0}`

**来源**: enemy.gd distribute_experience()

**相关规范**: [Godot 编码规范汇总 - 16.3 不要以对象实例作为Dictionary的key](../../../Godot%20编码规范汇总.md#163-不要以对象实例作为dictionary的key-🔴-强制)

---

## §53 怪物路径偏移不能用侧向力实现 🟡 中

**问题**: 用`global_position += perpendicular * lateral_offset * delta`施加侧向力，怪物抖动/转圈，偏移不生效

**根因**: 侧向力与路径追踪的`global_position = target_pos`互相打架，每帧先移向目标点再被侧向力推开

**踩坑过程**:
1. 需要让怪物沿路径有侧向偏移（避免重叠）
2. 在_process()中每帧施加侧向力
3. 但路径移动也在每帧设置global_position = target_pos
4. 两者互相打架：先移向目标点，再被侧向力推开
5. 怪物抖动/转圈，偏移不生效

**解决方案**:

```gdscript
# ❌ 错误：用侧向力实现路径偏移
func _process(delta: float):
    _move_along_path(delta)
    global_position += perpendicular * lateral_offset * delta  # 与路径移动冲突！

# ✅ 正确：在set_path()时一次性偏移所有路径点
func set_path(points: Array[Vector2]) -> void:
    path_points = points
    _apply_lateral_offset()  # 一次性偏移所有路径点

func _apply_lateral_offset() -> void:
    if lateral_offset == 0.0:
        return
    for i in range(path_points.size()):
        var direction: Vector2 = (path_points[i] - path_points[max(0, i - 1)]).normalized()
        var perpendicular: Vector2 = Vector2(-direction.y, direction.x)
        path_points[i] += perpendicular * lateral_offset
```

**规范**: 路径偏移必须一次性应用到所有路径点，不要用侧向力/每帧偏移实现路径偏移

**来源**: enemy.gd set_path() / _apply_lateral_offset()

**相关规范**: [Godot 编码规范汇总 - 16.4 路径偏移必须一次性应用到所有路径点](../../../Godot%20编码规范汇总.md#164-路径偏移必须一次性应用到所有路径点-🔴-强制)

---

## §54 分裂/召唤怪偏移需叠加父怪偏移 🟡 中

**问题**: 分裂/召唤怪的路径偏移只有自身随机偏移，没有继承父怪偏移，导致子怪路径与父怪不一致

**踩坑过程**:
1. 父怪已有lateral_offset偏移量
2. 分裂/召唤子怪时，只给子怪设置随机偏移
3. 子怪的偏移从0开始计算，而非从父怪当前位置偏移
4. 导致子怪路径与父怪路径不一致，视觉上跳跃

**解决方案**:

```gdscript
# ❌ 错误：子怪偏移只有自身随机值
func _on_split_requested():
    child.lateral_offset = randf_range(-15.0, 15.0)

# ✅ 正确：子怪偏移 = 父怪偏移 + 自身随机偏移
func _on_split_requested():
    child.lateral_offset = lateral_offset + randf_range(-15.0, 15.0)

func _on_summon_requested():
    child.lateral_offset = lateral_offset + randf_range(-15.0, 15.0)
```

**规范**: 分裂/召唤子怪的路径偏移 = 父怪偏移 + 自身随机偏移

**来源**: enemy.gd _on_split_requested() / _on_summon_requested()

---

## §55 怪出生时current_path_index应从1开始 🟡 中

**问题**: 怪出生在path_points[0]附近，但current_path_index=0，怪先走向path_points[0]（出生点本身）形成斜线

**踩坑过程**:
1. 怪物在path_points[0]（出生点）附近生成
2. current_path_index初始化为0
3. 怪物首先走向path_points[0]，但已经在出生点附近
4. 形成斜线移动轨迹，视觉不自然

**解决方案**:

```gdscript
# ❌ 错误：从索引0开始，怪先走向出生点
enemy.current_path_index = 0  # 怪走向path_points[0]（出生点本身）

# ✅ 正确：从索引1开始，跳过出生点
enemy.current_path_index = 1  # 怪直接走向第二个转弯点
```

**规范**: 怪出生时默认已到达第一个路径点，current_path_index应从1开始

**来源**: map_manager.gd _on_enemy_spawn_requested()

---

## §56 实际生成路径可能与预期不同 🟡 中

**问题**: 修改了enemy_spawner.gd的生成逻辑但没效果

**根因**: 游戏实际使用的是tower_defense/wave_manager.gd -> enemy_spawn_requested信号 -> map_manager._on_enemy_spawn_requested()，而enemy_spawner.gd根本没被调用

**踩坑过程**:
1. 需要修改怪物生成逻辑
2. 找到enemy_spawner.gd，修改了生成代码
3. 运行游戏，发现修改没有生效
4. 排查发现实际调用路径是wave_manager.gd -> map_manager.gd
5. enemy_spawner.gd根本没被使用

**解决方案**:

```gdscript
# ❌ 错误：假设某个文件/函数是被调用的入口
# 修改了 enemy_spawner.gd 但实际调用路径不经过它

# ✅ 正确：修改代码前必须用Grep搜索确认实际的调用路径
# 搜索 "enemy_spawn_requested" 信号的所有emit和connect
# 确认实际执行路径：wave_manager.gd -> map_manager.gd
```

**教训**: 修改代码前必须用Grep搜索确认实际的调用路径，不要假设

**来源**: map_manager.gd vs enemy_spawner.gd

**相关规范**: [Godot 编码规范汇总 - 16.1 修改代码前必须确认实际调用路径](../../../Godot%20编码规范汇总.md#161-修改代码前必须确认实际调用路径-🔴-强制)

---

## §57 Dictionary.has()对null值返回true 🟡 中

**问题**: `option.has("battle_trigger")`当`battle_trigger: null`时返回true（key存在），导致逻辑分支错误

**根因**: `has()`检查的是key是否存在，而非value是否有效。key存在但value为null时，`has()`仍返回true

**踩坑过程**:
1. event_ui.gd中用`option.has("battle_trigger")`判断是否触发战斗
2. 某些选项的battle_trigger字段为null（表示不触发战斗）
3. has("battle_trigger")对null值返回true（key存在）
4. 导致不触发战斗的选项也进入了战斗分支

**解决方案**:

```gdscript
# ❌ 错误：用has()判断，null值时仍返回true
if option.has("battle_trigger"):  # battle_trigger: null 时也返回true！
    _enter_battle()  # 误触发战斗

# ✅ 正确：用.get() + 类型检查，类型安全且不受null值影响
if option.get("battle_trigger") is Dictionary:
    _enter_battle()  # 只在battle_trigger是Dictionary时触发
```

**规范**: Dictionary值判断用.get()而非.has()，`has("key")`对null值返回true，可能导致逻辑错误

**来源**: event_ui.gd display_event() / _show_consequence_popup()

**相关规范**: [Godot 编码规范汇总 - 16.5 Dictionary值判断用.get()而非.has()](../../../Godot%20编码规范汇总.md#165-dictionary值判断用get而非has-🟡-建议)

---

## §58 老年阶段不应无条件触发终局 🔴 高

**问题**: 51岁进入老年阶段后，战斗结束直接触发终局

**根因1**: result_ui.gd中`is_final_battle = session.current_stage == "old_age"`导致老年阶段隐藏"继续人生"按钮，只显示"查看结局"

**根因2**: map_manager.gd中战斗结束后`session.current_age += 1`，年龄异常增长

**根因3**: event_system.gd中`_apply_stage_attribute_growth()`每次select_option都扣old_age的-10健康

**踩坑过程**:
1. 玩家51岁进入老年阶段
2. 战斗结束后直接触发终局，无法继续游戏
3. 排查发现三个问题叠加：
   - result_ui.gd将老年阶段等同于终局
   - map_manager.gd战斗后错误增长年龄
   - event_system.gd每次选择都扣健康，加速死亡
4. 三个问题共同导致老年阶段无法正常游玩

**解决方案**:

```gdscript
# ❌ 错误：老年阶段无条件触发终局
# result_ui.gd
is_final_battle = session.current_stage == "old_age"  # 老年=终局？

# map_manager.gd
session.current_age += 1  # 战斗结束增长年龄？

# event_system.gd
_apply_stage_attribute_growth()  # 每次select_option都扣健康？

# ✅ 正确：终局只在health<=0或用户选择triggers_ending选项时触发
# result_ui.gd
is_final_battle = session.health <= 0 or option_has_triggers_ending

# map_manager.gd
# 战斗不增长年龄，只在事件阶段增长

# event_system.gd
# _apply_stage_attribute_growth只在年龄实际增长时调用
```

**规范**: 终局只在health<=0或用户选择triggers_ending选项时触发；战斗不增长年龄；_apply_stage_attribute_growth只在年龄实际增长时调用

**来源**: result_ui.gd / map_manager.gd / event_system.gd

---

## §81 暴击特效不应作为额外伤害实例 🔴 高

**问题**: 1次攻击出现2-3个伤害数字，总伤害=base*(1+multiplier)而非base*multiplier

**根因**: CRIT特效在effect_system._apply_crit中调用take_damage造成额外伤害，而弹道命中也造成基础伤害，导致暴击伤害计算错误

**踩坑过程**:
1. 设计暴击效果时，在effect_system._apply_crit中调用target.take_damage(crit_damage)
2. 弹道命中时也调用target.take_damage(base_damage)
3. 暴击触发时，实际造成 base_damage + base_damage * multiplier = base_damage * (1 + multiplier)
4. 而设计意图是暴击伤害 = base_damage * multiplier
5. 导致1次攻击出现2-3个伤害数字，总伤害偏高

**解决方案**:

```gdscript
# ❌ 错误：暴击作为额外伤害实例
func _apply_crit(source_tower: Tower, target: Node2D, multiplier: float) -> void:
    var crit_damage: float = base_damage * multiplier
    target.take_damage(crit_damage)  # 额外伤害实例！加上弹道的基础伤害，总伤害=base*(1+multiplier)

# ✅ 正确：暴击作为伤害倍率，在攻击流程中判定
# tower_attack_component.gd
func _on_projectile_hit(target: Node2D) -> void:
    var final_damage: float = base_damage
    var is_crit: bool = _check_crit()
    if is_crit:
        final_damage *= crit_multiplier  # 直接乘以倍率
    target.take_damage(final_damage, is_crit)  # 通过is_crit参数控制数字颜色

# effect_system.gd - execute_effects跳过CRIT类型
func execute_effects(effects: Array, source: Node2D, target: Node2D) -> void:
    for effect in effects:
        match effect.get("type", ""):
            "CRIT":
                continue  # 跳过CRIT，暴击已在攻击流程中处理
            "SLOW":
                _apply_slow(target, effect)
            # ... 其他效果
```

**规范**: CRIT类特效必须在攻击流程中判定为伤害倍率，通过is_crit参数控制UI显示。禁止在effect_system中单独调用take_damage造成额外伤害实例

**涉及文件**: tower_attack_component.gd, enemy.gd, projectile.gd, effect_system.gd

**相关规范**: [Godot 编码规范汇总 - 24.1 暴击=伤害倍率而非额外伤害实例](../../../Godot%20编码规范汇总.md#241-暴击伤害倍率而非额外伤害实例-🔴-强制)

---

## §82 debuff_amount设置但未使用导致效果不生效 🟡 中

**问题**: 历史塔的"削弱敌人属性"完全无效，敌人抗性没有降低

**根因**: enemy.gd的apply_debuff设置了debuff_amount，但take_damage中从未读取该值来降低抗性，导致debuff效果"设置了但不生效"

**踩坑过程**:
1. 塔的配置中定义了debuff效果，apply_debuff()正确设置了enemy.debuff_amount
2. 但take_damage()中计算抗性时只读取了armor_break_amount
3. debuff_amount被设置但从未被消费，效果完全不生效
4. 玩家选择"削弱敌人属性"的塔，实际没有任何效果

**解决方案**:

```gdscript
# ❌ 错误：debuff_amount设置了但take_damage中未使用
func apply_debuff(amount: float) -> void:
    debuff_amount = amount  # 设置了

func take_damage(amount: float, is_crit: bool = false) -> void:
    var resistance: float = maxf(0.0, resistance - armor_break_amount)  # 只读了armor_break，没读debuff！
    var final_damage: float = amount * (1.0 - resistance)

# ✅ 正确：在take_damage中将debuff_amount加入抗性计算
func take_damage(amount: float, is_crit: bool = false) -> void:
    var resistance: float = maxf(0.0, resistance - armor_break_amount - debuff_amount)
    var final_damage: float = amount * (1.0 - resistance)
```

**规范**: 添加新的状态效果（如debuff/slow/armor_break）时，必须验证效果值在take_damage中被实际使用，避免"设置了但不生效"的情况

**涉及文件**: enemy.gd

**相关规范**: [Godot 编码规范汇总 - 24.2 debuff效果验证](../../../Godot%20编码规范汇总.md#242-debuff效果验证-🟡-建议)

---

## §83 翻译键不匹配导致格式化报错 🔴 高

**问题**: `String formatting error: not all arguments converted during string formatting`

**根因**: 代码使用`tr("ENEMY_DEBUFFED")`，但translations.csv中只有`ENEMY_DEBUFF`（没有ED后缀），tr()返回键名本身（"ENEMY_DEBUFFED"），`% [value1, value2]`格式化失败

**踩坑过程**:
1. 代码中写 `tr("ENEMY_DEBUFFED") % [slow_amount, slow_timer]`
2. CSV中只有 `ENEMY_DEBUFF,减速中（-%.0f%%，%.1fs）,Slowed (-%.0f%%, %.1fs)`
3. tr("ENEMY_DEBUFFED") 找不到翻译，返回键名本身 "ENEMY_DEBUFFED"
4. "ENEMY_DEBUFFED" % [slow_amount, slow_timer] 格式化失败，因为没有%占位符
5. 报错 "not all arguments converted"

**解决方案**:

```gdscript
# ❌ 错误：翻译键与CSV不匹配
# 代码中
var text: String = tr("ENEMY_DEBUFFED") % [slow_amount, slow_timer]  # 键名多了"ED"
# CSV中
# ENEMY_DEBUFF,减速中（-%.0f%%，%.1fs）,Slowed (-%.0f%%, %.1fs)  # 没有ED

# ✅ 正确：确保代码中的翻译键与CSV中完全一致
# 方案1：修改代码，使用CSV中已有的键
var text: String = tr("ENEMY_DEBUFF") % [slow_amount, slow_timer]

# 方案2：在CSV中添加缺失的键
# ENEMY_DEBUFFED,减速中（-%.0f%%，%.1fs）,Slowed (-%.0f%%, %.1fs)
```

**规范**: 代码中使用的tr()键名必须与translations.csv中完全一致，包括大小写和后缀。新增翻译键时必须同步更新CSV文件

**涉及文件**: enemy_info_panel.gd, translations.csv

**相关规范**: [Godot 编码规范汇总 - 24.3 翻译键一致性](../../../Godot%20编码规范汇总.md#243-翻译键一致性-🔴-强制)

---

## §84 终局状态机被UI回调覆盖 🔴 高

**问题**: 游戏健康归零后应进入ENDING状态，但被event_ui.gd的选项回调覆盖回STAGE状态

**根因**: event_ui.gd选项弹窗回调中不检查当前状态就强制切换到STAGE，当event_system的_check_health_depleted已将状态改为ENDING后，回调又把状态改回STAGE

**踩坑过程**:
1. 玩家健康归零，event_system._check_health_depleted()将GameState改为ENDING
2. 但此时event_ui.gd的选项回调仍在等待执行
3. 回调中直接执行 GameState.change_state(State.STAGE)
4. 终局状态被覆盖回STAGE，游戏继续而非结束
5. 玩家健康为0但游戏不结束

**解决方案**:

```gdscript
# ❌ 错误：回调中不检查当前状态就切换
func _on_option_selected(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)
    GameState.change_state(State.STAGE)  # 强制切换，可能覆盖ENDING状态！

# ✅ 正确：回调中先检查当前状态
func _on_option_selected(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)
    if GameState.current_state == GameState.State.ENDING:
        return  # 终局状态已被设置，不覆盖
    GameState.change_state(State.STAGE)
```

**规范**: UI回调中切换GameState状态前，必须检查当前状态是否已被其他逻辑修改（如健康归零触发ENDING），避免覆盖

**涉及文件**: event_ui.gd

**相关规范**: [Godot 编码规范汇总 - 24.4 状态机回调防护](../../../Godot%20编码规范汇总.md#244-状态机回调防护-🔴-强制)

---

## §85 ParticleProcessMaterial.color_ramp类型限制 🟡 中

**问题**: 尝试将Gradient对象直接赋值给ParticleProcessMaterial的color_ramp属性报错

**根因**: `color_ramp`属性需要`Texture2D`类型，不能直接赋值`Gradient`对象。必须通过`GradientTexture1D`包装

**踩坑过程**:
1. 创建粒子效果时需要渐变色
2. 直接创建Gradient对象并赋值给process_mat.color_ramp
3. 报类型错误：color_ramp期望Texture2D，传入了Gradient
4. 查阅文档发现color_ramp需要Texture2D类型

**解决方案**:

```gdscript
# ❌ 错误：直接赋值Gradient对象
var gradient: Gradient = Gradient.new()
gradient.colors = PackedColorArray([Color.RED, Color.BLUE])
process_mat.color_ramp = gradient  # 类型错误！color_ramp需要Texture2D

# ✅ 正确方案1：用GradientTexture1D包装Gradient
var gradient: Gradient = Gradient.new()
gradient.colors = PackedColorArray([Color.RED, Color.BLUE])
var gradient_tex: GradientTexture1D = GradientTexture1D.new()
gradient_tex.gradient = gradient
process_mat.color_ramp = gradient_tex  # 正确：GradientTexture1D是Texture2D子类

# ✅ 正确方案2：纯色粒子直接用color属性
process_mat.color = Color(1.0, 0.3, 0.3)  # 简单纯色，无需渐变
```

**规范**: 优先使用`process_mat.color`设置纯色粒子；需要渐变时必须用`GradientTexture1D`包装Gradient对象

**涉及文件**: enemy.gd

**相关规范**: [Godot 编码规范汇总 - 24.5 ParticleProcessMaterial颜色设置](../../../Godot%20编码规范汇总.md#245-particleprocessmaterial颜色设置-🟡-建议)

---

## 严重性统计

| 严重性 | 数量 | 章节 |
|--------|------|------|
| 🔴 **高** | 8 | §41, §43, §51, §52, §58, §81, §83, §84 |
| 🟡 **中** | 15 | §40, §42, §44, §45, §46, §47, §48, §49, §53, §54, §55, §56, §57, §82, §85 |
| 🟢 **低** | 1 | §50 |
| **总计** | **24** | §40-§58, §81-§85 |

---

## 相关文档

### Base 层相关
- [19_Pitfall_Records.md](./19_Pitfall_Records.md) - 基础踩坑记录（§1-§22）
- [Godot_4x_Autoload_Pitfalls.md](./Godot_4x_Autoload_Pitfalls.md) - Autoload 踩坑（§27-§31）
- [GUT_Testing_Pitfalls.md](./GUT_Testing_Pitfalls.md) - GUT 测试踩坑（§32-§36）
- [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](./Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md) - 资源引用踩坑（§37-§39）
- [GDScript_Code_Standards.md](../code-standards/GDScript_Code_Standards.md) - GDScript 代码规范

### Wiki 层相关
- [常见踩坑避雷指南](../../wiki/guides/common-pitfalls.md)
- [GDScript 代码规范](../../wiki/concepts/gdscript-standards.md)

### 索引层相关
- [踩坑记录完整索引](../../../踩坑记录完整索引.md)
- [Godot 编码规范汇总](../../../Godot%20编码规范汇总.md)

---

**文档版本**: 1.3
**最后更新**: 2026-04-22（新增 §81-§85 暴击/debuff/翻译键/状态机/粒子材质踩坑）
**维护者**: Knowledge Base Administrator
**来源**: tower_defense 项目实战经验
