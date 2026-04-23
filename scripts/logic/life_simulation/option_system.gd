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
		elif attr_name == "chain_flag":
			var flag_id: String = str(required_value)
			if not flag_id in session.chain_flags:
				return false
		elif attr_name == "family_member_alive":
			var member_id: String = str(required_value)
			if not session.family_members.has(member_id) or not session.family_members[member_id].get("alive", false):
				return false
		elif attr_name == "family_member_met":
			var member_id: String = str(required_value)
			if not session.family_members.has(member_id) or not session.family_members[member_id].get("met", false):
				return false
		elif attr_name == "work_ability":
			var threshold: int = int(required_value)
			var ability: int = session.attributes.get("intelligence", 0) + session.attributes.get("courage", 0)
			if ability < threshold:
				return false
		elif attr_name == "profession":
			var prof_value: String = str(required_value)
			if prof_value.begins_with("!"):
				var excluded_prof: String = prof_value.substr(1)
				if session.current_profession == excluded_prof:
					return false
			else:
				if session.current_profession != prof_value:
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
	var prof_names: Dictionary = {
		"programmer": tr("PROFESSION_PROGRAMMER"),
		"doctor": tr("PROFESSION_DOCTOR"),
		"teacher": tr("PROFESSION_TEACHER"),
		"civil_servant": tr("PROFESSION_CIVIL_SERVANT"),
		"entrepreneur": tr("PROFESSION_ENTREPRENEUR")
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
			"chain_flag":
				pass
			"family_member_alive":
				var member_name: String = _get_family_member_name(str(val))
				parts.append(tr("REQ_FAMILY_MEMBER_ALIVE") % member_name)
			"family_member_met":
				var member_name2: String = _get_family_member_name(str(val))
				parts.append(tr("REQ_FAMILY_MEMBER_MET") % member_name2)
			"work_ability":
				parts.append(tr("REQ_WORK_ABILITY") % int(val))
			"profession":
				var prof_key: String = str(val)
				if prof_key.begins_with("!"):
					var excluded_prof: String = prof_key.substr(1)
					var prof_display: String = prof_names.get(excluded_prof, excluded_prof)
					parts.append(tr("REQ_NOT_PROFESSION") % prof_display)
				else:
					var prof_display: String = prof_names.get(prof_key, prof_key)
					parts.append(tr("REQ_PROFESSION") % prof_display)
			"profession_absent":
				parts.append(tr("REQ_PROFESSION_ABSENT"))
			"npc_relation":
				if val is Dictionary:
					var npc_id: String = str(val.get("npc_id", ""))
					var op: String = str(val.get("op", ">="))
					var threshold: int = int(val.get("value", 0))
					var npc_name: String = _get_npc_name(npc_id)
					if op == "<":
						parts.append(tr("REQ_NPC_RELATION_LT") % [npc_name, threshold])
					else:
						parts.append(tr("REQ_NPC_RELATION_GTE") % [npc_name, threshold])
			_:
				var display_name: String = attr_names.get(key, key)
				parts.append(tr("REQUIREMENT_FORMAT") % [display_name, int(val)])
	return tr("SEPARATOR_DUN").join(parts)

func _get_npc_name(npc_id: String) -> String:
	var names: Dictionary = {
		"npc_father": tr("NPC_FATHER"),
		"npc_mother": tr("NPC_MOTHER"),
		"npc_friend": tr("NPC_FRIEND"),
		"npc_mentor": tr("NPC_MENTOR"),
		"npc_colleague": tr("NPC_COLLEAGUE"),
		"npc_spouse": tr("NPC_SPOUSE"),
	}
	return names.get(npc_id, npc_id)

func _get_family_member_name(member_id: String) -> String:
	var names: Dictionary = {
		"father": tr("FAMILY_FATHER"),
		"mother": tr("FAMILY_MOTHER"),
		"spouse": tr("FAMILY_SPOUSE"),
		"first_child": tr("FAMILY_FIRST_CHILD"),
		"second_child": tr("FAMILY_SECOND_CHILD"),
		"grandchild": tr("FAMILY_GRANDCHILD"),
	}
	return names.get(member_id, member_id)
