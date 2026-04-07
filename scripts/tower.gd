extends Node2D
class_name Tower

## 配置与状态
var config: TowerConfig
var target: Node2D = null

## 鼠标悬停状态 (使用内嵌 set/get 管理)
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

## 升级系统
var current_level: int = 1
var current_experience: int = 0
var experience_required: int = 100  # 下一级所需经验

## 节点引用（动态创建）
var tower_sprite: Sprite2D
var attack_component: TowerAttackComponent
var experience_bar: ProgressBar  # 经验条 UI
var level_label: Label  # 等级标签
var hover_area: Area2D  # 鼠标悬停检测区域
var collision_shape: CollisionShape2D  # 碰撞形状

## 信号（类型化）
signal target_changed(new_target: Node2D)
signal tower_placed(tower: Tower)
signal level_changed(new_level: int)  # 等级变化信号
signal experience_changed(current: int, required: int)  # 经验变化信号
signal mouse_hover_started(tower: Tower)  # 鼠标悬停开始
signal mouse_hover_ended(tower: Tower)  # 鼠标悬停结束
signal mouse_clicked(tower: Tower)  # 🆕 鼠标点击
signal stats_updated  # 🆕 属性更新信号 (用于通知 UI 刷新)

func _ready() -> void:
	# 验证节点是否已创建
	if not tower_sprite:
		print("[Tower] tower_sprite 未初始化，将在 setup_tower() 中创建")
	if not attack_component:
		print("[Tower] attack_component 未初始化，将在 setup_tower() 中创建")
	
	# 添加到 towers 组
	add_to_group("towers")

func _process(_delta: float) -> void:
	# 🆕 检测鼠标左键点击
	if hover_area and hover_area.global_position.distance_to(get_global_mouse_position()) < 30:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# 🆕 防止重复触发，使用静态变量记录上次点击时间
			var current_time = Time.get_ticks_msec()
			if not has_meta("last_click_time") or current_time - get_meta("last_click_time") > 200:
				set_meta("last_click_time", current_time)
				print("[Tower] _process 检测到点击！发射 mouse_clicked 信号")
				mouse_clicked.emit(self)

func initialize(tower_config: TowerConfig) -> void:
	config = tower_config
	config.init_projectile_scene()
	setup_tower()
	tower_placed.emit(self)

func setup_tower() -> void:
	if not config:
		push_error("[Tower] 配置为空！")
		return
	
	# 创建精灵（如果还没有创建）
	if not tower_sprite:
		tower_sprite = Sprite2D.new()
		tower_sprite.z_index = 10
		add_child(tower_sprite)
	
	# 设置精灵（使用 AssetsManager 加载）
	if config.texture_path != "":
		var texture: Texture2D = AssetsManager.load_image(config.texture_path) as Texture2D
		if texture:
			tower_sprite.texture = texture
			tower_sprite.scale = Vector2(0.78, 0.78)
		else:
			print("[Tower] 无法加载纹理：%s" % config.texture_path)
	
	# 创建攻击组件（如果还没有创建）
	if not attack_component:
		attack_component = TowerAttackComponent.new()
		attack_component.tower = self
		add_child(attack_component)
	
	# 配置攻击组件
	attack_component.config = config
	attack_component.setup_timer()
	
	# 初始化升级系统
	init_level_system()
	
	# 创建经验条和等级标签
	setup_experience_ui()
	
	# 创建鼠标悬停检测区域
	setup_hover_area()

func get_attack_range() -> float:
	return config.attack_range if config else 0.0

func set_target(new_target: Node2D) -> void:
	target = new_target
	target_changed.emit(new_target)
	if attack_component:
		attack_component.target = new_target

## 初始化升级系统
func init_level_system() -> void:
	current_level = 1
	current_experience = 0
	experience_required = config.get_experience_for_next_level(current_level)
	update_tower_stats()
	experience_changed.emit(current_experience, experience_required)

## 创建经验条 UI
func setup_experience_ui() -> void:
	# 创建经验条（在塔的下方）
	experience_bar = ProgressBar.new()
	experience_bar.custom_minimum_size = Vector2(40, 6)
	experience_bar.max_value = experience_required
	experience_bar.value = current_experience
	experience_bar.show_percentage = false
	experience_bar.position = Vector2(-20, 25)  # 在塔下方居中
	experience_bar.z_index = 15
	add_child(experience_bar)
	
	# 设置经验条样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # 深色背景
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.5, 0.2, 0.8, 1.0)  # 紫色经验条
	experience_bar.add_theme_stylebox_override("background", style)
	experience_bar.add_theme_stylebox_override("fill", fill_style)
	
	# 创建等级标签
	level_label = Label.new()
	level_label.text = "Lv.1"
	level_label.position = Vector2(-15, 8)  # 在经验条上方
	level_label.z_index = 16
	level_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	level_label.add_theme_font_size_override("font_size", 10)
	add_child(level_label)
	
	# 连接信号
	experience_changed.connect(_on_experience_changed)
	level_changed.connect(_on_level_changed)

