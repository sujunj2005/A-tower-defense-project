# 事件系统 v2.0 设计规格

> **版本:** v1.0 | **日期:** 2026-04-28 | **状态:** 待批准

## 一、设计支柱

| 编号 | 支柱 | 含义 | 设计标尺 |
|------|------|------|---------|
| **DP-1** | **选择有重量** | 每个选项必须带来可感知的后果 | "这个选择如果反过来，体验会不同吗？" |
| **DP-2** | **人生有张力** | 多线并发的未完成目标持续施压 | "玩家此刻在焦虑什么？" |
| **DP-3** | **命运有因果** | 善恶有报，性格决定命运 | "这个角色的结局是TA自己走出来的吗？" |
| **DP-4** | **文字有画面** | 纯文字必须触发玩家脑内画面 | "读到这段文字时，我看到画面了吗？" |

---

## 二、核心游戏循环

### 即时体验（0–10秒）
```
事件弹出 → 读描述（2秒）→ 看选项（3秒）→ 做选择（2秒）→ 看后果反馈（3秒）
```
**玩家感受：** "我又遇到了什么事？我该怎么做？后果是什么？"

### 单次会话循环（10–30分钟）
```
点击"年龄+1" → 处理当年所有事件 → 积累战斗资源 → 进入塔防战斗 → 结算 → 继续下一年
```
**玩家感受：** "这一年我做了什么决定？我的战斗力变强了吗？"

### 长期循环（1–3小时/完整人生）
```
出生选择 → 童年奠基 → 青年奋斗 → 中年危机 → 老年传承 → 人生结算 → 再来一局
```
**玩家感受：** "我这次的人生和上次有什么不同？我能达成更好的结局吗？"

---

## 三、事件分层架构

```
事件系统 v2.0
│
├── Layer 1: 叙事引擎（玩家能感知到的）
│   ├── EventTrigger（事件触发）
│   ├── NarrativeText（叙事文本）
│   ├── ChoicePanel（选项面板）
│   └── ConsequenceFeedback（后果反馈）
│
├── Layer 2: 世界引擎（驱动事件发生的）
│   ├── WorldState（世界状态：年龄/阶段/财富/职业）
│   ├── NPCNetwork（NPC关系网络）
│   ├── TensionMatrix（张力矩阵：多线并发压力）
│   └── RNGPool（随机池：基础事件+稀有事件）
│
├── Layer 3: 底层引擎（不可见的计算层）
│   ├── KarmaEngine（业力引擎：全局运气修正）
│   ├── PersonalityEngine（人格引擎：行为倾向）
│   ├── WeightCalculator（权重计算器）
│   └── ChainResolver（事件链解析器）
│
└── Layer 4: 战斗桥接层
    ├── ResourceAccumulator（资源累积器）
    ├── BattleTrigger（战斗触发器）
    └── DifficultyScaler（难度调节器）
```

---

## 四、数据模型

### 4.1 WorldState（替代现有 session_data 核心字段）

```gdscript
class_name WorldState extends Resource

## 时间维度
@export var current_age: int = 0
@export var era_id: String = ""

## 四维显性属性（对齐 BitLife 核心）
@export var happiness: int = 70       # 幸福感 - 影响心理健康、工作表现
@export var health: int = 90          # 健康值 - 归零即死亡
@export var intelligence: int = 50    # 智力值 - 影响学业/职业成功率
@export var appearance: int = 50      # 外貌值 - 影响社交/恋爱事件

## 隐性属性（仅上帝模式可见）
@export var willpower: int = 50       # 意志力 - 抗拒诱惑
@export var craziness: int = 50       # 疯狂度 - 极端行为倾向
@export var discipline: int = 50      # 纪律性 - 学业/职场自律
@export var karma: int = 0            # 业力值 - 全局运气修正（-100~+100）

## 社会维度
@export var gold: int = 0
@export var profession_id: String = ""
@export var fame: int = 0             # 名望值 - 解锁名人事件
@export var education_level: String = ""  # 学历等级

## 战斗资源
@export var towers: Dictionary = {}
@export var traits: Array[String] = []
```

