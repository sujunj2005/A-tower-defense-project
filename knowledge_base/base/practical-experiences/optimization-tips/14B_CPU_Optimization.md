# Godot 4.x CPU 性能优化

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/performance/cpu_optimization.rst

---

> 📖 **性能优化三部曲（本文是第2篇）：**
>
> ```
> [14A_General_Optimization.md] ◄── 第1篇：优化方法论 + 测量 + 技术索引（必读先导）
>         │
>         └──► [14B] 本文档 ◄── 第2篇：CPU/脚本瓶颈深度诊断与修复 ★ 本文
>                 │   （Profiler详解、脚本/物理/AI/GC优化实战）
>                 │
>                 └──► [14C_GPU_Optimization.md] ◄── 第3篇：GPU/渲染瓶颈深度诊断与修复
> ```

---

## 目录

1. [性能测量概述](#1-性能测量概述)
2. [CPU Profiler](#2-cpu-profiler)
3. [常见瓶颈与优化](#3-常见瓶颈与优化)
4. [脚本优化技巧](#4-脚本优化技巧)

---

## 1. 性能测量概述

### 1.1 找到瓶颈

必须知道"瓶颈"在哪里才能有效加速程序。瓶颈是程序中最慢的部分。

### 1.2 测量方法

- **Profiler**：最简单的 CPU 测量方法
- **外部 Profiler**：更强大，可分析引擎源码

---

## 2. CPU Profiler

### 2.1 使用内置 Profiler

Godot IDE 有内置的性能分析器：

1. 运行游戏
2. 打开 Debugger → Profiler
3. 点击 "开始录制"
4. 操作一段时间后点击"停止"
5. 分析结果

### 2.2 分析结果

可以看到：
- 内置进程成本（物理、音频等）
- 自定义脚本函数的成本（底部）

> **踩坑点**：录制会显著降低项目速度，仅在需要分析时使用。

### 2.3 外部 Profiler

对于更强大的分析需求，可以使用第三方 C++ 分析工具（如 Valgrind/Callgrind）。

---

## 3. 常见瓶颈与优化

### 3.1 常见瓶颈

| 瓶颈 | 典型症状 | 解决方向 |
|------|----------|----------|
| 脚本逻辑 | 特定函数耗时高 | 优化算法、减少调用 |
| 物理计算 | 物理占比过高 | 减少碰撞体、简化形状 |
| 渲染 | GPU 驱动耗时高 | 减少绘制调用、使用 LOD |
| GC | 周期性卡顿 | 复用对象、避免频繁创建 |

### 3.2 识别方法

- 如果某函数占用时间明显多于其他 → 主要瓶颈
- 如果大部分时间在 `libglapi`/驱动 → GPU 瓶颈

---

## 4. 脚本优化技巧

### 4.1 减少每帧计算

```gdscript
# ❌ 错误：每帧计算距离
func _process(delta):
    var dist = global_position.distance_to(target)
    
# ✅ 正确：定时检查
var _check_timer := 0.0
func _process(delta):
    _check_timer += delta
    if _check_timer >= 0.5:
        _check_timer = 0.0
        check_distance()
```

### 4.2 缓存节点引用

```gdscript
# ❌ 错误
func _process(delta):
    $Sprite.position += velocity * delta

# ✅ 正确
@onready var sprite: Sprite2D = $Sprite
func _process(delta):
    sprite.position += velocity * delta
```

### 4.3 使用类型化数组

```gdscript
# 较慢
var arr = []
# 较快
var arr: Array[Node] = []
```

### 4.4 对象池模式

```gdscript
var pool: Array[Node] = []

func get_object():
    for obj in pool:
        if not obj.visible:
            return obj
    return create_new_object()
```

### 4.5 减少绘制调用

- 使用 Sprite Sheet 合并多个精灵
- 合并静态背景为单个纹理
- 使用 TileMap 替代大量独立 Sprite

### 4.6 使用 @export_cache 或 @onready

避免在 `_ready()` 中频繁调用 `get_node()`。

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/performance/cpu_optimization.rst`
