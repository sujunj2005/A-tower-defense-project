# Base 层 - 信号与事件系统

**位置**: `knowledge_base/base/signals-events/`

**最后更新**: 2026-04-07  
**Godot 版本**: 4.x  
**文档数**: 1 份

---

## 📂 目录内容

本目录包含 Godot 4.x 信号系统的原始文档：

| 文档 | 描述 | 来源 | 行数 | 重要性 |
|------|------|------|------|--------|
| [03A_Signals_Detailed.md](./03A_Signals_Detailed.md) | Godot 4.x 信号系统详解 | `gdscript_basics.rst`, `instancing_with_signals.rst` | ~310 行 | 🔴 必读 |

---

## 📋 文档内容概览

### 03A_Signals_Detailed.md - 信号系统详解

**内容结构**:

1. **信号概述** (第 19-34 行)
   - 什么是信号（观察者模式实现）
   - 信号的优势（解耦/灵活/安全）

2. **定义信号** (第 36-60 行)
   - 使用 signal 关键字
   - 信号命名规范（过去时命名）

3. **发射信号** (第 63-91 行)
   - 使用 emit() 方法
   - emit 语法（无参数/带参数）

4. **连接信号** (第 93-140 行)
   - 在编辑器中连接
   - 在代码中连接（Callable 方式）
   - 连接选项（ONE_SHOT/DEFERRED/REFERENCE_COUNTED）
   - 绑定额外参数（.bind()）

5. **断开信号** (第 142-161 行)
   - 使用 disconnect()
   - 检查连接状态（is_connected()）

6. **带参数的信号** (第 163-185 行)
   - 定义和发射
   - 接收参数

7. **信号解耦实践** (第 187-244 行)
   - 问题：直接引用父节点
   - 解决方案：使用信号
   - 信号解耦的优势对比表

8. **内置信号** (第 247-279 行)
   - 常用节点信号表格
   - 使用内置信号示例

9. **await 关键字** (第 281-307 行)
   - 等待信号
   - 协程示例
   - 踩坑点提示

**核心知识点**:
- 信号是 Godot 的观察者模式实现
- 使用 signal 关键字定义信号
- 使用 emit() 发射信号
- 使用 connect() 连接信号
- 使用 disconnect() 断开信号
- await 关键字可以等待信号

**来源文件**:
- `godot-docs-master/tutorials/scripting/gdscript/gdscript_basics.rst`
- `godot-docs-master/tutorials/scripting/instancing_with_signals.rst`

---

## 🔗 Wiki 层映射

基于本文档创建的 Wiki 层页面：

| Wiki 页面 | 类型 | 描述 |
|-----------|------|------|
| [signals-events.md](../../wiki/concepts/signals-events.md) | 概念页面 | 信号系统核心概念摘要 |
| [signals-best-practices.md](../../wiki/guides/signals-best-practices.md) | 指南页面 | 信号最佳实践指南 |

---

## 📊 统计信息

- **文档总数**: 1 份
- **总行数**: ~310 行
- **字数估算**: ~8,000+
- **代码示例**: 20+ 个
- **表格**: 2 个

---

## 🎯 学习建议

### 新手路径
```
1. 先阅读 Wiki 层的 [信号系统概念](../../wiki/concepts/signals-events.md)
   ↓
2. 学习 [信号最佳实践指南](../../wiki/guides/signals-best-practices.md)
   ↓
3. 回到 Base 层阅读完整的 [03A_Signals_Detailed.md](./03A_Signals_Detailed.md)
```

### 进阶路径
```
1. 直接阅读 [03A_Signals_Detailed.md](./03A_Signals_Detailed.md) 完整文档
   ↓
2. 参考 Wiki 层的交叉引用页面
   ↓
3. 在实际项目中应用信号解耦技术
```

---

## 📝 更新记录

### 2026-04-07
- 创建 `base/signals-events/` 目录
- 复制原始文档 `03A_Signals_Detailed.md` 到 Base 层
- 创建本 README.md 索引文件
- 创建 Wiki 层映射页面（概念页面 + 指南页面）

---

## 🔗 相关链接

- **Wiki 概念页面**: [../../wiki/concepts/signals-events.md](../../wiki/concepts/signals-events.md)
- **Wiki 指南页面**: [../../wiki/guides/signals-best-practices.md](../../wiki/guides/signals-best-practices.md)
- **Base 层首页**: [../README.md](../README.md)
- **Architecture 索引**: [../../architecture/index.md](../../architecture/index.md)

---

**维护者**: Knowledge Base Administrator  
**文档版本**: 1.0
