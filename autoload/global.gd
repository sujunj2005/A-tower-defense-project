extends Node
class_name Global

## 游戏版本
const GAME_VERSION := "0.1.0-demo"

## 跨局持久化数据
var player_save: PlayerSaveData = PlayerSaveData.new()

## 当前单局数据
var game_session: GameSessionData = GameSessionData.new()

## 调试模式
var debug_mode: bool = true

func _ready() -> void:
	print("[Global] 全局单例初始化完成")
	print("[Global] 游戏版本：%s" % GAME_VERSION)

## 调试日志
func debug_log(message: String) -> void:
	if debug_mode:
		print("[DEBUG] %s" % message)

## 错误日志
func error_log(message: String) -> void:
	push_error("[ERROR] %s" % message)

## 获取当前存档数据
func get_player_save() -> PlayerSaveData:
	return player_save

## 获取当前单局数据
func get_game_session() -> GameSessionData:
	return game_session

## 重置单局数据
func reset_game_session() -> void:
	game_session = GameSessionData.new()
