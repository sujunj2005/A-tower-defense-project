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
		"intelligence": tr("ATTR_INTELLIGENCE"),
		"courage": tr("ATTR_COURAGE"),
		"health": tr("ATTR_HEALTH"),
		"charm": tr("ATTR_CHARM"),
		"work_ability": tr("ATTR_WORK_ABILITY"),
		"luck": tr("ATTR_LUCK")
	}
	var bg_names: Dictionary = {
		"farmer": tr("BG_FARMER"),
		"worker": tr("BG_WORKER"),
		"merchant": tr("BG_MERCHANT"),
		"cadre": tr("BG_CADRE"),
		"farmer_or_worker": tr("BG_FARMER_OR_WORKER")
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
						neg_name = tr(tc.get("name", neg_id))
					parts.append(tr("REQ_NOT_TRAIT") % neg_name)
				else:
					var ts2: Node = get_node_or_null("/root/TraitSystem")
					var tname: String = trait_id
					if ts2 and ts2.has_method("get_trait_config"):
						var tc2: Dictionary = ts2.get_trait_config(trait_id)
						tname = tr(tc2.get("name", trait_id))
					parts.append(tr("REQ_HAS_TRAIT") % tname)
			"gold":
				parts.append(tr("REQ_GOLD") % int(val))
			"family_background":
				var bg_val: String = str(val)
				if bg_names.has(bg_val):
					parts.append(tr("REQ_FAMILY") % bg_names[bg_val])
				elif bg_val.begins_with("!"):
					var neg_bg: String = bg_val.substr(1)
					var neg_name2: String = bg_names.get(neg_bg, neg_bg)
					parts.append(tr("REQ_NOT_FAMILY") % neg_name2)
				else:
					parts.append(tr("REQ_FAMILY") % bg_val)
			"education":
				parts.append(tr("REQ_EDUCATION") % str(val))
			"work_ability":
				parts.append(tr("REQ_WORK_ABILITY") % int(val))
			_:
				var display_name: String = attr_names.get(key, key)
				parts.append(tr("REQUIREMENT_FORMAT") % [display_name, int(val)])
	return tr("SEPARATOR_DUN").join(parts)
