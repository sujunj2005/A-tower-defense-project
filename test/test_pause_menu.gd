extends Node

# 测试暂停菜单功能的脚本

func _ready():
	print("=== 开始测试暂停菜单功能 ===")
	
	# 测试1: 检查暂停菜单是否存在
	var pause_menu = get_node_or_null("/root/Main/PauseCanvas/PauseMenu")
	if pause_menu:
		print("✅ 暂停菜单节点存在")
	else:
		print("❌ 暂停菜单节点不存在")
		return
	
	# 测试2: 直接调用暂停菜单的pause_game方法
	print("测试2: 调用pause_game方法呼出暂停菜单")
	pause_menu.pause_game()
	
	# 测试3: 验证游戏是否被暂停
	print("测试3: 验证游戏是否被暂停")
	var tree = get_tree()
	if tree.paused:
		print("✅ 游戏逻辑已被暂停")
	else:
		print("❌ 游戏逻辑未被暂停")
	
	# 测试4: 点击继续游戏按钮
	print("测试4: 点击继续游戏按钮")
	# 直接调用resume_game方法
	pause_menu.resume_game()
	# 验证游戏是否恢复
	if not tree.paused:
		print("✅ 游戏已成功恢复")
	else:
		print("❌ 游戏未恢复")
	
	# 测试5: 再次呼出暂停菜单
	print("测试5: 再次呼出暂停菜单")
	pause_menu.pause_game()
	
	# 测试6: 点击返回主菜单按钮
	print("测试6: 点击返回主菜单按钮")
	# 直接调用_on_main_menu_pressed方法
	pause_menu._on_main_menu_pressed()
	print("已触发返回主菜单操作")
	
	print("=== 暂停菜单功能测试完成 ===")
