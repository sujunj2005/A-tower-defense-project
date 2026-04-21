# Godot 4.x 随机数生成

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/math/random_number_generation.rst

---

## 目录

1. [随机数概述](#1-随机数概述)
2. [全局作用域 vs RandomNumberGenerator](#2-全局作用域-vs-randomnumbergenerator)
3. [随机化](#3-随机化)
4. [常用随机函数](#4-常用随机函数)
5. [从数组中随机选择](#5-从数组中随机选择)
6. [噪声生成](#6-噪声生成)
7. [加密安全随机数](#7-加密安全随机数)

---

## 1. 随机数概述

### 1.1 伪随机数

> **注意**：计算机无法生成"真正"的随机数。相反，它们依赖于伪随机数生成器（PRNG）。

Godot 内部使用 PCG 系列伪随机数生成器。

---

## 2. 全局作用域 vs RandomNumberGenerator

### 2.1 两种方式

| 方式 | 说明 |
|------|------|
| 全局作用域方法 | 更容易设置，但控制较少 |
| RandomNumberGenerator 类 | 需要更多代码，但允许创建多个实例，每个都有自己的种子和状态 |

---

## 3. 随机化

### 3.1 randomize()

> **注意**：从 Godot 4.0 开始，项目启动时随机种子会自动设置为随机值。这意味着您不再需要在 `_ready()` 中调用 `randomize()` 来确保结果在项目运行中是随机的。但是，如果您想使用特定的种子数，或者使用不同的方法生成它，仍然可以使用 `randomize()`。

```gdscript
func _ready():
    randomize()  # 显式随机化
```

### 3.2 设置固定种子

使用固定种子可以获得可重现的结果：

```gdscript
func _ready():
    seed(12345)  # 固定种子
    # 每次运行结果相同
    print(randi())  # 总是输出相同的值

    # 使用字符串作为种子
    seed("Hello world".hash())
```

---

## 4. 常用随机函数

### 4.1 randi() - 随机整数

```gdscript
var random_int = randi()  # 0 到 2^32-1
```

### 4.2 randf() - 随机浮点数

```gdscript
var random_float = randf()  # 0.0 到 1.0
```

### 4.3 randfn() - 正态分布

```gdscript
var normal_dist = randfn()  # 标准正态分布，均值 0，标准差 1
var custom = randfn(5, 2)  # 均值 5，标准差 2
```

### 4.4 randf_range() - 范围内随机

```gdscript
var in_range = randf_range(0.0, 100.0)  # 0 到 100 之间的浮点数
```

### 4.5 randi_range() - 范围内随机整数

```gdscript
var in_range = randi_range(0, 10)  # 0 到 10 之间的整数（包括端点）
```

---

## 5. 从数组中随机选择

### 5.1 随机元素

```gdscript
var fruits = ["apple", "banana", "cherry", "date"]
var random_fruit = fruits.pick_random()
```

### 5.2 洗牌

```gdscript
var deck = range(52)
deck.shuffle()
```

### 5.3 随机索引

```gdscript
var array = [1, 2, 3, 4, 5]
var random_index = randi_range(0, array.size() - 1)
var random_element = array[random_index]
```

### 5.4 随机多个元素

```gdscript
func pick_multiple(array: Array, count: int) -> Array:
    var copy = array.duplicate()
    copy.shuffle()
    return copy.slice(0, count)
```

---

## 6. 噪声生成

### 6.1 噪声类型

| 类型 | 说明 |
|------|------|
| `FastNoiseLite` | 快速噪声生成器 |
| `NoiseTexture2D` | 噪声纹理 |

### 6.2 FastNoiseLite 基本用法

```gdscript
var noise = FastNoiseLite.new()
noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
noise.frequency = 0.01
noise.seed = randi()

# 采样 2D 噪声
var value = noise.get_noise_2d(50, 100)
```

### 6.3 生成噪声贴图

```gdscript
var noise_texture = NoiseTexture2D.new()
noise_texture.width = 512
noise_texture.height = 512
noise_texture.noise = FastNoiseLite.new()

# 应用到 Sprite2D
$Sprite2D.texture = noise_texture
```

---

## 7. 加密安全随机数

### 7.1 使用 PCK 包装器

对于加密安全的随机数，使用 `PCK` 包装器（Godot 4.x+）：

```gdscript
var rng = PCK.new()
var secure_int = rng.get_random_bytes(4)  # 4 字节随机
```

### 7.2 与普通随机的区别

| 特性 | 普通随机 | 加密安全随机 |
|------|-----------|--------------|
| 性能 | 快 | 较慢 |
| 可预测性 | 可预测（给定种子） | 不可预测 |
| 适用场景 | 游戏逻辑 | 密码学、安全 |

---

## 8. RandomNumberGenerator 类

### 8.1 多个独立实例

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

### 8.2 实例方法

| 方法 | 说明 |
|------|------|
| `randomize()` | 随机化种子 |
| `seed(value)` | 设置种子 |
| `randi()` | 随机整数 |
| `randf()` | 随机浮点数 |
| `randfn(mean, deviation)` | 正态分布 |
| `randf_range(from, to)` | 范围内浮点数 |
| `randi_range(from, to)` | 范围内整数 |

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/math/random_number_generation.rst`
