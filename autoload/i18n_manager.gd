extends Node

signal language_changed(new_locale: String)

const SUPPORTED_LOCALES: PackedStringArray = ["zh", "en"]
const DEFAULT_LOCALE: String = "zh"
const SAVE_KEY: String = "language"

var current_locale: String = DEFAULT_LOCALE

func _ready() -> void:
	_load_csv_translations()
	_init_locale()

func _load_csv_translations() -> void:
	var existing: Array = TranslationServer.get_translations()
	for old_tr: Object in existing:
		TranslationServer.remove_translation(old_tr)
	if not existing.is_empty():
		Global.debug_log("[I18n] 已移除 %d 个引擎预加载的翻译对象（.translation二进制文件）" % existing.size())
	var file: FileAccess = FileAccess.open("res://locale/translations.csv", FileAccess.READ)
	if not file:
		return
	var first_line: bool = true
	var locales: PackedStringArray = []
	var translations: Dictionary = {}
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.strip_edges() == "":
			continue
		var parts: PackedStringArray = _parse_csv_line(line)
		if first_line:
			first_line = false
			for i: int in range(1, parts.size()):
				locales.append(parts[i].strip_edges())
				translations[parts[i].strip_edges()] = Translation.new()
				translations[parts[i].strip_edges()].locale = parts[i].strip_edges()
			continue
		var key: String = parts[0].strip_edges()
		for i: int in range(1, parts.size()):
			if i - 1 < locales.size():
				var value: String = parts[i].strip_edges()
				if value != "" and key != "":
					translations[locales[i - 1]].add_message(key, value)
	file.close()
	for locale: String in locales:
		if translations.has(locale):
			var msg_count: int = translations[locale].get_message_count()
			TranslationServer.add_translation(translations[locale])
			Global.debug_log("[I18n] CSV加载完成: locale=%s, 翻译条数=%d" % [locale, msg_count])
	var test_tr: String = tr("TOWER_MATH_MASTER_NAME")
	Global.debug_log("[I18n] 验证 tr(TOWER_MATH_MASTER_NAME)='%s'" % test_tr)
	if test_tr == "TOWER_MATH_MASTER_NAME":
			push_error("[I18n] ⚠️ 翻译未生效！tr()返回原始键")

func _parse_csv_line(line: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var i: int = 0
	var length: int = line.length()
	while i < length:
		if line[i] == '"':
			i += 1
			var field: String = ""
			while i < length:
				if line[i] == '"':
					if i + 1 < length and line[i + 1] == '"':
						field += '"'
						i += 2
					else:
						i += 1
						break
				else:
					field += line[i]
					i += 1
			result.append(field)
			if i < length and line[i] == ',':
				i += 1
		else:
			var start: int = i
			while i < length and line[i] != ',':
				i += 1
			result.append(line.substr(start, i - start))
			if i < length and line[i] == ',':
				i += 1
	return result

func _init_locale() -> void:
	var saved: String = _load_language_preference()
	if saved != "":
		current_locale = saved
	else:
		var system_lang: String = OS.get_locale_language()
		current_locale = system_lang if system_lang in SUPPORTED_LOCALES else DEFAULT_LOCALE
	TranslationServer.set_locale(current_locale)

func set_language(locale: String) -> void:
	if locale == current_locale:
		return
	if locale not in SUPPORTED_LOCALES:
		push_warning("Unsupported locale: %s" % locale)
		return
	current_locale = locale
	TranslationServer.set_locale(locale)
	_save_language_preference(locale)
	language_changed.emit(locale)

func get_supported_locales() -> PackedStringArray:
	return SUPPORTED_LOCALES

func get_locale_display_name(locale: String) -> String:
	match locale:
		"zh": return tr("LANG_ZH")
		"en": return tr("LANG_EN")
		_: return locale

func _load_language_preference() -> String:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		return config.get_value("i18n", SAVE_KEY, "")
	return ""

func _save_language_preference(locale: String) -> void:
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("i18n", SAVE_KEY, locale)
	config.save("user://settings.cfg")
