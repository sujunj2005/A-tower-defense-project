"""
升级现有事件 + 追加新事件 + 添加翻译条目
"""
import json, shutil, os
from datetime import datetime

BASE = r"E:\Test_MCP\first\TestMCP"
EVT = os.path.join(BASE, "data", "events.json")
NEW = os.path.join(BASE, "data", "new_events_v2.json")
CSV = os.path.join(BASE, "locale", "translations.csv")
BAK = EVT.replace(".json", ".bak." + datetime.now().strftime("%Y%m%d_%H%M%S"))

shutil.copy2(EVT, BAK)
print(f"备份: {BAK}")

with open(EVT, "r", encoding="utf-8") as f:
    data = json.load(f)
with open(NEW, "r", encoding="utf-8") as f:
    new_data = json.load(f)

events = data["events"]
print(f"现有事件: {len(events)}")

# ── 升级现有事件 ──
UPGRADES = {
    "event_kindergarten_show": {"rarity":"uncommon","personality_checks":{"craziness":"low"},"trait_boosts":{"little_singer":1.3}},
    "event_hobby_class": {"rarity":"uncommon","personality_checks":{"willpower":"high"},"tension_category":"exam","tension_duration":3},
    "event_peer_conflict": {"related_npcs":["npc_father","npc_mother"]},
    "event_family_crisis": {"rarity":"uncommon","personality_checks":{"willpower":"low"}},
    "event_zhongkao": {"rarity":"uncommon","event_weight":1.3,"trait_boosts":{"hardworking":1.3,"little_genius":1.3}},
    "event_college_love": {"rarity":"uncommon","personality_checks":{"craziness":"high"}},
    "event_master_or_work": {"rarity":"uncommon","personality_checks":{"discipline":"high","willpower":"high"},"event_weight":1.4},
    "event_first_job": {"tension_category":"career","tension_duration":3,"personality_checks":{"discipline":"high"}},
    "event_workplace_newbie": {"rarity":"uncommon","personality_checks":{"willpower":"low"}},
    "event_career_breakthrough": {"rarity":"uncommon","personality_checks":{"discipline":"high","willpower":"high"},"event_weight":1.3,"trait_boosts":{"career_focus":1.4}},
    "event_side_hustle": {"rarity":"uncommon","personality_checks":{"craziness":"high"}},
    "event_marriage_pressure": {"related_npcs":["npc_mother"],"personality_checks":{"willpower":"low"}},
    "event_proposal": {"rarity":"uncommon","related_npcs":["npc_spouse"]},
    "event_wedding": {"rarity":"uncommon","related_npcs":["npc_spouse"]},
    "event_first_child_birth": {"rarity":"uncommon","related_npcs":["npc_spouse","npc_first_child"]},
    "event_midlife_crisis": {"rarity":"uncommon","personality_checks":{"craziness":"high","willpower":"low"},"trait_boosts":{"career_focus":1.5}},
    "event_health_warning": {"rarity":"uncommon","tension_category":"health","tension_duration":3,"personality_checks":{"willpower":"low"}},
    "event_spouse_conflict": {"rarity":"uncommon","related_npcs":["npc_spouse"],"personality_checks":{"craziness":"high"}},
    "event_legacy": {"rarity":"uncommon","event_weight":1.5,"personality_checks":{"willpower":"high"},"trait_boosts":{"philanthropist":1.5}},
    "event_family_reunion": {"related_npcs":["npc_spouse","npc_first_child","npc_second_child","npc_grandchild"]},
    "event_serious_disease": {"rarity":"rare","tension_category":"health","tension_duration":5},
    "event_health_crisis": {"rarity":"rare","tension_category":"health","tension_duration":5},
    "event_old_friend_passing": {"rarity":"uncommon","personality_checks":{"willpower":"low"}},
    "event_life_reflection": {"rarity":"uncommon","personality_checks":{"willpower":"high"}},
    "event_retirement_hobby": {"rarity":"common"},
    "event_old_friend": {"personality_checks":{"willpower":"low"}},
}

upgraded = 0
for ev in events:
    eid = ev.get("event_id","")
    if eid in UPGRADES:
        for k, v in UPGRADES[eid].items():
            ev[k] = v
        upgraded += 1
