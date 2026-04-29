
"""
事件系统 v2.0 完整增强脚本
目标：升级现有事件 + 新增事件 + 选项深度优化
"""
import json, shutil, csv, os
from datetime import datetime

BASE_DIR = r"E:\Test_MCP\first\TestMCP"
EVENTS_PATH = os.path.join(BASE_DIR, "data", "events.json")
CSV_PATH = os.path.join(BASE_DIR, "locale", "translations.csv")
BACKUP_PATH = EVENTS_PATH.replace(".json", ".bak." + datetime.now().strftime("%Y%m%d_%H%M%S"))

EXISTING_UPGRADES = {
    "event_kindergarten_show": {
        "rarity": "uncommon", "personality_checks": {"craziness": "low"},
        "trait_boosts": {"little_singer": 1.3},
        "opts": {"A":{"karma_cost":8,"world_changes":{"courage":5,"happiness":10}},"B":{"karma_cost":3,"world_changes":{"intelligence":3}},"C":{"karma_cost":5,"world_changes":{"happiness":15,"discipline":-5}}}},
    "event_hobby_class": {
        "rarity": "uncommon", "personality_checks": {"willpower": "high"},
        "tension_category": "exam", "tension_duration": 3,
        "opts": {"A":{"karma_cost":5,"world_changes":{"intelligence":8,"happiness":5}},"B":{"karma_cost":3,"world_changes":{"courage":8,"health":5}},"C":{"karma_cost":-5,"world_changes":{"craziness":10}},"D":{"karma_cost":0,"world_changes":{"discipline":5}}}},
    "event_peer_conflict": {
        "related_npcs": ["npc_father", "npc_mother"],
        "opts": {"A":{"karma_cost":5,"world_changes":{"courage":5,"health":5}},"B":{"karma_cost":-10,"world_changes":{"courage":10}},"C":{"karma_cost":8,"world_changes":{"intelligence":5,"discipline":5}},"D":{"karma_cost":-5,"world_changes":{"happiness":3}}}},
    "event_family_crisis": {
        "rarity": "uncommon", "personality_checks": {"willpower": "low"},
        "opts": {"A":{"karma_cost":10,"world_changes":{"willpower":15,"happiness":-10}},"B":{"karma_cost":-5,"world_changes":{"courage":10,"health":-15}},"C":{"karma_cost":3,"world_changes":{"discipline":8,"happiness":-5}},"D":{"karma_cost":-15,"world_changes":{"craziness":10}}}},
    "event_zhongkao": {
        "rarity": "uncommon", "event_weight": 1.3,
        "trait_boosts": {"hardworking": 1.3, "little_genius": 1.3},
        "opts": {"A":{"karma_cost":5,"world_changes":{"intelligence":10,"willpower":5}},"B":{"karma_cost":3,"world_changes":{"intelligence":5}},"C":{"karma_cost":0,"world_changes":{"intelligence":2}}}},
    "event_college_love": {
        "rarity": "uncommon", "personality_checks": {"craziness": "high"},
        "opts": {"A":{"karma_cost":5,"world_changes":{"happiness":20,"appearance":5}},"B":{"karma_cost":3,"world_changes":{"intelligence":8,"happiness":-5}},"C":{"karma_cost":0,"world_changes":{"intelligence":10,"discipline":5}}}},
    "event_master_or_work": {
        "rarity": "uncommon", "personality_checks": {"discipline": "high", "willpower": "high"}, "event_weight": 1.4,
        "opts": {"A":{"karma_cost":10,"world_changes":{"intelligence":15,"willpower":10}},"B":{"karma_cost":5,"world_changes":{"discipline":5}},"C":{"karma_cost":-8,"world_changes":{"courage":20,"craziness":10}}}},
    "event_first_job": {
        "tension_category": "career", "tension_duration": 3, "personality_checks": {"discipline": "high"},
        "opts": {"A":{"karma_cost":5,"world_changes":{"discipline":10}},"B":{"karma_cost":-5,"world_changes":{"craziness":8}},"C":{"karma_cost":-20,"world_changes":{"craziness":20,"karma":-20}}}},
    "event_workplace_newbie": {
        "rarity": "uncommon", "personality_checks": {"willpower": "low"},
        "opts": {"A":{"karma_cost":8,"world_changes":{"discipline":15,"happiness":-10}},"B":{"karma_cost":-5,"world_changes":{"courage":10}},"C":{"karma_cost":-10,"world_changes":{"craziness":15,"happiness":15}}}},
    "event_career_breakthrough": {
        "rarity": "uncommon", "personality_checks": {"discipline": "high", "willpower": "high"}, "event_weight": 1.3,
        "trait_boosts": {"career_focus": 1.4},
        "opts": {"A":{"karma_cost":8,"world_changes":{"fame":15,"discipline":10}},"B":{"karma_cost":-5,"world_changes":{"fame":10,"craziness":5}},"C":{"karma_cost":15,"world_changes":{"fame":20,"karma":20}}}},
    "event_side_hustle": {
        "rarity": "uncommon", "personality_checks": {"craziness": "high"},
        "opts": {"A":{"karma_cost":5,"world_changes":{"discipline":5}},"B":{"karma_cost":-8,"world_changes":{"craziness":10}},"C":{"karma_cost":-15,"world_changes":{"craziness":20}}}},
    "event_marriage_pressure": {
        "related_npcs": ["npc_mother"], "personality_checks": {"willpower": "low"},
        "opts": {"A":{"karma_cost":3,"world_changes":{"happiness":5,"willpower":5}},"B":{"karma_cost":0,"world_changes":{"happiness":-15,"willpower":-5}},"C":{"karma_cost":-5,"world_changes":{"courage":10,"happiness":-5}}}},
    "event_proposal": {
        "rarity": "uncommon", "related_npcs": ["npc_spouse"],
        "opts": {"A":{"karma_cost":10,"world_changes":{"happiness":30,"gold":-500}},"B":{"karma_cost":5,"world_changes":{"happiness":15}},"C":{"karma_cost":-15,"world_changes":{"happiness":-20,"craziness":5}}}},
    "event_wedding": {
        "rarity": "uncommon", "related_npcs": ["npc_spouse"],
        "opts": {"A":{"karma_cost":10,"world_changes":{"gold":-1000,"happiness":25,"fame":5}},"B":{"karma_cost":5,"world_changes":{"gold":-200,"happiness":15}},"C":{"karma_cost":-5,"world_changes":{"gold":500,"happiness":-10}}}},
    "event_first_child_birth": {
        "rarity": "uncommon", "related_npcs": ["npc_spouse", "npc_first_child"],
        "opts": {"A":{"karma_cost":10,"world_changes":{"happiness":20,"willpower":10}},"B":{"karma_cost":0,"world_changes":{"happiness":10,"health":-5}},"C":{"karma_cost":-20,"world_changes":{"happiness":-15,"craziness":10}}}},
    "event_midlife_crisis": {
        "rarity": "uncommon", "personality_checks": {"craziness": "high", "willpower": "low"}, "trait_boosts": {"career_focus": 1.5},
        "opts": {"A":{"karma_cost":-10,"world_changes":{"gold":-5000,"craziness":15}},"B":{"karma_cost":5,"world_changes":{"discipline":10,"happiness":-10}},"C":{"karma_cost":15,"world_changes":{"willpower":15,"happiness":10}}}},
    "event_health_warning": {
        "rarity": "uncommon", "tension_category": "health", "tension_duration": 3, "personality_checks": {"willpower": "low"},
        "opts": {"A":{"karma_cost":5,"world_changes":{"health":15,"discipline":10}},"B":{"karma_cost":0,"world_changes":{"health":5}},"C":{"karma_cost":-10,"world_changes":{"health":-10,"craziness":5}}}},
    "event_spouse_conflict": {
        "rarity": "uncommon", "related_npcs": ["npc_spouse"], "personality_checks": {"craziness": "high"},
        "opts": {"A":{"karma_cost":10,"world_changes":{"happiness":5,"discipline":10}},"B":{"karma_cost":-5,"world_changes":{"happiness":-10}},"C":{"karma_cost":-20,"world_changes":{"happiness":-30,"craziness":15}}}},
    "event_legacy": {
        "rarity": "uncommon", "event_weight": 1.5, "personality_checks": {"willpower": "high"}, "trait_boosts": {"philanthropist": 1.5},
        "opts": {"A":{"karma_cost":20,"world_changes":{"karma":20,"fame":20}},"B":{"karma_cost":10,"world_changes":{"fame":10}},"C":{"karma_cost":-15,"world_changes":{"gold":5000,"fame":-10}}}},
    "event_family_reunion": {
        "related_npcs": ["npc_spouse", "npc_first_child", "npc_second_child", "npc_grandchild"],
        "opts": {"A":{"karma_cost":10,"world_changes":{"happiness":25}},"B":{"karma_cost":3,"world_changes":{"happiness":10,"gold":-200}},"C":{"karma_cost":-5,"world_changes":{"happiness":-5}}}},
}

