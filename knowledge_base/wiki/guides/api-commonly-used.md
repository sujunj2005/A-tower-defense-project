# Godot 常用 API 速查

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 19C_API_Commonly_Used.md](../../base/quick-reference/19C_API_Commonly_Used.md)  
> **重要性**: 🟡 推荐 - 高频 API 快速查询

---

## 📋 概述

本速查表整理了 Godot 开发中最常用的 API，按功能分类，方便快速查阅。

---

## 🎯 输入处理

```gdscript
# 按键检测
Input.is_action_pressed("move_right")
Input.is_action_just_pressed("jump")
Input.is_action_just_released("attack")

# 获取输入轴
Input.get_axis("move_left", "move_right")
Input.get_vector("move_left", "move_right", "move_up", "move_down")

# 鼠标
Input.get_mouse_position()
Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

# 触摸
if InputEventScreenTouch:
    print("触摸事件")
```

---

## 🎯 场景树操作

```gdscript
# 获取节点
$NodePath
get_node("NodePath")
get_node_or_null("NodePath")

# 获取子节点
get_children()
get_child(index)

# 添加/删除节点
add_child(node)
remove_child(node)
node.queue_free()

# 场景切换
get_tree().change_scene_to_file("res://level2.tscn")
get_tree().change_scene_to_packed(preload("res://level2.tscn"))
get_tree().reload_current_scene()

# 分组
add_to_group("enemies")
get_tree().get_nodes_in_group("enemies")
get_tree().call_group("enemies", "take_damage", 10)
```

---

## 🎯 数学和向量

```gdscript
# 向量运算
var v = Vector2(3, 4)
v.length()          # 5
v.normalized()      # 单位向量
v.dot(other)        # 点积
v.cross(other)      # 叉积（2D 返回标量）
v.angle()           # 角度（弧度）
v.distance_to(other) # 距离

# 向量插值
v.lerp(target, 0.1)  # 线性插值
v.slerp(target, 0.1) # 球面插值

# 角度转换
deg_to_rad(180)     # 3.14159
rad_to_deg(PI)      # 180.0

# 旋转
v.rotated(deg_to_rad(90))  # 旋转 90 度
```

---

## 🎯 时间相关

```gdscript
# 帧时间
delta  # _process 和 _physics_process 的参数

# 时间获取
Time.get_ticks_msec()      # 毫秒
Time.get_ticks_usec()      # 微秒
Time.get_unix_time_from_system()  # Unix 时间戳

# 延时
await get_tree().create_timer(2.0).timeout
await get_tree().create_timer(1.0, false).timeout  # 不处理暂停

# 调用延迟
call_deferred("method_name")
set_deferred("property", value)
```

---

## 🎯 文件操作

```gdscript
# 文件读写
var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
file.store_string("data")
file.store_var(data)
file.close()

file = FileAccess.open("user://save.dat", FileAccess.READ)
var data = file.get_var()
file.close()

# 目录操作
var dir = DirAccess.open("res://")
dir.list_dir_begin()
var filename = dir.get_next()
while filename != "":
    print(filename)
    filename = dir.get_next()

dir.make_dir("user://new_folder")
dir.remove("user://file.txt")
```

---

## 🎯 音频播放

```gdscript
# 播放音效
$AudioStreamPlayer.stream = preload("res://audio/sfx.ogg")
$AudioStreamPlayer.play()
$AudioStreamPlayer.stop()

# 音量控制
$AudioStreamPlayer.volume_db = -10

# 总线控制
AudioServer.set_bus_volume_db(0, -5)  # Master 总线
AudioServer.set_bus_mute(1, true)     # 静音 BGM 总线
```

---

## 🎯 调试工具

```gdscript
# 输出
print("普通输出")
print_rich("[color=red]彩色输出[/color]")
printerr("错误输出")
push_warning("警告")
push_error("严重错误")

# 断言
assert(condition, "错误消息")

# 性能
Performance.get_monitor(Performance.FPS)
Performance.get_monitor(Performance.OBJECT_COUNT)
```

---

## 🔗 相关资源

### Base 层
- [19C_API_Commonly_Used.md](../../base/quick-reference/19C_API_Commonly_Used.md) - 常用 API 详解

### Wiki 层
- [GDScript 速查表](../guides/gdscript-cheatsheet.md) - 语法速查
- [常用模式指南](../guides/common-patterns-guide.md) - 设计模式

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
