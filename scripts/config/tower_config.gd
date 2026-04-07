extends Resource
class_name TowerConfig

# 引入枚举类型定义
const AttackMode = preload("res://scripts/config/attack_types.gd").AttackMode
const ProjectileType = preload("res://scripts/config/attack_types.gd").ProjectileType
const EffectType = preload("res://scripts/config/attack_effects.gd").EffectType

@export_group("Base Info")
@export var tower_id: String = ""
@export var tower_name: String = ""
@export var tower_level: int = 1
@export var description: String = ""

@export_group("Combat Stats")
@export var damage: float = 10.0
@export var damage_type: int = 0  # 0=物理, 1=魔法

@export_group("Attack Mode")  # 🆕 V2.1 新增：攻击模式配置
@export var attack_mode: int = AttackMode.MELEE  # 0=近战, 1=远程
@export var attack_range: float = 150.0

@export_group("Detection")  # 🆕 V2.1 新增：索敌系统
@export var detection_range: float = 150.0  # 索敌范围（必须 >= attack_range）
@export var attack_speed: float = 1.0

@export_group("Attack Timing")  # 🆕 V2.1 新增：攻击时机
@export var windup_duration: float = 0.0  # 前摇时长（秒），0=无前摇

@export_group("Projectile Config")  # 🆕 V2.1 新增：弹道配置（仅 RANGED 模式有效）
@export var projectile_speed: float = 300.0  # 弹道飞行速度（像素/秒）
@export var projectile_scene: PackedScene  # 🆕 弹道场景（直接使用 PackedScene）
@export var projectile_scene_path: String = ""  # 🆕 弹道场景路径（兼容旧配置）
@export var projectile_type: int = ProjectileType.POSITION_FIXED  # 0=TARGET_LOCKED, 1=POSITION_FIXED
@export var projectile_config: ProjectileConfig  # 🆕 弹道配置资源（优先使用）

@export_group("Pierce Config")  # 🆕 V2.1 新增：穿透配置（仅POSITION_FIXED可用）
@export var pierce_enabled: bool = false  # 是否启用穿透
@export var pierce_count: int = 2  # 最大穿透数量
@export var pierce_damage_decay: float = 0.7  # 穿透伤害衰减系数（每个目标衰减30%）

@export_group("Attack Effects")  # 🆕 V2.1 新增：攻击特效配置
@export var effect_type: int = EffectType.NONE  # 特效类型
@export var effect_radius: float = 50.0  # AOE特效半径（像素）
@export var effect_damage_ratio: float = 0.5  # AOE伤害比例（对周围敌人造成主目标伤害的百分比）
@export var effect_max_targets: int = 3  # AOE最大影响目标数
@export var effect_value: float = 0.0  # 特效数值（如减速比例、DOT每秒伤害等）

@export_group("Economy")
@export var cost: int = 100
@export var sell_ratio: float = 0.5  # 出售价格比例（0.5=返还 50% 造价）

@export_group("Level System")  # 🆕 新增：升级系统配置
@export var max_level: int = 3  # 最大等级
@export var experience_curve: float = 1.5  # 经验曲线（每级所需经验倍数）
@export var base_experience_required: int = 100  # 1 级升 2 级所需经验
@export var damage_growth: float = 0.2  # 每级伤害增长比例（20%）
@export var attack_speed_growth: float = 0.1  # 每级攻速增长比例（10%）
@export var range_growth: float = 0.05  # 每级射程增长比例（5%）
@export var experience_on_hit: int = 1  # 🆕 每次造成伤害获得的基础经验（微量）

@export_group("Visuals")
@export var texture_path: String = ""
@export var windup_animation: String = ""  # 🆕 前摇动画名称
@export var attack_animation: String = ""  # 🆕 攻击动画名称

static var _registry: Dictionary = {}

static func _static_init():
	_registry = {
		"basic": "res://resources/towers/basic_tower.tres",
		"archer": "res://resources/towers/archer_tower.tres",
		"magic": "res://resources/towers/magic_tower.tres"
	}

static func get_tower_types() -> Array:
	return _registry.keys()

