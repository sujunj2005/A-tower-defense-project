## 事件数据 Bean。承载单个人生事件的完整配置，由 [method from_dict] 从 events.json 反序列化。
## 事件是人生模拟的核心驱动：每回合触发一个事件，玩家选择选项后推进年龄和状态。
class_name EventData
extends Resource

## 唯一标识符，对应 events.json 中的 event_id
@export var event_id: String = ""
## 翻译键，通过 [method get_display_name] 获取本地化名称
@export var event_name: String = ""
## 可触发的年龄列表，不在列表中的年龄不会出现此事件
@export var ages: Array[int] = []
## 人生阶段：childhood/youth/middle_age/old_age
@export var stage: String = ""
## 翻译键，通过 [method get_display_desc] 获取本地化描述
@export var description: String = ""
## 选项列表，玩家从中选择一个
@export var options: Array[OptionData] = []
## 致命事件：失败直接触发人生结局
@export var is_deadly: bool = false
## 事件链前置条件：flag:xxx 表示需要 chain_flag，否则需要已完成事件 ID
@export var chain_prerequisites: Array[String] = []
## 事件链互斥：已完成这些事件中的任一个则不触发
@export var chain_excludes: Array[String] = []
## 条件列表，统一承载所有触发条件：
## - attribute/trait/trait_absent/npc_relation/profession/profession_absent
## - trigger_chance: {"type":"trigger_chance","value":0.3}
## - family_member: {"type":"family_member","member":"father"}
## - required_family: {"type":"required_family","families":["family_farmer"]}
@export var conditions: Array[Dictionary] = []
## 基础权重，用于加权随机选取
@export var event_weight: float = 1.0
@export var karma_type: String = "neutral"
@export var personality_checks: Dictionary = {}
@export var related_npcs: Array[String] = []
@export var tension_category: String = ""
@export var trait_boosts: Dictionary = {}
@export var rarity: String = "common"
@export var tension_duration: int = 0

func to_dict() -> Dictionary:
	var opts: Array[Dictionary] = []
	for opt: OptionData in options:
		opts.append(opt.to_dict())
	return {
		"event_id": event_id,
		"event_name": event_name,
		"ages": ages,
		"stage": stage,
		"description": description,
		"options": opts,
		"is_deadly": is_deadly,
		"chain_prerequisites": chain_prerequisites,
		"chain_excludes": chain_excludes,
		"conditions": conditions,
		"event_weight": event_weight,
		"karma_type": karma_type,
		"personality_checks": personality_checks,
		"related_npcs": related_npcs,
		"tension_category": tension_category,
		"trait_boosts": trait_boosts,
		"rarity": rarity,
		"tension_duration": tension_duration
	}

static func from_dict(data: Dictionary) -> EventData:
	var event := EventData.new()
	event.event_id = str(data.get("event_id", ""))
	event.event_name = str(data.get("event_name", ""))
	var raw_ages = data.get("ages", [])
	for a in raw_ages:
		event.ages.append(int(a))
	event.stage = str(data.get("stage", ""))
	event.description = str(data.get("description", ""))
	var raw_options = data.get("options", [])
	for opt in raw_options:
		if opt is OptionData:
			event.options.append(opt)
		elif opt is Dictionary:
			event.options.append(OptionData.from_dict(opt))
	event.is_deadly = bool(data.get("is_deadly", false))
	var raw_prereqs = data.get("chain_prerequisites", [])
	for p in raw_prereqs:
		event.chain_prerequisites.append(str(p))
	var raw_excludes = data.get("chain_excludes", [])
	for e in raw_excludes:
		event.chain_excludes.append(str(e))
	var raw_conditions: Array = data.get("conditions", [])
	event.conditions.clear()
	for c: Dictionary in raw_conditions:
		event.conditions.append(c)
	event.event_weight = float(data.get("event_weight", 1.0))
	event.karma_type = str(data.get("karma_type", "neutral"))
	event.personality_checks = Dictionary(data.get("personality_checks", {}))
	event.related_npcs.clear()
	for npc_id in data.get("related_npcs", []):
		event.related_npcs.append(str(npc_id))
	event.tension_category = str(data.get("tension_category", ""))
	event.trait_boosts = Dictionary(data.get("trait_boosts", {}))
	event.rarity = str(data.get("rarity", "common"))
	event.tension_duration = int(data.get("tension_duration", 0))
	return event

## 从 conditions 中提取触发概率，默认 1.0
func get_trigger_chance() -> float:
	for cond: Dictionary in conditions:
		if cond.get("type", "") == "trigger_chance":
			return float(cond.get("value", 1.0))
	return 1.0

## 从 conditions 中提取关联家庭成员
func get_family_member() -> String:
	for cond: Dictionary in conditions:
		if cond.get("type", "") == "family_member":
			return str(cond.get("member", ""))
	return ""

## 从 conditions 中提取需要的家庭背景
func get_required_family() -> Array[String]:
	for cond: Dictionary in conditions:
		if cond.get("type", "") == "required_family":
			var result: Array[String] = []
			for f in cond.get("families", []):
				result.append(str(f))
			return result
	var empty: Array[String] = []
	return empty

## 返回本地化后的事件名称
func get_display_name() -> String:
	return tr(event_name)

## 返回本地化后的事件描述
func get_display_desc() -> String:
	return tr(description)
