# Godot 4.x 快速参考 - GDScript 速查表

> 适用版本：Godot 4.x | 来源：知识库整合

---

## 关键字速查

| 类别 | 关键字 |
|------|--------|
| 条件 | `if`, `elif`, `else`, `match` |
| 循环 | `for`, `while` |
| 流程控制 | `break`, `continue`, `return`, `pass` |
| 类 | `class`, `class_name`, `extends`, `is`, `as` |
| 函数 | `func`, `static`, `signal`, `await` |
| 变量 | `var`, `const`, `enum`, `self`, `super` |
| 导出 | `@export`, `@onready`, `@tool`, `@icon` |

## 操作符优先级（高→低）

```
() [] .          → 访问
**               → 幂运算
~ + - (一元)      → 取反、正负
* / %             → 乘除取余
+ -               → 加减
<< >>             → 位移
& ^ |             → 位操作
== != < > <= >=  → 比较
in not in         → 包含
not !             → 逻辑非
and &&            → 逻辑与
or ||             → 逻辑或
if else           → 三元运算符
as                → 类型转换
= += -= *= /=    → 赋值
```

## 内置常量

| 常量 | 值 |
|------|-----|
| PI | 3.14159... |
| TAU | 6.28318... |
| INF | ∞ |
| NAN | NaN |
| true / false | 布尔值 |
| null | 空值 |

## 字面量格式

| 类型 | 示例 |
|------|------|
| 整数 | `42`, `0xff`, `0b1010` |
| 浮点数 | `3.14`, `1.0e-10` |
| 字符串 | `"Hello"`, `'Hi'`, `"""多行"""` |
| StringName | `&"name"` |
| NodePath | `^"Node/Label"` |
| 数组 | `[1, 2, 3]` |
| 字典 | `{"key": "value", 2: 3}` |
| 数字分隔 | `12_345_678` |

## 常用内置类型

### 基本类型
`bool`, `int`, `float`, `String`, `StringName`, `NodePath`, `null`

### 向量
`Vector2(i)`, `Vector3(i)`, `Vector4(i)`, `Rect2`, `Plane`

### 引擎类型
`Color`, `RID`, `Object`, `Callable`, `Signal`, `Dictionary`, `Array`
`PackedByteArray`, `PackedInt32Array`, `PackedFloat32Array`
`PackedStringArray`, `PackedVector2Array`, `PackedVector3Array`, `PackedColorArray`

## 常用函数速查

### 数学
```gdscript
abs(x), absi(x), absf(x)          # 绝对值
clamp(x, min, max)                 # 限制范围
lerp(a, b, t)                       # 线性插值
smoothstep(edge0, edge1, x)        # 平滑阶跃
ease(x, bias)                       # 缓动函数
randi(), randf(), randfn(mean, dev)  # 随机数
randi_range(from, to)               # 范围随机整数
randf_range(from, to)               # 范围随机浮点
linear_to_db(linear)                # 线性转分贝
db_to_linear(db)                    # 分贝转线性
```

### 向量
```gdscript
v.length(), v.length_squared()      # 长度
v.normalized()                        # 归一化
v.direction_to(to)                  # 方向向量
v.distance_to(to)                    # 距离
v.dot(b)                             # 点积
v.cross(b)                           # 叉积
v.lerp(b, t)                         # 线性插值
v.bounce(normal)                     # 反射
v.angle()                            # 角度
v.rotated(angle)                     # 旋转
```

### 输入
```gdscript
Input.is_action_pressed(action)       # 按下瞬间
Input.is_action_just_pressed(action)  # 按下（仅一次）
Input.is_action_just_released(action) # 释放
Input.get_vector(left, right, up, down) # 方向向量
Input.get_axis(neg, pos)              # 单轴输入
Input.get_action_strength(action)     # 强度
```

### 文件
```gdscript
FileAccess.open(path, mode)           # 打开文件
FileAccess.file_exists(path)           # 检查存在
DirAccess.open(path)                   # 打开目录
DirAccess.dir_exists(path)             # 目录存在
DirAccess.make_dir(name)               # 创建目录
```

### JSON
```gdscript
JSON.stringify(data, indent)           # 序列化
JSON.new().parse(text)                 # 解析
JSON.parse_string(text)                # 解析字符串
```

## 信号连接

```gdscript
# 编辑器连接
signal_name.connect(_on_signal_name)

# 代码连接
button.pressed.connect(_on_pressed)

# 绑定参数
button.pressed.connect(_on_button.bind("Button1"))

# 断开
button.pressed.disconnect(_on_pressed)
```

## 常用路径语法

```gdscript
$NodePath              # 等价于 get_node("NodePath")
%UniqueNode           # 场景唯一节点
get_node("/root/Main")  # 绝对路径
get_node("..")          # 父节点
get_node("../Sibling")   # 兄弟节点
```

## 常用 Node 方法

```gdscript
get_node(path)           # 获取子节点
find_child(name)         # 查找子节点
has_node(path)           # 检查子节点
get_children()           # 所有子节点
add_child(node)          # 添加子节点
remove_child(node)       # 移除子节点
is_inside_tree()         # 是否在场景树中
queue_free()             # 安全删除
is_instance_valid(obj)   # 实例有效且未排队删除
```

## 常用 PhysicsBody2D 方法

```gdscript
move_and_slide()                        # 移动并滑动
move_and_collide(vel)                   # 移动并检测碰撞
is_on_floor() / is_on_wall() / is_on_ceiling()  # 接触检测
get_slide_collision_count()            # 碰撞数量
get_slide_collision(index)              # 获取碰撞信息
```

## 常用 CanvasItem 绘制方法

```gdscript
draw_line(from, to, color, width)       # 线条
draw_rect(rect, color)                   # 矩形轮廓
draw_rect_filled(rect, color)            # 填充矩形
draw_circle(pos, radius, color)          # 圆
draw_arc(center, radius, from, to, points, color)  # 弧线
draw_polygon(points, color)             # 多边形
draw_texture(texture, pos)               # 纹理
draw_string(font, pos, text, ...)        # 文字
queue_redraw()                            # 触发重绘
```

---
*此文档为快速参考，详细内容请查看对应章节。*