print(f"升级了 {upgraded} 个现有事件")

# ── 追加新事件 ──
new_count = len(new_data["events"])
events.extend(new_data["events"])
print(f"追加了 {new_count} 个新事件, 总数: {len(events)}")

with open(EVT, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent="\t")
print(f"写入: {EVT}")

# ── 追加翻译 ──
NEW_TR = [
    ("EVENT_DIVINE_ENCOUNTER_NAME","神圣邂逅","Divine Encounter"),
    ("EVENT_DIVINE_ENCOUNTER_DESC","一道金光闪过，一个声音在你脑海中响起...","A golden light flashes, a voice echoes in your mind..."),
    ("OPTION_DIVINE_ENCOUNTER_A_TEXT","接受祝福，踏上非凡之路","Accept the blessing"),
    ("OPTION_DIVINE_ENCOUNTER_B_TEXT","拒绝并坚守本心","Refuse and stay true"),
    ("OPTION_DIVINE_ENCOUNTER_C_TEXT","讨价还价，索要更多","Negotiate for more"),
    ("EVENT_LOTTERY_JACKPOT_NAME","彩票中奖","Lottery Jackpot"),
    ("EVENT_LOTTERY_JACKPOT_DESC","你随手买了一张彩票，然后...","You bought a lottery ticket on a whim..."),
    ("OPTION_LOTTERY_JACKPOT_A_TEXT","辞去工作，享受人生","Quit and enjoy life"),
    ("OPTION_LOTTERY_JACKPOT_B_TEXT","继续低调生活","Stay humble"),
    ("OPTION_LOTTERY_JACKPOT_C_TEXT","全部捐出，造福社会","Donate it all"),
    ("EVENT_CHILDHOOD_PRODIGY_NAME","天赋异禀","Childhood Prodigy"),
    ("EVENT_CHILDHOOD_PRODIGY_DESC","你展现出远超同龄人的天赋...","You show extraordinary talent..."),
    ("OPTION_CHILDHOOD_PRODIGY_A_TEXT","全力培养，牺牲童年","Push for greatness"),
    ("OPTION_CHILDHOOD_PRODIGY_B_TEXT","顺其自然","Let it develop naturally"),
    ("OPTION_CHILDHOOD_PRODIGY_C_TEXT","过度施压，急功近利","Over-push for results"),
    ("EVENT_WITNESS_CRIME_NAME","目睹犯罪","Witness a Crime"),
    ("EVENT_WITNESS_CRIME_DESC","你目睹了一场犯罪，你的选择将改变一切...","You witness a crime unfolding..."),
    ("OPTION_WITNESS_CRIME_A_TEXT","勇敢报警","Report to police"),
    ("OPTION_WITNESS_CRIME_B_TEXT","装作没看见","Pretend you saw nothing"),
    ("OPTION_WITNESS_CRIME_C_TEXT","参与其中","Join in"),
    ("EVENT_NEAR_DEATH_EXPERIENCE_NAME","死里逃生","Near Death"),
    ("EVENT_NEAR_DEATH_EXPERIENCE_DESC","一场意外让你与死神擦肩而过...","An accident brings you face to face with death..."),
    ("OPTION_NEAR_DEATH_EXPERIENCE_A_TEXT","重新审视人生","Re-examine your life"),
    ("OPTION_NEAR_DEATH_EXPERIENCE_B_TEXT","更加谨慎","Become more cautious"),
    ("OPTION_NEAR_DEATH_EXPERIENCE_C_TEXT","活在当下","Live in the moment"),
    ("EVENT_SECOND_CHANCE_NAME","第二人生","Second Chance"),
    ("EVENT_SECOND_CHANCE_DESC","人生到了晚年，你得到了一个意想不到的机会...","Late in life, an unexpected opportunity..."),
    ("OPTION_SECOND_CHANCE_A_TEXT","全力以赴","Go all in"),
    ("OPTION_SECOND_CHANCE_B_TEXT","稳健投资","Invest wisely"),
    ("OPTION_SECOND_CHANCE_C_TEXT","安享晚年","Enjoy retirement"),
    ("EVENT_SCHOOL_BULLY_NAME","校园霸凌","School Bully"),
    ("EVENT_SCHOOL_BULLY_DESC","学校里有人在欺负你...","Someone is bullying you at school..."),
    ("OPTION_SCHOOL_BULLY_A_TEXT","勇敢反击","Fight back"),
    ("OPTION_SCHOOL_BULLY_B_TEXT","默默忍受","Endure silently"),
    ("OPTION_SCHOOL_BULLY_C_TEXT","告诉老师/家长","Tell a teacher"),
    ("EVENT_SECRET_HIDING_PLACE_NAME","秘密基地","Secret Hiding Place"),
    ("EVENT_SECRET_HIDING_PLACE_DESC","你发现了一个完美的秘密基地...","You found a perfect secret hiding place..."),
    ("OPTION_SECRET_HIDING_PLACE_A_TEXT","和小伙伴一起玩","Play with friends"),
    ("OPTION_SECRET_HIDING_PLACE_B_TEXT","独自看书学习","Study alone"),
    ("OPTION_SECRET_HIDING_PLACE_C_TEXT","探索周围环境","Explore the surroundings"),
    ("EVENT_SCHOOL_ELECTION_NAME","竞选班委","School Election"),
    ("EVENT_SCHOOL_ELECTION_DESC","班级要选班长了...","The class is electing a monitor..."),
    ("OPTION_SCHOOL_ELECTION_A_TEXT","勇敢竞选","Run for election"),
    ("OPTION_SCHOOL_ELECTION_B_TEXT","专心学习","Focus on studies"),
    ("OPTION_SCHOOL_ELECTION_C_TEXT","支持好友","Support a friend"),
    ("EVENT_FIRST_PART_TIME_JOB_NAME","第一份兼职","First Part-time Job"),
    ("EVENT_FIRST_PART_TIME_JOB_DESC","你找到了第一份兼职工作...","You found your first part-time job..."),
    ("OPTION_FIRST_PART_TIME_JOB_A_TEXT","认真工作","Work diligently"),
    ("OPTION_FIRST_PART_TIME_JOB_B_TEXT","兼顾学习","Balance with studies"),
    ("OPTION_FIRST_PART_TIME_JOB_C_TEXT","辞职享受青春","Quit and enjoy youth"),
    ("EVENT_EMPTY_NEST_NAME","空巢综合症","Empty Nest"),
    ("EVENT_EMPTY_NEST_DESC","孩子长大了，要离开家了...","The kids are grown and leaving home..."),
    ("OPTION_EMPTY_NEST_A_TEXT","投入事业","Dive into career"),
    ("OPTION_EMPTY_NEST_B_TEXT","难以适应","Struggle to adapt"),
    ("OPTION_EMPTY_NEST_C_TEXT","重拾二人世界","Rekindle romance"),
    ("EVENT_KARMA_BLESSING_NAME","善有善报","Good Karma"),
    ("EVENT_KARMA_BLESSING_DESC","你做了太多好事，命运决定给你回报...","Fate rewards your good deeds..."),
    ("OPTION_KARMA_BLESSING_A_TEXT","心中充满喜悦","Feel joy"),
    ("OPTION_KARMA_BLESSING_B_TEXT","更加坚定","Stay resolved"),
    ("OPTION_KARMA_BLESSING_C_TEXT","获得智慧启迪","Receive wisdom"),
    ("EVENT_KARMA_RETRIBUTION_NAME","恶有恶报","Karma Strikes"),
    ("EVENT_KARMA_RETRIBUTION_DESC","你做了太多坏事，命运来讨债了...","Fate comes to collect..."),
    ("OPTION_KARMA_RETRIBUTION_A_TEXT","破罐破摔","Double down"),
    ("OPTION_KARMA_RETRIBUTION_B_TEXT","赎罪改过","Seek redemption"),
    ("OPTION_KARMA_RETRIBUTION_C_TEXT","无所谓","Don't care"),
    ("EVENT_FATHER_DRUNK_NAME","醉酒的父亲","Drunk Father"),
    ("EVENT_FATHER_DRUNK_DESC","父亲又喝醉了...","Father is drunk again..."),
    ("OPTION_FATHER_DRUNK_A_TEXT","扶他回家","Help him home"),
    ("OPTION_FATHER_DRUNK_B_TEXT","视而不见","Ignore him"),
    ("OPTION_FATHER_DRUNK_C_TEXT","和他谈一谈","Talk to him"),
    ("EVENT_BUCKET_LIST_NAME","遗愿清单","Bucket List"),
    ("EVENT_BUCKET_LIST_DESC","人生苦短，是时候列个清单了...","Life is short, time to make a list..."),
    ("OPTION_BUCKET_LIST_A_TEXT","环球旅行","Travel the world"),
    ("OPTION_BUCKET_LIST_B_TEXT","安度晚年","Peaceful retirement"),
    ("OPTION_BUCKET_LIST_C_TEXT","传道授业","Teach the next generation"),
    ("EVENT_WILL_WRITING_NAME","遗嘱","Will Writing"),
    ("EVENT_WILL_WRITING_DESC","是时候考虑身后事了...","Time to think about what comes after..."),
    ("OPTION_WILL_WRITING_A_TEXT","公平分配","Fair distribution"),
    ("OPTION_WILL_WRITING_B_TEXT","暂时不考虑","Not yet"),
    ("OPTION_WILL_WRITING_C_TEXT","偏袒特定子女","Favor certain children"),
    ("EVENT_PROFESSION_MILESTONE_NAME","职业里程碑","Career Milestone"),
    ("EVENT_PROFESSION_MILESTONE_DESC","你在职业生涯中达到了一个重要节点...","A major career milestone..."),
    ("OPTION_PROFESSION_MILESTONE_A_TEXT","再接再厉","Push further"),
    ("OPTION_PROFESSION_MILESTONE_B_TEXT","保持现状","Stay the course"),
    ("OPTION_PROFESSION_MILESTONE_C_TEXT","换个方向","Change direction"),
    ("EVENT_TALENT_DISCOVERY_NAME","发现天赋","Talent Discovery"),
    ("EVENT_TALENT_DISCOVERY_DESC","你发现自己在某个领域特别有天赋...","You discover a special talent..."),
    ("OPTION_TALENT_DISCOVERY_A_TEXT","深入钻研","Dive deep"),
    ("OPTION_TALENT_DISCOVERY_B_TEXT","当作爱好","Keep as hobby"),
    ("OPTION_TALENT_DISCOVERY_C_TEXT","展示给朋友","Show off to friends"),
    ("EVENT_TALENT_MASTERY_NAME","天赋大成","Talent Mastery"),
    ("EVENT_TALENT_MASTERY_DESC","多年的努力，你的天赋终于开花结果...","Years of effort bear fruit..."),
    ("OPTION_TALENT_MASTERY_A_TEXT","走向世界","Go global"),
    ("OPTION_TALENT_MASTERY_B_TEXT","知足常乐","Be content"),
    ("OPTION_TALENT_MASTERY_C_TEXT","追求极致","Pursue perfection"),
]

existing_keys = set()
if os.path.exists(CSV):
    with open(CSV, "r", encoding="utf-8-sig") as f:
        existing_keys = {row[0] for row in __import__("csv").reader(f)}

added_tr = 0
with open(CSV, "a", encoding="utf-8-sig", newline="") as f:
    w = __import__("csv").writer(f)
    for key, zh, en in NEW_TR:
        if key not in existing_keys:
            w.writerow([key, zh, en])
            added_tr += 1
print(f"新增翻译: {added_tr}")

# 统计
rarity_stats = {}
for ev in events:
    r = ev.get("rarity","common")
    rarity_stats[r] = rarity_stats.get(r,0)+1
print(f"稀有度分布: {json.dumps(rarity_stats, ensure_ascii=False)}")

tension_stats = {}
for ev in events:
    t = ev.get("tension_category","")
    if t:
        tension_stats[t] = tension_stats.get(t,0)+1
print(f"张力分布: {json.dumps(tension_stats, ensure_ascii=False)}")

npc_count = sum(1 for ev in events if ev.get("related_npcs",[]))
print(f"关联NPC事件: {npc_count}")