## 经验变化处理
func _on_experience_changed(current: int, required: int) -> void:
	if experience_bar:
		experience_bar.max_value = required
		experience_bar.value = current

## 等级变化处理
func _on_level_changed(new_level: int) -> void:
	if level_label:
		level_label.text = "Lv.%d" % new_level
	# 升级时播放特效（可选）
	if experience_bar:
		# 闪烁效果
		var tween = create_tween()
		tween.tween_property(experience_bar, "modulate", Color(1, 1, 1, 0.5), 0.1)
		tween.tween_property(experience_bar, "modulate", Color(1, 1, 1, 1), 0.1)

## 添加经验值
func add_experience(amount: int) -> void:
	if current_level >= config.max_level:
		return  # 已达到最大等级
	
	current_experience += amount
	print("[Tower] 获得经验：%d (当前：%d/%d)" % [amount, current_experience, experience_required])
	experience_changed.emit(current_experience, experience_required)
	
	# 检查是否可以升级
	while current_experience >= experience_required and current_level < config.max_level:
		level_up()

## 升级
func level_up() -> void:
	if current_level >= config.max_level:
		print("[Tower] 已达到最大等级：%d" % current_level)
		return
	
	current_level += 1
	current_experience -= experience_required
	experience_required = config.get_experience_for_next_level(current_level)
	
	# 更新属性
	update_tower_stats()
	
	# 发送升级信号
	level_changed.emit(current_level)
	
	print("[Tower] 升级到 %d 级！" % current_level)

## 更新塔的属性（基于等级）
func update_tower_stats() -> void:
	if not attack_component or not config:
		return
	
	# 更新攻击组件的属性
	attack_component.config.damage = config.get_damage_at_level(current_level)
	attack_component.config.attack_speed = config.get_attack_speed_at_level(current_level)
	attack_component.config.attack_range = config.get_attack_range_at_level(current_level)
	
	# 重置攻击计时器以应用新的攻速
	attack_component.setup_timer()
	
	# 🆕 发出属性更新信号，通知 UI 刷新显示
	stats_updated.emit()

## 创建鼠标悬停检测区域
func setup_hover_area() -> void:
	hover_area = Area2D.new()
	hover_area.name = "HoverArea"
	hover_area.z_index = 20
	
	# 🆕 设置碰撞层和掩码（确保能接收鼠标事件）
	hover_area.collision_layer = 1
	hover_area.collision_mask = 1
	
	# 创建碰撞形状
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 40)  # 根据塔的大小调整
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO
	
	hover_area.add_child(collision_shape)
	add_child(hover_area)
	
	# 连接鼠标悬停信号
	hover_area.mouse_entered.connect(_on_hover_area_mouse_entered)
	hover_area.mouse_exited.connect(_on_hover_area_mouse_exited)
	
	# 🆕 连接鼠标点击信号（通过 InputEvent）
	hover_area.input_event.connect(_on_hover_area_input_event)

## 🆕 处理 HoverArea 的输入事件
func _on_hover_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[Tower] 检测到点击！发射 mouse_clicked 信号")
		mouse_clicked.emit(self)

## 鼠标悬停区域信号处理
func _on_hover_area_mouse_entered() -> void:
	is_mouse_hovering = true

func _on_hover_area_mouse_exited() -> void:
	is_mouse_hovering = false

## 获取实时信息用于 UI 显示
func get_tower_info_for_ui() -> String:
	if not config:
		return ""
	var info: String = "%s (Lv.%d)\n" % [config.tower_name, current_level]
	info += "━━━━━━━━━━━━━━━\n"
	info += "⚔ 伤害：%.0f\n" % config.damage
	info += "🎯 射程：%.0f\n" % config.attack_range
	info += "⚡ 攻速：%.1f/s" % config.attack_speed
	return info
func get_tower_info_text() -> String:
	if not config or not attack_component:
		return ""
	
	var info_text = "%s (Lv.%d)\n" % [config.tower_name, current_level]
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += "💰 造价：%d\n" % config.cost
	info_text += "⚔ 伤害：%.0f\n" % attack_component.config.damage
	info_text += "🎯 射程：%.0f\n" % attack_component.config.attack_range
	info_text += "⚡ 攻速：%.1f/s\n" % attack_component.config.attack_speed
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += "⭐ 经验：%d/%d" % [current_experience, experience_required]
	
	return info_text
