# 3D 游戏开发概述

> **适用版本**: Godot 4.x  
> **知识领域**: 3D 游戏开发  
> **前置知识**: GDScript 基础、向量数学、矩阵变换

---

## 🎯 3D 游戏开发核心知识体系

### 1. 3D 坐标系与变换

#### 1.1 坐标系统
- **右手坐标系**: X 轴向右，Y 轴向上，Z 轴向前
- **原点**: 世界空间 (0, 0, 0)
- **单位**: 米（推荐），1 单位 = 1 米

#### 1.2 Transform3D
```gdscript
var transform = Transform3D(
    basis: Basis,      # 旋转和缩放
    origin: Vector3    # 位置
)

# 常用操作
transform.origin = Vector3(0, 0, 0)        # 设置位置
transform.basis = Basis()                   # 重置旋转缩放
transform = transform.scaled(Vector3(2, 2, 2))  # 缩放 2 倍
transform = transform.rotated(Vector3.UP, deg_to_rad(45))  # 旋转 45 度
```

**参考**:
- [3D 变换概念](../concepts/3d-transforms-concept.md)
- [矩阵与变换](../concepts/matrices-transforms.md)

---

### 2. 3D 节点体系

#### 2.1 核心节点
| 节点类型 | 用途 | 物理支持 |
|---------|------|---------|
| `Node3D` | 基础 3D 节点 | ❌ |
| `MeshInstance3D` | 显示 3D 网格 | ❌ |
| `Sprite3D` | 面向摄像机的 2D 精灵 | ❌ |
| `CharacterBody3D` | 角色控制（手动移动） | ✅ |
| `RigidBody3D` | 刚体物理（自动模拟） | ✅ |
| `Area3D` | 区域检测、信号触发 | ✅ |
| `StaticBody3D` | 静态碰撞体 | ✅ |
| `DirectionalLight3D` | 平行光（太阳） | ❌ |
| `OmniLight3D` | 点光源（灯泡） | ❌ |
| `SpotLight3D` | 聚光灯（手电筒） | ❌ |
| `Camera3D` | 3D 摄像机 | ❌ |
| `GPUParticles3D` | 3D 粒子系统 | ❌ |

**参考**:
- [3D 开发介绍](../concepts/3d-intro.md)

---

### 3. 3D 移动控制

#### 3.1 CharacterBody3D 移动
```gdscript
extends CharacterBody3D

var speed = 5.0
var jump_velocity = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
    # 获取输入
    var input_dir = Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    
    # 计算移动方向（基于摄像机）
    var direction = (get_viewport().get_camera_3d().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    # 应用重力
    if not is_on_floor():
        velocity.y -= gravity * delta
    
    # 处理跳跃
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity
    
    # 移动
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    
    move_and_slide()
```

**参考**:
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md)（2D 原理相同）

---

### 4. 3D 材质与渲染

#### 4.1 StandardMaterial3D
| 属性组 | 参数 | 效果 |
|-------|------|------|
| **Albedo** | Color/Texture | 基础颜色/纹理 |
| **Metallic** | 0-1 | 金属度（0=非金属，1=金属） |
| **Roughness** | 0-1 | 粗糙度（0=光滑，1=粗糙） |
| **Normal** | Texture | 法线贴图 |
| **Emission** | Color/Texture | 自发光 |
| **Ambient Occlusion** | Texture | 环境光遮蔽 |
| **Subsurface Scattering** | 0-1 | 次表面散射（皮肤/蜡） |

#### 4.2 渲染模式
```gdsl
// Spatial Shader 渲染模式
render_mode unshaded,              // 无光照
            cull_disabled,         // 禁用背面剔除
            depth_draw_always,     // 始终写入深度
            blend_add              // 加法混合
```

**参考**:
- [标准材质 3D](../guides/standard-material-guide.md)
- [Spatial 着色器指南](../guides/spatial-shader-guide.md)

---

### 5. 3D 光照系统

#### 5.1 光源类型
| 光源 | 特点 | 适用场景 |
|------|------|---------|
| `DirectionalLight3D` | 平行光、全局照射 | 太阳、月光 |
| `OmniLight3D` | 点光源、向四周照射 | 灯泡、火把 |
| `SpotLight3D` | 聚光灯、锥形照射 | 手电筒、舞台灯 |

#### 5.2 阴影设置
```gdscript
# DirectionalLight3D 阴影优化
directional_light.shadow_enabled = true
directional_light.shadow_max_distance = 100.0
directional_light.shadow_color = Color(0, 0, 0, 0.5)

# 级联阴影（远距离更好质量）
directional_light.shadow_mode = DirectionalLight3D.SHADOW_CASCADE_4
directional_light.shadow_split_1 = 0.1
directional_light.shadow_split_2 = 0.3
directional_light.shadow_split_3 = 0.7
```

**参考**:
- [3D 光照与阴影](../../base/3d-development/13C_Lights_and_Shadows.md)

---

### 6. 3D 粒子系统

#### 6.1 GPUParticles3D
- **高性能**: GPU 并行计算（支持 10000+ 粒子）
- **ProcessMaterial**: 粒子行为定义
- **发射器**: 点/球体/盒/环等形状

