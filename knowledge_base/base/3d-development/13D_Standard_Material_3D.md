# StandardMaterial3D 和 ORMMaterial3D 材质详解

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/3d/standard_material_3d.rst

---

## 一、简介

**StandardMaterial3D** 和 **ORMMaterial3D**（Occlusion, Roughness, Metallic）是 Godot 默认的3D材质，无需编写着色器代码即可实现大部分美术需求。

两种材质几乎相同，唯一区别：
- **StandardMaterial3D**：AO、Roughness、Metallic 分别设置
- **ORMMaterial3D**：使用单张 ORM 纹理（Substance Painter/Armor Paint 可导出此格式）

---

## 二、添加材质的方式（4种）

| 方式 | 位置 | 作用范围 |
|------|------|----------|
| **Mesh Material** | 网格的 Material 属性 | 每次使用该网格都应用 |
| **Node Material** | 使用网格节点的 Material 属性 | 仅该节点，覆盖网格材质 |
| **Material Override** | 节点的 Material Override 属性 | 仅该节点，覆盖上述两者 |
| **Material Overlay** | 节点的 Material Overlay 属性 | 在当前材质之上渲染（如透明护盾效果） |

---

## 三、透明度（Transparency）

### 3.1 默认行为

默认情况下材质是**不透明的**，渲染最快，即使使用透明纹理也不会显示透明效果。

### 3.2 透明模式对比

| 模式 | 渲染速度 | 特点 | 适用场景 |
|------|----------|------|----------|
| **Disabled** | ⚡⚡⚡ 最快 |完全不透明，支持全部渲染特性 | 地形、建筑等不透明物体 |
| **Alpha** | ⚡ 较慢 | 半透明区域混合，可能有排序问题 | 粒子特效、VFX |
| **Alpha Scissor** | ⚡⚡ 快 | 低于阈值不绘制，无排序问题 | 树叶、栅栏（硬边缘） |
| **Alpha Hash** | ⚡⚡ 快 | 抖动显示半透明 | 写实头发 |
| **Depth Pre-Pass** | ⚡⚡ | 先渲染不透明像素再做alpha混合 | 需要正确排序的透明物体 |

### 3.3 Alpha 混合的限制

> **警告**：Alpha混合有以下限制：
>
> - 渲染速度显著降低（尤其重叠时）
> - 可能出现**排序问题**（后面的面显示在前面）
> - **不能投射阴影**（但能接收阴影）
> - **不出现在反射中**（除反射探针外）
> - SDFGI 反射不可用（强制使用粗糙反射）

**建议**：优先考虑 Alpha Scissor 或 Alpha Hash

### 3.4 Alpha 抗锯齿（Alpha Antialiasing）

仅当透明模式为 **Alpha Scissor** 或 **Alpha Hash** 时可用：

| 模式 | 效果 | 别名 |
|------|------|------|
| **Disabled** | 无抗锯齿 | - |
| **Alpha Edge Blend** | 平滑过渡 | alpha to coverage |
| **Alpha Edge Clip** | 锐利但抗锯齿边缘 | alpha to coverage + alpha to one |

> **重要**：使用 Alpha 抗锯齿时，Project Settings 中 MSAA 3D 应至少设为 **2×**

**参数关系**：
- `Alpha Antialiasing Edge` 必须 **严格小于** `Alpha Scissor Threshold`
- 默认值：Edge=0.3, Threshold=0.5

---

## 四、混合模式（Blend Mode）

| 模式 | 效果 | 强制透明管线？ |
|------|------|----------------|
| **Mix** | 默认，alpha控制可见度 | ❌ |
| **Add** | 颜色叠加到屏幕 | ✅（光晕、火焰效果） |
| **Subtract** | 从屏幕减去颜色 | ✅ |
| **Multiply** | 与屏幕颜色相乘 | ✅ |
| **Premultiplied Alpha** | 预乘alpha | ✅ |

> **注意**：除 Mix 外的所有模式都会强制对象进入透明管线

---

## 五、剔除模式（Cull Mode）

| 模式 | 行为 |
|------|------|
| **Back** | 剔除背面（默认，性能好） |
| **Front** | 剔除正面（用于室内墙面等） |
| **Disabled** | 双面渲染（性能开销大） |

---

## 六、材质参数详解

### 6.1 Albedo（反照率/基础颜色）

控制物体的基础颜色：

- **Color**：基础颜色（白色 = 完全反射纹理）
- **Texture**：反照率纹理
- **Albedo Texture Force sRGB**：是否使用 sRGB 色彩空间

