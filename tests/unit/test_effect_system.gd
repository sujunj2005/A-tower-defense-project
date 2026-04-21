extends GutTest

const EffectType = GameConfig.EffectType
const DamageType = GameConfig.DamageType

var effect_system: Node
var mock_enemy: Enemy
var mock_tower: Tower

func before_each() -> void:
	effect_system = load("res://scripts/logic/tower_defense/effect_system.gd").new()
	add_child_autofree(effect_system)

	mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	var cfg := EnemyConfig.new()
	cfg.max_health = 100.0
	cfg.move_speed = 100.0
	cfg.physical_resistance = 0.2
	cfg.magical_resistance = 0.1
	cfg.gold_drop = 10
	cfg.enemy_type = "normal"
	cfg.experience_drop = 5
	mock_enemy.config = cfg
	mock_enemy.current_health = cfg.max_health
	mock_enemy.base_move_speed = cfg.move_speed
	mock_enemy.setup_sprite()
	mock_enemy.setup_health_bar()

	mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	var tcfg := TowerBean.new()
	tcfg.damage = 20.0
	tcfg.attack_speed = 1.0
	tcfg.attack_range = 150.0
	tcfg.detection_range = 200.0
	tcfg.effect_type = EffectType.NONE
	tcfg.effect_params = {}
	tcfg.experience_on_hit = 0
	tcfg.cost = 10
	tcfg.max_level = 3
	mock_tower.config = tcfg

