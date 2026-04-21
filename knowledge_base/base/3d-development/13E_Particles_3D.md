# 3D 粒子系统 (GPUParticles3D)

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/3d/particles/index.rst 及子页面

---

## 一、简介

Godot 4.x 提供 **GPU驱动**的3D粒子系统，通过着色器在GPU上高效模拟大量粒子。

**核心节点**：`GPUParticles3D`（推荐）/ `CPUParticles3D`（兼容性备选）

---

## 二、GPUParticles3D vs CPUParticles3D

| 特性 | GPUParticles3D | CPUParticles3D |
|------|---------------|---------------|
| **计算位置** | GPU（并行） | CPU（串行） |
| **性能** | ⚡⚡⚡ 极高（百万级粒子） | ⚡ 低（数千粒子） |
| **灵活性** | 受限于预设参数 | 完全程序控制 |
| **碰撞检测** | 有限 | 完全控制 |
| **适用平台** | 所有现代GPU | 所有机型（包括低端设备） |
| **调试难度** | 较难（GPU端） | 易于调试 |

> **推荐**：优先使用 GPUParticles3D，仅在需要精确物理交互时使用 CPUParticles3D

---

## 三、基本工作流程

### 3.1 创建粒子系统

1. 添加 `GPUParticles3D` 节点到场景
2. 创建 `ParticleProcessMaterial` 资源
3. 将材质分配给 GPUParticles3D 的 `process_material` 属性
4. 配置各种参数
5. 设置 `emitting = true` 开始发射

### 3.2 节点结构

```
GPUParticles3D (根节点)
├── process_material: ParticleProcessMaterial  ← 核心配置
├── draw_pass_1: Mesh (显示用的网格)          ← 外观
├── draw_pass_2: Mesh (可选的第二通道)        ← 用于复杂效果
└── sub_emitter: GPUParticles3D (可选)        ← 子发射器
```

---

## 四、核心参数详解

### 4.1 时间参数

| 参数 | 说明 | 典型值 |
|------|------|--------|
| **lifetime** | 粒子存活时间 | 1.0 - 5.0 秒 |
| **lifetime_randomness** | 寿命随机变化比例 | 0.0 - 0.5 |
| **explosiveness** | 0=持续发射, 1=一次性爆发 | 0.0 或 1.0 |
| **fixed_fps** | 固定更新率（0=每帧） | 0 或 30 |
| **interpolate** | 是否插值（平滑运动） | true |
| **fractional_delta** | 使用帧时间的分数部分 | true（更平滑） |

### 4.2 发射参数（Emission）

| 参数 | 说明 |
|------|------|
| **amount** | 同时存在的最大粒子数 | 100 - 10000 |
| **amount_ratio** | 粒子数量缩放因子 | 0.0 - 1.0 |

#### 发射形状（Emission Shape）

| 形状 | 说明 | 适用场景 |
|------|------|----------|
| **Point** | 单点发射 | 火花、爆炸中心 |
| **Sphere** | 球体内随机 | 魔法光环、烟雾 |
| **Sphere Surface** | 球表面 | 护盾、气泡 |
| **Ring** | 环形 | 传送门、漩涡 |
| **Box** | 盒体内 | 方形区域效果 |
| **Positions** | 自定义多点 | 复杂形状发射 |
| **Directed Points** | 带方向的自定义点 | 定向喷射 |

**Emission Shape 参数：**

```gdscene
# Sphere 形状示例
emission_shape = EMISSION_SHAPE_SPHERE
emission_sphere_radius = 2.0       # 半径
emission_sphere_inner_radius = 0.5  # 内半径（空心球）

# Box 形状示例
emission_shape = EMISSION_SHAPE_BOX
emission_box_extents = Vector3(5, 3, 1)  # 尺寸
```

### 4.3 运动参数（Motion）

| 参数 | 说明 | 正值效果 |
|------|------|----------|
| **direction** | 初始运动方向向量 | - |
| **spread** | 方向扩散角度（弧度） | 更分散 |
| **initial_velocity_min/max** | 初始速度范围 | 更快 |
| **velocity_limit** | 最大速度限制 | 限制极速 |
| **gravity** | 重力加速度向量 | 向下拉动 |

**典型配置：**

