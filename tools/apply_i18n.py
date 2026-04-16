import json
import csv
import os
import re
import copy

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(PROJECT_ROOT, "data")
CSV_PATH = os.path.join(PROJECT_ROOT, "locale", "translations.csv")

STAGE_ZH_TO_ID = {
    "童年": "childhood",
    "青年": "youth",
    "中年": "middle_age",
    "老年": "old_age",
}

ENUM_MAPS = {
    "tower_type": {
        "学科塔": "academic",
        "技能塔": "skill",
        "进阶": "advanced",
        "特殊": "special",
    },
    "tier_tower": {
        "基础": "basic",
        "进阶": "advanced",
        "大师": "master",
        "废墟": "ruin",
    },
    "tier_enemy": {
        "基础": "basic",
        "精英": "elite",
        "BOSS": "boss",
        "终极BOSS": "ultimate_boss",
    },
    "enemy_type": {
        "学业压力": "academic",
        "经济压力": "economic",
        "社会压力": "social",
        "健康威胁": "health",
        "心理压力": "mental",
        "BOSS": "boss",
    },
}

ENUM_I18N_KEYS = {
    "TOWER_TYPE_ACADEMIC": ("学科塔", "Academic Tower"),
    "TOWER_TYPE_SKILL": ("技能塔", "Skill Tower"),
    "TOWER_TYPE_ADVANCED": ("进阶", "Advanced"),
    "TOWER_TYPE_SPECIAL": ("特殊", "Special"),
    "TIER_BASIC": ("基础", "Basic"),
    "TIER_ADVANCED": ("高级", "Advanced"),
    "TIER_MASTER": ("大师", "Master"),
    "TIER_RUIN": ("废墟", "Ruin"),
    "TIER_ELITE": ("精英", "Elite"),
    "TIER_BOSS": ("BOSS", "BOSS"),
    "TIER_ULTIMATE_BOSS": ("终极BOSS", "Ultimate BOSS"),
    "ENEMY_TYPE_ACADEMIC": ("学业压力", "Academic Pressure"),
    "ENEMY_TYPE_ECONOMIC": ("经济压力", "Economic Pressure"),
    "ENEMY_TYPE_SOCIAL": ("社会压力", "Social Pressure"),
    "ENEMY_TYPE_HEALTH": ("健康威胁", "Health Threat"),
    "ENEMY_TYPE_MENTAL": ("心理压力", "Mental Pressure"),
    "ENEMY_TYPE_BOSS": ("BOSS", "BOSS"),
}

SE_I18N_KEYS = {
    "SE_SLOW_NAME": ("减速", "Slow"),
    "SE_SLOW_DESC": ("降低敌人移动速度", "Reduces enemy movement speed"),
    "SE_DOT_NAME": ("持续伤害", "Damage Over Time"),
    "SE_DOT_DESC": ("对敌人造成持续伤害", "Deals ongoing damage to enemies"),
    "SE_AOE_NAME": ("范围攻击", "Area Attack"),
    "SE_AOE_DESC": ("对范围内所有敌人造成伤害", "Deals damage to all enemies in range"),
    "SE_CRIT_NAME": ("暴击", "Critical Hit"),
    "SE_CRIT_DESC": ("有概率造成双倍伤害", "Chance to deal double damage"),
    "SE_PIERCE_NAME": ("穿透", "Pierce"),
    "SE_PIERCE_DESC": ("弹丸可穿透多个敌人", "Projectiles can pierce through multiple enemies"),
    "SE_CULTURAL_SUPPRESSION_NAME": ("文化压制", "Cultural Suppression"),
    "SE_CULTURAL_SUPPRESSION_DESC": ("对特定标签敌人造成额外伤害", "Deals bonus damage to enemies with specific tags"),
    "SE_SLOW_AURA_NAME": ("减速光环", "Slow Aura"),
    "SE_SLOW_AURA_DESC": ("减速范围内所有敌人", "Slows all enemies within range"),
    "SE_SINGLE_CONTROL_NAME": ("单体控制", "Single Target Control"),
    "SE_SINGLE_CONTROL_DESC": ("有概率眩晕敌人", "Chance to stun an enemy"),
    "SE_SUMMON_NAME": ("召唤", "Summon"),
    "SE_SUMMON_DESC": ("召唤临时辅助防御塔", "Summons a temporary helper tower"),
    "SE_GOLD_BONUS_NAME": ("金币加成", "Gold Bonus"),
    "SE_GOLD_BONUS_DESC": ("击杀敌人获得额外金币", "Extra gold per enemy kill"),
    "SE_CONFUSION_NAME": ("混乱", "Confusion"),
    "SE_CONFUSION_DESC": ("使敌人反向移动", "Causes enemies to move backwards"),
    "SE_ARMOR_BREAK_NAME": ("破甲", "Armor Break"),
    "SE_ARMOR_BREAK_DESC": ("降低敌人护甲", "Reduces enemy armor"),
    "SE_DEBUFF_NAME": ("削弱", "Debuff"),
    "SE_DEBUFF_DESC": ("降低敌人属性", "Weakens enemy stats"),
    "SE_BUFF_AURA_NAME": ("增益光环", "Buff Aura"),
    "SE_BUFF_AURA_DESC": ("提升范围内友方防御塔属性", "Boosts nearby tower stats"),
    "SE_BURN_NAME": ("灼烧", "Burn"),
    "SE_BURN_DESC": ("点燃敌人造成持续伤害", "Sets enemies ablaze for ongoing damage"),
    "SE_SILENCE_NAME": ("沉默", "Silence"),
    "SE_SILENCE_DESC": ("使敌人无法使用特殊能力", "Prevents enemies from using special abilities"),
}


