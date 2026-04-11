extends GutTest

func _check_requirements(requirements: Dictionary, session: GameSessionData) -> bool:
	for attr_name: String in requirements:
		var required_value: Variant = requirements[attr_name]
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
			if required_bg.begins_with("!"):
				if session.family_background == required_bg.substr(1):
					return false
			elif required_bg == "farmer_or_worker":
				if session.family_background != "farmer" and session.family_background != "worker":
					return false
			else:
				if session.family_background != required_bg:
					return false
		elif attr_name == "education":
			pass
		else:
			var current_value: int = session.attributes.get(attr_name, 0)
			if current_value < int(required_value):
				return false
	return true

func test_check_requirements_empty() -> void:
	var session: GameSessionData = GameSessionData.new()
	var result: bool = _check_requirements({}, session)
	assert_true(result, "空需求应通过")

func test_check_requirements_attribute_pass() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.attributes["intelligence"] = 80
	var result: bool = _check_requirements({"intelligence": 60}, session)
	assert_true(result, "属性满足时应通过")

func test_check_requirements_attribute_fail() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.attributes["intelligence"] = 30
	var result: bool = _check_requirements({"intelligence": 60}, session)
	assert_false(result, "属性不足时应失败")

func test_check_requirements_trait_pass() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.traits.append("lover")
	var result: bool = _check_requirements({"trait": "lover"}, session)
	assert_true(result, "拥有特质时应通过")

func test_check_requirements_trait_fail() -> void:
	var session: GameSessionData = GameSessionData.new()
	var result: bool = _check_requirements({"trait": "lover"}, session)
	assert_false(result, "缺少特质时应失败")

func test_check_requirements_trait_negation() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.family_background = "farmer"
	session.traits.append("farmer")
	var result: bool = _check_requirements({"family_background": "!farmer"}, session)
	assert_false(result, "!farmer 在农民家庭时应失败")

func test_check_requirements_trait_negation_pass() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.family_background = "cadre"
	var result: bool = _check_requirements({"family_background": "!farmer"}, session)
	assert_true(result, "!farmer 在非农民家庭时应通过")

func test_check_requirements_gold_pass() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.gold = 300
	var result: bool = _check_requirements({"gold": 200}, session)
	assert_true(result, "金币充足时应通过")

func test_check_requirements_gold_fail() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.gold = 50
	var result: bool = _check_requirements({"gold": 200}, session)
	assert_false(result, "金币不足时应失败")

func test_check_requirements_family_background_exact() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.family_background = "cadre"
	var result: bool = _check_requirements({"family_background": "cadre"}, session)
	assert_true(result, "家庭背景匹配时应通过")

func test_check_requirements_family_background_farmer_or_worker() -> void:
	var session1: GameSessionData = GameSessionData.new()
	session1.family_background = "farmer"
	var result1: bool = _check_requirements({"family_background": "farmer_or_worker"}, session1)
	assert_true(result1, "农民应匹配 farmer_or_worker")
	
	var session2: GameSessionData = GameSessionData.new()
	session2.family_background = "worker"
	var result2: bool = _check_requirements({"family_background": "farmer_or_worker"}, session2)
	assert_true(result2, "工人应匹配 farmer_or_worker")

func test_check_requirements_family_background_farmer_or_worker_fail() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.family_background = "cadre"
	var result: bool = _check_requirements({"family_background": "farmer_or_worker"}, session)
	assert_false(result, "干部不应匹配 farmer_or_worker")

func test_check_requirements_multiple() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.attributes["intelligence"] = 80
	session.traits.append("key_high_school")
	session.gold = 100
	var result: bool = _check_requirements({"intelligence": 60, "trait": "key_high_school", "gold": 50}, session)
	assert_true(result, "所有条件满足时应通过")

func test_check_requirements_multiple_one_fail() -> void:
	var session: GameSessionData = GameSessionData.new()
	session.attributes["intelligence"] = 80
	session.gold = 10
	var result: bool = _check_requirements({"intelligence": 60, "gold": 50}, session)
	assert_false(result, "任一条件不满足时应失败")
