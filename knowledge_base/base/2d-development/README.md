# Godot 4.x 2D 开发文档索引

> **适用版本**: Godot 4.x  
> **来源**: Godot 官方文档 (godot-docs-master/tutorials/2d/)  
> **整理日期**: 2026-04-07  
> **文档数量**: 9 份

---

## 📚 文档列表

### 入门与基础

| 文档 | 描述 | 来源文件 | 重要性 |
|------|------|---------|--------|
| [05A_Introduction_to_2D.md](05A_Introduction_to_2D.md) | **2D 开发介绍** - 2D 工作区、坐标系、工具栏、Node2D vs Control | `introduction_to_2d.rst` | 🔴 必读 |
| [05B_2D_Movement.md](05B_2D_Movement.md) | **2D 移动模式** - 8 方向移动、旋转 + 移动、点击移动 | `2d_movement.rst` | 🔴 必读 |
| [05C_2D_Transforms.md](05C_2D_Transforms.md) | **2D 变换** - 坐标系统、Canvas 变换、视口变换、变换函数 | `2d_transforms.rst` | 🔴 必读 |

### 视觉效果

| 文档 | 描述 | 来源文件 | 重要性 |
|------|------|---------|--------|
| [05D_Sprite_Animation.md](05D_Sprite_Animation.md) | **Sprite 动画** - AnimatedSprite2D、AnimationPlayer、代码控制动画 | `2d_sprite_animation.rst` | 🔴 必读 |
| [05E_2D_Lights_and_Shadows.md](05E_2D_Lights_and_Shadows.md) | **2D 光照与阴影** - PointLight2D、DirectionalLight2D、LightOccluder2D | `2d_lights_and_shadows.rst` | 🟡 推荐 |
| [05F_Particle_Systems_2D.md](05F_Particle_Systems_2D.md) | **2D 粒子系统** - GPUParticles2D、CPUParticles2D、ParticleProcessMaterial | `particle_systems_2d.rst` | 🟡 推荐 |

### 场景与地图

| 文档 | 描述 | 来源文件 | 重要性 |
|------|------|---------|--------|
| [05G_TileMaps.md](05G_TileMaps.md) | **TileMap 瓦片地图** - TileMapLayer、TileSet、地形系统、代码操作 | `using_tilemaps.rst` | 🔴 必读 |
| [05H_Parallax.md](05H_Parallax.md) | **视差滚动** - Parallax2D、scroll_scale、repeat_size、无限重复效果 | `2d_parallax.rst` | 🟡 推荐 |

### 高级绘制

| 文档 | 描述 | 来源文件 | 重要性 |
|------|------|---------|--------|
| [05I_Custom_Drawing_2D.md](05I_Custom_Drawing_2D.md) | **自定义 2D 绘制** - _draw 函数、绘制命令、重绘机制、常见示例 | `custom_drawing_in_2d.rst` | 🟢 参考 |

---

## 🎯 学习路径

### 新手入门
```
1. [2D 开发介绍](05A_Introduction_to_2D.md) - 了解 2D 工作区和工具
   ↓
2. [2D 移动模式](05B_2D_Movement.md) - 掌握角色移动实现
   ↓
3. [2D 变换](05C_2D_Transforms.md) - 理解坐标系统
```

### 视觉效果进阶
```
1. [Sprite 动画](05D_Sprite_Animation.md) - 角色动画制作
   ↓
2. [2D 光照与阴影](05E_2D_Lights_and_Shadows.md) - 增强场景深度
   ↓
3. [2D 粒子系统](05F_Particle_Systems_2D.md) - 特效制作
```

### 场景构建
```
1. [TileMap 瓦片地图](05G_TileMaps.md) - 地图绘制
   ↓
2. [视差滚动](05H_Parallax.md) - 背景深度效果
   ↓
3. [自定义 2D 绘制](05I_Custom_Drawing_2D.md) - 特殊效果绘制
```

---

## 📊 核心概念速查

### 2D 工作区

- **坐标系**: 向右和向下为正方向，原点在 (0, 0)
- **Node2D**: 2D 游戏对象基类（Sprite2D、CharacterBody2D 等）
- **Control**: GUI 基类（Button、Label 等）
- **CanvasLayer**: 独立渲染层，用于 UI 和视差背景

### 移动模式

| 模式 | 输入方式 | 适用场景 |
|------|---------|---------|
| 8 方向 | WASD/方向键 | RPG、塔防、俯视角射击 |
| 旋转 + 键盘 | 左右旋转 + 前进 | 太空射击、赛车 |
| 旋转 + 鼠标 | 鼠标瞄准+WASD | 俯视角射击、塔防角色 |
| 点击移动 | 鼠标点击 | RTS、策略游戏 |

### 变换核心

```gdscript
# 获取世界坐标
var world_pos = $Sprite2D.global_position

# 局部坐标转世界坐标
var world_pos = get_global_transform() * local_pos

# 世界坐标转局部坐标
var local_pos = get_global_transform().affine_inverse() * world_pos
```

### 常用节点

| 节点类型 | 用途 | 示例 |
|---------|------|------|
| `CharacterBody2D` | 角色移动 | 玩家、敌人 |
| `AnimatedSprite2D` | 精灵动画 | 角色动画 |
| `PointLight2D` | 点光源 | 火把、火焰 |
| `GPUParticles2D` | GPU 粒子 | 火花、烟雾 |
| `TileMapLayer` | 瓦片地图 | 关卡设计 |
| `Parallax2D` | 视差背景 | 多层背景 |

---

## 🔗 Wiki 层映射

本目录的 9 份文档已整合到 Wiki 层：

### 概念页面 (concepts/)
- [2D 开发介绍](../../wiki/concepts/2d-development-intro.md) - 来自 05A
- [2D 变换概念](../../wiki/concepts/2d-transforms.md) - 来自 05C
- [2D 灯光和阴影概念](../../wiki/concepts/2d-lights-shadows.md) - 来自 05E
- [TileMap 概念](../../wiki/concepts/tilemaps-concept.md) - 来自 05G

### 指南页面 (guides/)
- [2D 移动指南](../../wiki/guides/2d-movement-guide.md) - 来自 05B
- [Sprite 动画指南](../../wiki/guides/sprite-animation-guide.md) - 来自 05D
- [2D 粒子系统指南](../../wiki/guides/particles-2d-guide.md) - 来自 05F
- [视差滚动指南](../../wiki/guides/parallax-guide.md) - 来自 05H
- [自定义 2D 绘制指南](../../wiki/guides/custom-drawing-2d-guide.md) - 来自 05I

---

## 📝 使用建议

1. **Base 层文档是原始信息源**，包含完整的 Godot 官方文档内容
2. **Wiki 层文档是摘要和整合**，更适合快速查阅和学习
3. 建议先阅读 Wiki 层文档了解概念，再查阅 Base 层文档获取详细信息
4. 所有 Wiki 页面都有 Base 层来源引用，可追溯原始信息

---

## 📈 统计信息

- **文档总数**: 9 份
- **来源**: Godot 官方文档 (godot-docs-master/tutorials/2d/)
- **总字数**: ~50,000+
- **Wiki 层映射**: 9 个页面（4 概念 + 5 指南）

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