def is_chinese(text: str) -> bool:
    if not text or not isinstance(text, str):
        return False
    return any('\u4e00' <= c <= '\u9fff' for c in text)


def strip_prefix(s: str, prefix: str) -> str:
    if s.startswith(prefix):
        return s[len(prefix):]
    return s


def to_key_part(s: str) -> str:
    return re.sub(r'[^a-zA-Z0-9_]', '_', s).upper().strip('_')


def load_json(filename: str) -> dict:
    path = os.path.join(DATA_DIR, filename)
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(filename: str, data: dict):
    path = os.path.join(DATA_DIR, filename)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent='\t')


def load_existing_csv() -> set:
    keys = set()
    if not os.path.exists(CSV_PATH):
        return keys
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            keys.add(row.get('keys', ''))
    return keys


def extract_keys() -> list:
    rows = []

    # === towers.json ===
    data = load_json("towers.json")
    for tower in data.get("towers", []):
        tid = tower.get("tower_id", "")
        part = to_key_part(strip_prefix(tid, "tower_"))
        if is_chinese(tower.get("tower_name", "")):
            rows.append((f"TOWER_{part}_NAME", tower["tower_name"], ""))
        if is_chinese(tower.get("tower_type", "")):
            pass  # handled by enum
        if is_chinese(tower.get("tier", "")):
            pass  # handled by enum

    # === enemies.json ===
    data = load_json("enemies.json")
    for enemy in data.get("enemies", []):
        eid = enemy.get("enemy_id", "")
        part = to_key_part(strip_prefix(eid, "enemy_"))
        if is_chinese(enemy.get("enemy_name", "")):
            rows.append((f"ENEMY_{part}_NAME", enemy["enemy_name"], ""))

    # === events.json ===
    data = load_json("events.json")
    for event in data.get("events", []):
        evid = event.get("event_id", "")
        part = to_key_part(strip_prefix(evid, "event_"))
        if is_chinese(event.get("event_name", "")):
            rows.append((f"EVENT_{part}_NAME", event["event_name"], ""))
        if is_chinese(event.get("description", "")):
            rows.append((f"EVENT_{part}_DESC", event["description"], ""))

    # === options.json ===
    data = load_json("options.json")
    for opt in data.get("options", []):
        evid = opt.get("event_id", "")
        oid = opt.get("option_id", "")
        ev_part = to_key_part(strip_prefix(evid, "event_"))
        o_part = to_key_part(oid)
        if is_chinese(opt.get("text", "")):
            rows.append((f"OPTION_{ev_part}_{o_part}_TEXT", opt["text"], ""))

    # === stages.json ===
    data = load_json("stages.json")
    for key, stage in data.get("stages", {}).items():
        part = to_key_part(key)
        if is_chinese(stage.get("stage_name", "")):
            rows.append((f"STAGE_{part}_NAME", stage["stage_name"], ""))
        if is_chinese(stage.get("description", "")):
            rows.append((f"STAGE_{part}_DESC", stage["description"], ""))

    # === traits.json ===
    data = load_json("traits.json")
    for trait in data.get("traits", []):
        tid = trait.get("trait_id", "")
        part = to_key_part(tid)
        if is_chinese(trait.get("name", "")):
            rows.append((f"TRAIT_{part}_NAME", trait["name"], ""))
        if is_chinese(trait.get("description", "")):
            rows.append((f"TRAIT_{part}_DESC", trait["description"], ""))

    # === endings.json ===
    data = load_json("endings.json")
    for ending in data.get("endings", []):
        eid = ending.get("ending_id", "")
        part = to_key_part(eid)
        if is_chinese(ending.get("ending_name", "")):
            rows.append((f"ENDING_{part}_NAME", ending["ending_name"], ""))
        if is_chinese(ending.get("description", "")):
            rows.append((f"ENDING_{part}_DESC", ending["description"], ""))
        if is_chinese(ending.get("ending_phrase", "")):
            rows.append((f"ENDING_{part}_PHRASE", ending["ending_phrase"], ""))

    # === achievements.json ===
    data = load_json("achievements.json")
    for ach in data.get("achievements", []):
        aid = ach.get("achievement_id", "")
        part = to_key_part(aid)
        if is_chinese(ach.get("achievement_name", "")):
            rows.append((f"ACHIEVEMENT_{part}_NAME", ach["achievement_name"], ""))
        if is_chinese(ach.get("description", "")):
            rows.append((f"ACHIEVEMENT_{part}_DESC", ach["description"], ""))

    # === attributes.json ===
    data = load_json("attributes.json")
    for key, attr in data.get("attributes", {}).items():
        part = to_key_part(key)
        if is_chinese(attr.get("display_name", "")):
            rows.append((f"ATTR_{part}_DISPLAY_NAME", attr["display_name"], ""))

    # === family_backgrounds.json ===
    data = load_json("family_backgrounds.json")
    for fam in data.get("family_backgrounds", []):
        fid = fam.get("family_id", "")
        part = to_key_part(strip_prefix(fid, "family_"))
        if is_chinese(fam.get("family_name", "")):
            rows.append((f"FAMILY_{part}_NAME", fam["family_name"], ""))
        if is_chinese(fam.get("description", "")):
            rows.append((f"FAMILY_{part}_DESC", fam["description"], ""))
        for i, trait in enumerate(fam.get("traits", [])):
            if is_chinese(trait.get("text", "")):
                rows.append((f"FAMILY_{part}_TRAIT_{i}_TEXT", trait["text"], ""))

    # === eras.json ===
    data = load_json("eras.json")
    for key, era in data.get("eras", {}).items():
        part = to_key_part(key)
        if is_chinese(era.get("era_name", "")):
            rows.append((f"ERA_{part}_NAME", era["era_name"], ""))
        if is_chinese(era.get("time_period", "")):
            rows.append((f"ERA_{part}_TIME_PERIOD", era["time_period"], ""))

    # === special_effects.json ===
    data = load_json("special_effects.json")
    for effect in data.get("special_effects", []):
        eid = effect.get("effect_id", "")
        part = to_key_part(eid)
        if effect.get("effect_name", "").startswith("SE_"):
            pass  # already a translation key
        elif is_chinese(effect.get("effect_name", "")):
            rows.append((f"SE_{part}_NAME", effect["effect_name"], ""))
        if effect.get("description", "").startswith("SE_"):
            pass
        elif is_chinese(effect.get("description", "")):
            rows.append((f"SE_{part}_DESC", effect["description"], ""))

    return rows


