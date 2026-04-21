# 实战经验汇编（Base 层）

> **说明**: 本目录收录来自实际项目开发中的第一手经验资料，包括踩坑记录、代码规范、案例研究和优化技巧。

---

## 📂 目录结构

```
practical-experiences/
├── pitfall-cases/        # 踩坑案例
├── code-standards/       # 代码规范
├── case-studies/         # 案例研究
└── optimization-tips/    # 优化技巧
```

---

## 📦 内容说明

### 1. 踩坑案例 (pitfall-cases/)

收录实际项目中遇到的各类陷阱和解决方案：

| 文档 | 描述 | 严重性 |
|------|------|--------|
| [19_Pitfall_Records.md](./pitfall-cases/19_Pitfall_Records.md) | **23 个常见踩坑记录总览** | 🔴 必读 |
| [GDScript_Warning_Best_Practices.md](./pitfall-cases/GDScript_Warning_Best_Practices.md) | GDScript 警告处理最佳实践 | 🟡 推荐 |
| [Warning_Fix_Quick_Reference.md](./pitfall-cases/Warning_Fix_Quick_Reference.md) | 警告修复速查表 | 🟢 速查 |
| [Godot_4x_Resource_File_Comment_Issue.md](./pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md) | 资源文件注释导致加载失败 | 🔴 严重 |
| [20_TileMap_Shader_Border_Pitfall.md](./pitfall-cases/20_TileMap_Shader_Border_Pitfall.md) | TileMap Shader 边框对齐问题 | 🔴 严重 |

**核心踩坑分类：**
- GDScript 语言踩坑（整数除法、变量遮蔽等）
- 节点系统踩坑（queue_free、场景切换等）
- 物理系统踩坑（碰撞体、刚体等）
- UI 系统踩坑（容器、锚点等）
- 渲染系统踩坑（缩放、变换等）
- 资源系统踩坑（.tres 文件注释问题）

### 2. 代码规范 (code-standards/)

项目开发中形成的代码规范和标准：

| 文档 | 描述 | 适用范围 |
|------|------|---------|
| [GDScript_Code_Standards.md](./code-standards/GDScript_Code_Standards.md) | **GDScript 完整代码规范标准** ⭐⭐⭐ | 所有 GDScript 代码 |
| [20A_Godot_Large_Project_Pitfalls_Deep_Dive.md](./code-standards/20A_Godot_Large_Project_Pitfalls_Deep_Dive.md) | **大型项目深度避坑指南（完整深度版 v2.0）** 📘 | 系统学习 |
| [20B_Godot_Pitfalls_Verification_Guidelines.md](./code-standards/20B_Godot_Pitfalls_Verification_Guidelines.md) | **避坑验证准则（完整系统版 v1.0）** 📘 | 问题排查 |
| [20C_Godot_Best_Practices_Quick_Reference.md](./code-standards/20C_Godot_Best_Practices_Quick_Reference.md) | **最佳实践详细指南（详细实践版 v2.0）** 📘 | 实战参考 |

**📚 版本说明**：
- 📘 **完整版**（code-standards/）：适合系统学习和深入研究，包含完整的代码示例和详细说明
- 📙 **精简版**（best-practices/）：适合快速查阅核心要点，精简版内容请查看 [best-practices 目录](../best-practices/)

**核心规范内容：**
- 编码原则（警告处理、代码质量）
- 命名规范（变量、函数、常量）
- 变量与常量（整数除法、类型声明）
- 函数规范（参数命名、返回值处理）
- 枚举处理（版本兼容性）
- 资源管理（preload、load、UID）
- 调试输出（日志分级）
- 错误与日志处理
- 测试规范
- 代码审查清单
- 资源文件规范

### 3. 案例研究 (case-studies/)

完整的项目案例研究和架构设计文档：

| 文档 | 描述 | 项目来源 |
|------|------|---------|
| [14_Tower_Defense_Case_Study.md](./case-studies/14_Tower_Defense_Case_Study.md) | **塔防游戏完整案例研究** ⭐⭐⭐ | tower_defense 项目 |

