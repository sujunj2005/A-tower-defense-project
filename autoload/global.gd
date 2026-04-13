extends Node

signal session_reset

const GAME_VERSION: String = "0.1.0-demo"

var player_save: PlayerSaveData = PlayerSaveData.new()

var game_session: GameSessionData = GameSessionData.new()

var debug_mode: bool = true

func _ready() -> void:
	if debug_mode:
		print("[Global] 全局单例初始化完成")
		print("[Global] 游戏版本：%s" % GAME_VERSION)

func debug_log(message: String) -> void:
	if debug_mode:
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
	if debug_mode:
		print("[Global] 游戏会话已重置")
