class_name EnemyData
extends Resource

## 敌人 ID
@export var enemy_id: String = ""

## 敌人名称
@export var enemy_name: String = ""

## 敌人类型（学业压力/经济压力/社会压力/健康问题）
@export var enemy_type: String = ""

## 敌人等级（基础/精英/BOSS）
@export var tier: String = ""

## 战斗属性
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var speed: float = 50.0
@export var armor: int = 0
@export var armor_type: String = "none"  # none/light/heavy
@export var damage: float = 10.0
@export var attack_speed: float = 1.0
@export var attack_range: float = 20.0

## 击杀奖励
@export var kill_reward_gold: int = 10

## 特殊能力
@export var special_abilities: Array[Dictionary] = []

## 生成阶段
@export var spawn_stages: Array[String] = []

## 生成波次
@export var spawn_waves: Array[int] = []

## 当前血量
var current_health: float = 100.0

## 序列化为 Dictionary
func to_dict() -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"enemy_name": enemy_name,
		"enemy_type": enemy_type,
		"tier": tier,
		"health": health,
		"max_health": max_health,
		"speed": speed,
		"armor": armor,
		"armor_type": armor_type,
		"damage": damage,
		"attack_speed": attack_speed,
		"attack_range": attack_range,
		"kill_reward_gold": kill_reward_gold,
		"special_abilities": special_abilities,
		"spawn_stages": spawn_stages,
		"spawn_waves": spawn_waves
	}

## 从 Dictionary 反序列化
static func from_dict(data: Dictionary) -> EnemyData:
	var enemy = EnemyData.new()
	enemy.enemy_id = data.get("enemy_id", "")
	enemy.enemy_name = data.get("enemy_name", "")
	enemy.enemy_type = data.get("enemy_type", "")
	enemy.tier = data.get("tier", "")
	enemy.health = data.get("health", 100.0)
	enemy.max_health = data.get("max_health", 100.0)
	enemy.speed = data.get("speed", 50.0)
	enemy.armor = data.get("armor", 0)
	enemy.armor_type = data.get("armor_type", "none")
	enemy.damage = data.get("damage", 10.0)
	enemy.attack_speed = data.get("attack_speed", 1.0)
	enemy.attack_range = data.get("attack_range", 20.0)
	enemy.kill_reward_gold = data.get("kill_reward_gold", 10)
	enemy.special_abilities = data.get("special_abilities", [])
	enemy.spawn_stages = data.get("spawn_stages", [])
	enemy.spawn_waves = data.get("spawn_waves", [])
	enemy.current_health = enemy.max_health
	return enemy

## 受到伤害
func take_damage(amount: float) -> float:
	# 计算护甲减伤
	var damage_reduction = 0.0
	match armor_type:
		"light":
			damage_reduction = 0.2
		"heavy":
			damage_reduction = 0.4
	
	var actual_damage = amount * (1.0 - damage_reduction)
	current_health = maxf(current_health - actual_damage, 0.0)
	return actual_damage

## 是否死亡
func is_dead() -> bool:
	return current_health <= 0.0

## 重置血量
func reset_health() -> void:
	current_health = max_health
