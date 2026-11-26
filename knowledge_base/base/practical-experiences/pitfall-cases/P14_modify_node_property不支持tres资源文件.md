# P14：modify_node_property 不支持 .tres 资源文件

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | Godot MCP / 工具 |
| **严重程度** | 🟡 中 |
| **涉及文件** | Godot MCP 工具 / `.tres` 资源文件（如 `map_xxx.tres` 地图配置） |
| **知识库关联** | [§23 .tres 文件注释导致加载失败](../../../wiki/guides/common-pitfalls.md#23-tres-文件中的注释导致字段加载失败) / [§37 ext_resource 引用已删文件](../../../wiki/guides/common-pitfalls.md#37-tres-文件-ext_resource-引用已删除文件导致整体加载失败--高) |

---

## 现象

使用 Godot MCP 的 `modify_node_property` 工具修改 `.tres` 资源文件（如 `map_01.tres` 地图配置）时，返回错误：

```
Failed to load scene: res://resources/maps/map_01.tres
```

错误信息提示该文件无法作为场景加载。

## 根因

`modify_node_property` 的设计目标是操作 `.tscn` 场景文件中的节点属性，其内部工作流程是：

1. 将目标文件作为 `PackedScene` 加载
2. 实例化场景获取节点树
3. 按路径定位目标节点
4. 修改节点属性
5. 将修改后的场景树序列化写回

`.tres` 文件是 `Resource` 格式，不是 `PackedScene` 格式。它没有一个可遍历的节点树，因此 `modify_node_property` 在第一步加载时就失败了。

**Godot MCP 工具适用边界**：
| 工具 | 适用文件格式 | 不适用 |
|------|------------|--------|
| `add_node` | `.tscn` | `.tres`, `.gd` |
| `modify_node_property` | `.tscn` | `.tres`, `.gd` |
| `set_collision_shape` | `.tscn` | `.tres`, `.gd` |
| `remove_node` | `.tscn` | `.tres`, `.gd` |
| `edit_script` | `.gd` | `.tscn`, `.tres` |

## 正确做法

对 `.tres` 资源文件的修改，使用文件读写工具直接编辑其文本内容：

```
# 正确流程
1. Read 读取 .tres 文件的完整内容
2. SearchReplace 定位目标行并替换属性值
3. 注意 .tres 文件的 [ext_resource] 引用完整性
```

示例操作（修改 `map_01.tres` 中的 `difficulty_multiplier`）：

```gdscript
# ❌ 错误：用 modify_node_property 修改 .tres
mcp.invoke("modify_node_property", {
    "scene_path": "res://resources/maps/map_01.tres",  # 不支持！
    "node_path": ".",
    "property": "difficulty_multiplier",
    "value": 1.5
})

# ✅ 正确：用文件工具直接编辑 .tres 文本
# Read 文件 → SearchReplace → 写入
# 原始行：difficulty_multiplier = 1.0
# 替换行：difficulty_multiplier = 1.5
```

## 教训

**Godot MCP 工具按文件类型有明确的适用边界**：

- **场景类工具**（`add_node` / `modify_node_property` / `set_collision_shape` / `remove_node`）：仅适用于 `.tscn` 场景文件，因为依赖 PackedScene 的节点树结构
- **脚本类工具**（`edit_script`）：适用于 `.gd` 脚本文件
- **资源类文件**（`.tres` / `.json` / `.cfg`）：需要使用通用的文件读写工具（`Read` + `SearchReplace`）

在调用 Godot MCP 工具前，先确认目标文件的类型和格式，选对工具。

---

*记录时间：2026-04-30*
