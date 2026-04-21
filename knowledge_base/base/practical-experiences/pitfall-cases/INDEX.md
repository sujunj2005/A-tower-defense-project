# 19_Common_Pitfalls 索引

> **最后更新**: 2026-04-14
> **适用版本**: Godot 4.x
> **文档数**: 11

---

## 📂 文件列表

| 文件名 | 描述 | 重要性 |
|--------|------|--------|
| [19_Pitfall_Records.md](./19_Pitfall_Records.md) | **常见踩坑记录总览** ⭐⭐⭐ | 必读 |
| [GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md) | GDScript 警告处理最佳实践 | 推荐 |
| [Warning_Fix_Quick_Reference.md](./Warning_Fix_Quick_Reference.md) | 警告修复快速参考 | 速查 |
| [Godot_4x_Resource_File_Comment_Issue.md](./Godot_4x_Resource_File_Comment_Issue.md) | 资源文件注释问题 🆕 | 推荐 |
| [20_TileMap_Shader_Border_Pitfall.md](./20_TileMap_Shader_Border_Pitfall.md) | TileMap Shader 边框对齐问题 🆕 | 推荐 |
| [Godot_4x_Window_Size_Detection_Issue.md](./Godot_4x_Window_Size_Detection_Issue.md) | 窗口尺寸检测问题 🆕 | 推荐 |
| [GDScript_Setter_Getter_Dual_State_Pitfall.md](./GDScript_Setter_Getter_Dual_State_Pitfall.md) | 内嵌 get/set 双重状态踩坑（§26）🆕 | 推荐 |
| [Godot_4x_Autoload_Pitfalls.md](./Godot_4x_Autoload_Pitfalls.md) | Autoload 单例踩坑（§27-§31）🆕 | 推荐 |
| [GUT_Testing_Pitfalls.md](./GUT_Testing_Pitfalls.md) | GUT 测试框架踩坑（§32-§36）🆕 | 推荐 |
| [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](./Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md) | 资源引用与数据一致性踩坑（§37-§39）🆕 | 推荐 |
| [Godot_4x_Game_System_Pitfalls.md](./Godot_4x_Game_System_Pitfalls.md) | 游戏系统实战踩坑（§40-§58）🆕 | 推荐 |

---

## 📋 踩坑章节总览

### 1️⃣ GDScript 踩坑（§1-§5）

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §1 | 整数除法 | 🟡 中 |
| §2 | Lambda 变量捕获 | 🟢 低 |
| §3 | 类型数组赋值 | 🟡 中 |
| §4 | @export 在 _init() 中读取 | 🟡 中 |
| §5 | 静态变量与 @export/@onready | 🟡 中 |

### 2️⃣ 节点系统踩坑（§6-§10）

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §6 | queue_free vs free | 🔴 高 |
| §7 | 场景切换时删除当前场景 | 🔴 高 |
| §8 | add_child 后 _ready() 未调用 | 🟡 中 |
| §9 | 循环引用 preload | 🟡 中 |
| §10 | get_node 使用节点名称而非类型 | 🟢 低 |

### 3️⃣ 物理系统踩坑（§11-§15）

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §11 | move_and_slide 已包含 delta | 🟡 中 |
| §12 | RigidBody 直接设置位置 | 🟡 中 |
| §13 | CollisionShape Scale 必须保持 (1,1) | 🟡 中 |
| §14 | 物理代码必须在 _physics_process | 🟡 中 |
| §15 | is_on_floor() 只在 move_and_slide 后有效 | 🟡 中 |

### 4️⃣ UI 系统踩坑（§16-§18）

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §16 | Control.mouse_filter | 🟢 低 |
| §17 | 容器内子节点位置被覆盖 | 🟡 中 |
| §18 | 锚点预设后手动偏移 | 🟢 低 |

