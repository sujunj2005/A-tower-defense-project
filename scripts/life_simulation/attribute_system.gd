class_name AttributeSystem
extends Node

const ATTRIBUTES := ["intelligence", "courage", "health", "reputation"]

var session: GameSessionData
var age_system: AgeSystem

func _ready() -> void:
	session = Global.get_game_session()
	age_system = Global.get_node("AgeSystem") as AgeSystem

## 增加属性
func increase_attribute(attr_name: String, amount: int) -> void:
	if session.attributes.has(attr_name):
		session.attributes[attr_name] += amount
		Global.debug_log("属性 %s 增加 %d，当前值：%d" % [attr_name, amount, session.attributes[attr_name]])

## 减少属性
func decrease_attribute(attr_name: String, amount: int) -> void:
	increase_attribute(attr_name, -amount)

## 获取属性值
func get_attribute(attr_name: String) -> int:
	return session.attributes.get(attr_name, 0)

## 设置属性值
func set_attribute(attr_name: String, value: int) -> void:
	if session.attributes.has(attr_name):
		session.attributes[attr_name] = value

## 获取所有属性
func get_all_attributes() -> Dictionary:
	return session.attributes.duplicate()

## 检查属性是否满足要求
func check_requirement(attr_name: String, required_value: int) -> bool:
	return get_attribute(attr_name) >= required_value

## 应用老年属性递减
func apply_old_age_penalty() -> void:
	if age_system and age_system.current_stage == AgeSystem.Stage.OLD_AGE:
		age_system.apply_old_age_penalty()
