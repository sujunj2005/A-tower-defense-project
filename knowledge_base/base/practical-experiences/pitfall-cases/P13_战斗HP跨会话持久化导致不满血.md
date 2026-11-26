# P13：战斗 HP 跨会话持久化导致不满血

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | 数据/状态管理 |
| **严重程度** | 🔴 高 |
| **涉及文件** | `battle_manager.gd` / `map_manager.gd` |
| **知识库关联** | [数据流规范](../best-practices/数据流规范.md) / [§78 apply_buff 复合修改 config](../../../outline/踩坑记录完整索引.md#78-apply_buff-复合修改-config-导致-timer-报错--高) |

---

## 现象

玩家报告：战斗从未失守（基地血条从未归零），但下次进入战斗时基地不是满血，而是继承了上次战斗结束时的血量（比如只剩 60%）。

## 根因

战斗结束时 `session.home_health` 保存了当前血量（战斗中被打掉的血没有被恢复），下次进战斗直接读取该值作为起始血量，从未重置为满血。

数据流向：
```
战斗开始 → session.home_health = max_hp（正确）
战斗中   → session.home_health = max_hp - 受到的伤害（正确）
战斗结束 → session.home_health 保持为当前值（问题！）
下次战斗 → session.home_health 仍为上次战斗结束时的值（bug！）
```

核心问题：`home_health` 既是"当前血量"又充当"持久化血量"，在跨战斗场景中含义混淆。

## 修复

引入 `accumulated_damage`（累计掉血）字段，将"当前血量"和"累计伤害"分离：

```gdscript
# ❌ 修复前：home_health 一身二任
class BattleSession:
    var home_health: float = 100.0   # 既表示当前血量，又跨战斗持久化

func _initialize_battle() -> void:
    session.home_health = max_hp  # 设为满血

func home_take_damage(amount: float) -> void:
    session.home_health -= amount  # 直接扣血

# ✅ 修复后：分离"当前血量"与"累计伤害"
class BattleSession:
    var max_hp: float = 100.0
    var accumulated_damage: float = 0.0  # 跨战斗持久化的累计伤害
    var current_hp: float                # 仅当前战斗使用的波动血量

func _initialize_battle() -> void:
    # 用 max_hp - accumulated_damage 作为起始HP
    session.current_hp = session.max_hp - session.accumulated_damage

func home_take_damage(amount: float) -> void:
    session.current_hp -= amount
    session.accumulated_damage += amount  # 同时累加到持久化字段
    # 同步到 map_manager
    MapManager.sync_home_health(session.current_hp)
```

### 数据流对比

| 阶段 | 修复前 | 修复后 |
|------|--------|--------|
| 战斗初始化 | `home_health = max_hp` | `current_hp = max_hp - accumulated_damage` |
| 基地受伤 | `home_health -= damage` | `current_hp -= damage`; `accumulated_damage += damage` |
| 战斗结束时 | `home_health` = 残血值（bug！） | `accumulated_damage` = 累计伤害值 |
| 下次战斗初始化 | 以残血值开始（bug！） | `current_hp = max_hp - accumulated_damage`（正确） |
| 治疗/恢复 | 需要特殊处理 | 重置 `accumulated_damage = 0` |

## 设计原则

**区分"当前血量"和"累计伤害"**：

- `current_hp`：随战斗波动，战斗结束时销毁
- `accumulated_damage`：跨战斗持久化，记录玩家在整个游戏流程中受到的累计伤害

这遵循了"可变状态 vs 持久状态分离"的设计原则：
- 可变状态（`current_hp`）的生命周期限于单个战斗
- 持久状态（`accumulated_damage`）的生命周期跨越多个战斗

## 预防

1. **设计持久化字段时，检查含义是否跨场景混淆**
2. **引入新字段前，明确其生命周期和与现有字段的关系**
3. **状态字段命名体现其语义**：`current_hp`（当前）vs `accumulated_damage`（累计）

## 教训

不要让一个字段承担两种语义。血量既是"当前战斗的即时值"又是"跨战斗的持久值"会导致严重的状态管理 bug。正确的做法是用独立的字段表达独立的概念。

---

*记录时间：2026-04-29*