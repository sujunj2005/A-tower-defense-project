# Godot 4.x API 常用速查

> 适用版本：Godot 4.x | 来源：知识库整合

---

## Node 核心方法

```gdscript
# 节点操作
add_child(node), remove_child(node)
get_node(path), get_node_or_null(path)
has_node(path), find_child(name)
get_children(), get_parent()
is_inside_tree(), is_ancestor_of(node)
move_child(child, to_index)
duplicate(flags), create_instance()

# 场景树
get_tree(), get_viewport(), get_window()
get_path(), get_path_to(node)
is_in_group(name), add_to_group(name)
remove_from_group(name)
get_groups()

# 生命周期
_enter_tree(), _exit_tree()
_ready(), _process(delta), _physics_process(delta)
_notification(what)

# 输入
_input(event), _unhandled_input(event)
_gui_input(event), _shortcut_input(event)
```

## SceneTree 方法

```gdscript
get_tree().change_scene_to_file(path)
get_tree().change_scene_to_packed(scene)
get_tree().reload_current_scene()
get_tree().quit() / get_tree().quit(code)

get_tree().root
get_tree().paused = true/false
get_tree().current_scene
```

## Resource 加载

```gdscript
load(path)          # 运行时加载
preload(path)       # 编译时加载（常量路径）
ResourceLoader.load(path)  # 更灵活的加载方式

# 场景实例化
scene.instantiate()

# 资源释放
ResourceLoader.unload_ref(resource)
```

## Input 全局方法

```gdscript
Input.is_action_pressed(action)
Input.is_action_just_pressed(action)
Input.is_action_just_released(action)
Input.get_action_strength(action)
Input.get_vector(neg_x, pos_x, neg_y, pos_y)
Input.get_axis(neg, pos)
Input.is_key_pressed(keycode)
Input.is_mouse_button_pressed(button)
Input.get_mouse_position()
Input.set_mouse_mode(mode)
Input.parse_input_event(event)
```

## Math 工具函数

```gdscript
# 角度转换
deg_to_rad(deg), rad_to_deg(rad)
lerp_angle(from, to, weight)
fmod(x, y), fposmod(x, y)
wrapf(value, min, max)

# 向量工具
Vector2(angle), Vector2.from_angle(angle)
Vector3(forward, up), Vector3.UP, Vector3.RIGHT
Vector3.FORWARD, Vector3.BACK, Vector3.LEFT
Basis(axis, angle), Basis.from_euler(euler)
Quaternion(axis, angle), Quaternion.from_euler(euler)
Transform3D(), Transform3D.IDENTITY
```

## 时间相关

```gdscript
Time.get_ticks_msec()      # 自启动毫秒数
Time.get_time_dict()       # 详细时间信息
Engine.get_frames_per_second()  # 目标帧率
Engine.get_physics_ticks_per_second()  # 物理帧率
```

## OS 系统方法

```gdscript
OS.get_user_data_dir()     # 用户数据目录
OS.get_executable_path()   # 可执行文件路径
OS.get_system_dir(dir)     # 系统目录
OS.get_environment(var)     # 环境变量
OS.execute(cmd)             # 执行命令
OS.delay_msec(msec)         # 延迟执行
OS.request_attention()      # 请求用户注意
OS.shell_open(uri)          # 打开外部程序
```

## Debug 调试

```gdscript
push_error(message)         # 错误输出
push_warning(message)       # 警告输出
assert(condition, message)  # 断言
breakpoint                  # 断点
print_debug(...)            # 调试输出
print_stack()               # 打印调用栈
printerr(...)               # 错误输出
```

## 文件系统快捷

```gdscript
DirAccess.open_absolute(path)
DirAccess.dir_exists(path)
DirAccess.make_dir(path)
DirAccess.copy(from, to)
DirAccess.remove(path)
DirAccess.rename(old, new)
DirAccess.list_dir_begin/end()
```

---
*此文档为常用 API 的快速索引。*
