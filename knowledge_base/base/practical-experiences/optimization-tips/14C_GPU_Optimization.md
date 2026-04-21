# GPU 优化指南

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/3d/ 及性能优化相关文档

---

> 📖 **性能优化三部曲（本文是第3篇）：**
>
> ```
> [14A_General_Optimization.md] ◄── 第1篇：优化方法论 + 测量 + 技术索引（必读先导）
>         │
>         ├──► [14B_CPU_Optimization.md] ◄── 第2篇：CPU/脚本瓶颈深度诊断与修复
>         │
>         └──► [14C] 本文档 ◄── 第3篇：GPU/渲染瓶颈深度诊断与修复 ★ 本文
>             （Draw Call优化、Instancing、LOD、灯光、材质、后期处理、FSR）
> ```

---

## 一、GPU 瓶颈识别

### 1.1 如何判断是 GPU 瓶颈？

**症状**：
- 降低分辨率后帧率显著提升
- Profiler 中 "Frame" 时间主要在 "GPU" 区域
- 简化场景（减少物体/粒子/灯光）后帧率提升

### 1.2 常见 GPU 瓶颈来源

| 瓶颈类型 | 典型原因 |
|----------|----------|
| **填充率（Fill Rate）** | 大面积透明物体、多重叠粒子、后期处理 |
| **顶点处理（Vertex Processing）** | 高模、大量骨骼动画、GPU Skinning |
| **显存带宽（Memory Bandwidth）** | 大纹理、高分辨率 Render Target |
| **着色器复杂度（Shader Complexity）** | 复杂 PBR 材质、多光源、全局光照 |
| **Draw Call 过多** | 未使用合批、过多独立物体 |

---

## 二、Draw Call 优化

### 2.1 什么是 Draw Call？

每次 GPU 绘制一个物体的调用。Draw Call 越多，CPU→GPU 开销越大。

**目标**：尽量减少 Draw Call 数量（尤其移动平台 < 100-500）

### 2.2 合批技术（Batching）

#### 静态合批（Static Batching）
```
编辑器中合并静态物体为单个 Mesh
✅ 运行时零开销
❌ 物体不能单独移动/旋转
适用：建筑、地形、装饰物
```

#### 动态合批（Dynamic Batching）
```
运行时自动合并相似材质的小物体
✅ 自动化，无需手动操作
⚠️ 有 CPU 开销，仅适合小物体（< ~300 vertices）
适用：碎片、UI 元素、小道具
```

#### GPU Instancing（推荐）
```
相同 Mesh + 相同 Material 的多个实例一次绘制
✅ 极高效，支持数千实例
✅ 每个实例可有不同变换和属性
适用：森林、草地、人群、子弹
```

**GPU Instancing 使用：**

```gdscene
# 方法1：MultiMeshInstance3D 节点
var mmi = MultiMeshInstance3D.new()
var mm = MultiMesh.new()
mm.mesh = preload("res://tree.obj")
mm.transform_format = MultiMesh.TRANSFORM_3D
mm.instance_count = 1000

for i in range(mm.instance_count):
    var position = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
    mm.set_instance_transform(i, Transform3D(Basis(), position))

mmi.multimesh = mm
add_child(mmi)

# 方法2：StandardMaterial3D 启用
material.use_in_instancing_rendering = true
```

### 2.3 合并图集（Texture Atlas）

将多张小纹理合并成一张大图：

```gdscene
# 优点：
# - 减少 Draw Call（共享材质）
# - 减少纹理切换开销
# - 提高缓存命中率

# 工具选项：
# - 手动在图像编辑器中拼接
# - 使用 TexturePacker 等工具
# - Godot 的 AtlasTexture 资源
```

---

## 三、渲染优化

### 3.1 减少过度绘制（Overdraw）

**问题**：同一像素被多次绘制（如多层透明 UI、大面积粒子）

**解决方案：**

```gdscene
# ✅ 使用 Alpha Scissor 替代 Alpha Blend
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR

# ✅ 使用 Depth Pre-Pass
material.transparency = BaseMaterial3D.TRANSPARENCY_DEPTH_PREPASS

# ✅ 限制粒子屏幕大小
$GPUParticles3D.use_local_coordinates = false  # 世界坐标模式便于控制

# ✅ 远距离禁用粒子效果
func _process(delta):
    var dist_to_camera = global_position.distance_to($Camera3D.global_position)
    $Particles.visible = dist_to_camera < MAX_PARTICLE_DISTANCE
    if dist_to_camera > FAR_DISTANCE:
        $Particles.emitting = false
```

### 3.2 视锥剔除（Frustum Culling）与遮挡剔除（Occlusion Culling）

Godot 自动进行视锥剔除（相机视野外的物体不渲染）。

**遮挡剔除**需额外配置：

```gdscene
# 1. 在场景中放置 OccluderInstance3D（遮挡体）
# 2. Project Settings → Rendering → Occlusion Culling → 启用
# 3. 运行游戏生成 BVH 数据（或使用编辑器工具烘焙）
```

