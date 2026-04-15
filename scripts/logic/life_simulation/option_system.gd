extends Node

signal option_selected(event_id: String, option: OptionData)

var _options_data: Dictionary = {}
var _options_by_event: Dictionary = {}

func _ready() -> void:
	_load_options()

func _load_options() -> void:
	var cm: Node = get_node_or_null("/root/ConfigManager")
	if not cm or not cm.has_method("load_json"):
		return
	var data = cm.load_json("res://data/options.json")
	if not data is Dictionary or not data.has("options"):
		return
	_options_data = data
	_options_by_event.clear()
	for opt_raw: Dictionary in data.options:
		var opt := OptionData.from_dict(opt_raw)
		var eid: String = opt.event_id
		if not _options_by_event.has(eid):
			var arr: Array[OptionData] = []
			_options_by_event[eid] = arr
		(_options_by_event[eid] as Array[OptionData]).append(opt)

func reload_options() -> void:
	_load_options()

func get_options_for_event(event_id: String) -> Array[OptionData]:
	if _options_by_event.has(event_id):
		return _options_by_event[event_id] as Array[OptionData]
	var empty: Array[OptionData] = []
	return empty

func check_requirements(option: OptionData) -> bool:
	var session: GameSessionData = Global.get_game_session()
	for attr_name: String in option.requirements:
		var required_value: Variant = option.requirements[attr_name]
		if attr_name == "trait":
			if str(required_value).begins_with("!"):
				var trait_id: String = str(required_value).substr(1)
				if trait_id in session.traits:
					return false
			else:
				if not str(required_value) in session.traits:
					return false
		elif attr_name == "gold":
			if session.gold < int(required_value):
				return false
		elif attr_name == "family_background":
			var required_bg: String = str(required_value)
			var session_bg_short: String = session.family_background.replace("family_", "")
			if required_bg.begins_with("!"):
				var excluded: String = required_bg.substr(1)
				if session_bg_short == excluded or session.family_background == excluded:
					return false
			elif required_bg == "farmer_or_worker":
				if session_bg_short != "farmer" and session_bg_short != "worker":
					return false
			else:
				if session_bg_short != required_bg and session.family_background != required_bg:
					return false
		elif attr_name == "education":
			var edu_trait: String = str(required_value)
			if not edu_trait in session.traits:
				return false
		elif attr_name == "work_ability":
			var threshold: int = int(required_value)
			var ability: int = session.attributes.get("intelligence", 0) + session.attributes.get("courage", 0)
			if ability < threshold:
				return false
		else:
			var current_value: int = session.attributes.get(attr_name, 0)
			if current_value < int(required_value):
				return false
	return true

func format_requirements(requirements: Dictionary) -> String:
	var parts: Array[String] = []
	var attr_names: Dictionary = {
		"intelligence": "智力",
		"courage": "勇气",
		"health": "健康",
		"charm": "魅力",
		"work_ability": "工作能力",
		"luck": "运气"
	}
	var bg_names: Dictionary = {
		"farmer": "农民",
		"worker": "工人",
		"merchant": "商人",
		"cadre": "干部",
		"farmer_or_worker": "农民或工人"
	}
	for key: String in requirements:
		var val: Variant = requirements[key]
		match key:
			"trait":
				var trait_id: String = str(val)
				if trait_id.begins_with("!"):
					var neg_id: String = trait_id.substr(1)
					var neg_name: String = neg_id
					var ts: Node = get_node_or_null("/root/TraitSystem")
					if ts and ts.has_method("get_trait_config"):
						var tc: Dictionary = ts.get_trait_config(neg_id)
						neg_name = tc.get("name", neg_id)
					parts.append("非「%s」" % neg_name)
				else:
					var ts2: Node = get_node_or_null("/root/TraitSystem")
					var tname: String = trait_id
					if ts2 and ts2.has_method("get_trait_config"):
						var tc2: Dictionary = ts2.get_trait_config(trait_id)
						tname = tc2.get("name", trait_id)
					parts.append("拥有「%s」" % tname)
			"gold":
				parts.append("金币≥%d" % int(val))
			"family_background":
				var bg_val: String = str(val)
				if bg_names.has(bg_val):
					parts.append("家庭背景：%s" % bg_names[bg_val])
				elif bg_val.begins_with("!"):
					var neg_bg: String = bg_val.substr(1)
					var neg_name2: String = bg_names.get(neg_bg, neg_bg)
					parts.append("非%s家庭" % neg_name2)
				else:
					parts.append("家庭背景：%s" % bg_val)
			"education":
				parts.append("学历：%s" % str(val))
			"work_ability":
				parts.append("工作能力≥%d" % int(val))
			_:
				var display_name: String = attr_names.get(key, key)
				parts.append("%s≥%d" % [display_name, int(val)])
	return "、".join(parts)
