## NPC 数据 Bean。承载非玩家角色的关系、好感和生命状态。
## NPC 在事件系统中参与条件判断和动态权重计算。
class_name NPCData
extends Resource

## NPC 唯一标识，如 npc_father/npc_mother/npc_friend
@export var npc_id: String = ""
## 翻译键，通过 tr() 获取本地化名称
@export var name: String = ""
## 关系类型：family/friend/mentor/colleague/spouse/other
@export var relation_type: String = ""
## 好感度 0~100，影响事件权重（>70 加权，<30 降权）
@export var affection: int = 50
## 健康值，归零可能触发相关事件
@export var health: int = 100
## 生命阶段：child/youth/adult/middle_age/elderly
@export var life_stage: String = ""
## 年龄，随玩家年龄同步增长
@export var age: int = 0
## 是否活跃（死亡/离场后设为 false）
@export var is_active: bool = true

@export var willpower: int = 50
@export var craziness: int = 50
@export var generosity: int = 50
@export var loyalty: int = 50
@export var ambition: int = 50
@export var wealth: int = 0
@export var trust: int = 50

## 序列化为字典
func to_dict() -> Dictionary:
	return {
		"npc_id": npc_id,
		"name": name,
		"relation_type": relation_type,
		"affection": affection,
		"health": health,
		"life_stage": life_stage,
		"age": age,
		"is_active": is_active,
		"willpower": willpower,
		"craziness": craziness,
		"generosity": generosity,
		"loyalty": loyalty,
		"ambition": ambition,
		"wealth": wealth,
		"trust": trust
	}

## 从 JSON 字典反序列化为 NPCData 实例
static func from_dict(data: Dictionary) -> NPCData:
	var npc := NPCData.new()
	npc.npc_id = str(data.get("npc_id", ""))
	npc.name = str(data.get("name", ""))
	npc.relation_type = str(data.get("relation_type", ""))
	npc.affection = int(data.get("affection", 50))
	npc.health = int(data.get("health", 100))
	npc.life_stage = str(data.get("life_stage", ""))
	npc.age = int(data.get("age", 0))
	npc.is_active = bool(data.get("is_active", true))
	npc.willpower = int(data.get("willpower", 50))
	npc.craziness = int(data.get("craziness", 50))
	npc.generosity = int(data.get("generosity", 50))
	npc.loyalty = int(data.get("loyalty", 50))
	npc.ambition = int(data.get("ambition", 50))
	npc.wealth = int(data.get("wealth", 0))
	npc.trust = int(data.get("trust", 50))
	return npc
