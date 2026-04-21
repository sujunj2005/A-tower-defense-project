# 代码逻辑偏好

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/best_practices/logic_preferences.rst

---

## 一、概述

本文涵盖 Godot/GDScript 开发中的常见编程决策和最佳实践，帮助你在多种实现方式之间做出明智选择。

---

## 二、GDScript vs 其他语言

### 2.1 何时使用 GDScript？

| 场景 | 推荐语言 | 原因 |
|------|----------|------|
| **游戏逻辑** | GDScript ✅ | 与引擎深度集成，开发效率最高 |
| **原型开发** | GDScript ✅ | 快速迭代 |
| **UI脚本** | GDScript ✅ | 简洁的信号系统 |
| **性能关键算法** | C# / C++ / Rust (GDExtension) | 编译型语言快10-100倍 |
| **跨平台库集成** | C# / GDExtension | 更好的生态支持 |
| **大型团队协作** | C# | 强类型，IDE支持更好 |

### 2.2 GDScript 性能特点

- **解释执行**：比编译语言慢，但对大多数游戏逻辑足够
- **内置类型优化**：Vector2/3、Color、Transform 等是 C++ 实现，速度很快
- **避免频繁创建对象**：Variant/Object 创建有开销
- **利用内置方法**：内置方法通常是 C++ 实现的，比纯GDScript循环快

---

## 三、循环与迭代

### 3.1 循环方式对比

```gdscene
# 方式1：for-in 循环（推荐，最简洁）
for item in array:
    process(item)

# 方式2：索引循环（需要索引时使用）
for i in range(array.size()):
    process(array[i])

# 方式3：while 循环（特定条件时使用）
var i = 0
while i < array.size():
    process(array[i])
    i += 1

# 方式4：反向遍历（删除元素时安全）
for i in range(array.size() - 1, -1, -1):
    if should_remove(array[i]):
        array.remove_at(i)
```

### 3.2 循环内注意事项

```gdscene
# ❌ 避免：循环内重复调用函数/属性
for i in range(10000):
    var node = get_node("Path/To/Node")  # 每次都查找！
    node.do_something()

# ✅ 推荐：循环外缓存引用
var node = get_node("Path/To/Node")
for i in range(10000):
    node.do_something()


# ❌ 避免：循环内创建对象
for i in range(1000):
    var temp = SomeClass.new()  # 每次都分配内存！

# ✅ 推荐：复用对象或使用对象池
var pool: Array = []
for i in range(1000):
    var obj = get_from_pool()  # 从池中获取
    process(obj)
    return_to_pool(obj)        # 归还到池
```

---

## 四、条件判断与分支

### 4.1 if vs match

```gdscene
# if 语句（条件复杂或范围判断时）
if x > 0 and y < 100:
    do_something()
elif is_special_case():
    do_another()
else:
    fallback()


# match 语句（离散值匹配时更清晰）
match state:
    State.IDLE:
        play_idle()
    State.RUN:
        play_run()
    State.JUMP:
        play_jump()
    _:
        push_warning("未知状态: " + str(state))


# 性能提示：
# - 少量分支（< 5）：if 和 match 性能相近
# - 大量分支（≥ 10）：match 通常更快（编译器可优化为跳转表）
# - 范围判断：if 更直观
```

### 4.2 短路求值利用

```gdscene
# ✅ 利用短路求值避免不必要的计算
if object != null and object.is_valid():  # 如果object为null，不会调用is_valid()
    use_object()

if expensive_check() or cheap_check():    # cheap_check为true时不执行expensive_check()
    do_something()

# ❌ 反例：先调用可能失败的操作
if risky_operation().is_success():  # risky_operation() 可能崩溃
    ...
```

### 4.3 三元运算符

```gdscene
# 简单赋值时的简洁写法
var message = is_admin ? "欢迎管理员！" : "欢迎用户！"
var color = health > 50 ? Color.GREEN : Color.RED

# 复杂逻辑还是用 if（可读性优先）
if complex_condition_a and complex_condition_b:
    result = calculate_complex_value()
else:
    result = default_value
```

---

## 五、函数设计

### 5.1 函数长度原则

```
理想长度：10-30 行
上限：~50 行（超过考虑拆分）
原因：
- 短函数更容易理解、测试、复用
- 单一职责原则
- 减少嵌套层级
```

### 5.2 参数设计

```gdscene
# ✅ 推荐：参数清晰，必要时使用具名参数
func move(target: Vector2, speed: float = 100.0, smooth: bool = true):
    pass

# 调用时
move(Vector2(100, 200))                           # 使用默认值
move(Vector2(100, 200), 200.0, false)              # 全部指定
move(Vector2(100, 200), "speed" => 200.0)           # Godot 4.x 具名参数


# ❌ 避免：参数过多（> 5个考虑用字典或Config对象）
func create_enemy(x, y, z, hp, mp, atk, defense, speed, ai_type, ...):
    pass

# ✅ 改进：使用数据类
class EnemyConfig extends Resource:
    var position: Vector3
    var health: int
    var attack: int
    var speed: float
    var ai_type: String

func create_enemy(config: EnemyConfig):
    pass
```

