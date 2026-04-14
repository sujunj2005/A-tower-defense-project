extends Node2D

const TowerConfig = preload("res://scripts/logic/tower_defense/tower_config.gd")

func _ready():
	print("\n========== 防御塔攻击系统 V2.1 测试 ==========\n")
	
	# 初始化防御塔
	var tower = get_node("Tower")
	var archer_cfg = TowerConfig.get_config("archer")
	
	if archer_cfg:
		print("[测试] 初始化弓箭塔...")
		
		# 手动设置配置参数，确保攻击模式为远程
		archer_cfg.attack_mode = 1  # 远程
		archer_cfg.projectile_scene_path = "res://scenes/projectiles/arrow_projectile.tscn"
		archer_cfg.pierce_enabled = true
		
		tower.initialize(archer_cfg)
		print("[测试] 弓箭塔初始化完成")
		print("[测试] 塔名: %s" % archer_cfg.tower_name)
		print("[测试] 攻击范围: %.0f" % archer_cfg.attack_range)
		print("[测试] 索敌范围: %.0f" % archer_cfg.detection_range)
		print("[测试] 前摇时长: %.2f秒" % archer_cfg.windup_duration)
		print("[测试] 攻击模式: %s" % ("远程" if archer_cfg.attack_mode == 1 else "近战"))
		print("[测试] 弹道类型: %s" % ("追踪" if archer_cfg.projectile_type == 0 else "固定"))
		print("[测试] 穿透: %s" % ("启用" if archer_cfg.pierce_enabled else "禁用"))
		print("[测试] 穿透数量: %d" % archer_cfg.pierce_count)
		print("[测试] 特效类型: %s" % get_effect_type_name(archer_cfg.effect_type))
		print("[测试] 弹道场景路径: %s" % archer_cfg.projectile_scene_path)
		
		# 调用调试方法打印配置信息
		if tower.attack_component:
			tower.attack_component.debug_print_config()
	else:
		print("[测试] 无法加载弓箭塔配置")
	
	# 等待1秒后开始测试
	test_timer(1.0)

func test_timer(delay: float):
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(func():
		start_test()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func start_test():
	print("\n[测试] 开始测试防御塔攻击功能...")
	
	# 获取防御塔攻击组件
	var tower = get_node("Tower")
	var attack_component = tower.attack_component
	
	if attack_component:
		# 测试索敌
		print("[测试] 测试索敌功能...")
		attack_component.find_target()
		
		if attack_component.target:
			print("[测试] 找到目标: %s" % attack_component.target.name)
			
			# 测试前摇
			print("[测试] 测试前摇机制...")
			attack_component.start_windup()
			
			# 等待前摇完成
			test_timer(1.0)
		else:
			print("[测试] 未找到目标")
	else:
		print("[测试] 无法获取攻击组件")

func get_effect_type_name(effect_type: int) -> String:
	match effect_type:
		0: return "无"
		1: return "穿透"
		2: return "AOE爆炸"
		3: return "减速"
		4: return "持续伤害"
		5: return "击退"
		6: return "吸血"
		_: return "未知"
