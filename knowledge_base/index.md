# 知识库架构索引

> **最近核对**：2026-11-27（事件、存档、地图、测试）
> **核对版本**：Godot 4.6.2
> **知识库版本**: 1.30（目录迁移整合 + 技能系统与战斗HP持久化）

## TestMCP 常用专题

| 专题 | 当前入口 |
| --- | --- |
| 测试 | [运行方式、测试基线与用例](#testing) |
| 事件 | [筛选、选项结算与事件链](#events) |
| 存档 | [存档系统实战指南](./wiki/guides/saving-games-guide.md) |
| 地图 | [地图系统踩坑记录](./outline/地图系统踩坑记录.md) · [TileMapLayer 概念与示例](./wiki/concepts/tilemaps-concept.md) |

<a name="testing"></a>

### 测试引用入口

| 要查的内容 | 引用 |
| --- | --- |
| 如何运行单脚本或全量测试 | [GUT 运行方式与收集范围](./outline/Godot%20编码规范汇总.md#test-runner) |
| 如何重置会话、观察信号 | [会话重置](./outline/Godot%20编码规范汇总.md#132-autoload-会话引用与重置) · [信号测试](./outline/Godot%20编码规范汇总.md#133-autoload-信号测试) |
| 如何引用一次运行结果 | [测试基线与计数范围](./outline/Godot%20编码规范汇总.md#test-baseline) |
| 仓库中的回归用例 | [配置交叉引用](../tests/unit/test_config_cross_reference.gd) · [事件流程](../tests/unit/test_event_system_flow.gd) · [事件系统 v2](../tests/unit/test_event_system_v2.gd) |
| 如何追溯旧挂起案例 | [GUT 历史复盘](./base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md) |

<a name="events"></a>

### 事件引用入口

| 要查的内容 | 项目结论 | 源码、配置或验证依据 |
| --- | --- | --- |
| 为什么事件未入池，或在回退时出现 | [主筛选与回退](./outline/事件系统踩坑记录.md#event-filtering) | [筛选实现](../scripts/logic/life_simulation/event_system.gd) · [回退入口](../scripts/ui/event_ui.gd) |
| 选项奖励、代价与战斗如何结算 | [选项后果](./outline/事件系统踩坑记录.md#event-outcomes) | [事件配置](../data/events.json) · [事件流程用例](../tests/unit/test_event_system_flow.gd) |
| 如何核对前置、互斥分支和可达性 | [事件链结论](./outline/事件系统踩坑记录.md#event-chain) | [配置引用校验](../tests/unit/test_config_cross_reference.gd) · [定向测试基线](./outline/Godot%20编码规范汇总.md#test-baseline) |
| 如何追溯事件字段和历史问题 | [事件系统记录全文](./outline/事件系统踩坑记录.md) | [事件数据模型](../scripts/bean/event_data.gd) · [选项与家庭历史复盘](./base/practical-experiences/pitfall-cases/Godot_4x_Event_Option_Family_Pitfalls.md) |

---

## Steam、联机和塔防资料归属

通用教程和历史案例正文由《GDScript Godot 4.x 游戏开发专项知识库》维护。项目库的入口记录 TestMCP 的接入状态、当前源码与验证记录。通用库的篇名和编号可以在各入口查到。

| 专题 | 通用库正文索引 | TestMCP 入口 |
| --- | --- | --- |
| Steam | 第 12 篇《Steam 平台对接》 | [Steam 接入状态](./wiki/guides/steam-platform-integration-guide.md) |
| 多人联机 | 第 13 篇《多人联机网络编程》 | [多人联机状态](./wiki/guides/multiplayer-networking-guide.md) |
| 塔防案例 | 第 14 篇《塔防游戏案例研究》 | [塔防战斗架构和验证](./wiki/guides/tower-defense-architecture.md) |

---

## 知识库层级

**来源 → 整理 → 项目结论**

| 层级 | 目录 | 内容 |
| --- | --- | --- |
| 来源 | [`base/`](./base/index.md) | Godot 官方文档镜像、专题基础资料和原始复盘。 |
| 整理 | [`cases/`](#26-案例库-cases)、[`wiki/`](./wiki/README.md) | 案例分析、概念、指南和主题关联。 |
| 项目结论 | [`outline/`](#3-项目结论outline) | TestMCP 的已核对约定、实现限制和验证结果。正文保留证据入口。 |

[首页](./README.md)、主索引和[关系图](./outline/relationship-map.md)负责导航。`archive/` 保存历史记录。查项目行为时优先引用对应结论小节和证据，涉及引擎或插件行为时一起记录验证版本。

---

## 1. 来源（base/）

### 1.1 Godot 官方文档

**位置**: `base/godot-official-docs/`

| 目录 | 描述 | 文件数 |
|------|------|--------|
| `getting_started/` | 入门教程 | - |
| `tutorials/` | 各类技术教程 | - |
| `classes/` | API 类参考文档 | - |
| `about/` | 项目介绍 | - |
| `community/` | 社区资源 | - |
| `engine_details/` | 引擎细节 | - |

**来源**: https://github.com/godotengine/godot-docs (master 分支)  
**大小**: ~232 MB  
**文件数**: 3,621 个

### 1.2 GDScript 语言参考

**位置**: `base/gdscript-reference/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [01A_Basics.md](./base/gdscript-reference/01A_Basics.md) | GDScript 基础语法 | 🔴 必读 |
| [01B_Types_and_Variables.md](./base/gdscript-reference/01B_Types_and_Variables.md) | 类型和变量 | 🔴 必读 |
| [01C_Functions.md](./base/gdscript-reference/01C_Functions.md) | 函数 | 🔴 必读 |
| [01D_Classes_and_Inheritance.md](./base/gdscript-reference/01D_Classes_and_Inheritance.md) | 类与继承 | 🔴 必读 |
| [01E_Static_Typing.md](./base/gdscript-reference/01E_Static_Typing.md) | 静态类型系统 | 🟡 推荐 |
| [01F_Export_Properties.md](./base/gdscript-reference/01F_Export_Properties.md) | 导出属性 | 🟡 推荐 |
| [01G_Format_Strings.md](./base/gdscript-reference/01G_Format_Strings.md) | 格式化字符串 | 🟢 参考 |
| [01H_Style_Guide.md](./base/gdscript-reference/01H_Style_Guide.md) | 代码风格指南 | 🟡 推荐 |

**来源**: Godot 官方文档  
**大小**: ~42 KB  
**文件数**: 8 份

### 1.3 Godot 核心系统

**位置**: `base/core-systems/`

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [02A_Node_Operations.md](./base/core-systems/02A_Node_Operations.md) | 节点操作与场景实例化 | `nodes_and_scene_instances.rst` | 🔴 必读 |
| [02B_Scene_Tree.md](./base/core-systems/02B_Scene_Tree.md) | 场景树系统 | `scene_tree.rst` | 🔴 必读 |
| [02C_Resources.md](./base/core-systems/02C_Resources.md) | 资源系统 | `resources.rst` | 🔴 必读 |
| [02D_Autoload_Singletons.md](./base/core-systems/02D_Autoload_Singletons.md) | 自动加载单例 | `singletons_autoload.rst` | 🔴 必读 |

**来源**: Godot 官方文档  
**大小**: ~15 KB  
**文件数**: 4 份

### 1.4 信号与事件系统

**位置**: `base/signals-events/`

| 文档 | 描述 | 来源 | 行数 | 重要性 |
|------|------|------|------|--------|
| [03A_Signals_Detailed.md](./base/signals-events/03A_Signals_Detailed.md) | Godot 4.x 信号系统详解 | `gdscript_basics.rst`, `instancing_with_signals.rst` | ~310 行 | 🔴 必读 |

**来源**: Godot 官方文档  
**大小**: ~8 KB  
**文件数**: 1 份

**核心内容**:
- 信号的定义、发射、连接、断开
- 带参数的信号处理
- 信号解耦实践
- 内置信号使用
- await 关键字

### 1.5 数学与变换

**位置**: `base/math-transforms/`

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [04A_Vector_Math.md](./base/math-transforms/04A_Vector_Math.md) | **向量数学** - 2D/3D 向量操作、点积、叉积、反射 | `vector_math.rst` | 🔴 必读 |
| [04B_Matrices_and_Transforms.md](./base/math-transforms/04B_Matrices_and_Transforms.md) | **矩阵与变换** - Transform2D/3D、缩放、旋转、平移 | `matrices_and_transforms.rst` | 🔴 必读 |
| [04C_Interpolation.md](./base/math-transforms/04C_Interpolation.md) | **插值运算** - lerp、平滑移动、帧率无关插值 | `interpolation.rst` | 🔴 必读 |
| [04E_Beziers_and_Curves.md](./base/math-transforms/04E_Beziers_and_Curves.md) | **贝塞尔曲线** - 二次/三次贝塞尔、Curve2D/3D | `beziers_and_curves.rst` | 🟡 推荐 |
| [04F_Random_Numbers.md](./base/math-transforms/04F_Random_Numbers.md) | **随机数生成** - PRNG、噪声生成、加密安全随机数 | `random_number_generation.rst` | 🟡 推荐 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/math/)  
**大小**: ~25 KB  
**文件数**: 5 份

**核心内容**:
- 向量数学（点积、叉积、归一化）
- 矩阵变换（缩放、旋转、平移）
- 插值运算（lerp、smoothstep、帧率无关）
- 贝塞尔曲线（二次/三次、Curve2D/3D）
- 随机数生成（PRNG、噪声、加密安全）

### 1.6 2D 开发

**位置**: `base/2d-development/`

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [05A_Introduction_to_2D.md](./base/2d-development/05A_Introduction_to_2D.md) | **2D 开发介绍** - 2D 工作区、坐标系、工具栏、Node2D vs Control | `introduction_to_2d.rst` | 🔴 必读 |
| [05B_2D_Movement.md](./base/2d-development/05B_2D_Movement.md) | **2D 移动模式** - 8 方向移动、旋转 + 移动、点击移动 | `2d_movement.rst` | 🔴 必读 |
| [05C_2D_Transforms.md](./base/2d-development/05C_2D_Transforms.md) | **2D 变换** - 坐标系统、Canvas 变换、视口变换、变换函数 | `2d_transforms.rst` | 🔴 必读 |
| [05D_Sprite_Animation.md](./base/2d-development/05D_Sprite_Animation.md) | **Sprite 动画** - AnimatedSprite2D、AnimationPlayer、代码控制动画 | `2d_sprite_animation.rst` | 🔴 必读 |
| [05E_2D_Lights_and_Shadows.md](./base/2d-development/05E_2D_Lights_and_Shadows.md) | **2D 光照与阴影** - PointLight2D、DirectionalLight2D、LightOccluder2D | `2d_lights_and_shadows.rst` | 🟡 推荐 |
| [05F_Particle_Systems_2D.md](./base/2d-development/05F_Particle_Systems_2D.md) | **2D 粒子系统** - GPUParticles2D、CPUParticles2D、ParticleProcessMaterial | `particle_systems_2d.rst` | 🟡 推荐 |
| [05G_TileMaps.md](./base/2d-development/05G_TileMaps.md) | **TileMap 瓦片地图** - TileMapLayer、TileSet、地形系统、代码操作 | `using_tilemaps.rst` | 🔴 必读 |
| [05H_Parallax.md](./base/2d-development/05H_Parallax.md) | **视差滚动** - Parallax2D、scroll_scale、repeat_size、无限重复效果 | `2d_parallax.rst` | 🟡 推荐 |
| [05I_Custom_Drawing_2D.md](./base/2d-development/05I_Custom_Drawing_2D.md) | **自定义 2D 绘制** - _draw 函数、绘制命令、重绘机制、常见示例 | `custom_drawing_in_2d.rst` | 🟢 参考 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/2d/)  
**大小**: ~50 KB  
**文件数**: 9 份

**核心内容**:
- 2D 工作区和坐标系基础
- 四种移动模式实现
- Canvas 变换和视口变换
- Sprite 动画制作
- 2D 光照和阴影系统
- GPU/CPU 粒子系统
- TileMap 地形系统
- 视差滚动背景
- 自定义 2D 绘制

### 1.7 物理系统

**位置**: `base/physics-system/`

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [06A_Physics_Introduction.md](./base/physics-system/06A_Physics_Introduction.md) | **物理系统概述** - 碰撞对象类型、碰撞形状、碰撞层与掩码、物理处理回调 | `physics_introduction.rst` | 🔴 必读 |
| [06B_CharacterBody2D.md](./base/physics-system/06B_CharacterBody2D.md) | **CharacterBody2D 详解** - 移动与碰撞、move_and_collide、move_and_slide | `using_character_body_2d.rst` | 🔴 必读 |
| [06E_RigidBody.md](./base/physics-system/06E_RigidBody.md) | **刚体物理** - 刚体控制、_integrate_forces、常用操作 | `rigid_body.rst` | 🔴 必读 |
| [06F_Area2D.md](./base/physics-system/06F_Area2D.md) | **Area2D 使用指南** - 重叠检测、区域影响、物理覆盖 | `using_area_2d.rst` | 🔴 必读 |
| [06G_RayCasting.md](./base/physics-system/06G_RayCasting.md) | **射线检测** - 物理空间访问、射线查询、形状查询 | `ray-casting.rst` | 🔴 必读 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/physics/)  
**大小**: ~35 KB  
**文件数**: 5 份

**核心内容**:
- 四种碰撞对象（Area2D/StaticBody2D/RigidBody2D/CharacterBody2D）
- 碰撞层与掩码（32 层位运算配置）
- CharacterBody2D 移动控制（move_and_slide/move_and_collide）
- RigidBody2D 刚体物理（_integrate_forces/施加力/冲量）
- Area2D 区域检测（信号触发/物理覆盖）
- 射线检测（RayCast2D 节点/物理空间查询）

### 1.8 UI 系统

**位置**: `base/ui-system/`

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [07A_Containers_Detailed.md](./base/ui-system/07A_Containers_Detailed.md) | **UI 容器详解** - 容器概述/尺寸选项/容器类型/嵌套容器 | `gui_containers.rst` | 🔴 必读 |
| [07B_Size_and_Anchors_Detailed.md](./base/ui-system/07B_Size_and_Anchors_Detailed.md) | **尺寸与锚点详解** - 锚点概述/偏移与锚点/锚点预设/居中控件 | `size_and_anchors.rst` | 🔴 必读 |
| [07D_UI_Input_Handling.md](./base/ui-system/07D_UI_Input_Handling.md) | **UI 输入处理** - _gui_input 回调/鼠标过滤/焦点控制/通知 | `gui_input_handling.rst` | 🔴 必读 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/ui/)  
**大小**: ~20 KB  
**文件数**: 3 份

**核心内容**:
- UI 容器系统（BoxContainer/GridContainer/MarginContainer 等 10 种容器）
- 尺寸选项（Fill/Expand/Shrink 模式/Stretch Ratio）
- 锚点和偏移系统（锚点预设/响应式布局）
- UI 输入处理（_gui_input/鼠标过滤/焦点控制/通知系统）

**Wiki 映射**:
- 概念页面：[ui-containers.md](./wiki/concepts/ui-containers.md) - UI 容器概念
- 概念页面：[ui-size-anchors.md](./wiki/concepts/ui-size-anchors.md) - UI 尺寸和锚点概念
- 指南页面：[ui-input-handling.md](./wiki/guides/ui-input-handling.md) - UI 输入处理指南

### 1.9 输入系统

**位置**: `base/input-system/`

| 文档 | 描述 | 来源 | 行数 | 重要性 |
|------|------|------|------|--------|
| [08A_InputEvent.md](./base/input-system/08A_InputEvent.md) | **输入事件详解** - InputEvent 类型、事件传播流程、输入回调、输入动作 | `inputevent.rst` | ~226 行 | 🔴 必读 |
| [08B_InputMap.md](./base/input-system/08B_InputMap.md) | **输入映射详解** - InputMap 概述、事件 vs 轮询、定义输入动作、检查输入状态 | `input_examples.rst` | ~235 行 | 🔴 必读 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/inputs/)  
**大小**: ~15 KB  
**文件数**: 2 份

**核心内容**:
- 输入事件处理（InputEvent 类型、事件传播、14 种事件类型）
- 输入回调（_input、_unhandled_input、_shortcut_input、_gui_input）
- InputMap 系统（动作定义、状态检查、强度/向量获取）
- 跨平台输入（键盘、鼠标、手柄、触摸）
- 自定义光标（隐藏/设置/模式切换）

**Wiki 映射**:
- 概念页面：[input-events.md](./wiki/concepts/input-events.md) - 输入事件核心概念
- 指南页面：[input-map-guide.md](./wiki/guides/input-map-guide.md) - 输入映射实战指南

### 1.10 渲染系统

**位置**: `base/rendering/`

| 文档 | 描述 | 来源 | 重要性 |
|------|------|------|--------|
| [09A_Rendering_Basics.md](./base/rendering/09A_Rendering_Basics.md) | **渲染基础** - 渲染器类型/多分辨率/拉伸模式/视口 | `multiple_resolutions.rst` | 🔴 必读 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/rendering/)  
**大小**: ~5 KB  
**文件数**: 1 份

**核心内容**:
- 三种渲染器（Forward+/Mobile/Compatibility）
- 多分辨率支持（设计分辨率/运行时修改）
- 拉伸模式（Disabled/Canvas Items/Viewport）
- 拉伸纵横比（Ignore/Keep/Keep Width/Keep Height/Expand）
- 视口系统（Viewport 节点/渲染到纹理）

**Wiki 映射**:
- 概念页面：[rendering-basics.md](./wiki/concepts/rendering-basics.md) - 渲染基础概念

### 1.10A 着色器系统

**位置**: `base/shaders/`

| 文档 | 描述 | 来源 | 行数 | 重要性 |
|------|------|------|------|--------|
| [10A_Shader_Introduction.md](./base/shaders/10A_Shader_Introduction.md) | **着色器入门** - 着色器概述、类型、处理器函数、创建方法 | `introduction_to_shaders.rst` | ~150 行 | 🔴 必读 |
| [10B_Shading_Language.md](./base/shaders/10B_Shading_Language.md) | **着色器语言参考** - 数据类型、变量、uniforms、内置函数 | `shading_language.rst` | ~300 行 | 🔴 必读 |
| [10C_Canvas_Item_Shader.md](./base/shaders/10C_Canvas_Item_Shader.md) | **Canvas Item 着色器** - 2D 着色器变量和常见效果示例 | 知识库整合 | ~200 行 | 🟡 推荐 |
| [10D_Spatial_Shader.md](./base/shaders/10D_Spatial_Shader.md) | **Spatial 着色器** - 3D 着色器渲染模式、变量、材质参数 | 知识库整合 | ~250 行 | 🟡 推荐 |

**来源**: Godot 官方文档 (godot-docs-master/tutorials/shaders/) + 知识库整合  
**大小**: ~40 KB  
**文件数**: 4 份

**核心内容**:
- 着色器基础（GPU 并行程序、逐顶点/像素处理）
- 着色器类型（spatial/canvas_item/particles/sky/fog）
- 处理器函数（vertex/fragment/light/start/process/sky/fog）
- Godot 着色语言（基于 GLSL、数据类型、uniforms、内置函数）
- Canvas Item 着色器（2D 渲染、渐变/波浪/轮廓/像素化效果）
- Spatial 着色器（3D 渲染、PBR 材质、顶点动画、高级效果）

**Wiki 映射**:
- 概念页面：[shader-concepts.md](./wiki/concepts/shader-concepts.md) - 着色器核心概念
- 概念页面：[shading-language-reference.md](./wiki/concepts/shading-language-reference.md) - 着色器语言参考
- 指南页面：[canvas-item-shader-guide.md](./wiki/guides/canvas-item-shader-guide.md) - 2D 着色器实战
- 指南页面：[spatial-shader-guide.md](./wiki/guides/spatial-shader-guide.md) - 3D 着色器实战

### 1.11 实战经验汇编

**位置**: `base/practical-experiences/`

#### 踩坑案例 (pitfall-cases/)

| 文档 | 描述 | 严重性 |
|------|------|--------|
| [19_Pitfall_Records.md](./base/practical-experiences/pitfall-cases/19_Pitfall_Records.md) | **23 个常见踩坑记录总览** | 🔴 必读 |
| [GDScript_Warning_Best_Practices.md](./base/practical-experiences/pitfall-cases/GDScript_Warning_Best_Practices.md) | GDScript 警告处理最佳实践 | 🟡 推荐 |
| [Warning_Fix_Quick_Reference.md](./base/practical-experiences/pitfall-cases/Warning_Fix_Quick_Reference.md) | 警告修复速查表 | 🟢 速查 |
| [Godot_4x_Resource_File_Comment_Issue.md](./base/practical-experiences/pitfall-cases/Godot_4x_Resource_File_Comment_Issue.md) | 资源文件注释问题 | 🔴 严重 |
| [20_TileMap_Shader_Border_Pitfall.md](./base/practical-experiences/pitfall-cases/20_TileMap_Shader_Border_Pitfall.md) | TileMap Shader 边框问题 | 🔴 严重 |
| [Godot_4x_Window_Size_Detection_Issue.md](./base/practical-experiences/pitfall-cases/Godot_4x_Window_Size_Detection_Issue.md) | 窗口尺寸检测问题 | 🔴 严重 |
| [GDScript_Setter_Getter_Dual_State_Pitfall.md](./base/practical-experiences/pitfall-cases/GDScript_Setter_Getter_Dual_State_Pitfall.md) | **内嵌 get/set 双重状态踩坑** - 包装属性 vs 独立状态、状态不一致（§26） | 🔴 必读 |
| [Godot_4x_Autoload_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_Autoload_Pitfalls.md) | **Autoload 单例踩坑记录** - class_name 冲突、get_node 错误、GUT API 陷阱等 | 🔴 必读 |
| [GUT_Testing_Pitfalls.md](./base/practical-experiences/pitfall-cases/GUT_Testing_Pitfalls.md) | **GUT 测试框架踩坑记录** - 运行器模式挂起、Autoload 引用替换、watch_signals 挂起、字段名校验、参数类型错误（§32-§36） | 🔴 必读 |
| [Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md](./base/practical-experiences/pitfall-cases/Godot_4x_Resource_Ref_Data_Consistency_Pitfall.md) | **资源引用与数据一致性踩坑记录** - ext_resource 引用已删文件、数据格式不一致、遗漏配置文件消费者（§37-§39） | 🔴 必读 |
| [Godot_4x_Game_System_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_Game_System_Pitfalls.md) | **游戏系统实战踩坑记录** - Tooltip遮挡闪烁、场景切换绕过、分裂敌人未计入、freed instance引用、击退路径冲突、奖励重复显示、效果字段名不一致、UI语义与调试踩坑、场景树/Dictionary/路径偏移/终局触发踩坑（§40-§58） | 🔴 必读 |
| [Godot_4x_i18n_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_i18n_Pitfalls.md) | **国际化(i18n)踩坑记录** - CSV en列为空、重复代码遗漏、格式串截断、翻译键命名不一致、TranslationServer缓存不热重载、_process引用已释放对象（§59-§64） | 🔴 必读 |
| [GDScript_Indentation_Editor_Crash_Pitfall.md](./base/practical-experiences/pitfall-cases/GDScript_Indentation_Editor_Crash_Pitfall.md) | **GDScript 缩进错误导致编辑器崩溃** - 缩进敏感语言编辑工作流规范（§65） | 🔴 必读 |
| [Godot_4x_Area2D_Mouse_Signal_And_Parallel_Systems_Pitfall.md](./base/practical-experiences/pitfall-cases/Godot_4x_Area2D_Mouse_Signal_And_Parallel_Systems_Pitfall.md) | **Area2D鼠标信号与并行交互系统踩坑** - mouse_entered/mouse_exited不可靠、多套并行交互系统隐蔽Bug（§66-§67） | 🔴 必读 |
| [Godot_4x_PNG_Generation_Pitfall.md](./base/practical-experiences/pitfall-cases/Godot_4x_PNG_Generation_Pitfall.md) | **程序化生成PNG图片踩坑** - Python原生手写PNG导致Godot导入失败、Pillow正确方案（§68） | 🔴 必读 |
| [Godot_4x_Buff_Crit_ThemeOverride_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_Buff_Crit_ThemeOverride_Pitfalls.md) | **Buff系统/暴击计算/主题API踩坑** - apply_buff复合修改config、暴击伤害未含trait加成、add_theme_stylebox_override误用（§78-§80） | 🔴 必读 |
| [INDEX.md](./base/practical-experiences/pitfall-cases/INDEX.md) | **踩坑案例目录索引** - 所有踩坑案例文件的分类索引 | 🟢 速查 |
| [Godot_4x_Event_Option_Family_Pitfalls.md](./base/practical-experiences/pitfall-cases/Godot_4x_Event_Option_Family_Pitfalls.md) | **事件选项家族体系踩坑** - OptionData字段联动、条件校验、加权随机 | 🔴 必读 |

#### P 系列项目实战踩坑（新增 🆕）

聚焦人生塔防项目实际开发中的完整踩坑过程（现象 → 根因 → 修复 → 预防），与 § 系列的索引摘要互补。
P1-P13 涵盖：UI 程序化构建、翻译键规范、数据源一致性、条件格式化、事件链显示、脚本加载安全、场景树访问、数值平衡、class_name 冲突、脚本验证流程、CanvasLayer API 归属、实体引用验证、跨会话状态持久化。

| 文件 | 描述 | 严重程度 |
|------|------|----------|
| [P1_PanelContainer默认透明.md](./base/practical-experiences/pitfall-cases/P1_PanelContainer默认透明.md) | PanelContainer 默认透明导致文字可读性差 | 🟡 中 |
| [P2_翻译键命名不统一.md](./base/practical-experiences/pitfall-cases/P2_翻译键命名不统一.md) | 翻译键命名不统一导致 CSV 翻译断裂 | 🟡 中 |
| [P3_选项奖励数据源不一致.md](./base/practical-experiences/pitfall-cases/P3_选项奖励数据源不一致.md) | 选项奖励数据源不一致（UI弹框遗漏新字段） | 🔴 高 |
| [P4_条件格式化缺少自定义类型.md](./base/practical-experiences/pitfall-cases/P4_条件格式化缺少自定义类型.md) | 条件格式化缺少 npc_relation/profession 等类型处理 | 🟡 中 |
| [P5_事件链前置条件显示混淆.md](./base/practical-experiences/pitfall-cases/P5_事件链前置条件显示混淆.md) | 事件链前置条件显示混淆（flag: 前缀暴露） | 🟢 低 |
| [P6_重复变量声明导致脚本加载失败.md](./base/practical-experiences/pitfall-cases/P6_重复变量声明导致脚本加载失败.md) | 重复变量声明导致脚本加载失败（Parse Error） | 🔴 高 |
| [P7_场景树访问崩溃.md](./base/practical-experiences/pitfall-cases/P7_场景树访问崩溃.md) | 场景树访问崩溃（queue_free 后访问外部节点） | 🔴 高 |
| [P8_防御塔奖励缺失.md](./base/practical-experiences/pitfall-cases/P8_防御塔奖励缺失.md) | 数值平衡 — 44 个事件选项缺少防御塔奖励 | 🔴 高 |
| [P9_class_name命名冲突导致脚本无法加载.md](./base/practical-experiences/pitfall-cases/P9_class_name命名冲突导致脚本无法加载.md) | class_name 命名冲突导致脚本无法加载 | 🔴 高 |
| [P10_validate_script_error_code_43不等于有实际错误.md](./base/practical-experiences/pitfall-cases/P10_validate_script_error_code_43不等于有实际错误.md) | validate_script error_code 43 不等于有实际错误 | 🟡 中 |
| [P11_get_canvas_transform方法位置错误.md](./base/practical-experiences/pitfall-cases/P11_get_canvas_transform方法位置错误.md) | get_canvas_transform() 是 Viewport 方法而非 CanvasLayer | 🟡 中 |
| [P12_编造不存在的NPC_ID.md](./base/practical-experiences/pitfall-cases/P12_编造不存在的NPC_ID.md) | 编造不存在的 NPC ID（配置引用未验证） | 🔴 高 |
| [P13_战斗HP跨会话持久化导致不满血.md](./base/practical-experiences/pitfall-cases/P13_战斗HP跨会话持久化导致不满血.md) | 战斗 HP 跨会话持久化导致不满血（current_hp vs accumulated_damage） | 🔴 高 |

#### 代码规范 (code-standards/)

| 文档 | 描述 | 版本 | 适用范围 |
|------|------|------|---------|
| [GDScript_Code_Standards.md](./base/practical-experiences/code-standards/GDScript_Code_Standards.md) | **GDScript 完整代码规范标准** ⭐⭐⭐ | - | 所有 GDScript 代码 |
| [20A_Godot_Large_Project_Pitfalls_Deep_Dive.md](./base/practical-experiences/code-standards/20A_Godot_Large_Project_Pitfalls_Deep_Dive.md) | **大型项目深度避坑指南（完整深度版）** 📘 | v2.0 | 系统学习 |
| [20B_Godot_Pitfalls_Verification_Guidelines.md](./base/practical-experiences/code-standards/20B_Godot_Pitfalls_Verification_Guidelines.md) | **避坑验证准则（完整系统版）** 📘 | v1.0 | 问题排查 |
| [20C_Godot_Best_Practices_Quick_Reference.md](./base/practical-experiences/code-standards/20C_Godot_Best_Practices_Quick_Reference.md) | **最佳实践详细指南（详细实践版）** 📘 | v2.0 | 实战参考 |

**📚 版本分层说明**：
- 📘 **完整版**（code-standards/）：适合系统学习和深入研究，包含完整的代码示例和详细说明
- 📙 **精简版**（best-practices/）：适合快速查阅核心要点，查看 [best-practices 目录](./base/practical-experiences/best-practices/)

#### 案例研究 (case-studies/)

| 文档 | 描述 | 项目来源 |
|------|------|---------|
| [14_Tower_Defense_Case_Study.md](./base/practical-experiences/case-studies/14_Tower_Defense_Case_Study.md) | 通用库第 14 篇历史案例入口 | tower_defense 项目 |

#### 优化技巧 (optimization-tips/)

| 文档 | 描述 | 优化方向 |
|------|------|---------|
| [14A_General_Optimization.md](./base/practical-experiences/optimization-tips/14A_General_Optimization.md) | 性能优化通用指南 | 方法论 + 测量 |
| [14B_CPU_Optimization.md](./base/practical-experiences/optimization-tips/14B_CPU_Optimization.md) | CPU 优化实战 | 脚本/物理/AI |
| [14C_GPU_Optimization.md](./base/practical-experiences/optimization-tips/14C_GPU_Optimization.md) | GPU 优化实战 | 渲染/着色器 |

### 1.12 Steam 平台集成

[通用库第 12 篇入口](./base/steam-integration/12_Steam_Platform_Integration.md) · [TestMCP Steam 接入状态](./wiki/guides/steam-platform-integration-guide.md)

### 1.13 动画系统

**位置**: `base/animation-system/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [11A_Animation_Player.md](./base/animation-system/11A_Animation_Player.md) | **AnimationPlayer 节点** - 动画播放、关键帧、轨道系统 | 🔴 必读 |
| [11B_Animation_Tree.md](./base/animation-system/11B_Animation_Tree.md) | **AnimationTree 动画树** - 状态机、混合树、动画混合 | 🔴 必读 |
| [11C_2D_Skeletons.md](./base/animation-system/11C_2D_Skeletons.md) | **2D 骨骼** - 2D 骨骼系统、骨骼绑定 | 🟡 推荐 |
| [11D_Cutout_Animation.md](./base/animation-system/11D_Cutout_Animation.md) | **剪裁动画** - 角色剪裁动画制作 | 🟡 推荐 |

**来源**: Godot 官方文档 + 知识库整合  
**大小**: ~35 KB  
**文件数**: 4 份

**核心内容**:
- AnimationPlayer 动画播放
- AnimationTree 状态机
- 2D 骨骼系统
- 剪裁动画制作

**Wiki 映射**:
- 概念页面：[animation-player.md](./wiki/concepts/animation-player.md) - AnimationPlayer 核心概念
- 概念页面：[animation-tree.md](./wiki/concepts/animation-tree.md) - AnimationTree 核心概念
- 指南页面：[2d-animation-guide.md](./wiki/guides/2d-animation-guide.md) - 2D 动画制作实战指南
- 指南页面：[cutout-animation-guide.md](./wiki/guides/cutout-animation-guide.md) - 剪裁动画制作指南

### 1.14 多人游戏网络

[通用库第 13 篇入口](./base/multiplayer-networking/13_Multiplayer_Networking.md) · [TestMCP 多人联机状态](./wiki/guides/multiplayer-networking-guide.md)

### 1.15 音频系统

**位置**: `base/audio-system/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [12A_Audio_Buses.md](./base/audio-system/12A_Audio_Buses.md) | **音频总线** - 音频总线系统、混音器 | 🔴 必读 |
| [12B_Audio_Streams.md](./base/audio-system/12B_Audio_Streams.md) | **音频流** - 音频文件导入、播放 | 🔴 必读 |
| [12C_Audio_Effects.md](./base/audio-system/12C_Audio_Effects.md) | **音频效果** - 音频效果器、实时处理 | 🟡 推荐 |

**来源**: Godot 官方文档  
**大小**: ~25 KB  
**文件数**: 3 份

**核心内容**:
- 音频总线架构
- 音频流播放
- 音频效果器
- 3D 空间音频

**Wiki 映射**:
- 概念页面：[audio-buses-concept.md](./wiki/concepts/audio-buses-concept.md) - 音频总线核心概念
- 指南页面：[audio-streams-guide.md](./wiki/guides/audio-streams-guide.md) - 音频流实战指南
- 指南页面：[audio-effects-guide.md](./wiki/guides/audio-effects-guide.md) - 音频效果实战指南

### 1.16 3D 开发

**位置**: `base/3d-development/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [13A_Introduction_to_3D.md](./base/3d-development/13A_Introduction_to_3D.md) | **3D 开发介绍** - 3D 工作区、坐标系、Node3D | 🔴 必读 |
| [13B_3D_Transforms.md](./base/3d-development/13B_3D_Transforms.md) | **3D 变换** - Transform3D、Basis、四元数 | 🔴 必读 |
| [13C_Lights_and_Shadows.md](./base/3d-development/13C_Lights_and_Shadows.md) | **3D 光照与阴影** - 光源类型、阴影系统 | 🔴 必读 |
| [13D_Standard_Material_3D.md](./base/3d-development/13D_Standard_Material_3D.md) | **标准材质 3D** - StandardMaterial3D 完整参数 | 🔴 必读 |
| [13E_Particles_3D.md](./base/3d-development/13E_Particles_3D.md) | **3D 粒子系统** - GPUParticles3D、ParticleProcessMaterial | 🟡 推荐 |

**来源**: Godot 官方文档  
**大小**: ~45 KB  
**文件数**: 5 份

**核心内容**:
- 3D 坐标系与 Node3D
- Transform3D 变换
- 3D 光照与阴影
- StandardMaterial3D 材质
- 3D 粒子系统

**Wiki 映射**:
- 概念页面：[3d-intro.md](./wiki/concepts/3d-intro.md) - 3D 开发入门概念
- 概念页面：[3d-transforms-concept.md](./wiki/concepts/3d-transforms-concept.md) - 3D 变换核心概念
- 指南页面：[3d-lights-guide.md](./wiki/guides/3d-lights-guide.md) - 3D 灯光实战指南
- 指南页面：[particles-3d-guide.md](./wiki/guides/particles-3d-guide.md) - 3D 粒子系统指南
- 指南页面：[standard-material-guide.md](./wiki/guides/standard-material-guide.md) - 标准材质指南

### 1.17 资源与 I/O

**位置**: `base/assets-and-io/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [15A_File_System.md](./base/assets-and-io/15A_File_System.md) | **文件系统** - 文件访问、目录操作 | 🔴 必读 |
| [15B_Importing_Images.md](./base/assets-and-io/15B_Importing_Images.md) | **导入图像** - 图像资源导入设置 | 🔴 必读 |
| [15C_Saving_Games.md](./base/assets-and-io/15C_Saving_Games.md) | **保存游戏** - 存档系统、数据持久化 | 🔴 必读 |
| [15D_Background_Loading.md](./base/assets-and-io/15D_Background_Loading.md) | **后台加载** - 异步资源加载 | 🟡 推荐 |

**来源**: Godot 官方文档  
**大小**: ~30 KB  
**文件数**: 4 份

**核心内容**:
- FileAccess/DirAccess 文件操作
- 图像导入设置
- 游戏存档系统
- 异步资源加载

**Wiki 映射**:
- 指南页面：[filesystem-guide.md](./wiki/guides/filesystem-guide.md) - 文件系统指南
- 指南页面：[importing-images-guide.md](./wiki/guides/importing-images-guide.md) - 图片导入指南
- 指南页面：[saving-games-guide.md](./wiki/guides/saving-games-guide.md) - 存档系统指南
- 指南页面：[background-loading-guide.md](./wiki/guides/background-loading-guide.md) - 后台加载指南

### 1.18 最佳实践（精简速查版）

**位置**: `base/best-practices/`

> **📚 版本说明**：  
> - 📙 **精简速查版**（本目录）：适合快速查阅核心要点  
> - 📘 **完整深度版**：需要系统学习？查看 [code-standards 目录](./base/practical-experiences/code-standards/)

#### 通用最佳实践

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [16A_Scene_Organization.md](./base/best-practices/16A_Scene_Organization.md) | **场景组织** - 场景结构设计、节点组织 | 🔴 必读 |
| [16B_Data_Preferences.md](./base/best-practices/16B_Data_Preferences.md) | **数据偏好** - 数据驱动设计、资源配置 | 🟡 推荐 |
| [16C_Logic_Preferences.md](./base/best-practices/16C_Logic_Preferences.md) | **逻辑偏好** - 代码组织、逻辑分离 | 🟡 推荐 |

#### 大型项目避坑速查（🆕 精简版）

| 文档 | 描述 | 版本 | 完整版链接 |
|------|------|------|-----------|
| [20A_Godot_Large_Project_Pitfalls_Deep_Dive.md](./base/practical-experiences/best-practices/20A_Godot_Large_Project_Pitfalls_Deep_Dive.md) | **大型项目深度避坑指南（精简速查版）** 📙 | v1.0 | [完整深度版](./base/practical-experiences/code-standards/20A_Godot_Large_Project_Pitfalls_Deep_Dive.md) |
| [20B_Godot_Pitfalls_Verification_Guidelines.md](./base/practical-experiences/best-practices/20B_Godot_Pitfalls_Verification_Guidelines.md) | **避坑验证准则（精简指南版）** 📙 | v1.0 | [完整系统版](./base/practical-experiences/code-standards/20B_Godot_Pitfalls_Verification_Guidelines.md) |
| [20C_Godot_Best_Practices_Quick_Reference.md](./base/practical-experiences/best-practices/20C_Godot_Best_Practices_Quick_Reference.md) | **最佳实践速查（精简速查版）** 📙 | v1.0 | [详细实践版](./base/practical-experiences/code-standards/20C_Godot_Best_Practices_Quick_Reference.md) |

**来源**: Godot 官方文档 + 实战经验  
**大小**: ~45 KB  
**文件数**: 6 份（3 份通用 + 3 份速查）

**核心内容**:
- 场景拆分与组织
- 数据驱动设计
- 代码组织模式
- 组件化设计

**Wiki 映射**:
- 指南页面：[scene-organization-guide.md](./wiki/guides/scene-organization-guide.md) - 场景组织指南
- 指南页面：[data-preferences-guide.md](./wiki/guides/data-preferences-guide.md) - 数据偏好指南
- 指南页面：[logic-preferences-guide.md](./wiki/guides/logic-preferences-guide.md) - 逻辑偏好指南
- 指南页面：[common-patterns-guide.md](./wiki/guides/common-patterns-guide.md) - 常用模式指南

### 1.19 调试与测试

**位置**: `base/debug-and-testing/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [17A_Debugging_Tools.md](./base/debug-and-testing/17A_Debugging_Tools.md) | **调试工具** - 调试器使用、断点、监视 | 🔴 必读 |
| [17B_Profiler.md](./base/debug-and-testing/17B_Profiler.md) | **性能分析器** - 性能监控、瓶颈分析 | 🔴 必读 |

**来源**: Godot 官方文档  
**大小**: ~18 KB  
**文件数**: 2 份

**核心内容**:
- 调试器使用
- 断点与监视
- 性能监控
- 瓶颈分析

**Wiki 映射**:
- 指南页面：[debugging-tools-guide.md](./wiki/guides/debugging-tools-guide.md) - 调试工具指南
- 指南页面：[profiler-guide.md](./wiki/guides/profiler-guide.md) - 性能分析器指南

### 1.20 导出与平台

**位置**: `base/export-and-platforms/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [18A_Exporting_Projects.md](./base/export-and-platforms/18A_Exporting_Projects.md) | **导出项目** - 导出预设、平台配置 | 🔴 必读 |
| [18B_Feature_Tags.md](./base/export-and-platforms/18B_Feature_Tags.md) | **特性标签** - 平台特性、条件编译 | 🟡 推荐 |

**来源**: Godot 官方文档  
**大小**: ~15 KB  
**文件数**: 2 份

**核心内容**:
- 导出预设配置
- 平台特定设置
- 特性标签检测
- 跨平台兼容

**Wiki 映射**:
- 指南页面：[exporting-projects-guide.md](./wiki/guides/exporting-projects-guide.md) - 项目导出指南
- 指南页面：[feature-tags-guide.md](./wiki/guides/feature-tags-guide.md) - 功能标签指南

### 1.21 快速参考

**位置**: `base/quick-reference/`

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [20A_GDScript_Cheat_Sheet.md](./base/quick-reference/20A_GDScript_Cheat_Sheet.md) | **GDScript 速查表** - 语法速查、常用 API | 🔴 速查 |
| [20B_Common_Patterns.md](./base/quick-reference/20B_Common_Patterns.md) | **常用模式** - 设计模式、代码模式 | 🟡 推荐 |
| [20C_API_Commonly_Used.md](./base/quick-reference/20C_API_Commonly_Used.md) | **常用 API** - 核心 API 速查 | 🔴 速查 |

**来源**: Godot 官方文档 + 知识库整合  
**大小**: ~25 KB  
**文件数**: 3 份

**核心内容**:
- GDScript 语法速查
- 常用设计模式
- 核心 API 参考

**Wiki 映射**:
- 指南页面：[gdscript-cheatsheet.md](./wiki/guides/gdscript-cheatsheet.md) - GDScript 速查表
- 指南页面：[common-patterns-guide.md](./wiki/guides/common-patterns-guide.md) - 常用模式指南
- 指南页面：[api-commonly-used.md](./wiki/guides/api-commonly-used.md) - 常用 API 参考

---

## 2. 整理（cases/ 与 wiki/）

### 2.1 实体页面 (entities/)

**说明**: 游戏实体的详细设计文档

| 页面 | 描述 | 来源 | 状态 |
|------|------|------|------|
| [防御塔设计](./wiki/entities/tower.md) | 防御塔完整设计（继承/组件/数据/行为） | ✅ 已完成 |
| [敌人实体设计](./wiki/entities/enemy.md) | 敌人实体设计（类型/配置/移动/受击） | ✅ 已完成 |
| [Projectile - 投射物设计](./wiki/entities/projectile.md) | 投射物设计（类型/飞行/碰撞/伤害） | ✅ 已完成 |
| [Player - 玩家设计](./wiki/entities/player.md) | 玩家设计（输入/移动/状态/技能） | ✅ 已完成 |

### 2.2 概念页面 (concepts/)

**说明**: 核心概念和系统架构

| 页面 | 描述 | 来源 | 状态 |
|------|------|------|------|
| [GDScript 基础语法](./wiki/concepts/gdscript-basics.md) | GDScript 基础语法摘要（标识符/关键字/操作符/字面量） | ✅ 已完成 |
| [GDScript 类型系统](./wiki/concepts/gdscript-types.md) | GDScript 类型和变量摘要（值类型/引用类型/容器） | ✅ 已完成 |
| [GDScript 函数](./wiki/concepts/gdscript-functions.md) | GDScript 函数摘要（定义/Lambda/静态函数） | ✅ 已完成 |
| [GDScript 类和继承](./wiki/concepts/gdscript-classes.md) | GDScript 类和继承摘要（构造函数/内部类/抽象类） | ✅ 已完成 |
| [GDScript 代码规范](./wiki/concepts/gdscript-standards.md) | GDScript 完整代码规范 | ✅ 已完成 |
| [攻击系统设计](./wiki/concepts/attack-system.md) | 近战/远程/AOE 攻击实现 | ✅ 已完成 |
| [场景树](./wiki/concepts/scene-tree.md) | Godot 场景树核心概念（MainLoop/SceneTree/根视口） | ✅ 已完成 |
| [资源系统](./wiki/concepts/resources-system.md) | 资源系统概念（Node vs Resource/加载/自定义资源） | ✅ 已完成 |
| [单例模式](./wiki/concepts/autoload-singletons.md) | Autoload 单例模式（全局状态/场景切换） | ✅ 已完成 |
| [信号系统](./wiki/concepts/signals-events.md) | 信号系统核心概念（定义/发射/连接/断开/await） | ✅ 已完成 |
| [向量数学](./wiki/concepts/vector-math.md) | 向量数学核心概念（点积/叉积/归一化/反射） | ✅ 已完成 |
| [矩阵与变换](./wiki/concepts/matrices-transforms.md) | 矩阵变换核心概念（Transform2D/3D、缩放/旋转/平移） | ✅ 已完成 |
| [2D 开发介绍](./wiki/concepts/2d-development-intro.md) | 2D 工作区、坐标系、工具栏、Node2D vs Control | ✅ 已完成 |
| [2D 变换概念](./wiki/concepts/2d-transforms.md) | Canvas 变换、视口变换、坐标转换 | ✅ 已完成 |
| [2D 灯光和阴影概念](./wiki/concepts/2d-lights-shadows.md) | PointLight2D、DirectionalLight2D、阴影系统 | ✅ 已完成 |
| [TileMap 概念](./wiki/concepts/tilemaps-concept.md) | TileMapLayer、TileSet、地形系统 | ✅ 已完成 |
| [物理系统介绍](./wiki/concepts/physics-intro.md) | 物理系统核心概念（碰撞对象/碰撞层/物理回调） | ✅ 已完成 |
| [CharacterBody2D 概念](./wiki/concepts/characterbody2d-concept.md) | CharacterBody2D 核心概念（move_and_slide/碰撞检测） | ✅ 已完成 |
| [RigidBody2D 概念](./wiki/concepts/rigidbody2d-concept.md) | RigidBody2D 核心概念（_integrate_forces/施加力） | ✅ 已完成 |
| [Area2D 概念](./wiki/concepts/area2d-concept.md) | Area2D 核心概念（重叠检测/区域影响） | ✅ 已完成 |
| [UI 容器概念](./wiki/concepts/ui-containers.md) | UI 容器系统核心概念（10 种容器/尺寸选项/嵌套布局） | ✅ 已完成 |
| [UI 尺寸和锚点概念](./wiki/concepts/ui-size-anchors.md) | UI 尺寸和锚点核心概念（偏移/锚点/响应式布局） | ✅ 已完成 |
| [输入事件概念](./wiki/concepts/input-events.md) | 输入事件核心概念（事件传播/InputEvent 类型/输入回调） | ✅ 已完成 |
| [渲染基础概念](./wiki/concepts/rendering-basics.md) | 渲染基础概念（渲染器/多分辨率/拉伸模式/视口） | ✅ 已完成 |
| [着色器核心概念](./wiki/concepts/shader-concepts.md) | 着色器概述、类型、处理器函数、着色器语言基础 | ✅ 已完成 |
| [着色器语言参考](./wiki/concepts/shading-language-reference.md) | Godot 着色器语言完整参考（数据类型/运算符/内置函数） | ✅ 已完成 |
| [Camera2D 摄像机概念](./wiki/concepts/camera2d-concept.md) | Camera2D 摄像机核心概念（跟随/限制/平滑/抖动） | ✅ 已完成 |
| [StaticBody2D 静态物体概念](./wiki/concepts/staticbody2d-concept.md) | StaticBody2D 静态物体核心概念（碰撞/平台/移动平台） | ✅ 已完成 |
| [Tween 补间动画概念](./wiki/concepts/tween-concept.md) | Tween 补间动画核心概念（创建/链式/回调/自定义过渡） | ✅ 已完成 |
| [3D 开发入门](./wiki/concepts/3d-intro.md) | 3D 工作区、坐标系、Node3D 基础 | ✅ 已完成 |
| [3D 变换概念](./wiki/concepts/3d-transforms-concept.md) | Transform3D、Basis、四元数核心概念 | ✅ 已完成 |
| [音频总线概念](./wiki/concepts/audio-buses-concept.md) | 音频总线架构、混音器、总线路由 | ✅ 已完成 |
| [AnimationPlayer 动画播放器](./wiki/concepts/animation-player.md) | AnimationPlayer 核心概念（关键帧/轨道/播放控制） | ✅ 已完成 |
| [AnimationTree 动画树](./wiki/concepts/animation-tree.md) | AnimationTree 核心概念（状态机/混合树/动画混合） | ✅ 已完成 |

### 2.3 指南页面 (guides/)

**说明**: 开发指南和最佳实践

| 页面 | 描述 | 来源 | 状态 |
|------|------|------|------|
| [GDScript 静态类型指南](./wiki/guides/gdscript-static-typing.md) | GDScript 静态类型系统完整指南 | ✅ 已完成 |
| [GDScript 导出属性指南](./wiki/guides/gdscript-export-properties.md) | GDScript 导出属性完整指南 | ✅ 已完成 |
| [GDScript 格式化字符串指南](./wiki/guides/gdscript-format-strings.md) | GDScript 字符串格式化完整指南 | ✅ 已完成 |
| [GDScript 代码风格指南](./wiki/guides/gdscript-style-guide.md) | GDScript 代码风格完整指南 | ✅ 已完成 |
| [常见踩坑避雷](./wiki/guides/common-pitfalls.md) | 常见踩坑正文、原始案例与验证依据 | ✅ 已完成 |
| [i18n 实战指南](./wiki/guides/i18n-guide.md) | Godot 4.x 国际化(i18n)实战指南 | ✅ 已完成 |
| [性能优化实战指南](./wiki/guides/performance-optimization-guide.md) | CPU/GPU 优化完整指南（整合版） | ✅ 已完成 |
| [TestMCP 塔防战斗架构](./wiki/guides/tower-defense-architecture.md) | 战斗、建塔、存档和验证记录 | ✅ 已完成 |
| [节点操作指南](./wiki/guides/node-operations-guide.md) | 节点获取/创建/删除/场景实例化完整指南 | ✅ 已完成 |
| [信号最佳实践](./wiki/guides/signals-best-practices.md) | 信号系统最佳实践指南（解耦/命名/连接策略） | ✅ 已完成 |
| [插值运算指南](./wiki/guides/interpolation-guide.md) | 插值运算完整指南（lerp/平滑移动/帧率无关） | ✅ 已完成 |
| [贝塞尔曲线指南](./wiki/guides/bezier-curves-guide.md) | 贝塞尔曲线完整指南（二次/三次/Curve2D） | ✅ 已完成 |
| [随机数生成指南](./wiki/guides/random-numbers-guide.md) | 随机数生成完整指南（PRNG/噪声/加密安全） | ✅ 已完成 |
| [2D 移动指南](./wiki/guides/2d-movement-guide.md) | 8 方向/旋转 + 移动/点击移动实现 | ✅ 已完成 |
| [Sprite 动画指南](./wiki/guides/sprite-animation-guide.md) | AnimatedSprite2D/AnimationPlayer 动画制作 | ✅ 已完成 |
| [2D 粒子系统指南](./wiki/guides/particles-2d-guide.md) | GPUParticles2D/CPUParticles2D 使用 | ✅ 已完成 |
| [视差滚动指南](./wiki/guides/parallax-guide.md) | Parallax2D 多层背景深度效果 | ✅ 已完成 |
| [自定义 2D 绘制指南](./wiki/guides/custom-drawing-2d-guide.md) | _draw 函数、绘制命令、重绘机制 | ✅ 已完成 |
| [射线投射指南](./wiki/guides/raycasting-guide.md) | 射线检测实战（RayCast2D/物理空间查询） | ✅ 已完成 |
| [UI 输入处理指南](./wiki/guides/ui-input-handling.md) | UI 输入处理实战（_gui_input/鼠标过滤/焦点控制） | ✅ 已完成 |
| [输入映射指南](./wiki/guides/input-map-guide.md) | 输入映射实战（InputMap/事件 vs 轮询/跨平台输入） | ✅ 已完成 |
| [Canvas Item 着色器指南](./wiki/guides/canvas-item-shader-guide.md) | 2D 着色器实战（渐变/波浪/轮廓/像素化） | ✅ 已完成 |
| [Spatial 着色器指南](./wiki/guides/spatial-shader-guide.md) | 3D 着色器实战（PBR 材质/顶点动画/高级效果） | ✅ 已完成 |
| [TestMCP Steam 接入状态](./wiki/guides/steam-platform-integration-guide.md) | 本地成就实现及发行配置 | 待接入 |
| [场景组织指南](./wiki/guides/scene-organization-guide.md) | 场景结构设计、节点组织最佳实践 | ✅ 已完成 |
| [存档系统指南](./wiki/guides/saving-games-guide.md) | 游戏存档系统、数据持久化实现 | ✅ 已完成 |
| [性能分析器指南](./wiki/guides/profiler-guide.md) | 性能监控、瓶颈分析实战 | ✅ 已完成 |
| [3D 粒子指南](./wiki/guides/particles-3d-guide.md) | GPUParticles3D、ParticleProcessMaterial 使用 | ✅ 已完成 |
| [TestMCP 多人联机状态](./wiki/guides/multiplayer-networking-guide.md) | 项目状态与通用库入口 | 待接入 |
| [逻辑偏好指南](./wiki/guides/logic-preferences-guide.md) | 代码组织、逻辑分离最佳实践 | ✅ 已完成 |
| [图片导入指南](./wiki/guides/importing-images-guide.md) | 图像资源导入设置与优化 | ✅ 已完成 |
| [GDScript 速查表](./wiki/guides/gdscript-cheatsheet.md) | GDScript 语法速查、常用代码片段 | ✅ 已完成 |
| [文件系统指南](./wiki/guides/filesystem-guide.md) | FileAccess/DirAccess 文件操作实战 | ✅ 已完成 |
| [功能标签指南](./wiki/guides/feature-tags-guide.md) | 平台特性检测、条件编译实战 | ✅ 已完成 |
| [项目导出指南](./wiki/guides/exporting-projects-guide.md) | 导出预设、平台配置实战 | ✅ 已完成 |
| [调试工具指南](./wiki/guides/debugging-tools-guide.md) | 调试器使用、断点、监视实战 | ✅ 已完成 |
| [数据偏好指南](./wiki/guides/data-preferences-guide.md) | 数据驱动设计、资源配置最佳实践 | ✅ 已完成 |
| [剪纸动画指南](./wiki/guides/cutout-animation-guide.md) | 角色剪纸动画制作实战 | ✅ 已完成 |
| [常用模式指南](./wiki/guides/common-patterns-guide.md) | 设计模式、代码模式实战参考 | ✅ 已完成 |
| [后台加载指南](./wiki/guides/background-loading-guide.md) | 异步资源加载实战 | ✅ 已完成 |
| [音频流指南](./wiki/guides/audio-streams-guide.md) | 音频文件导入、播放实战 | ✅ 已完成 |
| [常用 API 参考](./wiki/guides/api-commonly-used.md) | 核心 API 速查参考 | ✅ 已完成 |
| [3D 灯光指南](./wiki/guides/3d-lights-guide.md) | 3D 光源类型、阴影系统实战 | ✅ 已完成 |
| [2D 动画指南](./wiki/guides/2d-animation-guide.md) | 2D 动画制作实战（AnimatedSprite2D/AnimationPlayer） | ✅ 已完成 |
| [音频效果指南](./wiki/guides/audio-effects-guide.md) | 音频效果器、实时处理实战 | ✅ 已完成 |
| [标准材质指南](./wiki/guides/standard-material-guide.md) | StandardMaterial3D 完整参数与使用 | ✅ 已完成 |

### 2.4 对比分析 (comparisons/)

**说明**: 不同技术方案的对比分析

| 页面 | 描述 | 来源 | 状态 |
|------|------|------|------|
| [近战 vs 远程攻击对比](./wiki/comparisons/melee-vs-range-attack.md) | 实现/性能/适用场景全面对比 | ✅ 已完成 |
| [不同加载方式对比](./wiki/comparisons/loading-methods-comparison.md) | preload/load/后台加载全面对比 | ✅ 已完成 |
| [碰撞检测方案对比](./wiki/comparisons/collision-detection-comparison.md) | 7 种碰撞检测方案对比 | ✅ 已完成 |

### 2.5 概述页面 (overviews/)

**说明**: 领域知识的整体概览

| 页面 | 描述 | 状态 |
|------|------|------|
| [Godot 4.x 游戏开发概述](./wiki/overviews/game-development-overview.md) | Godot 游戏开发全栈知识体系 | ✅ 已完成 |
| [2D 游戏开发概述](./wiki/overviews/2d-game-development-overview.md) | 2D 游戏开发完整知识体系 | ✅ 已完成 |
| [3D 游戏开发概述](./wiki/overviews/3d-game-development-overview.md) | 3D 游戏开发完整知识体系 | ✅ 已完成 |

### 2.6 案例库 (cases/)

**位置**: `cases/`

**说明**: 独立项目拆解案例，提供完整的实现参考和代码示例

#### CompositorEffect + Compute Shader 案例库

**位置**: `cases/compositor-effect-library/`

> **来源项目**: `compositor-effect-library` (GitHub: DevPoodle)
> **适用版本**: Godot 4.6+
> **关联踩坑**: §22A CompositorEffect 与 Compute Shader 体系

| 文档 | 描述 | 核心技术 | 重要性 |
|------|------|---------|--------|
| [01_Compute_Shader_Plus_Plugin.md](./cases/compositor-effect-library/01_Compute_Shader_Plus_Plugin.md) | **Compute Shader Plus 插件封装** - RenderingDevice 封装、Uniform 体系、ByteArrayHelper | GPU 计算基础框架 | 🔴 必读 |
| [02_CompositorEffect_Basic_Architecture.md](./cases/compositor-effect-library/02_CompositorEffect_Basic_Architecture.md) | **CompositorEffect 基础架构** - G-Buffer 提取、CompositorEffect 模板 | 后处理效果开发基础 | 🔴 必读 |
| [03_Outline_Depth_Edge_Detection.md](./cases/compositor-effect-library/03_Outline_Depth_Edge_Detection.md) | **深度缓冲边缘检测** - 深度缓冲差分、十字形采样 | 敌方描边、建筑高亮 | 🟡 推荐 |
| [04_Pixelate_Pixelation_Edge_Effect.md](./cases/compositor-effect-library/04_Pixelate_Pixelation_Edge_Effect.md) | **像素化 + 法线边缘** - 双层边缘检测（深度+法线） | 复古风格、受击效果 | 🟡 推荐 |
| [05_Ray_Tracing_Path_Tracing.md](./cases/compositor-effect-library/05_Ray_Tracing_Path_Tracing.md) | **蒙特卡洛路径追踪** - PCG 随机数、天空盒采样 | 过场动画、截图渲染 | 🟢 参考 |
| [06_Sample_Effect_GBuffer_Visualizer.md](./cases/compositor-effect-library/06_Sample_Effect_GBuffer_Visualizer.md) | **G-Buffer 可视化工具** - 通道切换、渲染调试 | 渲染调试必备 | 🟡 推荐 |

**来源**: compositor-effect-library 项目拆解
**文件数**: 6 份

**使用指南**:
1. 先读 **案例1** 理解 ComputeHelper 插件架构
2. 再读 **案例2** 掌握 CompositorEffect 基础模板
3. 根据需求选择 **案例3-5** 中的具体实现
4. 开发期间使用 **案例6** 的 Sample Effect 调试 G-Buffer

---

## 3. 项目结论（outline/）

| 查什么 | 入口 |
| --- | --- |
| 项目编码约定与验证 | [Godot 编码规范汇总](./outline/Godot%20编码规范汇总.md) · [测试引用入口](#testing) |
| 事件 | [事件系统踩坑记录](./outline/事件系统踩坑记录.md) · [事件引用入口](#events) |
| 地图 | [地图系统踩坑记录](./outline/地图系统踩坑记录.md) |
| 数值与战斗平衡 | [游戏平衡踩坑记录](./outline/游戏平衡踩坑记录.md) |
| 环境问题 | [环境与工具链踩坑记录](./outline/环境与工具链踩坑记录.md) |
| 按编号或症状查找 | [踩坑总索引](./outline/踩坑记录完整索引.md) |

历史操作日志保存在本地 `archive/log.md`。

---

## 📊 统计信息

下表保留此前的规模估算，用于了解资料分布。

### 来源（base/）

| 分类 | 文档数 | 字数估算 | 重要性 |
|------|--------|---------|--------|
| Godot 官方文档 | 3,621 | ~500,000+ | 🔴 基础 |
| GDScript 语言参考 | 8 | ~42,000+ | 🔴 必读 |
| Godot 核心系统 | 4 | ~15,000+ | 🔴 必读 |
| 信号与事件系统 | 1 | ~8,000+ | 🔴 必读 |
| 数学与变换 | 5 | ~25,000+ | 🔴 必读 |
| **2D 开发** | **9** | **~50,000+** | 🔴 **必读** |
| **物理系统** | **5** | **~35,000+** | 🔴 **必读** |
| **UI 系统** | **3** | **~20,000+** | 🔴 **必读** |
| **输入系统** | **2** | **~15,000+** | 🔴 **必读** |
| **渲染系统** | **1** | **~5,000+** | 🔴 **必读** |
| **着色器系统** | **4** | **~40,000+** | 🔴 **必读** |
| 踩坑案例 | 16 | 50,000+ | 🔴 必读 |
| 代码规范 | 1 | 25,000+ | 🔴 必读 |
| 案例研究 | 1 | 40,000+ | ⭐⭐⭐ 推荐 |
| 优化技巧 | 3 | 35,000+ | ⭐⭐ 参考 |
| **Steam 平台集成** | **1** | 正文入口 | 通用库维护 |
| **动画系统** | **4** | **~35,000+** | 🔴 **必读** |
| **多人游戏网络** | **1** | 正文入口 | 通用库维护 |
| **音频系统** | **3** | **~25,000+** | 🔴 **必读** |
| **3D 开发** | **5** | **~45,000+** | 🔴 **必读** |
| **资源与 I/O** | **4** | **~30,000+** | 🔴 **必读** |
| **最佳实践** | **3** | **~20,000+** | 🔴 **必读** |
| **调试与测试** | **2** | **~18,000+** | 🔴 **必读** |
| **导出与平台** | **2** | **~15,000+** | 🔴 **必读** |
| **快速参考** | **3** | **~25,000+** | 🔴 **速查** |
| **Base 总计** | **3,716** | **~1,223,000+** | - |

### 整理（cases/ 与 wiki/）

案例库见[案例条目](#26-案例库-cases)，以下为 Wiki 的分类统计。

| 分类 | 已完成 | 规划中 | 完成度 |
|------|--------|--------|--------|
| 实体页面 | **4** | 0 | **100%** |
| 概念页面 | **34** | 0 | **100%** |
| 指南页面 | **46** | 0 | **100%** |
| 对比分析 | **3** | 0 | **100%** |
| 概述页面 | **3** | 0 | **100%** |
| **Wiki 总计** | **90** | **0** | **100%** |

---

## 🎯 快速导航

### 新手路径

1. [Wiki 首页](./wiki/README.md) - 了解知识库结构
2. [GDScript 代码规范](./wiki/concepts/gdscript-standards.md) - 学习代码规范
3. [常见踩坑避雷](./wiki/guides/common-pitfalls.md) - 避免常见错误

### 进阶路径

1. [攻击系统设计](./wiki/concepts/attack-system.md) - 学习系统架构
2. [TestMCP 塔防战斗架构](./wiki/guides/tower-defense-architecture.md) - 项目源码和验证记录
3. [性能优化实战](./base/practical-experiences/optimization-tips/) - 性能调优

---

## 🔄 更新计划

### 待创建页面

#### 实体页面 (entities/)
- ✅ Tower - 防御塔设计（已完成）
- ✅ Enemy - 敌人实体设计（已完成）
- ✅ Projectile - 投射物设计（已完成）
- ✅ Player - 玩家设计（已完成）

#### 对比分析 (comparisons/)
- ✅ 近战 vs 远程攻击对比（已完成）
- ✅ 不同加载方式对比（已完成）
- ✅ 碰撞检测方案对比（已完成）

#### 概述页面 (overviews/)
- ✅ Godot 4.x 游戏开发概述（已完成）
- ✅ 2D 游戏开发概述（已完成）
- ✅ 3D 游戏开发概述（已完成）

---

## 🔗 相关链接

- **Wiki 首页**: [../wiki/](./wiki/)
- **Base 层首页**: [../base/](./base/)
- **Godot 官方文档**: [../base/godot-official-docs/](./base/godot-official-docs/)
- **实战经验汇编**: [../base/practical-experiences/](./base/practical-experiences/)

---

> **最近核对**：2026-11-27（事件、存档、地图、测试）
**维护者**: Knowledge Base Administrator
**知识库版本**: 1.30
