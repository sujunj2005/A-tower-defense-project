# 2D 游戏开发概述

> **适用版本**: Godot 4.x  
> **知识领域**: 2D 游戏开发  
> **前置知识**: GDScript 基础、向量数学

---

## 🎯 2D 游戏开发核心知识体系

### 1. 坐标系与变换

#### 1.1 坐标系统
- **笛卡尔坐标系**: X 轴向右，Y 轴向下（Godot 2D）
- **原点**: 默认为视口左上角 (0, 0)
- **单位**: 像素（默认），可通过变换缩放

#### 1.2 变换基础
- **Transform2D**: 包含 origin（位置）、x（右向量）、y（下向量）
- **常用变换**: 平移、旋转、缩放
- **变换组合**: 使用 `transform * other_transform` 组合变换

**参考**:
- [2D 变换概念](../concepts/2d-transforms.md)
- [向量数学](../concepts/vector-math.md)

---

### 2. 2D 节点体系

#### 2.1 核心节点
| 节点类型 | 用途 | 物理支持 |
|---------|------|---------|
| `Node2D` | 基础 2D 节点 | ❌ |
| `Sprite2D` | 显示 2D 图像 | ❌ |
| `AnimatedSprite2D` | 帧动画精灵 | ❌ |
| `CharacterBody2D` | 角色控制（手动移动） | ✅ |
| `RigidBody2D` | 刚体物理（自动模拟） | ✅ |
| `Area2D` | 区域检测、信号触发 | ✅ |
| `StaticBody2D` | 静态碰撞体 | ✅ |
| `TileMapLayer` | 瓦片地图（Godot 4.x（4.6+）） | ✅ |
| `Parallax2D` | 视差背景（Godot 4.x（4.6+）） | ❌ |
| `Light2D` | 2D 点光源 | ❌ |
| `PointLight2D` | 点光源 | ❌ |
| `DirectionalLight2D` | 平行光 | ❌ |

**参考**:
- [2D 开发介绍](../concepts/2d-development-intro.md)

---

### 3. 2D 移动控制

#### 3.1 常见移动模式
| 模式 | 实现方式 | 适用场景 |
|------|---------|---------|
| **8 方向移动** | `Vector2` 输入 + `move_and_slide()` | 平台跳跃、俯视角 |
| **旋转 + 移动** | `look_at()` + 前向向量 | 飞行射击、太空游戏 |
| **点击移动** | `get_global_mouse_position()` + 插值 | RPG、策略游戏 |
| **物理移动** | `apply_central_impulse()` | 物理驱动角色 |

**参考**:
- [2D 移动指南](../guides/2d-movement-guide.md)

---

### 4. 2D 动画系统

#### 4.1 动画制作方式
| 方式 | 节点 | 优点 | 缺点 |
|------|------|------|------|
| **帧动画** | `AnimatedSprite2D` | 简单易用、美术友好 | 灵活性较低 |
| **属性动画** | `AnimationPlayer` | 灵活、可动画任意属性 | 学习曲线较陡 |
| **混合动画** | `AnimationTree` | 状态机、平滑过渡 | 配置复杂 |
| **骨骼动画** | `Skeleton2D` | 高效、可动态调整 | 需要骨骼绑定 |

**参考**:
- [Sprite 动画指南](../guides/sprite-animation-guide.md)
- [2D 骨骼](../../base/animation-system/11C_2D_Skeletons.md)

---

### 5. 2D 物理系统

#### 5.1 碰撞对象选择
```
┌─────────────────────────────────────────┐
│  需要角色控制？                          │
│    ├─ 是 → CharacterBody2D              │
│    └─ 否 → 需要物理模拟？                │
│         ├─ 是 → RigidBody2D             │
│         └─ 否 → 需要检测？               │
│              ├─ 是 → Area2D             │
│              └─ 是 → StaticBody2D       │
└─────────────────────────────────────────┘
```

#### 5.2 碰撞层与掩码
- **32 个碰撞层**: 位运算配置（0-31）
- **Layer**: 自身所在层
- **Mask**: 能检测到哪些层

**示例**:
```gdscript
# 玩家：层 1，检测层 2（敌人）和层 3（地形）
collision_layer = 0b001
collision_mask = 0b110

# 敌人：层 2，检测层 1（玩家）和层 3（地形）
collision_layer = 0b010
collision_mask = 0b101
```

**参考**:
- [物理系统介绍](../concepts/physics-intro.md)
- [CharacterBody2D 概念](../concepts/characterbody2d-concept.md)
- [射线投射指南](../guides/raycasting-guide.md)

---

### 6. 2D 视觉效果

#### 6.1 光照与阴影
- **光源类型**:
  - `PointLight2D`: 点光源（圆形/矩形）
  - `DirectionalLight2D`: 平行光（全局光照）
- **阴影**: `LightOccluder2D` + `OccluderPolygon2D`
- **光照遮罩**: `LightOccluder2D` 定义遮挡区域

**参考**:
- [2D 灯光和阴影概念](../concepts/2d-lights-shadows.md)

#### 6.2 粒子系统
| 粒子类型 | 适用场景 | 性能 |
|---------|---------|------|
| `GPUParticles2D` | 大量粒子（1000+） | ⭐⭐⭐⭐⭐ |
| `CPUParticles2D` | 少量粒子、需要代码控制 | ⭐⭐⭐ |

