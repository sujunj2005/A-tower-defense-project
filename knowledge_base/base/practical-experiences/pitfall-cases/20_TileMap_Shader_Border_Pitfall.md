# TileMap 网格边框 Shader 开发踩坑记录

**最后更新**: 2026-04-03  
**适用版本**: Godot 4.x  
**重要性**: ⭐⭐⭐⭐⭐  
**相关文档**: [TileMaps.md](../05_2D_Development/05G_TileMaps.md), [GDScript_Code_Standards.md](../20_Best_Practices/GDScript_Code_Standards.md)

---

## 📋 问题描述

为 TileMapLayer 添加网格边框效果，要求：
1. 边框精确对齐每个瓦片（96x96 像素）
2. 边框跟随地图移动和缩放
3. 使用 Shader 实现，不依赖额外节点

---

## 🔍 开发过程与踩坑记录

### 第一阶段：使用 FRAGCOORD（屏幕坐标）❌

**实现方式**:
```glsl
shader_type canvas_item;
uniform vec2 tile_size = vec2(96.0, 96.0);

void fragment() {
    vec2 world_pos = FRAGCOORD.xy;
    vec2 tile_local = mod(world_pos, tile_size);
    // ... 绘制边框
}
```

**问题**: 边框焊在摄像机上，不跟随地图移动

**原因分析**:
- `FRAGCOORD.xy` 是**屏幕空间坐标**
- 当相机移动时，屏幕坐标不变，导致边框固定在屏幕上

**解决方案**: 改用 UV 坐标

---

### 第二阶段：使用 UV 坐标（未考虑缩放）❌

**实现方式**:
```glsl
void fragment() {
    vec2 uv = UV;
    vec2 world_pos = uv * textureSize(TEXTURE, 0);
    vec2 tile_local = mod(world_pos, tile_size);
    // ... 绘制边框
}
```

**问题**: 
1. 编译错误：`Invalid arguments to operator '*': 'vec2, ivec2'`
2. 边框仍然不对齐瓦片

**原因分析**:
1. `textureSize()` 返回 `ivec2`，需要转换为 `vec2`
2. UV 坐标是 0-1 归一化坐标，覆盖整个 TileMapLayer
3. **TileMapLayer 被缩放了 2 倍**（48→96），但计算未考虑缩放

**解决方案**: 
```glsl
vec2 texture_dim = vec2(textureSize(TEXTURE, 0));
vec2 world_pos = uv * texture_dim;
```

---

### 第三阶段：考虑缩放因子❌

**实现方式**:
```glsl
uniform float scale_factor = 2.0;
void fragment() {
    vec2 original_uv = UV / scale_factor;
    vec2 grid_pos = original_uv * map_size;
    vec2 tile_uv = mod(grid_pos, 1.0);
    vec2 pixel_pos = tile_uv * tile_size;
    // ... 绘制边框
}
```

**问题**: 边框仍然没有对齐瓦片

**原因分析**:
- UV 坐标的计算逻辑过于复杂
- `UV / scale_factor` 的假设不正确
- UV 坐标在缩放后的节点上的行为与预期不同

---

### 第四阶段：使用世界空间坐标 ✅

**实现方式**:
```glsl
shader_type canvas_item;
uniform vec2 tile_size = vec2(96.0, 96.0);
varying vec2 v_world_pos;

void vertex() {
    // 传递顶点的世界坐标（考虑了节点的位置和缩放）
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // v_world_pos 是世界空间坐标（像素）
    vec2 tile_local = mod(v_world_pos, tile_size);
    
    float dist_to_left = tile_local.x;
    float dist_to_right = tile_size.x - tile_local.x;
    float dist_to_top = tile_local.y;
    float dist_to_bottom = tile_size.y - tile_local.y;
    
    bool is_grid_line = (dist_to_left < grid_width) || 
                       (dist_to_right < grid_width) ||
                       (dist_to_top < grid_width) || 
                       (dist_to_bottom < grid_width);
    
    if (is_grid_line) {
        COLOR = grid_color;
    } else {
        COLOR = texture(TEXTURE, UV);
    }
}
```

**成功!** ✅

**关键原理**:
1. `MODEL_MATRIX` 包含节点的**位置和缩放信息**
2. `VERTEX` 是顶点的**局部坐标**
3. `MODEL_MATRIX * VERTEX` = 顶点的**世界空间坐标**
4. `mod(世界坐标，tile_size)` = 在瓦片内的局部位置
5. **自动考虑缩放**：MODEL_MATRIX 已经包含了 scale

---

## 🎯 核心知识点

### 1. Godot Shader 坐标系统

| 坐标类型 | 变量名 | 单位 | 特点 |
|---------|--------|------|------|
| **屏幕坐标** | `FRAGCOORD.xy` | 像素 | 相对于屏幕左上角，不随节点移动 |
| **UV 坐标** | `UV` | 归一化 (0-1) | 相对于纹理或节点边界 |
| **世界坐标** | `MODEL_MATRIX * VERTEX` | 像素 | 相对于游戏世界原点，随节点移动和缩放 |

### 2. MODEL_MATRIX 的作用

```glsl
// vertex() 函数中
v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
```

