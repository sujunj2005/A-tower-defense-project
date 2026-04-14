extends Node

signal stage_changed(new_stage: String)

enum Stage { CHILDHOOD, YOUTH, MIDDLE_AGE, OLD_AGE }

const STAGE_AGES := {
	Stage.CHILDHOOD: {"start": 6, "end": 12},
	Stage.YOUTH: {"start": 15, "end": 30},
	Stage.MIDDLE_AGE: {"start": 35, "end": 50},
	Stage.OLD_AGE: {"start": 50, "end": 80}
}

const STAGE_IDS := {
	Stage.CHILDHOOD: "childhood",
	Stage.YOUTH: "youth",
	Stage.MIDDLE_AGE: "middle_age",
	Stage.OLD_AGE: "old_age"
}

const STAGE_NAMES := {
	Stage.CHILDHOOD: "童年",
	Stage.YOUTH: "青年",
	Stage.MIDDLE_AGE: "中年",
	Stage.OLD_AGE: "老年"
}

var current_age: int = 6
var current_stage: Stage = Stage.CHILDHOOD
var stage_events_count: int = 0  # 当前阶段经历的事件数

var session: GameSessionData

func _ready() -> void:
	session = Global.get_game_session()
	Global.session_reset.connect(_on_session_reset)

func _on_session_reset() -> void:
	session = Global.get_game_session()
	current_age = session.current_age
	current_stage = Stage.CHILDHOOD
	stage_events_count = 0

## 增加年龄
func increase_age(years: int = 1) -> void:
	current_age += years
	_update_stage()

## 更新阶段
func _update_stage() -> void:
	var new_stage: Stage = current_stage
	
	if current_age >= STAGE_AGES[Stage.OLD_AGE].start:
		new_stage = Stage.OLD_AGE
	elif current_age >= STAGE_AGES[Stage.MIDDLE_AGE].start:
		new_stage = Stage.MIDDLE_AGE
	elif current_age >= STAGE_AGES[Stage.YOUTH].start:
		new_stage = Stage.YOUTH
	elif current_age >= STAGE_AGES[Stage.CHILDHOOD].start:
		new_stage = Stage.CHILDHOOD
	
	if new_stage != current_stage:
		current_stage = new_stage
		stage_events_count = 0
		_on_stage_changed()

## 阶段转换回调
func _on_stage_changed() -> void:
	Global.debug_log("进入新阶段：%s" % get_stage_name())
	session.current_stage = get_stage_id()
	session.current_age = current_age
	stage_changed.emit(get_stage_id())

## 获取阶段名称
func get_stage_id() -> String:
	return STAGE_IDS[current_stage]

func get_stage_name() -> String:
	return STAGE_NAMES[current_stage]

## 获取阶段进度（第几个事件）
func get_stage_progress() -> int:
	return stage_events_count

## 增加阶段事件计数
func increment_stage_events() -> void:
	stage_events_count += 1

## 是否还可以继续增长
func can_continue() -> bool:
	return current_age < 80

## 获取当前阶段可用的事件池
func get_stage_event_pool() -> Array[Dictionary]:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	var stages_data: Dictionary = {}
	if cm and cm.has_method("load_json"):
		stages_data = cm.load_json("res://data/stages.json")
	if not stages_data.has("stages"):
		return []
	var stages: Dictionary = stages_data.stages
	var sid: String = get_stage_id()
	if not stages.has(sid):
		return []
	var pool: Array = stages[sid].get("enemy_pool", [])
	var result: Array[Dictionary] = []
	for entry: Dictionary in pool:
		result.append(entry)
	return result

## 应用老年属性递减
func apply_old_age_penalty() -> void:
	if current_stage == Stage.OLD_AGE:
		# 每年属性 -1%
		var years_old = current_age - STAGE_AGES[Stage.OLD_AGE].start
		var penalty_rate: float = 1.0 - (years_old * 0.01)
		
		for attr in session.attributes:
			session.attributes[attr] = int(float(session.attributes[attr]) * penalty_rate)
		
		Global.debug_log("老年属性递减：%d%%" % int(penalty_rate * 100.0))
