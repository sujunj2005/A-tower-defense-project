"""
事件系统 v2.0 迁移脚本：为所有114个事件自动添加 v2 字段
规则基于事件ID关键词匹配 + 阶段/年龄特征
"""
import json
import os
import shutil
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INPUT_PATH = os.path.join(BASE_DIR, "data", "events.json")
BACKUP_PATH = os.path.join(BASE_DIR, "data", "events.json.bak.%s" % datetime.now().strftime("%Y%m%d_%H%M%S"))

# ── 分类规则 ──
# 按 event_id 关键词匹配确定事件类型

RULES = {
    # 考试/学业事件
    "exam": {
        "keywords": ["zhongkao", "gaokao", "kaoyan", "master_or_work", "math_contest", "studying"],
        "karma_type": "positive",
        "rarity": "common",
        "tension_category": "exam",
        "tension_duration": 3,
        "event_weight": 1.2,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 职业/工作事件
    "career": {
        "keywords": ["first_job", "career_breakthrough", "career_switch", "workplace", "job_interview",
                     "job_offer", "side_hustle", "friend_business", "work", "job", "promotion",
                     "overtime", "programmer", "teacher_cert"],
        "karma_type": "neutral",
        "rarity": "common",
        "tension_category": "career",
        "tension_duration": 4,
        "event_weight": 1.0,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 恋爱/婚姻事件
    "love": {
        "keywords": ["college_love", "first_love", "meet_spouse", "proposal", "wedding",
                     "marriage_pressure", "family_wedding", "date", "love"],
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "",
        "tension_duration": 0,
        "event_weight": 1.1,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 家庭事件
    "family": {
        "keywords": ["family_crisis", "family_conflict", "family_support", "family_together",
                     "family_feud", "father_back", "father_sick", "mother_nag", "mother_visit",
                     "first_child_birth", "child_education", "child_rebellion",
                     "elderly_care", "grandchild", "family_member_sick", "parent_aging",
                     "inheritance", "parent_death", "spouse_conflict", "spouse", "divorce",
                     "family_weekend", "family_travel", "family_dinner"],
        "karma_type": "neutral",
        "rarity": "common",
        "tension_category": "family",
        "tension_duration": 4,
        "event_weight": 1.0,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 童年/青少年成长事件
    "growth": {
        "keywords": ["kindergarten_show", "hobby_class", "peer_conflict", "puberty_rebellion",
                     "pet_companion", "hobby", "art"],
        "karma_type": "neutral",
        "rarity": "common",
        "tension_category": "",
        "tension_duration": 0,
        "event_weight": 1.0,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 冲突/负面事件
    "conflict": {
        "keywords": ["friend_betrayal", "friend_fight", "bully", "crime", "steal", "arrest",
                     "prison", "neighbor_conflict", "fight", "duel", "revenge"],
        "karma_type": "negative",
        "rarity": "uncommon",
        "tension_category": "crime",
        "tension_duration": 4,
        "event_weight": 0.8,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 经济/投资事件
    "finance": {
        "keywords": ["home_purchase", "friend_loan", "invest", "stock", "lottery", "gambling",
                     "rent_house", "debt", "bankrupt", "rich"],
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 3,
        "event_weight": 1.0,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 健康事件
    "health": {
        "keywords": ["health_check", "sick", "hospital", "disease", "doctor", "illness",
                     "mental_health", "depression", "anxiety", "exercise", "sport", "fitness",
                     "yoga", "meditation"],
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "health",
        "tension_duration": 3,
        "event_weight": 1.0,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
    # 社交/朋友事件
    "social": {
        "keywords": ["friend_wedding", "friend_invite", "friend_favor", "friend_party",
                     "party", "social", "reunion", "classmate", "friend"],
        "karma_type": "neutral",
        "rarity": "common",
        "tension_category": "",
        "tension_duration": 0,
        "event_weight": 1.0,
        "personality_checks": {},
        "related_npcs": [],
        "trait_boosts": {},
    },
}

# ── 按事件ID补充精细规则 ──
# 覆写/补充特定事件的具体规则
EVENT_OVERRIDES = {
    "event_kindergarten_show": {
        "karma_type": "positive",
        "rarity": "common",
        "personality_checks": {"craziness": "low"},
    },
    "event_math_contest": {
        "karma_type": "positive",
        "tension_category": "exam",
        "tension_duration": 2,
        "personality_checks": {"discipline": "high"},
        "trait_boosts": {"little_genius": 1.3},
    },
    "event_hobby_class": {
        "karma_type": "positive",
        "personality_checks": {"willpower": "high"},
    },
    "event_peer_conflict": {
        "karma_type": "negative",
        "related_npcs": [],
        "tension_category": "",
        "tension_duration": 0,
        "personality_checks": {"craziness": "high"},
    },
    "event_family_crisis": {
        "karma_type": "negative",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "family",
        "tension_duration": 3,
    },
    "event_father_back": {
        "karma_type": "positive",
        "related_npcs": ["npc_father"],
        "tension_category": "family",
        "tension_duration": 2,
    },
    "event_mother_nag": {
        "karma_type": "negative",
        "related_npcs": ["npc_mother"],
        "tension_category": "family",
        "tension_duration": 2,
        "personality_checks": {"willpower": "low"},
    },
    "event_zhongkao": {
        "karma_type": "positive",
        "rarity": "common",
        "tension_category": "exam",
        "tension_duration": 3,
        "personality_checks": {"discipline": "high", "willpower": "high"},
        "trait_boosts": {"hardworking": 1.2},
    },
    "event_gaokao_choice": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "exam",
        "tension_duration": 3,
        "personality_checks": {"discipline": "high", "willpower": "high"},
        "event_weight": 1.5,
    },
    "event_college_love": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "related_npcs": ["npc_spouse"],
        "tension_category": "",
        "tension_duration": 0,
        "personality_checks": {"craziness": "high"},
    },
    "event_master_or_work": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "exam",
        "tension_duration": 3,
        "personality_checks": {"discipline": "high"},
        "event_weight": 1.3,
    },
    "event_first_job": {
        "karma_type": "positive",
        "tension_category": "career",
        "tension_duration": 3,
        "event_weight": 1.2,
    },
    "event_rent_house": {
        "karma_type": "neutral",
        "tension_category": "finance",
        "tension_duration": 3,
        "rarity": "common",
    },
    "event_workplace_newbie": {
        "karma_type": "neutral",
        "tension_category": "career",
        "tension_duration": 2,
        "personality_checks": {"willpower": "low"},
    },
    "event_marriage_pressure": {
        "karma_type": "negative",
        "related_npcs": ["npc_mother"],
        "tension_category": "family",
        "tension_duration": 3,
        "personality_checks": {"willpower": "low"},
    },
    "event_career_breakthrough": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "career",
        "tension_duration": 4,
        "personality_checks": {"discipline": "high"},
        "event_weight": 1.2,
    },
    "event_friend_wedding": {
        "karma_type": "positive",
        "rarity": "common",
        "tension_category": "",
        "tension_duration": 0,
    },
    "event_side_hustle": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 2,
        "personality_checks": {"craziness": "high"},
    },
    "event_career_switch": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "career",
        "tension_duration": 3,
        "personality_checks": {"craziness": "high", "willpower": "high"},
    },
    "event_home_purchase": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 3,
        "event_weight": 1.2,
    },
    "event_pet_companion": {
        "karma_type": "positive",
        "rarity": "common",
        "tension_category": "",
        "tension_duration": 0,
    },
    "event_puberty_rebellion": {
        "karma_type": "negative",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "family",
        "tension_duration": 2,
        "personality_checks": {"craziness": "high"},
    },
    "event_first_love": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "",
        "tension_duration": 0,
        "personality_checks": {"craziness": "high"},
    },
    "event_father_sick": {
        "karma_type": "negative",
        "related_npcs": ["npc_father"],
        "tension_category": "health",
        "tension_duration": 3,
    },
    "event_mother_visit": {
        "karma_type": "positive",
        "related_npcs": ["npc_mother"],
        "tension_category": "family",
        "tension_duration": 2,
    },
    "event_meet_spouse": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "related_npcs": ["npc_spouse"],
        "tension_category": "",
        "tension_duration": 0,
    },
    "event_proposal": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "related_npcs": ["npc_spouse"],
        "tension_category": "family",
        "tension_duration": 1,
    },
    "event_wedding": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "related_npcs": ["npc_spouse"],
        "tension_category": "",
        "tension_duration": 0,
    },
    "event_first_child_birth": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "related_npcs": ["npc_spouse", "npc_first_child"],
        "tension_category": "family",
        "tension_duration": 18,
    },
    "event_family_conflict": {
        "karma_type": "negative",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "family",
        "tension_duration": 3,
    },
    "event_family_support": {
        "karma_type": "positive",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "family",
        "tension_duration": 2,
    },
    "event_friend_invite": {
        "karma_type": "positive",
        "rarity": "common",
    },
    "event_friend_favor": {
        "karma_type": "positive",
        "rarity": "common",
    },
    "event_friend_betrayal": {
        "karma_type": "negative",
        "rarity": "uncommon",
        "tension_category": "",
        "tension_duration": 0,
        "personality_checks": {"craziness": "high"},
    },
    "event_family_together": {
        "karma_type": "positive",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "family",
        "tension_duration": 1,
    },
    "event_family_feud": {
        "karma_type": "negative",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "family",
        "tension_duration": 3,
    },
    "event_family_wedding": {
        "karma_type": "positive",
        "rarity": "common",
        "tension_category": "family",
        "tension_duration": 1,
    },
    "event_friend_business": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 3,
    },
    "event_friend_loan": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 2,
    },
    "event_job_interview": {
        "karma_type": "positive",
        "tension_category": "career",
        "tension_duration": 2,
    },
    "event_job_offer": {
        "karma_type": "positive",
        "tension_category": "career",
        "tension_duration": 2,
    },
    # ── 中年事件 ──
    "event_house_loan": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 10,
    },
    "event_children_education": {
        "karma_type": "positive",
        "related_npcs": ["npc_first_child"],
        "tension_category": "family",
        "tension_duration": 6,
    },
    "event_parents_care": {
        "karma_type": "positive",
        "related_npcs": ["npc_father", "npc_mother"],
        "tension_category": "health",
        "tension_duration": 5,
        "personality_checks": {"willpower": "high"},
    },
    "event_career_promotion": {
        "karma_type": "positive",
        "tension_category": "career",
        "tension_duration": 3,
        "personality_checks": {"discipline": "high"},
    },
    "event_health_warning": {
        "karma_type": "negative",
        "tension_category": "health",
        "tension_duration": 3,
    },
    "event_midlife_crisis": {
        "karma_type": "negative",
        "rarity": "uncommon",
        "tension_category": "family",
        "tension_duration": 4,
        "personality_checks": {"craziness": "high"},
    },
    "event_spouse_conflict": {
        "karma_type": "negative",
        "related_npcs": ["npc_spouse"],
        "tension_category": "family",
        "tension_duration": 3,
    },
    "event_overtime_burnout": {
        "karma_type": "negative",
        "tension_category": "career",
        "tension_duration": 2,
    },
    "event_investment": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 3,
    },
    # ── 老年事件 ──
    "event_retirement_plan": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "finance",
        "tension_duration": 5,
    },
    "event_chronic_illness": {
        "karma_type": "negative",
        "rarity": "uncommon",
        "tension_category": "health",
        "tension_duration": 8,
    },
    "event_family_reunion": {
        "karma_type": "positive",
        "related_npcs": ["npc_spouse", "npc_first_child", "npc_second_child"],
        "rarity": "uncommon",
    },
    "event_old_friend": {
        "karma_type": "positive",
        "rarity": "uncommon",
    },
    "event_legacy": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "event_weight": 1.5,
    },
    "event_elderly_alone": {
        "karma_type": "negative",
        "rarity": "uncommon",
        "tension_category": "health",
        "tension_duration": 5,
    },
    "event_death_of_parent": {
        "karma_type": "negative",
        "rarity": "rare",
        "related_npcs": ["npc_father", "npc_mother"],
    },
    "event_inheritance": {
        "karma_type": "neutral",
        "rarity": "uncommon",
        "tension_category": "family",
        "tension_duration": 3,
    },
    "event_volunteer": {
        "karma_type": "positive",
        "rarity": "common",
    },
    "event_travel": {
        "karma_type": "positive",
        "rarity": "uncommon",
    },
    "event_second_child": {
        "karma_type": "positive",
        "related_npcs": ["npc_spouse"],
        "tension_category": "family",
        "tension_duration": 18,
    },
    "event_child_rebellion": {
        "karma_type": "negative",
        "related_npcs": ["npc_first_child"],
        "tension_category": "family",
        "tension_duration": 4,
        "personality_checks": {"craziness": "high"},
    },
    "event_grandchild_birth": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "related_npcs": ["npc_first_child", "npc_grandchild"],
    },
    "event_profession_milestone": {
        "karma_type": "positive",
        "rarity": "uncommon",
        "tension_category": "career",
        "tension_duration": 3,
    },
    "event_lottery": {
        "karma_type": "neutral",
        "rarity": "rare",
        "tension_category": "finance",
        "tension_duration": 1,
    },
}

