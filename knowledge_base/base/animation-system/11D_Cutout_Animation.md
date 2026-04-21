# 剪纸动画 (Cutout Animation)

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/animation/cutout_animation.rst

---

## 一、什么是剪纸动画？

### 1.1 传统定义

**剪纸动画（Cutout Animation）**是一种定格动画形式，将纸片剪成特殊形状，排列成二维角色/物体。每一帧拍摄一次，通过微小移动/旋转部件来创造运动错觉。

**著名案例**：
- 《南方公园》（South Park）
- 《杰克与梦幻岛海盗》（Jake and the Never Land Pirates）
- 游戏：《纸片马里奥》（Paper Mario）、《雷曼起源》（Rayman Origins）

### 1.2 Godot 中的剪纸动画

Godot 提供完整的剪纸动画工具链，非常适合这种工作流：

✅ **动画系统完全集成**：不仅控制运动，还可动画纹理、精灵大小、轴心、不透明度、颜色调制等  
✅ **组合动画风格**：AnimatedSprite2D 允许传统逐帧动画与剪纸动画共存  
✅ **自定义形状元素**：Polygon2D 支持 UV 动画、变形等  
✅ **粒子系统**：可结合粒子系统（魔法效果、喷射背包等）  
✅ **自定义碰撞体**：为骨骼不同部位设置碰撞体（Boss、格斗游戏）  
✅ **AnimationTree**：复杂混合和过渡（与3D相同）  

---

## 二、GBot 角色制作案例

本教程使用 Andreas Esau 创作的 **GBot** 角色。

### 2.1 准备素材

