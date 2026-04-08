extends Node2D

## 战斗配置
@export var total_waves: int = 1
@export var enemy_to_spawn_per_wave: int = 5

## 老家节点
@export var home_node: Node2D

## 防御塔容器
@onready var towers_container: Node = $Towers

## 敌人生成器
@onready var enemy_spawner: EnemySpawner = $EnemySpawner

## 战斗管理器
var battle_manager: BattleManager

func _ready() -> void:
	_initialize_battle_manager()
	_setup_signals()
	_initialize_wave()

func _initialize_battle_manager() -> void:
	battle_manager = BattleManager.new()
	battle_manager.total_waves = total_waves
	add_child(battle_manager)

func _setup_signals() -> void:
	if enemy_spawner:
		enemy_spawner.enemy_died.connect(_on_enemy_died)

func _initialize_wave() -> void:
	# 配置第一波敌人
	if enemy_spawner:
		enemy_spawner.enemies_to_spawn = enemy_to_spawn_per_wave

func _on_enemy_died(enemy: Enemy, reward_gold: int) -> void:
	battle_manager.on_enemy_died(enemy, reward_gold)

func start_battle() -> void:
	battle_manager.start_battle()

func get_battle_manager() -> BattleManager:
	return battle_manager
