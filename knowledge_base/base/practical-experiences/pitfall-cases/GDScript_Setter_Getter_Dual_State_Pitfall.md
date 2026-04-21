# Godot 4.x 内嵌 get/set 双重状态踩坑

> **问题分类**: 代码规范 / 常见错误  
> **影响版本**: Godot 4.x  
> **发现时间**: 2026-04-08  
> **来源**: tower_defense 项目 TowerSelectUI 重构实战  
> **严重性**: 🔴 高 - 导致面板无法显示，UI 交互完全失效

---

## 📋 问题描述

在 Godot 4.x 中使用内嵌 `set`/`get` 函数包装已有属性（如 Control 的 `visible`）时，如果错误地将包装变量当作独立状态处理，会创建两个互不关联的状态变量，导致状态不一致、UI 无法响应等严重问题。

---

## 🎯 问题表现

### 1. 面板无法显示

```gdscript
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if is_panel_visible != value:  # ❌ 检查自身（应该检查 visible）
            is_panel_visible = value    # ❌ 自赋值（冗余）
            visible = value             # ❌ 同步另一个属性
            if is_panel_visible:
                _on_panel_shown()
            else:
                _on_panel_hidden()
    get:
        return is_panel_visible  # ❌ 返回自身（应该返回 visible）

func _complete_tower_building():
    tower_select_ui.visible = false  # ❌ 直接设置 visible，is_panel_visible 仍为 true

func show_at_position(pos: Vector2):
    is_panel_visible = true  # ❌ setter 检查发现已是 true，不执行 visible = true
    # 结果：面板无法显示，点击塔位无反应！
```

### 2. 踩坑过程

1. 在 `_complete_tower_building()` 中直接设置 `visible = false`
2. `is_panel_visible` 仍为 `true`，状态不同步
3. 下次调用 `show_at_position()` 时设置 `is_panel_visible = true`
4. setter 检查发现 `is_panel_visible` 已经是 `true`，不执行 `visible = true`
5. **结果**：面板无法显示，点击塔位无反应

---

## 🔍 根因分析

### 两种使用场景的本质区别

| 场景 | 用法 | setter 检查 | setter 设置 | getter 返回 | 示例 |
|------|------|-----------|-----------|-----------|------|
| **独立状态** | 无底层属性 | `if self != value` | `self = value` | `return self` | `is_locked`, `hovered_tower` |
| **包装属性** | 有底层属性 | `if underlying != value` | `underlying = value` | `return underlying` | `is_panel_visible` (包装 `visible`) |
| **计算属性** | 只读 getter | N/A | N/A | 计算表达式 | `health_percent` |

**核心错误**：将**包装属性**场景当作**独立状态**场景处理，导致：
- 创建了两个独立状态（`is_panel_visible` 和 `visible`）
- setter 中自赋值是冗余的
- 需要手动同步两个属性，容易遗漏
- 直接访问底层属性会破坏状态一致性

---

## 🔧 解决方案

### 正确做法：包装属性时设置底层属性

```gdscript
extends Panel

var is_panel_visible: bool = false:
    set(value):
        if visible != value:  # ✅ 检查实际的 visible 状态
            visible = value    # ✅ 直接设置 Control 的 visible
            if visible:
                _on_panel_shown()
            else:
                _on_panel_hidden()
    get:
        return visible  # ✅ 直接返回 Control 的 visible 值

func _complete_tower_building():
    is_panel_visible = false  # ✅ 始终使用包装属性，状态保持一致

func show_at_position(pos: Vector2):
    is_panel_visible = true  # ✅ 正常工作
    position = pos
```

### 对比：独立状态变量的正确写法

```gdscript
# ✅ 正确：独立状态变量（无底层属性）
var is_locked: bool = false:
    set(value):
        if is_locked != value:  # ✅ 检查自身当前值
            is_locked = value    # ✅ 自赋值设置内部存储
            if is_locked:
                _lock_panel()
            else:
                _unlock_panel()
    get:
        return is_locked  # ✅ 返回自身值

# ✅ 正确：对象引用类型的独立状态
var hovered_tower: Tower = null:
    set(value):
        if hovered_tower != value:
            hovered_tower = value
            if hovered_tower:
                _on_tower_hovered(hovered_tower)
            else:
                _on_tower_hover_ended()
    get:
        return hovered_tower
```

### 对比：计算属性的正确写法

```gdscript
# ✅ 正确：只读计算属性
var health: float = 100.0
var max_health: float = 100.0

var health_percent: float:
    get:
        return health / max_health if max_health > 0 else 0.0
```

---

## 📏 判断规则

在编写内嵌 `set`/`get` 前，先问自己：

1. **这个变量有底层对应属性吗？**
   - 有 → **包装属性**：setter 设置底层属性，getter 返回底层属性
   - 没有 → **独立状态**：setter 自赋值，getter 返回自身

2. **是否需要始终通过包装属性访问？**
   - 是 → 确保所有代码都通过包装属性访问，不直接访问底层属性
   - 否 → 考虑是否真的需要包装

---

## ✅ 检查清单

- [ ] 正确区分独立状态和包装属性
- [ ] 独立状态使用自赋值，包装属性设置底层属性
- [ ] getter 返回正确的值（自身 vs 底层属性）
- [ ] 没有创建双重状态
- [ ] 避免了直接访问底层属性（包装属性场景）
- [ ] 状态始终保持一致

---

## 🔗 相关文档

### 本项目知识库
- [GDScript_Code_Standards.md](../code-standards/GDScript_Code_Standards.md#34-内嵌-getset-使用场景与常见错误) - GDScript 代码规范（含完整 set/get 规范）
- [gdscript-standards.md](../../../wiki/concepts/gdscript-standards.md#3-内嵌-setget-函数规范) - Wiki 层代码规范
- [踩坑记录完整索引.md](../../../踩坑记录完整索引.md#26-内嵌-getset-创建双重状态-🔴-高) - 踩坑索引 §26

### 外部资源
- [GDScript 参考：属性](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#properties-setters-and-getters)
- [Godot 最佳实践](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)

---

**文档版本**: 1.0  
**最后更新**: 2026-04-09  
**维护者**: Knowledge Base Administrator  
**来源**: tower_defense 项目 TowerSelectUI 重构实战
