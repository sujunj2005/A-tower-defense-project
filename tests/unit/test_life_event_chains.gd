extends GutTest

var _events: Dictionary
var _previous_state: GameState.State

func before_all() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/events.json")
	for entry: Dictionary in data.events:
		var event: EventData = EventData.from_dict(entry)
		_events[event.event_id] = event

func before_each() -> void:
	_previous_state = GameState.current_state
	GameState.current_state = GameState.State.STAGE
	Global.reset_game_session()

func after_each() -> void:
	Global.reset_game_session()
	GameState.current_state = _previous_state

func test_math_contest_routes_are_exclusive() -> void:
	for index: int in range(3):
		Global.reset_game_session()
		_set_age(8, "childhood")
		_choose("event_math_contest", index)
		assert_eq(_eligible("event_math_club_invitation"), index < 2, "参赛才能收到数学小组邀请")
		assert_eq(_eligible("event_school_track_trial"), index == 2, "去踢球才能收到运动队邀请")

func test_childhood_activity_returns_as_a_youth_choice() -> void:
	for branch: Array in [
		["event_math_club_invitation", "event_math_peer_tutoring", "math_contest_participated"],
		["event_school_track_trial", "event_youth_relay", "math_contest_played_football"]
	]:
		Global.reset_game_session()
		_set_age(9, "childhood")
		var session: GameSessionData = Global.get_game_session()
		session.completed_events.append("event_math_contest")
		session.chain_flags.append(branch[2])
		assert_true(_eligible(branch[0]), "童年分支应当出现")
		if not _events.has(branch[0]):
			continue
		_choose(branch[0], 0)
		_set_age(15, "youth")
		assert_true(_eligible(branch[1]), "参加童年活动后应在青年阶段看到对应回响")

func test_rental_incident_and_follow_up_use_existing_choices() -> void:
	for index: int in range(2):
		Global.reset_game_session()
		_set_age(25, "youth")
		var session: GameSessionData = Global.get_game_session()
		session.gold = 100
		assert_false(_eligible("event_rental_water_leak"), "尚未租房不能触发租屋漏水")
		session.completed_events.append("event_rent_house")
		assert_true(_eligible("event_rental_water_leak"), "租房后可以触发住房问题")
		assert_false(_eligible("event_rental_follow_up"), "漏水尚未处理时不能办理收尾")
		if not _events.has("event_rental_water_leak"):
			continue
		_choose("event_rental_water_leak", index)
		assert_true(_eligible("event_rental_follow_up"), "任一处理方式都应开启收尾")
		if _events.has("event_rental_follow_up"):
			var follow_up: EventData = _events["event_rental_follow_up"]
			assert_eq(OptionSystem.check_requirements(follow_up.options[0]), index == 0, "只有留下的租客能验收维修")
			assert_eq(OptionSystem.check_requirements(follow_up.options[1]), index == 1, "只有搬走的租客能办理交接")

func test_vehicle_accident_has_midlife_recovery_and_follow_up() -> void:
	for index: int in range(2):
		Global.reset_game_session()
		_set_age(35, "middle_age")
		var session: GameSessionData = Global.get_game_session()
		session.gold = 600 if index == 0 else 0
		assert_false(_eligible("event_recovery"), "没有事故记录时不触发事故康复")
		_choose("event_accident", index)
		assert_eq(session.gold, 100 if index == 0 else 0, "事故支出只结算一次")
		assert_eq(session.attributes.health, 70 if index == 0 else 50, "事故损耗只结算一次")
		assert_true(_eligible("event_recovery"), "幸存后应能在中年进入康复")
		if not _eligible("event_recovery"):
			GameState.current_state = GameState.State.STAGE
			continue
		_choose("event_recovery", 0)
		assert_true(_eligible("event_recovery_new_routine"), "结束康复后应有调整日常的后续")

func test_childhood_prodigy_unlocks_existing_talent_payoff() -> void:
	_set_age(25, "youth")
	var session: GameSessionData = Global.get_game_session()
	assert_false(_eligible("event_talent_mastery"), "成年天赋回响需要童年铺垫")
	session.completed_events.append("event_childhood_prodigy")
	assert_true(_eligible("event_talent_mastery"), "已有童年天赋事件记录即可进入回响")

func test_father_farewell_accepts_one_retirement_choice() -> void:
	_set_age(48, "middle_age")
	var session: GameSessionData = Global.get_game_session()
	session.completed_events.append("event_father_retire")
	for flag: String in ["father_retire_cared", "father_retire_mail", "father_retire_reconciled", "father_retire_cold"]:
		session.chain_flags.assign([flag])
		assert_eq(_eligible("event_father_final"), flag != "father_retire_cold", flag)
		assert_eq(_eligible("event_father_alone"), flag == "father_retire_cold", flag)

func test_parent_memories_follow_either_valid_outcome() -> void:
	_set_age(59, "old_age")
	var session: GameSessionData = Global.get_game_session()
	for event_id: String in ["event_father_final", "event_father_alone"]:
		session.completed_events.assign([event_id])
		assert_true(_eligible("event_father_memory"), event_id)
	_set_age(55, "old_age")
	for event_id: String in ["event_mother_recovery", "event_mother_decline"]:
		session.completed_events.assign([event_id])
		assert_true(_eligible("event_mother_final_memory"), event_id)

func test_mother_care_options_open_only_their_own_outcomes() -> void:
	for index: int in range(4):
		Global.reset_game_session()
		_set_age(35, "middle_age")
		_choose("event_mother_sick_serious", index)
		_set_age(40, "middle_age")
		assert_eq(_eligible("event_mother_recovery"), index != 3, "接受照护可以进入康复分支")
		assert_eq(_eligible("event_mother_decline"), index == 3, "未接受照护则进入衰退分支")

func test_event_screen_fallback_honors_alternative_prerequisites() -> void:
	_set_age(48, "middle_age")
	var session: GameSessionData = Global.get_game_session()
	session.completed_events.append("event_father_retire")
	session.chain_flags.append("father_retire_mail")
	var screen: Control = load("res://scenes/ui/event_screen.tscn").instantiate()
	add_child_autofree(screen)
	var candidates: Array[EventData] = screen.call("_get_events_for_stage")
	var ids: Array = candidates.map(func(event: EventData) -> String: return event.event_id)
	assert_has(ids, "event_father_final")
	assert_does_not_have(ids, "event_father_alone")

func _set_age(age: int, stage: String) -> void:
	var session: GameSessionData = Global.get_game_session()
	session.current_age = age
	session.current_stage = stage
	AgeSystem.current_age = age

func _choose(event_id: String, index: int) -> void:
	var event: EventData = _events[event_id]
	EventSystem.select_option(event.to_dict(), event.options[index].to_dict())

func _eligible(event_id: String) -> bool:
	var event: EventData = _events.get(event_id)
	return event != null and EventSystem._can_trigger(event, AgeSystem)