> **适用场景**：城市街道、室内环境、有大量被墙壁遮挡的物体

### 3.3 LOD（Level of Detail）

根据距离使用不同精度的模型：

```gdscene
# 方法1：Visibility Range（Godot 4.x 内置）
mesh.visibility_range_begin = 10.0   # 最近距离
mesh.visibility_range_end = 100.0    # 最远距离
mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF

# 方法2：手动 LOD 切换
func _process(delta):
    var dist = global_position.distance_to($Camera3D.global_position)

    match true:
        dist < 20:
            mesh.mesh = high_poly_mesh
        dist < 50:
            mesh.mesh = medium_poly_mesh
        _:
            mesh.mesh = low_poly_mesh  # 或隐藏
```

**LOD 距离参考值（基于典型角色高度 1.8m）：**

| LOD级别 | 距离 | 多边形数建议 |
|--------|------|-------------|
| LOD0 (最高) | 0 - 20m | 5,000 - 50,000 |
| LOD1 | 20 - 50m | 1,000 - 5,000 |
| LOD2 | 50 - 100m | 500 - 1,000 |
| LOD3 (最低) | > 100m | < 500 或 Billboard/Cross |

---

## 四、灯光优化

### 4.1 光照成本

| 类型 | 性能影响 |
|------|----------|
| **DirectionalLight3D** | ⚡ 低（通常1-2个，用于太阳/月亮） |
| **OmniLight3D** | ⚡⚡ 中等（范围越大越慢） |
| **SpotLight3D** | ⚡⚡ 中等（类似 Omni 但有方向限制） |
| **阴影** | 🐢🐢 **极高**（最大的性能杀手之一） |

### 4.2 优化策略

```gdscene
# ✅ 限制阴影投射光源数量（< 3-4 个实时阴影）
$DirectionalLight3D.shadow_enabled = true  # 主光源
$OmniLight3D.shadow_enabled = false        # 其他光源关闭阴影

# ✅ 降低阴影地图分辨率
light.shadow_map_size = 512  # 或 1024（默认2048太贵）

# ✅ 使用 LightmapGI（静态光照）替代实时光照
# 对于不变的光照/阴影，预烘焙到纹理

# ✅ 使用 SDFGI/VoxelGI（全局光照缓存）
# 比 realtime GI 每帧成本低很多

# ✅ 远距离物体禁用光照
func update_based_on_distance():
    for light in get_tree().get_nodes_in_group("detail_lights"):
        var dist = global_position.distance_to(light.global_position)
        light.visible = dist < LIGHT_MAX_DISTANCE
```

### 4.3 Light Groups 和 Layers

```gdscene
# 使用 Light Layers 限制哪些物体受哪些光影响
light.light_layer = 1  # 只有 layer=1 的物体会被此光照射
mesh.light_layer = 1   # 此物体只接收 layer=1 的光
```

---

## 五、材质和着色器优化

### 5.1 简化材质

```gdscene
# ✅ 使用 unshaded 模式（不需要光照计算的物体）
material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
# 适用：UI元素、全发光物体、卡通轮廓

# ✅ 关闭不需要的功能
material.vertex_lighting = false       # 不需要逐顶点光照
material.detail_enabled = false         # 不需要细节纹理
material.clearcoat_enabled = false      # 不需要清漆层
material.rim_enabled = false            # 不需要边缘光
material.subsurf_scatter_enabled = false # 不需要次表面散射

# ✅ 使用较低精度法线贴图
material.normalmap_depth = 2.0  # 降低强度可接受时减小
```

### 5.2 着色器优化技巧

```glsl
// ❌ 避免：复杂计算每像素执行
void fragment() {
    // 100次 sin/cos 计算...
}

// ✅ 推荐：预计算或简化
void fragment() {
    // 使用 LUT（查找表）纹理存储复杂函数结果
    float value = texture(lut_texture, uv).r;
}

// ❌ 避免：过多的纹理采样
color = texture(tex1, uv) + texture(tex2, uv) + texture(tex3, uv) + ...

// ✅ 推荐：合并纹理到图集（Atlas）
color = texture(atlas_tex, uv1) + texture(atlas_tex, uv2);

// ✅ 使用分支优化（避免动态分支）
// early out: 先做最可能的判断
if (ALPHA < 0.01) {
    discard;  // 尽早丢弃透明像素
}
```

### 5.3 渲染器选择

| 渲染器 | 特点 | 适用平台 |
|--------|------|----------|
| **Forward+** | 功能最全，质量最高 | PC、高性能主机 |
| **Mobile** | 移动优化，功能折中 | iOS、Android |
| **Compatibility** | 最大兼容性 | Web、低端硬件 |

```gdscene
# Project Settings → Rendering → Renderer → Renderer
# Mobile/Web: 选择 "mobile" 或 "gl_compatibility"
```

---

## 六、后期处理优化

后期处理通常是**非常昂贵**的：

