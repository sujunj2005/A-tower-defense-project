class_name TraitSystem
extends Node

var session: GameSessionData
var trait_configs: Dictionary = {}

func _ready() -> void:
	session = Global.get_game_session()
	_load_trait_configs()

func _load_trait_configs() -> void:
	# 从配置加载词条效果
	# 后续从 data/traits.json 读取
	trait_configs = {
		"little_singer": {
			"name": "小歌唱家",
			"description": "幼儿园表演表现出色",
			"effect": {"tower_damage_bonus": 0.1, "tower_types": ["语文塔"]}
		},
		"math_genius": {
			"name": "数学天才",
			"description": "数学竞赛获奖",
			"effect": {"tower_damage_bonus": 0.2, "tower_types": ["数学塔"]}
		}
	}

## 授予词条
func grant_trait(trait_id: String) -> void:
	if not trait_id in session.traits:
		session.traits.append(trait_id)
		_apply_trait_effect(trait_id)
		Global.debug_log("获得词条：%s" % trait_id)

## 应用词条效果
func _apply_trait_effect(trait_id: String) -> void:
	if not trait_configs.has(trait_id):
		return
	
	var config = trait_configs[trait_id]
	if config.has("effect"):
		# 应用词条效果
		# 后续根据效果类型应用不同的增益
		pass

## 移除词条
func remove_trait(trait_id: String) -> void:
	if trait_id in session.traits:
		session.traits.erase(trait_id)
		Global.debug_log("移除词条：%s" % trait_id)

## 检查是否拥有词条
func has_trait(trait_id: String) -> bool:
	return trait_id in session.traits

## 获取所有词条
func get_all_traits() -> Array:
	return session.traits.duplicate()

## 获取词条配置
func get_trait_config(trait_id: String) -> Dictionary:
	return trait_configs.get(trait_id, {})