### 5.2 返回值设计

```gdscene
# ✅ 单返回值：直接返回
func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)


# ✅ 多返回值：使用 Dictionary 或 Array
func raycast_result() -> Dictionary:
    return {
        "hit": true,
        "position": hit_position,
        "normal": hit_normal,
        "collider": hit_collider,
        "distance": distance,
    }

var result = raycast_result()
if result["hit"]:
    handle_hit(result["position"], result["collider"])


# ✅ 可能失败的操作：返回空或使用 Error 枚举
func load_save_data(slot: int) -> Dictionary:
    var path = get_save_path(slot)
    if not FileAccess.file_exists(path):
        return {}  # 空字典表示无存档

    var file = FileAccess.open(path, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    return data if not data.has_error() else {}
```

---

## 六、错误处理

### 6.1 异常处理策略

GDScript 没有 try-catch（除 `can_return` 外），使用其他方式：

```gdscene
# 方式1：检查返回值（传统方式）
var file = FileAccess.open(path, FileAccess.READ)
if file == null:
    push_error("无法打开文件: " + path)
    return

var content = file.get_as_text()


# 方式2：assert（仅调试构建生效）
assert(node != null, "节点不应为null")
assert(health >= 0, "血量不能为负")


# 方式3：is_instance_valid（防止已释放节点）
if is_instance_valid(some_node):
    some_node.do_something()


# 方式4：has_method / has_signal（检查接口兼容性）
if target.has_method("take_damage"):
    target.take_damage(amount)

if object.has_signal("interacted"):
    object.interacted.connect(_on_interacted)
```

### 6.2 防御性编程

```gdscene
# ✅ 总是检查外部依赖
func _ready():
    # 安全获取节点
    animation_player = get_node_or_null("AnimationPlayer")
    if animation_player == null:
        push_warning("AnimationPlayer 未找到")

    # 安全连接信号
    if has_node("Button") and $Button.has_signal("pressed"):
        $Button.pressed.connect(_on_pressed)


# ✅ 使用 @onready 延迟初始化
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar
# _ready 时才查找，确保节点已就绪


# ✅ 提供 sensible defaults
@export var max_health: int = 100  # 默认值
@export var move_speed: float = 200.0
```

---

## 七、数学运算偏好

### 7.1 内置函数 vs 手动实现

```gdscene
# ✅ 优先使用内置函数（C++实现，快速）
var result = a.lerp(b, t)           # 线性插值
var result = a.clamp(min_val, max_val)  # 钳制
var result = a.move_toward(b, delta)  # 向目标移动
var angle = a.angle_to(b)           # 两向量夹角
var reflected = b.reflect(normal)   # 反射向量


# ❌ 避免手动实现（除非有特殊需求）
# 手动 lerp：
var manual_lerp = a + (b - a) * t  # 可以工作但稍慢且易出错
```

### 7.2 常见数学选择

| 需求 | 推荐方法 | 避免 |
|------|----------|------|
| **两点间插值** | `lerp()` / `smoothstep()` | 手动线性公式 |
| **角度插值** | `lerp_angle()` | 直接 lerp angles |
| **朝向目标旋转** | `transform.looking_at()` | `atan2` + set_rotation |
| **平滑跟随** | `exp(-speed * delta)` 公式 | 简单 lerp（不平滑） |
| **随机方向** | `Vector2.RIGHT.rotated(randf() * TAU)` | sin/cos 分别计算 |
| **距离检测** | `distance_squared_to()` > `distance_to()` | 后者需要开方 |

### 7.3 性能敏感的数学

```gdscene
# ❌ 避免：频繁的三角函数调用
for i in range(10000):
    x = cos(angle) * radius
    y = sin(angle) * radius
    angle += step

# ✅ 推荐：预先计算或使用查找表
# 或使用旋转矩阵/四元数批量变换

# ❌ 避免：不必要的 sqrt（distance_to 内部会 sqrt）
if a.distance_to(b) < threshold:

# ✅ 推荐：比较平方距离（避免 sqrt）
if a.distance_squared_to(b) < threshold * threshold:


# ✅ 批量向量运算使用 Basis/Transform3D
var basis = Basis()
basis = basis.rotated(axis, angle)  # 一次性旋转整个坐标系
```

---

## 八、内存管理

### 8.1 对象生命周期

