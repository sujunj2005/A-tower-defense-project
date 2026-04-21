# Godot 4.x 常见踩坑记录

> 适用版本：Godot 4.x | 来源：知识库整合（从各文档提取）

---

## 目录

1. [GDScript 踩坑](#1-gdscript-踩坑)
2. [节点系统踩坑](#2-节点系统-踩坑)
3. [物理系统踩坑](#3-物理系统-踩坑)
4. [UI 系统踩坑](#4-ui-系统-踩坑)
5. [渲染系统踩坑](#5-渲染系统-踩坑)
6. [相关文档](#6-相关文档)

---

## ⭐ 新增：GDScript 警告处理最佳实践

> 详细说明见：[GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md)  
> **代码规范**请查看：[GDScript_Code_Standards.md](../20_Best_Practices/GDScript_Code_Standards.md)

**快速参考：**

| 警告类型 | 严重程度 | 修复建议 | 实战修复数 |
|----------|----------|----------|----------|
| `SHADOWED_VARIABLE` | 🟡 中 | 重命名参数避免与成员变量冲突 | 4 处 |
| `INT_AS_ENUM_WITHOUT_MATCH` | 🟢 低 | 使用整数值 + 注释说明映射关系 | 2 处 |
| `INTEGER_DIVISION` | 🟡 中 | 使用 `/ 2.0` 替代 `/ 2` | 11 处 |
| `INVALID_RESOURCE_UID` | 🟡 中 | 使用 Godot 自动生成的真实 UID | 2 处 |
| `UNUSED_VARIABLE` | 🟡 中 | 删除未使用的变量 | - |
| `RETURN_VALUE_DISCARDED` | 🟡 中 | 正确使用返回值 | - |

**核心原则：**
- 🔴 高优先级：类型安全警告必须修复
- 🟡 中优先级：代码质量警告建议修复
- 🟢 低优先级：兼容性警告可保留但需注释

**批量检查命令：**
```bash
# 搜索整数除法
grep -rn "/ 2[^.0]" --include="*.gd" .

# 搜索变量遮蔽
grep -rn "var target:" --include="*.gd" .
grep -rn "func.*target:" --include="*.gd" .

# 搜索枚举使用
grep -rn "emission_shape = [0-9]" --include="*.gd" .
```

**规范文档：**
- [GDScript_Code_Standards.md](../20_Best_Practices/GDScript_Code_Standards.md) - 完整代码规范标准

---

---

## 1. GDScript 踩坑

### §1 整数除法
```gdscript
var a = 5 / 2      # 结果为 2，不是 2.5！
var b = 5.0 / 2    # 结果为 2.5 ✅
```

### §2 Lambda 变量捕获
```gdscript
var x = 42
var lambda = func (): print(x)  # 按值捕获，之后修改不影响
x = "Hello"
lambda.call()  # 输出 42，不是 "Hello"
```

### §3 类型数组赋值
```gdscript
var a: Array[Node2D] = [Node2D.new()]
var b: Array[Node] = []
b = a  # 错误！类型不兼容
b.assign(a)  # 正确 ✅
```

### §4 @export 在 _init() 中读取
```gdscript
@export var health: int = 100

func _init():
    print(health)  # 返回默认值 100，不是检查器设置的值 ❌

func _ready():
    print(health)  # 正确返回检查器值 ✅
```

### §5 静态变量与 @export/@onready
```gdscript
static var my_var: int  # 错误！不能用于静态变量
@export var my_var: int   # 正确
@onready var my_var       # 正确
```

---

## 2. 节点系统踩坑

### §6 queue_free vs free
```gdscript
node.free()    # 立即删除！后续引用会崩溃 ❌
node.queue_free()  # 延迟到帧末删除 ✅
```

### §7 场景切换时删除当前场景
```gdscript
# ❌ 错误：在信号回调中直接删除
get_tree().change_scene_to_file("res://scene2.tscn")  # 可能崩溃

# ✅ 正确：使用 call_deferred 延迟执行
get_tree().change_scene_to_file.call_deferred("res://scene2.tscn")
```

### §8 add_child 后 _ready() 未调用
```gdscript
var enemy = scene.instantiate()
add_child(enemy)
enemy.setup()  # _ready() 还未调用，需要手动初始化 ❌
```

### §9 循环引用 preload
```gdscript
# a.gd
var b_scene = preload("res://b.tscn")
# b.gd 如果 preload("res://a.tscn") → 循环引用错误
# 解决方案：使用 load() 或 Autoload
```

### §10 get_node 使用节点名称而非类型
```gdscript
$Sprite2D  # 通过名称获取
# 节点重命名后需要更新代码！❌
```

---

## 3. 物理系统踩坑

### §11 move_and_slide 已包含 delta
```gdscript
velocity.y += gravity * delta  # 加速度需要乘 delta ✅
move_and_slide(velocity * delta)  # ❌ 不需要乘 delta！
move_and_slide()  # ✅ 正确
```

### §12 RigidBody 直接设置位置
```gdscript
extends RigidBody3D
func _process(delta):
    position += velocity * delta  # ❌ 会破坏物理模拟！

# ✅ 正确方式：使用 _integrate_forces
func _integrate_forces(state):
    state.linear_velocity = velocity
```

### §13 CollisionShape Scale 必须保持 (1,1)
```gdscript
$CollisionShape2D.scale = Vector2(2, 2)  # ❌ 无效！
# 应该调整 shape 属性的 size/extent
$CollisionShape2D.shape.size = Vector2(64, 64)  # ✅
```

### §14 物理代码必须在 _physics_process
```gdscript
func _process(delta):        # ❌ 不稳定
    move_and_slide()

func _physics_process(delta):  # ✅ 固定时间步长
    move_and_slide()
```

### §15 is_on_floor() 只在 move_and_slide 后有效
```gdscript
move_and_collide(velocity * delta)  # ❌ 不会更新 is_on_floor()
move_and_slide()                   # ✅ 会更新状态
```

---

## 4. UI 系统踩坑

### §16 Control.mouse_filter
```gdscript
mouse_filter = Control.MOUSE_FILTER_IGNORE  # 点击穿透 ✅
mouse_filter = Control.MOUSE_FILTER_STOP     # 拦截点击 ✅
```

### §17 容器内子节点位置被覆盖
```gdscript
# Container 内的子节点 position 会被容器重置
# 不要在 _process 中修改 Container 子节点的 position ❌
```

### §18 锚点预设后手动偏移
```gdscript
anchors_preset = Control.PRESET_CENTER
offset_left = -size.x / 2  # 需要手动调整偏移使控件居中
```

---

## 5. 渲染系统踩坑

### §19 screen_get_scale 平台限制
```gdscript
screen_get_scale()  # 仅 Android、iOS、Linux(Wayland)、macOS、Web 实现
# Windows 上可能返回 1.0 ❌
```

### §20 Vector2/Vector3 内部使用 float32
```gdscript
var v: Vector2 = Vector2(1.0, 2.0)  # GDScript 是 float64
# 但 GPU 内部是 float32，可能有精度损失 ⚠️
```

### §21 3D 旋转避免欧拉角
```gdscript
rotation_degrees = Vector3(0, 90, 0)  # 可能万向节死锁 ❌
quaternion = Quaternion.from_euler(...)   # ✅ 更安全
basis = Basis.from_euler(...)            # ✅ 更安全
```

### §22 Transform2D 乘法顺序
```gdscript
var t = parent_transform * child_transform  # 子的世界变换 ✅
# A * B ≠ B * A！矩阵乘法不满足交换律
```

---

## 6. 资源系统踩坑 🆕

### §23 .tres 文件中的注释导致字段加载失败

**问题**：在 `.tres` 资源文件中，字段值后添加行内注释（`# 注释`）会导致该字段无法正确加载，字段值会被重置为默认值。

**错误示例**：
```tres
# ❌ 错误：注释导致字段加载失败
gold_drop = 20  # 高价值目标
experience_drop = 50  # 高经验奖励
texture_path = "res://images/enemies/marble_0_0.png"  # 纹理路径
```

**正确示例**：
```tres
# ✅ 正确：移除所有行内注释
gold_drop = 20
experience_drop = 50
texture_path = "res://images/enemies/marble_0_0.png"
```

**影响**：
- `texture_path` 变为空字符串 → 怪物纹理不显示
- `experience_drop` 变为默认值 5 → 经验值异常低
- `gold_drop` 可能正确加载（取决于默认值）

**解决方案**：
1. 移除所有 `.tres` 文件中的行内注释
2. 重新保存资源文件（在 Godot 编辑器中）
3. 重启 Godot 编辑器清除缓存

**详细说明**：[Godot_4x_Resource_File_Comment_Issue.md](./Godot_4x_Resource_File_Comment_Issue.md)

---

## 7. 相关文档

- **[GDScript_Code_Standards.md](../20_Best_Practices/GDScript_Code_Standards.md)** - **代码规范标准** ⭐
- **[GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md)** - GDScript 警告处理最佳实践详细指南
  - 警告分类与影响分析
  - 常见警告原因与解决方案
  - 实战案例
- **[Warning_Fix_Quick_Reference.md](./Warning_Fix_Quick_Reference.md)** - 快速参考手册

---

## 参考资料

本文档内容整合自知识库中所有文档的踩坑点标注。
