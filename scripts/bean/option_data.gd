## 选项数据 Bean。承载事件选项的完整配置，包括需求、奖励、后果和触发条件。
## 一个事件包含多个选项，玩家选择后由 EventSystem.select_option() 执行后果。
class_name OptionData
extends Resource

## 所属事件 ID
@export var event_id: String = ""
## 选项唯一标识
@export var option_id: String = ""
## 翻译键，通过 [method get_display_text] 获取本地化文本
@export var text: String = ""
## 选择需求：trait/gold/family_background/education/chain_flag/family_member_alive 等
@export var requirements: Dictionary = {}
## 奖励列表，每项含 type(tower/trait/gold/attribute) 和对应 id/value/count
@export var rewards: Array[Dictionary] = []
## 消耗，如 {"gold": -50, "health": -10}
@export var cost: Dictionary = {}
## 战斗触发配置，含 battle_id/is_deadly/force_map_id，不含 waves
@export var battle_trigger: Variant = null
## 地图权重偏移，选择后影响下次战斗的地图选取概率
@export var map_weights: Dictionary = {}
## 强制指定战斗地图 ID
@export var force_map_id: String = ""
## 战斗修改器，如难度倍率、额外波次等
@export var battle_modifiers: Array[Dictionary] = []
## 是否触发人生结局
@export var triggers_ending: bool = false
## 结局原因翻译键
@export var ending_reason: String = ""
## 事件链标记，选择后写入 session.chain_flags 供后续事件检查
@export var chain_flag: String = ""
## 家庭成员效果，Dictionary 或 Array，如出生/死亡/相遇
@export var family_effect: Variant = {}
## 属性变化，如 {"intelligence": 5, "health": -10}
@export var attribute_changes: Dictionary = {}
## 获得的词条 ID 列表
@export var trait_gains: Array[String] = []
## 失去的词条 ID 列表
@export var trait_losses: Array[String] = []
## 职业变更 ID，空字符串表示不变
@export var profession_change: String = ""
## 是否失去当前职业
@export var profession_lost: bool = false
## NPC 好感度变化列表，每项含 npc_id/value/name/relation_type
@export var npc_relation_changes: Array[Dictionary] = []
## 获得的防御塔 ID 列表
@export var tower_gains: Array[String] = []
## 失去的防御塔 ID 列表
@export var tower_losses: Array[String] = []
## 金币变化（正=获得，负=失去）
@export var gold_change: int = 0
## 解锁的事件 ID 列表
@export var unlock_events: Array[String] = []
## 锁定的事件 ID 列表
@export var lock_events: Array[String] = []
@export var karma_cost: int = 0
@export var world_changes: Dictionary = {}
@export var tension_changes: Array[Dictionary] = []

func to_dict() -> Dictionary:
	var result: Dictionary = {
		"option_id": option_id,
		"text": text,
		"requirements": requirements,
		"rewards": rewards,
	}
	if not cost.is_empty():
		result["cost"] = cost
	if battle_trigger is Dictionary and not battle_trigger.is_empty():
		result["battle_trigger"] = battle_trigger
	if triggers_ending:
		result["triggers_ending"] = true
		result["ending_reason"] = ending_reason
	if chain_flag != "":
		result["chain_flag"] = chain_flag
	if not map_weights.is_empty():
		result["map_weights"] = map_weights
	if force_map_id != "":
		result["force_map_id"] = force_map_id
	if not battle_modifiers.is_empty():
		result["battle_modifiers"] = battle_modifiers
	var fx = family_effect
	if fx is Dictionary and not fx.is_empty():
		result["family_effect"] = fx
	elif fx is Array and not fx.is_empty():
		result["family_effect"] = fx
	if not attribute_changes.is_empty():
		result["attribute_changes"] = attribute_changes
	if not trait_gains.is_empty():
		result["trait_gains"] = trait_gains
	if not trait_losses.is_empty():
		result["trait_losses"] = trait_losses
	if profession_change != "":
		result["profession_change"] = profession_change
	if profession_lost:
		result["profession_lost"] = true
	if not npc_relation_changes.is_empty():
		result["npc_relation_changes"] = npc_relation_changes
	if not tower_gains.is_empty():
		result["tower_gains"] = tower_gains
	if not tower_losses.is_empty():
		result["tower_losses"] = tower_losses
	if gold_change != 0:
		result["gold_change"] = gold_change
	if not unlock_events.is_empty():
		result["unlock_events"] = unlock_events
	if not lock_events.is_empty():
		result["lock_events"] = lock_events
	if karma_cost != 0:
		result["karma_cost"] = karma_cost
	if not world_changes.is_empty():
		result["world_changes"] = world_changes
	if not tension_changes.is_empty():
		result["tension_changes"] = tension_changes
	return result

static func from_dict(data: Dictionary) -> OptionData:
	var opt := OptionData.new()
	opt.event_id = str(data.get("event_id", ""))
	opt.option_id = str(data.get("option_id", ""))
	opt.text = str(data.get("text", ""))
	opt.requirements = Dictionary(data.get("requirements", {}))
	var raw_rewards = data.get("rewards", [])
	for r in raw_rewards:
		opt.rewards.append(Dictionary(r))
	opt.cost = Dictionary(data.get("cost", {}))
	var bt = data.get("battle_trigger", null)
	if bt is Dictionary:
		opt.battle_trigger = bt
	opt.triggers_ending = bool(data.get("triggers_ending", false))
	opt.ending_reason = str(data.get("ending_reason", ""))
	opt.chain_flag = str(data.get("chain_flag", ""))
	opt.map_weights = Dictionary(data.get("map_weights", {}))
	opt.force_map_id = str(data.get("force_map_id", ""))
	var raw_mods: Array = data.get("battle_modifiers", [])
	opt.battle_modifiers.clear()
	for m: Dictionary in raw_mods:
		opt.battle_modifiers.append(m)
	var raw_fx = data.get("family_effect", {})
	if raw_fx is Array:
		opt.family_effect = raw_fx
	else:
		opt.family_effect = Dictionary(raw_fx)
	opt.attribute_changes = Dictionary(data.get("attribute_changes", {}))
	opt.trait_gains.clear()
	for item in data.get("trait_gains", []):
		opt.trait_gains.append(str(item))
	opt.trait_losses.clear()
	for item in data.get("trait_losses", []):
		opt.trait_losses.append(str(item))
	opt.profession_change = str(data.get("profession_change", ""))
	opt.profession_lost = bool(data.get("profession_lost", false))
	var raw_npc_changes: Array = data.get("npc_relation_changes", [])
	opt.npc_relation_changes.clear()
	for nc: Dictionary in raw_npc_changes:
		opt.npc_relation_changes.append(nc)
	opt.tower_gains.clear()
	for item in data.get("tower_gains", []):
		opt.tower_gains.append(str(item))
	opt.tower_losses.clear()
	for item in data.get("tower_losses", []):
		opt.tower_losses.append(str(item))
	opt.gold_change = int(data.get("gold_change", 0))
	opt.unlock_events.clear()
	for item in data.get("unlock_events", []):
		opt.unlock_events.append(str(item))
	opt.lock_events.clear()
	for item in data.get("lock_events", []):
		opt.lock_events.append(str(item))
	opt.karma_cost = int(data.get("karma_cost", 0))
	opt.world_changes = Dictionary(data.get("world_changes", {}))
	opt.tension_changes.clear()
	for tc: Dictionary in data.get("tension_changes", []):
		opt.tension_changes.append(tc)
	return opt

## 返回本地化后的选项文本
func get_display_text() -> String:
	return tr(text)