```gdscene
# 烟雾上升
direction = Vector3(0, 1, 0)     # 向上
initial_velocity_min = 0.5
initial_velocity_max = 2.0
gravity = Vector3(0, -0.5, 0)   # 微弱向下重力

# 爆炸向外
direction = Vector3(0, 1, 0)     # 主要向上
spread = PI * 0.5                # 90度扩散
initial_velocity_max = 10.0      # 高初速度
gravity = Vector3(0, -9.8, 0)   # 正常重力
```

### 4.4 阻尼参数（Damping）

| 参数 | 说明 |
|------|------|
| **damping** | 速度衰减系数（摩擦力） |
| **damping_min/max** | 阻尼随机范围 |

**应用**：
- 烟雾：高阻尼（快速停止）
- 火花：低阻尼（长时间飞行）
- 水/粘液：极高阻尼

### 4.5 外观参数（Appearance）

#### 缩放（Scale）

| 参数 | 说明 |
|------|------|
| **scale_min/max** | 初始缩放范围 |
| **scale_curve** | 随时间变化的缩放曲线（TextureCurve） |

#### 颜色（Color）

| 参数 | 说明 |
|------|------|
| **color** | 基础颜色 |
| **color_ramp** | 颜色渐变（TextureGradientRamp）|

**Color Ramp 配合示例：**

```
时间轴:  0% -------- 50% -------- 100%
颜色:   [白/黄] ---- [橙] ------ [红/透明]
效果:   明亮火焰 → 橙色主体 → 暗淡消失
```

### 4.6 纹理和材质

**绘制通道（Draw Pass）：**

```gdscene
# 简单粒子（使用 QuadMesh）
draw_pass_1 = preload("res://particle_quad.mesh")

# 复杂粒子（使用自定义 Mesh）
draw_pass_1 = preload("res://models/spark.obj")

# 多通道（叠加效果）
draw_pass_1 = glow_mesh    # 发光层
draw_pass_2 = core_mesh    # 核心层
```

**材质设置：**

```gdscene
# 为 draw_pass_1 设置材质
var material = StandardMaterial3D.new()
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
material.albedo_color = Color(1, 0.5, 0, 1)  # 橙色
material.billboard = true                     # 始终朝向相机
material.billboard_keep_scale = true
draw_pass_1.surface_set_material(0, material)
```

---

## 五、高级特性

### 5.1 子发射器（Sub-Emitters）

粒子死亡时触发新的粒子系统：

```gdscene
# 主粒子：火花
# 子发射器：火花消失时的烟雾

var main_sparks = GPUParticles3D.new()
main_sparks.process_material = sparks_material

var smoke_sub_emitter = GPUParticles3D.new()
smoke_sub_emitter.process_material = smoke_material

main_sparks.sub_emitter = smoke_sub_emitter  # 火花死亡时发射烟雾
```

### 5.2 碰撞检测（Collision）

