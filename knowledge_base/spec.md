# Godot 4.x 知识库重构规范

> 版本：1.0 | 创建日期：2026-04-01

---

## 1. 项目概述

### 1.1 目标

将离线 Godot 文档（`F:\迅雷下载\godot-docs-master`）的完整知识系统性地整理到知识库中，确保：
- **全量覆盖**：包含离线文档的所有重要知识点
- **结构清晰**：方便阅读和检索
- **实用导向**：保留代码示例和踩坑点

### 1.2 知识来源

- **主目录**：`F:\迅雷下载\godot-docs-master\tutorials\`
- **文档格式**：RST 源文件（比 HTML 更易解析）

### 1.3 离线文档章节清单

| 章节 | 目录 | 重要程度 | 文件数 |
|------|------|----------|--------|
| GDScript 基础 | scripting/gdscript/ | ⭐⭐⭐ | 10 |
| 节点与场景 | scripting/ | ⭐⭐⭐ | 18 |
| 2D 开发 | 2d/ | ⭐⭐⭐ | 14 |
| 3D 开发 | 3d/ | ⭐⭐ | 20+ |
| 物理系统 | physics/ | ⭐⭐⭐ | 14 |
| 数学运算 | math/ | ⭐⭐⭐ | 7 |
| UI 系统 | ui/ | ⭐⭐⭐ | 5 |
| 着色器 | shaders/ | ⭐⭐ | 20+ |
| 渲染系统 | rendering/ | ⭐⭐ | 6 |
| 动画系统 | animation/ | ⭐⭐ | 8 |
| 音频系统 | audio/ | ⭐⭐ | 7 |
| 输入处理 | inputs/ | ⭐⭐⭐ | 6 |
| 性能优化 | performance/ | ⭐⭐ | 11 |
| 资源管道 | assets_pipeline/ | ⭐⭐ | 4 |
| 国际化 | i18n/ | ⭐ | 5 |
| 编辑器 | editor/ | ⭐ | 13 |
| 导出发布 | export/ | ⭐ | 13 |
| 文件 IO | io/ | ⭐⭐ | 5 |
| 最佳实践 | best_practices/ | ⭐⭐ | 6 |
| 平台特定 | platform/ | ⭐ | 10+ |

---

## 2. 知识库目录结构

```
knowledge_base/
├── README.md                          # 知识库索引和导航
├── 01_GDScript_Language/              # GDScript 语言
│   ├── 01A_Basics.md                  # 基础语法
│   ├── 01B_Types_and_Variables.md     # 类型和变量
│   ├── 01C_Functions.md               # 函数定义
│   ├── 01D_Classes_and_Inheritance.md # 类和继承
│   ├── 01E_Static_Typing.md           # 静态类型
│   ├── 01F_Export_Properties.md       # 导出属性
│   ├── 01G_Format_Strings.md          # 格式化字符串
│   ├── 01H_Style_Guide.md             # 代码风格
│   └── 01I_Warning_System.md          # 警告系统
├── 02_Core_Systems/                   # 核心系统
│   ├── 02A_Node_System.md             # 节点系统
│   ├── 02B_Scene_Tree.md              # 场景树
│   ├── 02C_Scene_Instances.md         # 场景实例化
│   ├── 02D_Resources.md               # 资源系统
│   ├── 02E_Autoload_Singletons.md     # 自动加载单例
│   ├── 02F_Scene_Unique_Nodes.md      # 场景唯一节点
│   └── 02G_Groups.md                  # 节点组
├── 03_Signals_and_Events/             # 信号与事件
│   ├── 03A_Signals_Basics.md          # 信号基础
│   ├── 03B_Custom_Signals.md          # 自定义信号
│   └── 03C_Event_Handling.md          # 事件处理
├── 04_Math_and_Transforms/            # 数学与变换
│   ├── 04A_Vector_Math.md             # 向量数学
│   ├── 04B_Advanced_Vectors.md        # 高级向量
│   ├── 04C_Matrices_and_Transforms.md # 矩阵与变换
│   ├── 04D_Interpolation.md           # 插值运算
│   ├── 04E_Beziers_and_Curves.md      # 贝塞尔曲线
│   └── 04F_Random_Numbers.md          # 随机数生成
├── 05_2D_Development/                 # 2D 开发
│   ├── 05A_Introduction_to_2D.md      # 2D 简介
│   ├── 05B_2D_Movement.md             # 2D 移动
│   ├── 05C_2D_Transforms.md           # 2D 变换
│   ├── 05D_Sprite_Animation.md        # 精灵动画
│   ├── 05E_2D_Lights_and_Shadows.md   # 2D 光影
│   ├── 05F_Particle_Systems_2D.md     # 2D 粒子系统
│   ├── 05G_TileMaps.md                # 瓦片地图
│   ├── 05H_Parallax.md                # 视差滚动
│   └── 05I_Custom_Drawing_2D.md       # 自定义 2D 绘制
├── 06_Physics_System/                 # 物理系统
│   ├── 06A_Physics_Introduction.md    # 物理简介
│   ├── 06B_Collision_Shapes_2D.md     # 2D 碰撞形状
│   ├── 06C_Collision_Shapes_3D.md     # 3D 碰撞形状
│   ├── 06D_CharacterBody_2D.md        # 2D 角色物体
│   ├── 06E_RigidBody.md               # 刚体
│   ├── 06F_Area2D.md                  # 区域检测
│   ├── 06G_RayCasting.md              # 射线检测
│   └── 06H_Physics_Interpolation.md   # 物理插值
├── 07_UI_System/                      # UI 系统
│   ├── 07A_UI_Basics.md               # UI 基础
│   ├── 07B_Size_and_Anchors.md        # 尺寸与锚点
│   ├── 07C_Containers.md              # 容器系统
│   ├── 07D_Custom_GUI_Controls.md     # 自定义控件
│   ├── 07E_Themes_and_Skinning.md     # 主题与皮肤
│   └── 07F_BBCode_in_RichTextLabel.md # 富文本
├── 08_Input_System/                   # 输入系统
│   ├── 08A_InputEvent.md              # 输入事件
│   ├── 08B_InputMap.md                # 输入映射
│   ├── 08C_Controller_Input.md        # 控制器输入
│   └── 08D_Custom_Mouse_Cursor.md     # 自定义鼠标
├── 09_Rendering/                      # 渲染系统
│   ├── 09A_Multiple_Resolutions.md    # 多分辨率
│   ├── 09B_Viewports.md               # 视口
│   ├── 09C_Renderers.md               # 渲染器
│   └── 09D_HDR_Output.md              # HDR 输出
├── 10_Shaders/                        # 着色器
│   ├── 10A_Shader_Introduction.md     # 着色器简介
│   ├── 10B_Shading_Language.md        # 着色语言
│   ├── 10C_Canvas_Item_Shader.md      # 2D 着色器
│   ├── 10D_Spatial_Shader.md          # 3D 着色器
│   ├── 10E_Visual_Shaders.md          # 可视化着色器
│   └── 10F_Post_Processing.md         # 后处理
├── 11_Animation_System/               # 动画系统
│   ├── 11A_Animation_Player.md        # AnimationPlayer
│   ├── 11B_Animation_Tree.md          # AnimationTree
│   ├── 11C_2D_Skeletons.md            # 2D 骨骼
│   └── 11D_Cutout_Animation.md        # 剪纸动画
├── 12_Audio_System/                   # 音频系统
│   ├── 12A_Audio_Buses.md             # 音频总线
│   ├── 12B_Audio_Streams.md           # 音频流
│   └── 12C_Audio_Effects.md           # 音频效果
├── 13_3D_Development/                 # 3D 开发
│   ├── 13A_Introduction_to_3D.md      # 3D 简介
│   ├── 13B_3D_Transforms.md           # 3D 变换
│   ├── 13C_Lights_and_Shadows.md      # 光照与阴影
│   ├── 13D_Standard_Material_3D.md    # 标准材质
│   └── 13E_Particles_3D.md            # 3D 粒子
├── 14_Performance/                    # 性能优化
│   ├── 14A_General_Optimization.md    # 通用优化
│   ├── 14B_CPU_Optimization.md        # CPU 优化
│   ├── 14C_GPU_Optimization.md        # GPU 优化
│   └── 14D_3D_Performance.md          # 3D 性能
├── 15_Assets_and_IO/                  # 资源与 IO
│   ├── 15A_Importing_Images.md        # 图片导入
│   ├── 15B_File_System.md             # 文件系统
│   ├── 15C_Saving_Games.md            # 游戏存档
│   └── 15D_Background_Loading.md      # 后台加载
├── 16_Best_Practices/                 # 最佳实践
│   ├── 16A_Scene_Organization.md      # 场景组织
│   ├── 16B_Data_Preferences.md        # 数据偏好
│   └── 16C_Logic_Preferences.md       # 逻辑偏好
├── 17_Debug_and_Testing/              # 调试与测试
│   ├── 17A_Debugging_Tools.md         # 调试工具
│   ├── 17B_Profiler.md                # 性能分析器
│   └── 17C_Error_Handling.md          # 错误处理
├── 18_Export_and_Platforms/           # 导出与平台
│   ├── 18A_Exporting_Projects.md      # 导出项目
│   ├── 18B_Feature_Tags.md            # 功能标签
│   └── 18C_Platform_Specific.md       # 平台特定
├── 19_Common_Pitfalls/                # 常见踩坑
│   └── 19_Pitfall_Records.md          # 踩坑记录
└── 20_Quick_Reference/                # 快速参考
    ├── 20A_GDScript_Cheat_Sheet.md    # GDScript 速查
    ├── 20B_Common_Patterns.md         # 常用模式
    └── 20C_API_Commonly_Used.md       # 常用 API
