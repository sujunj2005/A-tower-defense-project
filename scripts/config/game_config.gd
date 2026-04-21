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
	LIFESTEAL = 6,
	CRIT = 7,
	SILENCE = 8,
	ARMOR_BREAK = 9,
	CONFUSION = 10,
	DEBUFF = 11,
	SLOW_AURA = 12,
	BUFF_AURA = 13,
	SINGLE_CONTROL = 14,
	CULTURAL_SUPPRESSION = 15,
	GOLD_BONUS = 16,
	SUMMON = 17,
	BURN = 18
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
