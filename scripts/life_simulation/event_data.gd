class_name EventData
extends Resource

## 事件 ID
@export var event_id: String = ""

## 事件名称
@export var event_name: String = ""

## 触发年龄
@export var age: int = 0

## 触发阶段（童年/青年/中年）
@export var stage: String = ""

## 事件描述
@export var description: String = ""

## 选项列表
@export var options: Array[Dictionary] = []

## 是否致命事件
@export var is_deadly: bool = false

## 触发概率（0-1）
@export var trigger_chance: float = 1.0

## 序列化为 Dictionary
func to_dict() -> Dictionary:
	return {
		"event_id": event_id,
		"event_name": event_name,
		"age": age,
		"stage": stage,
		"description": description,
		"options": options,
		"is_deadly": is_deadly,
		"trigger_chance": trigger_chance
	}

## 从 Dictionary 反序列化
static func from_dict(data: Dictionary) -> EventData:
	var event = EventData.new()
	event.event_id = data.get("event_id", "")
	event.event_name = data.get("event_name", "")
	event.age = data.get("age", 0)
	event.stage = data.get("stage", "")
	event.description = data.get("description", "")
	event.options = data.get("options", [])
	event.is_deadly = data.get("is_deadly", false)
	event.trigger_chance = data.get("trigger_chance", 1.0)
	return event