def update_csv(new_rows: list):
    existing_keys = load_existing_csv()
    rows_to_add = []
    for key, zh, en in new_rows:
        if key not in existing_keys:
            rows_to_add.append((key, zh, en))
            existing_keys.add(key)

    # Add enum keys
    for key, (zh, en) in ENUM_I18N_KEYS.items():
        if key not in existing_keys:
            rows_to_add.append((key, zh, en))
            existing_keys.add(key)

    # Add SE keys
    for key, (zh, en) in SE_I18N_KEYS.items():
        if key not in existing_keys:
            rows_to_add.append((key, zh, en))
            existing_keys.add(key)

    with open(CSV_PATH, 'a', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        for key, zh, en in rows_to_add:
            writer.writerow([key, zh, en])

    print(f"Added {len(rows_to_add)} new keys to translations.csv")


def build_zh_to_key_map() -> dict:
    mapping = {}
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            zh = row.get('zh', '')
            key = row.get('keys', '')
            if zh and key:
                mapping[zh] = key
    return mapping


def apply_i18n_to_json():
    zh_map = build_zh_to_key_map()

    # === towers.json ===
    data = load_json("towers.json")
    for tower in data.get("towers", []):
        if is_chinese(tower.get("tower_name", "")):
            tower["tower_name"] = zh_map.get(tower["tower_name"], tower["tower_name"])
        if is_chinese(tower.get("tower_type", "")):
            tower["tower_type"] = ENUM_MAPS["tower_type"].get(tower["tower_type"], tower["tower_type"])
        if is_chinese(tower.get("tier", "")):
            tower["tier"] = ENUM_MAPS["tier_tower"].get(tower["tier"], tower["tier"])

        # Restructure special_effect
        se = tower.get("special_effect", {})
        if se:
            new_se = convert_special_effect(se, zh_map)
            tower["special_effect"] = new_se
        elif se == {}:
            tower["special_effect"] = {"effect_id": ""}

    save_json("towers.json", data)
    print("Updated towers.json")

    # === enemies.json ===
    data = load_json("enemies.json")
    for enemy in data.get("enemies", []):
        if is_chinese(enemy.get("enemy_name", "")):
            enemy["enemy_name"] = zh_map.get(enemy["enemy_name"], enemy["enemy_name"])
        if is_chinese(enemy.get("enemy_type", "")):
            enemy["enemy_type"] = ENUM_MAPS["enemy_type"].get(enemy["enemy_type"], enemy["enemy_type"])
        if is_chinese(enemy.get("tier", "")):
            enemy["tier"] = ENUM_MAPS["tier_enemy"].get(enemy["tier"], enemy["tier"])
        new_stages = []
        for stage in enemy.get("spawn_stages", []):
            if is_chinese(stage):
                new_stages.append(STAGE_ZH_TO_ID.get(stage, stage))
            else:
                new_stages.append(stage)
        if new_stages:
            enemy["spawn_stages"] = new_stages
    save_json("enemies.json", data)
    print("Updated enemies.json")

    # === events.json ===
    data = load_json("events.json")
    for event in data.get("events", []):
        if is_chinese(event.get("event_name", "")):
            event["event_name"] = zh_map.get(event["event_name"], event["event_name"])
        if is_chinese(event.get("description", "")):
            event["description"] = zh_map.get(event["description"], event["description"])
    save_json("events.json", data)
    print("Updated events.json")

    # === options.json ===
    data = load_json("options.json")
    for opt in data.get("options", []):
        if is_chinese(opt.get("text", "")):
            opt["text"] = zh_map.get(opt["text"], opt["text"])
    save_json("options.json", data)
    print("Updated options.json")

    # === stages.json ===
    data = load_json("stages.json")
    for key, stage in data.get("stages", {}).items():
        if is_chinese(stage.get("stage_name", "")):
            stage["stage_name"] = zh_map.get(stage["stage_name"], stage["stage_name"])
        if is_chinese(stage.get("description", "")):
            stage["description"] = zh_map.get(stage["description"], stage["description"])
    save_json("stages.json", data)
    print("Updated stages.json")

    # === traits.json ===
    data = load_json("traits.json")
    for trait in data.get("traits", []):
        if is_chinese(trait.get("name", "")):
            trait["name"] = zh_map.get(trait["name"], trait["name"])
        if is_chinese(trait.get("description", "")):
            trait["description"] = zh_map.get(trait["description"], trait["description"])
    save_json("traits.json", data)
    print("Updated traits.json")

    # === endings.json ===
    data = load_json("endings.json")
    for ending in data.get("endings", []):
        if is_chinese(ending.get("ending_name", "")):
            ending["ending_name"] = zh_map.get(ending["ending_name"], ending["ending_name"])
        if is_chinese(ending.get("description", "")):
            ending["description"] = zh_map.get(ending["description"], ending["description"])
        if is_chinese(ending.get("ending_phrase", "")):
            ending["ending_phrase"] = zh_map.get(ending["ending_phrase"], ending["ending_phrase"])
    save_json("endings.json", data)
    print("Updated endings.json")

    # === achievements.json ===
    data = load_json("achievements.json")
    for ach in data.get("achievements", []):
        if is_chinese(ach.get("achievement_name", "")):
            ach["achievement_name"] = zh_map.get(ach["achievement_name"], ach["achievement_name"])
        if is_chinese(ach.get("description", "")):
            ach["description"] = zh_map.get(ach["description"], ach["description"])
        # Fix condition.stages Chinese values
        cond = ach.get("condition", {})
        if isinstance(cond, dict):
            stages = cond.get("stages", [])
            if isinstance(stages, list):
                new_stages = []
                for s in stages:
                    if is_chinese(s):
                        new_stages.append(STAGE_ZH_TO_ID.get(s, s))
                    else:
                        new_stages.append(s)
                cond["stages"] = new_stages
    save_json("achievements.json", data)
    print("Updated achievements.json")

    # === attributes.json ===
    data = load_json("attributes.json")
    for key, attr in data.get("attributes", {}).items():
        if is_chinese(attr.get("display_name", "")):
            attr["display_name"] = zh_map.get(attr["display_name"], attr["display_name"])
    save_json("attributes.json", data)
    print("Updated attributes.json")

    # === family_backgrounds.json ===
    data = load_json("family_backgrounds.json")
    for fam in data.get("family_backgrounds", []):
        if is_chinese(fam.get("family_name", "")):
            fam["family_name"] = zh_map.get(fam["family_name"], fam["family_name"])
        if is_chinese(fam.get("description", "")):
            fam["description"] = zh_map.get(fam["description"], fam["description"])
        for trait in fam.get("traits", []):
            if is_chinese(trait.get("text", "")):
                trait["text"] = zh_map.get(trait["text"], trait["text"])
    save_json("family_backgrounds.json", data)
    print("Updated family_backgrounds.json")

    # === eras.json ===
    data = load_json("eras.json")
    for key, era in data.get("eras", {}).items():
        if is_chinese(era.get("era_name", "")):
            era["era_name"] = zh_map.get(era["era_name"], era["era_name"])
        if is_chinese(era.get("time_period", "")):
            era["time_period"] = zh_map.get(era["time_period"], era["time_period"])
    save_json("eras.json", data)
    print("Updated eras.json")


def convert_special_effect(se: dict, zh_map: dict) -> dict:
    if not se:
        return {"effect_id": ""}

    effect_type = se.get("type", "")
    if not effect_type:
        return {"effect_id": ""}

    overrides = {}
    skip_keys = {"type", "extra"}
    for k, v in se.items():
        if k not in skip_keys:
            overrides[k] = v

    result = {
        "effect_id": effect_type,
        "overrides": overrides,
    }

    extra = se.get("extra", {})
    if extra:
        sub_effects = []
        sub_type = extra.get("type", "")
        if sub_type:
            sub_overrides = {}
            for k, v in extra.items():
                if k != "type":
                    sub_overrides[k] = v
            sub_effects.append({
                "effect_id": sub_type,
                "overrides": sub_overrides,
            })
        result["sub_effects"] = sub_effects

    return result


if __name__ == "__main__":
    print("=== Step 1: Extracting i18n keys ===")
    rows = extract_keys()
    print(f"Extracted {len(rows)} translation keys")

    print("\n=== Step 2: Updating translations.csv ===")
    update_csv(rows)

    print("\n=== Step 3: Applying i18n keys to JSON files ===")
    apply_i18n_to_json()

    print("\n=== Step 4: Validating JSON files ===")
    for f in os.listdir(DATA_DIR):
        if f.endswith('.json'):
            try:
                json.load(open(os.path.join(DATA_DIR, f), encoding='utf-8'))
                print(f"  {f}: OK")
            except Exception as e:
                print(f"  {f}: ERROR - {e}")

    print("\nDone!")
