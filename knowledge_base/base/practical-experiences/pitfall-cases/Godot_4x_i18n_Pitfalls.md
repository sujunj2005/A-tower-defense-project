# Godot 4.x 国际化(i18n)踩坑记录

## 坑1：CSV翻译文件en列为空导致tr()回退中文 [🔴高]

### 问题描述
切换语言到英文后，UI上仍显示中文文本。代码已正确使用tr()包装，但翻译不生效。

### 根因分析
Godot的TranslationServer在加载CSV翻译文件时，如果某行的en列为空，tr()会回退到zh列的值（中文）。这意味着**代码层tr()包装是必要但不充分的——CSV必须实际填充目标语言的翻译值**。

### 错误示例
```csv
key,zh,en
TOWER_CHINESE_BASIC_NAME,语文之塔,
```
tr("TOWER_CHINESE_BASIC_NAME") 在英文模式下返回 "语文之塔" 而非空字符串。

### 解决方案
1. 编写脚本批量检查CSV中en列为空的键
2. 为所有空en列填充英文翻译
3. 验证：`Total keys: 770, Has English: 770`

### 预防措施
- 每次添加新翻译键时，必须同时填写zh和en两列
- 在CI/CD中添加CSV完整性检查脚本

---

## 坑2：重复代码导致i18n改造遗漏 [🔴高]

### 问题描述
event_ui.gd的_format_requirements()已改为tr()调用，但切换英文后事件条件仍显示中文（"智力≥40"、"非农民家庭"）。

### 根因分析
存在两份功能相同的代码：event_ui.gd的_format_requirements()和option_system.gd的format_requirements()。UI层优先调用OptionSystem单例的方法，而OptionSystem中的方法仍是硬编码中文，未做i18n改造。

### 错误模式
```
event_ui.gd:
  if os and os.has_method("format_requirements"):
    req_text = os.format_requirements(...)  # ← 实际走这条路径
  else:
    req_text = _format_requirements(...)     # ← 只改了这条fallback
```

### 解决方案
1. 全局搜索同名/同功能函数，确保所有副本都做i18n改造
2. 删除冗余副本，统一使用单例方法
3. 搜索策略：`func format_requirements`、`func _format_requirements`

### 预防措施
- 遵循DRY原则，格式化逻辑只在一个地方实现
- 新增i18n改造时，用全局搜索确认所有调用路径

---

## 坑3：CSV格式串截断导致运行时错误 [🔴高]

### 问题描述
target_info_panel.gd报错：`String formatting error: not all arguments converted during string formatting`

### 根因分析
CSV中ENEMY_SLOWED和ENEMY_DOT的英文翻译被截断，缺少右括号和第二个参数占位符：
```csv
ENEMY_SLOWED,🐌 减速中（-%.0f%%，%.1fs）,🐌 Slowed (-%.0f%%     ← 截断！缺 , %.1fs)
ENEMY_DOT,🔥 持续伤害（%.1f/s，%.1fs）,🔥 DoT (%.1f/s            ← 截断！缺 , %.1fs)
```
代码中 `tr("ENEMY_SLOWED") % [slow_amount, slow_timer]` 传了2个参数，但格式串只有1个占位符。

### 解决方案
确保CSV中格式串的参数占位符数量与代码中的参数数量完全匹配：
```csv
ENEMY_SLOWED,🐌 减速中（-%.0f%%，%.1fs）,🐌 Slowed (-%.0f%%, %.1fs)
ENEMY_DOT,🔥 持续伤害（%.1f/s，%.1fs）,🔥 DoT (%.1f/s, %.1fs)
```

### 预防措施
- 添加翻译键时，格式串必须完整复制所有参数占位符
- 对含%格式符的翻译键，添加后立即用代码验证参数数量匹配

---

## 坑4：翻译键命名不一致导致重复 [🟡中]

### 问题描述
CSV中出现语义相同的重复翻译键：
- STAGE_CHILDHOOD vs STAGE_CHILDHOOD_NAME
- AGE_PLUS_1 vs AGE_PLUS_ONE
- SEPARATOR_DUN vs TOWERS_SEPARATOR

### 根因分析
不同开发阶段添加翻译键时，未遵循统一命名规范，导致同一含义用不同键名。

### 解决方案
1. 统一命名规范：`{CATEGORY}_{ENTITY_ID}_{FIELD}`
2. 添加前先搜索是否已存在语义相同的键
3. 删除冗余键，统一代码引用

### 命名规范示例
| 类别 | 格式 | 示例 |
|------|------|------|
| 防御塔名 | TOWER_{ID}_NAME | TOWER_CHINESE_BASIC_NAME |
| 敌人名 | ENEMY_{ID}_NAME | ENEMY_HOMEWORK_NAME |
| 阶段名 | STAGE_{ID}_NAME | STAGE_CHILDHOOD_NAME |
| 事件名 | EVENT_{ID}_NAME | EVENT_MATH_CONTEST_NAME |
| 选项文本 | OPTION_{EVENT}_{LETTER}_TEXT | OPTION_MATH_CONTEST_A_TEXT |
| 词条名 | TRAIT_{ID}_NAME | TRAIT_LITTLE_SINGER_NAME |
| 属性名 | ATTR_{ID}_DISPLAY_NAME | ATTR_INTELLIGENCE_DISPLAY_NAME |
| UI按钮 | BTN_{ACTION} | BTN_SUMMON |
| 格式串 | {CONTEXT}_FORMAT | ATTR_FORMAT |

---

## 坑5：Godot TranslationServer缓存不热重载 [🟡中]

### 问题描述
修改CSV文件后，游戏运行中翻译不更新，仍显示旧值。

### 根因分析
Godot的TranslationServer在项目启动时加载CSV并缓存。外部修改CSV文件不会自动更新内存中的翻译表。rescan_filesystem只更新文件索引，不重新加载翻译。

### 解决方案
修改CSV后必须**重启Godot编辑器**（不仅是重新运行场景）才能使翻译生效。

### 预防措施
- 批量修改CSV后，先停止场景再重启编辑器
- 开发期间可考虑用TranslationServer.add_translation()动态加载

---

## 坑6：_process中引用已释放对象导致崩溃 [🔴高]

### 问题描述
tower_select_ui.gd报错：`Attempt to call function 'add_theme_stylebox_override' in base 'previously freed' on a null instance`

### 根因分析
_process中遍历flashing_buttons字典时，按钮可能已被queue_free()释放，但字典仍持有对它的引用。

### 解决方案
```gdscript
for button in flashing_buttons.keys():
    if not is_instance_valid(button):
        to_remove.append(button)
        continue
    # ... 正常处理
```

### 预防措施
- _process/_physics_process中引用可能被释放的对象时，必须先检查is_instance_valid()
- queue_free()后及时清理相关引用（字典、数组等）