| 效果 | 性能消耗 | 优化建议 |
|------|----------|----------|
| **Glow/Bloom** | 🐢🐢 高 | 降低 Bloom 强度/阈值，降低分辨率 |
| **DOF（景深）** | 🐢🐢 高 | 仅在过场动画中使用 |
| **Motion Blur** | 🐢🐢 高 | 可选效果，移动端常禁用 |
| **SSR（屏幕空间反射）** | 🐢🐢🐢 极高 | 用反射探针替代 |
| **SSAO** | 🐢🐢 高 | 降低质量/分辨率 |
| **SDFGI** | 🐢🐢 高 | 缓存更新频率 |
| **TAA/FSR** | 🐢 中等 | 抗锯齿的必要代价 |

**优化配置：**

```gdscene
# WorldEnvironment → Environment
env.glow_enabled = true
env.glow_bloom = 0.5          # 降低泛光强度
env.glow_intensity = 0.8       # 降低整体亮度
env.dof_mode = Environment.DOF_DISABLED  # 禁用景深
env.ssr_enabled = false        # 禁用SSR（用反射探针代替）
env.ssao_enabled = false        # 或降低质量
env.sdfgi_enabled = true
env.sdfgi_framesToUpdateLight = 4  # 每4帧更新一次光照
env.sdfgi_framesToUpdateProbes = 8  # 每8帧更新探针
```

---

## 七、分辨率缩放（Resolution Scaling）

### 7.1 动态分辨率

```gdscene
# 根据帧率自动调整渲染分辨率
extends Node

@export var target_fps: float = 60.0
@export var min_scale: float = 0.5
@export var max_scale: float = 1.0

var current_scale: float = 1.0

func _process(delta):
    var actual_fps = Engine.get_frames_per_second()

    if actual_fps < target_fps * 0.9:
        # 帧率过低，降低分辨率
        current_scale = maxi(current_scale - delta * 0.5, min_scale)
    elif actual_fps > target_fps and current_scale < max_scale:
        # 帧率充足，提高分辨率
        current_scale = mini(current_scale + delta * 0.25, max_scale)

    get_viewport().scaling_3d_scale = current_scale
```

### 7.2 FSR / FSR2（超分辨率）

Godot 4.x 支持 AMD FSR（FidelityFX Super Resolution）：

```gdscene
# Project Settings → Rendering → Textures → VRS
# 启用 FSR 后可以以更低分辨率渲染然后放大
get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
get_viewport().scaling_3d_scale = 0.7  # 以70%分辨率渲染
```

> **收益**：以 70% 分数率渲染可获得接近原生分辨率的画质，但性能提升约 **2倍**

---

## 八、VRS（Variable Rate Shading）

可变率着色：对画面不同区域使用不同的着色速率。

```gdscene
# 对非焦点区域（边缘）降低着色密度
get_viewport().vrs_mode = Viewport.VRS_TEXTURE
# 配合注视点渲染（Foveated Rendering），VR 应用必备
```

---

## 九、GPU 优化检查清单

| 检查项 | 操作 | 预期收益 |
|--------|------|----------|
| ✅ **Draw Call 分析** | 使用 Debugger → Monitor 查看 | 了解瓶颈 |
| ✅ **启用 GPU Instancing** | MultiMeshInstance / use_in_instancing_rendering | 大幅减少 Draw Call |
| ✅ **合并图集** | 小纹理打包成大图 | 减少材质切换 |
| ✅ **LOD 系统** | Visibility Range 或手动切换 | 远距离减少顶点 |
| ✅ **遮挡剔除** | OccluderInstance3D + BVH | 避免渲染不可见物体 |
| ✅ **限制阴影** | ≤ 2-3 个实时光源投射阴影 | 显著提升性能 |
| ✅ **简化材质** | 关闭不需要的功能（unshaded/detail/clearcoat） | 减少像素着色 |
| ✅ **优化透明度** | Alpha Scissor > Alpha Blend | 减少过度绘制 |
| ✅ **后期处理精简** | 禁用不必要的 DOF/MotionBlur/SSR | 减少后处理开销 |
| ✅ **分辨率缩放** | 动态分辨率或 FSR | 按需平衡画质/性能 |
| ✅ **渲染器选择** | Mobile端用Mobile渲染器 | 移动端优化 |

---

## 十、参考链接

- [GPU 优化官方文档](https://docs.godotengine.org/en/stable/tutorials/3d/mesh_lod.html)
- [Occlusion Culling](https://docs.godotengine.org/en/stable/tutorials/3d/occlusion_culling.html)
- [Visibility Ranges](https://docs.godotengine.org/en/stable/tutorials/3d/visibility_ranges.html)
- [Resolution Scaling](https://docs.godotengine.org/en/stable/tutorials/3d/resolution_scaling.html)
- [MultiMeshInstance](https://docs.godotengine.org/en/stable/classes/class_multimeshinstance3d.html)
- [StandardMaterial3D](13D_Standard_Material_3D.md)
- [Spatial Shader](10D_Spatial_Shader.md)
- [通用优化指南](14A_General_Optimization.md)
- [CPU 优化指南](14B_CPU_Optimization.md)
