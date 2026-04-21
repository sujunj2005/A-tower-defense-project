# Godot 4.x Area2D 鼠标信号不可靠与并行交互系统踩坑

> **适用版本**: Godot 4.x（特别是 4.6+）
> **严重级别**: 🔴 高（两个问题均为 🔴强制 规则）
> **发现日期**: 2026-04-20
> **来源**: 塔防项目实战踩坑

---

## §66 Area2D 的 mouse_entered/mouse_exited 信号不可靠 🔴 高

### 问题描述

Area2D 创建后，`mouse_entered`/`mouse_exited` 信号完全不触发，即使以下条件全部满足：
- `input_pickable = true`
- `collision_layer` / `collision_mask` 正确设置
- `CollisionShape2D` 已添加且有效

同时 `input_event` 信号中的 `InputEventMouseMotion` 也不触发。但 `input_event` 中的 `InputEventMouseButton` 点击事件可以触发（不稳定）。

### 根因分析

Godot 4 中 Area2D 的鼠标检测信号在特定场景下可能完全不工作，且**无任何错误提示**。已知的不工作场景包括：

1. **CanvasLayer 叠加**：当 Area2D 所在节点与 CanvasLayer 下的 Control 节点叠加时，鼠标事件被 Control 拦截
2. **Control 节点遮挡**：即使 Control 设置了 `mouse_filter = IGNORE`，某些情况下仍会拦截 Area2D 的鼠标事件
3. **视口变换**：非默认视口或经过变换的视口下，Area2D 的鼠标坐标计算可能出错
4. **Z-index 层级**：多个 Area2D 叠加时，鼠标信号的触发不稳定

### 错误做法

```gdscript
# ❌ 错误：依赖 Area2D 的鼠标信号做悬停检测
extends Area2D

signal hovered
signal unhovered

func _ready() -> void:
    mouse_entered.connect(func(): hovered.emit())
    mouse_exited.connect(func(): unhovered.emit())
    input_event.connect(_on_input_event)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseMotion:
        # 可能永远不触发！
        print("鼠标移动")
    if event is InputEventMouseButton:
        # 不稳定触发
        print("鼠标点击")
```

### 正确做法

**不要依赖 Area2D 的 mouse_entered/mouse_exited/input_event 做鼠标悬停检测**，改用 `_process()` 中的 `Rect2.has_point(get_global_mouse_position())` 矩形碰撞检测，这是唯一可靠的方式。

```gdscript
# ✅ 正确：使用 _process + Rect2 矩形碰撞检测
extends Node2D

var is_mouse_hovering: bool = false
var hover_rect: Rect2  # 在 _ready() 或 setup() 中初始化

func _ready() -> void:
    # 根据碰撞形状计算矩形区域
    var shape: CollisionShape2D = $CollisionShape2D
    var rect_shape: RectangleShape2D = shape.shape as RectangleShape2D
    if rect_shape:
        hover_rect = Rect2(
            global_position - rect_shape.size / 2.0,
            rect_shape.size
        )

func _process(_delta: float) -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var was_hovering: bool = is_mouse_hovering
    is_mouse_hovering = hover_rect.has_point(mouse_pos)

    if is_mouse_hovering and not was_hovering:
        _on_mouse_entered()
    elif not is_mouse_hovering and was_hovering:
        _on_mouse_exited()

func _on_mouse_entered() -> void:
    # 悬停进入逻辑
    pass

func _on_mouse_exited() -> void:
    # 悬停离开逻辑
    pass
```

### 对于圆形碰撞区域

```gdscript
# ✅ 圆形碰撞区域用距离检测
var hover_center: Vector2
var hover_radius: float

func _process(_delta: float) -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var was_hovering: bool = is_mouse_hovering
    is_mouse_hovering = mouse_pos.distance_to(hover_center) <= hover_radius

    if is_mouse_hovering and not was_hovering:
        _on_mouse_entered()
    elif not is_mouse_hovering and was_hovering:
        _on_mouse_exited()
```

### 规则

🔴 **强制**：禁止使用 Area2D 的 mouse_entered/mouse_exited/input_event 信号做鼠标悬停检测。必须使用 `_process()` 中的 `Rect2.has_point()` 或距离检测实现。

### 关联踩坑

此问题是 §67 的直接诱因——因为 Area2D 鼠标信号不可靠，开发者创建了轮询系统作为替代方案，但未删除旧系统，导致两套并行系统并存。

---

## §67 多套并行交互系统导致隐蔽 Bug 🔴 高

### 问题描述

项目中存在三套独立的 tooltip/悬停系统：
1. **MapManager 轮询系统**：`_update_tower_hover()` 每帧轮询检测鼠标位置
2. **TowerSelectUI 信号系统**：基于 Area2D 的 mouse_entered/mouse_exited 信号
3. **TooltipManager**：独立的 tooltip 显示管理

战斗场景实际使用的是 MapManager 的轮询机制，但开发者一直以为走的是 TowerSelectUI 的信号路径，导致所有针对信号路径的修复都无效。

### 根因分析

MapManager._update_tower_hover() 是每帧轮询检测鼠标位置的独立系统，完全绕过了 Tower 的 Area2D/信号系统。两套系统并存但互不通信，导致：