NEW_EVENTS = [
    {"event_id":"event_divine_encounter","event_name":"EVENT_DIVINE_ENCOUNTER_NAME","description":"EVENT_DIVINE_ENCOUNTER_DESC","ages":list(range(25,56)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"trait_absent","key":"blessed_one"}],"event_weight":1.0,"karma_type":"positive","rarity":"legendary","tension_category":"","tension_duration":0,"personality_checks":{"craziness":"low"},"related_npcs":[],"trait_boosts":{"pure_heart":2.0},
    "options":[{"option_id":"A","text":"OPTION_DIVINE_ENCOUNTER_A_TEXT","requirements":{"courage":50},"rewards":[{"type":"trait","id":"blessed_one"},{"type":"tower","id":"tower_philosophy_master","count":2}],"karma_cost":15,"world_changes":{"karma":30,"happiness":15,"willpower":15,"intelligence":10}},{"option_id":"B","text":"OPTION_DIVINE_ENCOUNTER_B_TEXT","rewards":[{"type":"trait","id":"unshakeable"},{"type":"gold","value":500}],"karma_cost":30,"world_changes":{"karma":50,"willpower":30,"happiness":10}},{"option_id":"C","text":"OPTION_DIVINE_ENCOUNTER_C_TEXT","rewards":[{"type":"gold","value":5000}],"karma_cost":5,"world_changes":{"gold":5000,"intelligence":10,"craziness":20}}]},

    {"event_id":"event_lottery_jackpot","event_name":"EVENT_LOTTERY_JACKPOT_NAME","description":"EVENT_LOTTERY_JACKPOT_DESC","ages":list(range(20,51)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.0,"karma_type":"neutral","rarity":"legendary","tension_category":"finance","tension_duration":5,"personality_checks":{},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_LOTTERY_JACKPOT_A_TEXT","rewards":[{"type":"gold","value":100000},{"type":"trait","id":"lucky_bastard"}],"karma_cost":-5,"world_changes":{"gold":100000,"happiness":30,"discipline":-10}},{"option_id":"B","text":"OPTION_LOTTERY_JACKPOT_B_TEXT","rewards":[{"type":"gold","value":100000},{"type":"trait","id":"humble_millionaire"}],"karma_cost":10,"world_changes":{"gold":100000,"discipline":20,"happiness":10}},{"option_id":"C","text":"OPTION_LOTTERY_JACKPOT_C_TEXT","rewards":[{"type":"trait","id":"philanthropist"}],"karma_cost":30,"world_changes":{"karma":50,"fame":30}}]},

    {"event_id":"event_childhood_prodigy","event_name":"EVENT_CHILDHOOD_PRODIGY_NAME","description":"EVENT_CHILDHOOD_PRODIGY_DESC","ages":[5,6,7,8],"stage":"childhood","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"trigger_chance","value":0.15}],"event_weight":1.2,"karma_type":"positive","rarity":"rare","tension_category":"exam","tension_duration":15,"personality_checks":{"discipline":"high"},"related_npcs":["npc_father","npc_mother"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_CHILDHOOD_PRODIGY_A_TEXT","cost":{"gold":-300},"rewards":[{"type":"trait","id":"child_prodigy"},{"type":"tower","id":"tower_scholarship_basic","count":2}],"karma_cost":10,"world_changes":{"intelligence":20,"discipline":10,"happiness":-10}},{"option_id":"B","text":"OPTION_CHILDHOOD_PRODIGY_B_TEXT","karma_cost":5,"world_changes":{"intelligence":10,"happiness":10}},{"option_id":"C","text":"OPTION_CHILDHOOD_PRODIGY_C_TEXT","rewards":[{"type":"trait","id":"child_prodigy"}],"karma_cost":-8,"world_changes":{"intelligence":15,"happiness":-15,"craziness":15}}]},

    {"event_id":"event_witness_crime","event_name":"EVENT_WITNESS_CRIME_NAME","description":"EVENT_WITNESS_CRIME_DESC","ages":list(range(16,41)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"trigger_chance","value":0.08}],"event_weight":0.8,"karma_type":"negative","rarity":"rare","tension_category":"crime","tension_duration":3,"personality_checks":{},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_WITNESS_CRIME_A_TEXT","requirements":{"courage":50},"rewards":[{"type":"trait","id":"vigilante"},{"type":"gold","value":100}],"karma_cost":15,"world_changes":{"courage":15,"fame":5}},{"option_id":"B","text":"OPTION_WITNESS_CRIME_B_TEXT","karma_cost":-10,"world_changes":{"craziness":5,"happiness":-5}},{"option_id":"C","text":"OPTION_WITNESS_CRIME_C_TEXT","rewards":[{"type":"gold","value":800}],"karma_cost":-30,"world_changes":{"craziness":20,"karma":-30,"gold":800}}]},

    {"event_id":"event_near_death_experience","event_name":"EVENT_NEAR_DEATH_EXPERIENCE_NAME","description":"EVENT_NEAR_DEATH_EXPERIENCE_DESC","ages":list(range(25,56)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"trigger_chance","value":0.05}],"event_weight":1.0,"karma_type":"neutral","rarity":"rare","tension_category":"health","tension_duration":2,"personality_checks":{},"related_npcs":["npc_spouse"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_NEAR_DEATH_EXPERIENCE_A_TEXT","rewards":[{"type":"trait","id":"born_again"}],"karma_cost":15,"world_changes":{"happiness":30,"willpower":20,"gold":-1000}},{"option_id":"B","text":"OPTION_NEAR_DEATH_EXPERIENCE_B_TEXT","karma_cost":5,"world_changes":{"health":20,"discipline":15}},{"option_id":"C","text":"OPTION_NEAR_DEATH_EXPERIENCE_C_TEXT","karma_cost":-5,"world_changes":{"happiness":25,"craziness":15,"gold":-2000}}]},

    {"event_id":"event_second_chance","event_name":"EVENT_SECOND_CHANCE_NAME","description":"EVENT_SECOND_CHANCE_DESC","ages":list(range(50,71)),"stage":"old_age","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.2,"karma_type":"positive","rarity":"rare","tension_category":"","tension_duration":0,"personality_checks":{"willpower":"high"},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_SECOND_CHANCE_A_TEXT","rewards":[{"type":"trait","id":"late_bloomer"},{"type":"tower","id":"tower_philosophy_master","count":2}],"karma_cost":20,"world_changes":{"intelligence":15,"happiness":25,"fame":15}},{"option_id":"B","text":"OPTION_SECOND_CHANCE_B_TEXT","rewards":[{"type":"gold","value":3000}],"karma_cost":10,"world_changes":{"gold":3000,"happiness":15}},{"option_id":"C","text":"OPTION_SECOND_CHANCE_C_TEXT","karma_cost":5,"world_changes":{"happiness":5}}]},

    {"event_id":"event_school_bully","event_name":"EVENT_SCHOOL_BULLY_NAME","description":"EVENT_SCHOOL_BULLY_DESC","ages":[8,9,10,11,12],"stage":"childhood","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.0,"karma_type":"negative","rarity":"uncommon","tension_category":"","tension_duration":0,"personality_checks":{},"related_npcs":["npc_father"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_SCHOOL_BULLY_A_TEXT","requirements":{"courage":40},"rewards":[{"type":"trait","id":"tough_guy"},{"type":"tower","id":"tower_communication_advanced","count":1}],"karma_cost":8,"world_changes":{"courage":10,"willpower":5}},{"option_id":"B","text":"OPTION_SCHOOL_BULLY_B_TEXT","karma_cost":-5,"world_changes":{"happiness":-15,"courage":-5}},{"option_id":"C","text":"OPTION_SCHOOL_BULLY_C_TEXT","rewards":[{"type":"trait","id":"has_backing"}],"karma_cost":3,"world_changes":{"intelligence":5,"courage":3}}]},

    {"event_id":"event_secret_hiding_place","event_name":"EVENT_SECRET_HIDING_PLACE_NAME","description":"EVENT_SECRET_HIDING_PLACE_DESC","ages":[6,7,8,9,10],"stage":"childhood","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.0,"karma_type":"positive","rarity":"uncommon","tension_category":"","tension_duration":0,"personality_checks":{},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_SECRET_HIDING_PLACE_A_TEXT","rewards":[{"type":"trait","id":"happy_childhood"},{"type":"gold","value":20}],"karma_cost":5,"world_changes":{"happiness":15,"craziness":5}},{"option_id":"B","text":"OPTION_SECRET_HIDING_PLACE_B_TEXT","rewards":[{"type":"trait","id":"little_genius"}],"karma_cost":3,"world_changes":{"intelligence":8,"discipline":5}},{"option_id":"C","text":"OPTION_SECRET_HIDING_PLACE_C_TEXT","rewards":[{"type":"gold","value":40}],"karma_cost":-5,"world_changes":{"courage":8}}]},

    {"event_id":"event_school_election","event_name":"EVENT_SCHOOL_ELECTION_NAME","description":"EVENT_SCHOOL_ELECTION_DESC","ages":[13,14,15,16],"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.0,"karma_type":"positive","rarity":"uncommon","tension_category":"","tension_duration":0,"personality_checks":{},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_SCHOOL_ELECTION_A_TEXT","requirements":{"courage":50},"rewards":[{"type":"tower","id":"tower_communication_advanced","count":1}],"karma_cost":8,"world_changes":{"courage":15,"fame":5}},{"option_id":"B","text":"OPTION_SCHOOL_ELECTION_B_TEXT","karma_cost":-5,"world_changes":{"intelligence":5}},{"option_id":"C","text":"OPTION_SCHOOL_ELECTION_C_TEXT","rewards":[{"type":"gold","value":30}],"karma_cost":0,"world_changes":{"courage":5}}]},

    {"event_id":"event_first_part_time_job","event_name":"EVENT_FIRST_PART_TIME_JOB_NAME","description":"EVENT_FIRST_PART_TIME_JOB_DESC","ages":[15,16,17,18],"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.1,"karma_type":"positive","rarity":"common","tension_category":"career","tension_duration":2,"personality_checks":{"discipline":"high"},"related_npcs":["npc_mother"],"trait_boosts":{"hardworking":1.3},"options":[{"option_id":"A","text":"OPTION_FIRST_PART_TIME_JOB_A_TEXT","rewards":[{"type":"gold","value":100},{"type":"trait","id":"hardworking"}],"karma_cost":8,"world_changes":{"discipline":10}},{"option_id":"B","text":"OPTION_FIRST_PART_TIME_JOB_B_TEXT","rewards":[{"type":"gold","value":50}],"karma_cost":3,"world_changes":{"intelligence":5}},{"option_id":"C","text":"OPTION_FIRST_PART_TIME_JOB_C_TEXT","karma_cost":-5,"world_changes":{"happiness":10,"gold":-20}}]},

    {"event_id":"event_empty_nest","event_name":"EVENT_EMPTY_NEST_NAME","description":"EVENT_EMPTY_NEST_DESC","ages":list(range(45,56)),"stage":"middle_age","is_deadly":False,"chain_prerequisites":["event_child_college"],"chain_excludes":[],"conditions":[],"event_weight":1.0,"karma_type":"neutral","rarity":"uncommon","tension_category":"family","tension_duration":3,"personality_checks":{},"related_npcs":["npc_spouse","npc_first_child"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_EMPTY_NEST_A_TEXT","rewards":[{"type":"trait","id":"career_focus"}],"karma_cost":5,"world_changes":{"discipline":10,"happiness":5}},{"option_id":"B","text":"OPTION_EMPTY_NEST_B_TEXT","rewards":[{"type":"gold","value":-500}],"karma_cost":-10,"world_changes":{"happiness":-15}},{"option_id":"C","text":"OPTION_EMPTY_NEST_C_TEXT","karma_cost":8,"world_changes":{"happiness":15,"willpower":5}}]},

    # Karma反馈事件
    {"event_id":"event_karma_blessing","event_name":"EVENT_KARMA_BLESSING_NAME","description":"EVENT_KARMA_BLESSING_DESC","ages":list(range(20,70)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"attribute","key":"karma","op":">=","value":70}],"event_weight":1.5,"karma_type":"positive","rarity":"uncommon","tension_category":"","tension_duration":0,"personality_checks":{"craziness":"low"},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_KARMA_BLESSING_A_TEXT","rewards":[{"type":"trait","id":"pure_heart"},{"type":"gold","value":200}],"karma_cost":15,"world_changes":{"happiness":20,"karma":10}},{"option_id":"B","text":"OPTION_KARMA_BLESSING_B_TEXT","rewards":[],"karma_cost":5,"world_changes":{"willpower":15}},{"option_id":"C","text":"OPTION_KARMA_BLESSING_C_TEXT","rewards":[{"type":"tower","id":"tower_philosophy_master","count":1}],"karma_cost":10,"world_changes":{"intelligence":10}}]},

    {"event_id":"event_karma_retribution","event_name":"EVENT_KARMA_RETRIBUTION_NAME","description":"EVENT_KARMA_RETRIBUTION_DESC","ages":list(range(25,65)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"attribute","key":"karma","op":"<=","value":-70}],"event_weight":1.5,"karma_type":"negative","rarity":"uncommon","tension_category":"","tension_duration":0,"personality_checks":{"craziness":"high"},"related_npcs":[],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_KARMA_RETRIBUTION_A_TEXT","rewards":[],"karma_cost":-10,"world_changes":{"happiness":-20,"craziness":10}},{"option_id":"B","text":"OPTION_KARMA_RETRIBUTION_B_TEXT","requirements":{"gold":200},"rewards":[{"type":"gold","value":-200}],"karma_cost":15,"world_changes":{"karma":20,"happiness":-5}},{"option_id":"C","text":"OPTION_KARMA_RETRIBUTION_C_TEXT","karma_cost":-20,"world_changes":{"happiness":-15}}]},

    # NPC人格驱动事件
    {"event_id":"event_father_drunk","event_name":"EVENT_FATHER_DRUNK_NAME","description":"EVENT_FATHER_DRUNK_DESC","ages":[12,13,14,15,16,17,18,19,20,21,22,23,24,25],"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"npc_relation","npc_id":"npc_father","op":">=","value":0}],"event_weight":1.2,"karma_type":"negative","rarity":"uncommon","tension_category":"family","tension_duration":3,"personality_checks":{},"related_npcs":["npc_father","npc_mother"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_FATHER_DRUNK_A_TEXT","karma_cost":10,"world_changes":{"willpower":10,"happiness":-10}},{"option_id":"B","text":"OPTION_FATHER_DRUNK_B_TEXT","karma_cost":-5,"world_changes":{"craziness":5}},{"option_id":"C","text":"OPTION_FATHER_DRUNK_C_TEXT","karma_cost":15,"world_changes":{"courage":10,"discipline":5}}]},

    # 老年新增事件
    {"event_id":"event_bucket_list","event_name":"EVENT_BUCKET_LIST_NAME","description":"EVENT_BUCKET_LIST_DESC","ages":[60,61,62,63,64,65,66,67,68,69,70],"stage":"old_age","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.1,"karma_type":"positive","rarity":"uncommon","tension_category":"","tension_duration":0,"personality_checks":{},"related_npcs":["npc_spouse"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_BUCKET_LIST_A_TEXT","cost":{"gold":-2000},"rewards":[{"type":"gold","value":0}],"karma_cost":15,"world_changes":{"happiness":35,"fame":10,"gold":-2000}},{"option_id":"B","text":"OPTION_BUCKET_LIST_B_TEXT","karma_cost":5,"world_changes":{"happiness":10}},{"option_id":"C","text":"OPTION_BUCKET_LIST_C_TEXT","rewards":[{"type":"tower","id":"tower_scholarship_basic","count":3}],"karma_cost":20,"world_changes":{"happiness":20,"fame":15}}]},

    {"event_id":"event_will_writing","event_name":"EVENT_WILL_WRITING_NAME","description":"EVENT_WILL_WRITING_DESC","ages":list(range(55,71)),"stage":"old_age","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[],"event_weight":1.0,"karma_type":"neutral","rarity":"uncommon","tension_category":"family","tension_duration":1,"personality_checks":{},"related_npcs":["npc_spouse","npc_first_child"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_WILL_WRITING_A_TEXT","karma_cost":15,"world_changes":{"happiness":10,"fame":10}},{"option_id":"B","text":"OPTION_WILL_WRITING_B_TEXT","karma_cost":0,"world_changes":{"happiness":-5}},{"option_id":"C","text":"OPTION_WILL_WRITING_C_TEXT","karma_cost":-10,"world_changes":{"craziness":10}}]},

    # 职业特殊事件
    {"event_id":"event_profession_milestone","event_name":"EVENT_PROFESSION_MILESTONE_NAME","description":"EVENT_PROFESSION_MILESTONE_DESC","ages":list(range(30,56)),"stage":"youth","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"profession_absent","absent":True}],"event_weight":1.1,"karma_type":"positive","rarity":"uncommon","tension_category":"career","tension_duration":3,"personality_checks":{"discipline":"high"},"related_npcs":[],"trait_boosts":{"career_focus":1.5},"options":[{"option_id":"A","text":"OPTION_PROFESSION_MILESTONE_A_TEXT","rewards":[{"type":"gold","value":500},{"type":"tower","id":"tower_finance_advanced","count":1}],"karma_cost":10,"world_changes":{"fame":20,"discipline":10}},{"option_id":"B","text":"OPTION_PROFESSION_MILESTONE_B_TEXT","karma_cost":5,"world_changes":{"fame":10}},{"option_id":"C","text":"OPTION_PROFESSION_MILESTONE_C_TEXT","karma_cost":-8,"world_changes":{"craziness":10,"fame":5}}]},

    # 跨阶段事件链：天赋发现→发展→成就
    {"event_id":"event_talent_discovery","event_name":"EVENT_TALENT_DISCOVERY_NAME","description":"EVENT_TALENT_DISCOVERY_DESC","ages":[8,9,10,11,12],"stage":"childhood","is_deadly":False,"chain_prerequisites":[],"chain_excludes":[],"conditions":[{"type":"trigger_chance","value":0.3}],"event_weight":1.1,"karma_type":"positive","rarity":"uncommon","tension_category":"exam","tension_duration":10,"personality_checks":{},"related_npcs":["npc_father","npc_mother"],"trait_boosts":{},"options":[{"option_id":"A","text":"OPTION_TALENT_DISCOVERY_A_TEXT","rewards":[{"type":"trait","id":"child_prodigy"}],"karma_cost":8,"world_changes":{"intelligence":10,"discipline":10,"happiness":-5}},{"option_id":"B","text":"OPTION_TALENT_DISCOVERY_B_TEXT","karma_cost":3,"world_changes":{"intelligence":5,"happiness":10}},{"option_id":"C","text":"OPTION_TALENT_DISCOVERY_C_TEXT","karma_cost":-5,"world_changes":{"courage":8}}]},

    {"event_id":"event_talent_mastery","event_name":"EVENT_TALENT_MASTERY_NAME","description":"EVENT_TALENT_MASTERY_DESC","ages":list(range(25,41)),"stage":"youth","is_deadly":False,"chain_prerequisites":["flag:child_prodigy"],"chain_excludes":[],"conditions":[],"event_weight":1.5,"karma_type":"positive","rarity":"uncommon","tension_category":"career","tension_duration":5,"personality_checks":{"discipline":"high"},"related_npcs":[],"trait_boosts":{"child_prodigy":2.0},"options":[{"option_id":"A","text":"OPTION_TALENT_MASTERY_A_TEXT","rewards":[{"type":"tower","id":"tower_philosophy_master","count":2},{"type":"gold","value":500}],"karma_cost":15,"world_changes":{"intelligence":20,"fame":25,"discipline":15}},{"option_id":"B","text":"OPTION_TALENT_MASTERY_B_TEXT","karma_cost":5,"world_changes":{"intelligence":10,"fame":10}},{"option_id":"C","text":"OPTION_TALENT_MASTERY_C_TEXT","karma_cost":-10,"world_changes":{"intelligence":15,"craziness":10}}]},
]

