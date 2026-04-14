extends Node

var _config_cache: Dictionary[String, Dictionary] = {}

func _ready() -> void:
	pass

## 加载 JSON 配置
func load_json(file_path: String) -> Dictionary:
	# 检查缓存
	if file_path in _config_cache:
		return _config_cache[file_path]
	
	# 加载文件
	var file = FileAccess.open(file_path, FileAccess.READ)
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

## 重新加载配置（清除缓存）
func reload_config(file_path: String) -> Dictionary:
	if file_path in _config_cache:
		_config_cache.erase(file_path)
	return load_json(file_path)

## 获取特定配置项
func get_config(file_path: String, key: String, default_value: Variant = null) -> Variant:
	var data = load_json(file_path)
	if data.has(key):
		return data[key]
	return default_value