**设计决策 D-201:** 当前6维属性（charm/courage/health/intelligence/work_ability/luck）缺乏明确的情感锚点，玩家难以建立"我在管理人生"的直觉。改为**四维显性属性**（对齐BitLife）+ **隐性人格**的架构，玩家一眼就知道"我的人生状态"。

**向后兼容:** 现有6维属性通过映射表自动转换为新结构：
```
charm → appearance (线性映射)
courage → willpower (线性映射)
work_ability → discipline (线性映射)
luck → karma (映射到 -100~100)
intelligence → intelligence (直接保留)
health → health (直接保留)
```

### 4.2 TensionData

```gdscript
class_name TensionData extends Resource

@export var tension_id: String = ""
@export var source_event: String = ""          # 来源事件ID
@export var title: String = ""                 # 显示标题，如"高考倒计时"
@export var description: String = ""           # 描述
@export var remaining: int = 0                 # 剩余年数
@export var duration: int = 0                  # 总年数
@export var pressure: float = 0.0              # 压力值 0~1
@export var resolution_event: String = ""      # 到期触发的事件
@export var tension_type: String = ""          # career/health/family/crime/exam
```

### 4.3 NPCData 重构

```gdscript
class_name NPCData extends Resource

@export var npc_id: String = ""
@export var name: String = ""
@export var relation: String = ""              # father/mother/spouse/friend/boss
@export var affection: int = 50                # 好感度 0~100
@export var age: int = 0
@export var is_alive: bool = true
@export var health: int = 100

## 人格参数（独立于玩家属性）
@export var willpower: int = 50
@export var craziness: int = 50
@export var generosity: int = 50
@export var loyalty: int = 50                  # 忠诚度
@export var ambition: int = 50                 # 野心值

## 资源与关系
@export var wealth: int = 0                    # 财富（遗产基础）
@export var trust: int = 50                    # 信任度（独立于好感度）
```

### 4.4 EventData 扩展

```
新增字段（不破坏现有结构）：
├── karma_type: String           # "positive"/"negative"/"neutral"
├── personality_checks: Dict     # {"willpower": "low", "craziness": "high"}
├── related_npcs: Array[String]  # 关联NPC ID列表
├── tension_category: String     # "career"/"health"/"family"/"crime"/"exam"
├── trait_boosts: Dict           # {"ambitious": 1.5}
├── rarity: String               # "common"/"uncommon"/"rare"/"legendary"
└── tension_duration: int        # 触发张力持续年数
```

### 4.5 OptionData 扩展

```
新增字段（不破坏现有结构）：
├── karma_cost: int              # karma变更值
├── world_changes: Dict          # 统一的世界状态变更（替代零散的attribute_changes等）
└── tension_changes: Array[Dict] # 张力变更 [{"action": "add", "tension_id": "xxx", "duration": 5}]
```

---

## 五、事件触发流程

```
┌─────────────────────────────────────────────────┐
│                 AGE UP 触发                       │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  Step 1: 收集候选事件池                            │
│  - 年龄匹配                                       │
│  - 阶段匹配                                       │
│  - 前置条件检查（chain_flags/requirements）          │
│  - 互斥事件检查                                    │
│  - 排除已完成事件                                  │
│  - 稀有度过滤（rarity checks）                       │
└──────────────┬──────────────────────────────────┘
               │ 候选事件: [A, B, C, D, E]
               ▼
┌─────────────────────────────────────────────────┐
│  Step 2: 计算动态权重                              │
│                                                   │
│  weight = base_weight                            │
│           × karma_multiplier(karma)               │
│           × personality_modifier(world_state)     │
│           × npc_modifier(npc_network)             │
│           × tension_modifier(tension_matrix)      │
│           × trait_modifier(traits)                │
│           × freshness_bonus(not_recent)           │
│                                                   │
│  最终权重: [A:2.3, B:0.8, C:4.1, D:1.5, E:0.2]   │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  Step 3: 加权随机抽取（1~3个/年）                   │
│  - 权重>3.0 的事件保证触发                          │
│  - 保底机制：如果所有权重<0.5，随机抽取1个             │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  Step 4: 按权重降序逐个弹出事件                     │
│  事件A弹出 → 玩家选择 → 后果执行 → 更新世界状态      │
│  → 检查张力到期 → 检查连锁事件                      │
│  → 事件B弹出 → ...                                │
└─────────────────────────────────────────────────┘
```

