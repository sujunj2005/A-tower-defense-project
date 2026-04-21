extends VBoxContainer

signal birthday_selected(year: int, month: int, day: int)

var _year_spin: SpinBox
var _month_option: OptionButton
var _day_option: OptionButton
var _season_label: Label
var _zodiac_label: Label
var _selected_year: int = 1990
var _selected_month: int = 1
var _selected_day: int = 1

const _MONTH_DAYS: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const _ZODIAC_DATES: Array[Dictionary] = [
	{"name": "CAPRICORN", "month": 1, "day": 20},
	{"name": "AQUARIUS", "month": 2, "day": 19},
	{"name": "PISCES", "month": 3, "day": 20},
	{"name": "ARIES", "month": 4, "day": 20},
	{"name": "TAURUS", "month": 5, "day": 21},
	{"name": "GEMINI", "month": 6, "day": 21},
	{"name": "CANCER", "month": 7, "day": 22},
	{"name": "LEO", "month": 8, "day": 23},
	{"name": "VIRGO", "month": 9, "day": 23},
	{"name": "LIBRA", "month": 10, "day": 23},
	{"name": "SCORPIO", "month": 11, "day": 22},
	{"name": "SAGITTARIUS", "month": 12, "day": 21},
	{"name": "CAPRICORN", "month": 12, "day": 32},
]

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	var row_ym: HBoxContainer = HBoxContainer.new()
	row_ym.alignment = BoxContainer.ALIGNMENT_CENTER
	row_ym.add_theme_constant_override("separation", 6)
	_year_spin = SpinBox.new()
	_year_spin.min_value = 1950
	_year_spin.max_value = 2010
	_year_spin.value = _selected_year
	_year_spin.suffix = tr("BIRTHDAY_UNIT_YEAR")
	_year_spin.custom_minimum_size = Vector2(90, 28)
	_year_spin.value_changed.connect(_on_year_changed)
	row_ym.add_child(_year_spin)
	_month_option = OptionButton.new()
	for i: int in range(1, 13):
		_month_option.add_item(tr("BIRTHDAY_MONTH_%d" % i), i)
	_month_option.select(0)
	if not _month_option.item_selected.is_connected(_on_month_selected):
		_month_option.item_selected.connect(_on_month_selected)
	_month_option.custom_minimum_size = Vector2(90, 28)
	row_ym.add_child(_month_option)
	add_child(row_ym)
	var row_d: HBoxContainer = HBoxContainer.new()
	row_d.alignment = BoxContainer.ALIGNMENT_CENTER
	_day_option = OptionButton.new()
	_rebuild_day_options()
	_day_option.select(0)
	if not _day_option.item_selected.is_connected(_on_day_selected):
		_day_option.item_selected.connect(_on_day_selected)
	_day_option.custom_minimum_size = Vector2(70, 28)
	row_d.add_child(_day_option)
	add_child(row_d)
	_season_label = Label.new()
	_season_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_season_label.add_theme_font_size_override("font_size", 13)
	_season_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	add_child(_season_label)
	_zodiac_label = Label.new()
	_zodiac_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_zodiac_label.add_theme_font_size_override("font_size", 14)
	_zodiac_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	_zodiac_label.text = ""
	add_child(_zodiac_label)
	_update_season()
	_update_zodiac()

func get_birthday() -> String:
	return "%d-%02d-%02d" % [_selected_year, _selected_month, _selected_day]

func get_year() -> int:
	return _selected_year

func get_month() -> int:
	return _selected_month

func get_day() -> int:
	return _selected_day

func _rebuild_day_options() -> void:
	var current_sel: int = _day_option.selected if is_instance_valid(_day_option) else 0
	_day_option.clear()
	var max_day: int = _get_max_day(_selected_month, _selected_year)
	for d: int in range(1, max_day + 1):
		_day_option.add_item(str(d), d)
	_day_option.selected = mini(current_sel, max_day - 1)

func _get_max_day(month: int, year: int) -> int:
	if month == 2 and _is_leap_year(year):
		return 29
	return _MONTH_DAYS[month - 1]

func _is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

func _on_year_changed(value: float) -> void:
	_selected_year = int(value)
	_rebuild_day_options()
	_update_zodiac()
	birthday_selected.emit(_selected_year, _selected_month, _selected_day)

func _on_month_selected(index: int) -> void:
	_selected_month = _month_option.get_item_id(index)
	_rebuild_day_options()
	_update_season()
	_update_zodiac()
	birthday_selected.emit(_selected_year, _selected_month, _selected_day)

func _on_day_selected(index: int) -> void:
	_selected_day = _day_option.get_item_id(index)
	_update_zodiac()
	birthday_selected.emit(_selected_year, _selected_month, _selected_day)

func _update_season() -> void:
	var season_key: String = ""
	if _selected_month in [3, 4, 5]:
		season_key = "BIRTHDAY_SPRING"
	elif _selected_month in [6, 7, 8]:
		season_key = "BIRTHDAY_SUMMER"
	elif _selected_month in [9, 10, 11]:
		season_key = "BIRTHDAY_AUTUMN"
	else:
		season_key = "BIRTHDAY_WINTER"
	_season_label.text = tr(season_key)

func _update_zodiac() -> void:
	for z: Dictionary in _ZODIAC_DATES:
		if _selected_month < z.month or (_selected_month == z.month and _selected_day <= z.day):
			_zodiac_label.text = tr("BIRTHDAY_ZODIAC_PREFIX") + tr("ZODIAC_" + z.name)
			return
	_zodiac_label.text = tr("BIRTHDAY_ZODIAC_PREFIX") + tr("ZODIAC_CAPRICORN")
