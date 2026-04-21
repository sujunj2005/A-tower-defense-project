# 数据结构偏好指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 16B_Data_Preferences.md](../../base/best-practices/16B_Data_Preferences.md)  
> **重要性**: 🟡 推荐 - 数据管理最佳实践

---

## 📋 概述

选择合适的数据结构可以提高代码性能和可维护性。本指南介绍 Godot 中各种数据结构的最佳使用场景。

---

## 🎯 数据结构选择

### 1. Array（数组）

**适用场景**：
- 有序列表
- 需要索引访问
- 允许重复元素

```gdscript
var items = ["sword", "shield", "potion"]
items.append("bow")
items.remove_at(1)
```

### 2. Dictionary（字典）

**适用场景**：
- 键值对存储
- 快速查找
- 配置数据

```gdscript
var player_stats = {
    "health": 100,
    "mana": 50,
    "level": 5
}
print(player_stats["health"])
```

### 3. Set（集合）

**适用场景**：
- 唯一元素集合
- 快速成员检查
- 集合运算

```gdscript
var unique_items = ["sword", "shield", "sword"]
var item_set = unique_items.to_set()  # 去重
print(item_set.has("sword"))  # true
```

---

## 🔧 实战技巧

### 1. 类型安全

```gdscript
# 使用类型注解
var health_values: Array[int] = [100, 80, 60]
var config: Dictionary = {"volume": 0.8}

# GDScript 2.0 强类型
var typed_array: Array[float] = [1.0, 2.0, 3.0]
```

### 2. 性能优化

```gdscript
# ✅ 快速：Dictionary 查找 O(1)
var lookup = {"key": "value"}
if lookup.has("key"):
    print(lookup["key"])

# ❌ 慢速：Array 查找 O(n)
var list = ["key1", "key2", "key3"]
if "key" in list:
    print("found")
```

---

## 🔗 相关资源

### Base 层
- [16B_Data_Preferences.md](../../base/best-practices/16B_Data_Preferences.md) - 数据结构详解

### Wiki 层
- [场景组织指南](../guides/scene-organization-guide.md) - 场景组织最佳实践

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
