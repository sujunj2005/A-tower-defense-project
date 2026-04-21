# Godot 4.x 资源引用与数据一致性踩坑

> **适用版本**: Godot 4.6+  
> **发现日期**: 2026-04-11  
> **严重性**: 🔴 高（§37）/ 🟡 中（§38-§39）  
> **来源**: 人生塔防项目实战

---

## §37 .tres 文件 ext_resource 引用已删除文件导致整体加载失败 🔴 高

### 问题

删除 `.tres` 资源文件后，其他 `.tres` 文件中的 `[ext_resource]` 仍引用已删除的文件路径，导致**整个 .tres 文件无法加载**，而非仅跳过缺失资源。

### 踩坑过程

1. 清理项目时批量删除了 14 个 `.tres` 文件（塔/敌人/波次配置）
2. 运行游戏后报错：`MapConfig: Failed to load resource from: res://resources/maps/map_01.tres`
3. 排查发现 `map_01.tres` 中有 4 个 `[ext_resource]` 引用了已删除文件：
   - `heavy_armor.tres`、`magic_shield.tres`、`wave_1.tres`、`wave_2.tres`
4. Godot 的 .tres 加载机制：**任何一个 ext_resource 找不到，整个 .tres 都无法加载**

### 根因

Godot 的 `.tres` 文件加载是原子操作——所有 `[ext_resource]` 必须全部可解析，否则整个资源加载失败。这与代码中的 `preload()` 不同，`preload()` 缺失资源会在编译时报错，而 `.tres` 的 `ext_resource` 缺失在运行时静默失败。

### 解决方案

```gdscript
# ❌ 错误：删除 .tres 文件后不清理引用
# 删除了 res://resources/enemies/heavy_armor.tres
# 但 map_01.tres 中仍有：
# [ext_resource id="3" type="Resource" path="res://resources/enemies/heavy_armor.tres"]

# ✅ 正确：删除 .tres 文件时，同步清理所有引用该文件的 .tres 中的 ext_resource
# 1. 全局搜索被删除文件的路径
# 2. 从引用方 .tres 中移除对应的 [ext_resource] 行
# 3. 移除 [resource] 中使用该 id 的属性
# 4. 更新 load_steps 计数
```

### 预防措施

1. **删除资源前全局搜索引用**：删除任何 `.tres` 文件前，先在项目中搜索该文件路径
2. **使用 .bak 后缀代替直接删除**：将不用的 `.tres` 改名为 `.tres.bak`，Godot 不会加载 `.bak` 文件，但引用仍可追溯
3. **逐步迁移到 JSON 配置**：本项目已将塔/敌人/事件配置迁移到 JSON，避免 .tres 引用链问题

---

## §38 数据格式不一致导致条件判断永远失败 🟡 中

### 问题

`session.family_background` 存储完整 ID（如 `"family_farmer"`），而 `events.json` 的条件使用短名（如 `"!farmer"`），导致比较永远不匹配，条件判断形同虚设。

### 踩坑过程

1. 事件选项配置了 `"requirements": {"family_background": "!farmer"}`，意图排除农民
2. 农民开局仍可选择该选项——条件未生效
3. 排查发现 `session.family_background` 值为 `"family_farmer"`
4. 比较逻辑：`"family_farmer" == "farmer"` → `false`，排除条件永远不触发

### 根因

数据源（`family_backgrounds.json`）的 `family_id` 字段使用 `"family_farmer"` 格式，而条件配置（`events.json`）使用 `"farmer"` 格式。两个配置文件的数据格式约定不一致，且没有在代码层做统一转换。

### 错误修复方式

```gdscript
# ❌ 错误方式：在每个消费者处提取短名（运行时转换）
# event_ui.gd
var session_bg_short: String = session.family_background.replace("family_", "")
if session_bg_short == "farmer":  # 每个消费者都要做转换

# event_system.gd
var session_bg_short: String = session.family_background.replace("family_", "")
if session_bg_short == "farmer":  # 又要重复转换
```

### 正确修复方式

```gdscript
# ✅ 正确方式：在数据源头统一格式，消费者直接使用
# era_system.gd（数据源）
var raw_family_id: String = current_family.get("family_id", "worker")
session.family_background = raw_family_id.replace("family_", "")
# 现在 session.family_background 直接存储 "farmer"

# event_ui.gd / event_system.gd（消费者）
if session.family_background == "farmer":  # 直接比较，无需转换
    return false
```

### 核心原则

> **数据格式应在源头统一，而非在每个消费者处转换**

1. **单一转换点**：数据格式转换只在一处完成（数据入口），所有消费者使用统一格式
2. **配置文件对齐**：修改数据格式后，必须同步检查所有配置文件（`events.json`、`achievements.json` 等）
3. **全局搜索验证**：修改 `session` 字段格式后，全局搜索该字段名，逐一确认兼容性

---

## §39 修改数据格式时遗漏配置文件消费者 🟡 中

### 问题

修改 `session.family_background` 的存储格式后，只更新了代码文件，遗漏了 `achievements.json` 中的配置值，导致成就系统匹配失败。

### 踩坑过程

1. 将 `session.family_background` 从 `"family_farmer"` 改为 `"farmer"`
2. 更新了 `era_system.gd`、`event_ui.gd`、`event_system.gd` 的代码
3. 遗漏了 `achievements.json` 中的 `"family": "family_farmer"` 和 `"families": ["family_cadre", ...]`
4. 成就系统的 `on_ending_reached()` 将 `session.family_background`（`"farmer"`）加入 `_families_completed`
5. 但 `check_achievement()` 比较的是配置中的 `"family_farmer"`，永远不匹配

### 根因

修改数据格式时只关注了代码文件（.gd），忽略了 JSON 配置文件也是数据消费者。JSON 配置中的硬编码值必须与代码中的数据格式保持一致。

### 解决方案

```json
// ❌ 修改前：achievements.json 使用完整 ID
{
  "condition": {
    "type": "family_ending_combo",
    "family": "family_farmer",  // 与 session.family_background 不一致
    "min_rating": "A"
  }
}

// ✅ 修改后：achievements.json 使用短名，与 session.family_background 一致
{
  "condition": {
    "type": "family_ending_combo",
    "family": "farmer",  // 与 session.family_background 一致
    "min_rating": "A"
  }
}
```

### 预防措施

1. **修改字段格式时全局搜索**：不仅搜索 `.gd` 文件，还要搜索 `.json`、`.tres`、`.tscn` 等所有可能引用该字段的文件
2. **建立字段格式文档**：记录每个 session 字段的格式约定（如 `family_background` 存储短名）
3. **配置文件审查清单**：修改代码数据格式后，逐一检查所有 JSON 配置文件

### 修改数据格式的完整检查清单

```
- [ ] 全局搜索字段名（含 .gd / .json / .tres / .tscn）
- [ ] 逐一确认每个引用点的兼容性
- [ ] 更新代码中的比较逻辑
- [ ] 更新 JSON 配置中的硬编码值
- [ ] 更新默认值（如 session_data.gd 的 @export 默认值）
- [ ] 更新测试用例中的测试数据
- [ ] 运行场景验证
```

---

## 📊 总结

| 章节 | 严重性 | 核心教训 |
|------|--------|----------|
| §37 | 🔴 高 | 删除 .tres 文件必须同步清理所有 ext_resource 引用 |
| §38 | 🟡 中 | 数据格式在源头统一，消费者不做运行时转换 |
| §39 | 🟡 中 | 修改数据格式时，JSON 配置文件也是消费者，必须同步更新 |
