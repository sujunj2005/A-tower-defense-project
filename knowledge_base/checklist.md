# Godot 4.x 知识库重构检查清单

> 版本：1.0 | 创建日期：2026-04-01

---

## 文档质量检查清单

每个文档完成后，需通过以下检查：

### 1. 文件头部检查

- [ ] 标题使用一级标题 `#`
- [ ] 包含适用版本标注
- [ ] 包含来源文件路径
- [ ] 包含目录（如适用）

### 2. 内容结构检查

- [ ] 章节使用二级标题 `##`
- [ ] 小节使用三级标题 `###`
- [ ] 内容层次清晰，不超过 4 级
- [ ] 每个章节有明确的主题

### 3. 代码示例检查

- [ ] 代码块使用正确的语言标记 `gdscript` 或 `glsl`
- [ ] 代码缩进正确（Tab 或 4 空格）
- [ ] 代码可运行（无语法错误）
- [ ] 包含必要的注释

### 4. 表格检查

- [ ] 表格格式正确
- [ ] 表头与内容对齐
- [ ] 表格内容简洁明了

### 5. 踩坑点检查

- [ ] 使用 `> **踩坑点**：` 格式
- [ ] 踩坑点有实际价值
- [ ] 提供解决方案或替代方案

### 6. 链接检查

- [ ] 内部链接有效
- [ ] 外部链接有效（如有）
- [ ] 文件路径引用正确

### 7. 语言检查

- [ ] 使用中文（与用户一致）
- [ ] 术语翻译准确
- [ ] 无错别字

---

## 知识库完整性检查清单

### 按章节检查

#### 01_GDScript_Language
- [ ] 01A_Basics.md - 基础语法
- [ ] 01B_Types_and_Variables.md - 类型和变量
- [ ] 01C_Functions.md - 函数定义
- [ ] 01D_Classes_and_Inheritance.md - 类和继承
- [ ] 01E_Static_Typing.md - 静态类型
- [ ] 01F_Export_Properties.md - 导出属性
- [ ] 01G_Format_Strings.md - 格式化字符串
- [ ] 01H_Style_Guide.md - 代码风格
- [ ] 01I_Warning_System.md - 警告系统

#### 02_Core_Systems
- [ ] 02A_Node_System.md - 节点系统
- [ ] 02B_Scene_Tree.md - 场景树
- [ ] 02C_Scene_Instances.md - 场景实例化
- [ ] 02D_Resources.md - 资源系统
- [ ] 02E_Autoload_Singletons.md - 自动加载单例
- [ ] 02F_Scene_Unique_Nodes.md - 场景唯一节点
- [ ] 02G_Groups.md - 节点组

#### 03_Signals_and_Events
- [ ] 03A_Signals_Basics.md - 信号基础
- [ ] 03B_Custom_Signals.md - 自定义信号
- [ ] 03C_Event_Handling.md - 事件处理

#### 04_Math_and_Transforms
- [ ] 04A_Vector_Math.md - 向量数学
- [ ] 04B_Advanced_Vectors.md - 高级向量
- [ ] 04C_Matrices_and_Transforms.md - 矩阵与变换
- [ ] 04D_Interpolation.md - 插值运算
- [ ] 04E_Beziers_and_Curves.md - 贝塞尔曲线
- [ ] 04F_Random_Numbers.md - 随机数生成

#### 05_2D_Development
- [ ] 05A_Introduction_to_2D.md - 2D 简介
- [ ] 05B_2D_Movement.md - 2D 移动
- [ ] 05C_2D_Transforms.md - 2D 变换
- [ ] 05D_Sprite_Animation.md - 精灵动画
- [ ] 05E_2D_Lights_and_Shadows.md - 2D 光影
- [ ] 05F_Particle_Systems_2D.md - 2D 粒子系统
- [ ] 05G_TileMaps.md - 瓦片地图
- [ ] 05H_Parallax.md - 视差滚动
- [ ] 05I_Custom_Drawing_2D.md - 自定义 2D 绘制

#### 06_Physics_System
- [ ] 06A_Physics_Introduction.md - 物理简介
- [ ] 06B_Collision_Shapes_2D.md - 2D 碰撞形状
- [ ] 06C_Collision_Shapes_3D.md - 3D 碰撞形状
- [ ] 06D_CharacterBody_2D.md - 2D 角色物体
- [ ] 06E_RigidBody.md - 刚体
- [ ] 06F_Area2D.md - 区域检测
- [ ] 06G_RayCasting.md - 射线检测
- [ ] 06H_Physics_Interpolation.md - 物理插值

