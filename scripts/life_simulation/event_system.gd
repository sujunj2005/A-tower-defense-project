class_name EventSystem
extends Node

signal event_triggered(event_data: Dictionary)
signal event_completed(event_id: String, selected_option: String)

var config_manager: ConfigManager
var age_system: AgeSystem
var session: GameSessionData

func _ready() -> void:
	config_manager = Global.get_node("ConfigManager") as ConfigManager
	age_system = Global.get_node("AgeSystem") as AgeSystem
	session = Global.get_game_session()

## 获取当前年龄可触发的事件
func get_events_for_current_age() -> Array:
	var events_data = config_manager.load_json("res://data/events.json")
	if not events_data.has("events"):
		return []
	
	var available_events = []
	
	for event in events_data.events:
		if _can_trigger(event):
			available_events.append(event)
	
	return available_events

## 检查事件是否可以触发
func _can_trigger(event: Dictionary) -> bool:
	# 检查年龄
	if event.get("age", 0) != age_system.current_age:
		return false
	
	# 检查阶段
	var event_stage = event.get("stage", "")
	if event_stage != age_system.get_stage_name():
		return false
	
	# 检查是否已完成
	if event.event_id in session.completed_events:
		return false
	
	return true

## 触发事件
func trigger_event(event: Dictionary) -> void:
	Global.debug_log("触发事件：%s" % event.event_name)
	event_triggered.emit(event)

## 选择选项
func select_option(event: Dictionary, option: Dictionary) -> void:
	Global.debug_log("选择选项：%s" % option.option_id)
	
	# 应用奖励
	_apply_rewards(option.get("rewards", []))
	
	# 应用消耗
	_apply_costs(option.get("cost", {}))
	
	# 标记为完成
	session.completed_events.append(event.event_id)
	age_system.increment_stage_events()
	
	# 触发战斗（如果有）
	if option.has("battle_trigger") and option.battle_trigger:
		_trigger_battle(option.battle_trigger)
	else:
		# 没有战斗，直接年龄增长
		age_system.increase_age(1)
	
	event_completed.emit(event.event_id, option.option_id)

## 应用奖励
func _apply_rewards(rewards: Array) -> void:
	for reward in rewards:
		match reward.type:
			"tower":
				_grant_tower(reward.id, reward.get("count", 1))
			"trait":
				_grant_trait(reward.id)
			"gold":
				session.gold += reward.get("count", 0)
			"attribute":
				var attr = reward.get("attribute", "intelligence")
				var count = reward.get("count", 0)
				if session.attributes.has(attr):
					session.attributes[attr] += count

## 授予防御塔
func _grant_tower(tower_id: String, count: int) -> void:
	session.towers.append({
		"tower_id": tower_id,
		"count": count
	})
	Global.debug_log("获得防御塔：%s x%d" % [tower_id, count])

## 授予词条
func _grant_trait(trait_id: String) -> void:
	if not trait_id in session.traits:
		session.traits.append(trait_id)
		Global.debug_log("获得词条：%s" % trait_id)

## 应用消耗
func _apply_costs(costs: Dictionary) -> void:
	if costs.has("gold"):
		var gold_change = costs.gold
		session.gold += gold_change
		if gold_change < 0:
			Global.debug_log("消耗金币：%d" % (-gold_change))
	
	if costs.has("health"):
		var health_change = costs.health
		session.attributes["health"] += health_change
		if health_change < 0:
			Global.debug_log("消耗健康：%d" % (-health_change))

## 触发战斗
func _trigger_battle(battle_trigger: Dictionary) -> void:
	Global.debug_log("触发战斗：%s" % battle_trigger.get("battle_id", "unknown"))
	# 后续跳转到战斗场景
	# GameState.change_state(GameState.State.BATTLE)

## 检查选项是否满足要求
func check_option_requirements(option: Dictionary) -> bool:
	if not option.has("requirements"):
		return true
	
	for attr_name in option.requirements:
		var required_value = option.requirements[attr_name]
		var current_value = session.attributes.get(attr_name, 0)
		if current_value < required_value:
			return false
	
	return true