下载资源包：[cutout_animation_assets.zip](https://github.com/godotengine/godot-docs-project-starters/releases/download/latest-4.x/cutout_animation_assets.zip)

---

## 三、搭建骨架（Rigging）

### 3.1 创建根节点

创建空的 `Node2D` 作为根节点：

```
Node2D (root)
```

### 3.2 从髋部开始（Hip First）

**原则**：2D和3D一样，髋部是骨架的根，这样更容易动画：

```
Node2D (root)
└── Hip (Sprite2D)  ← 第一个节点
```

### 3.3 添加躯干（Torso）

躯干必须是髋部的子节点：

```
Node2D (root)
└── Hip (Sprite2D)
    └── Torso (Sprite2D)  ← 加载躯干纹理，调整位置
```

**测试层级**：按 **E** 进入旋转模式，拖拽鼠标旋转躯干，检查层级是否正确。

---

## 四、调整轴心（Pivot）

### 4.1 问题识别

Sprite2D 中心的**小十字**就是旋转轴心。如果轴心位置不对，旋转时会围绕错误的点转动。

### 4.2 调整方法

**方法1：在 Inspector 中设置 Offset**

```
Sprite2D > Offset > Position
```

**方法2：使用远程变换（Remote Transform）**

对于复杂骨骼，可以使用 RemoteTransform2D 来精确控制轴心。

**方法3：使用 Bone2D（推荐用于骨骼动画）**

如果计划做骨骼动画，应该使用 Bone2D 节点而不是纯 Sprite2D 层级。详见 [2D 骨骼动画教程](11C_2D_Skeletons.md)。

---

## 五、继续搭建身体

按照从中心向外的方式继续添加部位：

```
Node2D (root)
└── Hip
    └── Torso
        ├── Head
        ├── LeftUpperArm
        │   └── LeftForearm
        │       └── LeftHand
        ├── RightUpperArm
        │   └── RightForearm
        │       └── RightHand
        ├── LeftUpperLeg
        │   └── LeftLowerLeg
        │       └── LeftFoot
        └── RightUpperLeg
            └── RightLowerLeg
                └── RightFoot
```

### 关键要点

1. **每个部位的轴心都要调整**到合理的关节位置
2. **节点顺序决定绘制顺序**（Z-index 或节点顺序）
3. **随时测试旋转**确保层级正确

---

## 六、使用 Polygon2D 替代 Sprite2D

### 6.1 为什么用 Polygon2D？

- 可以从一张纹理图中裁切出多个部件
- 支持 UV 编辑
- 支持变形动画
- 更灵活的形状控制

### 6.2 工作流程

1. 加载包含所有部件的大图
2. 为每个部件创建 Polygon2D
3. 在 UV 编辑器中框选对应部件区域
4. 组装成角色

详见 [2D 骨骼动画教程](11C_2D_Skeletons.md) 中的详细步骤。

---

## 七、动画制作

### 7.1 使用 AnimationPlayer

1. 添加 `AnimationPlayer` 节点到场景
2. 创建新动画（如 "idle", "run", "attack"）
3. 选择要动画的节点/骨骼
4. 插入关键帧（位置、旋转、缩放等）

### 7.2 可动画的属性

| 类别 | 属性 |
|------|------|
| **变换** | position, rotation, scale |
| **视觉** | modulate, self_modulate, visible |
| **纹理** | region_rect (for Sprite2D) |
| **材质** | shader_parameter/* |
| **自定义** | 脚本中 @export 的变量 |

### 7.3 动画技巧

#### 循环动画（Idle/Breathe）
```gdscript
# 轻微的上下浮动模拟呼吸
AnimationPlayer.play("idle", -1, 1.0)  # -1 = 无限循环
```

#### 过渡动画
```gdscript
# 从 idle 过渡到 run
AnimationPlayer.play("run", -1, 0.3)  # 0.3秒交叉淡化
```

#### 混合动画（需要 AnimationTree）
- 使用 Blend2 混合 aim_up/aim_down
- 使用 StateMachine 管理 idle/run/jump 状态切换

详见 [AnimationTree 教程](11B_Animation_Tree.md)

---

## 八、完整示例：平台跳跃角色

```gdscript
extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Hip/Torso

var direction = 0

func _physics_process(delta):
    # 移动
    direction = Input.get_axis("move_left", "move_right")
    velocity.x = direction * SPEED

    # 跳跃
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = JUMP_POWER

    # 重力
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    move_and_slide()

    # 更新动画
    update_animations()

func update_animations():
    if not is_on_floor():
        animation_player.play("jump")
    elif abs(direction) > 0:
        animation_player.play("run")
        # 翻转
        $Hip.scale.x = sign(direction)
    else:
        animation_player.play("idle")
```

---

## 九、剪纸动画 vs 逐帧动画 vs 骨骼动画

| 特性 | 剪纸动画 | 逐帧动画 | 骨骼动画 |
|------|----------|----------|----------|
| **制作难度** | 🟡 中等 | 🔴 高（需画每帧） | 🟢 低（复用部件） |
| **文件大小** | 🟢 小（共用纹理） | 🔴 大（每帧图片） | 🟢 小 |
| **内存占用** | 🟢 低 | 🔴 高 | 🟢 低 |
| **灵活性** | 🟡 中等 | 🔴 低（固定帧） | 🟢 高（程序控制） |
| **风格** | 扁平/纸质 | 手绘/像素 | 3D感/流畅 |
| **适用场景** | RPG对话、UI、简单角色 | 复杂动作游戏 | 主角、复杂角色 |
| **Godot节点** | Sprite2D/Polygon2D 层级 | AnimatedSprite2D | Skeleton2D + Bone2D |

---

## 十、最佳实践

### 10.1 命名规范

```
# 身体部位命名
Hip, Torso, Head, UpperArm, Forearm, Hand, UpperLeg, LowerLeg, Foot

# 左右区分
LeftArm, RightArm, LeftLeg, RightLeg

# 动画命名
idle, run, jump, attack, hurt, die
idle AimUp, idle AimDown  # 混合变体
```

### 10.2 层级组织

```
CharacterRoot (CharacterBody2D or RigidBody2D)
├── Skeleton2D (or root for cutout rig)
│   └── [骨骼/部位层级]
├── CollisionShape2D
├── AnimationPlayer
└── AnimationTree (可选)
```

### 10.3 性能优化

- **避免过多节点**：合并静态部位
- **使用 Atlas 纹理**：减少纹理切换
- **合理使用 Visibility**：屏幕外的角色可禁用
- **LOD（Level of Detail）**：远处使用简化版

### 10.4 工作流程建议

1. **原型阶段**：先用简单几何体搭建
2. **细化阶段**：替换为最终美术资源
3. **绑定阶段**：调整轴心和层级
4. **动画阶段**：制作基础动画集
5. **整合阶段**：添加逻辑、音效、粒子

---

## 十一、进阶主题

### 11.1 与物理系统集成

为攻击部位添加碰撞体：

```gdscript
# 拳头的碰撞检测
func _on_attack_frame():
    $HitboxPunch.monitoring = true

func _on_attack_end():
    $HitboxPunch.monitoring = false
```

### 11.2 与着色器结合

轮廓发光效果（受击反馈）：

```glsl
// shader_type canvas_item
uniform bool outline_enabled : source_color = false;
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_size : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // ... 主渲染逻辑
}
```

### 11.3 程序化动画

使用代码驱动部分动画（如头发飘动、衣服摆动）：

```gdscript
func _process(delta):
    # 头发随时间轻微摆动
    var hair_wave = sin(Time.get_ticks_msec() * 0.005) * 0.05
    $Hair.rotation = base_hair_rotation + hair_wave
```

---

## 十二、参考链接

- [剪纸动画官方教程](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html)
- [2D 骨骼动画教程](11C_2D_Skeletons.md)
- [AnimationPlayer 教程](11A_Animation_Player.md)
- [AnimationTree 教程](11B_Animation_Tree.md)
- [Sprite2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)
- [Polygon2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html)
