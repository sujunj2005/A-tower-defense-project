extends Node

const SAVE_DIR: String = "user://saves/"
const SAVE_EXTENSION: String = ".sav"
const MAX_SAVE_SLOTS: int = 3

func _ready() -> void:
	_ensure_save_dir()

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(slot: int = 0) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("SaveSystem: 无效的存档位 %d" % slot)
		return false
	var save_path: String = SAVE_DIR + "save_%d%s" % [slot, SAVE_EXTENSION]
	var player_save: PlayerSaveData = Global.get_player_save()
	var save_data: Dictionary = {
		"version": "1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"player_data": player_save.to_dict()
	}
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		push_error("SaveSystem: 无法创建存档文件 %s" % save_path)
		return false
	var json_string: String = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	Global.debug_log("存档保存成功：槽位 %d" % slot)
	return true

func load_game(slot: int = 0) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("SaveSystem: 无效的存档位 %d" % slot)
		return false
	var save_path: String = SAVE_DIR + "save_%d%s" % [slot, SAVE_EXTENSION]
	if not FileAccess.file_exists(save_path):
		push_error("SaveSystem: 存档文件不存在 %s" % save_path)
		return false
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		push_error("SaveSystem: 无法读取存档文件 %s" % save_path)
		return false
	var content: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var error: Error = json.parse(content)
	if error != OK:
		push_error("SaveSystem: 存档 JSON 解析失败 %s" % save_path)
		return false
	var save_data: Dictionary = json.data
	if not save_data.has("player_data"):
		push_error("SaveSystem: 存档数据格式错误")
		return false
	var player_save: PlayerSaveData = PlayerSaveData.from_dict(save_data.player_data)
	Global.player_save = player_save
	Global.debug_log("存档加载成功：槽位 %d" % slot)
	return true

func has_save(slot: int = 0) -> bool:
	var save_path: String = SAVE_DIR + "save_%d%s" % [slot, SAVE_EXTENSION]
	return FileAccess.file_exists(save_path)

func delete_save(slot: int = 0) -> bool:
	var save_path: String = SAVE_DIR + "save_%d%s" % [slot, SAVE_EXTENSION]
	if not FileAccess.file_exists(save_path):
		return false
	var dir: DirAccess = DirAccess.open(SAVE_DIR)
	if dir:
		dir.remove("save_%d%s" % [slot, SAVE_EXTENSION])
		Global.debug_log("存档删除：槽位 %d" % slot)
		return true
	return false

func get_save_info(slot: int = 0) -> Dictionary:
	var save_path: String = SAVE_DIR + "save_%d%s" % [slot, SAVE_EXTENSION]
	if not FileAccess.file_exists(save_path):
		return {}
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return {}
	var content: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(content) != OK:
		return {}
	var data: Dictionary = json.data
	return {
		"version": data.get("version", ""),
		"timestamp": data.get("timestamp", ""),
		"life_wisdom": data.get("player_data", {}).get("currencies", {}).get("life_wisdom", 0),
		"total_games": data.get("player_data", {}).get("play_stats", {}).get("total_games", 0),
		"best_ending": data.get("player_data", {}).get("play_stats", {}).get("best_ending", "D")
	}

func get_all_save_slots() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i: int in range(MAX_SAVE_SLOTS):
		var info: Dictionary = get_save_info(i)
		info["slot"] = i
		info["has_save"] = has_save(i)
		result.append(info)
	return result

func auto_save() -> void:
	save_game(0)
	Global.debug_log("自动存档完成")
