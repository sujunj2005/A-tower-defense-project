extends Resource
class_name WaveEnemyConfig

@export var enemy_type: String  # 保留向后兼容
@export var enemy_config: EnemyConfig  # 🆕 直接使用资源引用
@export var count: int
@export var delay: float = 0.0

## 🆕 获取敌人配置（优先使用引用，回退到字符串）
func get_enemy_config_value() -> EnemyConfig:
	if enemy_config:
		return enemy_config
	elif enemy_type != "":
		return EnemyConfig.get_config(enemy_type)
	return null