> 详见 [particles/collision.rst](https://docs.godotengine.org/en/stable/tutorials/3d/particles/collision.html)

启用碰撞后粒子可与静态物体交互：

```gdscene
collision_mode = COLLISION_MODE_RIGID
collision_friction = 0.1
collision_bounce = 0.5
```

### 5.3 吸引子（Attractors）

> 详见 [particles/attractors.rst](https://docs.godotengine.org/en/stable/tutorials/3d/particles/attractors.html)

使用吸引子影响粒子运动轨迹：

- **吸引**：向指定点聚集
- **排斥**：从指定点散开
- **涡旋**：围绕轴线旋转

### 5.4 湍流（Turbulence）

> 详见 [particles/turbulence.rst](https://docs.godotengine.org/en/stable/tutorials/3d/particles/turbulence.html)

添加自然的不规则运动，模拟风、水流等效果。

### 5.5 粒子轨迹（Trails）

> 详见 [particles/trails.rst](https://docs.godotengine.org/en/stable/tutorials/3d/particles/trails.html)

为粒子添加拖尾效果，增强运动感。

---

## 六、代码控制

### 6.1 基本控制

```gdscene
@onready var particles: GPUParticles3D = $GPUParticles3D

func emit_burst():
    particles.emitting = true
    await get_tree().create_timer(particles.lifetime).timeout
    particles.emitting = false

func one_shot():
    particles.emitting = true  # explosiveness=1 时自动只发一次

func set_color(color: Color):
    var mat = particles.process_material as ParticleProcessMaterial
    mat.color = color

func set_amount(new_amount: int):
    particles.amount = new_amount
```

### 6.2 动态参数调整

```gdscene
# 根据武器等级调整粒子效果
func update_weapon_particles(level: int):
    var mat = $MuzzleFlash.process_material as ParticleProcessMaterial

    match level:
        1:
            mat.amount = 20
            mat.initial_velocity_max = 5.0
        2:
            mat.amount = 40
            mat.initial_velocity_max = 8.0
        3:
            mat.amount = 80
            mat.initial_velocity_max = 12.0
```

### 6.3 与动画系统集成

```gdscene
# 在 AnimationPlayer 中动画化粒子参数
# Track: GPUParticles3D : process_material : initial_velocity_max
# Keyframes: 5.0 → 15.0 → 5.0 (攻击时增强)
```

---

## 七、常用粒子效果配方

### 7.1 火焰

```gdscene
lifetime = 1.5
direction = Vector3(0, 1, 0)
spread = 0.3
initial_velocity_min = 1.0
initial_velocity_max = 3.0
gravity = Vector3(0, -0.5, 0)
scale_max = 0.5
color_ramp: 白 → 黄 → 橙 → 红 → 透明
```

### 7.2 烟雾

```gdscene
lifetime = 3.0
direction = Vector3(0, 1, 0)
spread = 0.5
initial_velocity_min = 0.5
initial_velocity_max = 1.5
gravity = Vector3(0, -0.2, 0)
damping = 0.98
scale_max = 2.0
color_ramp: 灰(半透明) → 灰(几乎透明)
```

### 7.3 爆炸

```gdscene
lifetime = 0.8
explosiveness = 1.0  # 一次性爆发
spread = PI          # 全方向
initial_velocity_max = 15.0
gravity = Vector3(0, -9.8, 0)
scale_curve: 快速放大然后缩小
color_ramp: 白 → 黄 → 橙 → 红
```

### 7.2 魔法光环

```gdscene
lifetime = 2.0
emission_shape = EMISSION_SHAPE_RING
emission_ring_radius = 2.0
emission_ring_height = 0.0
direction = Vector3.UP
spread = 0.1
initial_velocity_max = 0.5
gravity = Vector3.ZERO
damping = 0.95
color_ramp: 青(透明) → 蓝(半透明) → 紫(透明)
```

### 7.4 雨滴

```gdscene
lifetime = 1.0
direction = Vector3(0, -1, 0)
spread = 0.2
initial_velocity_min = 10.0
initial_velocity_max = 15.0
gravity = Vector3(0, -20.0, 0)  # 加速下落
scale_min = 0.05
scale_max = 0.1
color = Color(0.7, 0.7, 1.0, 0.6)  # 淡蓝色半透明
amount = 1000
```

---

## 八、性能优化

| 优化项 | 方法 | 收益 |
|--------|------|------|
| **限制粒子数** | amount 保持最小必要值 | 显著降低GPU负载 |
| **使用 LOD** | 远距离减少 amount 或禁用 | 减少远处计算 |
| **简化 Mesh** | 用 QuadMesh 替代复杂模型 | 减少顶点处理 |
| **避免过度透明** | Alpha Scissor > Alpha Blend | 减少排序开销 |
| **固定 FPS** | fixed_fps = 30（非关键效果） | 减少更新频率 |
| **烘焙到纹理** | 静态粒子预渲染为视频/纹理 | 运行时零开销 |
| **GPU Instancing** | MultiMeshInstance 替代粒子（大量相似物体） | 极高性能 |

---

## 九、参考链接

- [GPUParticles3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_gpuparticles3d.html)
- [ParticleProcessMaterial 官方文档](https://docs.godotengine.org/en/stable/classes/class_particleprocessmaterial.html)
- [CPUParticles3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_cpuparticles3d.html)
- [2D 粒子系统](05F_Particle_Systems_2D.md)
- [StandardMaterial3D](13D_Standard_Material_3D.md)
- [Spatial Shader](10D_Spatial_Shader.md)
