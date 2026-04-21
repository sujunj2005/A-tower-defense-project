# 2D 骨骼动画系统

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/animation/2d_skeletons.rst

---

## 一、为什么在 Godot 中做2D骨骼动画？

### 优势

✅ **更好的引擎集成**：动画可控制粒子、着色器、声音、脚本调用、颜色、透明度等  
✅ **组合动画风格**：可与传统的 AnimatedSprite2D（逐帧动画）结合  
✅ **自定义形状**：Polygon2D 支持 UV 动画、变形等  
✅ **粒子系统集成**：魔法效果、喷射背包等  
✅ **自定义碰撞体**：Boss、格斗游戏的关键  
✅ **AnimationTree**：复杂混合和过渡（与3D相同）  

### 对比外部工具

| 工具 | 优点 | 缺点 |
|------|------|------|
| **Spine/Dragonbones** | 功能成熟 | 导入麻烦，集成度低 |
| **Godot 内置** | 引擎深度集成，免费 | 学习曲线 |

---

## 二、准备工作

### 前置知识

建议先阅读 [Cutout Animation 教程](11D_Cutout_Animation.md) 了解基本概念。

### 所需素材

- 角色部件图（PNG格式，透明背景）
- 本教程使用 GBot 角色（Andreas Esau 创作）

---

## 三、创建多边形

### 3.1 创建根节点

创建新场景，使用空 Node2D 作为根节点（如果是角色可用 CharacterBody2D）：

```
Node2D (root)
```

### 3.2 创建 Polygon2D 并分配纹理

1. 添加 `Polygon2D` 子节点
2. 分配角色部件纹理

### 3.3 绘制多边形（UV编辑）

**不要直接手动绘制多边形顶点！** 正确方法：

1. 选择 Polygon2D 节点
2. 打开 **UV 编辑对话框**
3. 切换到 **Points 模式**
4. 使用铅笔工具围绕所需部件绘制多边形

### 3.4 复制并调整

1. 复制 Polygon2D 节点，重命名
2. 再次打开 UV 编辑器，替换为新部件的多边形
3. 如果形状相似，可直接编辑之前的多边形

> **提示**：移动多边形后，记得通过 **Edit > Copy Polygon to UV** 更新 UV

### 3.5 组装角色

将所有部件排列成角色形状。此时不需要关心旋转轴心，后续会调整。

**重要**：调整节点顺序以确保正确的视觉层级（前面的部件在后面的上面）。

---

## 四、创建骨骼

### 4.1 添加 Skeleton2D

在根节点下创建 `Skeleton2D` 节点作为骨骼基础：

```
Node2D (root)
└── Skeleton2D
```

### 4.2 创建 Bone2D 层级

1. 在 Skeleton2D 下创建 `Bone2D` 节点
2. 通常从**髋部（Hip）**开始（2D和3D都一样，髋部是骨骼根）
3. 继续创建层级结构并命名

**典型 humanoid 骨骼结构：**

```
Skeleton2D
├── Hip (Bone2D)
│   ├── Torso (Bone2D)
│   │   ├── Head (Bone2D)
│   │   ├── LeftUpperArm (Bone2D)
│   │   │   └── LeftForearm (Bone2D)
│   │   └── RightUpperArm (Bone2D)
│   │       └── RightForearm (Bone2D)
│   ├── LeftUpperLeg (Bone2D)
│   │   └── LeftLowerLeg (Bone2D)
│   └── RightUpperLeg (Bone2D)
│       └── RightLowerLeg (Bone2D)
```

### 4.3 Tip Bones（末端骨骼）

链条末端的骨骼（如 jaw）会很短且指向右侧——这是正常的。

**调整末端骨骼长度**：在 Inspector 中修改属性（仅末端骨骼需要）。

---

## 五、设置 Rest Pose（休息姿势）

### 为什么要设置 Rest Pose？

Rest Pose 是骨骼的**默认姿势**，可以随时回到这个姿势（对动画非常重要）。

### 设置步骤

1. 点击场景树中的 **Skeleton2D** 节点
2. 点击工具栏上的 **Skeleton2D** 按钮
3. 从下拉菜单中选择 **Overwrite Rest Pose**

> **警告**：所有骨骼都会显示缺少 rest pose 的警告，直到你设置它

---

## 六、绑定骨骼到网格

### 6.1 手动绑定方法

将每个 Polygon2D 节点拖动到对应的 Bone2D 下：

```
Skeleton2D
├── Hip
│   └── Torso
│       ├── Head
│       │   └── Head_Sprite (Polygon2D)  ← 绑定到此骨头上
│       ├── LeftUpperArm
│       │   └── LeftArm_Sprite (Polygon2D)
│       └── ...
```

### 6.2 自动绑定（使用 SkeletonModifier2D）

