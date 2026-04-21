# Godot 4.x 国际化(i18n)实战指南

## 概述
本文档总结了在"人生塔防"项目中实施i18n的完整经验，包括架构设计、踩坑记录和最佳实践。

## 架构设计

### 三层翻译架构
1. **数据层**：JSON配置文件中的字段值存储翻译键（如 `TOWER_CHINESE_BASIC_NAME`）
2. **Bean层**：配置类提供 `get_display_name()` 方法，返回 `tr(field_value)`
3. **CSV层**：`locale/translations.csv` 存储所有翻译键的多语言映射

### 翻译流程
```
JSON字段值(翻译键) → Bean.get_display_name() → tr(翻译键) → TranslationServer查表 → 当前语言文本
```

## 关键实现

### 1. CSV格式
```csv
key,zh,en
TOWER_CHINESE_BASIC_NAME,语文之塔,Chinese Basics Tower
ATTR_FORMAT,%s：%d,%s: %d
```

### 2. Bean层模式
```gdscript
class_name TowerBean
var tower_name: String = ""

func get_display_name() -> String:
    return tr(tower_name)
```

### 3. config_tool.py双向转换
- 导出：翻译键→中文（带批注标记原始键）
- 导入：中文→翻译键（反向映射）

## 常见陷阱

| 陷阱 | 严重性 | 详见 |
|------|--------|------|
| CSV en列为空 | 🔴高 | [坑1](../../base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md) |
| 重复代码遗漏 | 🔴高 | [坑2](../../base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md) |
| 格式串截断 | 🔴高 | [坑3](../../base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md) |
| 翻译键重复 | 🟡中 | [坑4](../../base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md) |
| 缓存不热重载 | 🟡中 | [坑5](../../base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md) |

## 验证清单

- [ ] 所有JSON字段值已替换为翻译键
- [ ] 所有Bean类提供get_display_name()
- [ ] 所有UI代码使用tr()而非硬编码
- [ ] CSV中en列100%填充
- [ ] 无语义重复的翻译键
- [ ] 英文模式下无残留中文
- [ ] 格式串参数数量中英文一致
