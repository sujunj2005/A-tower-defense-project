# 3D 变换系统详解

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/3d/using_transforms.rst

---

## 一、为什么不用欧拉角？

### 1.1 欧拉角的问题

虽然直觉上认为"3D旋转就是X/Y/Z轴旋转"，但这种方法有严重缺陷：

#### 问题1：旋转顺序依赖

**没有唯一方式**从三个角度构建朝向。旋转顺序不同，最终结果不同：

```gdscript
# 先X后Y再Z ≠ 先Y后Z再X
# 结果取决于旋转的应用顺序！
```

**实际影响**：FPS游戏中鼠标控制视角
- 正确：先Y轴（水平转向），再X轴（上下看）
- 错误：先X轴再Y轴会导致奇怪的旋转行为

#### 问题2：插值问题

两个旋转之间插值时，可能走"远路"而不是最短路径：

```gdscript
# 从270度插值到0度
# 可能是：270 → 360（正确，90度路径）
# 也可能是：270 → 0（错误，270度路径）
```

还会遇到**万向锁（Gimbal Lock）**问题：当两个旋转轴对齐时，丢失一个自由度。

> **结论**：**不要在代码中使用 Node3D 的 rotation 属性**（仅用于编辑器简单旋转）

---

## 二、Transform3D 变换系统

### 2.1 Transform3D 结构

每个 `Node3D` 包含 `transform` 属性（相对父节点）和 `global_transform` 属性（全局坐标）。

Transform3D 由两部分组成：

#### Basis（基/旋转矩阵）
包含三个 Vector3，表示各轴的旋转方向：

```gdscript
var basis = Basis()
basis.x = Vector3(1, 0, 0)  # X轴（右）
basis.y = Vector3(0, 1, 0)  # Y轴（上）
basis.z = Vector3(0, 0, 1)  # Z轴（前）
```

**OpenGL约定**：X=右，Y=上，Z=前（-Z=后）

#### Origin（原点）
Vector3 类型，表示距离世界原点 `(0,0,0)` 的偏移。

### 2.2 可视化理解

在编辑器中查看3D Gizmo的"本地空间"模式：
- 红色箭头 = X轴
- 绿色箭头 = Y轴
- 蓝色箭头 = Z轴
- Gizmo中心 = origin

---

## 三、操作变换

### 3.1 旋转变换

#### 方法1：直接操作 Basis
```gdscript
# 绕X轴旋转0.1弧度
transform.basis = Basis(Vector3.RIGHT, 0.1) * transform.basis

# 简写形式
transform.basis = transform.basis.rotated(Vector3.RIGHT, 0.1)
```

#### 方法2：使用 Node3D 方法（推荐）
```gdscript
# 绕父节点坐标系旋转
rotate(Vector3.RIGHT, 0.1)
rotate_x(0.1)  # 简写

# 绕自身局部坐标系旋转
rotate_object_local(Vector3.RIGHT, 0.1)
```

### 3.2 精度误差处理

连续操作变换会产生浮点误差，导致：
- 各轴长度不再精确为 1.0
- 轴间不再是精确90度

**解决方案：正交归一化**

```gdscript
# 每帧或定期执行（会丢失缩放信息）
transform = transform.orthonormalized()

# 如果需要保留缩放
var current_scale = transform.basis.get_scale()
transform = transform.orthonormalized()
transform = transform.scaled(current_scale)
```

> **建议**：需要频繁操作的节点不要直接缩放，而是缩放其子节点（如 MeshInstance3D）

---

## 四、从变换获取信息

### 核心原则：停止用角度思考！

**常见任务用向量解决：**

#### 发射子弹方向
```gdscript
# 在 RigidBody3D 上
bullet.transform = transform
bullet.linear_velocity = -transform.basis.z * BULLET_SPEED  # -Z是前方
```

#### 检测敌人是否看向玩家
```gdscript
var direction = enemy.transform.origin - player.transform.origin
if direction.dot(enemy.transform.basis.z) > 0:
    enemy.im_watching_you(player)
```

#### 横向移动（CharacterBody3D）
```gdscript
# -X 是左方
if Input.is_action_pressed("strafe_left"):
    velocity = -transform.basis.x * MOVE_SPEED

move_and_slide()
```

#### 跳跃
```gdscript
# +Y 是上方
if Input.is_action_just_pressed("jump"):
    velocity.y = JUMP_SPEED
```

---

## 五、设置变换信息

### FPS控制器示例

对于确实需要角度的场景（如FPS视角），将角度保持在变换外部：