Godot 4.x 提供了更方便的绑定工具：

1. 选择要绑定的 Polygon2D 节点
2. 在 Inspector 中查找 Skeleton 相关属性
3. 指定所属骨骼

---

## 七、IK（逆向动力学）

### 7.1 什么是 IK？

IK（Inverse Kinematics）允许通过指定末端位置来反向计算整个骨骼链的角度。

例如：手要够到一个目标位置，IK 会自动计算肩膀、肘部的角度。

### 7.2 在 Godot 2D 中使用 IK

Godot 4.x 的 Skeleton2D 支持 IK：

```gdscript
# 获取 IK 链
var ik = $Skeleton2D.get_bone(ik_bone_index)

# 设置 IK 目标位置
ik.set_global_position(target_position)

# 应用 IK
ik.apply_ik()
```

> **详细用法**请参考官方 Skeleton2DIK 2D 文档

---

## 八、动画制作

### 8.1 使用 AnimationPlayer

1. 添加 AnimationPlayer 节点
2. 创建新动画（如 "idle", "run", "jump"）
3. 选择骨骼节点，在时间轴上插入关键帧
4. 旋转/移动/缩放骨骼制作动画

### 8.2 可动画属性

骨骼动画不仅可以控制旋转，还能动画：
- **position**：位置
- **rotation**：旋转
- **scale**：缩放
- 子节点的 **modulate**：颜色调制
- 子节点的 **visible**：可见性
- 自定义属性（脚本中定义）

### 8.3 AnimationTree 混合

使用 AnimationTree 实现复杂的动画状态机和混合：

```
AnimationTree
├── StateMachine (idle → run → jump)
├── BlendTree (aim_up/down 混合)
└── Parameters
```

详见 [AnimationTree 教程](11B_Animation_Tree.md)

---

## 九、完整示例代码

```gdscript
extends CharacterBody2D

@onready var skeleton = $Skeleton2D
@onready var animation_player = $AnimationPlayer

enum State { IDLE, RUN, JUMP, ATTACK }
var current_state = State.IDLE

func _physics_process(delta):
    handle_input()
    update_animation()

func handle_input():
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    if input_dir.length() > 0:
        velocity = input_dir * SPEED
        current_state = State.RUN

        # 翻转角色
        if input_dir.x != 0:
            $Sprite2D.flip_h = input_dir.x < 0
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        current_state = State.IDLE

    if not is_on_floor():
        current_state = State.JUMP

    if Input.is_action_just_pressed("attack"):
        current_state = State.ATTACK

    move_and_slide()

func update_animation():
    match current_state:
        State.IDLE:
            animation_player.play("idle")
        State.RUN:
            animation_player.play("run")
        State.JUMP:
            animation_player.play("jump")
        State.ATTACK:
            animation_player.play("attack")


# 示例2：程序化骨骼控制
extends Node2D

@onready var skeleton = $Skeleton2D

func _process(delta):
    # 让头部始终看向鼠标位置
    var head_bone = skeleton.get_bone("Head")
    var mouse_pos = get_global_mouse_position()
    head_bone.look_at(mouse_pos)

    # 限制头部旋转角度
    var current_rotation = head_bone.rotation
    head_base.rotation = clamp(current_rotation, -0.5, 0.5)
```

---

## 十、最佳实践与优化

| 方面 | 建议 |
|------|------|
| **骨骼数量** | 保持合理（humanoid通常15-30根骨头） |
| **Rest Pose** | T-pose或自然站立姿势，便于后续调整 |
| **命名规范** | 使用清晰的名字（LeftArm, RightLeg） |
| **动画复用** | 通过 AnimationTree 混合减少动画数量 |
| **性能** | Godot 2D骨骼系统针对性能优化，适合移动平台 |
| **调试** | 使用 Skeleton2D 的 gizmo 可视化骨骼 |
| **碰撞体** | 为关键部位（拳头、脚）附加 CollisionShape2D |

---

## 十一、与其他系统集成

### 与粒子系统结合
```gdscript
# 在脚步位置发射灰尘粒子
func on_foot_step(position):
    $DustParticles.global_position = position
    $DustParticles.emitting = true
```

### 与着色器结合
```gdscript
# 受伤闪烁效果
func take_damage(amount):
    modulate = Color.RED
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.2)
```

### 与音频结合
```gdscript
# 脚步声
func on_foot_down():
    $FootstepAudioPlayer.play()
```

---

## 十二、参考链接

- [Skeleton2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_skeleton2d.html)
- [Bone2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_bone2d.html)
- [AnimationPlayer 教程](11A_Animation_Player.md)
- [AnimationTree 教程](11B_Animation_Tree.md)
- [剪纸动画教程](11D_Cutout_Animation.md)
- [2D 自定义绘制](05I_Custom_Drawing_2D.md)
