# Godot 4.x 警告修复快速参考

> 适用版本：Godot 4.x（特别是 4.6+） | 版本：1.0

---

## 🚀 快速修复指南

### 1. 整数除法（INTEGER_DIVISION）

**警告信息：**
```
Integer division. Decimal part will be discarded.
```

**快速修复：**
```gdscript
# ❌ 错误
var half = size / 2

# ✅ 正确
var half = size / 2.0
```

**批量搜索：**
```bash
grep -rn "/ 2[^.0]" --include="*.gd" .
```

**常见位置：**
- `tile_size / 2` → `tile_size / 2.0`
- `viewport_size.x / 2` → `viewport_size.x / 2.0`
- `Vector2(size / 2, size / 2)` → `Vector2(size / 2.0, size / 2.0)`

---

### 2. 变量遮蔽（SHADOWED_VARIABLE）

**警告信息：**
```
The local function parameter "target" is shadowing an already-declared variable
```

**快速修复：**
```gdscript
# ❌ 错误
var target: Node2D = null
func apply_effect(target: Node2D):
    if not target: return

# ✅ 正确
var target: Node2D = null
func apply_effect(effect_target: Node2D):
    if not effect_target: return
```

**命名模式：**
- `target` → `slow_target` / `dot_target` / `knockback_target`
- `config` → `attack_config` / `enemy_config`
- `damage` → `damage_value` / `base_damage`

**批量搜索：**
```bash
grep -rn "var target:" --include="*.gd" .
grep -rn "func.*target:" --include="*.gd" .
```

---

### 3. 枚举值不匹配（INT_AS_ENUM_WITHOUT_MATCH）

**警告信息：**
```
Cannot assign 0 as Enum "ParticleProcessMaterial.EmissionShape": no enum member has matching value.
```

**快速修复：**
```gdscript
# ❌ 错误（依赖版本）
material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT

# ✅ 正确（版本兼容）
# Godot 4.x 发射形状值：
# 0 = POINT, 1 = SPHERE, 2 = BOX, 3 = RING, 4 = CIRCLE
material.emission_shape = 0
```

**常见枚举值：**
```gdscript
# ParticleProcessMaterial.EmissionShape
0  # POINT (点)
2  # BOX (盒子)
3  # RING (环)
4  # CIRCLE (圆形)
```

**批量搜索：**
```bash
grep -rn "emission_shape = [0-9]" --include="*.gd" .
```

---

### 4. 资源 UID 无效（INVALID_RESOURCE_UID）

**警告信息：**
```
ext_resource, invalid UID: uid://arrow_projectile_unique_id - using text path instead
```

**快速修复：**
```tres
# ❌ 错误（占位符 UID）
[ext_resource type="Resource" uid="uid://arrow_projectile_unique_id" path="res://resources/projectiles/arrow_projectile.tres" id="2_projectile"]

# ✅ 正确（真实 UID）
[ext_resource type="Resource" uid="uid://bir4roo7lnx42" path="res://resources/projectiles/arrow_projectile.tres" id="2_projectile"]
```

**获取正确 UID 的方法：**
1. 打开实际资源文件（如 `arrow_projectile.tres`）
2. 查看第一行的 UID：`uid="uid://bir4roo7lnx42"`
3. 复制并替换引用处的错误 UID

**预防措施：**
- ✅ 在 Godot 编辑器中创建资源，不要手动编写 UID
- ✅ 使用检查器面板查看资源的真实 UID

---

## 📊 实战统计

| 问题类型 | 修复数量 | 涉及文件 |
|----------|----------|----------|
| 整数除法 | 11 处 | map_manager.gd (5), enemy_spawner.gd (2), camera_controller.gd (4), projectile_config.gd (1) |
| 变量遮蔽 | 4 处 | tower_attack_component.gd (4) |
| 枚举问题 | 2 处 | projectile_config.gd, archer_tower.tres, magic_tower.tres |
| 资源 UID | 2 处 | archer_tower.tres, magic_tower.tres |
| **总计** | **19 处** | **7 个文件** |

---

## 🔍 批量检查脚本

**一键搜索所有常见问题：**
```bash
#!/bin/bash

echo "=== 搜索整数除法 ==="
grep -rn "/ 2[^.0]" --include="*.gd" .

echo -e "\n=== 搜索变量遮蔽 ==="
grep -rn "var target:" --include="*.gd" .
grep -rn "func.*target:" --include="*.gd" .

echo -e "\n=== 搜索枚举使用 ==="
grep -rn "emission_shape = [0-9]" --include="*.gd" .

echo -e "\n=== 搜索资源 UID ==="
grep -rn "uid://.*_unique_id" --include="*.tres" .
```

---

## ✅ 提交前检查清单

- [ ] 编译警告数量为 0（或仅有可接受的第三方警告）
- [ ] 所有除法运算都使用浮点数（`/ 2.0` 而不是 `/ 2`）
- [ ] 函数参数名不与成员变量冲突
- [ ] `.tres` 和 `.tscn` 文件中的 UID 都是正确的
- [ ] 所有警告都有注释说明（如果故意保留）
- [ ] 代码符合命名规范
- [ ] 调试代码已清理

---

## 📚 相关文档

- **[GDScript_Code_Standards.md](../20_Best_Practices/GDScript_Code_Standards.md)** - **代码规范标准** ⭐
- [GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md) - 警告处理详细指南
- [19_Pitfall_Records.md](./19_Pitfall_Records.md) - 通用踩坑记录

---

**文档说明：**
本快速参考基于实际项目中的警告修复经验整理，旨在提供快速定位和解决常见 GDScript 警告的方法。

**最后更新：** 2026-04-03 | **版本：** 1.0
