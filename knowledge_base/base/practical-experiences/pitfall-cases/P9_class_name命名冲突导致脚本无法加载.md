# P9：class_name 命名冲突导致脚本无法加载

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | GDScript/语法 |
| **严重程度** | 🔴 高 |
| **涉及文件** | `scripts/bean/skill/skill_bean.gd` |
| **知识库关联** | [GDScript 语法基础](../../GDScript%20语法基础.md) / [§27 Autoload class_name 冲突](../../../wiki/guides/common-pitfalls.md#27-autoload-脚本禁止-class_name-声明) |

---

## 现象

创建 `SkillData.gd` 后，Godot 编辑器报错：

```
Parse Error: Class "SkillData" hides a global script class.
```

脚本完全无法加载，导致技能系统不可用。

## 根因

Godot 中 `class_name` 全局唯一，项目中已存在同名的全局脚本类 `SkillData`。再次声明会导致命名冲突。

## 修复

将新脚本重命名为 `SkillBean`（本项目约定数据类使用 `Bean` 后缀）：

```gdscript
# ❌ class_name SkillData  ← 冲突
# ✅ 
class_name SkillBean
extends Resource
```

同时更新所有引用该类的代码。

## 预防

1. **创建新脚本前先用 `Grep` 搜索 `class_name <目标名称>` 确认无冲突**
2. 遵循项目命名约定：数据类用 `Bean` 后缀（如 `SkillBean`、`TowerBean`）
3. 新建脚本后立即在编辑器中验证能否正常加载

---

*记录时间：2026-04-29*