### 5️⃣ 渲染系统踩坑（§19-§22）

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §19 | screen_get_scale 平台限制 | 🟡 中 |
| §20 | Vector2/Vector3 内部使用 float32 | 🟢 低 |
| §21 | 3D 旋转避免欧拉角 | 🟡 中 |
| §22 | Transform2D 乘法顺序 | 🟡 中 |

### 6️⃣ 资源系统踩坑（§23）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §23 | .tres 文件中的注释导致字段加载失败 | 🔴 高 |

**详细说明**：[Godot_4x_Resource_File_Comment_Issue.md](./Godot_4x_Resource_File_Comment_Issue.md)

### 7️⃣ TileMap 系统踩坑（§24）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §24 | TileMap Shader 边框对齐问题 | 🔴 高 |

**详细说明**：[20_TileMap_Shader_Border_Pitfall.md](./20_TileMap_Shader_Border_Pitfall.md)

### 8️⃣ 其他踩坑（§25-§26）

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §25 | 窗口尺寸检测问题 | 🟡 中 |
| §26 | 内嵌 get/set 创建双重状态 | 🔴 高 |

**详细说明**：[Godot_4x_Window_Size_Detection_Issue.md](./Godot_4x_Window_Size_Detection_Issue.md)

### 9️⃣ Autoload 单例踩坑（§27-§28）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §27 | Autoload 脚本禁止 class_name 声明 | 🔴 高 |
| §28 | Autoload 单例间互访不能用 Global.get_node() | 🔴 高 |

**详细说明**：[Godot_4x_Autoload_Pitfalls.md](./Godot_4x_Autoload_Pitfalls.md)

### 1️⃣1️⃣ GUT 测试框架踩坑（§32-§36）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §32 | GUT 测试运行器模式导致框架挂起 | 🔴 高 |
| §33 | before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起 | 🔴 高 |
| §34 | watch_signals() 在 Autoload 实例上导致 GUT 挂起 | 🔴 高 |
| §35 | 测试中引用了不存在的类属性 | 🟡 中 |
| §36 | select_option() 第二个参数类型错误 | 🟡 中 |

**详细说明**：[GUT_Testing_Pitfalls.md](./GUT_Testing_Pitfalls.md)

### 🔟 GDScript 语言与工具踩坑（§29-§31）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §29 | trait 是 GDScript 4.x 保留关键字 | 🟡 中 |
| §30 | GUT 测试框架 API 陷阱 | 🟡 中 |
| §31 | := 类型推断限制与 .godot 缓存问题 | 🟡 中 |

**详细说明**：[Godot_4x_Autoload_Pitfalls.md](./Godot_4x_Autoload_Pitfalls.md)

### 1️⃣2️⃣ 资源引用与数据一致性踩坑（§37-§39）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §37 | .tres 文件 ext_resource 引用已删除文件导致整体加载失败 | 🔴 高 |
| §38 | 数据格式不一致导致条件判断永远失败 | 🟡 中 |
| §39 | 修改数据格式时遗漏配置文件消费者 | 🟡 中 |

**详细说明**：[Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](./Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md)

### 1️⃣3️⃣ 游戏系统实战踩坑（§40-§58）🆕

| 编号 | 问题 | 严重性 |
|------|------|--------|
| §40 | Tooltip遮挡触发元素导致闪烁循环 | 🟡 中 |
| §41 | 场景切换绕过导致UI不更新 | 🔴 高 |
| §42 | 分裂/召唤敌人未被计入存活数 | 🟡 中 |
| §43 | 字典中保留已释放节点引用导致freed instance报错 | 🔴 高 |
| §44 | 击退效果与路径移动冲突 | 🟡 中 |
| §45 | 事件/战斗奖励重复显示 | 🟡 中 |
| §46 | 词条效果字段名不一致 | 🟡 中 |
| §47 | UI计数显示语义错误 | 🟡 中 |
| §48 | 变量命名与GDScript内置标识符冲突 | 🟡 中 |
| §49 | 已满的塔从UI消失而非变灰 | 🟡 中 |
| §50 | 调试误判——在正确的逻辑上反复修改 | 🟢 低 |
| §51 | 节点被移出场景树后调用get_node_or_null报错 | 🔴 高 |
| §52 | 以freed对象为key的Dictionary遍历崩溃 | 🔴 高 |
| §53 | 怪物路径偏移不能用侧向力实现 | 🟡 中 |
| §54 | 分裂/召唤怪偏移需叠加父怪偏移 | 🟡 中 |
| §55 | 怪出生时current_path_index应从1开始 | 🟡 中 |
| §56 | 实际生成路径可能与预期不同 | 🟡 中 |
| §57 | Dictionary.has()对null值返回true | 🟡 中 |
| §58 | 老年阶段不应无条件触发终局 | 🔴 高 |