#### 6.2 常用参数
```gdscript
var particles = GPUParticles3D.new()
particles.amount = 100
particles.lifetime = 2.0
particles.one_shot = true  # 只发射一次

var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, -1, 0)  # 向下
material.spread = 20.0                   # 扩散角度
material.initial_velocity_min = 5.0
material.initial_velocity_max = 10.0
material.gravity = Vector3(0, -9.8, 0)

particles.process_material = material
```

**参考**:
- [3D 粒子指南](../guides/particles-3d-guide.md)

---

### 7. 3D 物理系统

#### 7.1 碰撞形状
| 形状 | 节点 | 适用场景 |
|------|------|---------|
| `SphereShape3D` | `CollisionShape3D` | 球体（简单高效） |
| `BoxShape3D` | `CollisionShape3D` | 立方体（常用） |
| `CapsuleShape3D` | `CollisionShape3D` | 角色（圆柱 + 半球） |
| `CylinderShape3D` | `CollisionShape3D` | 柱子 |
| `ConvexPolygonShape3D` | `CollisionShape3D` | 凸多边形（复杂形状） |
| `ConcavePolygonShape3D` | `CollisionShape3D` | 凹多边形（静态网格） |

#### 7.2 物理性能优化
- **优先使用简单形状**: Sphere > Box > Capsule > Convex > Concave
- **复合碰撞体**: 多个简单形状组合代替复杂形状
- **碰撞层**: 合理配置，减少不必要检测

**参考**:
- [物理系统介绍](../concepts/physics-intro.md)

---

### 8. 3D 摄像机

#### 8.1 摄像机类型
| 类型 | 实现方式 | 适用场景 |
|------|---------|---------|
| **第一人称** | 直接控制 Camera3D | FPS 游戏 |
| **第三人称** | 弹簧臂 + 插值 | 动作游戏 |
| **俯视** | 固定角度向下 | 策略游戏 |
| **轨道** | 围绕目标旋转 | 展示/BOSS 战 |

#### 8.2 第三人称摄像机示例
```gdscript
var camera_angle = Vector2(0, 0)
var camera_distance = 5.0
var target: Node3D

func _process(delta):
    # 更新摄像机位置
    var cam_pos = target.global_position
    cam_pos.y += 2.0  # 稍微高于目标
    cam_pos.z += camera_distance
    
    camera.global_position = cam_pos
    camera.look_at(target.global_position)
```

---

### 9. 3D 着色器

#### 9.1 Spatial Shader 基础
```glsl
shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float metallic = 0.0;
uniform float roughness = 0.5;

void fragment() {
    ALBEDO = albedo_color.rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}
```

#### 9.2 常见效果
- **溶解**: 使用噪声纹理 + 裁剪阈值
- **水面**: 顶点动画 + 法线贴图
- **全息**: 菲涅尔效应 + 扫描线
- **卡通渲染**: 阶梯化光照 + 轮廓线

**参考**:
- [Spatial 着色器指南](../guides/spatial-shader-guide.md)

---

### 10. 3D 性能优化

#### 10.1 渲染优化
| 优化方向 | 具体措施 |
|---------|---------|
| **LOD** | 远距离使用低模（Godot 4.x（4.6+）LOD 节点） |
| **遮挡剔除** | 使用 OccluderInstance3D |
| **合批** | 相同材质的 MeshInstance 合并 |
| **光照烘焙** | 静态光照烘焙到光照贴图 |
| **阴影距离** | 限制阴影最大距离 |

#### 10.2 物理优化
| 优化方向 | 具体措施 |
|---------|---------|
| **简单碰撞体** | 优先使用 Sphere/Box |
| **睡眠阈值** | 刚体静止时自动睡眠 |
| **碰撞层** | 减少不必要检测 |

**参考**:
- [性能优化实战指南](../guides/performance-optimization-guide.md)

---

## 📚 推荐学习路径

### 入门阶段
```
1. [3D 开发介绍](../concepts/3d-intro.md)
   ↓
2. [3D 变换概念](../concepts/3d-transforms-concept.md)
   ↓
3. [标准材质 3D](../guides/standard-material-guide.md)
   ↓
4. [3D 光照指南](../guides/3d-lights-guide.md)
```

### 进阶阶段
```
1. [3D 粒子指南](../guides/particles-3d-guide.md)
   ↓
2. [Spatial 着色器指南](../guides/spatial-shader-guide.md)
   ↓
3. [物理系统介绍](../concepts/physics-intro.md)
```

### 高级阶段
```
1. [遮挡剔除](../../base/3d-development/) - 高级渲染优化
   ↓
2. [光照烘焙](../../base/3d-development/) - 静态光照优化
   ↓
3. [GPU 优化](../../base/practical-experiences/optimization-tips/14C_GPU_Optimization.md)
```

---

## 🔗 相关资源

### Base 层来源
- [3D 开发](../../base/3d-development/) - 5 份完整文档
- [着色器系统](../../base/shaders/) - 4 份着色器文档
- [物理系统](../../base/physics-system/) - 5 份物理文档

### Wiki 层相关
- [3D 开发介绍](../concepts/3d-intro.md) - 3D 入门指南
- [3D 变换概念](../concepts/3d-transforms-concept.md)
- [矩阵与变换](../concepts/matrices-transforms.md)
- [向量数学](../concepts/vector-math.md)
- [标准材质 3D](../guides/standard-material-guide.md)
- [3D 光照指南](../guides/3d-lights-guide.md)

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
