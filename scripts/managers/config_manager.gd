extends Node

var _config_cache: Dictionary[String, Dictionary] = {}

func _ready() -> void:
	pass

func _res_to_external_path(res_path: String) -> String:
	if not res_path.begins_with("res://"):
		return res_path
	var relative: String = res_path.substr(6)
	if relative.begins_with("data/"):
		relative = relative.substr(5)
	var exe_dir: String = OS.get_executable_path().get_base_dir()
	return exe_dir.path_join("data").path_join(relative)

func load_json(file_path: String) -> Dictionary:
	if file_path in _config_cache:
		return _config_cache[file_path]

	var actual_path: String = file_path
	if OS.has_feature("standalone") and file_path.begins_with("res://data/"):
		var external_path: String = _res_to_external_path(file_path)
		if FileAccess.file_exists(external_path):
			actual_path = external_path

	var file = FileAccess.open(actual_path, FileAccess.READ)
	if not file:
		push_error("无法打开配置文件：%s" % file_path)
		return {}

	var content: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var error: Error = json.parse(content)
	if error != OK:
		push_error("JSON 解析失败：%s 错误：%s" % [file_path, error])
		return {}

	var result: Dictionary = json.data
	_config_cache[file_path] = result
	return result

func reload_config(file_path: String) -> Dictionary:
	if file_path in _config_cache:
		_config_cache.erase(file_path)
	return load_json(file_path)

func get_config(file_path: String, key: String, default_value: Variant = null) -> Variant:
	var data = load_json(file_path)
	if data.has(key):
		return data[key]
	return default_value
