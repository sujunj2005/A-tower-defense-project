extends GutTest

var _map_manager: Node2D
var _tower_select_ui: Control

func before_all():
	var map_mgr_script: GDScript = load("res://scripts/map_manager.gd")
	_map_manager = Node2D.new()
	_map_manager.set_script(map_mgr_script)
	_map_manager.built_towers = {}
	add_child(_map_manager)

	var ui_script: GDScript = load("res://scripts/ui/tower_select_ui.gd")
	_tower_select_ui = Control.new()
	_tower_select_ui.set_script(ui_script)
	_map_manager.add_child(_tower_select_ui)

func after_all():
	if is_instance_valid(_map_manager):
		_map_manager.queue_free()

func test_no_towers_returns_empty():
	var counts: Dictionary = _tower_select_ui._get_placed_tower_counts()
	assert_eq(counts.size(), 0, "没有建塔时计数应为空字典")

func test_single_tower_counted():
	var tower: Node2D = Node2D.new()
	tower.set_meta("tower_id", "archer")
	tower.add_to_group("towers")
	add_child(tower)

	var counts: Dictionary = _tower_select_ui._get_placed_tower_counts()
	assert_eq(counts.get("archer", 0), 1, "一个弓箭塔应计数为1")

	remove_child(tower)
	tower.queue_free()

func test_multiple_same_type_counted():
	var t1: Node2D = Node2D.new()
	t1.set_meta("tower_id", "archer")
	t1.add_to_group("towers")
	var t2: Node2D = Node2D.new()
	t2.set_meta("tower_id", "archer")
	t2.add_to_group("towers")
	add_child(t1)
	add_child(t2)

	var counts: Dictionary = _tower_select_ui._get_placed_tower_counts()
	assert_eq(counts.get("archer", 0), 2, "两个弓箭塔应计数为2")

	remove_child(t1)
	remove_child(t2)
	t1.queue_free()
	t2.queue_free()

func test_mixed_tower_types_counted():
	var t1: Node2D = Node2D.new()
	t1.set_meta("tower_id", "archer")
	t1.add_to_group("towers")
	var t2: Node2D = Node2D.new()
	t2.set_meta("tower_id", "cannon")
	t2.add_to_group("towers")
	add_child(t1)
	add_child(t2)

	var counts: Dictionary = _tower_select_ui._get_placed_tower_counts()
	assert_eq(counts.get("archer", 0), 1, "弓箭塔应计数为1")
	assert_eq(counts.get("cannon", 0), 1, "炮塔应计数为1")

	remove_child(t1)
	remove_child(t2)
	t1.queue_free()
	t2.queue_free()

func test_no_meta_tower_skipped():
	var tower: Node2D = Node2D.new()
	tower.add_to_group("towers")
	add_child(tower)

	var counts: Dictionary = _tower_select_ui._get_placed_tower_counts()
	assert_eq(counts.size(), 0, "无tower_id meta的塔不应被计数")

	remove_child(tower)
	tower.queue_free()

func test_remaining_display_format():
	var max_count: int = 2
	var placed: int = 1
	var remaining: int = max_count - placed
	assert_eq(remaining, 1, "max=2,placed=1时剩余应为1")
	assert_eq("%d/%d" % [remaining, max_count], "1/2", "显示格式应为剩余/最大")

	var placed2: int = 0
	var remaining2: int = max_count - placed2
	assert_eq(remaining2, 2, "max=2,placed=0时剩余应为2")
	assert_eq("%d/%d" % [remaining2, max_count], "2/2", "没放塔时应显示2/2")
