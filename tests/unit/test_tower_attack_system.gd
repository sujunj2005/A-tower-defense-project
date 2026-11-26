extends GutTest

const AttackMode = GameConfig.AttackMode
const ProjectileType = GameConfig.ProjectileType
const EffectType = GameConfig.EffectType
const WindupState = GameConfig.WindupState


class MockEnemy extends Node2D:
	var current_health: float = 100.0

	func take_damage(amount: float, _damage_type: int, _attacker: Node2D = null, _is_crit: bool = false) -> void:
		current_health -= amount


var _arena: Node2D


func before_each() -> void:
	_arena = Node2D.new()
	add_child_autofree(_arena)


func _make_config(attack_mode: int = AttackMode.RANGED) -> TowerBean:
	var config := TowerBean.new()
	config.attack_mode = attack_mode
	config.projectile_type = ProjectileType.TARGET_LOCKED
	config.attack_range = 160.0
	config.damage = 20.0
	config.projectile_speed = 300.0
	config.windup_duration = 0.5
	config.texture_path = "res://icon.svg"
	return config


func _add_tower(config: TowerBean) -> Tower:
	var tower := Tower.new()
	_arena.add_child(tower)
	tower.initialize(config)
	return tower


func _add_enemy(x: float) -> MockEnemy:
	var enemy := MockEnemy.new()
	enemy.position = Vector2(x, 0.0)
	_arena.add_child(enemy)
	enemy.add_to_group("enemies")
	return enemy


func _shoot(tower: Tower, target: MockEnemy) -> Projectile:
	tower.attack_component.target = target
	tower.attack_component.execute_attack()
	for child: Node in _arena.get_children():
		if child is Projectile:
			return child
	return null


func test_tower_attack_component_initialization() -> void:
	var config := _make_config(AttackMode.MELEE)
	var tower := _add_tower(config)
	assert_not_null(tower.attack_component)
	assert_same(tower.attack_component.config, config)
	assert_same(tower.attack_component.tower, tower)


func test_windup_mechanism() -> void:
	var tower := _add_tower(_make_config())
	var enemy := _add_enemy(100.0)
	var attack := tower.attack_component
	assert_eq(attack.windup_state, WindupState.IDLE)
	attack.target = enemy
	attack.start_windup()
	assert_eq(attack.windup_state, WindupState.WINDUP_ACTIVE)
	assert_same(attack.committed_target, enemy)


func test_melee_attack() -> void:
	var config := _make_config(AttackMode.MELEE)
	var tower := _add_tower(config)
	var enemy := _add_enemy(50.0)
	tower.attack_component.target = enemy
	tower.attack_component.execute_attack()
	assert_eq(enemy.current_health, 100.0 - config.damage)


func test_ranged_attack() -> void:
	var tower := _add_tower(_make_config())
	var target := _add_enemy(150.0)
	var projectile := _shoot(tower, target)
	assert_not_null(projectile, "远程攻击应生成弹道")
	if projectile:
		assert_same(projectile.get_actual_target(), target)
		assert_eq(target.current_health, 100.0, "飞行期间未命中目标")


func test_projectile_types() -> void:
	var config := _make_config()
	var homing := TowerConfig.create_projectile_bean(config)
	assert_eq(homing.movement_type, ProjectileType.TARGET_LOCKED)
	config.projectile_type = ProjectileType.POSITION_FIXED
	var fixed := TowerConfig.create_projectile_bean(config)
	assert_eq(fixed.movement_type, ProjectileType.POSITION_FIXED)
	var tower := _add_tower(config)
	var target := _add_enemy(100.0)
	var projectile := _shoot(tower, target)
	assert_not_null(projectile)
	if projectile:
		projectile.update_position_fixed_movement(1.0)
		assert_eq(target.current_health, 80.0, "固定弹道应命中路径上的 Node2D 敌人")


func test_pierce_system() -> void:
	var config := _make_config()
	config.pierce_enabled = true
	config.pierce_count = 2
	config.pierce_damage_decay = 0.5
	var tower := _add_tower(config)
	var first := _add_enemy(40.0)
	var second := _add_enemy(85.0)
	var target := _add_enemy(150.0)
	var projectile := _shoot(tower, target)
	assert_not_null(projectile, "穿透攻击应生成弹道")
	if not projectile:
		return
	assert_eq(projectile.projectile_type, ProjectileType.POSITION_FIXED)
	projectile.update_position_fixed_movement(1.0)
	assert_eq(first.current_health, 80.0)
	assert_eq(second.current_health, 90.0, "第二个目标应受到衰减伤害")
	assert_eq(target.current_health, 100.0, "超过穿透次数的目标不会受伤")
	assert_true(projectile.is_queued_for_deletion())


func test_splash_effect() -> void:
	var config := _make_config()
	config.effect_type = EffectType.SPLASH
	config.effect_radius = 50.0
	config.effect_params = {"radius": 50.0, "damage_ratio": 0.5}
	var tower := _add_tower(config)
	var target := _add_enemy(100.0)
	var nearby := _add_enemy(130.0)
	var distant := _add_enemy(180.0)
	var projectile := _shoot(tower, target)
	assert_not_null(projectile)
	if not projectile:
		return
	assert_eq(nearby.current_health, 100.0, "弹道命中前不会触发溅射")
	projectile.on_hit_target(target)
	assert_eq(target.current_health, 80.0, "主目标只受到直接伤害")
	assert_eq(nearby.current_health, 90.0, "邻近目标只受到一次溅射")
	assert_eq(distant.current_health, 100.0)


func test_attack_range_validation() -> void:
	var config := _make_config(AttackMode.MELEE)
	var tower := _add_tower(config)
	var enemy := _add_enemy(config.attack_range + 100.0)
	var attack := tower.attack_component
	attack.target = enemy
	attack.start_windup()
	assert_eq(attack.windup_state, WindupState.IDLE)
	attack.execute_attack()
	assert_eq(enemy.current_health, 100.0)


func test_target_death_during_windup() -> void:
	var tower := _add_tower(_make_config())
	var enemy := _add_enemy(100.0)
	var attack := tower.attack_component
	attack.target = enemy
	attack.start_windup()
	assert_eq(attack.windup_state, WindupState.WINDUP_ACTIVE)
	enemy.free()
	attack.update_windup(0.1)
	assert_eq(attack.windup_state, WindupState.IDLE)
	assert_null(attack.committed_target)


func test_projectile_lifetime() -> void:
	var tower := _add_tower(_make_config())
	var target := _add_enemy(150.0)
	var projectile := _shoot(tower, target)
	assert_not_null(projectile)
	if not projectile:
		return
	projectile.update_target_locked_movement(1.0)
	assert_eq(target.current_health, 80.0, "单帧步长超过目标距离时仍应命中")
	assert_true(projectile.is_queued_for_deletion())
