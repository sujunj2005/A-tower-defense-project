# Godot 4.x 知识库重构任务清单

> 版本：1.0 | 创建日期：2026-04-01

---

## 阶段一：准备工作

- [ ] 1.1 备份现有知识库
- [ ] 1.2 创建新目录结构
- [ ] 1.3 创建 README.md 索引文件

---

## 阶段二：GDScript 语言（P0）

### 2.1 基础语法
- [ ] 读取 `gdscript_basics.rst`
- [ ] 创建 `01A_Basics.md` - 关键字、操作符、字面量
- [ ] 创建 `01B_Types_and_Variables.md` - 内置类型、变量定义
- [ ] 创建 `01C_Functions.md` - 函数、Lambda、静态函数

### 2.2 类与继承
- [ ] 读取 `gdscript_basics.rst`（类相关部分）
- [ ] 创建 `01D_Classes_and_Inheritance.md` - 类定义、继承、内部类

### 2.3 静态类型与导出
- [ ] 读取 `static_typing.rst`
- [ ] 整合现有 `01C_Static_Typing.md`
- [ ] 读取 `gdscript_exports.rst`
- [ ] 整合现有 `01D_Export_Properties.md`

### 2.4 其他
- [ ] 读取 `gdscript_format_string.rst`
- [ ] 创建 `01G_Format_Strings.md`
- [ ] 读取 `gdscript_styleguide.rst`
- [ ] 创建 `01H_Style_Guide.md`
- [ ] 读取 `warning_system.rst`
- [ ] 创建 `01I_Warning_System.md`

---

## 阶段三：核心系统（P0）

### 3.1 节点系统
- [ ] 读取 `nodes_and_scene_instances.rst`
- [ ] 整合现有 `02B_Node_Operations.md`
- [ ] 创建 `02A_Node_System.md`

### 3.2 场景树
- [ ] 读取 `scene_tree.rst`
- [ ] 创建 `02B_Scene_Tree.md`

### 3.3 资源与单例
- [ ] 读取 `resources.rst`
- [ ] 创建 `02D_Resources.md`
- [ ] 读取 `singletons_autoload.rst`
- [ ] 创建 `02E_Autoload_Singletons.md`

### 3.4 其他核心
- [ ] 读取 `scene_unique_nodes.rst`
- [ ] 创建 `02F_Scene_Unique_Nodes.md`
- [ ] 读取 `groups.rst`
- [ ] 创建 `02G_Groups.md`

---

## 阶段四：信号系统（P0）

- [ ] 读取 `gdscript_basics.rst`（信号部分）
- [ ] 整合现有 `03_Signals_and_Events.md`
- [ ] 读取 `instancing_with_signals.rst`
- [ ] 完善 `03C_Event_Handling.md`

---

## 阶段五：数学与变换（P0）

### 5.1 向量
- [ ] 读取 `vector_math.rst`
- [ ] 整合现有 `01B_Math_and_Vectors.md`
- [ ] 创建 `04A_Vector_Math.md`
- [ ] 读取 `vectors_advanced.rst`
- [ ] 创建 `04B_Advanced_Vectors.md`

### 5.2 变换与插值
- [ ] 读取 `matrices_and_transforms.rst`
- [ ] 创建 `04C_Matrices_and_Transforms.md`
- [ ] 读取 `interpolation.rst`
- [ ] 创建 `04D_Interpolation.md`

### 5.3 曲线与随机
- [ ] 读取 `beziers_and_curves.rst`
- [ ] 创建 `04E_Beziers_and_Curves.md`
- [ ] 读取 `random_number_generation.rst`
- [ ] 创建 `04F_Random_Numbers.md`

---

## 阶段六：2D 开发（P0）

### 6.1 基础
- [ ] 读取 `introduction_to_2d.rst`
- [ ] 创建 `05A_Introduction_to_2D.md`
- [ ] 读取 `2d_movement.rst`
- [ ] 整合现有 `04B_2D_Movement.md`
- [ ] 读取 `2d_transforms.rst`
- [ ] 创建 `05C_2D_Transforms.md`

