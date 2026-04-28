extends GutTest

var _session: GameSessionData

func before_each() -> void:
	_session = GameSessionData.new()

func test_karma_change_positive() -> void:
	_session.karma = 0
	_apply_karma_change(10)
	assert_eq(_session.karma, 10, "正Karma应增加")

func test_karma_change_negative() -> void:
	_session.karma = 0
	_apply_karma_change(-15)
	assert_eq(_session.karma, -15, "负Karma应减少")

func test_karma_clamped() -> void:
	_session.karma = 95
	_apply_karma_change(20)
	assert_eq(_session.karma, 100, "Karma上限100")
	_session.karma = -95
	_apply_karma_change(-20)
	assert_eq(_session.karma, -100, "Karma下限-100")

func test_karma_weight_positive_event() -> void:
	_session.karma = 100
	var mult: float = _karma_weight_multiplier("positive")
	assert_eq(mult, 1.3, "Karma=+100时正面事件权重×1.3")

func test_karma_weight_negative_event() -> void:
	_session.karma = -100
	var mult: float = _karma_weight_multiplier("negative")
	assert_eq(mult, 1.5, "Karma=-100时负面事件权重×1.5")

func test_karma_weight_neutral() -> void:
	_session.karma = 50
	var mult: float = _karma_weight_multiplier("neutral")
	assert_eq(mult, 1.0, "中性事件权重不变")

func test_tension_add() -> void:
	_apply_tension_changes([{
		"action": "add",
		"tension_id": "exam_prep",
		"tension_type": "exam",
		"duration": 3,
		"pressure": 0.8,
		"resolution_event": "event_gaokao"
	}])
	assert_eq(_session.tensions.size(), 1, "应添加1个张力")
	assert_eq(_session.tensions[0].tension_id, "exam_prep", "张力ID应正确")
	assert_eq(_session.tensions[0].remaining, 3, "剩余年数应为3")
	assert_eq(_session.tensions[0].pressure, 0.8, "压力值应为0.8")

func test_tension_resolve() -> void:
	var t := TensionData.new()
	t.tension_id = "exam_prep"
	t.tension_type = "exam"
	t.remaining = 2
	_session.tensions.append(t)
	_apply_tension_changes([{"action": "resolve", "tension_id": "exam_prep"}])
	assert_eq(_session.tensions.size(), 0, "张力应被移除")

func test_tension_advance() -> void:
	var t := TensionData.new()
	t.tension_id = "exam_prep"
	t.tension_type = "exam"
	t.remaining = 2
	t.resolution_event = "event_gaokao"
	_session.tensions.append(t)
	_advance_tensions()
	assert_eq(_session.tensions.size(), 1, "剩余2年推进1年后应还有1个张力")
	assert_eq(_session.tensions[0].remaining, 1, "剩余年数应为1")

func test_tension_expire() -> void:
	var t := TensionData.new()
	t.tension_id = "exam_prep"
	t.tension_type = "exam"
	t.remaining = 1
	t.resolution_event = "event_gaokao"
	_session.tensions.append(t)
	_advance_tensions()
	assert_eq(_session.tensions.size(), 0, "剩余1年推进1年后张力应到期移除")
	assert_true(_session.unlocked_events.has("event_gaokao"), "到期应解锁结算事件")

func test_rarity_modifier() -> void:
	assert_eq(_rarity_modifier("common"), 1.0, "common权重1.0")
	assert_eq(_rarity_modifier("uncommon"), 0.5, "uncommon权重0.5")
	assert_eq(_rarity_modifier("rare"), 0.1, "rare权重0.1")
	assert_eq(_rarity_modifier("legendary"), 0.03, "legendary权重0.03")

func test_freshness_modifier() -> void:
	_session.recent_events.append("event_test")
	var ev := EventData.new()
	ev.event_id = "event_test"
	assert_eq(_freshness_modifier(ev), 0.3, "近期事件权重衰减为0.3")
	ev.event_id = "event_other"
	assert_eq(_freshness_modifier(ev), 1.0, "非近期事件权重不变")

func test_world_changes_attributes() -> void:
	_session.attributes["intelligence"] = 50
	_apply_world_changes({"intelligence": 10})
	assert_eq(_session.attributes["intelligence"], 60, "world_changes应修改显性属性")

func test_world_changes_hidden_attributes() -> void:
	_session.hidden_attributes["willpower"] = 50
	_apply_world_changes({"willpower": 15})
	assert_eq(_session.hidden_attributes["willpower"], 65, "world_changes应修改隐性属性")

