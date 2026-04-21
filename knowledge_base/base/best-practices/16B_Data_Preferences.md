# 数据结构与算法偏好

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/best_practices/data_preferences.rst

---

## 一、时间复杂度简介

本文涉及"[某]时间复杂度"操作，来自算法分析的**大O表示法（Big O Notation）**：

| 复杂度 | 符号 | 含义 | 示例 |
|--------|------|------|------|
| **常数时间** | O(1) | 数据量增加，运行时间不变 | 数组索引访问 |
| **对数时间** | O(log n) | 缓慢增长 | 二分查找 |
| **线性时间** | O(n) | 同步增长 | 遍历数组 |
| **线性对数** | O(n log n) | 排序算法 | 快速排序 |
| **平方时间** | O(n²) | 快速增长 | 双重循环 |

> **关键思考**：如果在单帧内处理300万个数据点，线性算法不可能完成；而常数时间算法可以轻松处理。

---

## 二、Array vs Dictionary vs Object

Godot 在脚本 API 中将所有变量存储在 **Variant** 类中。Variant 可以存储：
- Array（数组）
- Dictionary（字典）
- Object（对象）
- 基本类型（int, float, String等）

---

## 三、Array（数组）详解

### 3.1 内部实现

Godot 的 Array 是 **`Vector<Variant>`**（连续内存存储）。

### 3.2 操作性能分析

#### 迭代（Iterate）⚡⚡⚡ 最快

```gdscene
for item in array:
    process(item)
# 仅递增计数器获取下一条记录
```

#### 插入/删除/移动（Insert/Erase/Move）🐢 位置相关，一般较慢

**原因**：添加/删除/移动内容需要移动相邻记录（腾出空间/填补空缺）。

| 操作位置 | 性能 |
|----------|------|
| **末尾** | ⚡⚡ 快速 |
| **任意位置** | 🐢 较慢 |
| **开头** | 🐢🐢 最慢 |

> **大量从开头插入/删除的优化技巧**：
>
> 1. 反转数组
> 2. 循环在末尾执行操作
> 3. 再次反转
>
> 这样只需复制2次数组（仍是常数时间），而不是平均 N 次复制约一半数组（线性时间）。

#### 获取/设置（Get/Set）⚡⚡ 按位置最快

```gdscene
var item = array[0]     # O(1)
array[10] = new_value   # O(1)
# 但不能按值查找
```

#### 查找（Find）🐢🐢 最慢

必须遍历整个数组并比较值直到找到匹配：

```gdscene
var index = array.find(value)  # O(n)
```

性能还取决于是否需要穷举搜索（找到第一个还是所有匹配）。

### 3.3 PackedArray（类型化数组）

对于已知类型的同质数据，使用 **PackedArray**：

| 类型 | 说明 |
|------|------|
| `PackedByteArray` | 字节数组 |
| `PackedInt32Array` | 32位整数数组 |
| `PackedFloat32Array` | 32位浮点数数组 |
| `PackedStringArray` | 字符串数组 |
| `PackedVector2Array` | Vector2 数组 |
| `PackedVector3Array` | Vector3 数组 |
| `PackedColorArray` | Color 数组 |

**优势**：
- 内存效率更高（连续内存，无 Variant 开销）
- 性能更好（尤其批量操作）
- 可直接传递给 GPU（如顶点数据、颜色数组）

**劣势**：
- 只能存储单一类型
- 不能调整大小（需创建新数组）

---

## 四、Dictionary（字典）详解

### 4.1 内部实现

Godot 的 Dictionary 基于**哈希表**实现。

### 4.2 操作性能分析

| 操作 | 复杂度 | 说明 |
|------|--------|------|
| **插入/修改** | **O(1)** 平均 | ⚡⚡⚡ 极快 |
| **删除** | **O(1)** 平均 | ⚡⚡⚡ 极快 |
| **查找** | **O(1)** 平均 | ⚡⚡⚡ 极快 |
| **迭代** | O(n) | 需要遍历所有桶 |

