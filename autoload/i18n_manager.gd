extends Node

signal language_changed(new_locale: String)

const SUPPORTED_LOCALES: PackedStringArray = ["zh", "en"]
const DEFAULT_LOCALE: String = "zh"
const SAVE_KEY: String = "language"

var current_locale: String = DEFAULT_LOCALE

func _ready() -> void:
	_init_locale()

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