**参考**:
- [2D 粒子系统指南](../guides/particles-2d-guide.md)

#### 6.3 视差滚动
- **Parallax2D** (Godot 4.x（4.6+）): 简化视差背景
- **scroll_scale**: 视差因子（1=同步，0.5=半速）
- **repeat_size**: 无限重复尺寸

**参考**:
- [视差滚动指南](../guides/parallax-guide.md)

#### 6.4 自定义绘制
- **`_draw()` 函数**: 自定义 2D 绘制
- **常用命令**:
  - `draw_line()`: 绘制线段
  - `draw_circle()`: 绘制圆形
  - `draw_rect()`: 绘制矩形
  - `draw_texture()`: 绘制纹理
- **重绘**: `queue_redraw()` 触发重绘

**参考**:
- [自定义 2D 绘制指南](../guides/custom-drawing-2d-guide.md)

---

### 7. TileMap 瓦片地图

#### 7.1 TileMap 核心概念
- **TileMapLayer**: Godot 4.x（4.6+）新节点（替代 TileMap）
- **TileSet**: 瓦片资源集合
- **地形系统**: 自动铺路、水域连接
- **碰撞层**: 每层可独立配置碰撞

#### 7.2 代码操作
```gdscript
# 设置瓦片
tile_map.set_cell(layer, coordinate, source_id, alternative_tile)

# 获取瓦片
var tile = tile_map.get_cell_tile_data(layer, coordinate)

# 清除瓦片
tile_map.erase_cell(layer, coordinate)
```

**参考**:
- [TileMap 概念](../concepts/tilemaps-concept.md)

---

### 8. UI 系统

#### 8.1 Control 节点
| 节点 | 用途 |
|------|------|
| `Label` | 文本显示 |
| `Button` | 按钮 |
| `VBoxContainer`/`HBoxContainer` | 垂直/水平布局 |
| `GridContainer` | 网格布局 |
| `MarginContainer` | 边距控制 |
| `CenterContainer` | 居中对齐 |
| `TextureRect` | 纹理显示 |
| `ProgressBar` | 进度条 |
| `LineEdit` | 单行输入框 |
| `TextEdit` | 多行文本框 |

#### 8.2 锚点与尺寸
- **锚点**: 相对于父节点的相对位置（0-1）
- **偏移**: 相对于锚点的像素偏移
- **预设**: 快速设置锚点（Full Rect、Center 等）

**参考**:
- [UI 容器概念](../concepts/ui-containers.md)
- [UI 尺寸和锚点概念](../concepts/ui-size-anchors.md)

---

### 9. 2D 着色器

#### 9.1 Canvas Item 着色器
```glsl
shader_type canvas_item;

uniform vec4 color : source_color;
uniform float time;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = tex_color * color;
}
```

#### 9.2 常见效果
- **渐变**: 使用 UV 坐标插值颜色
- **波浪**: `sin()` 函数偏移 UV
- **轮廓**: 距离场或边缘检测
- **像素化**: `floor(UV * scale) / scale`

**参考**:
- [Canvas Item 着色器指南](../guides/canvas-item-shader-guide.md)

---

### 10. 性能优化

#### 10.1 渲染优化
| 优化方向 | 具体措施 |
|---------|---------|
| **合批** | 减少材质切换、使用纹理集 |
| **剔除** | 视口外节点自动剔除 |
| **LOD** | 远距离使用低精度模型 |
| **粒子** | 优先使用 GPUParticles2D |

#### 10.2 物理优化
| 优化方向 | 具体措施 |
|---------|---------|
| **碰撞层** | 合理配置，减少不必要检测 |
| **Area2D** | 使用 `monitorable` 禁用监控 |
| **刚体** | 睡眠阈值、连续碰撞检测 |

**参考**:
- [性能优化实战指南](../guides/performance-optimization-guide.md)

---

## 📚 推荐学习路径

### 入门阶段
```
1. [2D 开发介绍](../concepts/2d-development-intro.md)
   ↓
2. [2D 移动指南](../guides/2d-movement-guide.md)
   ↓
3. [Sprite 动画指南](../guides/sprite-animation-guide.md)
   ↓
4. [物理系统介绍](../concepts/physics-intro.md)
```

### 进阶阶段
```
1. [TileMap 概念](../concepts/tilemaps-concept.md)
   ↓
2. [2D 灯光和阴影概念](../concepts/2d-lights-shadows.md)
   ↓
3. [Canvas Item 着色器指南](../guides/canvas-item-shader-guide.md)
   ↓
4. [性能优化实战指南](../guides/performance-optimization-guide.md)
```

### 高级阶段
```
1. [自定义 2D 绘制指南](../guides/custom-drawing-2d-guide.md)
   ↓
2. [2D 骨骼](../../base/animation-system/11C_2D_Skeletons.md)
   ↓
3. [剪裁动画](../../base/animation-system/11D_Cutout_Animation.md)
```

---

## 🔗 相关资源

### Base 层来源
- [2D 开发](../../base/2d-development/) - 9 份完整文档
- [物理系统](../../base/physics-system/) - 5 份物理文档
- [UI 系统](../../base/ui-system/) - 3 份 UI 文档
- [输入系统](../../base/input-system/) - 2 份输入文档

### Wiki 层相关
- [2D 变换概念](../concepts/2d-transforms.md)
- [向量数学](../concepts/vector-math.md)
- [常见踩坑避雷](../guides/common-pitfalls.md)

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
