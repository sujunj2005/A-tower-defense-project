# Godot 4.x 事件系统选项与家庭成员踩坑记录

> **适用版本**: Godot 4.6+
> **创建日期**: 2026-04-23
> **来源**: EventSystem / OptionSystem / EventUI 实战修复

---

## E17 选项系统职业条件检查支持否定前缀

### 问题

选项系统的职业条件检查只支持正向匹配（如 `"programmer"`），不支持否定条件（如 `"!programmer"` 表示"非程序员"）

### 根因

条件检查逻辑直接使用 `==` 或 `in` 比较，未解析条件字符串的前缀符号

### 解决方案

```gdscript
# ✅ 正确：解析条件前缀，支持否定条件
func _check_profession_condition(session_profession: String, condition_value: String) -> bool:
    if condition_value.begins_with("!"):
        # 否定条件：玩家职业不等于指定职业
        var target: String = condition_value.substr(1)
        return session_profession != target
    else:
        # 正向条件：玩家职业等于指定职业
        return session_profession == condition_value
```

**规则**: 选项系统的职业条件检查必须支持 `!` 前缀表示否定条件，如 `"!programmer"` 表示"玩家不是程序员时满足"

---

## E18 事件使用 family_member 字段标识关联家庭成员

### 问题

事件数据中缺少标识关联家庭成员的字段，导致无法追踪事件影响的具体家庭成员

### 根因

事件字典中未定义 `family_member` 字段来关联家庭成员 ID

### 解决方案

```gdscript
# ✅ 事件数据结构中添加 family_member 字段
var event_data: Dictionary = {
    "event_id": "family_reunion",
    "family_member": "spouse",  # 标识关联的家庭成员
    # ... 其他字段
}

# ✅ 在处理事件时读取并使用 family_member
func _process_event(event: Dictionary) -> void:
    var member_id: String = event.get("family_member", "")
    if not member_id.is_empty():
        var member: Dictionary = _get_family_member(member_id)
        if member.is_valid():
            _apply_event_to_member(event, member)
```

**规则**: 事件数据中涉及家庭成员时，必须使用 `family_member` 字段明确标识关联的成员 ID

---

## §E19 选项使用 family_effect 字段更新家庭成员状态

### 问题

选项数据中缺少更新家庭成员状态的机制

### 根因

选项字典中未定义 `family_effect` 字段来描述选择该选项后对家庭成员状态的影响

### 解决方案

```gdscript
# ✅ 选项数据结构中添加 family_effect 字段
var option_data: Dictionary = {
    "option_id": "A",
    "text": "option_family_reunion_care",
    "family_effect": {
        "member_id": "spouse",
        "alive_change": 0,  # 状态变化值，正数增加，负数减少
        # 可扩展其他状态字段
    }
}

# ✅ 在选择选项后应用 family_effect
func _apply_family_effect(option: Dictionary) -> void:
    var effect: Dictionary = option.get("family_effect", {})
    if effect.is_empty():
        return
    var member_id: String = effect.get("member_id", "")
    var alive_change: int = effect.get("alive_change", 0)
    _update_member_alive_state(member_id, alive_change)
```

**规则**: 选项数据中需要影响家庭成员状态时，必须使用 `family_effect` 字段描述影响（如 `alive_change`），并在选项处理逻辑中应用

---

## §E20 event_ui.gd 中 /root 路径访问前必须检查 is_inside_tree()

### 问题

`event_ui.gd` 中在 `select_option()` 后使用 `get_node_or_null("/root/...")` 访问全局节点，可能触发场景切换导致当前节点被移出场景树，报错 `Can't use get_node() with absolute paths from outside the active scene tree`

### 根因

`select_option()` 可能触发状态切换（如进入 BATTLE 阶段），导致当前 UI 节点被移出场景树，后续对 `/root` 绝对路径的访问报错

### 解决方案

```gdscript
# ❌ 错误：场景切换调用后继续访问 /root 路径
func _on_option_pressed(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)  # 可能触发场景切换
    var node = get_node_or_null("/root/SomeNode")  # 报错！当前节点已不在场景树

# ✅ 正确：在可能触发场景切换的调用之后，加 is_inside_tree() 检查
func _on_option_pressed(option: Dictionary) -> void:
    EventSystem.select_option(event_data, option)
    if not is_inside_tree():
        return  # 场景已切换，安全退出
    var node = get_node_or_null("/root/SomeNode")
    if node:
        # 安全使用 node
        pass
```

**规则**: 在 `event_ui.gd` 等可能被场景切换影响的 UI 脚本中，使用 `get_node()` / `get_node_or_null()` 访问 `/root` 路径前，必须先检查 `is_inside_tree()`

**相关踩坑**: [§51 节点被移出场景树后调用get_node_or_null报错](../../../wiki/guides/common-pitfalls.md#51-节点被移出场景树后调用get_node_or_null报错--高)

---

## §E21 翻译键使用规范：选项文本与特质翻译键前缀分离

### 问题

选项文本使用 `TRAIT_` 前缀的翻译键，特质使用 `OPTION_` 前缀，翻译键前缀混用导致语义混乱、翻译文件管理困难、后续维护成本高

### 根因

添加翻译键时未遵循统一的前缀约定，选项文本和特质内容的翻译键前缀颠倒或混用

### 解决方案

**统一翻译键前缀规范**:

| 内容类型 | 翻译键前缀 | 示例 |
|---------|-----------|------|
| 选项文本 | `OPTION_` | `OPTION_EVENT_LETTER_TEXT` |
| 特质名称 | `TRAIT_` | `TRAIT_QUICK_LEARNER_NAME` |
| 特质描述 | `TRAIT_` | `TRAIT_QUICK_LEARNER_DESC` |
| 事件名称 | `EVENT_` | `EVENT_MATH_CONTEST_NAME` |

```gdscript
# ❌ 错误：选项文本使用 TRAIT_ 前缀
option_text = tr("TRAIT_OPTION_A_TEXT")  # 前缀错误！

# ❌ 错误：特质名称使用 OPTION_ 前缀
trait_name = tr("OPTION_QUICK_LEARNER_NAME")  # 前缀错误！

# ✅ 正确：选项文本使用 OPTION_ 前缀
option_text = tr("OPTION_MATH_CONTEST_A_TEXT")

# ✅ 正确：特质名称使用 TRAIT_ 前缀
trait_name = tr("TRAIT_QUICK_LEARNER_NAME")
```

**规则**: 🔴 **强制** —— 选项文本翻译键必须使用 `OPTION_` 前缀，特质翻译键必须使用 `TRAIT_` 前缀，两者不得混用。添加新翻译键时必须先搜索确认前缀约定

**相关踩坑**: [§62 翻译键命名不一致导致重复](../../../outline/踩坑记录完整索引.md#62-翻译键命名不一致导致重复--中)

---

**文档版本**: 1.0
**最后更新**: 2026-04-23
**维护者**: Knowledge Base Administrator
