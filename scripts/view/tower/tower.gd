## 防御塔视图节点。管理塔的渲染、升级、经验、Buff 和销毁流程。
## 由 MapManager.build_tower() 创建并挂载到场景树。
extends Node2D
class_name Tower

const AttackMode = GameConfig.AttackMode

var config: TowerBean
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
var name_label: Label

var is_selected: bool = false
var is_destroyed: bool = false
var is_attack_enabled: bool = true
var _selection_indicator: ColorRect = null

var _buff_damage_bonus: float = 0.0
var _buff_speed_bonus: float = 0.0
var _buff_timer: float = 0.0
var _base_damage: float = 0.0
var _base_attack_speed: float = 0.0

## 目标切换时发射
signal target_changed(new_target: Node2D)
## 塔放置到场景后发射
signal tower_placed(tower: Tower)
## 等级变化时发射
signal level_changed(new_level: int)
## 经验值变化时发射
signal experience_changed(current: int, required: int)
## 鼠标悬停开始
signal mouse_hover_started(tower: Tower)
## 鼠标悬停结束
signal mouse_hover_ended(tower: Tower)
## 鼠标点击塔
signal mouse_clicked(tower: Tower)
## 属性更新后发射（供信息面板刷新）
signal stats_updated

func _ready() -> void:
	if not tower_sprite:
		Global.debug_log("[Tower] tower_sprite 未初始化，将在 setup_tower() 中创建")
	if not attack_component:
		Global.debug_log("[Tower] attack_component 未初始化，将在 setup_tower() 中创建")

	add_to_group("towers")

var _click_cooldown: int = 0

func _process(delta: float) -> void:
	_update_buff(delta)
	var mouse_pos: Vector2 = get_global_mouse_position()
	var half: float = 20.0
	var rect: Rect2 = Rect2(global_position - Vector2(half, half), Vector2(40, 40))
	var is_inside: bool = rect.has_point(mouse_pos)
	if is_inside != is_mouse_hovering:
		is_mouse_hovering = is_inside
	if is_inside and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var now: int = Time.get_ticks_msec()
		if now - _click_cooldown > 300:
			_click_cooldown = now
			mouse_clicked.emit(self)

## 用配置初始化塔：设置元数据、创建精灵和攻击组件、注册光环/被动
func initialize(tower_config: TowerBean) -> void:
	config = tower_config
	set_meta("tower_id", tower_config.tower_id)
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

	var texture: Texture2D = AssetsManager.load_image(config.texture_path) as Texture2D
	tower_sprite.texture = texture
	tower_sprite.scale = Vector2(0.78, 0.78)

	if not attack_component:
		attack_component = TowerAttackComponent.new()
		attack_component.tower = self
		add_child(attack_component)

	attack_component.config = config
	_base_damage = config.damage
	_base_attack_speed = config.attack_speed
	if config.attack_mode == AttackMode.NONE:
		Global.debug_log("[Tower] %s 为技能塔，跳过攻击组件初始化" % config.get_display_name())
	else:
		attack_component.setup_timer()
		Global.debug_log("[Tower] %s 初始化完成 - 攻击模式：%d (0=近战,1=远程,2=无), 攻击范围：%.0f, 索敌范围：%.0f, 攻速：%.1f" % [
			config.get_display_name(), config.attack_mode, config.attack_range,
			config.detection_range, config.attack_speed
		])

	init_level_system()
	setup_experience_ui()
	_setup_name_label()
	_register_aura_if_needed()
	_register_passive_if_needed()

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
	experience_required = TowerConfig.get_experience_for_next_level(config, current_level)
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

func _setup_name_label() -> void:
	if not config:
		return
	name_label = Label.new()
	name_label.text = config.get_display_name()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-40, -30)
	name_label.z_index = 17
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	add_child(name_label)

func _register_aura_if_needed() -> void:
	if not config:
		return
	var is_aura: bool = config.effect_type == GameConfig.EffectType.SLOW_AURA or config.effect_type == GameConfig.EffectType.BUFF_AURA
	if not is_aura:
		return
	var es: Node = get_node_or_null("/root/EffectSystem")
	if not es or not es.has_method("apply_effect"):
		return
	es.apply_effect(config.effect_type, config.effect_params, self, self)

func _register_passive_if_needed() -> void:
	if not config or config.passive_effect.is_empty():
		return
	var es: Node = get_node_or_null("/root/EffectSystem")
	if es and es.has_method("register_passive"):
		es.register_passive(self)

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

## 添加经验值，满足升级条件时自动升级（可连续升级）
func add_experience(exp_amount: int) -> void:
	if current_level >= config.max_level:
		return

	current_experience += exp_amount
	Global.debug_log("[Tower] 获得经验：%d (当前：%d/%d)" % [exp_amount, current_experience, experience_required])

	while current_experience >= experience_required and current_level < config.max_level:
		level_up()

	experience_changed.emit(current_experience, experience_required)

