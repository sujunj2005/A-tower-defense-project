# P16：config_tool.py 合并 events sheet 读写设计

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | 工具/Python |
| **严重程度** | 🟢 参考 |
| **涉及文件** | `config_tool.py` / `events.json` / `options.json`（合并后仅为 `events.json`） |
| **知识库关联** | [§39 修改数据格式遗漏配置文件消费者](../../../wiki/guides/common-pitfalls.md#39-修改数据格式时遗漏配置文件消费者--中) / [§73 JSON 字段名不匹配](../../../outline/踩坑记录完整索引.md#73-json-字段名不匹配--中) |

---

## 背景

项目最初 `events.json` 和 `options.json` 是两个独立文件，`config_tool.py` 中有两个独立的 Excel sheet 分别导出/导入。后续架构调整，将 `options` 内嵌到 `events.json` 中（每个 event 包含 `options: Array[Dictionary]`），`config_tool.py` 需要改为单一 `events` sheet 的读写设计。

## 设计要点

### 1. 导出：每个选项一行，事件级字段冗余填充

```
Excel 中的 events sheet 结构：

| event_id | event_name | stage | ... | option_id | option_text | option_gold | ... |
|----------|------------|-------|-----|-----------|-------------|-------------|-----|
| E001     | 数学竞赛   | child | ... | A         | 参加        | 50          | ... |
| E001     | 数学竞赛   | child | ... | B         | 弃权        | -20         | ... |
| E002     | 运动会     | teen  | ... | A         | 报名        | 0           | ... |
```

- 事件级字段（`event_id`、`event_name`、`stage` 等）在同一个 event 的多行中**冗余填充相同值**
- 每个选项占一行，选项字段（`option_id`、`option_text`、`option_gold` 等）在对应行中填充

### 2. 导入：按 `event_id` 分组还原嵌套结构

```python
# config_tool.py 导入逻辑（简化示意）

# 第一步：按 event_id 分组
events_grouped = {}
for row in rows:
    eid = row["event_id"]
    if eid not in events_grouped:
        events_grouped[eid] = {"options": []}
    # 填充事件级字段（取第一行的值）
    events_grouped[eid].update(event_fields)
    # 追加选项
    events_grouped[eid]["options"].append(extract_option(row))

# 第二步：还原为 JSON 嵌套结构
events = list(events_grouped.values())
```

### 3. flatten / unflatten 处理嵌套 dict/list

对于 `events.json` 中的嵌套字段（如 `conditions`、`consequences`），导出时 flatten 为独立列，导入时 unflatten 还原：

```python
# 导出：flatten
# {"conditions": [{"type": "gold", "op": ">=", "value": 100}]}
# → column: conditions_0_type = "gold", conditions_0_op = ">=", conditions_0_value = 100

# 导入：unflatten
# 根据列名中的索引号 _0_, _1_ 分组还原为 Array[Dictionary]
```

### 4. EVENT_OPTION_FIELDS 和 EVENT_EVENT_FIELDS 分离字段域

```python
EVENT_EVENT_FIELDS = [
    "event_id", "event_name", "stage", "trigger_chance",
    "chain_prerequisites", "chain_excludes", ...
]

EVENT_OPTION_FIELDS = [
    "option_id", "option_text", "gold_change",
    "battle_trigger", "consequences", ...
]
```

导入时用字段域区分行内的哪些列属于事件级、哪些属于选项级。

### 5. 兼容原有 `is_i18n_field` 机制

```python
# 某些字段的值是翻译键（如 event_name → "EVENT_MATH_CONTEST_NAME"），
# 导出到 Excel 时保持键名，不展开翻译值
I18N_EVENT_FIELDS = ["event_name", "event_description", ...]
I18N_OPTION_FIELDS = ["option_text", "option_description", ...]
```

## 数据流总结

```
JSON（嵌套） ──flatten──→ Excel（扁平行） ──group_by event_id──→ JSON（嵌套）
  events.json     ↑ 导出          events sheet        ↑ 导入        events.json
  [                   [                               [
    {                   {event_id: E001, option: A}      {
      event_id: E001,    {event_id: E001, option: B}      event_id: E001,
      options: [...]    {event_id: E002, option: A}      options: [...]
    }                   ]                               }
  ]                                                 ]
```

## 教训

合并配置的导入导出工具设计需要明确"**扁平化 → 分组 → 还原**"三阶段流程：

1. **扁平化**：嵌套结构展开为冗余行（每个子元素一行，父级字段冗余填充）
2. **分组**：按主键将冗余行重新分组
3. **还原**：从分组数据中提取父级字段（取首行值）和子元素列表

设计前先想清楚：**Excel 的二维表结构如何映射到 JSON 的嵌套结构？反过来呢？**

---

*记录时间：2026-04-30*