---

## 六、权重计算引擎

```gdscript
func _calculate_event_weight(event: EventData, world: WorldState, npcs: Array) -> float:
    var weight: float = event.base_weight

    # ── Karma 修正 ──
    if event.karma_type == "positive":
        weight *= 1.0 + (world.karma / 100.0) * 0.3
    elif event.karma_type == "negative":
        weight *= 1.0 - (world.karma / 100.0) * 0.5

    # ── 人格修正 ──
    if event.personality_checks.has("willpower") and world.willpower < 30:
        weight *= 1.4
    if event.personality_checks.has("craziness") and world.craziness > 70:
        weight *= 1.5

    # ── NPC 修正 ──
    for npc: NPCData in npcs:
        if npc.npc_id in event.related_npcs:
            if npc.affection > 80:
                weight *= 1.3
            elif npc.affection < 20:
                weight *= 0.5
            if npc.craziness > 80:
                weight *= 1.4

    # ── 张力修正 ──
    for tension: TensionData in world.active_tensions:
        if tension.type == event.tension_category:
            weight *= (1.0 + tension.pressure)

    # ── 特质修正 ──
    for trait: String in world.traits:
        if trait in event.trait_boosts:
            weight *= event.trait_boosts[trait]

    # ── 新鲜度修正 ──
    if event.event_id in world.recent_events:
        weight *= 0.3

    return weight
```

---

## 七、Karma 系统

### 7.1 Karma 变更来源

| 行为类别 | Karma变化 | 示例 |
|---------|----------|------|
| 善举 | +5 ~ +20 | 捐赠、举报犯罪、救助他人 |
| 恶行 | -10 ~ -50 | 偷窃、出轨、遗弃家人 |

### 7.2 Karma 影响矩阵

| Karma 区间 | 正面事件权重 | 负面事件权重 | 稀有事件触发率 |
|-----------|------------|------------|--------------|
| +70 ~ +100 | ×1.3 | ×0.5 | ×2.0（主角光环） |
| +30 ~ +69 | ×1.1 | ×0.8 | ×1.5 |
| -29 ~ +29 | ×1.0 | ×1.0 | ×1.0（正常） |
| -30 ~ -69 | ×0.9 | ×1.2 | ×0.7 |
| -70 ~ -100 | ×0.7 | ×1.5 | ×0.5（厄运缠身） |

### 7.3 Karma 可见性

- **玩家可见值：** 仅显示"业力"图标和模糊状态（如"你最近做了不少好事"）
- **精确值：** 仅上帝模式/调试面板可见
- **设计理由：** 保持Karma的神秘感，增强"因果报应"的叙事张力

---

## 八、张力系统

### 8.1 张力类型

| 张力类型 | 来源事件 | 压力等级 | 到期后果 | 玩家感受 |
|---------|---------|---------|---------|---------|
| **exam** | 高考/考研选择 | high | 考试事件，成功/失败分支 | "时间不够了" |
| **career** | 升职考核/创业 | medium | 职业事件，失业或晋升 | "我必须做好" |
| **health** | 健康警告 | high | 疾病事件，可能致命 | "我快撑不住了" |
| **family** | 婚姻危机/子女教育 | medium | 家庭事件，关系恶化 | "家要散了" |
| **crime** | 犯罪后通缉 | high | 追捕事件，入狱或逃脱 | "我快被发现了" |
| **finance** | 投资/负债 | low | 财务事件，破产或暴富 | "钱要没了" |

### 8.2 张力生命周期

```
添加张力 → 每年显示进度条 → 压力影响事件权重 → 到期检定
                                                    │
                                    ┌───────────────┼───────────────┐
                                    ▼               ▼               ▼
                                  成功            失败            部分成功
                                (奖励)           (惩罚)          (中间状态)
```

### 8.3 张力可视化

```
玩家UI - 事件面板上方：

┌──────────────────────────────────┐
│ ⏳ 高考倒计时 [██████░░░░] 3年    │
│ ⚠️  健康隐患   [████░░░░░░] 2年    │
│ 💼 升职考核   [████████░░] 4年    │
└──────────────────────────────────┘
```

---

## 九、NPC 关系深度

### 9.1 NPC 驱动事件机制