```gdscene
# ✅ 正确的清理顺序
func cleanup():
    # 1. 断开信号连接
    signal_name.disconnect(callback)

    # 2. 清理子节点
    for child in get_children():
        child.queue_free()

    # 3. 释放资源引用
    texture = null
    material = null

    # 4. 最后 queue_free 自身
    queue_free()


# ⚠️ 注意：不要在 _notification(NOTIFICATION_PREDELETE) 中访问其他节点
# 它们可能已被释放
```

### 8.2 对象池模式

详见 [Common Patterns 文档](20B_Common_Patterns.md) 中的 Object Pool 章节。

### 8.3 避免内存泄漏

```gdscene
# ❌ 泄漏风险：循环引用
# A 引用 B，B 通过信号回调引用 A
# 如果不断创建而不释放，内存持续增长

# ✅ 解决方案：
# 1. 使用 weakref（弱引用）
var weak_ref = obj.get_weak_ref()
if weak_ref.get_ref():  # 检查是否仍有效
    weak_ref.get_ref().do_something()

# 2. 定期断开不再需要的信号连接
signal_name.disconnect(callback)

# 3. 使用 call_deferrred 延迟断开
call_deferred("_cleanup_old_references")
```

---

## 九、代码组织与架构

### 9.1 文件/类大小

| 类型 | 建议行数 | 说明 |
|------|----------|------|
| **简单组件** | 100-300行 | 单一职责的小功能 |
| **中等复杂度** | 300-600行 | 如完整敌人AI |
| **复杂系统** | 600-1000行 | 如玩家控制器 |
| **超长文件** | > 1000行 | 应拆分为多个类/文件 |

### 9.2 Autoload（全局单例）使用

**适合放在 Autoload 的内容**：
- 游戏管理器（GameManager、LevelManager）
- 事件总线（EventBus / SignalBus）
- 数据管理（DataManager、SaveManager）
- 音频管理（AudioManager）
- 对象池（ObjectPoolManager）

**不适合的内容**：
- 具体游戏实体（Player、Enemy）
- 场景特定逻辑
- UI控件

### 9.3 信号总线模式（Event Bus）

```gdscene
# EventBus.gd (Autoload)
extends Node

signal player_died(player)
signal item_collected(item_id, amount)
signal level_completed(level_id)
signal game_paused()
signal game_resumed()
signal settings_changed(setting_name, new_value)

# 任何地方都可以连接和发射
func emit_player_died(player):
    player_died.emit(player)

# 使用示例
func _ready():
    EventBus.item_collected.connect(_on_item_collected)

func _on_item_collected(item_id: int, amount: int):
    inventory.add_item(item_id, amount)
    ui.show_collection_feedback(item_id, amount)
```

> **优势**：完全解耦通信双方，无需相互引用

---

## 十、调试友好性

### 10.1 日志策略

```gdscene
# 层级化的日志输出
func log_debug(message: String):
    print_debug("[%s] DEBUG: %s" % [name, message])

func log_info(message: String):
    print("[%s] INFO: %s" % [name, message])

func log_warning(message: String):
    push_warning("[%s] WARNING: %s" % [name, message])

func log_error(message: String):
    push_error("[%s] ERROR: %s" % [name, message])


# 条件日志（避免发布版本的性能损失）
if OS.is_debug_build():
    print("详细调试信息: ", detailed_info)
```

### 10.2 可视化调试

```gdscene
# 2D 调试绘制
func _draw():
    if not debug_visible:
        return

    # 绘制检测范围
    draw_arc(position, detection_radius, 0, TAU, 32, Color.YELLOW, 1.0)

    # 绘制视线方向
    draw_line(position, position + facing * sight_distance, Color.RED)

    # 绘制路径
    if path.size() > 1:
        draw_polyline(path, Color.CYAN, 1.0)


# 3D 调试（使用 DebugDraw3D 或 ImmediateMesh）
func _process(delta):
    if Engine.is_editor_hint():
        return  # 编辑器中不绘制调试信息

    DebugDraw3D.draw_sphere(global_position, detection_radius, Color.YELLOW)
    DebugDraw3D.draw_line(global_position, target_position, Color.RED)
```

### 10.3 断言使用

```gdscene
# ✅ 用于验证不变量（应该永远为真的条件）
assert(health >= 0 and health <= max_health, "血量超出有效范围")
assert(speed >= 0, "速度不能为负")
assert(not is_inside_tree() or get_parent() != null, "树中节点必须有父节点")

# ⚠️ assert 仅在调试构建中生效
# 发布版本中会被自动移除，不影响性能
```

---

## 十一、参考链接

- [GDScript 官方文档](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [GDScript 风格指南](01H_Style_Guide.md)
- [静态类型](01E_Static_Typing.md)
- [数据偏好](16B_Data_Preferences.md)
- [场景组织](16A_Scene_Organization.md)
- [通用优化](14A_General_Optimization.md)
- [调试工具](17A_Debugging_Tools.md)
