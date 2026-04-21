# 插值运算指南

> **来源**: [04C_Interpolation.md](../../base/math-transforms/04C_Interpolation.md)  
> **适用版本**: Godot 4.x  
> **最后更新**: 2026-04-07

---

## 📚 概述

插值用于在两个值之间**平滑过渡**。使用参数 `t` 表示中间状态：
- `t = 0`：状态 A
- `t = 1`：状态 B
- `0 < t < 1`：中间状态

插值是游戏开发中最常用的技术之一，用于实现平滑移动、动画过渡、相机跟随等效果。

---

## 🎯 核心概念

### 1. 线性插值（Lerp）

#### 1.1 基本公式

```
interpolation = A * (1 - t) + B * t
// 简化为：
interpolation = A + (B - A) * t
```

这种以恒定速度变换的插值称为**线性插值**（Linear Interpolation，简称 lerp）。

#### 1.2 向量插值

Vector2 和 Vector3 提供 `lerp()` 方法：

```gdscript
var t = 0.0

func _physics_process(delta):
    t += delta * 0.4
    $Sprite2D.position = $A.position.lerp($B.position, t)
```

#### 1.3 三次插值

三次插值使用贝塞尔风格，提供更平滑的过渡：

```gdscript
var result = a.cubic_interpolate(b, pre_a, post_b, t)
```

**参数说明**:
- `a`: 起始点
- `b`: 目标点
- `pre_a`: a 之前的点（影响曲线曲率）
- `post_b`: b 之后的点（影响曲线曲率）
- `t`: 插值参数（0.0 到 1.0）

---

### 2. 变换插值

#### 2.1 interpolate_with()

Transform3D 可以整体插值：

```gdscript
var t = 0.0

func _physics_process(delta):
    t += delta
    $Monkey.transform = $Position1.transform.interpolate_with($Position2.transform, t)
```

> ⚠️ **踩坑点**: 变换插值要求两个变换具有**统一缩放**，或至少相同的非统一缩放。

---

### 3. 平滑移动

#### 3.1 基本平滑跟随

使用 lerp 实现平滑跟随目标：

```gdscript
const FOLLOW_SPEED = 4.0

func _physics_process(delta):
    var mouse_pos = get_local_mouse_position()
    $Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, delta * FOLLOW_SPEED)
```

**工作原理**:
- 每一帧都向目标移动一定百分比的距离
- 距离越远移动越快，距离越近移动越慢
- 形成平滑的减速效果

#### 3.2 应用场景

- **相机平滑跟随**: 相机平滑跟踪玩家位置
- **盟友跟随玩家**: NPC 平滑跟随玩家移动
- **UI 元素动画**: 菜单、按钮的平滑过渡
- **指针平滑移动**: 鼠标指针的平滑效果

---

## 🔧 帧率无关插值

### 4.1 问题

上述 lerp 公式是**帧率相关**的，因为 `weight` 参数表示剩余差异的百分比，而非绝对变化量。

**问题表现**:
- 在 60 FPS 和 30 FPS 下，相同的代码会产生不同的移动速度
- 在 `_process()` 中尤其明显（物理帧率固定，但渲染帧率可变）

### 4.2 解决方案

使用**指数衰减公式**实现帧率无关：

```gdscript
const FOLLOW_SPEED = 4.0

func _process(delta):
    var mouse_pos = get_local_mouse_position()
    var weight = 1 - exp(-FOLLOW_SPEED * delta)
    $Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, weight)
```

### 4.3 公式推导

```
weight = 1 - exp(-speed * delta)
```

这个公式确保：
- 在 60 FPS 下运行 1 秒后，物体移动到目标的约 98%
- 在 30 FPS 下运行 1 秒后，结果相同
- **帧率无关**：无论帧率如何，移动速度一致

> ⚠️ **踩坑点**: 在 `_physics_process()` 中使用简单 lerp 通常没问题，因为物理帧率是固定的。但在 `_process()` 中应使用帧率无关公式。

---

## 🎨 其他插值方法

### 5.1 smoothstep()

平滑阶跃插值，提供缓入缓出效果：

```gdscript
var t = smoothstep(0.0, 1.0, x)  # 缓入缓出
```

**应用场景**:
- 淡入淡出动画
- 平滑的开关效果
- 自然的速度变化

### 5.2 ease()

缓动函数，提供多种缓动曲线：

```gdscript
var t = ease(x, 2.0)  # 各种缓动曲线
```