```
高疯狂度NPC → 频繁主动发起关系事件
低忠诚度+高魅力玩家 → 配偶出轨事件概率提升
高慷慨+高财富NPC → 死亡后高额遗产
高野心NPC → 更可能升职/创业，带来相关事件
```

### 9.2 遗产继承系统

```
NPC死亡 → 检查遗嘱标记 → 按关系亲密度+trust排序继承人
→ 分配遗产（gold + 可选trait）
→ 触发遗产事件（可选争夺）
```

---

## 十、稀有事件（离群值）

### 10.1 稀有度等级

| 稀有度 | 触发概率 | 事件示例 | 设计目的 |
|-------|---------|---------|---------|
| **common** | 常规权重 | 日常事件 | 填充生命周期 |
| **uncommon** | 权重×0.5 | 中彩票、遇到贵人 | 制造惊喜 |
| **rare** | 触发率 0.01 | 陨石、雷击 | 戏剧性转折 |
| **legendary** | 触发率 0.003 | 遇到独角兽、全属性+100 | 终局回忆点 |

### 10.2 双极性事件

```
event_meteor_strike (rarity=legendary):
  → 50%: 立即死亡（悲剧结局）
  → 50%: 全属性+100 + happiness=100（爽文结局）

event_lightning (rarity=rare):
  → 50%: health=-50（重伤）
  → 50%: intelligence+30（开窍）
```

**设计理由：** 极端事件必须有记忆点，双极性设计让玩家"非黑即白"地记住这局人生。

---

## 十一、后果执行引擎

### 11.1 统一后果结构

```
每个选项的后果通过以下方式表达（替代现有零散字段）：

world_changes: {
  "happiness": -10,
  "health": 5,
  "intelligence": 3,
  "appearance": 0,
  "willpower": 10,
  "craziness": 0,
  "discipline": 5,
  "karma": -5,
  "gold": 5000,
  "fame": 10
}

tension_changes: [
  {"action": "add", "tension_id": "debt_pressure", "duration": 5},
  {"action": "resolve", "tension_category": "family"},
  {"action": "extend", "tension_id": "exam_gaokao", "years": 1}
]

npc_changes: {
  "spouse": {"affection": -15, "trust": -20},
  "father": {"affection": 10}
}

flag_changes: ["midlife_splurge", "donated_charity"]
trait_gains: ["optimistic"]
trait_losses: ["anxious"]
event_unlocks: ["event_new_car"]
event_locks: ["event_old_car_maintenance"]
```

**设计决策:** 保留现有 OptionData 的零散字段（attribute_changes, trait_gains, gold_change 等）作为**向后兼容层**，新增 `world_changes` 作为统一接口。新事件使用新接口，旧事件保持不变。

### 11.2 执行顺序

```
1. 检查 requirements → 不满足则选项不可用
2. 应用 cost（金币/属性消耗）
3. 应用 world_changes（统一状态变更）
4. 应用 tension_changes（张力管理）
5. 应用 npc_changes（NPC关系变更）
6. 应用 flag_changes/trait_gains/trait_losses
7. 处理 event_unlocks/locks
8. 处理 battle_trigger（如有）
9. 处理 ending_trigger（如有）
10. 处理 map_weights（如有）
11. 保存事件到 completed_events
```

---

## 十二、迁移策略

### 12.1 渐进式迁移（不破坏现有游戏）

| 周 | 任务 | 风险 | 回滚方案 |
|----|------|------|---------|
| Week 1 | 新增 WorldState 类，与现有 session_data 并行运行 | 低 | 不启用即可回滚 |
| Week 2 | 迁移权重引擎，保留旧接口作为 fallback | 中 | 切换回旧权重计算 |
| Week 3 | 新增 Karma + 张力，现有事件数据零改动 | 低 | 新字段默认值=无影响 |
| Week 4 | 逐步迁移114个事件到新结构（分批） | 中 | 每批独立测试 |
| Week 5 | 删除旧接口，全面切换 | 中 | 回退上一版本 |

### 12.2 兼容性保证

```
Phase 02 期间：
├── 旧事件格式 → 完全兼容，零改动
├── 新事件格式 → 使用扩展字段
├── 权重引擎 → 新旧混合模式（新事件用新引擎，旧事件用旧引擎）
└── SessionData → 新增字段均有默认值，不影响旧存档
```

