# 索敌状态机枚举定义
# 适用于防御塔攻击系统 V2.1

## 索敌状态枚举
## 定义塔的索敌流程状态
enum DetectionState {
	IDLE,           # 空闲状态：未开始索敌
	DETECTING,      # 索敌中：搜索范围内的敌人
	TRACKING,       # 跟踪中：已锁定目标，持续监控
	ATTACKING,      # 攻击中：正在执行攻击动作
	COOLDOWN        # 冷却中：等待下次攻击
}

## 前摇状态枚举
## 定义攻击前摇的状态
enum WindupState {
	IDLE,               # 空闲状态（无前摇或前摇未开始）
	WINDUP_ACTIVE,      # 前摇进行中：正在计时
	COMMITTED           # 已提交：前摇结束，攻击必定执行
}
