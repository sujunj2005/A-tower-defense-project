# P10：validate_script 返回 error_code 43 不等于有实际错误

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | GDScript/调试 |
| **严重程度** | 🟡 中 |
| **涉及文件** | 技能系统脚本（`scripts/bean/skill/` 相关） |
| **知识库关联** | [运行时安全实践](../best-practices/运行时安全实践.md) / [GUT 测试框架 API 陷阱（§30）](../../../wiki/guides/common-pitfalls.md#30-gut-测试框架-api-陷阱) |

---

## 现象

使用 Godot MCP 的 `validate_script` 验证脚本时，返回：

```
valid=false, error_code=43
```

但随后调用 `get_errors` 却返回 0 个错误。这使得判断脚本是否真正有问题变得困难——error_code 说有问题，但实际上没有语法错误。

## 根因

`error_code` 43 的含义是：

> **Script parsed but cannot be instantiated (may have dependency errors)**

即脚本语法解析通过，但由于依赖的类/资源尚未加载完成，当前无法实例化。这在以下情况下是正常的：

- Godot 编辑器尚未完全加载场景依赖
- 脚本引用了其他 `class_name` 类，但该类尚未完成注册
- 脚本是 `@tool` 但编辑器尚未初始化完整

## 正确做法

**优先以 `get_errors` 的结果为准**。`validate_script` 的 non-zero error_code **不等于**脚本有语法错误。

完整的验证流程：

```
1. 清空 console log → 避免旧错误干扰
2. rescan_filesystem → 确保文件系统最新
3. get_errors 检查 → 获取实际错误信息
4. 如果 get_errors 返回 0 错误 → 脚本通过验证
5. 如果 get_errors 有内容 → 逐一分析错误
```

### Godot MCP 交互示例

```python
# 正确的脚本验证流程
# 1. 清空日志
mcp.invoke("clear_console")

# 2. 重新扫描
mcp.invoke("rescan_filesystem")

# 3. 验证脚本
result = mcp.invoke("validate_script", path="res://scripts/bean/skill/skill_bean.gd")
# result.error_code 可能是 43，先不要 panic

# 4. 获取实际错误
errors = mcp.invoke("get_errors")
# 如果 errors 为空或 count=0 → 脚本没有问题
```

## 常见 error_code 对照表

| error_code | 含义 | 是否严重 |
|------------|------|----------|
| 0 | 脚本完全有效 | ✅ 通过 |
| 43 | 解析通过但无法实例化（依赖未就绪） | ⚠️ 通常正常 |
| 其他非零值 | 语法/解析错误 | ❌ 需要修复 |

## 教训

不要只根据 `validate_script` 的返回值判断脚本好坏。error_code 43 是 Godot 编辑器环境特有的状态，不等于脚本有语法错误。正确做法是先看 `get_errors` 的实际错误内容。

---

*记录时间：2026-04-29*