**参数说明**:
- `x`: 输入值（0.0 到 1.0）
- `curve`: 曲线强度
  - `curve > 1`: 缓入（先慢后快）
  - `0 < curve < 1`: 缓出（先快后慢）
  - `curve < 0`: 更复杂的缓动效果

### 5.3 slerp()

球面线性插值（Spherical Linear Interpolation），用于 3D 旋转：

```gdscript
var result = a.slerp(b, t)
```

**应用场景**:
- 3D 角色旋转
- 相机方向平滑过渡
- 四元数插值

**优势**:
- 保持旋转向量的单位长度
- 提供最短路径旋转
- 避免万向节死锁

---

## 📊 插值方法对比

| 方法 | 适用场景 | 帧率无关 | 平滑度 | 性能 |
|------|---------|---------|--------|------|
| `lerp()` | 通用插值 | ❌ 需要额外处理 | 线性 | ⭐⭐⭐⭐⭐ |
| `cubic_interpolate()` | 曲线路径 | ❌ 需要额外处理 | 高（三次） | ⭐⭐⭐⭐ |
| `slerp()` | 3D 旋转 | ❌ 需要额外处理 | 高（球面） | ⭐⭐⭐ |
| `smoothstep()` | 缓入缓出 | ✅ 天然支持 | 高 | ⭐⭐⭐⭐⭐ |
| `ease()` | 各种缓动 | ✅ 天然支持 | 可配置 | ⭐⭐⭐⭐⭐ |
| 帧率无关 lerp | 平滑跟随 | ✅ 公式保证 | 指数衰减 | ⭐⭐⭐⭐ |

---

## 💡 实战示例

### 示例 1: 相机平滑跟随

```gdscript
# 帧率无关的相机跟随
const CAMERA_SPEED = 5.0

func _process(delta):
    var target_position = player.position
    var weight = 1 - exp(-CAMERA_SPEED * delta)
    $Camera2D.position = $Camera2D.position.lerp(target_position, weight)
```

### 示例 2: UI 淡入效果

```gdscript
func fade_in(duration: float):
    var elapsed = 0.0
    while elapsed < duration:
        elapsed += get_process_delta_time()
        var t = elapsed / duration
        var alpha = smoothstep(0.0, 1.0, t)
        modulate.a = alpha
        await get_tree().process_frame
```

### 示例 3: 投射物追踪

```gdscript
func _physics_process(delta):
    if target:
        # 平滑转向目标
        var direction = (target.position - position).normalized()
        var t = delta * turn_speed
        velocity = velocity.slerp(direction * speed, t)
    
    position += velocity * delta
```

### 示例 4: 颜色渐变

```gdscript
func _process(delta):
    var t = (Time.get_ticks_msec() % 2000) / 2000.0
    var color1 = Color.RED
    var color2 = Color.BLUE
    $Sprite2D.modulate = color1.lerp(color2, smoothstep(0.0, 1.0, t))
```

---

## 🔗 相关链接

### Base 层来源
- [04C_Interpolation.md](../../base/math-transforms/04C_Interpolation.md) - 完整原始文档

### Wiki 层相关
- [向量数学概念](./vector-math.md) - 向量插值基础
- [贝塞尔曲线指南](./bezier-curves-guide.md) - 高级曲线插值
- [矩阵与变换概念](./matrices-transforms.md) - 变换插值

### 外部资源
- [Godot 官方插值教程](https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html)

---

## 📝 最佳实践

### 1. 选择合适的插值方法

- **简单移动**: 使用 `lerp()`
- **平滑跟随**: 使用帧率无关 lerp
- **曲线路径**: 使用 `cubic_interpolate()`
- **3D 旋转**: 使用 `slerp()`
- **缓动效果**: 使用 `smoothstep()` 或 `ease()`

### 2. 帧率无关性

- 在 `_process()` 中使用帧率无关公式
- 在 `_physics_process()` 中可以使用简单 lerp（物理帧率固定）
- 使用 `1 - exp(-speed * delta)` 确保一致性

### 3. 性能优化

- 避免在循环中频繁调用插值
- 使用 `length_squared()` 代替 `length()` 进行比较
- 预计算常用的插值参数

### 4. 调试技巧

- 可视化插值路径（使用 `draw_line()`）
- 打印 t 值检查插值进度
- 使用不同的颜色标记起始点和目标点

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**许可**: MIT
