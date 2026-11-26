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
	Stage.CHILDHOOD: "STAGE_CHILDHOOD_NAME",
	Stage.YOUTH: "STAGE_YOUTH_NAME",
	Stage.MIDDLE_AGE: "STAGE_MIDDLE_AGE_NAME",
	Stage.OLD_AGE: "STAGE_OLD_AGE_NAME"
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
	return tr(STAGE_NAMES[current_stage])

## 获取阶段进度（第几个事件）
func get_stage_progress() -> int:
	return stage_events_count

## 增加阶段事件计数
func increment_stage_events() -> void:
	stage_events_count += 1

## 是否还可以继续增长
func can_continue() -> bool:
	return current_age < 80

## 获取当前阶段的敌人池，保留旧方法名供现有调用方使用。
func get_stage_event_pool() -> Array[Dictionary]:
	return EnemyConfig.get_enemies_for_stage(get_stage_id())

## 应用年龄属性递减（中年和老年）
func apply_age_penalty() -> void:
	if current_stage == Stage.MIDDLE_AGE:
		# 中年：每年属性 -0.5%
		var years_middle = current_age - STAGE_AGES[Stage.MIDDLE_AGE].start
		var penalty_rate: float = 1.0 - (years_middle * 0.005)
		
		for attr in session.attributes:
			session.attributes[attr] = maxi(int(float(session.attributes[attr]) * penalty_rate), 1)
		
		Global.debug_log("中年属性递减：%d%%" % int(penalty_rate * 100.0))
	elif current_stage == Stage.OLD_AGE:
		# 老年：每年属性 -1%
		var years_old = current_age - STAGE_AGES[Stage.OLD_AGE].start
		var penalty_rate: float = 1.0 - (years_old * 0.01)
		
		for attr in session.attributes:
			session.attributes[attr] = maxi(int(float(session.attributes[attr]) * penalty_rate), 1)
		
		Global.debug_log("老年属性递减：%d%%" % int(penalty_rate * 100.0))

## 应用老年属性递减（已废弃，保留兼容）
func apply_old_age_penalty() -> void:
	apply_age_penalty()
