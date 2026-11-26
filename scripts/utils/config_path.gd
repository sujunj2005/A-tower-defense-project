extends RefCounted
class_name ConfigPath

static func resolve(res_path: String) -> String:
	if not OS.has_feature("standalone"):
		return res_path
	if not res_path.begins_with("res://data/"):
		return res_path
	var exe_dir: String = OS.get_executable_path().get_base_dir()
	var relative: String = res_path.substr(12)
	var external_path: String = exe_dir.path_join("data").path_join(relative)
	if FileAccess.file_exists(external_path):
		return external_path
	return res_path
