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

func _on_gut_end_run(gut: Gut) -> void:
    print("\n========================================")
    print("Task 4 Tests Completed")
    print("========================================")
    
    var summary = gut.get_summary()
    var total_tests := summary.get_test_count()
    var passed_tests := summary.get_passing_test_count()
    var failed_tests := summary.get_failing_test_count()
    
    print("Total: %d" % total_tests)
    print("Passed: %d" % passed_tests)
    print("Failed: %d" % failed_tests)
    
    if failed_tests > 0:
        print("\nFAILED TESTS:")
        _print_failed_tests(summary)
    else:
        print("\nALL TESTS PASSED!")
    
    gut.queue_free()

func _print_failed_tests(summary: Object) -> void:
    var test_results = summary.get_tests()
    for test_result in test_results:
        if test_result.get("result") != "passed":
            print("  - " + str(test_result.get("name")) + ": " + str(test_result.get("assertion_failure_message", "")))