### 6.2 动画与粒子
- [ ] 读取 `2d_sprite_animation.rst`
- [ ] 创建 `05D_Sprite_Animation.md`
- [ ] 读取 `particle_systems_2d.rst`
- [ ] 创建 `05F_Particle_Systems_2D.md`

### 6.3 其他 2D
- [ ] 读取 `2d_lights_and_shadows.rst`
- [ ] 创建 `05E_2D_Lights_and_Shadows.md`
- [ ] 读取 `using_tilemaps.rst`
- [ ] 创建 `05G_TileMaps.md`
- [ ] 读取 `2d_parallax.rst`
- [ ] 创建 `05H_Parallax.md`
- [ ] 读取 `custom_drawing_in_2d.rst`
- [ ] 创建 `05I_Custom_Drawing_2D.md`

---

## 阶段七：物理系统（P0）

### 7.1 基础
- [ ] 读取 `physics_introduction.rst`
- [ ] 创建 `06A_Physics_Introduction.md`
- [ ] 读取 `collision_shapes_2d.rst`
- [ ] 创建 `06B_Collision_Shapes_2D.md`
- [ ] 读取 `collision_shapes_3d.rst`
- [ ] 创建 `06C_Collision_Shapes_3D.md`

### 7.2 物理节点
- [ ] 读取 `using_character_body_2d.rst`
- [ ] 创建 `06D_CharacterBody_2D.md`
- [ ] 读取 `rigid_body.rst`
- [ ] 创建 `06E_RigidBody.md`
- [ ] 读取 `using_area_2d.rst`
- [ ] 创建 `06F_Area2D.md`
- [ ] 读取 `ray-casting.rst`
- [ ] 创建 `06G_RayCasting.md`

---

## 阶段八：UI 系统（P0）

### 8.1 基础
- [ ] 整合现有 `06A_Containers.md`
- [ ] 整合现有 `06B_Size_and_Anchors.md`
- [ ] 整合现有 `06C_Custom_GUI_Controls.md`

### 8.2 主题
- [ ] 读取 `gui_skinning.rst`
- [ ] 创建 `07E_Themes_and_Skinning.md`
- [ ] 读取 `bbcode_in_richtextlabel.rst`
- [ ] 创建 `07F_BBCode_in_RichTextLabel.md`

---

## 阶段九：输入系统（P0）

- [ ] 读取 `inputevent.rst`
- [ ] 创建 `08A_InputEvent.md`
- [ ] 读取 `input_examples.rst`
- [ ] 创建 `08B_InputMap.md`
- [ ] 读取 `controller_features.rst`
- [ ] 创建 `08C_Controller_Input.md`

---

## 阶段十：渲染系统（P1）

- [ ] 整合现有 `07A_Multiple_Resolutions.md`
- [ ] 读取 `viewports.rst`
- [ ] 创建 `09B_Viewports.md`
- [ ] 读取 `renderers.rst`
- [ ] 创建 `09C_Renderers.md`

---

## 阶段十一：着色器（P1）

### 11.1 基础
- [ ] 整合现有 `07B_Shader_Language.md`
- [ ] 读取 `introduction_to_shaders.rst`
- [ ] 完善 `10A_Shader_Introduction.md`

### 11.2 着色器类型
- [ ] 读取 `canvas_item_shader.rst`
- [ ] 创建 `10C_Canvas_Item_Shader.md`
- [ ] 读取 `spatial_shader.rst`
- [ ] 创建 `10D_Spatial_Shader.md`

### 11.3 其他
- [ ] 读取 `visual_shaders.rst`
- [ ] 创建 `10E_Visual_Shaders.md`
- [ ] 读取 `custom_postprocessing.rst`
- [ ] 创建 `10F_Post_Processing.md`

---

