class_name RewardData
extends Resource

@export var reward_type: String = ""
@export var id: String = ""
@export var count: int = 1
@export var attribute: String = ""
@export var value: int = 0

func to_dict() -> Dictionary:
	return {
		"type": reward_type,
		"id": id,
		"count": count,
		"attribute": attribute,
		"value": value
	}

static func from_dict(data: Dictionary) -> RewardData:
	var reward = RewardData.new()
	reward.reward_type = data.get("type", "")
	reward.id = data.get("id", "")
	reward.count = data.get("count", 1)
	reward.attribute = data.get("attribute", "")
	reward.value = data.get("value", 0)
	return reward
