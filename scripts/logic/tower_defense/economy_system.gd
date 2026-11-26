## 经济系统。管理金币收支、利息计算、战斗评级奖励和塔奖励发放。
## 作为 Autoload 全局单例运行，通过信号通知 UI 金币变化。
extends Node

signal gold_changed(new_gold: int)
signal salary_earned(amount: int)

var session: GameSessionData
var _balance_config: Dictionary = {}

const RATING_GOLD_REWARDS: Dictionary = {
	"S": 100,
	"A": 80,
	"B": 60,
	"C": 40,
	"D": 0
}

const RATING_TOWER_PROBABILITIES: Dictionary = {
	"S": 1.0,
	"A": 0.6,
	"B": 0.4,
	"C": 0.0,
	"D": 0.0
}

func _ready() -> void:
	session = Global.get_game_session()
	_load_balance_config()
	Global.session_reset.connect(_on_session_reset)

func _on_session_reset() -> void:
	session = Global.get_game_session()

func _get_config_manager() -> Node:
	return get_node_or_null("/root/ConfigManager")

func _get_age_system() -> Node:
	return get_node_or_null("/root/AgeSystem")

func _load_balance_config() -> void:
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return
	_balance_config = cm.load_json("res://data/economy_balance.json")

func calculate_salary() -> int:
	if session.current_profession == "":
		return 0
	var cm: Node = _get_config_manager()
	if not cm or not cm.has_method("load_json"):
		return 0
	var prof_data = cm.load_json("res://data/professions.json")
	if not prof_data is Dictionary or not prof_data.has("professions"):
		return 0
	for prof: Dictionary in prof_data.professions:
		if prof.get("profession_id", "") == session.current_profession:
			return int(prof.get("salary", 0))
	return 0

func apply_salary() -> int:
	var salary: int = calculate_salary()
	if salary > 0:
		session.gold += salary
		gold_changed.emit(session.gold)
		salary_earned.emit(salary)
		Global.debug_log("薪资收入：%d 金币（职业：%s）" % [salary, session.current_profession])
	return salary

func get_rating_gold_reward(rating: String) -> int:
	return RATING_GOLD_REWARDS.get(rating, 0)

func apply_rating_gold_reward(rating: String) -> int:
	var reward: int = get_rating_gold_reward(rating)
	if reward > 0:
		session.gold += reward
		gold_changed.emit(session.gold)
		Global.debug_log("评价奖励：%d 金币（评级 %s）" % [reward, rating])
	return reward

func roll_tower_reward(rating: String) -> bool:
	var probability: float = RATING_TOWER_PROBABILITIES.get(rating, 0.0)
	if probability <= 0.0:
		return false
	var roll: float = randf()
	var granted: bool = roll <= probability
	Global.debug_log("出塔概率：%.0f%%，掷骰：%.2f，结果：%s" % [probability * 100.0, roll, "获得" if granted else "未获得"])
	return granted

func get_random_tower_for_stage() -> String:
	var cm: Node = _get_config_manager()
	if not cm:
		return ""
	var stages_data: Dictionary = cm.load_json("res://data/stages.json")
	if not stages_data.has("stages"):
		return ""
	var stage_id: String = session.current_stage
	var stages: Dictionary = stages_data.stages
	if not stages.has(stage_id):
		return ""
	var available: Array = stages[stage_id].get("available_towers", [])
	if available.is_empty():
		return ""
	return available[randi() % available.size()]

func apply_battle_rewards(rating: String) -> Dictionary:
	var rewards: Dictionary = {"gold": 0, "tower_id": "", "rating": rating}
	rewards.gold = apply_rating_gold_reward(rating)
	if roll_tower_reward(rating):
		var tower_id: String = get_random_tower_for_stage()
		if tower_id != "":
			rewards.tower_id = tower_id
			session.add_tower(tower_id, -1)
			Global.debug_log("评价出塔奖励：%s" % tower_id)
	return rewards

func spend_gold(amount: int) -> bool:
	if session.gold >= amount:
		session.gold -= amount
		gold_changed.emit(session.gold)
		return true
	return false

func earn_gold(amount: int) -> void:
	session.gold += amount
	gold_changed.emit(session.gold)

func get_gold() -> int:
	return session.gold

func get_expected_gold_range(wave: int) -> Dictionary:
	var curve: Dictionary = _balance_config.get("expected_economy_curve", {})
	var phase_key: String = _get_wave_phase_key(wave)
	var phase_data: Dictionary = curve.get(phase_key, {})
	return {
		"min": phase_data.get("expected_gold_min", 0),
		"max": phase_data.get("expected_gold_max", 0),
		"phase": phase_data.get("phase", "未知"),
		"strategy": phase_data.get("strategy", "")
	}

func _get_wave_phase_key(wave: int) -> String:
	if wave <= 3:
		return "wave_1_3"
	elif wave <= 6:
		return "wave_4_6"
	elif wave <= 9:
		return "wave_7_9"
	else:
		return "wave_10"

func validate_economy_curve(current_wave: int) -> Dictionary:
	var expected: Dictionary = get_expected_gold_range(current_wave)
	var current_gold: int = get_gold()
	var status: String = "normal"
	if current_gold < expected.get("min", 0):
		status = "below"
	elif current_gold > expected.get("max", 0):
		status = "above"
	return {
		"wave": current_wave,
		"current_gold": current_gold,
		"expected_min": expected.get("min", 0),
		"expected_max": expected.get("max", 0),
		"phase": expected.get("phase", "未知"),
		"status": status
	}

func get_ending_reward(ending_rating: String) -> Dictionary:
	var ending_rewards: Dictionary = _balance_config.get("ending_rewards", {})
	return ending_rewards.get(ending_rating, {})

func get_kill_reward(enemy_id: String) -> int:
	var kill_rewards: Dictionary = _balance_config.get("kill_rewards", {})
	return kill_rewards.get(enemy_id, 0)

func get_meta_currency_projection() -> Dictionary:
	return _balance_config.get("meta_currency_projection", {})
