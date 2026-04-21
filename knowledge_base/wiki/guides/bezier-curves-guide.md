# 贝塞尔曲线指南

> **来源**: [04E_Beziers_and_Curves.md](../../base/math-transforms/04E_Beziers_and_Curves.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📚 概述

贝塞尔曲线是**自然几何形状的数学近似**。我们使用它们以尽可能少的信息表示曲线，并且具有很高的灵活性。

贝塞尔曲线依赖于插值，将多个步骤组合在一起以创建平滑曲线。

**应用场景**:
- 路径规划（敌人沿曲线移动）
- 动画轨迹（投射物飞行路径）
- UI 动画（平滑的缓动效果）
- 地形生成（自然曲线）
- 字体设计（字形轮廓）

---

## 🎯 核心概念

### 1. 二次贝塞尔曲线

#### 1.1 三个点

二次贝塞尔需要三个点：
- `p0`: **起点**
- `p1`: **控制点**（影响曲线曲率）
- `p2`: **终点**

#### 1.2 实现代码

```gdscript
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    var r = q0.lerp(q1, t)
    return r
```

#### 1.3 工作原理

1. 首先在 `p0` 和 `p1` 之间插值，得到 `q0`
2. 然后在 `p1` 和 `p2` 之间插值，得到 `q1`
3. 最后在 `q0` 和 `q1` 之间插值，得到最终点 `r`

**几何理解**:
```
p0 ---- q0 ---- r ---- q1 ---- p2
         \      /       \
          \    /         \
           p1 ----------- 
```

---

### 2. 三次贝塞尔曲线

#### 2.1 四个点

三次贝塞尔需要四个点：
- `p0`: **起点**
- `p1`: **第一个控制点**（影响起点切线方向）
- `p2`: **第二个控制点**（影响终点切线方向）
- `p3`: **终点**

#### 2.2 实现代码

```gdscript
func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    var q2 = p2.lerp(p3, t)
    var r0 = q0.lerp(q1, t)
    var r1 = q1.lerp(q2, t)
    var s = r0.lerp(r1, t)
    return s
```

#### 2.3 工作原理

三次贝塞尔是二次贝塞尔的扩展：
1. 第一层插值：`q0`, `q1`, `q2`（3 个点）
2. 第二层插值：`r0`, `r1`（2 个点）
3. 第三层插值：`s`（最终点）

**几何理解**:
```
p0 ---- q0 ---- r0 ---- s ---- r1 ---- q2
         \      /                 \
          \    /                   \
           p1 ---- q1 ------------- p2
```

---

## 🔧 实际应用

### 3.1 绘制贝塞尔曲线

```gdscript
func _draw():
    var p0 = Vector2(0, 0)
    var p1 = Vector2(100, 50)
    var p2 = Vector2(200, 0)
    
    var points = []
    for t in range(0, 101):
        var tt = t / 100.0
        var point = _quadratic_bezier(p0, p1, p2, tt)
        points.append(point)
    
    draw_polyline(points, Color.RED, 2)
```

**说明**:
- 采样 101 个点（t 从 0 到 1）
- 使用 `draw_polyline()` 绘制曲线
- 可以调整采样密度提高平滑度

### 3.2 沿曲线移动

```gdscript
var t = 0.0
var speed = 0.5

func _process(delta):
    t += delta * speed
    if t > 1.0:
        t = 0.0
    
    var pos = _cubic_bezier(p0, p1, p2, p3, t)
    $Character.position = pos
```

**应用场景**:
- 敌人沿预设路径巡逻
- 投射物沿曲线轨迹飞行
- 相机沿路径移动

### 3.3 缓动函数

使用贝塞尔曲线实现自定义缓动效果：

```gdscript
func ease_in(t: float) -> float:
    return t * t

func ease_out(t: float) -> float:
    return 1.0 - (1.0 - t) * (1.0 - t)

func ease_in_out(t: float) -> float:
    return t * t * (3.0 - 2.0 * t)

# 使用缓动函数
var eased_t = ease_in_out(t)
var pos = _cubic_bezier(p0, p1, p2, p3, eased_t)
```

**效果对比**:
- `ease_in()`: 缓入（先慢后快）
- `ease_out()`: 缓出（先快后慢）
- `ease_in_out()`: 缓入缓出（慢 - 快 - 慢）

---

## 🎮 Godot 内置曲线资源

### 4.1 Curve2D

Godot 提供 `Curve2D` 资源来处理贝塞尔曲线：

```gdscript
var curve = Curve2D.new()
curve.add_point(Vector2(0, 0))
curve.add_point(Vector2(50, 50), Vector2(-20, 0), Vector2(20, 0))
curve.add_point(Vector2(100, 0))

# 采样曲线上的点
var pos = curve.sample_baked(0.5)  # 参数 0-1
```

**add_point() 参数**:
- 第一个参数：点的位置
- 第二个参数：进入控制点（相对于该点）
- 第三个参数：离开控制点（相对于该点）

**常用方法**:
- `add_point()`: 添加点
- `sample_baked(offset)`: 采样曲线上的点（0-1 参数）
- `get_baked_length()`: 获取曲线总长度
- `get_point_count()`: 获取点数

### 4.2 Curve3D

3D 版本的曲线：

```gdscript
var curve = Curve3D.new()
curve.add_point(Vector3(0, 0, 0))
curve.add_point(Vector3(50, 50, 0))
curve.add_point(Vector3(100, 0, 0))
```

**应用场景**:
- 3D 路径飞行
- 过山车轨道
- 摄像机路径动画

### 4.3 Path2D 和 PathFollow2D

Godot 提供专门的节点来使用曲线：

```gdscript
@onready var path = $Path2D
@onready var follow = $Path2D/PathFollow2D

func _process(delta):
    follow.progress += delta * 100
    if follow.progress > path.curve.get_baked_length():
        follow.progress = 0
```

**节点说明**:
- `Path2D`: 包含 Curve2D 资源的节点
- `PathFollow2D`: 自动沿路径移动的节点
- `progress`: 沿路径的距离（像素单位）

**优势**:
- 可视化编辑曲线路径
- 自动计算切线方向
- 支持循环路径

---

## 📊 贝塞尔曲线对比

| 类型 | 点数 | 控制点 | 复杂度 | 适用场景 |
|------|------|--------|--------|---------|
| 二次贝塞尔 | 3 | 1 个 | 低 | 简单曲线、缓动 |
| 三次贝塞尔 | 4 | 2 个 | 中 | 复杂曲线、路径 |
| Curve2D | N | 每点 2 个 | 高 | 复杂路径、可视化编辑 |

---

## 💡 实战示例

### 示例 1: 抛物线投射物

```gdscript
# 二次贝塞尔模拟抛物线
func launch_projectile(start: Vector2, end: Vector2, height: float):
    var control_point = (start + end) / 2 + Vector2(0, -height)
    
    var t = 0.0
    while t <= 1.0:
        var pos = _quadratic_bezier(start, control_point, end, t)
        $Projectile.position = pos
        t += get_process_delta_time() * speed
        await get_tree().process_frame
```

### 示例 2: S 形路径

```gdscript
# 三次贝塞尔创建 S 形曲线
func create_s_curve():
    var p0 = Vector2(0, 0)
    var p1 = Vector2(100, 0)   # 向右拉
    var p2 = Vector2(100, 100) # 向下拉
    var p3 = Vector2(200, 100)
    
    var points = []
    for i in range(0, 101):
        var t = i / 100.0
        points.append(_cubic_bezier(p0, p1, p2, p3, t))
    
    return points
```

### 示例 3: 敌人巡逻路径

```gdscript
@onready var path = $PatrolPath/Path2D
@onready var follow = $PatrolPath/PathFollow2D

var moving = true

func _process(delta):
    if moving:
        follow.progress += delta * 50
        
        var length = path.curve.get_baked_length()
        if follow.progress >= length:
            follow.progress = length
            moving = false
        elif follow.progress <= 0:
            follow.progress = 0
            moving = false
    
    # 更新敌人位置
    position = follow.position
```

### 示例 4: 动态曲线绘制

```gdscript
var curve = Curve2D.new()

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        # 添加新点到曲线
        curve.add_point(get_global_mouse_position())
        update()

func _draw():
    if curve.get_point_count() > 1:
        var points = []
        var length = curve.get_baked_length()
        for i in range(0, int(length) + 1):
            points.append(curve.sample_baked(i / length))
        draw_polyline(points, Color.GREEN, 2)
```

---

## 🔗 相关链接

### Base 层来源
- [04E_Beziers_and_Curves.md](../../base/math-transforms/04E_Beziers_and_Curves.md) - 完整原始文档

### Wiki 层相关
- [插值运算指南](./interpolation-guide.md) - 插值基础
- [向量数学概念](./vector-math.md) - 向量操作

### 外部资源
- [Godot 官方贝塞尔曲线教程](https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html)
- [Curve2D API 文档](https://docs.godotengine.org/en/stable/classes/class_curve2d.html)
- [Path2D API 文档](https://docs.godotengine.org/en/stable/classes/class_path2d.html)

---

## 📝 最佳实践

### 1. 选择合适的曲线类型

- **简单弧线**: 使用二次贝塞尔
- **复杂路径**: 使用三次贝塞尔或 Curve2D
- **可视化编辑**: 使用 Path2D + Curve2D
- **性能敏感**: 手动实现贝塞尔（避免资源开销）

### 2. 性能优化

- **预采样曲线**: 提前计算曲线点，运行时直接查表
- **减少采样密度**: 根据视觉需求调整采样点数量
- **缓存曲线对象**: 避免每帧创建新的 Curve2D

### 3. 调试技巧

- **可视化控制点**: 使用 `draw_circle()` 绘制控制点
- **显示曲线**: 使用 `draw_polyline()` 绘制曲线
- **标注参数 t**: 在曲线上标记 t=0, 0.5, 1 的位置

### 4. 曲线平滑度

- **增加采样点**: 提高曲线平滑度
- **合理设置控制点**: 避免过大的曲率变化
- **使用 Curve2D**: 自动处理平滑度

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**许可**: MIT
