extends Node2D

@export var total_waves: int = 1
@export var enemy_to_spawn_per_wave: int = 5

@export var home_node: Node2D

var towers_container: Node2D
var enemy_spawner: Node
var battle_manager: Node
var _game_hud: CanvasLayer

func _ready() -> void:
	_create_scene_structure()
	_initialize_battle_manager()
	_setup_signals()
	_initialize_wave()

func _create_scene_structure() -> void:
	towers_container = Node2D.new()
	towers_container.name = "Towers"
	add_child(towers_container)

	enemy_spawner = Node.new()
	enemy_spawner.name = "EnemySpawner"
	enemy_spawner.set_script(load("res://scripts/enemy_spawner.gd"))
	add_child(enemy_spawner)

	_game_hud = CanvasLayer.new()
	_game_hud.name = "GameHUD"
	_game_hud.set_script(load("res://scripts/ui/game_hud.gd"))
	add_child(_game_hud)

func _initialize_battle_manager() -> void:
	var bm_script: GDScript = load("res://scripts/battle/battle_manager.gd")
	battle_manager = Node.new()
	battle_manager.name = "BattleManager"
	battle_manager.set_script(bm_script)
	battle_manager.total_waves = total_waves
	add_child(battle_manager)
	battle_manager.battle_ended.connect(_on_battle_ended)

func _setup_signals() -> void:
	if enemy_spawner and enemy_spawner.has_signal("enemy_reached_base"):
		enemy_spawner.enemy_reached_base.connect(_on_enemy_reached_base)
	if enemy_spawner and enemy_spawner.has_signal("enemy_died"):
		enemy_spawner.enemy_died.connect(_on_enemy_died)

func _initialize_wave() -> void:
	pass

func _on_enemy_reached_base(_enemy: Node2D) -> void:
	if battle_manager and battle_manager.has_method("home_take_damage"):
		var damage: float = 1.0
		if _enemy and _enemy.has_method("get_damage"):
			damage = float(_enemy.get_damage())
		battle_manager.home_take_damage(damage)

func _on_enemy_died(enemy: Node2D, reward_gold: int) -> void:
	if battle_manager and battle_manager.has_method("on_enemy_died"):
		battle_manager.on_enemy_died(enemy, reward_gold)

func start_battle() -> void:
	if battle_manager and battle_manager.has_method("start_battle"):
		battle_manager.start_battle()

func get_battle_manager() -> Node:
	return battle_manager

func _on_battle_ended(victory: bool) -> void:
	var session: GameSessionData = Global.get_game_session()
	session.current_battle_victory = victory
	if victory and battle_manager:
		if "home_health" in battle_manager:
			session.home_health = battle_manager.home_health
		if "gold" in battle_manager:
			session.gold = battle_manager.gold
	GameState.change_state(GameState.State.RESULT)
