extends Control

signal play_again
signal return_to_menu

@onready var _rating_label: Label = $VBox/RatingLabel
@onready var _desc_label: Label = $VBox/DescLabel
@onready var _wisdom_label: Label = $VBox/WisdomLabel
@onready var _destiny_label: Label = $VBox/DestinyLabel
@onready var _play_again_button: Button = $VBox/PlayAgainButton
@onready var _menu_button: Button = $VBox/MenuButton

func _ready() -> void:
	if _play_again_button:
		_play_again_button.pressed.connect(_on_play_again)
	if _menu_button:
		_menu_button.pressed.connect(_on_return_menu)
	_display_ending()

func _get_ending_system() -> Node:
	return get_node_or_null("/root/EndingSystem")

func _get_achievement_system() -> Node:
	return get_node_or_null("/root/AchievementSystem")

func _get_currency_manager() -> Node:
	return get_node_or_null("/root/CurrencyManager")

func _get_save_system() -> Node:
	return get_node_or_null("/root/SaveSystem")

func _display_ending() -> void:
	var session: GameSessionData = Global.get_game_session()
	var health_percent: float = 0.0
	if session.max_home_health > 0.0:
		health_percent = session.home_health / session.max_home_health

	var es: Node = _get_ending_system()
	var rating: String = "D"
	var ending_config: Dictionary = {}
	var description: String = "未知结局"

	if es:
		if es.has_method("determine_ending"):
			rating = es.determine_ending(health_percent)
		if es.has_method("get_ending_config"):
			ending_config = es.get_ending_config(rating)
		if es.has_method("get_ending_description"):
			description = es.get_ending_description(rating)

	if _rating_label:
		var rating_colors: Dictionary = {
			"S": Color(1.0, 0.84, 0.0),
			"A": Color(0.4, 0.8, 1.0),
			"B": Color(0.4, 1.0, 0.4),
			"C": Color(1.0, 1.0, 0.4),
			"D": Color(0.8, 0.4, 0.4)
		}
		_rating_label.text = "结局评级：%s" % rating
		_rating_label.add_theme_color_override("font_color", rating_colors.get(rating, Color.WHITE))
		_rating_label.add_theme_font_size_override("font_size", 28)

	if _desc_label:
		_desc_label.text = description

	var reward: Dictionary = ending_config.get("reward", {})
	var wisdom_amount: int = reward.get("life_wisdom", 0)
	var destiny_amount: int = reward.get("destiny_points", 0)

	var cm: Node = _get_currency_manager()
	if cm:
		if wisdom_amount > 0 and cm.has_method("add_life_wisdom"):
			cm.add_life_wisdom(wisdom_amount)
		if destiny_amount > 0 and cm.has_method("add_destiny_points"):
			cm.add_destiny_points(destiny_amount)

	var ach: Node = _get_achievement_system()
	if ach and ach.has_method("on_ending_reached"):
		ach.on_ending_reached(rating)

	var player_save: PlayerSaveData = Global.get_player_save()
	if _wisdom_label:
		_wisdom_label.text = "人生智慧：%d" % player_save.currencies.get("life_wisdom", 0)
	if _destiny_label:
		_destiny_label.text = "命运点数：%d" % player_save.currencies.get("destiny_points", 0)

	var ss: Node = _get_save_system()
	if ss and ss.has_method("auto_save"):
		ss.auto_save()

func _on_play_again() -> void:
	Global.reset_game_session()
	play_again.emit()
	GameState.change_state(GameState.State.ERA_SELECTION)

func _on_return_menu() -> void:
	Global.reset_game_session()
	return_to_menu.emit()
	GameState.change_state(GameState.State.MAIN_MENU)
