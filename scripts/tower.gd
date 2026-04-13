extends Node2D
class_name Tower

const AttackMode = preload("res://scripts/config/attack_types.gd").AttackMode

var config: TowerConfig
var target: Node2D = null

var is_mouse_hovering: bool = false:
	set(value):
		if is_mouse_hovering != value:
			is_mouse_hovering = value
			if is_mouse_hovering:
				mouse_hover_started.emit(self)
			else:
				mouse_hover_ended.emit(self)
	get:
		return is_mouse_hovering

var current_level: int = 1
var current_experience: int = 0
var experience_required: int = 100

var tower_sprite: Sprite2D
var attack_component: TowerAttackComponent
var experience_bar: ProgressBar
var level_label: Label
var hover_area: Area2D
var collision_shape: CollisionShape2D

var is_selected: bool = false
var _selection_indicator: ColorRect = null

signal target_changed(new_target: Node2D)
signal tower_placed(tower: Tower)
signal level_changed(new_level: int)
signal experience_changed(current: int, required: int)
signal mouse_hover_started(tower: Tower)
signal mouse_hover_ended(tower: Tower)
signal mouse_clicked(tower: Tower)
signal stats_updated

func _ready() -> void:
	if not tower_sprite:
		Global.debug_log("[Tower] tower_sprite 未初始化，将在 setup_tower() 中创建")
	if not attack_component:
		Global.debug_log("[Tower] attack_component 未初始化，将在 setup_tower() 中创建")

	add_to_group("towers")

func _process(_delta: float) -> void:
	if hover_area and hover_area.global_position.distance_to(get_global_mouse_position()) < 30:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var current_time: int = Time.get_ticks_msec()
			if not has_meta("last_click_time") or current_time - get_meta("last_click_time") > 200:
				set_meta("last_click_time", current_time)
				Global.debug_log("[Tower] _process 检测到点击！发射 mouse_clicked 信号")
				mouse_clicked.emit(self)

func initialize(tower_config: TowerConfig) -> void:
	config = tower_config
	set_meta("tower_id", tower_config.tower_id)
	config.init_projectile_scene()
	setup_tower()
	tower_placed.emit(self)

func setup_tower() -> void:
	if not config:
		push_error("[Tower] 配置为空！")
		return

	if not tower_sprite:
		tower_sprite = Sprite2D.new()
		tower_sprite.z_index = 10
		add_child(tower_sprite)

	if config.texture_path != "":
		var texture: Texture2D = AssetsManager.load_image(config.texture_path) as Texture2D
		if texture:
			tower_sprite.texture = texture
			tower_sprite.scale = Vector2(0.78, 0.78)
		else:
			tower_sprite.texture = _create_placeholder_texture()
			tower_sprite.scale = Vector2(0.78, 0.78)

	if not attack_component:
		attack_component = TowerAttackComponent.new()
		attack_component.tower = self
		add_child(attack_component)

	attack_component.config = config
	if config.attack_mode == AttackMode.NONE:
		Global.debug_log("[Tower] %s 为技能塔，跳过攻击组件初始化" % config.tower_name)
	else:
		attack_component.setup_timer()
		Global.debug_log("[Tower] %s 初始化完成 - 攻击模式：%d (0=近战,1=远程,2=无), 攻击范围：%.0f, 索敌范围：%.0f, 攻速：%.1f" % [
			config.tower_name, config.attack_mode, config.attack_range,
			config.detection_range, config.attack_speed
		])

	init_level_system()

	setup_experience_ui()

	setup_hover_area()

func get_attack_range() -> float:
	return config.attack_range if config else 0.0

func set_target(new_target: Node2D) -> void:
	target = new_target
	target_changed.emit(new_target)
	if attack_component:
		attack_component.target = new_target

func init_level_system() -> void:
	current_level = 1
	current_experience = 0
	experience_required = config.get_experience_for_next_level(current_level)
	update_tower_stats()
	experience_changed.emit(current_experience, experience_required)

func setup_experience_ui() -> void:
	experience_bar = ProgressBar.new()
	experience_bar.custom_minimum_size = Vector2(40, 6)
	experience_bar.max_value = experience_required
	experience_bar.value = current_experience
	experience_bar.show_percentage = false
	experience_bar.position = Vector2(-20, 25)
	experience_bar.z_index = 15
	add_child(experience_bar)

	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.5, 0.2, 0.8, 1.0)
	experience_bar.add_theme_stylebox_override("background", bg_style)
	experience_bar.add_theme_stylebox_override("fill", fill_style)

	level_label = Label.new()
	level_label.text = "Lv.1"
	level_label.position = Vector2(-15, 8)
	level_label.z_index = 16
	level_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	level_label.add_theme_font_size_override("font_size", 10)
	add_child(level_label)

	experience_changed.connect(_on_experience_changed)
	level_changed.connect(_on_level_changed)

func _on_experience_changed(current: int, required: int) -> void:
	if experience_bar:
		experience_bar.max_value = required
		experience_bar.value = current