**详细说明**：[Godot_4x_Game_System_Pitfalls.md](./Godot_4x_Game_System_Pitfalls.md)

---

## 🔍 快速查找

### 按问题查找

| 问题描述 | 章节 | 解决方案 |
|----------|------|----------|
| "除法结果不对" | §1 | 使用 `/ 2.0` 替代 `/ 2` |
| "场景切换崩溃" | §7 | 使用 `call_deferred` |
| "碰撞检测失效" | §13 | 调整 shape.size，不要修改 scale |
| "角色纹理不显示" | §23 | 移除 .tres 文件中的注释 |
| "配置值加载错误" | §23 | 移除 .tres 文件中的注释 |
| "TileMap 边框不对齐" | §24 | 使用 `MODEL_MATRIX * VERTEX` 计算世界坐标 |
| "Autoload class_name 冲突" | §27 | 移除 Autoload 脚本的 class_name |
| "Autoload 互访问报错" | §28 | 直接使用 Autoload 注册名称访问 |
| "trait 保留关键字报错" | §29 | 使用 trait_item 等替代命名 |
| "GUT 测试 API 不存在" | §30 | 使用 GUT v9.6.0+ 正确 API |
| ":= 类型推断失败" | §31 | 显式类型声明，删除 .godot 缓存 |
| "GUT 测试运行器挂起" | §32 | 使用 GutConfig + run_tests() 模式 |
| "Autoload 引用替换挂起" | §33 | 不替换 Autoload 引用对象本身 |
| "watch_signals Autoload 挂起" | §34 | 禁止对 Autoload 使用 watch_signals |
| "测试引用不存在属性" | §35 | 编写测试前先读取被测类源码 |
| "select_option 参数类型错误" | §36 | 传入完整选项 Dictionary |
| ".tres 加载失败（引用已删文件）" | §37 | 删除 .tres 前清理所有 ext_resource |
| "条件判断永远失败（数据格式不一致）" | §38 | 数据格式在源头统一 |
| "成就匹配失败（遗漏配置文件）" | §39 | 修改数据格式时同步更新 JSON |
| "节点移出场景树后get_node_or_null报错" | §51 | 场景切换调用后检查is_inside_tree() |
| "以freed对象为key的Dictionary遍历崩溃" | §52 | 用Array[Dictionary]替代对象key |
| "路径偏移不能用侧向力实现" | §53 | set_path时一次性偏移所有路径点 |
| "分裂/召唤怪偏移需叠加父怪偏移" | §54 | 子怪偏移=父怪偏移+自身随机偏移 |
| "怪出生时current_path_index应从1开始" | §55 | current_path_index=1，跳过出生点 |
| "实际生成路径可能与预期不同" | §56 | 修改前用Grep确认实际调用路径 |
| "Dictionary.has()对null值返回true" | §57 | 用.get() is ExpectedType判断 |
| "老年阶段不应无条件触发终局" | §58 | 终局只在health<=0或用户选择时触发 |

### 按严重性查找

#### 🔴 高严重性