func test_apply_slow_effect() -> void:
	effect_system.apply_effect(EffectType.SLOW, {"value": 0.3, "duration": 2.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_slowed, "敌人应被减速")
	assert_eq(mock_enemy.slow_amount, 0.3, "减速量应为0.3")
	assert_eq(mock_enemy.slow_timer, 2.0, "减速计时器应为2.0")

func test_apply_slow_clamped() -> void:
	effect_system.apply_effect(EffectType.SLOW, {"value": 1.5, "duration": 2.0}, mock_tower, mock_enemy)
	assert_eq(mock_enemy.slow_amount, 0.95, "减速量应被钳制到0.95")

func test_apply_dot_effect() -> void:
	effect_system.apply_effect(EffectType.DOT, {"value": 5.0, "duration": 3.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_dot_active, "DOT应激活")
	assert_eq(mock_enemy.dot_damage_per_second, 5.0, "DOT每秒伤害应为5.0")
	assert_eq(mock_enemy.dot_duration, 3.0, "DOT持续应为3.0秒")

func test_apply_burn_effect() -> void:
	effect_system.apply_effect(EffectType.BURN, {"value": 8.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_dot_active, "灼烧应激活DOT")
	assert_eq(mock_enemy.dot_damage_per_second, 8.0, "灼烧每秒伤害应为8.0")
	assert_eq(mock_enemy.dot_duration, 2.0, "灼烧持续应为2.0秒")

func test_apply_silence_effect() -> void:
	effect_system.apply_effect(EffectType.SILENCE, {"duration": 3.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_silenced, "敌人应被沉默")
	assert_eq(mock_enemy.silence_timer, 3.0, "沉默计时器应为3.0")

func test_apply_armor_break_effect() -> void:
	effect_system.apply_effect(EffectType.ARMOR_BREAK, {"value": 0.3, "duration": 4.0}, mock_tower, mock_enemy)
	assert_eq(mock_enemy.armor_break_amount, 0.3, "破甲量应为0.3")
	assert_eq(mock_enemy.armor_break_timer, 4.0, "破甲计时器应为4.0")

func test_armor_break_reduces_resistance() -> void:
	mock_enemy.apply_armor_break(0.15, 3.0)
	var health_before: float = mock_enemy.current_health
	mock_enemy.take_damage(100.0, DamageType.PHYSICAL)
	var damage_taken: float = health_before - mock_enemy.current_health
	var expected_resistance: float = maxf(0.0, 0.2 - 0.15)
	var expected_damage: float = 100.0 * (1.0 - expected_resistance)
	assert_eq(damage_taken, expected_damage, "破甲应降低抗性")

func test_armor_break_zero_resistance_floor() -> void:
	mock_enemy.apply_armor_break(0.5, 3.0)
	var health_before: float = mock_enemy.current_health
	mock_enemy.take_damage(100.0, DamageType.PHYSICAL)
	var damage_taken: float = health_before - mock_enemy.current_health
	assert_eq(damage_taken, 100.0, "抗性不应低于0，破甲超过抗性时应全额伤害")

func test_apply_confusion_effect() -> void:
	effect_system.apply_effect(EffectType.CONFUSION, {"duration": 2.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_confused, "敌人应被混乱")
	assert_eq(mock_enemy.confusion_timer, 2.0, "混乱计时器应为2.0")

func test_apply_debuff_effect() -> void:
	effect_system.apply_effect(EffectType.DEBUFF, {"value": 0.15, "duration": 3.0}, mock_tower, mock_enemy)
	assert_eq(mock_enemy.debuff_amount, 0.15, "减益量应为0.15")
	assert_eq(mock_enemy.debuff_timer, 3.0, "减益计时器应为3.0")

func test_apply_single_control_stun() -> void:
	effect_system.apply_effect(EffectType.SINGLE_CONTROL, {"duration": 3.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_stunned, "单体控制应造成眩晕")
	assert_eq(mock_enemy.stun_timer, 3.0, "眩晕计时器应为3.0")

func test_stun_stops_movement() -> void:
	mock_enemy.path_points = [Vector2(0, 0), Vector2(200, 0)]
	mock_enemy.current_path_index = 1
	mock_enemy.global_position = Vector2(100, 0)
	mock_enemy.apply_stun(2.0)
	var pos_before: Vector2 = mock_enemy.global_position
	mock_enemy._process(0.016)
	assert_eq(mock_enemy.global_position, pos_before, "眩晕时敌人不应移动")

func test_confusion_reverses_movement() -> void:
	mock_enemy.path_points = [Vector2(0, 0), Vector2(200, 0), Vector2(400, 0)]
	mock_enemy.current_path_index = 2
	mock_enemy.global_position = Vector2(250, 0)
	mock_enemy.apply_confusion(2.0)
	var pos_before: Vector2 = mock_enemy.global_position
	mock_enemy._process(0.016)
	assert_lt(mock_enemy.global_position.x, pos_before.x, "混乱时敌人应反向移动")

func test_slow_effect_expires() -> void:
	mock_enemy.apply_slow(0.3, 1.0)
	assert_true(mock_enemy.is_slowed, "减速应激活")
	mock_enemy.update_slow_effect(1.5)
	assert_false(mock_enemy.is_slowed, "减速应过期")
	assert_eq(mock_enemy.slow_amount, 0.0, "减速量应归零")

func test_silence_effect_expires() -> void:
	mock_enemy.apply_silence(2.0)
	assert_true(mock_enemy.is_silenced, "沉默应激活")
	mock_enemy.update_silence_effect(2.5)
	assert_false(mock_enemy.is_silenced, "沉默应过期")

func test_stun_effect_expires() -> void:
	mock_enemy.apply_stun(1.0)
	assert_true(mock_enemy.is_stunned, "眩晕应激活")
	mock_enemy.update_stun_effect(1.5)
	assert_false(mock_enemy.is_stunned, "眩晕应过期")

func test_confusion_effect_expires() -> void:
	mock_enemy.apply_confusion(1.5)
	assert_true(mock_enemy.is_confused, "混乱应激活")
	mock_enemy.update_confusion_effect(2.0)
	assert_false(mock_enemy.is_confused, "混乱应过期")

func test_armor_break_effect_expires() -> void:
	mock_enemy.apply_armor_break(0.3, 2.0)
	assert_eq(mock_enemy.armor_break_amount, 0.3, "破甲量应为0.3")
	mock_enemy.update_armor_break_effect(2.5)
	assert_eq(mock_enemy.armor_break_amount, 0.0, "破甲过期后应归零")

func test_debuff_effect_expires() -> void:
	mock_enemy.apply_debuff(0.2, 3.0)
	assert_eq(mock_enemy.debuff_amount, 0.2, "减益量应为0.2")
	mock_enemy.update_debuff_effect(3.5)
	assert_eq(mock_enemy.debuff_amount, 0.0, "减益过期后应归零")

func test_effect_probability_check() -> void:
	var params: Dictionary = {"probability": 0.0, "value": 0.3, "duration": 2.0}
	effect_system.apply_effect(EffectType.SLOW, params, mock_tower, mock_enemy)
	assert_false(mock_enemy.is_slowed, "概率为0时特效不应触发")

func test_effect_none_ignored() -> void:
	effect_system.apply_effect(EffectType.NONE, {}, mock_tower, mock_enemy)
	assert_false(mock_enemy.is_slowed, "NONE特效不应触发任何效果")

func test_apply_effect_with_none_type() -> void:
	effect_system.apply_effect(EffectType.NONE, {}, mock_tower, mock_enemy)
	assert_eq(mock_enemy.current_health, 100.0, "NONE特效不应改变敌人状态")

func test_knockback_effect() -> void:
	mock_tower.global_position = Vector2(0, 0)
	mock_enemy.global_position = Vector2(100, 0)
	effect_system.apply_effect(EffectType.KNOCKBACK, {"distance": 50.0}, mock_tower, mock_enemy)
	assert_true(mock_enemy.is_being_knocked_back, "敌人应被击退")
	assert_gt(mock_enemy.knockback_velocity.length(), 0.0, "击退速度应大于0")

func test_cultural_suppression_matching() -> void:
	mock_enemy.config.enemy_type = "homework"
	var params: Dictionary = {"target_tags": ["homework", "exam"], "bonus_damage": 0.5}
	var health_before: float = mock_enemy.current_health
	effect_system.apply_effect(EffectType.CULTURAL_SUPPRESSION, params, mock_tower, mock_enemy)
	assert_lt(mock_enemy.current_health, health_before, "文化压制对匹配类型应造成额外伤害")

func test_cultural_suppression_no_match() -> void:
	mock_enemy.config.enemy_type = "sports"
	var params: Dictionary = {"target_tags": ["homework", "exam"], "bonus_damage": 0.5}
	var health_before: float = mock_enemy.current_health
	effect_system.apply_effect(EffectType.CULTURAL_SUPPRESSION, params, mock_tower, mock_enemy)
	assert_eq(mock_enemy.current_health, health_before, "文化压制对不匹配类型不应造成伤害")

func test_crit_effect_with_probability() -> void:
	var params: Dictionary = {"crit_probability": 1.0, "crit_multiplier": 2.5}
	var health_before: float = mock_enemy.current_health
	effect_system.apply_effect(EffectType.CRIT, params, mock_tower, mock_enemy)
	var damage: float = health_before - mock_enemy.current_health
	var extra_damage: float = 20.0 * (2.5 - 1.0) * (1.0 - 0.2)
	assert_eq(damage, extra_damage, "暴击sub_effect应补差价1.5倍(含抗性减免)")

func test_crit_effect_zero_probability() -> void:
	var params: Dictionary = {"crit_probability": 0.0, "crit_multiplier": 2.5}
	var health_before: float = mock_enemy.current_health
	effect_system.apply_effect(EffectType.CRIT, params, mock_tower, mock_enemy)
	assert_eq(mock_enemy.current_health, health_before, "暴击概率为0时不应触发")

func test_aura_registration() -> void:
	var params: Dictionary = {"radius": 200.0, "slow_value": 0.25}
	effect_system.apply_effect(EffectType.SLOW_AURA, params, mock_tower, mock_enemy)
	assert_eq(effect_system._aura_towers.size(), 1, "应注册1个光环塔")

func test_aura_no_duplicate() -> void:
	var params: Dictionary = {"radius": 200.0, "slow_value": 0.25}
	effect_system.apply_effect(EffectType.SLOW_AURA, params, mock_tower, mock_enemy)
	effect_system.apply_effect(EffectType.SLOW_AURA, params, mock_tower, mock_enemy)
	assert_eq(effect_system._aura_towers.size(), 1, "同一塔不应重复注册光环")

func test_remove_aura_for_tower() -> void:
	var params: Dictionary = {"radius": 200.0, "slow_value": 0.25}
	effect_system.apply_effect(EffectType.SLOW_AURA, params, mock_tower, mock_enemy)
	assert_eq(effect_system._aura_towers.size(), 1, "应注册1个光环塔")
	effect_system.remove_aura_for_tower(mock_tower)
	assert_eq(effect_system._aura_towers.size(), 0, "移除后光环应为0")

func test_gold_bonus_on_kill() -> void:
	mock_tower.config.effect_type = EffectType.GOLD_BONUS
	mock_tower.config.effect_params = {"gold_per_kill": 0.5}
	mock_enemy.damage_dealers[mock_tower] = 50.0
	mock_enemy.last_hit_tower = mock_tower
	var bonus: int = maxi(1, int(ceilf(mock_enemy.config.gold_drop * 0.5)))
	assert_eq(bonus, 5, "击杀金币奖励应为5")

func test_slow_effective_speed() -> void:
	mock_enemy.apply_slow(0.5, 2.0)
	var effective: float = mock_enemy.get_effective_move_speed()
	assert_eq(effective, 50.0, "50%减速时有效速度应为50")

func test_no_slow_effective_speed() -> void:
	var effective: float = mock_enemy.get_effective_move_speed()
	assert_eq(effective, 100.0, "无减速时有效速度应为100")

func test_armor_break_does_not_stack_lower() -> void:
	mock_enemy.apply_armor_break(0.3, 3.0)
	mock_enemy.apply_armor_break(0.1, 3.0)
	assert_eq(mock_enemy.armor_break_amount, 0.3, "较低破甲不应覆盖较高值")

func test_armor_break_stacks_higher() -> void:
	mock_enemy.apply_armor_break(0.1, 3.0)
	mock_enemy.apply_armor_break(0.4, 3.0)
	assert_eq(mock_enemy.armor_break_amount, 0.4, "较高破甲应覆盖较低值")

func test_stun_does_not_stack_lower() -> void:
	mock_enemy.apply_stun(3.0)
	mock_enemy.apply_stun(1.0)
	assert_eq(mock_enemy.stun_timer, 3.0, "较短眩晕不应覆盖较长计时器")

func test_stun_extends_duration() -> void:
	mock_enemy.apply_stun(1.0)
	mock_enemy.apply_stun(3.0)
	assert_eq(mock_enemy.stun_timer, 3.0, "较长眩晕应覆盖较短计时器")

func test_silence_extends_duration() -> void:
	mock_enemy.apply_silence(1.0)
	mock_enemy.apply_silence(3.0)
	assert_eq(mock_enemy.silence_timer, 3.0, "较长沉默应覆盖较短计时器")

func test_confusion_extends_duration() -> void:
	mock_enemy.apply_confusion(1.0)
	mock_enemy.apply_confusion(3.0)
	assert_eq(mock_enemy.confusion_timer, 3.0, "较长混乱应覆盖较短计时器")

func test_debuff_does_not_stack_lower() -> void:
	mock_enemy.apply_debuff(0.2, 3.0)
	mock_enemy.apply_debuff(0.1, 3.0)
	assert_eq(mock_enemy.debuff_amount, 0.2, "较低减益不应覆盖较高值")

func test_debuff_stacks_higher() -> void:
	mock_enemy.apply_debuff(0.1, 3.0)
	mock_enemy.apply_debuff(0.3, 3.0)
	assert_eq(mock_enemy.debuff_amount, 0.3, "较高减益应覆盖较低值")