# ── 选项级 karma_cost 规则 ──
OPTION_KARMA_RULES = {
    # 善举选项
    "donate": 10, "help": 8, "charity": 15, "save": 20,
    "protect": 10, "support": 5, "care": 8, "visit": 5,
    # 恶行选项
    "steal": -20, "betray": -30, "cheat": -15, "fight": -10,
    "bully": -20, "revenge": -25, "abandon": -40, "divorce": -25,
    "lie": -10, "gambling": -15, "corrupt": -30,
}


def classify_event(event_id, stage, ages):
    """根据 event_id 关键词匹配返回事件类型"""
    event_lower = event_id.lower()
    best_type = "growth"
    best_priority = 999

    for rule_type, rule in RULES.items():
        for kw in rule["keywords"]:
            if kw in event_lower:
                priority = len(kw)
                if priority > best_priority:
                    best_priority = priority
                    best_type = rule_type
    return best_type


def compute_option_karma(option):
    """基于选项的 rewards 计算 karma_cost"""
    karma = 0
    rewards = option.get("rewards", [])
    for r in rewards:
        rtype = r.get("type", "")
        rid = r.get("id", "").lower()
        if rtype == "trait":
            for kw, val in OPTION_KARMA_RULES.items():
                if kw in rid:
                    karma += val
                    break
        if rtype == "gold":
            gold_val = r.get("value", 0)
            if gold_val > 0:
                karma += min(gold_val // 10, 5)
    text = option.get("text", "").lower()
    for kw, val in OPTION_KARMA_RULES.items():
        if kw in text:
            karma += val
            break
    return karma


def compute_world_changes(option, stage):
    """从 rewards/cost 转换为 world_changes"""
    changes = {}
    rewards = option.get("rewards", [])
    for r in rewards:
        rtype = r.get("type", "")
        if rtype == "attribute":
            attr_id = r.get("attribute", r.get("id", ""))
            val = r.get("value", r.get("count", 0))
            if attr_id in ("intelligence", "courage", "health", "charm"):
                v2_key = attr_id
                if attr_id == "charm":
                    v2_key = "appearance"
                changes[v2_key] = changes.get(v2_key, 0) + val
    cost = option.get("cost", {})
    for ckey, cval in cost.items():
        if ckey == "gold":
            if "gold" in changes:
                changes["gold"] += cval
            else:
                changes["gold"] = cval
        if ckey == "health":
            if "health" in changes:
                changes["health"] += cval
            else:
                changes["health"] = cval
    return changes


def migrate_event(event, force=False):
    """为单个事件添加 v2 字段"""
    event_id = event.get("event_id", "")
    stage = event.get("stage", "")
    ages = event.get("ages", [])

    # 跳过已迁移的事件
    if not force and event.get("karma_type", "") != "":
        return event

    # 分类
    etype = classify_event(event_id, stage, ages)
    rule = RULES.get(etype, RULES["growth"])

    # 应用默认规则
    event["karma_type"] = rule["karma_type"]
    event["rarity"] = rule["rarity"]
    event["tension_category"] = rule["tension_category"]
    event["tension_duration"] = rule["tension_duration"]
    event["event_weight"] = rule["event_weight"]
    event["personality_checks"] = dict(rule["personality_checks"])
    event["related_npcs"] = list(rule["related_npcs"])
    event["trait_boosts"] = dict(rule["trait_boosts"])

    # 精细覆写
    if event_id in EVENT_OVERRIDES:
        for k, v in EVENT_OVERRIDES[event_id].items():
            event[k] = v

    # 额外规则：致命事件调整
    if event.get("is_deadly", False):
        event["rarity"] = "rare"
        event["event_weight"] = event.get("event_weight", 1.0) * 0.3

    # 老年阶段事件默认为 uncommon
    if stage == "old_age" and event.get("rarity") == "common":
        event["rarity"] = "uncommon"

    return event


def migrate_options(options, event_stage, event_karma_type):
    """为每个选项添加 v2 字段（karma_cost + world_changes）"""
    for opt in options:
        if not isinstance(opt, dict):
            continue

        # karma_cost
        if "karma_cost" not in opt:
            base_karma = compute_option_karma(opt)
            if base_karma == 0:
                if event_karma_type == "positive":
                    base_karma = 5
                elif event_karma_type == "negative":
                    base_karma = -5
            opt["karma_cost"] = base_karma

        # world_changes
        if "world_changes" not in opt:
            opt["world_changes"] = compute_world_changes(opt, event_stage)

    return options


def main():
    import sys
    force = "--force" in sys.argv

    # 读取
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    # 备份
    shutil.copy2(INPUT_PATH, BACKUP_PATH)
    print(f"✓ 备份已创建: {BACKUP_PATH}")

    events = data.get("events", [])
    print(f"事件总数: {len(events)}")

    # 迁移
    migrated_count = 0
    skipped_count = 0
    for event in events:
        event_id = event.get("event_id", "")
        stage = event.get("stage", "")
        ages = event.get("ages", [])

        if not force and event.get("karma_type", "") != "":
            skipped_count += 1
            continue

        migrate_event(event, force=force)
        event["options"] = migrate_options(
            event.get("options", []),
            stage,
            event.get("karma_type", "neutral")
        )
        migrated_count += 1

    # 统计报告
    print(f"\n✓ 迁移完成: {migrated_count} 个事件已处理, {skipped_count} 个跳过")

    rarity_stats = {}
    karma_stats = {}
    tension_stats = {}
    for event in events:
        r = event.get("rarity", "common")
        rarity_stats[r] = rarity_stats.get(r, 0) + 1
        k = event.get("karma_type", "neutral")
        karma_stats[k] = karma_stats.get(k, 0) + 1
        t = event.get("tension_category", "")
        if t:
            tension_stats[t] = tension_stats.get(t, 0) + 1

    print(f"\n稀有度分布: {json.dumps(rarity_stats, ensure_ascii=False)}")
    print(f"业力类型分布: {json.dumps(karma_stats, ensure_ascii=False)}")
    print(f"张力类型分布: {json.dumps(tension_stats, ensure_ascii=False)}")

    # 写入
    with open(INPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent="\t")
    print(f"\n✓ 已写入: {INPUT_PATH}")


if __name__ == "__main__":
    main()