## 升级：扣除经验、重算属性、发射信号
func level_up() -> void:
	if current_level >= config.max_level:
		Global.debug_log("[Tower] 已达到最大等级：%d" % current_level)
		return

	current_level += 1
	current_experience -= experience_required
	experience_required = TowerConfig.get_experience_for_next_level(config, current_level)

	update_tower_stats()

	level_changed.emit(current_level)

	Global.debug_log("[Tower] 升级到 %d 级！" % current_level)

## 根据当前等级重算伤害/攻速/范围，同步到攻击组件并重设定时器
func update_tower_stats() -> void:
	if not attack_component or not config:
		return
	if config.attack_mode == AttackMode.NONE:
		return

	var new_damage: float = TowerConfig.get_damage_at_level(config, current_level)
	var new_attack_speed: float = TowerConfig.get_attack_speed_at_level(config, current_level)
	var new_attack_range: float = TowerConfig.get_attack_range_at_level(config, current_level)

	config.damage = new_damage
	config.attack_speed = new_attack_speed
	config.attack_range = new_attack_range

	attack_component.config.damage = new_damage
	attack_component.config.attack_speed = new_attack_speed
	attack_component.config.attack_range = new_attack_range

	attack_component.setup_timer()

	stats_updated.emit()

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

## 销毁塔：移除光环/被动、在原位创建废墟、释放节点
func destroy() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	var slot_idx: int = -1
	if has_meta("slot_index"):
		slot_idx = get_meta("slot_index")
	Global.debug_log("[Tower] %s 开始销毁流程，slot_index=%d" % [(config.get_display_name() if config else "未知"), slot_idx])
	var mm: Node = get_node_or_null("/root/MapManager")
	if mm and mm.has_method("remove_built_tower"):
		mm.remove_built_tower(self)
	if mm and mm.has_method("build_ruins_at_slot") and slot_idx >= 0:
		mm.build_ruins_at_slot(slot_idx)
		Global.debug_log("[Tower] 已请求在 slot %d 创建废墟" % slot_idx)
	else:
		Global.debug_log("[Tower] 无法创建废墟：mm=%s, slot_idx=%d" % [str(mm != null), slot_idx])
	var es: Node = get_node_or_null("/root/EffectSystem")
	if es and es.has_method("remove_aura_for_tower"):
		es.remove_aura_for_tower(self)
	if es and es.has_method("unregister_passive"):
		es.unregister_passive(self)
	queue_free()

func get_tower_info_text() -> String:
	if not config:
		return ""

	if not attack_component:
		return ""

	var info_text: String = "%s (Lv.%d)\n" % [config.get_display_name(), current_level]
	if config.effect_id != "":
		info_text += "\n" + config.effect_icon + " " + config.get_display_effect_name() + " — " + config.get_display_effect_desc()
	for sub: Dictionary in config.sub_effects:
		var sub_eid: String = sub.get("effect_id", "")
		if sub_eid != "":
			var sec: SpecialEffectConfig = SpecialEffectConfig.new()
			info_text += "\n" + sec.get_effect_icon(sub_eid) + " " + sec.get_display_name(sub_eid) + " — " + sec.get_display_desc(sub_eid)
	if not config.passive_effect.is_empty():
		var ptype: String = config.passive_effect.get("type", "")
		if ptype == "global_gold_bonus":
			var bonus_val: float = float(config.passive_effect.get("gold_bonus", 0.0))
			info_text += "\n💰 " + tr("PASSIVE_GLOBAL_GOLD_BONUS") % (bonus_val * 100.0)
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += tr("TOWER_INFO_COST") % config.cost + "\n"
	info_text += tr("TOWER_INFO_DAMAGE") % attack_component.config.damage + "\n"
	info_text += tr("TOWER_INFO_RANGE") % attack_component.config.attack_range + "\n"
	info_text += tr("TOWER_INFO_SPEED") % attack_component.config.attack_speed + "\n"
	info_text += "━━━━━━━━━━━━━━━\n"
	info_text += tr("TOWER_EXP") % [current_experience, experience_required, config.cost]

	return info_text

## 应用 Buff：取最大值叠加，不刷新则延长持续时间
func apply_buff(damage_bonus: float, speed_bonus: float, duration: float) -> void:
	_buff_damage_bonus = maxf(_buff_damage_bonus, damage_bonus)
	_buff_speed_bonus = maxf(_buff_speed_bonus, speed_bonus)
	_buff_timer = maxf(_buff_timer, duration)
	if attack_component and _base_attack_speed > 0:
		attack_component.setup_timer_with_buffs(_buff_damage_bonus, _buff_speed_bonus)

func _update_buff(delta: float) -> void:
	if _buff_timer <= 0.0:
		return
	_buff_timer -= delta
	if _buff_timer <= 0.0:
		_buff_timer = 0.0
		_buff_damage_bonus = 0.0
		_buff_speed_bonus = 0.0
		if attack_component and _base_attack_speed > 0:
			attack_component.setup_timer_with_buffs(0.0, 0.0)
