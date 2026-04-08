class_name BattleManager
extends Node

## 战斗状态
enum BattleState {
	WAITING,
	IN_PROGRESS,
	VICTORY,
	DEFEAT
}

## 战斗结束信号
signal battle_ended(victory: bool)

## 敌人死亡信号
signal enemy_died(enemy: Enemy, reward_gold: int)

## 老家生命值变化信号
signal home_health_changed(current: float, max_value: float)

var battle_state: BattleState = BattleState.WAITING

## 老家生命值
var home_health: float = 100.0
var max_home_health: float = 100.0

## 金币
var gold: int = 50

## 波次管理
var current_wave: int = 1
var total_waves: int = 1  # 垂直切片只有 1 波

## 敌人生成器
var enemy_spawner: EnemySpawner

## 游戏会话数据
var session: GameSessionData

func _ready() -> void:
	session = Global.get_game_session()
	_initialize_battle()

func _initialize_battle() -> void:
	# 从会话数据初始化战斗
	if session:
		home_health = session.home_health
		max_home_health = session.max_home_health
		gold = session.gold
	
	# 获取敌人生成器
	enemy_spawner = get_node_or_null("EnemySpawner")
	if not enemy_spawner:
		push_warning("BattleManager: EnemySpawner not found")

## 开始战斗
func start_battle() -> void:
	if battle_state != BattleState.WAITING:
		return
	
	battle_state = BattleState.IN_PROGRESS
	Global.debug_log("战斗开始！波次 %d/%d" % [current_wave, total_waves])
	
	# 开始生成敌人
	if enemy_spawner:
		enemy_spawner.start_spawning()

## 敌人死亡处理
func on_enemy_died(enemy: Enemy, reward_gold: int) -> void:
	gold += reward_gold
	enemy_died.emit(enemy, reward_gold)
	
	Global.debug_log("敌人死亡，获得金币：%d，当前金币：%d" % [reward_gold, gold])
	
	# 检查是否所有敌人都被消灭
	_check_wave_completion()

## 老家受到伤害
func home_take_damage(amount: float) -> void:
	home_health = maxf(home_health - amount, 0.0)
	home_health_changed.emit(home_health, max_home_health)
	
	# 更新会话数据
	if session:
		session.home_health = home_health
	
	Global.debug_log("老家受到攻击！剩余生命：%d/%d" % [int(home_health), int(max_home_health)])
	
	# 检查失败
	if home_health <= 0.0:
		_on_defeat()

## 检查波次完成
func _check_wave_completion() -> void:
	if not enemy_spawner:
		return
	
	# 检查是否还有活跃敌人
	var active_enemies = enemy_spawner.get_active_enemies()
	if active_enemies.is_empty() and enemy_spawner.is_wave_complete():
		_on_victory()

## 胜利
func _on_victory() -> void:
	if battle_state != BattleState.IN_PROGRESS:
		return
	
	battle_state = BattleState.VICTORY
	Global.debug_log("战斗胜利！")
	
	# 更新会话数据
	if session:
		session.gold = gold
		session.completed_battles.append("battle_wave_%d" % current_wave)
	
	battle_ended.emit(true)

## 失败
func _on_defeat() -> void:
	if battle_state != BattleState.IN_PROGRESS:
		return
	
	battle_state = BattleState.DEFEAT
	Global.debug_log("战斗失败！")
	
	# 更新会话数据
	if session:
		session.home_health = 0.0
	
	battle_ended.emit(false)

## 放置防御塔
func place_tower(tower_scene: PackedScene, position: Vector2) -> Tower:
	if not tower_scene:
		push_error("BattleManager: tower_scene is null")
		return null
	
	var tower = tower_scene.instantiate() as Tower
	if not tower:
		push_error("BattleManager: Failed to instantiate tower")
		return null
	
	# 添加到场景
	get_node("Towers").add_child(tower)
	tower.global_position = position
	
	Global.debug_log("放置防御塔：%s" % tower.name)
	return tower

## 获取当前金币
func get_gold() -> int:
	return gold

## 消耗金币
func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		if session:
			session.gold = gold
		return true
	return false

## 获取老家生命值百分比
func get_home_health_percent() -> float:
	return home_health / max_home_health
