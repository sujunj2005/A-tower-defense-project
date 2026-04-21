# 2D 灯光和阴影概念

> **来源**: [05E_2D_Lights_and_Shadows.md](../../base/2d-development/05E_2D_Lights_and_Shadows.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本文档介绍 Godot 4.x 的 2D 光照与阴影系统，包括光源类型、阴影投射和性能考虑。

---

## 💡 光照系统概述

### 默认行为

默认情况下，2D 场景**无光照和阴影**，渲染速度快但视觉效果平淡。

### 启用效果

启用 2D 光照后可以显著增强场景的深度感和氛围。

---

## 🎭 所需节点

| 节点 | 用途 |
|------|------|
| `CanvasModulate` | 使场景变暗，作为基础环境色 |
| `PointLight2D` | 全向/聚光灯光 |
| `DirectionalLight2D` | 太阳光/月光 |
| `LightOccluder2D` | 阴影投射体 |
| `Sprite2D` / `TileMapLayer` | 接收光照的节点 |

> ⚠️ **踩坑点**: 背景颜色**不接收**任何光照。如果需要背景被照亮，需添加 Sprite2D 作为背景表示。

---

## 🔦 PointLight2D 点光源

### 常用场景

- 火把
- 火焰
- 投射物
- 台灯

### 重要属性

| 属性 | 说明 |
|------|------|
| `Texture` | 光源纹理（决定大小） |
| `Offset` | 纹理偏移（不移动阴影） |
| `Texture Scale` | 光源大小倍数 |
| `Height` | 虚拟高度（影响法线贴图） |
| `Color` | 光源颜色 |
| `Energy` | 光源强度 |

### 性能注意

> ⚠️ **踩坑点**: 更大的光源会影响更多像素，性能成本更高。增加光源大小时请考虑性能。

### 混合模式

| 模式 | 效果 |
|------|------|
| **Add** (默认) | 叠加模式，增亮 |
| **Mix** | 混合模式，自然过渡 |
| **Subtract** | 减去模式，变暗 |

---

## ☀️ DirectionalLight2D 平行光

### 用途

- 模拟太阳光
- 月光
- 全局光源

### 特点

- 所有物体产生相同方向的阴影
- 适合模拟全局光源
- 平行光没有位置概念，只有方向

---

## 🌑 阴影配置

### LightOccluder2D

告诉着色器场景的哪些部分投射阴影：

```gdscript
@onready var occluder = $LightOccluder2D

func _ready():
    occluder.occluder_light_mask = 1  # 只对第 1 个光源生效
```

### TileMapLayer 中的阴影

TileMapLayer 可以直接包含遮光数据，无需额外的 LightOccluder2D 节点。

### 阴影方向

阴影方向基于 PointLight2D 的中心位置计算。

---

## 🎨 实际应用场景

### 场景 1: 火把照明

```gdscript
# 创建火把光源
var torch_light = PointLight2D.new()
torch_light.texture = load("res://assets/light/torch_light.png")
torch_light.color = Color(1, 0.8, 0.5)  # 暖黄色
torch_light.energy = 1.5
torch_light.texture_scale = 2.0

# 添加闪烁效果
func _process(delta):
    light.energy = 1.5 + randf_range(-0.2, 0.2)
```

### 场景 2: 昼夜循环

```gdscript
# 使用 DirectionalLight2D 模拟太阳
var sun_light = DirectionalLight2D.new()
sun_light.light_color = Color(1, 1, 0.9)  # 白天
sun_light.light_energy = 1.0

# 切换到夜晚
func set_night():
    sun_light.light_color = Color(0.3, 0.3, 0.5)  # 冷蓝色
    sun_light.light_energy = 0.2
```

### 场景 3: 恐怖氛围

```gdscript
# 使用多个 PointLight2D 创建恐怖氛围
var spooky_lights = [
    {color = Color(1, 0, 0), energy = 0.8},    # 红色
    {color = Color(0, 1, 0), energy = 0.6},    # 绿色
    {color = Color(0, 0, 1), energy = 0.7},    # 蓝色
]
```

---

## ⚡ 性能优化

### 优化建议

1. **限制光源数量**
   - 每个场景使用 3-5 个动态光源
   - 使用烘焙光照替代动态光源（如果适用）

2. **合理设置光源大小**
   - 不要过度使用大光源
   - 小光源性能更好

3. **使用 Light Mask**
   - 只对需要的物体启用光照
   - 减少不必要的光照计算

### Light Mask 使用

```gdscript
# 设置光源的遮罩
point_light.light_mask = 1 | 2  # 对第 1 和第 2 层生效

# 设置物体的遮罩
sprite.light_mask = 1  # 只接收第 1 层光源
```

---

## ⚠️ 常见踩坑

### 踩坑 1: 背景不接收光照

**问题**: 设置背景颜色后，光照不生效

**解决方案**:
```gdscript
# ❌ 错误：背景颜色不接收光照
# 在 Project Settings 中设置背景颜色

# ✅ 正确：使用 Sprite2D 作为背景
var bg_sprite = Sprite2D.new()
bg_sprite.texture = load("res://assets/background.png")
```

### 踩坑 2: 阴影不显示

**可能原因**:
1. 没有添加 LightOccluder2D 节点
2. LightOccluder2D 的遮罩设置不正确
3. 光源的 light_mask 和物体的 light_mask 不匹配

**检查清单**:
- [ ] 添加了 LightOccluder2D 节点
- [ ] LightOccluder2D 有正确的 occluder 资源
- [ ] light_mask 设置正确

### 踩坑 3: 性能下降严重

**问题**: 添加光源后帧率大幅下降

**解决方案**:
1. 减少光源数量
2. 缩小光源的 texture_scale
3. 使用 Light Mask 限制光照范围
4. 考虑使用烘焙光照

---

## 🔗 相关链接

### 前置知识
- [2D 开发介绍](2d-development-intro.md) - 2D 节点基础
- [Sprite 动画指南](../guides/sprite-animation-guide.md) - 精灵使用

### 后续学习
- [2D 粒子系统指南](../guides/particles-2d-guide.md) - 配合光照创建特效
- [自定义 2D 绘制指南](../guides/custom-drawing-2d-guide.md) - 自定义光照效果

### Base 层来源
- [05E_2D_Lights_and_Shadows.md](../../base/2d-development/05E_2D_Lights_and_Shadows.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
