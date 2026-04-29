extends Node

signal session_reset

const GAME_VERSION: String = "0.1.0-demo"

var player_save: PlayerSaveData = PlayerSaveData.new()

var game_session: GameSessionData = GameSessionData.new()

var debug_map_id: String = ""

var soft_paused: bool = false

func _ready() -> void:
	if OS.is_debug_build():
		print("[Global] 全局单例初始化完成")
		print("[Global] 游戏版本：%s" % GAME_VERSION)

func debug_log(message: String) -> void:
	if OS.is_debug_build():
		print("[DEBUG] %s" % message)

func error_log(message: String) -> void:
	push_error("[ERROR] %s" % message)

func get_player_save() -> PlayerSaveData:
	return player_save

func get_game_session() -> GameSessionData:
	return game_session

func reset_game_session() -> void:
	game_session = GameSessionData.new()
	session_reset.emit()
	if OS.is_debug_build():
		print("[Global] 游戏会话已重置")