1. **Tower 的 is_mouse_hovering 在战斗场景永远为 false**：因为战斗场景走的是 MapManager 轮询，Tower 的 Area2D 信号从未触发
2. **两套系统维护两份 tooltip 文本生成逻辑**：翻译键 bug 只在其中一套出现
3. **map_manager._show_tower_info() 中直接用了 `cfg.tower_name`（翻译键）**而不是 `cfg.get_display_name()`（已翻译名），因为轮询系统是独立开发的，没有复用 TowerBean 的翻译方法

### 错误做法

```gdscript
# ❌ 错误：三套独立的悬停/tooltip系统并存

# 系统1：MapManager 轮询（战斗场景实际使用）
func _update_tower_hover() -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    for tower in built_towers.values():
        if is_instance_valid(tower):
            var rect := Rect2(tower.global_position - Vector2(24, 24), Vector2(48, 48))
            if rect.has_point(mouse_pos):
                _show_tower_info(tower)  # 独立的显示逻辑
                return
    _hide_tower_info()

# 系统2：Tower Area2D 信号（战斗场景不使用）
func _ready() -> void:
    $Area2D.mouse_entered.connect(_on_mouse_entered)
    $Area2D.mouse_exited.connect(_on_mouse_exited)

# 系统3：TooltipManager（另一套独立逻辑）
func show_tooltip(text: String, position: Vector2) -> void:
    # 独立的 tooltip 显示逻辑
    pass
```

### 正确做法

**同一交互功能只能有一条实现路径**，禁止"备用"或"并行"系统。如果需要重构，先删除旧系统再实现新系统，绝不允许两套并存。

**关键认知**：问题的严重之处不在于"有两套代码"，而在于**两套机制同时在运行，开发者却不知道**。其中一套是每帧轮询（性能浪费），另一套是信号驱动（从未生效），两者互不通信，导致所有针对信号路径的修复全部无效。

```gdscript
# ✅ 正确：Tower 自身用 _process + Rect2 检测悬停，发射信号
# tower.gd
func _process(_delta: float) -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var rect: Rect2 = Rect2(global_position - Vector2(20, 20), Vector2(40, 40))
    var is_inside: bool = rect.has_point(mouse_pos)
    if is_inside != is_mouse_hovering:
        is_mouse_hovering = is_inside  # setter 自动发射信号

# ✅ 正确：MapManager 只需连接信号，不做轮询
# map_manager.gd
func _build_tower(slot_index: int, tower_config: TowerBean) -> void:
    var tower: Tower = Tower.new()
    # ...
    tower.mouse_hover_started.connect(_on_tower_hover_started)
    tower.mouse_hover_ended.connect(_on_tower_hover_ended)

func _on_tower_hover_started(tower: Tower) -> void:
    hovered_tower = tower
    _show_tower_hover_ui(tower)

func _on_tower_hover_ended(tower: Tower) -> void:
    if hovered_tower == tower:
        hovered_tower = null
        _hide_tower_hover_ui()

func _show_tower_info(tower: Tower) -> void:
    var cfg: TowerBean = tower.config
    # ✅ 复用 TowerBean 的翻译方法，不直接用翻译键
    var info: String = "%s (Lv.%d)\n" % [cfg.get_display_name(), tower.current_level]
```

### 重构步骤

```
1. 用 Grep 搜索所有 emit/connect 确认当前有几条交互路径在运行
2. 如果发现多条路径并存 → 立即停止，先搞清楚哪条在生效
3. 删除所有未生效的路径（不要保留"备用"）
4. 删除轮询机制，改用信号驱动（Tower._process 检测 → 发射信号 → Manager 处理）
5. 确保唯一路径复用翻译方法（cfg.get_display_name()），不直接用翻译键（cfg.tower_name）
6. 运行测试验证功能完整
7. Grep 确认无残留的并行系统代码
```

### 规则

🔴 **强制**：禁止为同一功能实现多套并行系统。同一交互功能只能有一条实现路径。如果需要重构，先删除旧系统再实现新系统，绝不允许两套并存。本项目对同一功能的多套系统**零容忍**，发现即重构。

🔴 **强制**：禁止轮询机制。不要在 _process 中每帧遍历所有对象做碰撞检测，应让对象自身检测并发射信号，管理器只负责响应信号。

🔴 **强制**：实现新功能或修复 Bug 时，必须扩展搜索范围，用 Grep 搜索项目中所有可能实现同一功能的路径（搜索关键词如 hover、tooltip、click 等）。一旦发现同一功能存在多套系统，即刻重构，零容忍。**假设架构而不是验证架构，是调试失败的根本原因；验证架构才是调试时应该做的事情。**

### 关联踩坑

- §66 Area2D 鼠标信号不可靠（本问题的直接诱因）
- §41 场景切换绕过导致UI不更新（同类问题：多入口导致绕过）
- §60 重复代码导致i18n改造遗漏（同类问题：多份逻辑并存）

---

## 总结

| 章节 | 问题 | 严重性 | 核心规则 |
|------|------|--------|----------|
| §66 | Area2D 鼠标信号不可靠 | 🔴 高 | 禁止使用 Area2D 鼠标信号做悬停检测，改用 Rect2.has_point() |
| §67 | 多套并行交互系统 | 🔴 高 | 同一功能只能有一条实现路径，禁止并行系统 |

**因果链**：§66（Area2D 信号不可靠）→ 开发者创建轮询替代方案 → 未删除旧系统 → §67（两套并行系统并存）→ 隐蔽 Bug