---

## 十三、平衡参数表

| 变量 | 默认值 | 最小值 | 最大值 | 说明 |
|------|--------|--------|--------|------|
| events_per_year | 1~3 | 1 | 5 | 每年触发事件数范围 [待测试] |
| weight_threshold | 3.0 | 1.0 | 5.0 | 超过此权重的事件保证触发 [待测试] |
| freshness_decay | 0.3 | 0.1 | 0.5 | 近期事件的权重衰减系数 [待测试] |
| karma_range | -100~100 | -200 | 200 | Karma 的上下限 [待测试] |
| tension_pressure_max | 1.0 | 0.5 | 1.5 | 张力压力值上限 [待测试] |
| rarity_legendary | 0.003 | 0.001 | 0.01 | 传说级事件触发率 [待测试] |
| karma_good_multiplier | 0.3 | 0.1 | 0.5 | 正面Karma权重修正系数 [待测试] |
| karma_bad_multiplier | 0.5 | 0.3 | 0.8 | 负面Karma权重修正系数 [待测试] |
| npc_affection_high | 80 | 60 | 95 | 高好感阈值 [待测试] |
| npc_affection_low | 20 | 5 | 40 | 低好感阈值 [待测试] |

---

## 十四、架构决策记录

| ID | 决策 | 理由 |
|----|------|------|
| **D-201** | WorldState 新增字段，不删除旧字段 | 保证向后兼容，渐进迁移 |
| **D-202** | Karma 采用线性修正而非非线性曲线 | 简单可预测，易于调参 |
| **D-203** | 事件新增字段采用可选设计 | 不破坏现有114个事件 |
| **D-204** | NPC 人格使用独立字段而非引用玩家属性 | NPC 是独立行为主体 |
| **D-205** | 张力系统使用独立数组而非嵌套字典 | 多线并发，数组更易管理 |
| **D-206** | 隐性属性仅上帝模式可见 | 保持因果报应的叙事张力 |
| **D-207** | world_changes 作为统一后果接口 | 替代零散字段，降低维护成本 |

---

## 十五、Phase 02 实施拆分

| Phase | 名称 | 核心交付物 | 文件变更 | 预估工作量 |
|-------|------|-----------|---------|-----------|
| **02-01** | 数据模型重构 | WorldState/TensionData/NPCData 新结构 | session_data.gd, npc_data.gd, 新增3个Bean | 2天 |
| **02-02** | 权重引擎重构 | 新的 _calculate_event_weight | event_system.gd | 1天 |
| **02-03** | Karma 引擎 | karma 字段 + 权重修正 + 事件 karma_cost | option_data.gd, event_system.gd | 1天 |
| **02-04** | 张力系统 | Tension 管理 + UI + 到期检定 | session_data.gd, event_system.gd, event_ui.gd | 2天 |
| **02-05** | NPC 人格深度 | personality + 关系驱动事件 | npc_data.gd, event_system.gd | 2天 |
| **02-06** | 事件数据迁移 | 现有114事件迁移到新结构 | events.json（纯数据） | 1天 |

---

## 十六、测试策略

### 16.1 单元测试

| 测试用例 | 输入 | 预期输出 |
|---------|------|---------|
| Karma权重修正 | karma=+100, positive_event | weight ×1.3 |
| Karma权重修正 | karma=-100, negative_event | weight ×1.5 |
| 人格权重修正 | willpower=20, temptation_event | weight ×1.4 |
| NPC权重修正 | npc.affection=90, related_event | weight ×1.3 |
| 张力权重修正 | tension.pressure=0.8, career_event | weight ×1.8 |
| 新鲜度修正 | event_in_recent_events | weight ×0.3 |
| 张力到期 | remaining=0 | 触发resolution_event |

### 16.2 集成测试

| 场景 | 操作步骤 | 验证点 |
|------|---------|--------|
| Karma因果循环 | 连续做善举→Karma>50 | 正面事件权重提升 |
| 张力到期检定 | 创建张力→推进到0 | 到期事件触发 |
| NPC遗产继承 | NPC死亡+高trust | 获得遗产+事件触发 |
| 稀有事件触发 | 推进1000年 | 至少1个rare事件触发 |