- §6: queue_free vs free
- §7: 场景切换时删除当前场景
- §23: .tres 文件注释导致加载失败
- §24: TileMap Shader 边框对齐问题
- §26: 内嵌 get/set 创建双重状态
- §27: Autoload 脚本禁止 class_name 声明
- §28: Autoload 单例间互访不能用 Global.get_node()
- §32: GUT 测试运行器模式导致框架挂起
- §33: before_each/after_each 修改 Autoload 全局引用导致 GUT 挂起
- §34: watch_signals() 在 Autoload 实例上导致 GUT 挂起
- §37: .tres 文件 ext_resource 引用已删除文件导致整体加载失败
- §51: 节点被移出场景树后调用get_node_or_null报错
- §52: 以freed对象为key的Dictionary遍历崩溃
- §58: 老年阶段不应无条件触发终局

#### 🟡 中严重性

- §1, §3-§5, §8-§15, §17, §19, §21-§22, §25, §29-§31, §35-§36, §38-§39, §53-§57

#### 🟢 低严重性

- §2, §10, §16, §18, §20

---

## 📚 相关文档

### 本项目知识库

- **[GDScript_Code_Standards.md](../code-standards/GDScript_Code_Standards.md)** - GDScript 代码规范标准 ⭐⭐⭐
- **[GDScript_Warning_Best_Practices.md](./GDScript_Warning_Best_Practices.md)** - GDScript 警告处理详细指南
- **[Warning_Fix_Quick_Reference.md](./Warning_Fix_Quick_Reference.md)** - 警告修复快速参考手册
- **[Godot_4x_Resource_File_Comment_Issue.md](./Godot_4x_Resource_File_Comment_Issue.md)** - 资源文件注释问题详解 🆕
- **[20_TileMap_Shader_Border_Pitfall.md](./20_TileMap_Shader_Border_Pitfall.md)** - TileMap Shader 边框开发踩坑 🆕
- **[Godot_4x_Autoload_Pitfalls.md](./Godot_4x_Autoload_Pitfalls.md)** - Autoload 单例踩坑（§27-§31）🆕
- **[GUT_Testing_Pitfalls.md](./GUT_Testing_Pitfalls.md)** - GUT 测试框架踩坑（§32-§36）🆕
- **[Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](./Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md)** - 资源引用与数据一致性踩坑（§37-§39）🆕
- **[TileMaps.md](../../../2d-development/05G_TileMaps.md)** - TileMap 系统完整文档

### 外部资源

- [Godot 资源系统文档](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot 4.x 已知问题列表](https://github.com/godotengine/godot/issues)
- [本项目知识库：Resources](../../../core-systems/02C_Resources.md)
- [CanvasItem Shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvasitem_shader.html)
- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)

---

## 🔄 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-04-03 | 1.0 | 初始创建索引文件 |
| 2026-04-03 | 1.1 | 添加 §23 资源文件注释问题 |
| 2026-04-03 | 1.2 | 添加 §24 TileMap Shader 边框对齐问题 |
| 2026-04-09 | 1.3 | 添加 §25-§31 窗口尺寸、get/set、Autoload 单例、保留关键字、GUT 测试、类型推断踩坑 |
| 2026-04-09 | 1.4 | 添加 §32-§36 GUT 测试框架踩坑（运行器模式、Autoload 引用替换、watch_signals、字段名校验、参数类型） |
| 2026-04-11 | 1.5 | 添加 §37-§39 资源引用与数据一致性踩坑（ext_resource 引用、数据格式不一致、遗漏配置文件消费者） |
| 2026-04-14 | 1.6 | 添加 §51-§58 场景树/Dictionary/路径偏移/终局触发踩坑 |

---

## 💡 使用建议

1. **遇到问题先查索引**：使用本索引快速定位相关章节
2. **高严重性问题优先处理**：优先解决 🔴 高严重性问题
3. **结合详细文档阅读**：索引只提供快速参考，详细解决方案请查看对应文档
4. **定期复习**：建议每月复习一次踩坑记录，避免重复犯错

---

*索引版本：1.6 | 最后更新：2026-04-14*