## 阶段十二：动画系统（P1）

- [ ] 读取 `introduction.rst`（animation）
- [ ] 创建 `11A_Animation_Player.md`
- [ ] 读取 `animation_tree.rst`
- [ ] 创建 `11B_Animation_Tree.md`
- [ ] 读取 `2d_skeletons.rst`
- [ ] 创建 `11C_2D_Skeletons.md`

---

## 阶段十三：音频系统（P1）

- [ ] 读取 `audio_buses.rst`
- [ ] 创建 `12A_Audio_Buses.md`
- [ ] 读取 `audio_streams.rst`
- [ ] 创建 `12B_Audio_Streams.md`
- [ ] 读取 `audio_effects.rst`
- [ ] 创建 `12C_Audio_Effects.md`

---

## 阶段十四：3D 开发（P1）

- [ ] 读取 `introduction_to_3d.rst`
- [ ] 创建 `13A_Introduction_to_3D.md`
- [ ] 读取 `using_transforms.rst`（3D）
- [ ] 创建 `13B_3D_Transforms.md`
- [ ] 读取 `lights_and_shadows.rst`
- [ ] 创建 `13C_Lights_and_Shadows.md`
- [ ] 读取 `standard_material_3d.rst`
- [ ] 创建 `13D_Standard_Material_3D.md`

---

## 阶段十五：性能优化（P1）

- [ ] 读取 `general_optimization.rst`
- [ ] 创建 `14A_General_Optimization.md`
- [ ] 读取 `cpu_optimization.rst`
- [ ] 创建 `14B_CPU_Optimization.md`
- [ ] 读取 `gpu_optimization.rst`
- [ ] 创建 `14C_GPU_Optimization.md`

---

## 阶段十六：资源与 IO（P1）

- [ ] 读取 `importing_images.rst`
- [ ] 创建 `15A_Importing_Images.md`
- [ ] 读取 `filesystem.rst`
- [ ] 创建 `15B_File_System.md`
- [ ] 读取 `saving_games.rst`
- [ ] 创建 `15C_Saving_Games.md`

---

## 阶段十七：最佳实践（P1）

- [ ] 读取 `scene_organization.rst`
- [ ] 创建 `16A_Scene_Organization.md`
- [ ] 读取 `data_preferences.rst`
- [ ] 创建 `16B_Data_Preferences.md`
- [ ] 读取 `logic_preferences.rst`
- [ ] 创建 `16C_Logic_Preferences.md`

---

## 阶段十八：调试与测试（P1）

- [ ] 读取 `overview_of_debugging_tools.rst`
- [ ] 创建 `17A_Debugging_Tools.md`
- [ ] 读取 `the_profiler.rst`
- [ ] 创建 `17B_Profiler.md`

---

## 阶段十九：导出与平台（P2）

- [ ] 读取 `exporting_projects.rst`
- [ ] 创建 `18A_Exporting_Projects.md`
- [ ] 读取 `feature_tags.rst`
- [ ] 创建 `18B_Feature_Tags.md`

---

## 阶段二十：踩坑记录与快速参考

### 20.1 踩坑记录
- [ ] 整合现有 `08_Common_Pitfalls.md`
- [ ] 从所有文档提取踩坑点
- [ ] 创建 `19_Pitfall_Records.md`

### 20.2 快速参考
- [ ] 创建 `20A_GDScript_Cheat_Sheet.md`
- [ ] 创建 `20B_Common_Patterns.md`
- [ ] 创建 `20C_API_Commonly_Used.md`

---

## 阶段二十一：清理与验证

- [ ] 删除旧目录结构
- [ ] 验证所有链接有效
- [ ] 更新 README.md 索引
- [ ] 最终质量检查

---

## 统计

- 总任务数：约 100 个
- 预计文档数：约 60 个
- 优先级 P0：约 35 个文档
- 优先级 P1：约 20 个文档
- 优先级 P2：约 5 个文档