static func get_config(tower_type: String) -> TowerConfig:
	if _registry.is_empty():
		_static_init()
	
	if not _registry.has(tower_type):
		return null
	var path: String = _registry[tower_type]
	if not ResourceLoader.exists(path):
		return null
	var config = load(path) as TowerConfig
	if config:
		# ⚠️ 警告：使用默认值的字段
		if tower_type != "basic" and config.cost == 100:
			print("[⚠️ 警告] %s 的 cost 使用默认值 100，可能未正确配置" % config.tower_name)
		if tower_type != "basic" and config.attack_mode == 0:
			print("[⚠️ 警告] %s 的 attack_mode 使用默认值 0 (MELEE)，可能未正确配置" % config.tower_name)
		if config.attack_mode == 1 and config.projectile_scene_path == "" and config.projectile_scene == null and config.projectile_config == null:
			print("[⚠️ 警告] %s 是远程塔但没有配置弹道场景或弹道配置！" % config.tower_name)
		
	return config

static func register_tower(tower_type: String, path: String):
	_registry[tower_type] = path

## 验证配置合法性（用于编辑器提示和运行时检查）
func validate() -> Dictionary:
	var warnings := []
	var errors := []

	# 检查索敌范围 >= 攻击范围
	if detection_range < attack_range:
		warnings.append("detection_range (%.0f) 应该 >= attack_range (%.0f)" % [detection_range, attack_range])

	# 检查远程模式必须有弹道场景
	if attack_mode == AttackMode.RANGED and projectile_scene == null and projectile_scene_path == "":
		errors.append("远程模式 (RANGED) 必须配置 projectile_scene 或 projectile_scene_path")

	# 检查 PIERCE 仅对 POSITION_FIXED 生效
	if pierce_enabled and projectile_type != ProjectileType.POSITION_FIXED:
		warnings.append("PIERCE 穿透特效要求 projectile_type 为 POSITION_FIXED，已自动强制切换")
		projectile_type = ProjectileType.POSITION_FIXED

	# 检查前摇时长合理性
	if windup_duration < 0:
		warnings.append("windup_duration 不应为负数，已重置为 0")
		windup_duration = 0.0
	elif windup_duration > 2.0:
		warnings.append("windup_duration(%.1f) 超过 2 秒，可能导致手感不佳" % windup_duration)

	# 检查穿透参数合理性
	if pierce_enabled and pierce_count <= 0:
		warnings.append("pierce_count 应>0，当前值为%d" % pierce_count)

	# 检查 AOE 参数
	if effect_type == EffectType.SPLASH and effect_radius <= 0:
		errors.append("SPLASH 特效必须设置 effect_radius > 0")

	return {
		"valid": errors.is_empty(),
		"warnings": warnings,
		"errors": errors
	}

## 🆕 初始化弹道场景（从路径加载）
func init_projectile_scene() -> void:
	if projectile_scene == null and projectile_scene_path != "":
		var loaded_scene = load(projectile_scene_path) as PackedScene
		if loaded_scene:
			projectile_scene = loaded_scene
		else:
			push_error("[TowerConfig] 无法加载弹道场景：%s" % projectile_scene_path)

## 🆕 计算指定等级所需的总经验值（累计）
func get_experience_required(level: int) -> int:
	if level < 1:
		return 0
	if level >= max_level:
		return -1  # 已达到最大等级，无法继续升级
	
	# 等比数列求和：base * (curve^0 + curve^1 + ... + curve^(level-1))
	var total_exp: float = 0.0
	for i in range(level):
		total_exp += base_experience_required * pow(experience_curve, i)
	
	return int(total_exp)

## 🆕 计算从当前等级升级到下一级所需的经验值（增量）
func get_experience_for_next_level(current_level: int) -> int:
	if current_level < 1:
		current_level = 1
	if current_level >= max_level:
		return -1
	
	# 升级所需经验 = base * curve^(current_level - 1)
	return int(base_experience_required * pow(experience_curve, current_level - 1))

## 🆕 计算升级后的伤害值
func get_damage_at_level(level: int) -> float:
	if level < 1:
		level = 1
	return damage * pow(1.0 + damage_growth, level - 1)

## 🆕 计算升级后的攻击速度
func get_attack_speed_at_level(level: int) -> float:
	if level < 1:
		level = 1
	return attack_speed * pow(1.0 + attack_speed_growth, level - 1)

## 🆕 计算升级后的射程
func get_attack_range_at_level(level: int) -> float:
	if level < 1:
		level = 1
	return attack_range * pow(1.0 + range_growth, level - 1)