> **注意**：最坏情况下（哈希冲突严重）所有操作退化为 O(n)，但实际很少发生。

### 4.3 适用场景

```gdscene
# ✅ 适合：键值对查找
var inventory = {}
inventory["potion"] = 5
inventory["sword"] = 1
if inventory.has("potion"):
    use_potion()

# ✅ 适合：快速查找
var entity_map = {}  # id -> entity
entity_map[entity_id] = entity
var entity = entity_map[target_id]

# ❌ 不适合：有序遍历（用 Array）
for key in dictionary:  # 顺序不确定
    pass
```

### 4.4 键的类型选择

| 键类型 | 推荐度 | 说明 |
|--------|--------|------|
| **String** | ⭐⭐⭐ | 可读性好，常用 |
| **int** | ⭐⭐⭐ | 最高效，适合ID映射 |
| **Vector2i/3i** | ⭐⭐ | 网格坐标、瓦片地图 |
| **Object** | ⭐ | 可能导致内存泄漏（循环引用） |
| **Array** | ⚠️ | 可哈希但性能较差 |

---

## 五、Object（对象）详解

### 5.1 特点

- 引用类型（赋值是引用而非拷贝）
- 支持信号（Signal）
- 支持 @export / @onready
- 有生命周期（_enter_tree/_ready/_exit_tree/_tree_exiting）

### 5.2 性能特点

| 方面 | 表现 |
|------|------|
| 创建开销 | 中等（需要初始化） |
| 内存占用 | 较大（元数据+属性） |
| 访问速度 | 快（属性查找经过优化） |
| 键可用性 | ⚠️ 作为Dictionary键可能导致循环引用 |

### 5.3 何时用 Object

```gdscene
# ✅ 适合：需要生命周期的复杂数据
class_name ItemData extends Resource  # 或 Node

@export var name: String
@export var description: String
@export var stack_size: int = 99
@export var icon: Texture2D

signal used(item_data)
signal quantity_changed(old_val, new_val)


# ✅ 适合：需要信号的组件
class_name HealthComponent extends Node

signal health_depleted()
signal health_changed(old_value, new_value)
signal damage_taken(amount, attacker)

var current_health: int
var max_health: int

func take_damage(amount: int, attacker: Node):
    current_health = maxi(0, current_health - amount)
    damage_taken.emit(amount, attacker)
    health_changed.emit(current_health + amount, current_health)
    if current_health <= 0:
        health_depleted.emit()
```

---

## 六、选择决策树

```
需要存储什么？
│
├─ 同类型数据集合
│  ├─ 需要有序访问？→ Array / PackedArray
│  └─ 需要按键查找？→ Dictionary（int键）+ Array（存值）
│
├─ 键值对映射
│  ├─ 键是字符串/int？→ Dictionary ✅
│  ├─ 需要排序？→ Array of custom objects
│  └─ 需要范围查询？→ 自定义数据结构
│
├─ 复杂实体
│  ├─ 需要生命周期/信号？→ Object (Node/Resource) ✅
│  ├─ 纯数据容器？→ Resource（继承自 Object）
│  └─ 需要在场景树中？→ Node
│
└─ GPU数据（顶点/颜色/UV）
   └─ PackedArray ✅（最高效）
```

---

## 七、典型使用场景对比

### 7.1 实体管理系统

```gdscene
# 方案A：Array + 线性查找（少量实体 < 1000）
var enemies: Array[Enemy] = []

func find_enemy_by_id(id: int) -> Enemy:
    for enemy in enemies:
        if enemy.id == id:
            return enemy
    return null

# 方案B：Dictionary + O(1)查找（大量实体 ≥ 1000）
var enemies_by_id: Dictionary = {}

func find_enemy_by_id(id: int) -> Enemy:
    return enemies_by_id.get(id)

# 方案C：混合方案（需要有序+查找）
var enemies: Array[Enemy] = []           # 用于有序遍历
var enemy_id_map: Dictionary = {}         # 用于快速查找

func add_enemy(enemy: Enemy):
    enemies.append(enemy)
    enemy_id_map[enemy.id] = enemy

func remove_enemy(enemy: Enemy):
    enemies.erase(enemy)
    enemy_id_map.erase(enemy.id)
```

