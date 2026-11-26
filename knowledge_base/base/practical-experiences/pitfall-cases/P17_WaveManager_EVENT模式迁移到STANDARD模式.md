# P17：WaveManager EVENT 模式迁移到 STANDARD 模式

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | 架构/重构 |
| **严重程度** | 🟡 中 |
| **涉及文件** | `wave_manager.gd` / `map_manager.gd` / `battle_trigger` 相关 / `stages.json` |
| **知识库关联** | [§38 数据格式不一致](../../../wiki/guides/common-pitfalls.md#38-数据格式不一致导致条件判断永远失败--中) / [P13 战斗 HP 跨会话持久化](./P13_战斗HP跨会话持久化导致不满血.md) |

---

## 背景

事件选项中的 `battle_trigger` 原本包含 `waves` 字段（定义事件战斗的独立波次配置），但经架构评审后决定移除 `waves` 字段，事件战斗统一使用塔防的 STANDARD 模式（由 `stages.json` 统一配置波次）。这需要将 WaveManager 从支持两种模式（EVENT / STANDARD）简化为只支持 STANDARD。

## 重构步骤

### 1. 简化 `battle_trigger`

```gdscript
# 重构前：battle_trigger 包含 waves 配置
{
    "battle_trigger": {
        "battle_id": "event_battle_01",
        "is_deadly": true,
        "force_map_id": "",
        "waves": [
            {"enemy_id": "math_problem", "count": 5, "interval": 1.0},
            {"enemy_id": "exam_paper", "count": 3, "interval": 2.0}
        ]
    }
}

# 重构后：battle_trigger 只保留三个字段
{
    "battle_trigger": {
        "battle_id": "stages_event_01",
        "is_deadly": true,
        "force_map_id": ""
    }
}
# waves 由 stages.json 统一管理
```

### 2. WaveManager 移除 EVENT 枚举值和 `start_event_battle` 方法

```gdscript
# 重构前
enum BattleMode {
    STANDARD,
    EVENT  # ← 移除
}

func start_event_battle(waves: Array) -> void:
    # 使用 battle_trigger 中的 waves 配置

# 重构后：只保留 STANDARD
enum BattleMode {
    STANDARD
}

# start_event_battle 方法完全删除
```

### 3. `map_manager` 统一调用 `start_battle(stage_config)`

```gdscript
# 重构前：分支判断
if is_event_battle:
    WaveManager.start_event_battle(event_waves)
else:
    WaveManager.start_battle(stage_config)

# 重构后：统一入口
WaveManager.start_battle(stage_config)
# 所有战斗（事件战斗和阶段战斗）都走同一方法
```

### 4. `enemy_pool` 格式兼容（Dictionary → Array[Dictionary] 转换）

这是迁移中最关键的坑点：

```json
// stages.json 中的 enemy_pool 格式
{
    "stages": {
        "child_01": {
            "enemy_pool": {
                "homework": 3,
                "quiz": 2,
                "exam_paper": 1
            }
        }
    }
}
```

```gdscript
# WaveManager.start_battle() 内部期望的格式
# 期望：Array[Dictionary]
# [
#     {"enemy_id": "homework", "weight": 3},
#     {"enemy_id": "quiz", "weight": 2},
#     {"enemy_id": "exam_paper", "weight": 1}
# ]

# ✅ 需要在加载 stages.json 时做格式转换
func _convert_enemy_pool(raw_pool: Dictionary) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for enemy_id in raw_pool:
        result.append({
            "enemy_id": enemy_id,
            "weight": raw_pool[enemy_id]
        })
    return result
```

**为什么这个坑容易忽视**：`enemy_pool` 的 Dictionary 格式 `{"enemy_id": weight}` 和 Array[Dictionary] 格式 `[{"enemy_id": ..., "weight": ...}]` 都能在 GDScript 中正常工作（都是合法类型），但 `WaveManager.start_battle()` 内部用 `for pool_item in enemy_pool` 遍历 Array，如果传入 Dictionary 则会按 key 遍历导致逻辑错误。

### 5. 致命战斗自动选 `map_hospital`

```gdscript
# is_deadly = true 的事件战斗，force_map_id 默认为 map_hospital
func _resolve_battle_map(battle_trigger: Dictionary) -> String:
    if battle_trigger.get("is_deadly", false):
        return "map_hospital"
    return battle_trigger.get("force_map_id", "")
```

## 重构验证清单

```
- [ ] WaveManager 中不再有 EVENT 枚举值
- [ ] start_event_battle() 方法已删除
- [ ] 所有 battle_trigger 不包含 waves 字段
- [ ] stages.json 的 enemy_pool 格式转换正确
- [ ] 事件战斗（致命/非致命）均能正常触发
- [ ] 事件战斗后结算面板正常显示
- [ ] 旧存档兼容（如有持久化数据）
```

## 教训

**模式迁移时要检查所有数据格式的上下游兼容性**：

1. **上游（JSON 配置）**：stages.json 的 `enemy_pool` 是 Dictionary 格式，但 WaveManager 内部期望 Array[Dictionary]
2. **下游（消费者）**：map_manager 不再需要区分事件战斗和阶段战斗，统一调用 `start_battle(stage_config)`
3. **数据流中间环节**：加载 JSON 时就要做格式转换，不要推迟到使用时再转

重构最容易遗漏的是"看起来差不多但实际上格式不同"的数据结构，因为编译器/类型系统往往不会报错，只能靠运行时验证。

---

*记录时间：2026-04-30*
