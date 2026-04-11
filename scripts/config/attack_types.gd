# 攻击模式与弹道类型枚举定义
# 适用于防御塔攻击系统 V2.1

## 攻击模式枚举
## 定义塔的攻击方式：近战或远程
enum AttackMode {
	MELEE = 0,
	RANGED = 1,
	NONE = 2
}

## 弹道类型枚举
## 定义远程弹道的终点确定方式
enum ProjectileType {
	TARGET_LOCKED = 0,    # 目标锁定型：动态追踪目标位置（不支持PIERCE）
	POSITION_FIXED = 1     # 坐标指定型：固定坐标（支持PIERCE穿透）
}
