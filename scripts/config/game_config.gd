class_name GameConfig

enum AttackMode {
	MELEE = 0,
	RANGED = 1,
	NONE = 2
}

enum ProjectileType {
	TARGET_LOCKED = 0,
	POSITION_FIXED = 1
}

enum EffectType {
	NONE = 0,
	PIERCE = 1,
	SPLASH = 2,
	SLOW = 3,
	DOT = 4,
	KNOCKBACK = 5,
	LIFESTEAL = 6
}

enum DetectionState {
	IDLE,
	DETECTING,
	TRACKING,
	ATTACKING,
	COOLDOWN
}

enum WindupState {
	IDLE,
	WINDUP_ACTIVE,
	COMMITTED
}

enum DamageType {
	PHYSICAL = 0,
	MAGICAL = 1
}