**核心章节：**
1. 项目架构概览（目录结构、Autoload 单例）
2. 数据模型架构（BaseModel 模式）
3. 加密存档系统
4. 异步场景加载管理器
5. 配置管理器（ConfigFile）
6. Camera2D 完整控制器
7. 建造系统：弹出面板与类型匹配
8. 角色继承体系（攻击/受击分离）
9. 动态脚本挂载（运行时 set_script）
10. 节点组（Group）在地图设计中的应用
11. 自定义 Tooltip 实现
12. 项目踩坑记录与最佳实践

### 4. 优化技巧 (optimization-tips/)

性能优化相关的实战经验和技巧：

| 文档 | 描述 | 优化方向 |
|------|------|---------|
| [14A_General_Optimization.md](./optimization-tips/14A_General_Optimization.md) | 性能优化通用指南 | 方法论 + 测量 |
| [14B_CPU_Optimization.md](./optimization-tips/14B_CPU_Optimization.md) | CPU 优化实战 | 脚本/物理/AI |
| [14C_GPU_Optimization.md](./optimization-tips/14C_GPU_Optimization.md) | GPU 优化实战 | 渲染/着色器 |

**核心优化技术：**
- 对象池（预创建对象复用）
- 缓存节点引用（@onready）
- 类型化数组（减少类型检查）
- 减少每帧计算（信号/定时器）
- 空间划分（四叉树/网格）
- 减少 Draw Call（Instancing/合并图集）
- LOD 细节层次
- 遮挡剔除
- 灯光精简
- 透明度优化
- 分辨率缩放
- 后期处理精简

---

## 🎯 使用建议

### 新手开发者
1. 先阅读 [code-standards/GDScript_Code_Standards.md](./code-standards/GDScript_Code_Standards.md) 了解代码规范
2. 查看 [pitfall-cases/19_Pitfall_Records.md](./pitfall-cases/19_Pitfall_Records.md) 避免常见错误
3. 参考 [case-studies/14_Tower_Defense_Case_Study.md](./case-studies/14_Tower_Defense_Case_Study.md) 学习完整架构

### 有经验开发者
1. 遇到性能问题时查阅 [optimization-tips/](./optimization-tips/) 系列文档
2. 代码审查时使用 [code-standards/GDScript_Code_Standards.md](./code-standards/GDScript_Code_Standards.md) 作为检查清单
3. 参考 [case-studies/](./case-studies/) 中的架构设计模式

### 问题排查
1. 遇到警告 → 查看 [pitfall-cases/GDScript_Warning_Best_Practices.md](./pitfall-cases/GDScript_Warning_Best_Practices.md)
2. 遇到 bug → 查看 [pitfall-cases/19_Pitfall_Records.md](./pitfall-cases/19_Pitfall_Records.md)
3. 性能问题 → 查看 [optimization-tips/](./optimization-tips/) 系列

---

## 📊 统计信息

| 分类 | 文档数 | 字数估算 | 重要性 |
|------|--------|---------|--------|
| 踩坑案例 | 5 | 30,000+ | 🔴 必读 |
| 代码规范 | 1 | 25,000+ | 🔴 必读 |
| 案例研究 | 1 | 40,000+ | ⭐⭐⭐ 推荐 |
| 优化技巧 | 3 | 35,000+ | ⭐⭐ 参考 |
| **总计** | **10** | **130,000+** | - |

---

## 🔄 更新策略

- **踩坑案例**: 遇到新问题时及时记录和更新
- **代码规范**: 项目迭代中持续完善
- **案例研究**: 完成新项目后补充
- **优化技巧**: 性能优化实践后总结

---

## 🔗 相关资源

- **Wiki 层**: [../../wiki/](../../wiki/) - 经过整理和提炼的结构化知识
- **Architecture 层**: [../../architecture/](../../architecture/) - 完整的知识索引和日志
- **Godot 官方文档**: [../godot-official-docs/](../godot-official-docs/) - 官方原始资料

---

**最后更新**: 2026-04-07  
**资料来源**: tower_defense 项目实战经验