```

---

## 3. 文档格式规范

### 3.1 文件头部

```markdown
# 标题

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/xxx/xxx.rst

---

## 目录

1. [章节1](#章节1)
2. [章节2](#章节2)
...

---
```

### 3.2 内容结构

每个知识点包含：
1. **概念说明**：简明扼要的解释
2. **代码示例**：实际可运行的代码
3. **参数说明**：表格形式的参数列表
4. **踩坑点**：使用 `> **踩坑点**：` 标注

### 3.3 代码块格式

```gdscript
# 代码说明
func example():
    pass
```

### 3.4 踩坑点格式

```markdown
> **踩坑点**：描述常见错误和解决方案。
```

### 3.5 表格格式

| 参数 | 类型 | 说明 |
|------|------|------|
| name | String | 名称 |

---

## 4. 索引与导航

### 4.1 README.md 结构

```markdown
# Godot 4.x GDScript 知识库

## 快速导航

### 按主题
- [GDScript 语言](01_GDScript_Language/)
- [核心系统](02_Core_Systems/)
...

### 按场景
- 我想实现 2D 移动 → [2D 移动](05_2D_Development/05B_2D_Movement.md)
- 我想处理碰撞 → [物理系统](06_Physics_System/)
...

## 知识库统计
- 文档数量：XX 个
- 覆盖主题：XX 个
```

---

## 5. 实施原则

### 5.1 优先级

1. **P0（必须）**：GDScript、核心系统、2D、物理、UI、输入
2. **P1（重要）**：数学、渲染、着色器、动画、性能
3. **P2（可选）**：3D、音频、导出、平台特定

### 5.2 内容取舍

- **保留**：核心概念、代码示例、最佳实践、踩坑点
- **精简**：编辑器操作截图、平台特定细节
- **舍弃**：过时内容、重复内容

### 5.3 命名规范

- 目录：`数字_英文名称/`
- 文件：`数字字母_英文名称.md`
- 使用下划线分隔

---

## 6. 质量检查

每个文档完成后需检查：
- [ ] 来源文件标注正确
- [ ] 代码示例可运行
- [ ] 踩坑点已标注
- [ ] 表格格式正确
- [ ] 链接有效
