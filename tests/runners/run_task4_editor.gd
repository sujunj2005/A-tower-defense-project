@tool
extends EditorScript

## Task 4 GUT 测试运行器 - 编辑器脚本版本
## 可以直接在编辑器中运行

var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

func _run() -> void:
	print("\n========================================")
	print("开始运行 Task 4 战斗系统 GUT 测试")
	print("========================================\n")
	
	# 创建 GUT 实例
	var gut = Gut.new()
	EditorInterface.get_base_control().add_child(gut)
	
	var gut_config = GutConfig.new()
	
	# 加载配置
	var config_result = gut_config._load_options_from_config_file(
		"res://.gutconfig_task4.json", 
		gut_config.options
	)
	
	if config_result != 1:
		push_error("加载 GUT 配置文件失败")
		return
	
	# 应用配置
	gut_config._apply_options(gut_config.options, gut)
	
	# 连接信号
	gut.end_run.connect(_on_gut_end_run.bind(gut))
	
	# 开始运行测试
	print("开始运行测试...\n")
	gut.run_tests()

func _on_gut_end_run(gut: Object) -> void:
	print("\n========================================")
	print("Task 4 测试运行完成")
	print("========================================")
	
	var totals = gut.get_summary().get_totals(gut)
	var total_tests: int = totals.tests
	var passed_tests: int = totals.passing_tests
	var failed_tests: int = totals.failing_tests
	
	print("总测试数：%d" % total_tests)
	print("通过测试数：%d" % passed_tests)
	print("失败测试数：%d" % failed_tests)
	
	if failed_tests > 0:
		print("\n❌ 有测试失败，请检查输出")
		_print_failed_tests(gut)
	else:
		print("\n✅ 所有测试通过！")
	
	# 清理
	gut.queue_free()

func _print_failed_tests(gut: Object) -> void:
	var tc = gut.get_test_collector()
	for s in tc.scripts:
		for t in s.tests:
			if t.was_run and not t.is_passing():
				print("  - %s: %s" % [t.name, str(t.fail_texts)])
