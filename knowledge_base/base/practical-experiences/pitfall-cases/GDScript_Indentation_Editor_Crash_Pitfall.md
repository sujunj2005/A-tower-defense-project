# GDScript 缩进错误导致 Godot 编辑器崩溃

> **严重级别**: 🔴 强制（最高级别，必须100%严格遵守）
> **发现日期**: 2026-04-20
> **影响范围**: 所有使用 AI 辅助工具（mcp_godot_edit_script / SearchReplace）编辑 GDScript 文件的场景
> **后果**: Godot 编辑器直接崩溃

---

## 问题描述

在使用 `mcp_godot_edit_script`（手术式文本替换工具）编辑 GDScript 文件时，因缩进（tab）层级错误，导致 `file.close()` 被放在 `while` 循环内部而非外部。第一次循环就关闭文件，第二次循环读取已关闭文件，直接导致 Godot 编辑器崩溃。

---

## 根因分析

### 1. GDScript 是缩进敏感语言

GDScript 与 Python 相同，使用缩进（tab 或空格）来定义代码块的逻辑层级。缩进即逻辑，一个 tab 的差异就是"在循环内"还是"在循环外"的区别。

```gdscript
# 缩进差一个 tab，逻辑完全不同
while condition:
    do_something()
    file.close()  # 在循环内：每次循环都关闭

while condition:
    do_something()
file.close()  # 在循环外：循环结束后才关闭
```

### 2. 纯文本替换工具不理解语法结构

`mcp_godot_edit_script` 和 `SearchReplace` 是纯文本替换工具，它们：
- 只机械匹配和替换字符串
- 不理解 GDScript 的语法结构
- 不会校验缩进层级是否正确
- 不会警告缩进不一致

### 3. 人脑数 tab 极易出错

在构造 `new_snippet` 时靠人脑数 tab 来确定缩进层级：
- 嵌套深时（3层以上）极易出错
- 上下文切换时容易遗漏层级
- 没有可视化辅助，纯靠心算

### 4. 缺少读回验证步骤

编辑后没有读回文件验证缩进是否正确，直接运行游戏导致崩溃。如果先读回验证，问题可以在运行前被发现。

---

## 实际案例

### 基本信息

- **文件**: `autoload/i18n_manager.gd`
- **错误**: `file.close()` 多了一个 tab 缩进，从 `while` 循环外滑入循环内
- **后果**: Godot 编辑器直接崩溃
- **修复**: 将 `file.close()` 缩进从循环内移到循环外（与 `while` 同级）

### 错误代码

```gdscript
func _load_translations() -> void:
    var file: FileAccess = FileAccess.open(translation_path, FileAccess.READ)
    if file == null:
        return

    while not file.eof_reached():
        var line: String = file.get_line()
        if line.is_empty() or line.begins_with("#"):
            continue
        var parts: PackedStringArray = line.split(",")
        if parts.size() >= 2:
            _translations[parts[0]] = parts[1]
        file.close()  # ❌ 错误：在 while 循环内部！第一次循环就关闭文件
```

### 正确代码

```gdscript
func _load_translations() -> void:
    var file: FileAccess = FileAccess.open(translation_path, FileAccess.READ)
    if file == null:
        return

    while not file.eof_reached():
        var line: String = file.get_line()
        if line.is_empty() or line.begins_with("#"):
            continue
        var parts: PackedStringArray = line.split(",")
        if parts.size() >= 2:
            _translations[parts[0]] = parts[1]
    file.close()  # ✅ 正确：与 while 同级，循环结束后才关闭
```

### 崩溃机制

1. 第一次循环：正常读取第一行数据，然后 `file.close()` 关闭文件
2. 第二次循环：`file.eof_reached()` 检查已关闭的文件句柄
3. Godot 引擎访问已释放的文件资源 -> 编辑器崩溃

---

## 必须遵守的规则

### 规则 1: 编辑后必须读回验证缩进 [🔴强制]

每次用 `edit_script` 或 `SearchReplace` 修改 GDScript 文件后，**必须立即 Read 文件确认缩进正确**，然后才能运行测试。

### 规则 2: 大段新增代码优先用 Write 工具 [🔴强制]

对于大段新增代码（如整个新方法），优先用 `Write` 工具写完整文件，而非片段替换。Write 工具可以保证整体缩进的一致性。

### 规则 3: 片段替换前必须先 Read 确认上下文缩进 [🔴强制]

如果用片段替换，先 Read 原文件确认上下文的精确缩进，再构造替换内容。特别注意：
- 确认替换位置所在函数的缩进层级
- 确认循环/条件语句的嵌套深度
- 逐行对比 tab 层级

### 规则 4: 编辑工作流必须三步走 [🔴强制]

编辑流程必须是：**编辑 -> 读回验证 -> 运行测试**，绝不能跳过读回验证步骤。

```
标准流程（不可跳过任何步骤）：
1. Read 原文件 -> 确认上下文精确缩进
2. 构造替换内容 -> 逐行对比 tab 层级
3. 执行替换（edit_script / SearchReplace）
4. Read 修改后的文件 -> 验证缩进正确
5. 运行测试 -> 确认功能正常
```

---

## 关联文档

- [踩坑记录完整索引 §65](../../踩坑记录完整索引.md#65-gdscript-缩进错误导致-godot-编辑器崩溃-🔴-高)
- [Godot 编码规范汇总 - 第19章 GDScript编辑工作流规范](../../Godot%20编码规范汇总.md#19-gdscript编辑工作流规范)