- `MODEL_MATRIX` = 节点的变换矩阵（包含 position, rotation, scale）
- `VERTEX` = 顶点的局部坐标
- **结果** = 顶点在世界空间中的实际位置（像素）

### 3. TileMapLayer 的缩放行为

当 TileMapLayer.scale = (2.0, 2.0) 时：
- **顶点坐标**：被放大 2 倍
- **UV 坐标**：仍然覆盖 0-1，但覆盖的是缩放后的节点边界
- **纹理采样**：`texture(TEXTURE, UV)` 会自动适配缩放

### 4. 网格计算通用公式

```glsl
// 世界坐标 → 瓦片内局部坐标
vec2 tile_local = mod(world_pos, tile_size);

// 检查边框
bool is_grid_line = (tile_local.x < grid_width) || 
                   (tile_local.x > tile_size.x - grid_width) ||
                   (tile_local.y < grid_width) || 
                   (tile_local.y > tile_size.y - grid_width);
```

---

## 🛠️ 完整实现代码

### Shader (grid_overlay.gdshader)

```glsl
shader_type canvas_item;

// 网格边框自定义设置 
uniform vec4 grid_color: source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float grid_width: hint_range(0.0, 10.0) = 2.0;
uniform vec2 tile_size = vec2(96.0, 96.0);

// 从顶点函数传递世界坐标到片段函数
varying vec2 v_world_pos;

void vertex() {
    // 传递顶点的世界坐标（考虑了节点的位置和缩放）
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // v_world_pos 是世界空间坐标（像素）
    // 计算在瓦片内的局部坐标
    vec2 tile_local = mod(v_world_pos, tile_size);
    
    // 检查是否在边框线上
    float dist_to_left = tile_local.x;
    float dist_to_right = tile_size.x - tile_local.x;
    float dist_to_top = tile_local.y;
    float dist_to_bottom = tile_size.y - tile_local.y;
    
    bool is_grid_line = (dist_to_left < grid_width) || 
                       (dist_to_right < grid_width) ||
                       (dist_to_top < grid_width) || 
                       (dist_to_bottom < grid_width);
    
    if (is_grid_line) {
        COLOR = grid_color;
    } else {
        COLOR = texture(TEXTURE, UV);
    }
}
```

### GDScript (map_manager.gd)

```gdscript
func apply_grid_shader():
    var shader_mat = ShaderMaterial.new()
    shader_mat.shader = preload("res://shaders/grid_overlay.gdshader")
    ground_layer.material = shader_mat
    shader_mat.set_shader_parameter("tile_size", Vector2(map_config.tile_size, map_config.tile_size))
    shader_mat.set_shader_parameter("grid_color", Color(1.0, 1.0, 1.0, 0.5))
    shader_mat.set_shader_parameter("grid_width", 2.0)
    print("[GridShader] Applied to TileMapLayer with tile_size=", map_config.tile_size)
```

---

## 📊 测试验证

### 测试场景 1: 静态观察
- ✅ 边框精确对齐 96x96 瓦片
- ✅ 边框宽度 2 像素，颜色白色半透明

### 测试场景 2: 移动相机
- ✅ 边框跟随地图一起移动
- ✅ 边框位置始终对齐瓦片边缘

### 测试场景 3: 缩放地图
- ✅ 边框随地图缩放而变化
- ✅ 缩放后仍然精确对齐

---

## 💡 最佳实践总结

### 1. Shader 坐标选择优先级

| 需求 | 推荐坐标 | 原因 |
|------|---------|------|
| 跟随节点移动 | **世界坐标** | `MODEL_MATRIX * VERTEX` |
| 固定在屏幕 | **FRAGCOORD** | 屏幕空间坐标 |
| 纹理采样 | **UV** | 自动适配纹理 |
| 后处理效果 | **FRAGCOORD / SCREEN_UV** | 全屏效果 |

### 2. TileMapLayer Shader 开发要点

1. **使用世界坐标**：`MODEL_MATRIX * VERTEX` 计算网格位置
2. **避免复杂 UV 计算**：UV 在缩放节点上的行为复杂
3. **varying 传递数据**：从 vertex() 传递计算结果到 fragment()
4. **mod 运算**：计算周期性图案（如网格）的核心工具

### 3. 调试技巧

1. **可视化中间变量**：
   ```glsl
   COLOR = vec4(v_world_pos / 1000.0, 0.0, 1.0); // 查看世界坐标
   ```

2. **逐步验证**：
   - 先验证 vertex() 传递的坐标是否正确
   - 再验证 mod 运算结果
   - 最后验证边框绘制逻辑

3. **使用 Godot MCP 调试**：
   - 运行场景后立即检查错误
   - 修改 shader 后重新运行验证

---

## 🔗 相关资源

### 本项目知识库
- [TileMaps.md](../05_2D_Development/05G_TileMaps.md) - TileMap 系统完整文档
- [GDScript_Code_Standards.md](../20_Best_Practices/GDScript_Code_Standards.md) - GDScript 代码规范

### Godot 官方文档
- [CanvasItem Shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvasitem_shader.html)
- [MODEL_MATRIX](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shader_builtins.html)
- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)

---

## 📝 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-04-03 | 1.0 | 初始创建文档，记录完整开发过程 |

---

*文档版本：1.0 | 最后更新：2026-04-03*
