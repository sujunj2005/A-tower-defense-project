@tool
extends Node

## Task 4 GUT 测试运行器 - 简化版
## 直接在编辑器中运行 GUT 测试

var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

var gut: Gut
var gut_config: GutConfig

func _ready() -> void:
	print("\n========================================")
	print("开始运行 Task 4 战斗系统 GUT 测试")
	print("========================================\n")
	
	# 初始化 GUT
	gut = Gut.new()
	add_child(gut)
	
	gut_config = GutConfig.new()
	
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
	gut.end_run.connect(_on_gut_end_run)
	
	# 开始运行测试
	print("开始运行测试...\n")
	gut.run_tests()

func _on_gut_end_run() -> void:
	print("\n========================================")
	print("Task 4 测试运行完成")
	print("========================================")
	
	# 获取测试结果
	var summary = gut.get_summary()
	var total_tests := summary.get_test_count()
	var passed_tests := summary.get_passing_test_count()
	var failed_tests := summary.get_failing_test_count()
	
	print("总测试数：%d" % total_tests)
	print("通过测试数：%d" % passed_tests)
	print("失败测试数：%d" % failed_tests)
	
	if failed_tests > 0:
		print("\n❌ 有测试失败，请检查输出")
		print("失败的测试:")
		_print_failed_tests(summary)
	else:
		print("\n✅ 所有测试通过！")

func _print_failed_tests(summary: Object) -> void:
	# 打印失败测试的详细信息
	var test_results = summary.get_tests()
	for test_result in test_results:
		if test_result.get("result") != "passed":
			print("  - %s: %s" % [test_result.get("name"), test_result.get("assertion_failure_message", "")])
