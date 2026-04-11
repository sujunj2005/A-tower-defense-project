class_name TowerData
extends Resource

## 防御塔 ID
@export var tower_id: String = ""

## 防御塔名称
@export var tower_name: String = ""

## 塔类型（学科塔/技能塔）
@export var tower_type: String = ""

## 塔等级（基础/高级/大师）
@export var tier: String = ""

## 战斗属性
@export var damage: float = 0.0
@export var attack_speed: float = 1.0
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 100.0
@export var projectile_speed: float = 300.0
@export var damage_type: String = "none"  # none/physical/magic

## 特殊效果
@export var special_effect: Dictionary = {}

## 等级
@export var level: int = 1
@export var exp: int = 0

## 序列化为 Dictionary
func to_dict() -> Dictionary:
	return {
		"tower_id": tower_id,
		"tower_name": tower_name,
		"tower_type": tower_type,
		"tier": tier,
		"damage": damage,
		"attack_speed": attack_speed,
		"attack_cooldown": attack_cooldown,
		"range": attack_range,
		"projectile_speed": projectile_speed,
		"damage_type": damage_type,
		"special_effect": special_effect,
		"level": level,
		"exp": exp
	}

## 从 Dictionary 反序列化
static func from_dict(data: Dictionary) -> TowerData:
	var tower = TowerData.new()
	tower.tower_id = data.get("tower_id", "")
	tower.tower_name = data.get("tower_name", "")
	tower.tower_type = data.get("tower_type", "")
	tower.tier = data.get("tier", "")
	tower.damage = data.get("damage", 0.0)
	tower.attack_speed = data.get("attack_speed", 1.0)
	tower.attack_cooldown = data.get("attack_cooldown", 1.0)
	tower.attack_range = data.get("range", 100.0)
	tower.projectile_speed = data.get("projectile_speed", 300.0)
	tower.damage_type = data.get("damage_type", "none")
	tower.special_effect = data.get("special_effect", {})
	tower.level = data.get("level", 1)
	tower.exp = data.get("exp", 0)
	return tower

## 升级
func level_up() -> void:
	level += 1
	exp = 0

## 添加经验
func add_exp(amount: int) -> void:
	exp += amount
	# 简单升级逻辑：每 100 经验升一级
	while exp >= 100:
		exp -= 100
		level_up()
