extends Node

## 游戏状态枚举
enum State {
	NONE,
	MAIN_MENU,
	ERA_SELECTION,
	STAGE,
	EVENT,
	BATTLE,
	RESULT,
	META_PROGRESSION,
	ENDING
}

## 状态改变信号
signal state_changed(new_state: State)

## 当前状态
var current_state: State = State.NONE

## 场景路径映射
const SCENE_PATHS := {
	State.MAIN_MENU: "res://scenes/core/main_menu.tscn",
	State.ERA_SELECTION: "res://scenes/ui/life_choice.tscn",
	State.STAGE: "res://scenes/core/game_session.tscn",
	State.EVENT: "res://scenes/ui/event_screen.tscn",
	State.BATTLE: "res://scenes/map.tscn",
	State.RESULT: "res://scenes/ui/result_screen.tscn",
	State.META_PROGRESSION: "res://scenes/core/meta_progression.tscn",
	State.ENDING: "res://scenes/ui/ending_screen.tscn"
}

var scene_manager: Node

func _ready() -> void:
	scene_manager = get_node_or_null("/root/SceneManager")

## 改变状态
func change_state(new_state: State) -> void:
	if new_state == current_state:
		return
	
	Global.debug_log("状态改变：%s -> %s" % [State.keys()[current_state], State.keys()[new_state]])
	current_state = new_state
	state_changed.emit(new_state)
	
	# 根据新状态加载对应场景
	_load_scene_for_state(new_state)

## 加载状态对应的场景
func _load_scene_for_state(state: State) -> void:
	if not SCENE_PATHS.has(state):
		push_error("GameState: 状态 %s 没有对应的场景路径" % State.keys()[state])
		return
	
	var scene_path = SCENE_PATHS[state]
	
	# 使用 SceneManager 加载场景
	if scene_manager and scene_manager.has_method("change_scene"):
		scene_manager.change_scene(scene_path)
	else:
		# 如果 SceneManager 不存在，直接使用 get_tree()
		get_tree().change_scene_to_file(scene_path)

## 获取当前状态名称
func get_state_name() -> String:
	return State.keys()[current_state]

## 检查是否是特定状态
func is_state(state: State) -> bool:
	return current_state == state

## 初始化到主菜单
func initialize_to_main_menu() -> void:
	change_state(State.MAIN_MENU)
