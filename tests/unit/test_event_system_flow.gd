extends GutTest

func test_trigger_battle_stores_battle_id() -> void:
	var session: GameSessionData = EventSystem.session
	var old_battle_id: String = session.current_battle_id
	var old_deadly: bool = session.current_battle_deadly
	
	var battle_trigger: Dictionary = {"battle_id": "battle_math_contest", "is_deadly": false}
	EventSystem._trigger_battle(battle_trigger)
	
	assert_eq(session.current_battle_id, "battle_math_contest", "battle_id 应存储到 session")
	assert_false(session.current_battle_deadly, "非致命战斗应标记为 false")
	
	session.current_battle_id = old_battle_id
	session.current_battle_deadly = old_deadly

func test_trigger_battle_deadly_flag() -> void:
	var session: GameSessionData = EventSystem.session
	var old_battle_id: String = session.current_battle_id
	var old_deadly: bool = session.current_battle_deadly
	
	var battle_trigger: Dictionary = {"battle_id": "battle_cancer", "is_deadly": true}
	EventSystem._trigger_battle(battle_trigger)
	
	assert_eq(session.current_battle_id, "battle_cancer", "致命战斗 battle_id 应存储")
	assert_true(session.current_battle_deadly, "致命战斗应标记为 true")
	
	session.current_battle_id = old_battle_id
	session.current_battle_deadly = old_deadly

func test_select_option_without_battle() -> void:
	var session: GameSessionData = EventSystem.session
	var old_battle_id: String = session.current_battle_id
	var old_events_size: int = session.completed_events.size()
	
	var option: Dictionary = {"option_id": "A", "text": "选项A", "requirements": {}, "rewards": [], "battle_trigger": null}
	var event_data: Dictionary = {"event_id": "event_test_no_battle", "options": [option]}
	EventSystem.select_option(event_data, option)
	
	assert_eq(session.current_battle_id, old_battle_id, "无战斗选项不应改变 battle_id")
	assert_true(session.completed_events.has("event_test_no_battle"), "应记录已完成事件")
	
	session.completed_events.remove_at(session.completed_events.find("event_test_no_battle"))
	session.current_battle_id = old_battle_id

func test_select_option_with_battle() -> void:
	var session: GameSessionData = EventSystem.session
	var old_battle_id: String = session.current_battle_id
	var old_deadly: bool = session.current_battle_deadly
	var old_events_size: int = session.completed_events.size()
	
	var option: Dictionary = {"option_id": "A", "text": "选项A", "requirements": {}, "rewards": [], "battle_trigger": {"battle_id": "battle_test", "is_deadly": false}}
	var event_data: Dictionary = {"event_id": "event_test_with_battle", "options": [option]}
	EventSystem.select_option(event_data, option)
	
	assert_eq(session.current_battle_id, "battle_test", "有战斗选项应设置 battle_id")
	
	session.current_battle_id = old_battle_id
	session.current_battle_deadly = old_deadly
	if session.completed_events.has("event_test_with_battle"):
		session.completed_events.remove_at(session.completed_events.find("event_test_with_battle"))

func test_select_option_applies_gold_reward() -> void:
	var session: GameSessionData = EventSystem.session
	var old_gold: int = session.gold
	var old_events_size: int = session.completed_events.size()
	
	var option: Dictionary = {"option_id": "A", "text": "选项A", "requirements": {}, "rewards": [{"type": "gold", "value": 50}], "battle_trigger": null}
	var event_data: Dictionary = {"event_id": "event_gold_test", "options": [option]}
	EventSystem.select_option(event_data, option)
	
	assert_eq(session.gold, old_gold + 50, "金币奖励应正确应用")
	
	session.gold = old_gold
	if session.completed_events.has("event_gold_test"):
		session.completed_events.remove_at(session.completed_events.find("event_gold_test"))

func test_select_option_applies_tower_reward() -> void:
	var session: GameSessionData = EventSystem.session
	var old_towers_size: int = session.towers.size()
	
	var option: Dictionary = {"option_id": "A", "text": "选项A", "requirements": {}, "rewards": [{"type": "tower", "id": "tower_math_basic_test", "count": 1}], "battle_trigger": null}
	var event_data: Dictionary = {"event_id": "event_tower_test", "options": [option]}
	EventSystem.select_option(event_data, option)
	
	assert_true(session.towers.size() > old_towers_size, "塔奖励应添加到 towers")
	
	if session.completed_events.has("event_tower_test"):
		session.completed_events.remove_at(session.completed_events.find("event_tower_test"))

func test_select_option_applies_trait_reward() -> void:
	var session: GameSessionData = EventSystem.session
	
	var option: Dictionary = {"option_id": "A", "text": "选项A", "requirements": {}, "rewards": [{"type": "trait", "id": "test_trait_reward"}], "battle_trigger": null}
	var event_data: Dictionary = {"event_id": "event_trait_test", "options": [option]}
	EventSystem.select_option(event_data, option)
	
	assert_true(session.traits.has("test_trait_reward"), "特质奖励应添加到 traits")
	
	if session.traits.has("test_trait_reward"):
		session.traits.remove_at(session.traits.find("test_trait_reward"))
	if session.completed_events.has("event_trait_test"):
		session.completed_events.remove_at(session.completed_events.find("event_trait_test"))

func test_select_option_records_completed_event() -> void:
	var session: GameSessionData = EventSystem.session
	
	var option: Dictionary = {"option_id": "A", "text": "选项A", "requirements": {}, "rewards": [], "battle_trigger": null}
	var event_data: Dictionary = {"event_id": "event_record_test", "options": [option]}
	EventSystem.select_option(event_data, option)
	
	assert_true(session.completed_events.has("event_record_test"), "已完成事件应记录到 completed_events")
	
	if session.completed_events.has("event_record_test"):
		session.completed_events.remove_at(session.completed_events.find("event_record_test"))