NEW_TRANSLATIONS = [
    # 传说事件
    ("EVENT_DIVINE_ENCOUNTER_NAME","神圣邂逅","Divine Encounter"),
    ("EVENT_DIVINE_ENCOUNTER_DESC","一道金光闪过，一个声音在你脑海中响起...","A golden light flashes, a voice echoes in your mind..."),
    ("OPTION_DIVINE_ENCOUNTER_A_TEXT","接受祝福，踏上非凡之路","Accept the blessing"),
    ("OPTION_DIVINE_ENCOUNTER_B_TEXT","拒绝并坚守本心","Refuse and stay true"),
    ("OPTION_DIVINE_ENCOUNTER_C_TEXT","讨价还价，索要更多","Negotiate for more"),
    ("EVENT_LOTTERY_JACKPOT_NAME","彩票中奖","Lottery Jackpot"),
    ("EVENT_LOTTERY_JACKPOT_DESC","你随手买了一张彩票，然后...","You bought a lottery ticket on a whim, and then..."),
    ("OPTION_LOTTERY_JACKPOT_A_TEXT","辞去工作，享受人生","Quit and enjoy life"),
    ("OPTION_LOTTERY_JACKPOT_B_TEXT","继续低调生活","Stay humble"),
    ("OPTION_LOTTERY_JACKPOT_C_TEXT","全部捐出，造福社会","Donate it all"),
    # 稀有事件
    ("EVENT_CHILDHOOD_PRODIGY_NAME","天赋异禀","Childhood Prodigy"),
    ("EVENT_CHILDHOOD_PRODIGY_DESC","你展现出远超同龄人的天赋...","You show extraordinary talent beyond your age..."),
    ("OPTION_CHILDHOOD_PRODIGY_A_TEXT","全力培养，牺牲童年","Push for greatness"),
    ("OPTION_CHILDHOOD_PRODIGY_B_TEXT","顺其自然","Let it develop naturally"),
    ("OPTION_CHILDHOOD_PRODIGY_C_TEXT","过度施压，急功近利","Over-push for results"),
    ("EVENT_WITNESS_CRIME_NAME","目睹犯罪","Witness a Crime"),
    ("EVENT_WITNESS_CRIME_DESC","你目睹了一场犯罪，你的选择将改变一切...","You witness a crime unfolding before you..."),
    ("OPTION_WITNESS_CRIME_A_TEXT","勇敢报警","Report to police"),
    ("OPTION_WITNESS_CRIME_B_TEXT","装作没看见","Pretend you saw nothing"),
    ("OPTION_WITNESS_CRIME_C_TEXT","参与其中","Join in"),
    ("EVENT_NEAR_DEATH_EXPERIENCE_NAME","死里逃生","Near Death Experience"),
    ("EVENT_NEAR_DEATH_EXPERIENCE_DESC","一场意外让你与死神擦肩而过...","An accident brings you face to face with death..."),
    ("OPTION_NEAR_DEATH_EXPERIENCE_A_TEXT","重新审视人生","Re-examine your life"),
    ("OPTION_NEAR_DEATH_EXPERIENCE_B_TEXT","更加谨慎","Become more cautious"),
    ("OPTION_NEAR_DEATH_EXPERIENCE_C_TEXT","活在当下","Live in the moment"),
    ("EVENT_SECOND_CHANCE_NAME","第二人生","Second Chance"),
    ("EVENT_SECOND_CHANCE_DESC","人生到了晚年，你得到了一个意想不到的机会...","Late in life, you receive an unexpected opportunity..."),
    ("OPTION_SECOND_CHANCE_A_TEXT","全力以赴","Go all in"),
    ("OPTION_SECOND_CHANCE_B_TEXT","稳健投资","Invest wisely"),
    ("OPTION_SECOND_CHANCE_C_TEXT","安享晚年","Enjoy retirement"),
    # 童年新增
    ("EVENT_SCHOOL_BULLY_NAME","校园霸凌","School Bully"),
    ("EVENT_SCHOOL_BULLY_DESC","学校里有人在欺负你...","Someone is bullying you at school..."),
    ("OPTION_SCHOOL_BULLY_A_TEXT","勇敢反击","