# Godot 4.x TileMap 瓦片地图

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/2d/using_tilemaps.rst

---

## 目录

1. [TileMap 概述](#1-tilemap-概述)
2. [TileSet 指定](#2-tileset-指定)
3. [多 TileMapLayer 和设置](#3-多-tilemaplayer-和设置)
4. [TileMap 编辑器](#4-tilemap-编辑器)
5. [代码操作 TileMap](#5-代码操作-tilemap)
6. [地形系统（Terrain System）](#6-地形系统terrain-system)

---

## 1. TileMap 概述

### 1.1 什么是 TileMap

TileMap 是用于创建游戏布局的瓦片网格。使用 TileMapLayer 节点设计关卡有几个好处：

1. 可以通过在网格上"绘制"瓦片来绘制布局，比逐个放置 Sprite2D 节点快得多
2. 针对绘制大量瓦片进行了优化，可以创建更大的关卡
3. 可以向瓦片添加碰撞、遮挡和导航形状，增加更多功能

### 1.2 TileMap vs TileMapLayer

- **TileMapLayer**：核心节点，继承自 Node2D
- **TileMap**：旧版本（Godot 3.x），Godot 4.x 推荐使用 TileMapLayer

---

## 2. TileSet 指定

### 2.1 外部 TileSet

将 TileSet 保存为外部资源，以便在多个关卡中重用：

1. 点击 TileSet 资源旁的下拉菜单
2. 选择"Save"

### 2.2 内置 TileSet

TileSet 可以内置于 TileMapLayer 节点，适合原型开发，但实际项目中推荐使用外部资源。

---

## 3. 多 TileMapLayer 和设置

### 3.1 使用多图层

使用多个 TileMapLayer 节点是推荐做法，例如：

- 背景层
- 前景层
- 装饰层

这样可以在同一位置的每个层放置一个瓦片，从而重叠多个瓦片。

### 3.2 TileMapLayer 属性

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

> **踩坑点**：TileMap 内置导航有许多实际限制，导致寻路性能和路径跟踪质量较低。设计 TileMap 后，考虑使用 NavigationRegion2D 或 NavigationServer2D 烘焙到更优化的导航网格（并禁用 TileMap NavigationLayer）。

> **踩坑点**：2D 导航网格不能像视觉或物理形状那样"分层"或堆叠。尝试在同一导航地图上堆叠导航网格会导致合并和逻辑错误，破坏寻路。

### 3.3 重新排序图层

可以通过在场景选项卡中拖放节点来重新排序图层。也可以通过 TileMap 编辑器右上角的按钮在正在处理的 TileMapLayer 节点之间切换。

> **踩坑点**：删除图层也会删除放置在该图层上的所有瓦片。

---

## 4. TileMap 编辑器

### 4.1 打开编辑器

选择 TileMapLayer 节点，然后打开编辑器底部的 TileMap 面板。

### 4.2 选择瓦片

在 TileMap 面板中选择瓦片：

- 点击选择单个瓦片
- 按住鼠标选择多个瓦片
- 按住 Shift 添加到当前选择

### 4.3 绘制模式和工具

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

## 5. 代码操作 TileMap

### 5.1 获取瓦片

```gdscript
@onready var tilemap = $TileMapLayer

func _ready():
    # 检查瓦片是否存在
    var tile_data = tilemap.get_cell_tile_data(0, Vector2i(5, 5))
    if tile_data:
        print("瓦片存在")
```

### 5.2 设置瓦片

```gdscript
func place_tile(x: int, y: int, source_id: int):
    tilemap.set_cell(0, Vector2i(x, y), 0, source_id, Vector2i(0, 0))
```

### 5.3 清除瓦片

```gdscript
func clear_tile(x: int, y: int):
    tilemap.set_cell(0, Vector2i(x, y), -1)
```

### 5.4 遍历所有瓦片

```gdscript
func list_all_tiles():
    for cell in tilemap.get_used_cells(0):
        var pos = cell
        var tile_data = tilemap.get_cell_tile_data(0, pos)
        if tile_data:
            print("瓦片位置：", pos)
```

---

## 6. 地形系统（Terrain System）

> 来源：Godot官方文档、GitHub社区文档、Godot新手村 | 整理日期：2026-04-03

### 6.1 地形系统概述

Godot 4.x 的地形系统（Terrain System）是 Godot 3.x Autotile 的升级版，用于自动处理瓦片之间的过渡和连接。通过定义地形规则，系统可以自动选择正确的边界瓦片，无需手动绘制每种连接情况。

**核心优势**：
- 自动处理瓦片过渡，节省大量手动绘制时间
- 支持多种地形之间的平滑过渡
- 适用于程序化生成的地图
- 比手动绘制更灵活、更易维护

### 6.2 地形匹配模式

Godot 提供三种地形匹配模式，每种模式适用于不同的场景：

#### 6.2.1 Match Sides（匹配边）

**适用场景**：
- 简单的边缘过渡（如草地到道路）
- 上下左右四方向连接
- 需要瓦片数量最少

**Peering Bits 数量**：4个（上、下、左、右）

**所需瓦片数量**：最多 16 种组合

**示例**：
```
草地瓦片：
- Center Bit: 0（草地）
- Peering Bits: 上=0, 下=0, 左=0, 右=0（全部连接草地）

草地-道路边界：
- Center Bit: 0（草地）
- Peering Bits: 上=0, 下=0, 左=0, 右=1（右侧连接道路）
```

#### 6.2.2 Match Corners（匹配角）

**适用场景**：
- 45度角纹理
- 精确的角点过渡
- 斜向连接的地形

**Peering Bits 数量**：4个（左上、右上、左下、右下）

**所需瓦片数量**：最多 16 种组合

**示例**：
```
对角线过渡：
- Center Bit: 0
- Peering Bits: 左上=0, 右上=1, 左下=0, 右下=1
```

#### 6.2.3 Match Corners and Sides（匹配角和边）

**适用场景**：
- 最复杂的地形过渡
- 需要同时处理边和角的连接
- 最灵活但需要最多瓦片

**Peering Bits 数量**：8个（上、下、左、右、左上、右上、左下、右下）

**所需瓦片数量**：最多 256 种组合

**示例**：
```
复杂地形过渡：
- Center Bit: 0
- Peering Bits: 上=0, 下=1, 左=0, 右=1, 左上=0, 右上=1, 左下=0, 右下=1
```

### 6.3 Peering Bits 详解

#### 6.3.1 什么是 Peering Bits

Peering Bits（连接位）是瓦片周围的小方块，用于定义瓦片如何与相邻瓦片连接：

- **Center Bit（中心位）**：瓦片所属的地形类型（如草地=0，道路=1）
- **Peering Bits（连接位）**：定义瓦片每个方向连接的地形类型

#### 6.3.2 在编辑器中设置 Peering Bits

**步骤**：

1. **打开 TileSet 编辑器**：
   - 双击 TileSet 资源文件（.tres）
   - 或选择 TileMapLayer 节点，在 Inspector 中点击 TileSet

2. **创建 Terrain Set**：
   - 在 TileSet 编辑器底部，点击"Terrain Sets"标签
   - 点击"Add New"创建新地形集
   - 选择匹配模式（Match Sides / Match Corners / Match Corners and Sides）

3. **创建 Terrain**：
   - 在 Terrain Set 下，点击"Add New"创建地形
   - 为每个地形命名（如"草地"、"道路"、"边界"）
   - 每个地形会自动分配一个 ID（0, 1, 2...）

4. **设置瓦片的 Terrain 属性**：
   - 切换到"Paint"标签
   - 选择要设置的瓦片
   - 在右侧"Terrain"部分：
     - **Terrain Set**：选择所属的地形集
     - **Terrain**：选择中心位的地形类型
     - **Peering Bits**：点击瓦片周围的小方块设置连接位

5. **Peering Bits 可视化**：
   - 瓦片周围会显示小方块（数量取决于匹配模式）
   - 点击方块设置该方向连接的地形 ID
   - -1 表示连接空空间（无瓦片）

#### 6.3.3 Peering Bits 设置示例

**草地瓦片（完全被草地包围）**：
```
Center Bit: 0（草地）
Peering Bits: 全部设为 0
```

**草地-道路边界（右侧是道路）**：
```
Center Bit: 0（草地）
Peering Bits: 右=1（道路），其他=0（草地）
```

**道路转角（左上是草地，其他是道路）**：
```
Center Bit: 1（道路）
Peering Bits: 左上=0（草地），其他=1（道路）
```

### 6.4 代码中使用地形系统

#### 6.4.1 设置单个瓦片的地形

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

#### 6.4.2 批量设置地形连接

```gdscript
func paint_terrain_area(cells: Array[Vector2i], terrain_set: int, terrain: int):
    tilemap.set_cells_terrain_connect(
        cells,           # 瓦片坐标数组
        terrain_set,     # 地形集索引
        terrain,         # 地形索引
        false            # 忽略空瓦片
    )
```

#### 6.4.3 填充矩形区域

```gdscript
func fill_terrain_rect(start: Vector2i, end: Vector2i, terrain_set: int, terrain: int):
    tilemap.set_cells_terrain_path(
        [start, end],    # 路径点数组
        terrain_set,     # 地形集索引
        terrain,         # 地形索引
        false            # 忽略空瓦片
    )
```

#### 6.4.4 完整示例：创建草地地图

```gdscript
func create_grass_map():
    var tilemap: TileMapLayer = $TileMapLayer
    
    var grass_cells: Array[Vector2i] = []
    for x in range(30):
        for y in range(30):
            grass_cells.append(Vector2i(x, y))
    
    tilemap.set_cells_terrain_connect(
        grass_cells,
        0,  # terrain_set（草地地形集）
        0,  # terrain（草地）
        false
    )
```

### 6.5 实际应用案例

#### 6.5.1 塔防游戏地图（草地+道路+边界）

**Terrain Set 配置**：
- 模式：Match Sides
- Terrain 0：草地
- Terrain 1：边界
- Terrain 2：道路

**代码实现**：

```gdscript
func create_tower_defense_map():
    var tilemap: TileMapLayer = $TileMapLayer
    
    var path_set: Dictionary = {}
    for point in path_points:
        path_set[point] = true
    
    var grass_cells: Array[Vector2i] = []
    var road_cells: Array[Vector2i] = []
    var edge_cells: Array[Vector2i] = []
    
    for x in range(map_width):
        for y in range(map_height):
            var coords = Vector2i(x, y)
            var is_edge = x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1
            
            if is_edge:
                edge_cells.append(coords)
            elif path_set.has(coords):
                road_cells.append(coords)
            else:
                grass_cells.append(coords)
    
    tilemap.set_cells_terrain_connect(grass_cells, 0, 0, false)
    tilemap.set_cells_terrain_connect(road_cells, 0, 2, false)
    tilemap.set_cells_terrain_connect(edge_cells, 0, 1, false)
```

#### 6.5.2 程序化生成地图

```gdscript
func generate_procedural_map():
    var tilemap: TileMapLayer = $TileMapLayer
    
    var noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    
    var cells_by_terrain: Dictionary = {
        0: [],  # 深水
        1: [],  # 浅水
        2: [],  # 沙滩
        3: [],  # 草地
        4: [],  # 山地
    }
    
    for x in range(100):
        for y in range(100):
            var coords = Vector2i(x, y)
            var noise_value = noise.get_noise_2d(x, y)
            var terrain_id: int
            
            if noise_value < -0.5:
                terrain_id = 0
            elif noise_value < -0.2:
                terrain_id = 1
            elif noise_value < 0.0:
                terrain_id = 2
            elif noise_value < 0.5:
                terrain_id = 3
            else:
                terrain_id = 4
            
            cells_by_terrain[terrain_id].append(coords)
    
    for terrain_id in cells_by_terrain.keys():
        tilemap.set_cells_terrain_connect(
            cells_by_terrain[terrain_id],
            0,
            terrain_id,
            false
        )
```

### 6.6 地形系统最佳实践

#### 6.6.1 选择合适的匹配模式

| 场景 | 推荐模式 | 原因 |
|------|---------|------|
| 简单边缘过渡（草地-道路） | Match Sides | 瓦片数量少，易于管理 |
| 45度角纹理 | Match Corners | 精确角点过渡 |
| 复杂地形混合 | Match Corners and Sides | 最灵活，支持所有连接情况 |

#### 6.6.2 瓦片素材准备

**Match Sides 模式所需瓦片**：
- 完全被同类地形包围（1张）
- 单边连接不同地形（4张）
- 双边连接（相邻或对角）（6张）
- 三边连接（4张）
- 四边连接不同地形（1张）
- **总计：最多 16 张**

**Match Corners and Sides 模式所需瓦片**：
- 理论最多 256 张，但实际通常只需要 47 张常用组合

#### 6.6.3 性能优化

1. **使用外部 TileSet 资源**：
   - 避免在每个场景中重复定义 TileSet
   - 便于统一管理和修改

2. **合理使用地形集数量**：
   - 每个 TileMapLayer 建议不超过 3-4 个地形集
   - 过多的地形集会影响性能

3. **批量操作**：
   - 使用 `set_cells_terrain_connect()` 批量设置
   - 避免逐个瓦片调用 `set_cell()`

### 6.7 常见问题与解决方案

#### 6.7.1 瓦片过渡不自然

**问题**：地形之间的过渡看起来生硬或不连续

**解决方案**：
1. 检查 Peering Bits 是否正确设置
2. 确保所有可能的连接情况都有对应的瓦片
3. 使用 Match Corners and Sides 模式获得更精细的控制

#### 6.7.2 地形自动选择错误

**问题**：系统选择了错误的瓦片

**解决方案**：
1. 检查瓦片的 Terrain Set 和 Terrain 属性是否正确
2. 确认 Peering Bits 设置与实际需求匹配
3. 使用 TileMap 编辑器的"Terrain"绘制模式手动测试

#### 6.7.3 瓦片缺失

**问题**：某些连接情况没有对应的瓦片

**解决方案**：
1. 在 TileSet 编辑器中检查所有瓦片的地形属性
2. 补充缺失的过渡瓦片
3. 使用概率（Probability）让多个瓦片共享相同的 Peering Bits 配置

### 6.8 替代方案：Better Terrain 插件

如果内置地形系统过于复杂，可以使用社区插件：

**Better Terrain**：
- GitHub: https://godotassetlibrary.com/asset/HiwFMr/better-terrain
- 更简单的规则系统
- 更灵活的 API
- 支持所有 Godot 3.x Autotile 功能

---

## 参考资料

本文档内容基于以下来源整理：
- Godot 官方文档：`godot-docs-master/tutorials/2d/using_tilemaps.rst`
- GitHub 社区文档：`dandeliondino/godot-4-tileset-terrains-docs`
- Godot 新手村：`https://godotvillage.github.io/tutorial/tilemap`
- Godot 官方 API 文档：`docs.godotengine.org/en/stable/classes/class_tileset.html`