### 7.2 物品栏系统

```gdscene
# 推荐方案：Dictionary + 自定义Item数据
var inventory: Dictionary = {}  # item_id → ItemData

func add_item(item: ItemData, quantity: int = 1):
    if inventory.has(item.id):
        inventory[item.id].quantity += quantity
    else:
        inventory[item.id] = {
            "data": item,
            "quantity": quantity,
        }
    item_added.emit(item, quantity)

func remove_item(item_id: String, quantity: int = 1) -> bool:
    if not inventory.has(item_id):
        return false

    inventory[item_id].quantity -= quantity
    if inventory[item_id].quantity <= 0:
        inventory.erase(item_id)

    item_removed.emit(item_id, quantity)
    return true
```

### 7.3 地图/网格数据

```gdscene
# 推荐：Dictionary with Vector2i key（稀疏网格）
var tile_data: Dictionary = {}

func set_tile(pos: Vector2i, tile_type: int):
    tile_data[pos] = tile_type

func get_tile(pos: Vector2i) -> int:
    return tile_data.get(pos, -1)  # -1 表示空

# 替代方案：密集网格用 PackedInt32Array（性能更高但固定大小）
# var grid = PackedInt32Array()
# grid.resize(width * height)
# grid[y * width + x] = tile_type
```

---

## 八、性能优化技巧

### 8.1 Array 优化

```gdscene
# ✅ 预分配大小（已知最终大小时）
var array = []
array.resize(expected_size)  # 避免多次重新分配

# ✅ 批量操作时先收集再统一处理
var to_remove: Array = []
for item in array:
    if should_remove(item):
        to_remove.append(item)
for item in to_remove:
    array.erase(item)  # 减少中间移动

# ✅ 使用 PackedArray 存储数值数据
var positions: PackedVector3Array = []
positions.append(Vector3(1, 2, 3))
# 直接传给 GPU 渲染
mesh.surface_set_attribute_arrays(Mesh.ARRAY_VERTEX, positions)
```

### 8.2 Dictionary 优化

```gdscene
# ✅ 使用 int 键而非 String（更快）
var map_int: Dictionary = {}      # ⚡ 更快
map_int[12345] = value

var map_str: Dictionary = {}      # 🐢 较慢
map_str["12345"] = value

# ✅ 批量插入比逐个插入更高效
var batch_data = {
    key1: value1,
    key2: value2,
    key3: value3,
}
dictionary.merge(batch_data)

# ✅ 避免频繁创建/销毁 Dictionary（考虑对象池）
```

### 8.3 内存意识

```gdscene
# ⚠️ 注意：Array 和 Dictionary 存储的是 Variant
# 对于大量数值数据，PackedArray 内存占用显著更低：

# Array（每个元素是 Variant，~24字节 overhead）
var arr: Array = []
arr.append(42)  # ~40+ bytes per element

# PackedInt32Array（每个元素4字节）
var packed: PackedInt32Array = []
packed.append(42)  # 4 bytes per element

# 100万元素：Array ≈ 40MB, PackedInt32Array ≈ 4MB
```

---

## 九、参考链接

- [Array 官方文档](https://docs.godotengine.org/en/stable/classes/class_array.html)
- [Dictionary 官方文档](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)
- [Variant 官方文档](https://docs.godotengine.org/en/stable/classes/class_variant.html)
- [Packed*Array 文档系列](https://docs.godotengine.org/en/stable/classes/class_packed*array.html)
- [场景组织](16A_Scene_Organization.md)
- [静态类型](01E_Static_Typing.md)