func test_world_changes_karma() -> void:
	_session.karma = 0
	_apply_world_changes({"karma": 10})
	assert_eq(_session.karma, 10, "world_changes应修改karma")

func test_tension_add_replace_existing() -> void:
	var t := TensionData.new()
	t.tension_id = "exam_prep"
	t.remaining = 5
	t.pressure = 0.3
	_session.tensions.append(t)
	_apply_tension_changes([{
		"action": "add",
		"tension_id": "exam_prep",
		"tension_type": "exam",
		"duration": 3,
		"pressure": 0.9,
		"resolution_event": "event_gaokao"
	}])
	assert_eq(_session.tensions.size(), 1, "同ID张力应替换而非新增")
	assert_eq(_session.tensions[0].pressure, 0.9, "替换后压力值应更新")

func test_tension_extend() -> void:
	var t := TensionData.new()
	t.tension_id = "exam_prep"
	t.remaining = 2
	t.duration = 5
	_session.tensions.append(t)
	_apply_tension_changes([{"action": "extend", "tension_id": "exam_prep", "years": 3}])
	assert_eq(_session.tensions[0].remaining, 5, "延长后剩余年数应为5")
	assert_eq(_session.tensions[0].duration, 8, "延长后总年数应为8")

func _apply_karma_change(karma_cost: int) -> void:
	if karma_cost == 0:
		return
	_session.karma = clampi(_session.karma + karma_cost, -100, 100)

func _karma_weight_multiplier(karma_type: String) -> float:
	var k: int = _session.karma
	match karma_type:
		"positive":
			return 1.0 + (k / 100.0) * 0.3
		"negative":
			return 1.0 - (k / 100.0) * 0.5
		_:
			return 1.0

func _rarity_modifier(rarity: String) -> float:
	match rarity:
		"common":
			return 1.0
		"uncommon":
			return 0.5
		"rare":
			return 0.1
		"legendary":
			return 0.03
		_:
			return 1.0

func _freshness_modifier(event: EventData) -> float:
	if event.event_id in _session.recent_events:
		return 0.3
	return 1.0

func _apply_world_changes(changes: Dictionary) -> void:
	if changes.is_empty():
		return
	for key: String in changes:
		var val: int = int(changes[key])
		if _session.attributes.has(key):
			_session.attributes[key] += val
		elif _session.hidden_attributes.has(key):
			_session.hidden_attributes[key] += val
		elif key == "karma":
			_apply_karma_change(val)

func _apply_tension_changes(changes: Array) -> void:
	for change: Dictionary in changes:
		var action: String = str(change.get("action", ""))
		match action:
			"add":
				var t := TensionData.new()
				t.tension_id = str(change.get("tension_id", ""))
				t.tension_type = str(change.get("tension_type", ""))
				t.duration = int(change.get("duration", 3))
				t.remaining = t.duration
				t.pressure = float(change.get("pressure", 0.5))
				t.resolution_event = str(change.get("resolution_event", ""))
				var existing_idx: int = -1
				for i: int in range(_session.tensions.size()):
					if _session.tensions[i].tension_id == t.tension_id:
						existing_idx = i
						break
				if existing_idx >= 0:
					_session.tensions[existing_idx] = t
				else:
					_session.tensions.append(t)
			"resolve":
				var tid: String = str(change.get("tension_id", ""))
				var category: String = str(change.get("tension_category", ""))
				var to_remove: Array[int] = []
				for i: int in range(_session.tensions.size()):
					if (category != "" and _session.tensions[i].tension_type == category) or (tid != "" and _session.tensions[i].tension_id == tid):
						to_remove.append(i)
				to_remove.reverse()
				for idx: int in to_remove:
					_session.tensions.pop_at(idx)
			"extend":
				var tid2: String = str(change.get("tension_id", ""))
				var years: int = int(change.get("years", 1))
				for tension: TensionData in _session.tensions:
					if tension.tension_id == tid2:
						tension.remaining += years
						tension.duration += years

func _advance_tensions() -> void:
	var to_resolve: Array[TensionData] = []
	for tension: TensionData in _session.tensions:
		tension.remaining -= 1
		if tension.remaining <= 0:
			to_resolve.append(tension)
	for tension: TensionData in to_resolve:
		_session.tensions.erase(tension)
		if tension.resolution_event != "":
			_session.unlocked_events.append(tension.resolution_event)