func _on_level_changed(new_level: int) -> void:
	if level_label:
		level_label.text = "Lv.%d" % new_level
	if experience_bar:
		var tween: Tween = create_tween()
		tween.tween_property(experience_bar, "modulate", Color(1, 1, 1, 0.5), 0.1)
		tween.tween_property(experience_bar, "modulate", Color(1, 1, 1, 1), 0.1)

func add_experience(exp_amount: int) -> void:
	if current_level >= config.max_level:
		return

	current_experience += exp_amount
	Global.debug_log("[Tower] 获得经验：%d (当前：%d/%d)" % [exp_amount, current_experience, experience_required])
	experience_changed.emit(current_experience, experience_required)

	while current_experience >= experience_required and current_level < config.max_level:
		level_up()

func level_up() -> void:
	if current_level >= config.max_level:
		Global.debug_log("[Tower] 已达到最大等级：%d" % current_level)
		return

	current_level += 1
	current_experience -= experience_required
	experience_required = config.get_experience_for_next_level(current_level)

	update_tower_stats()

	level_changed.emit(current_level)

	Global.debug_log("[Tower] 升级到 %d 级！" % current_level)

func update_tower_stats() -> void:
	if not attack_component or not config:
		return

	var new_damage: float = config.get_damage_at_level(current_level)
	var new_attack_speed: float = config.get_attack_speed_at_level(current_level)
	var new_attack_range: float = config.get_attack_range_at_level(current_level)

	config.damage = new_damage
	config.attack_speed = new_attack_speed
	config.attack_range = new_attack_range

	attack_component.config.damage = new_damage
	attack_component.config.attack_speed = new_attack_speed
	attack_component.config.attack_range = new_attack_range

	attack_component.setup_timer()

	stats_updated.emit()

func setup_hover_area() -> void:
	hover_area = Area2D.new()
	hover_area.name = "HoverArea"
	hover_area.z_index = 20
	hover_area.collision_layer = 1
	hover_area.collision_mask = 1
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(40, 40)
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO
	hover_area.add_child(collision_shape)
	add_child(hover_area)
	hover_area.mouse_entered.connect(_on_hover_area_mouse_entered)
	hover_area.mouse_exited.connect(_on_hover_area_mouse_exited)
	hover_area.input_event.connect(_on_hover_area_input_event)

func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	if is_selected:
		if not _selection_indicator:
			_selection_indicator = ColorRect.new()
			_selection_indicator.size = Vector2(80, 80)
			_selection_indicator.position = Vector2(-40, -40)
			_selection_indicator.z_index = 9
			_selection_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var shader_mat: ShaderMaterial = ShaderMaterial.new()
			var shader: Shader = Shader.new()
			shader.code = "shader_type canvas_item;\nvoid fragment() {\n	vec2 uv = UV;\n	float border = 0.06;\n	float alpha = 0.0;\n	if (uv.x < border || uv.x > 1.0 - border || uv.y < border || uv.y > 1.0 - border) {\n		alpha = 0.9;\n	}\n	float pulse = 0.5 + 0.5 * sin(TIME * 4.0);\n	alpha *= (0.6 + 0.4 * pulse);\n	COLOR = vec4(1.0, 0.85, 0.2, alpha);\n}"
			shader_mat.shader = shader
			_selection_indicator.material = shader_mat
			add_child(_selection_indicator)
		_selection_indicator.visible = true
	else:
		if _selection_indicator:
			_selection_indicator.visible = false

func _on_hover_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.debug_log("[Tower] 检测到点击！发射 mouse_clicked 信号")
		mouse_clicked.emit(self)

func _on_hover_area_mouse_entered() -> void:
	is_mouse_hovering = true

func _on_hover_area_mouse_exited() -> void:
	is_mouse_hovering = false

func _create_placeholder_texture() -> ImageTexture:
	var img_size: int = 64
	var image: Image = Image.create(img_size, img_size, false, Image.FORMAT_RGBA8)
	var fill_color: Color = Color(0.3, 0.6, 0.9, 1.0) if config and config.damage_type == 1 else Color(0.9, 0.5, 0.3, 1.0)
	image.fill(fill_color)
	var border: int = 4
	for y: int in range(img_size):
		for x: int in range(img_size):
			if x < border or x >= img_size - border or y < border or y >= img_size - border:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.8))
	var center: int = floori(img_size / 2.0)
	var inner_size: int = 20
	var half_inner: int = floori(inner_size / 2.0)
	for y: int in range(center - half_inner, center + half_inner):
		for x: int in range(center - half_inner, center + half_inner):
			if x >= 0 and x < img_size and y >= 0 and y < img_size:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.9))
	return ImageTexture.create_from_image(image)

func get_tower_info_text() -> String:
	if not config or not attack_component:
		return ""

	var info_text: String = "%s (Lv.%d)\n" % [config.tower_name, current_level]
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += "💰 造价：%d\n" % config.cost
	info_text += "⚔ 伤害：%.0f\n" % attack_component.config.damage
	info_text += "🎯 射程：%.0f\n" % attack_component.config.attack_range
	info_text += "⚡ 攻速：%.1f/s\n" % attack_component.config.attack_speed
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += "⭐ 经验：%d/%d" % [current_experience, experience_required]

	return info_text
