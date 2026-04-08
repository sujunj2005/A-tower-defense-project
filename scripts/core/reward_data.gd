class_name RewardData
extends Resource

## 奖励类型（tower/trait/gold/attribute）
@export var reward_type: String = ""

## 奖励 ID（塔 ID 或词条 ID）
@export var id: String = ""

## 奖励数量
@export var count: int = 1

## 属性名称（仅 attribute 类型使用）
@export var attribute: String = ""

## 序列化为 Dictionary
func to_dict() -> Dictionary:
	return {
		"type": reward_type,
		"id": id,
		"count": count,
		"attribute": attribute
	}

## 从 Dictionary 反序列化
static func from_dict(data: Dictionary) -> RewardData:
	var reward = RewardData.new()
	reward.reward_type = data.get("type", "")
	reward.id = data.get("id", "")
	reward.count = data.get("count", 1)
	reward.attribute = data.get("attribute", "")
	return reward
