# TileMap 概念

> **来源**: [05G_TileMaps.md](../../base/2d-development/05G_TileMaps.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📋 概述

本文档介绍 Godot 4.x 的 TileMap 系统核心概念，包括 TileMapLayer 节点、TileSet 资源、地形系统和代码操作。

---

## 🗺️ TileMap 概述

### 什么是 TileMap

TileMap 是用于创建游戏布局的瓦片网格。使用 TileMapLayer 节点设计关卡有几个好处：

1. **快速绘制**: 可以通过在网格上"绘制"瓦片来绘制布局，比逐个放置 Sprite2D 节点快得多
2. **性能优化**: 针对绘制大量瓦片进行了优化，可以创建更大的关卡
3. **多功能**: 可以向瓦片添加碰撞、遮挡和导航形状，增加更多功能

### TileMap vs TileMapLayer

- **TileMapLayer**: 核心节点，继承自 Node2D（**Godot 4.x（4.6+）推荐**）
- **TileMap**: 旧版本（Godot 3.x），Godot 4.x 已弃用

> 💡 **Godot 4.x（4.6+）新特性**
> 
> **TileMapLayer 节点** 是 Godot 4.3 引入的新节点类型，相比旧的 TileMap 有以下改进：
> - **独立节点**: TileMapLayer 直接继承自 Node2D，无需嵌套在 TileMap 节点下
> - **简化层级**: 减少了节点层级，场景结构更清晰
> - **性能优化**: 更好的渲染性能和内存管理
> - **新 API**: `set_cell()`、`get_cell_tile_data()` 等方法更直观
> 
> **迁移指南**: 如果你使用的是 Godot 4.0-4.2，升级到 4.3+ 后需要将 TileMap 节点替换为 TileMapLayer。

---

## 📦 TileSet 指定

### 外部 TileSet

将 TileSet 保存为外部资源，以便在多个关卡中重用：

1. 点击 TileSet 资源旁的下拉菜单
2. 选择"Save"

### 内置 TileSet

TileSet 可以内置于 TileMapLayer 节点，适合原型开发，但实际项目中推荐使用外部资源。

---

## 📚 多 TileMapLayer 和设置

### 使用多图层

使用多个 TileMapLayer 节点是推荐做法，例如：

- **背景层**: 远处的景物
- **前景层**: 玩家交互的物体
- **装饰层**: 额外的视觉效果

这样可以在同一位置的每个层放置一个瓦片，从而重叠多个瓦片。

### TileMapLayer 属性

#### 基本属性

| 属性 | 说明 |
|------|------|
| Enabled | 启用后，图层在编辑器和运行时可见 |
| TileSet | 图层使用的 TileSet |

#### 渲染设置

| 属性 | 说明 |
|------|------|
| Y Sort Origin | Y 排序的垂直偏移（像素），仅在 CanvasItem 下 Y Sort Enabled 为 true 时有效 |
| X Draw Order Reversed | 反转 X 轴上瓦片的绘制顺序，需要 Y Sort Enabled 为 true |
| Rendering Quadrant Size | 渲染四边形大小，分组绘制优化 |

#### 物理设置

| 属性 | 说明 |
|------|------|
| Collision Enabled | 启用或禁用碰撞 |
| Use Kinematic Bodies | 为 true 时，TileMapLayer 碰撞形状实例化为运动学物体 |
| Collision Visibility Mode | 碰撞形状是否可见 |

#### 导航设置

| 属性 | 说明 |
|------|------|
| Navigation Enabled | 启用或禁用导航区域 |
| Navigation Visible | 导航网格是否可见 |

> ⚠️ **踩坑点**: TileMap 内置导航有许多实际限制，导致寻路性能和路径跟踪质量较低。设计 TileMap 后，考虑使用 NavigationRegion2D 或 NavigationServer2D 烘焙到更优化的导航网格（并禁用 TileMap NavigationLayer）。

> ⚠️ **踩坑点**: 2D 导航网格不能像视觉或物理形状那样"分层"或堆叠。尝试在同一导航地图上堆叠导航网格会导致合并和逻辑错误，破坏寻路。

### 重新排序图层

可以通过在场景选项卡中拖放节点来重新排序图层。也可以通过 TileMap 编辑器右上角的按钮在正在处理的 TileMapLayer 节点之间切换。

> ⚠️ **踩坑点**: 删除图层也会删除放置在该图层上的所有瓦片。

---

## 🎨 TileMap 编辑器

### 打开编辑器

选择 TileMapLayer 节点，然后打开编辑器底部的 TileMap 面板。

### 选择瓦片

在 TileMap 面板中选择瓦片：

- 点击选择单个瓦片
- 按住鼠标选择多个瓦片
- 按住 Shift 添加到当前选择

### 绘制模式和工具

从 TileMap 编辑器顶部的工具栏可以选择多种绘制模式和工具：

| 模式 | 说明 |
|------|------|
| Selection | 选择瓦片 |
| Paint | 绘制瓦片 |
| Line | 绘制直线 |
| Rectangle | 绘制矩形 |
| Fill | 填充区域 |
| Eraser | 擦除瓦片 |
| Picker | 拾取瓦片 |

---

## 💻 代码操作 TileMap

### 获取瓦片

```gdscript
@onready var tilemap = $TileMapLayer

func _ready():
    # 检查瓦片是否存在
    var tile_data = tilemap.get_cell_tile_data(0, Vector2i(5, 5))
    if tile_data:
        print("瓦片存在")
```

### 设置瓦片

```gdscript
func place_tile(x: int, y: int, source_id: int):
    tilemap.set_cell(0, Vector2i(x, y), 0, source_id, Vector2i(0, 0))
```

### 清除瓦片

```gdscript
func clear_tile(x: int, y: int):
    tilemap.set_cell(0, Vector2i(x, y), -1)
```

### 遍历所有瓦片

```gdscript
func list_all_tiles():
    for cell in tilemap.get_used_cells(0):
        var pos = cell
        var tile_data = tilemap.get_cell_tile_data(0, pos)
        if tile_data:
            print("瓦片位置：", pos)
```

---

## 🏔️ 地形系统（Terrain System）

### 地形系统概述

Godot 4.x 的地形系统（Terrain System）是 Godot 3.x Autotile 的升级版，用于自动处理瓦片之间的过渡和连接。通过定义地形规则，系统可以自动选择正确的边界瓦片，无需手动绘制每种连接情况。

**核心优势**:
- 自动处理瓦片过渡，节省大量手动绘制时间
- 支持多种地形之间的平滑过渡
- 适用于程序化生成的地图
- 比手动绘制更灵活、更易维护

### 地形匹配模式

Godot 提供三种地形匹配模式，每种模式适用于不同的场景：

#### Match Sides（匹配边）

**适用场景**:
- 简单的边缘过渡（如草地到道路）
- 上下左右四方向连接
- 需要瓦片数量最少

**Peering Bits 数量**: 4 个（上、下、左、右）

**所需瓦片数量**: 最多 16 种组合

#### Match Corners（匹配角）

**适用场景**:
- 45 度角纹理
- 精确的角点过渡
- 斜向连接的地形

**Peering Bits 数量**: 4 个（左上、右上、左下、右下）

**所需瓦片数量**: 最多 16 种组合

#### Match Corners and Sides（匹配角和边）

**适用场景**:
- 最复杂的地形过渡
- 需要同时处理边和角的连接
- 最灵活但需要最多瓦片

**Peering Bits 数量**: 8 个（上、下、左、右、左上、右上、左下、右下）

**所需瓦片数量**: 最多 256 种组合

### Peering Bits 详解

#### 什么是 Peering Bits

Peering Bits（连接位）是瓦片周围的小方块，用于定义瓦片如何与相邻瓦片连接：

- **Center Bit（中心位）**: 瓦片所属的地形类型（如草地=0，道路=1）
- **Peering Bits（连接位）**: 定义瓦片每个方向连接的地形类型

#### Peering Bits 设置示例

**草地瓦片（完全被草地包围）**:
```
Center Bit: 0（草地）
Peering Bits: 全部设为 0
```

**草地 - 道路边界（右侧是道路）**:
```
Center Bit: 0（草地）
Peering Bits: 右=1（道路），其他=0（草地）
```

**道路转角（左上是草地，其他是道路）**:
```
Center Bit: 1（道路）
Peering Bits: 左上=0（草地），其他=1（道路）
```

### 代码中使用地形系统

#### 设置单个瓦片的地形

```gdscript
@onready var tilemap: TileMapLayer = $TileMapLayer

func set_tile_with_terrain(coords: Vector2i, terrain_set: int, terrain: int):
    tilemap.set_cell(
        coords,           # 瓦片坐标
        0,                # source_id
        Vector2i(0, 0),   # atlas_coords（会自动选择）
        terrain_set,      # terrain_set
        terrain           # terrain
    )
```

#### 批量设置地形连接

```gdscript
func paint_terrain_area(cells: Array[Vector2i], terrain_set: int, terrain: int):
    tilemap.set_cells_terrain_connect(
        cells,           # 瓦片坐标数组
        terrain_set,     # 地形集索引
        terrain,         # 地形索引
        false            # 忽略空瓦片
    )
```

#### 填充矩形区域

```gdscript
func fill_terrain_rect(start: Vector2i, end: Vector2i, terrain_set: int, terrain: int):
    tilemap.set_cells_terrain_path(
        [start, end],    # 路径点数组
        terrain_set,     # 地形集索引
        terrain,         # 地形索引
        false            # 忽略空瓦片
    )
```

---

## ⚠️ 常见踩坑

### 踩坑 1: 导航系统限制

**问题**: TileMap 内置导航性能较差

**解决方案**:
- 使用 NavigationRegion2D 替代
- 或使用 NavigationServer2D 烘焙导航网格
- 禁用 TileMap 的 NavigationLayer

### 踩坑 2: 导航网格堆叠

**问题**: 在同一位置堆叠多个导航网格导致寻路错误

**解决方案**:
- 避免在同一区域堆叠导航网格
- 使用不同的导航层（navigation layers）
- 使用 visibility_layer 和 canvas_cull_mask 分离

### 踩坑 3: 删除图层丢失瓦片

**问题**: 删除 TileMapLayer 节点会丢失所有瓦片数据

**解决方案**:
- 删除前备份瓦片数据
- 使用多个图层而不是删除
- 使用 enabled 属性隐藏而非删除

---

## 🔗 相关链接

### 前置知识
- [2D 开发介绍](2d-development-intro.md) - Node2D 基础
- [2D 变换概念](2d-transforms.md) - 坐标系统

### 后续学习
- [自定义 2D 绘制指南](../guides/custom-drawing-2d-guide.md) - 在 TileMap 上绘制
- [视差滚动指南](../guides/parallax-guide.md) - 多层背景配合

### Base 层来源
- [05G_TileMaps.md](../../base/2d-development/05G_TileMaps.md) - 完整文档

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
