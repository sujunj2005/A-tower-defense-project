# 性能优化实战指南

> **最后更新**: 2026-04-07  
> **适用版本**: Godot 4.x  
> **来源**: [14A_General_Optimization.md](../../base/practical-experiences/optimization-tips/14A_General_Optimization.md), [14B_CPU_Optimization.md](../../base/practical-experiences/optimization-tips/14B_CPU_Optimization.md), [14C_GPU_Optimization.md](../../base/practical-experiences/optimization-tips/14C_GPU_Optimization.md)

---

## 📖 文档概述

本指南整合了 Godot 4.x 性能优化的完整知识体系，包含优化方法论、CPU 优化实战和 GPU 优化实战三大部分。

**性能优化三部曲**：
```
[入门层] 性能优化通用指南 ◄── 本文档（整合版）
    │
    ├──► [CPU 优化] 脚本/物理/AI/GC 优化实战
    │       （Profiler 使用、脚本优化、物理优化、GC 调优）
    │
    └──► [GPU 优化] 渲染/着色器/灯光/材质优化实战
            （Draw Call、Instancing、LOD、灯光、后期处理、FSR）
```

---

## 📋 目录

1. [优化方法论](#1-优化方法论)
2. [性能测量技术](#2-性能测量技术)
3. [CPU 优化实战](#3-cpu-优化实战)
4. [GPU 优化实战](#4-gpu-优化实战)
5. [优化检查清单](#5-优化检查清单)

---

## 1. 优化方法论

### 1.1 两种优化途径

- **工作更快**：优化代码效率，提升性能
- **工作更聪明**：使用技巧"欺骗"玩家，让他们相信世界比实际更复杂

### 1.2 Donald Knuth 名言

> 过早优化是万恶之源。97% 的时间我们应该忘记小的效率问题。

### 1.3 优化流程

```
1. 测量 → 找到瓶颈
   ↓
2. 分析 → 理解问题
   ↓
3. 优化 → 解决问题
   ↓
4. 验证 → 测量改进
```

### 1.4 问题类型分类

| 类型 | 症状 | 解决方向 |
|------|------|----------|
| **持续慢速** | FPS 持续低于目标值 | CPU/GPU 瓶颈分析 |
| **间歇性卡顿** | FPS 突然下降然后恢复 | GC/资源加载/大循环 |
| **加载慢速** | 关卡加载时间长 | 后台加载 + 压缩纹理 |

---

## 2. 性能测量技术

### 2.1 测量方法概览

| 方法 | 适用场景 | 详细说明 |
|------|----------|----------|
| **计时器** | 精确测量代码段耗时 | 使用 `Time.get_ticks_usec()` |
| **Godot Profiler** | 内置分析，查看函数调用 | 📖 [17B_Profiler](../../07_Debug_and_Testing/17B_Profiler.md) |
| **外部 CPU Profiler** | 深度 CPU 分析 | VeryL、Instruments 等 |
| **GPU Profiler** | GPU 瓶颈诊断 | Nsight、Radeon Profiler |
| **帧率检查** | 快速判断是否达标 | `Engine.get_frames_per_second()` |

### 2.2 快速 FPS 监控

```gdscript
# 简单 FPS 监控
func _process(_delta):
    if Engine.get_frames_per_second() < 55:
        $FPSLabel.add_theme_color_override("font_color", Color.RED)
    else:
        $FPSLabel.add_theme_color_override("font_color", Color.GREEN)
    $FPSLabel.text = "FPS: %d" % Engine.get_frames_per_second()
```

### 2.3 判断 CPU vs GPU 瓶颈

```
降低分辨率测试：
├─ FPS 显著提升 → GPU 瓶颈
├─ FPS 基本不变 → CPU 瓶颈
└─ 禁用脚本后 FPS 提升 → CPU 瓶颈（脚本逻辑）
```

---

## 3. CPU 优化实战

### 3.1 常见瓶颈与优化

| 瓶颈 | 典型症状 | 解决方向 |
|------|----------|----------|
| 脚本逻辑 | 特定函数耗时高 | 优化算法、减少调用 |
| 物理计算 | 物理占比过高 | 减少碰撞体、简化形状 |
| GC | 周期性卡顿 | 复用对象、避免频繁创建 |

### 3.2 脚本优化技巧

#### 3.2.1 减少每帧计算

```gdscript
# ❌ 错误：每帧计算距离
func _process(delta):
    var dist = global_position.distance_to(target)
    
# ✅ 正确：定时检查
var _check_timer := 0.0
func _process(delta):
    _check_timer += delta
    if _check_timer >= 0.5:
        _check_timer = 0.0
        check_distance()
```

#### 3.2.2 缓存节点引用

```gdscript
# ❌ 错误
func _process(delta):
    $Sprite.position += velocity * delta

# ✅ 正确
@onready var sprite: Sprite2D = $Sprite
func _process(delta):
    sprite.position += velocity * delta
```

#### 3.2.3 使用类型化数组

```gdscript
# 较慢
var arr = []
# 较快
var arr: Array[Node] = []
# 最快（避免类型检查）
var arr: Array[Enemy] = []
```

#### 3.2.4 对象池模式

```gdscript
var pool: Array[Node] = []

func get_object():
    for obj in pool:
        if not obj.visible:
            return obj
    return create_new_object()

func return_object(obj: Node):
    obj.visible = false
    pool.append(obj)
```

#### 3.2.5 减少绘制调用

- 使用 Sprite Sheet 合并多个精灵
- 合并静态背景为单个纹理
- 使用 TileMap 替代大量独立 Sprite

### 3.3 物理优化

#### 3.3.1 move_and_slide 已包含 delta

```gdscript
velocity.y += gravity * delta  # ✅ 加速度需要乘 delta
move_and_slide()               # ✅ 不需要再乘 delta！
```

#### 3.3.2 RigidBody 避免直接设置位置

```gdscript
# ❌ 错误：会破坏物理模拟
func _process(delta):
    position += velocity * delta

# ✅ 正确：使用 _integrate_forces
func _integrate_forces(state):
    state.linear_velocity = velocity
```

#### 3.3.3 CollisionShape Scale 必须保持 (1,1)

```gdscript
# ❌ 错误：scale 无效
$CollisionShape2D.scale = Vector2(2, 2)

# ✅ 正确：调整 shape 属性
$CollisionShape2D.shape.size = Vector2(64, 64)
```

### 3.4 GC 优化

#### 3.4.1 避免频繁创建对象

```gdscript
# ❌ 错误：每帧创建新数组
func _process(delta):
    var temp_array = []
    # ... 使用 temp_array

# ✅ 正确：复用数组
var temp_array: Array = []
func _process(delta):
    temp_array.clear()
    # ... 使用 temp_array
```

#### 3.4.2 使用 queue_free 替代 free

```gdscript
# ❌ 错误：立即删除可能导致崩溃
node.free()

# ✅ 正确：延迟到帧末删除
node.queue_free()
```

---

## 4. GPU 优化实战

### 4.1 Draw Call 优化

#### 4.1.1 GPU Instancing（强烈推荐）

```gdscript
# 方法 1：MultiMeshInstance3D 节点
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

# 方法 2：StandardMaterial3D 启用
material.use_in_instancing_rendering = true
```

#### 4.1.2 合并图集（Texture Atlas）

将多张小纹理合并成一张大图：
- 减少 Draw Call（共享材质）
- 减少纹理切换开销
- 提高缓存命中率

### 4.2 LOD（Level of Detail）

```gdscript
# 方法 1：Visibility Range（Godot 4.x 内置）
mesh.visibility_range_begin = 10.0   # 最近距离
mesh.visibility_range_end = 100.0    # 最远距离
mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF

# 方法 2：手动 LOD 切换
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

| LOD 级别 | 距离 | 多边形数建议 |
|--------|------|-------------|
| LOD0 (最高) | 0 - 20m | 5,000 - 50,000 |
| LOD1 | 20 - 50m | 1,000 - 5,000 |
| LOD2 | 50 - 100m | 500 - 1,000 |
| LOD3 (最低) | > 100m | < 500 或 Billboard/Cross |

### 4.3 灯光优化

#### 4.3.1 光照成本对比

| 类型 | 性能影响 |
|------|----------|
| **DirectionalLight3D** | ⚡ 低（通常 1-2 个，用于太阳/月亮） |
| **OmniLight3D** | ⚡⚡ 中等（范围越大越慢） |
| **SpotLight3D** | ⚡⚡ 中等（类似 Omni 但有方向限制） |
| **阴影** | 🐢🐢 **极高**（最大的性能杀手之一） |

#### 4.3.2 优化策略

```gdscript
# ✅ 限制阴影投射光源数量（< 3-4 个实时阴影）
$DirectionalLight3D.shadow_enabled = true  # 主光源
$OmniLight3D.shadow_enabled = false        # 其他光源关闭阴影

# ✅ 降低阴影地图分辨率
light.shadow_map_size = 512  # 或 1024（默认 2048 太贵）

# ✅ 使用 LightmapGI（静态光照）替代实时光照
# 对于不变的光照/阴影，预烘焙到纹理

# ✅ 远距离物体禁用光照
func update_based_on_distance():
    for light in get_tree().get_nodes_in_group("detail_lights"):
        var dist = global_position.distance_to(light.global_position)
        light.visible = dist < LIGHT_MAX_DISTANCE
```

### 4.4 材质和着色器优化

#### 4.4.1 简化材质

```gdscript
# ✅ 使用 unshaded 模式（不需要光照计算的物体）
material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
# 适用：UI 元素、全发光物体、卡通轮廓

# ✅ 关闭不需要的功能
material.vertex_lighting = false       # 不需要逐顶点光照
material.detail_enabled = false         # 不需要细节纹理
material.clearcoat_enabled = false      # 不需要清漆层
material.rim_enabled = false            # 不需要边缘光
material.subsurf_scatter_enabled = false # 不需要次表面散射
```

#### 4.4.2 着色器优化技巧

```glsl
// ❌ 避免：复杂计算每像素执行
void fragment() {
    // 100 次 sin/cos 计算...
}

// ✅ 推荐：预计算或简化
void fragment() {
    // 使用 LUT（查找表）纹理存储复杂函数结果
    float value = texture(lut_texture, uv).r;
}

// ✅ 使用分支优化（避免动态分支）
// early out: 先做最可能的判断
if (ALPHA < 0.01) {
    discard;  // 尽早丢弃透明像素
}
```

### 4.5 后期处理优化

后期处理通常是**非常昂贵**的：

| 效果 | 性能消耗 | 优化建议 |
|------|----------|----------|
| **Glow/Bloom** | 🐢🐢 高 | 降低 Bloom 强度/阈值 |
| **DOF（景深）** | 🐢🐢 高 | 仅在过场动画中使用 |
| **Motion Blur** | 🐢🐢 高 | 可选效果，移动端常禁用 |
| **SSR（屏幕空间反射）** | 🐢🐢🐢 极高 | 用反射探针替代 |
| **SSAO** | 🐢🐢 高 | 降低质量/分辨率 |
| **SDFGI** | 🐢🐢 高 | 缓存更新频率 |

```gdscript
# WorldEnvironment → Environment
env.glow_enabled = true
env.glow_bloom = 0.5          # 降低泛光强度
env.glow_intensity = 0.8       # 降低整体亮度
env.dof_mode = Environment.DOF_DISABLED  # 禁用景深
env.ssr_enabled = false        # 禁用 SSR（用反射探针代替）
env.ssao_enabled = false        # 或降低质量
env.sdfgi_enabled = true
env.sdfgi_framesToUpdateLight = 4  # 每 4 帧更新一次光照
env.sdfgi_framesToUpdateProbes = 8  # 每 8 帧更新探针
```

### 4.6 分辨率缩放（Resolution Scaling）

#### 4.6.1 动态分辨率

```gdscript
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

#### 4.6.2 FSR / FSR2（超分辨率）

```gdscript
# Godot 4.x 支持 AMD FSR（FidelityFX Super Resolution）
get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
get_viewport().scaling_3d_scale = 0.7  # 以 70% 分辨率渲染
```

> **收益**：以 70% 分数率渲染可获得接近原生分辨率的画质，但性能提升约 **2 倍**

---

## 5. 优化检查清单

### 5.1 CPU 优化检查清单

| 检查项 | 操作 | 预期收益 |
|--------|------|----------|
| ✅ **减少每帧计算** | 用信号/定时器替代 `_process` 中的高频检测 | ⚡⚡⚡ 降低 CPU 占用 |
| ✅ **缓存节点引用** | `@onready` 替代每帧 `get_node()` | ⚡⚡ 减少树查找 |
| ✅ **类型化数组** | `Array[Enemy]` 替代 `Array` | ⚡⚡ 减少类型检查 |
| ✅ **对象池** | 预创建对象复用，避免频繁 new/queue_free | ⚡⚡⚡ 消除 GC 峰值 |
| ✅ **空间划分** | 四叉树/网格管理大量实体 | ⚡⚡⚡ O(log n) 查找 |

### 5.2 GPU 优化检查清单

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

### 5.3 快速决策流程

```
遇到性能问题？
│
├─ FPS 持续低？→ 用 Profiler 定位瓶颈（📖 17B_Profiler）
│   ├─ 脚本/物理/AI 占比高？→ 查 CPU 优化（本节第 3 章）
│   └─ GPU/渲染占比高？     → 查 GPU 优化（本节第 4 章）
│
├─ 间歇性卡顿？→ 检查 GC / 资源加载 / 大循环
│
└─ 加载慢？      → 后台加载（📖 15D_Background_Loading）+ 压缩纹理
```

---

## 🔗 相关文档

### 详细专题文档

- **[CPU 优化深度指南](../../base/practical-experiences/optimization-tips/14B_CPU_Optimization.md)** - Profiler 详解、脚本/物理/AI/GC 优化实战
- **[GPU 优化深度指南](../../base/practical-experiences/optimization-tips/14C_GPU_Optimization.md)** - Draw Call 优化、Instancing、LOD、灯光、材质、后期处理、FSR
- **[性能测量工具使用](../../07_Debug_and_Testing/17B_Profiler.md)** - Godot Profiler 详细教程

### 相关概念页面

- [GDScript 代码规范](../concepts/gdscript-standards.md) - 代码性能相关的规范
- [攻击系统设计](../concepts/attack-system.md) - 包含性能优化设计

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator
