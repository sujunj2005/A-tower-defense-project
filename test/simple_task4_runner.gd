@tool
extends Node

var _gut: Object

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	_run_tests()

func _run_tests() -> void:
	print("\n========================================")
	print("开始运行 Task 4 战斗系统 GUT 测试")
	print("========================================\n")
	
	var Gut = load("res://addons/gut/gut.gd")
	_gut = Gut.new()
	get_tree().root.add_child(_gut)
	
	_gut.add_script("res://tests/unit/test_task4_battle.gd")
	_gut.end_run.connect(_on_tests_done)
	
	print("开始运行测试...\n")
	_gut.test_scripts()

func _on_tests_done() -> void:
	print("\n========================================")
	print("Task 4 测试运行完成")
	print("========================================")
	
	var totals = _gut.get_summary().get_totals(_gut)
	print("总测试数：%d" % totals.tests)
	print("通过测试数：%d" % totals.passing_tests)
	print("失败测试数：%d" % totals.failing_tests)
	
	if totals.failing_tests > 0:
		print("\n❌ 有测试失败")
		_print_failures()
	else:
		print("\n✅ 所有测试通过！")

func _print_failures() -> void:
	var tc = _gut.get_test_collector()
	for s in tc.scripts:
		for t in s.tests:
			if t.was_run and not t.is_passing():
				print("  - %s: %s" % [t.name, str(t.fail_texts)])