```gdscript
extends Camera3D

var rot_x = 0.0  # 累积的水平旋转
var rot_y = 0.0  # 累积的垂直旋转
const LOOKAROUND_SPEED = 0.005

func _input(event):
    if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
        # 修改累积旋转值
        rot_x -= event.screen_relative.x * LOOKAROUND_SPEED
        rot_y -= event.screen_relative.y * LOOKAROUND_SPEED

        # 重置并重新应用旋转
        transform.basis = Basis()  # 重置旋转
        rotate_object_local(Vector3.UP, rot_x)     # 先绕Y轴转（水平）
        rotate_object_local(Vector3.RIGHT, rot_y)   # 再绕X轴转（垂直）
```

> **关键**：每帧重建变换，而不是尝试读取/复用之前的值

---

## 六、四元数插值

### 6.1 为什么用四元数？

四元数（Quaternion）提供**最短路径插值**，适合相机/路径平滑过渡。

### 6.2 使用方法

```gdscript
# 将 Basis 转换为 Quaternion（注意：会丢失缩放信息）
var a = Quaternion(transform.basis)
var b = Quaternion(target_transform.basis)

# 使用球面线性插值（SLERP）找到中点
var c = a.slerp(b, 0.5)

# 应用回变换
transform.basis = Basis(c)
```

### 6.3 注意事项

- 四元数需要定期归一化，否则会有数值精度误差
- 适合相机/路径等需要平滑过渡的场景
- 结果总是正确且平滑的

---

## 七、完整示例：第三人称跟随相机

```gdscript
extends Camera3D

@export var target: Node3D
@export var distance: float = 5.0
@export var height: float = 2.0
@export var follow_speed: float = 10.0

func _physics_process(delta):
    if not target:
        return

    # 计算目标位置（目标后方上方）
    var target_pos = target.global_transform.origin
    target_pos += -target.global_transform.basis.z * distance
    target_pos += Vector3.UP * height

    # 平滑插值到目标位置
    global_transform.origin = global_transform.origin.lerp(target_pos, delta * follow_speed)

    # 始终看向目标
    look_at(target.global_transform.origin, Vector3.UP)


# 示例2：轨道相机
extends Camera3D

@export var center_point: Node3D
@export var orbit_speed: float = 1.0
var orbit_angle: float = 0.0

func _process(delta):
    orbit_angle += delta * orbit_speed

    # 计算轨道位置
    var radius = 10.0
    var x = center_point.global_position.x + cos(orbit_angle) * radius
    var z = center_point.global_position.z + sin(orbit_angle) * radius

    global_position = Vector3(x, global_position.y, z)
    look_at(center_point.global_position, Vector3.UP)
```

---

## 八、最佳实践速查表

| 任务 | 推荐方法 | 避免 |
|------|----------|------|
| **简单旋转** | `rotate()` / `rotate_object_local()` | 直接修改 `rotation` |
| **获取朝向** | `-transform.basis.z`（前方） | `rotation.y` |
| **检测视线** | `direction.dot(basis.z)` | 角度比较 |
| **移动方向** | `basis.x / basis.y / basis.z` | sin/cos 计算 |
| **平滑旋转** | `Quaternion.slerp()` | lerp angles |
| **精度维护** | 定期 `orthonormalized()` | 忽略浮点误差 |
| **FPS视角** | 外部累积角度 + 每帧重建 | 读取/修改 transform.rotation |
| **子弹发射** | `basis.z * speed` | 角度三角函数 |

---

## 九、坐标系速记

```
        Y (UP)
        |
        |
        |
        +-------- X (RIGHT)
       /
      /
     Z (FORWARD, into screen in Godot's left-handed system)

关键向量常量：
- Vector3.RIGHT  = (1, 0, 0)   → +X
- Vector3.UP     = (0, 1, 0)   → +Y
- Vector3.FORWARD = (0, 0, 1) → +Z
- -Vector3.FORWARD = (0, 0,-1) → -Z（通常作为"前方"）
```

---

## 十、参考链接

- [Transform3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_transform3d.html)
- [Basis 官方文档](https://docs.godotengine.org/en/stable/classes/class_basis.html)
- [Quaternion 官方文档](https://docs.godotengine.org/en/stable/classes/class_quaternion.html)
- [Node3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_node3d.html)
- [向量数学教程](04A_Vector_Math.md)
- [矩阵与变换教程](04B_Matrices_and_Transforms.md)
- [3D 开发概述](13A_Introduction_to_3D.md)
