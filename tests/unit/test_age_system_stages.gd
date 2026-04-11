extends GutTest

func test_get_stage_name_childhood() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 0
	assert_eq(AgeSystem.get_stage_name(), "童年", "stage 0 应为童年")
	AgeSystem.current_stage = old_stage

func test_get_stage_name_youth() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 1
	assert_eq(AgeSystem.get_stage_name(), "青年", "stage 1 应为青年")
	AgeSystem.current_stage = old_stage

func test_get_stage_name_middle_age() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 2
	assert_eq(AgeSystem.get_stage_name(), "中年", "stage 2 应为中年")
	AgeSystem.current_stage = old_stage

func test_get_stage_name_old_age() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 3
	assert_eq(AgeSystem.get_stage_name(), "老年", "stage 3 应为老年")
	AgeSystem.current_stage = old_stage

func test_get_stage_event_pool_childhood() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 0
	var pool: Array[Dictionary] = AgeSystem.get_stage_event_pool()
	assert_true(pool.size() > 0, "童年阶段应有敌人池")
	AgeSystem.current_stage = old_stage

func test_get_stage_event_pool_youth() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 1
	var pool: Array[Dictionary] = AgeSystem.get_stage_event_pool()
	assert_true(pool.size() > 0, "青年阶段应有敌人池")
	AgeSystem.current_stage = old_stage

func test_get_stage_event_pool_middle_age() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 2
	var pool: Array[Dictionary] = AgeSystem.get_stage_event_pool()
	assert_true(pool.size() > 0, "中年阶段应有敌人池")
	AgeSystem.current_stage = old_stage

func test_get_stage_event_pool_old_age() -> void:
	var old_stage: int = AgeSystem.current_stage
	AgeSystem.current_stage = 3
	var pool: Array[Dictionary] = AgeSystem.get_stage_event_pool()
	assert_true(pool.size() > 0, "老年阶段应有敌人池（含BOSS）")
	AgeSystem.current_stage = old_stage

func test_stages_json_age_ranges() -> void:
	var data: Dictionary = ConfigManager.load_json("res://data/stages.json")
	for stage: Dictionary in data.stages:
		var age_range: Dictionary = stage.age_range
		assert_true(age_range.start < age_range.end, "阶段起始年龄应小于结束年龄")

func test_stages_json_enemy_pool_valid_ids() -> void:
	var enemies_data: Dictionary = ConfigManager.load_json("res://data/enemies.json")
	var valid_ids: Array = []
	for enemy: Dictionary in enemies_data.enemies:
		valid_ids.append(enemy.enemy_id)
	var stages_data: Dictionary = ConfigManager.load_json("res://data/stages.json")
	for stage: Dictionary in stages_data.stages:
		for entry: Dictionary in stage.enemy_pool:
			assert_true(entry.id in valid_ids, "阶段敌人池中的 id 应在 enemies.json 中存在: %s" % entry.id)

func test_stages_json_tower_ids_valid() -> void:
	var towers_data: Dictionary = ConfigManager.load_json("res://data/towers.json")
	var valid_ids: Array = []
	for tower: Dictionary in towers_data.towers:
		valid_ids.append(tower.tower_id)
	var stages_data: Dictionary = ConfigManager.load_json("res://data/stages.json")
	for stage: Dictionary in stages_data.stages:
		for tower_id: String in stage.available_towers:
			assert_true(tower_id in valid_ids, "阶段可用塔 id 应在 towers.json 中存在: %s" % tower_id)
