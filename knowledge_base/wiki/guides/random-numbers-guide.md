# 随机数生成指南

> **来源**: [04F_Random_Numbers.md](../../base/math-transforms/04F_Random_Numbers.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📚 概述

随机数在游戏中无处不在：暴击判定、掉落物品、敌人行为、地图生成等。

> **重要概念**: 计算机无法生成"真正"的随机数，而是依赖**伪随机数生成器**（PRNG）。Godot 内部使用 PCG 系列伪随机数生成器。

---

## 🎯 核心概念

### 1. 两种随机化方式

| 方式 | 说明 | 优点 | 缺点 |
|------|------|------|------|
| **全局作用域方法** | `randi()`, `randf()` 等全局函数 | 简单易用，代码简洁 | 全局状态，难以控制 |
| **RandomNumberGenerator 类** | 创建独立的随机数生成器实例 | 多个独立实例，可分别设置种子 | 代码稍多，需要管理实例 |

---

### 2. 随机化（Randomize）

#### 2.1 randomize()

> **注意**: 从 Godot 4.0 开始，项目启动时随机种子会**自动设置为随机值**。这意味着您不再需要在 `_ready()` 中调用 `randomize()` 来确保结果在项目运行中是随机的。

```gdscript
func _ready():
    randomize()  # 显式随机化（可选）
```

**使用场景**:
- 需要重新随机化全局随机种子
- 使用固定种子后想恢复随机状态

#### 2.2 设置固定种子

使用固定种子可以获得**可重现的结果**：

```gdscript
func _ready():
    seed(12345)  # 固定种子
    # 每次运行结果相同
    print(randi())  # 总是输出相同的值
    
    # 使用字符串作为种子
    seed("Hello world".hash())
```

**应用场景**:
- 程序化生成（固定种子生成相同地图）
- 调试和测试（重现随机行为）
- 多人游戏同步（使用相同种子）

---

### 3. 常用随机函数

#### 3.1 randi() - 随机整数

```gdscript
var random_int = randi()  # 0 到 2^32-1
```

**返回值**: 0 到 4,294,967,295 之间的随机整数

#### 3.2 randf() - 随机浮点数

```gdscript
var random_float = randf()  # 0.0 到 1.0
```

**返回值**: 0.0 到 1.0 之间的随机浮点数

#### 3.3 randfn() - 正态分布

```gdscript
var normal_dist = randfn()  # 标准正态分布，均值 0，标准差 1
var custom = randfn(5, 2)  # 均值 5，标准差 2
```

**应用场景**:
- 模拟自然现象（身高、体重分布）
- 游戏数值波动（伤害浮动）
- AI 行为变化（更自然的决策）

#### 3.4 randf_range() - 范围内随机浮点数

```gdscript
var in_range = randf_range(0.0, 100.0)  # 0 到 100 之间的浮点数
```

#### 3.5 randi_range() - 范围内随机整数

```gdscript
var in_range = randi_range(0, 10)  # 0 到 10 之间的整数（包括端点）
```

> **重要**: `randi_range()` 包含两个端点值！

---

### 4. 从数组中随机选择

#### 4.1 随机元素

```gdscript
var fruits = ["apple", "banana", "cherry", "date"]
var random_fruit = fruits.pick_random()
```

#### 4.2 洗牌

```gdscript
var deck = range(52)
deck.shuffle()
```

**应用场景**:
- 洗牌（卡牌游戏）
- 随机顺序生成（Roguelike 关卡）
- 随机出场顺序（敌人波次）

#### 4.3 随机索引

```gdscript
var array = [1, 2, 3, 4, 5]
var random_index = randi_range(0, array.size() - 1)
var random_element = array[random_index]
```

#### 4.4 随机多个元素

```gdscript
func pick_multiple(array: Array, count: int) -> Array:
    var copy = array.duplicate()
    copy.shuffle()
    return copy.slice(0, count)

# 使用
var items = ["sword", "shield", "potion", "ring", "armor"]
var random_items = pick_multiple(items, 3)
```

---

## 🎮 噪声生成

### 5.1 噪声类型

| 类型 | 说明 | 应用场景 |
|------|------|---------|
| `FastNoiseLite` | 快速噪声生成器 | 地形生成、纹理生成 |
| `NoiseTexture2D` | 噪声纹理 | 背景效果、自然纹理 |

### 5.2 FastNoiseLite 基本用法

```gdscript
var noise = FastNoiseLite.new()
noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
noise.frequency = 0.01
noise.seed = randi()

# 采样 2D 噪声
var value = noise.get_noise_2d(50, 100)
```

**常用属性**:
- `noise_type`: 噪声类型（Simplex, Perlin, Value 等）
- `frequency`: 频率（控制噪声细节）
- `seed`: 随机种子
- `octaves`: 倍频程（控制细节层次）
- `lacunarity`: 倍频程之间的频率增长

### 5.3 生成噪声贴图

```gdscript
var noise_texture = NoiseTexture2D.new()
noise_texture.width = 512
noise_texture.height = 512
noise_texture.noise = FastNoiseLite.new()

# 应用到 Sprite2D
$Sprite2D.texture = noise_texture
```

**应用场景**:
- 地形高度图
- 云层效果
- 水面波纹
- 大理石/木纹纹理

---

## 🔐 加密安全随机数

### 6.1 使用 PCK 包装器

对于加密安全的随机数，使用 `PCK` 包装器（Godot 4.x+）：

```gdscript
var rng = PCK.new()
var secure_int = rng.get_random_bytes(4)  # 4 字节随机数
```

### 6.2 与普通随机的区别

| 特性 | 普通随机 | 加密安全随机 |
|------|-----------|--------------|
| 性能 | 快 | 较慢 |
| 可预测性 | 可预测（给定种子） | 不可预测 |
| 适用场景 | 游戏逻辑 | 密码学、安全令牌 |

**使用建议**:
- 游戏逻辑使用普通随机数（`randi()`, `RandomNumberGenerator`）
- 仅在需要加密安全时使用 `PCK`（如生成密码、令牌）

---

## 🎮 RandomNumberGenerator 类

### 7.1 多个独立实例

```gdscript
var rng1 = RandomNumberGenerator.new()
var rng2 = RandomNumberGenerator.new()

func _ready():
    rng1.randomize()
    rng2.seed = 12345

func generate():
    print(rng1.randi())  # 每次不同
    print(rng2.randi())  # 每次相同（固定种子）
```

**优势**:
- 独立的随机状态
- 可以为不同系统使用不同的种子
- 便于测试和调试

### 7.2 实例方法

| 方法 | 说明 | 示例 |
|------|------|------|
| `randomize()` | 随机化种子 | `rng.randomize()` |
| `seed(value)` | 设置种子 | `rng.seed = 12345` |
| `randi()` | 随机整数 | `rng.randi()` |
| `randf()` | 随机浮点数 | `rng.randf()` |
| `randfn(mean, deviation)` | 正态分布 | `rng.randfn(5, 2)` |
| `randf_range(from, to)` | 范围内浮点数 | `rng.randf_range(0.0, 1.0)` |
| `randi_range(from, to)` | 范围内整数 | `rng.randi_range(1, 6)` |

---

## 💡 实战示例

### 示例 1: 随机掉落物品

```gdscript
var loot_table = [
    {item = "sword", chance = 0.1},
    {item = "shield", chance = 0.2},
    {item = "potion", chance = 0.5},
    {item = "nothing", chance = 0.2}
]

func get_random_loot():
    var roll = randf()
    var cumulative = 0.0
    
    for entry in loot_table:
        cumulative += entry.chance
        if roll <= cumulative:
            return entry.item
    
    return "nothing"
```

### 示例 2: 随机地图生成

```gdscript
var map_seed = Time.get_ticks_msec()

func generate_map():
    seed(map_seed)
    var noise = FastNoiseLite.new()
    noise.seed = map_seed
    noise.frequency = 0.05
    
    var map_data = []
    for y in range(map_height):
        var row = []
        for x in range(map_width):
            var value = noise.get_noise_2d(x, y)
            row.append(value > 0.0 ? 1 : 0)  # 1=陆地，0=水
        map_data.append(row)
    
    return map_data
```

### 示例 3: 敌人行为随机性

```gdscript
var rng = RandomNumberGenerator.new()

func _ready():
    rng.randomize()

func choose_behavior():
    var behaviors = ["attack", "defend", "flee", "patrol"]
    var index = rng.randi_range(0, behaviors.size() - 1)
    return behaviors[index]

func should_critical_hit():
    # 20% 暴击率
    return rng.randf() < 0.2
```

### 示例 4: 随机对话选择

```gdscript
var greetings = [
    "你好，冒险者！",
    "欢迎来到小镇！",
    "今天天气不错！",
    "有什么需要帮忙的吗？"
]

func greet_player():
    var index = randi_range(0, greetings.size() - 1)
    return greetings[index]

# 使用
var greeting = greet_player()
$Label.text = greeting
```

### 示例 5: 程序化武器属性

```gdscript
func generate_random_weapon():
    var weapon = {
        name = "Sword",
        damage = randi_range(10, 20),
        speed = randf_range(0.8, 1.5),
        critical_chance = randf_range(0.05, 0.2),
        enchantment = pick_random(["fire", "ice", "lightning", "none"])
    }
    
    # 使用正态分布生成更自然的数值
    weapon.durability = int(randfn(100, 20))
    
    return weapon
```

---

## 📊 随机函数选择指南

| 需求 | 推荐函数 | 说明 |
|------|---------|------|
| 简单随机整数 | `randi_range(from, to)` | 包含端点 |
| 简单随机浮点数 | `randf_range(from, to)` | 不包含上界 |
| 从数组选一个 | `array.pick_random()` | 最简洁 |
| 洗牌数组 | `array.shuffle()` | 原地修改 |
| 自然分布数值 | `randfn(mean, deviation)` | 正态分布 |
| 可重现随机 | `seed(value)` + `randi()` | 固定种子 |
| 多个独立随机源 | `RandomNumberGenerator` | 独立实例 |
| 噪声/地形 | `FastNoiseLite` | 程序化生成 |
| 加密安全 | `PCK.get_random_bytes()` | 不可预测 |

---

## 🔗 相关链接

### Base 层来源
- [04F_Random_Numbers.md](../../base/math-transforms/04F_Random_Numbers.md) - 完整原始文档

### Wiki 层相关
- [插值运算指南](./interpolation-guide.md) - 随机插值应用

### 外部资源
- [Godot 官方随机数教程](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html)
- [FastNoiseLite API](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html)
- [RandomNumberGenerator API](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html)

---

## 📝 最佳实践

### 1. 种子的使用

- **开发阶段**: 使用固定种子便于调试
- **发布版本**: 使用自动随机种子
- **程序化生成**: 保存种子以便重现

### 2. 性能考虑

- 全局函数 `randi()` 比 `RandomNumberGenerator` 稍快
- 避免每帧都调用 `randomize()`
- 正态分布 `randfn()` 比普通随机稍慢

### 3. 测试技巧

```gdscript
# 测试时使用固定种子
func _ready():
    if OS.is_debug_build():
        seed(12345)  # 调试时固定种子

# 发布时随机
    else:
        randomize()
```

### 4. 避免常见错误

- ❌ 不要在循环中调用 `randomize()`
- ✅ 在 `_ready()` 中调用一次即可
- ❌ 不要依赖 `randi() % n`（分布不均）
- ✅ 使用 `randi_range(0, n-1)`

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**许可**: MIT