#### 07_UI_System
- [ ] 07A_UI_Basics.md - UI 基础
- [ ] 07B_Size_and_Anchors.md - 尺寸与锚点
- [ ] 07C_Containers.md - 容器系统
- [ ] 07D_Custom_GUI_Controls.md - 自定义控件
- [ ] 07E_Themes_and_Skinning.md - 主题与皮肤
- [ ] 07F_BBCode_in_RichTextLabel.md - 富文本

#### 08_Input_System
- [ ] 08A_InputEvent.md - 输入事件
- [ ] 08B_InputMap.md - 输入映射
- [ ] 08C_Controller_Input.md - 控制器输入
- [ ] 08D_Custom_Mouse_Cursor.md - 自定义鼠标

#### 09_Rendering
- [ ] 09A_Multiple_Resolutions.md - 多分辨率
- [ ] 09B_Viewports.md - 视口
- [ ] 09C_Renderers.md - 渲染器
- [ ] 09D_HDR_Output.md - HDR 输出

#### 10_Shaders
- [ ] 10A_Shader_Introduction.md - 着色器简介
- [ ] 10B_Shading_Language.md - 着色语言
- [ ] 10C_Canvas_Item_Shader.md - 2D 着色器
- [ ] 10D_Spatial_Shader.md - 3D 着色器
- [ ] 10E_Visual_Shaders.md - 可视化着色器
- [ ] 10F_Post_Processing.md - 后处理

#### 11_Animation_System
- [ ] 11A_Animation_Player.md - AnimationPlayer
- [ ] 11B_Animation_Tree.md - AnimationTree
- [ ] 11C_2D_Skeletons.md - 2D 骨骼
- [ ] 11D_Cutout_Animation.md - 剪纸动画

#### 12_Audio_System
- [ ] 12A_Audio_Buses.md - 音频总线
- [ ] 12B_Audio_Streams.md - 音频流
- [ ] 12C_Audio_Effects.md - 音频效果

#### 13_3D_Development
- [ ] 13A_Introduction_to_3D.md - 3D 简介
- [ ] 13B_3D_Transforms.md - 3D 变换
- [ ] 13C_Lights_and_Shadows.md - 光照与阴影
- [ ] 13D_Standard_Material_3D.md - 标准材质
- [ ] 13E_Particles_3D.md - 3D 粒子

#### 14_Performance
- [ ] 14A_General_Optimization.md - 通用优化
- [ ] 14B_CPU_Optimization.md - CPU 优化
- [ ] 14C_GPU_Optimization.md - GPU 优化
- [ ] 14D_3D_Performance.md - 3D 性能

#### 15_Assets_and_IO
- [ ] 15A_Importing_Images.md - 图片导入
- [ ] 15B_File_System.md - 文件系统
- [ ] 15C_Saving_Games.md - 游戏存档
- [ ] 15D_Background_Loading.md - 后台加载

#### 16_Best_Practices
- [ ] 16A_Scene_Organization.md - 场景组织
- [ ] 16B_Data_Preferences.md - 数据偏好
- [ ] 16C_Logic_Preferences.md - 逻辑偏好

#### 17_Debug_and_Testing
- [ ] 17A_Debugging_Tools.md - 调试工具
- [ ] 17B_Profiler.md - 性能分析器
- [ ] 17C_Error_Handling.md - 错误处理

#### 18_Export_and_Platforms
- [ ] 18A_Exporting_Projects.md - 导出项目
- [ ] 18B_Feature_Tags.md - 功能标签
- [ ] 18C_Platform_Specific.md - 平台特定

#### 19_Common_Pitfalls
- [ ] 19_Pitfall_Records.md - 踩坑记录

#### 20_Quick_Reference
- [ ] 20A_GDScript_Cheat_Sheet.md - GDScript 速查
- [ ] 20B_Common_Patterns.md - 常用模式
- [ ] 20C_API_Commonly_Used.md - 常用 API

---

## 最终验收检查

### 知识库结构
- [ ] 目录结构符合规范
- [ ] 文件命名正确
- [ ] 无冗余文件

### 索引与导航
- [ ] README.md 包含完整索引
- [ ] 快速导航链接有效
- [ ] 按场景导航清晰

### 内容质量
- [ ] 所有文档通过质量检查
- [ ] 无重复内容
- [ ] 无遗漏重要知识点

### 来源标注
- [ ] 所有文档标注来源
- [ ] 来源路径正确

---

## 统计信息

| 类别 | 数量 | 完成数 | 进度 |
|------|------|--------|------|
| P0 文档 | 35 | 0 | 0% |
| P1 文档 | 20 | 0 | 0% |
| P2 文档 | 5 | 0 | 0% |
| **总计** | **60** | **0** | **0%** |
