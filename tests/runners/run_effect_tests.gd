@tool
extends Node

var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

var gut: Object
var gut_config: Object

func _ready() -> void:
	print("\n========================================")
	print("运行特效系统 GUT 测试")
	print("========================================\n")
	
	gut = Gut.new()
	add_child(gut)
	
	gut_config = GutConfig.new()
	gut_config.options.dirs = ["res://tests/unit/"]
	gut_config.options.unit_test_name = "test_effect_system"
	gut_config.options.should_maximize = false
	gut_config.options.should_exit = true
	
	gut_config._apply_options(gut_config.options, gut)
	gut.end_run.connect(_on_gut_end_run)
	
	print("开始运行测试...\n")
	gut.run_tests()

func _on_gut_end_run() -> void:
	print("\n========================================")
	print("特效系统测试运行完成")
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
	
	get_tree().quit()

func _print_failed_tests(gut_ref: Object) -> void:
	var tc = gut_ref.get_test_collector()
	for s in tc.scripts:
		for t in s.tests:
			if t.was_run and not t.is_passing():
				print("  - %s: %s" % [t.name, str(t.fail_texts)])
