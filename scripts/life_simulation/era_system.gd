class_name EraSystem
extends Node

## 当前选择的时代配置
var current_era: Dictionary = {}

## 当前选择的家境配置
var current_family: Dictionary = {}

## 当前选择的地域
var current_region: String = "tier2_city"

var config_manager: ConfigManager
var session: GameSessionData

func _ready() -> void:
	config_manager = Global.get_node("ConfigManager") as ConfigManager
	session = Global.get_game_session()

## 加载时代配置
func load_era(era_id: String) -> Error:
	var eras_data = config_manager.load_json("res://data/eras.json")
	if not eras_data.has("eras"):
		return ERR_DOES_NOT_EXIST
	
	for era in eras_data.eras:
		if era.era_id == era_id:
			current_era = era
			return OK
	
	return ERR_DOES_NOT_EXIST

## 加载家境配置
func load_family(family_id: String) -> Error:
	var families_data = config_manager.load_json("res://data/family_backgrounds.json")
	if not families_data.has("family_backgrounds"):
		return ERR_DOES_NOT_EXIST
	
	for family in families_data.family_backgrounds:
		if family.family_id == family_id:
			current_family = family
			return OK
	
	return ERR_DOES_NOT_EXIST

## 初始化单局数据
func initialize_session() -> void:
	session.era_id = current_era.get("era_id", "china_modern")
	session.family_background = current_family.get("family_id", "worker")
	session.region = current_region
	
	# 应用家境初始资源
	if current_family.has("initial_resources"):
		var initial_res = current_family.initial_resources
		session.gold = initial_res.get("gold", 50)
		
		# 应用初始塔
		if initial_res.has("towers"):
			for tower in initial_res.towers:
				session.towers.append(tower)
		
		# 应用初始词条
		if initial_res.has("traits"):
			for trait in initial_res.traits:
				session.traits.append(trait)

## 获取家境加成
func get_family_modifier(modifier_type: String) -> float:
	if current_family.has("modifiers"):
		return current_family.modifiers.get(modifier_type, 0.0)
	return 0.0

## 应用家境加成到金币
func apply_gold_bonus(base_gold: int) -> int:
	var bonus = get_family_modifier("gold_bonus")
	return int(base_gold * (1.0 + bonus))
