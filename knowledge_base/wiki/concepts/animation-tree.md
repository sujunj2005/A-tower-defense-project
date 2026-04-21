# AnimationTree 核心概念

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 11B_Animation_Tree.md](../../base/animation-system/11B_Animation_Tree.md)  
> **重要性**: 🔴 必读 - 复杂动画状态管理

---

## 📋 概述

AnimationTree 是用于管理复杂动画系统的工具，基于状态机和混合树。它允许你创建流畅的动画过渡、混合多个动画源，并实现程序化动画控制。

---

## 🎯 核心概念

### 1. 状态机（StateMachine）

状态机是 AnimationTree 的核心，用于管理不同动画状态之间的切换。

**状态机特点**：
- **状态（State）**: 代表一个动画或动画组合
- **过渡（Transition）**: 定义状态之间的切换条件
- **初始状态**: 状态机启动时的默认状态

**常见状态**：
- Idle（待机）
- Walk（行走）
- Run（奔跑）
- Jump（跳跃）
- Attack（攻击）

### 2. 混合树（BlendTree）

混合树用于组合多个动画源，创建复杂的动画效果。

**混合节点类型**：
- **Blend2**: 混合两个动画
- **Blend3**: 混合三个动画
- **BlendSpace1D**: 一维混合空间（如速度）
- **BlendSpace2D**: 二维混合空间（如方向 + 速度）
- **OneShot**: 一次性动画（如攻击）
- **Sequence**: 序列动画（连招）

### 3. 动画参数（Parameters）

参数用于控制状态机和混合树的行为。

**参数类型**：
- **float**: 浮点数（如速度、混合权重）
- **bool**: 布尔值（如是否在地面）
- **int**: 整数（如攻击索引）
- **vector**: 向量（如移动方向）

---

## 🔧 使用方法

### 基本设置

```gdscript
# 1. 添加节点
# - AnimationPlayer
# - AnimationTree

# 2. 配置 AnimationTree
$AnimationTree.tree = preload("res://animation_tree.tres")
$AnimationTree.active = true

# 3. 获取状态机
var state_machine = $AnimationTree.get("parameters/playback")
```

### 状态机控制

```gdscript
# 获取状态机
var state_machine = $AnimationTree.get("parameters/playback")

# 切换到特定状态
state_machine.travel("walk")

# 检查当前状态
if state_machine.get_current_node() == "run":
    print("正在奔跑")

# 条件过渡（自动）
$AnimationTree.set("parameters/conditions/is_moving", true)
```

### 混合空间控制

```gdscript
# 1D 混合空间（基于速度）
$AnimationTree.set("parameters/blend1d/blend_amount", speed)

# 2D 混合空间（基于方向）
$AnimationTree.set("parameters/blend2d/blend_position", Vector2(input_x, input_y))

# 混合权重
$AnimationTree.set("parameters/blend2/blend_amount", 0.5)  # 50% 混合
```

---

## 🎨 实战示例

### 1. 角色移动动画

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0
var velocity: Vector2 = Vector2.ZERO

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta):
    # 获取输入
    var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # 移动
    velocity = input_direction * speed
    move_and_slide(velocity)
    
    # 更新动画参数
    anim_tree.set("parameters/conditions/is_moving", velocity.length() > 0)
    anim_tree.set("parameters/blend1d/blend_amount", velocity.length() / speed)
    
    # 面向方向
    if input_direction.x != 0:
        $Sprite2D.flip_h = input_direction.x < 0
```

### 2. 攻击连招系统

```gdscript
extends CharacterBody2D

var combo_count: int = 0
var can_attack: bool = true

@onready var anim_tree = $AnimationTree

func _input(event):
    if event.is_action_pressed("attack") and can_attack:
        perform_attack()

func perform_attack():
    combo_count = (combo_count % 3) + 1  # 3 连击循环
    anim_tree.set("parameters/attack/attack_index", combo_count)
    anim_tree.set("parameters/conditions/attack", true)
    can_attack = false

func _on_attack_completed():
    can_attack = true
    combo_count = 0
```

### 3. 空中/地面动画切换

```gdscript
extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta):
    var is_on_ground = is_on_floor()
    
    # 更新条件
    anim_tree.set("parameters/conditions/is_on_ground", is_on_ground)
    
    # 状态机自动处理过渡
    # ground → air (当 is_on_ground = false)
    # air → ground (当 is_on_ground = true)
```

---

## ⚠️ 常见踩坑

### 1. 状态机不切换

**问题**：调用 travel() 但状态不切换

**原因**：
- 状态之间没有过渡
- 过渡条件不满足
- 状态机未激活

**解决方案**：
```gdscript
# 检查状态机是否有效
if state_machine:
    state_machine.travel("walk")
else:
    print("状态机未初始化！")

# 检查过渡条件
anim_tree.set("parameters/conditions/can_transition", true)
```

### 2. 动画混合不平滑

**问题**：状态切换时动画跳跃

**解决方案**：
- 增加过渡时间（Transition Time）
- 确保动画起始姿势相似
- 使用混合树而不是直接切换

### 3. 参数更新不及时

**问题**：参数设置了但动画不响应

**解决方案**：
```gdscript
# ✅ 正确：在 _process 或 _physics_process 中更新
func _process(delta):
    anim_tree.set("parameters/speed", velocity.length())

# ❌ 错误：只在 _ready 中设置
func _ready():
    anim_tree.set("parameters/speed", 0)  # 之后不会更新
```

---

## 📊 性能优化

### 1. 减少活动状态机数量

只对可见/附近的角色使用 AnimationTree。

### 2. 使用 LOD 系统

```gdscript
func update_animation_lod(distance: float):
    if distance > 50:
        $AnimationTree.active = false  # 禁用动画树
        $Sprite2D.frame = 0  # 使用静态帧
    else:
        $AnimationTree.active = true
```

### 3. 简化混合树

远距离角色使用简化的混合树或预烘焙动画。

---

## 🔗 相关资源

### Base 层
- [11B_Animation_Tree.md](../../base/animation-system/11B_Animation_Tree.md) - AnimationTree 详解
- [11A_Animation_Player.md](../../base/animation-system/11A_Animation_Player.md) - AnimationPlayer 基础

### Wiki 层
- [动画制作实战指南](../guides/2d-animation-guide.md) - 2D 动画指南
- [剪裁动画指南](../guides/cutout-animation-guide.md) - 角色剪裁动画

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