### 6.2 Metallic（金属度）

- **0.0** = 非金属（电介质）
- **1.0** = 纯金属
- 影响高光和反射强度

### 6.3 Roughness（粗糙度）

- **0.0** = 完全光滑（镜面反射）
- **1.0** = 完全粗糙（漫反射）
- 影响高光的模糊程度

### 6.4 Emission（自发光）

- 使物体看起来像自己在发光
- 可配合 **Emission Operator** 使用（Add/Multiply）
- 需要 **Emission Energy Multiplier** 控制强度

### 6.5 Normal Map（法线贴图）

- 模拟表面细节凹凸
- **NormalMap Depth**：深度强度（0-10左右典型值）
- 需要 Tangent 信息（导入时确保开启）

### 6.6 ORM 纹理通道映射（ORMMaterial3D）

| 通道 | 参数 |
|------|------|
| **Red** | Occlusion（环境光遮蔽） |
| **Green** | Roughness（粗糙度） |
| **Blue** | Metallic（金属度） |

---

## 七、高级特性

### 7.1 清漆层（Clearcoat）

模拟汽车清漆等表面效果：
- **Clearcoat**：清漆强度（0-1）
- **Clearcoat Roughness**：清漆粗糙度

### 7.2 高光（Specular）

- **Specular Mode**：
  - **Schlick-GGX**：物理准确（默认）
  - **Toon**：卡通风格
  - **Blinn**：传统 Blinn-Phong
- **Metallic Specular**：金属高光强度

### 7.3 各向异性（Anisotropy）

模拟拉丝金属、CD表面等效果：
- **Anisotropy**：各向异性强度

### 7.4 细节纹理（Detail）

- **Detail Albedo**：细节反照率
- **Detail Normal**：细节法线
- 用于添加表面微细节（织物纹理、皮肤毛孔等）

### 7.5 距离淡出（Distance Fade）

- **Enabled**：启用基于距离的淡出
- **Distance**：开始淡出的距离
- **Fade mode**：渐变方式

### 7.6 接近淡出（Proximity Fade）

- 基于相机距离的淡出
- 适用于植被、雾效边界等

---

## 八、常用材质配置示例

### 8.1 标准PBR材质
```gdscript
var material = StandardMaterial3D.new()
material.albedo_color = Color.WHITE
material.metallic = 0.0
material.roughness = 0.5
material.normal_enabled = true
material.normal_texture = load("res://normal_map.png")
mesh.surface_set_material(0, material)
```

### 8.2 发光材质
```gdscript
var material = StandardMaterial3D.new()
material.albedo_color = Color(1, 0.5, 0)
material.emission_enabled = true
material.emission = Color(1, 0.5, 0)
material.emission_energy_multiplier = 2.0
```

### 8.3 透明材质（树叶）
```gdscript
var material = StandardMaterial3D.new()
material.albedo_texture = load("res://leaf.png")
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
material.alpha_scissor_threshold = 0.5
material.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_EDGE_BLEND
material.cull_mode = BaseMaterial3D.CULL_DISABLED  # 双面
```

### 8.4 卡通/Toon材质
```gdscript
var material = StandardMaterial3D.new()
material.shading_mode = BaseMaterial3D.SHADING_MODE_TOON
material.specular_mode = BaseMaterial3D.SPECULAR_TOON
material.roughness = 0.1  # 锐利高光
```

---

## 九、性能优化建议

| 场景 | 建议 |
|------|------|
| **大量静态物体** | 使用 Disabled 透明 + Back 剔除 |
| ** foliage/植被** | Alpha Scissor + 双面剔除禁用 |
| **粒子特效** | Alpha 混合（接受排序问题） |
| **UI/HUD 3D元素** | Depth Pre-Pass 保证排序 |
| **移动平台** | 降低纹理分辨率，减少 Normal Map 使用 |
| **远景物体** | 使用 Distance Fade 减少绘制 |

---

## 十、参考链接

- [StandardMaterial3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_standard_material3d.html)
- [BaseMaterial3D 官方文档](https://docs.godotengine.org/en/stable/classes/class_basematerial3d.html)
- [Spatial Shader 教程](10D_Spatial_Shader.md)
- [3D 光照阴影](13C_Lights_and_Shadows.md)
- [3D 渲染限制](https://docs.godotengine.org/en/stable/tutorials/3d/3d_rendering_limitations.html)
