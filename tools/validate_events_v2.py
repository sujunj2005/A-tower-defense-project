import json

with open("data/events.json", "r", encoding="utf-8") as f:
    data = json.load(f)

events = data["events"]
print(f"JSON 合法, 事件总数: {len(events)}\n")

# 缺失字段检查
missing_stats = {}
for ev in events:
    eid = ev["event_id"]
    missing = []
    for field in ["karma_type", "rarity", "tension_category", "tension_duration",
                   "event_weight", "personality_checks", "related_npcs", "trait_boosts"]:
        if field not in ev:
            missing.append(field)
    if missing:
        missing_stats[eid] = missing
    
    # 检查选项
    for opt in ev.get("options", []):
        oid = opt.get("option_id", "?")
        if "karma_cost" not in opt:
            print(f"  ⚠ {eid}/{oid}: 缺少 karma_cost")
        if "world_changes" not in opt:
            print(f"  ⚠ {eid}/{oid}: 缺少 world_changes")

if missing_stats:
    print(f"\n⚠ 事件级缺失字段:")
    for eid, fields in missing_stats.items():
        print(f"  {eid}: {fields}")
else:
    print("\n✓ 所有事件 v2 字段完整")

# 按阶段展示
for stage in ["childhood", "youth", "middle_age", "old_age"]:
    stage_evts = [e for e in events if e["stage"] == stage]
    print(f"\n--- {stage} ({len(stage_evts)} 事件) ---")
    for ev in stage_evts[:5]:
        print(f"  {ev['event_id']}: karma={ev['karma_type']}, rarity={ev['rarity']}, tension={ev['tension_category'] or '-'}")
