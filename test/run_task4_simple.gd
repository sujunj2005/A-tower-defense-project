@tool
extends EditorScript

## Simple Task 4 GUT Test Runner
## Run this from Godot Editor > Script > Run

var Gut = load("res://addons/gut/gut.gd")
var GutConfig = load("res://addons/gut/gut_config.gd")

func _run() -> void:
    print("\n========================================")
    print("Starting Task 4 Battle System GUT Tests")
    print("========================================\n")
    
    var gut = Gut.new()
    EditorInterface.get_base_control().add_child(gut)
    
    var gut_config = GutConfig.new()
    
    var config_result = gut_config._load_options_from_config_file(
        "res://.gutconfig_task4.json", 
        gut_config.options
    )
    
    if config_result != 1:
        push_error("Failed to load GUT config")
        return
    
    gut_config._apply_options(gut_config.options, gut)
    gut.end_run.connect(_on_gut_end_run.bind(gut))
    
    print("Running tests...\n")
    gut.run_tests()

func _on_gut_end_run(gut: Object) -> void:
    print("\n========================================")
    print("Task 4 Tests Completed")
    print("========================================")
    
    var totals = gut.get_summary().get_totals(gut)
    var total_tests: int = totals.tests
    var passed_tests: int = totals.passing_tests
    var failed_tests: int = totals.failing_tests
    
    print("Total: %d" % total_tests)
    print("Passed: %d" % passed_tests)
    print("Failed: %d" % failed_tests)
    
    if failed_tests > 0:
        print("\nFAILED TESTS:")
        _print_failed_tests(gut)
    else:
        print("\nALL TESTS PASSED!")
    
    gut.queue_free()

func _print_failed_tests(gut: Object) -> void:
    var tc = gut.get_test_collector()
    for s in tc.scripts:
        for t in s.tests:
            if t.was_run and not t.is_passing():
                print("  - " + str(t.name) + ": " + str(t.fail_texts))
