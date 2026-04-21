# 性能分析器实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 17B_Profiler.md](../../base/debug-and-testing/17B_Profiler.md)  
> **重要性**: 🟡 推荐 - 性能优化必备技能

---

## 📋 概述

性能分析器用于识别和解决游戏性能瓶颈。本指南介绍 Godot 内置和第三方性能分析工具的使用方法。

---

## 🎯 性能分析器

### 1. 内置性能监视器

**启用方法**：
- 调试 → 可调试选项 → 性能 → 启用性能监视器

**监视指标**：
- **帧时间（Frame Time）**: 每帧耗时（ms）
- **FPS**: 每秒帧数
- **对象数**: 活动对象数量
- **内存使用**: RAM 和 VRAM 使用量

### 2. 性能分析器面板

**使用方法**：
1. 点击 "调试器" → "性能分析器"
2. 运行游戏
3. 查看各函数的调用时间和次数
4. 识别性能瓶颈

**关键指标**：
- **Total Time**: 总耗时
- **Self Time**: 函数自身耗时（不含子函数）
- **Call Count**: 调用次数

---

## 🔧 实战技巧

### 1. 自定义性能监控

```gdscript
# 性能监控器
class_name PerformanceMonitor
extends Node

var frame_times: Array[float] = []
var target_fps: int = 60

func _process(delta):
    frame_times.append(delta)
    if frame_times.size() > 60:
        frame_times.pop_front()
    
    var avg_frame_time = sum(frame_times) / frame_times.size()
    var current_fps = 1.0 / avg_frame_time
    
    if current_fps < target_fps * 0.9:
        print("性能警告：FPS = %d" % current_fps)

func sum(array: Array[float]) -> float:
    var total = 0.0
    for value in array:
        total += value
    return total
```

### 2. 内存监控

```gdscript
func check_memory_usage():
    var static_mem = Performance.get_monitor(Performance.MEMORY_STATIC)
    var static_max = Performance.get_monitor(Performance.MEMORY_STATIC_MAX)
    
    print("内存使用：%.2f MB / %.2f MB" % [
        static_mem / 1048576.0,
        static_max / 1048576.0
    ])
    
    if static_mem > static_max * 0.9:
        push_warning("内存使用接近上限！")
```

### 3. 渲染性能

```gdscript
func check_rendering_performance():
    var objects = Performance.get_monitor(Performance.OBJECT_3D)
    var vertices = Performance.get_monitor(Performance.VERTICES)
    var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS)
    
    print("3D 对象：%d" % objects)
    print("顶点数：%d" % vertices)
    print("绘制调用：%d" % draw_calls)
```

---

## 📊 优化建议

### 1. CPU 优化

- 减少 _process 和 _physics_process 中的复杂计算
- 使用对象池复用对象
- 延迟加载和卸载资源

### 2. GPU 优化

- 减少绘制调用（使用合批）
- 优化着色器复杂度
- 使用 LOD 系统

### 3. 内存优化

- 及时释放不用的资源
- 使用纹理压缩
- 避免频繁的内存分配

---

## 🔗 相关资源

### Base 层
- [17B_Profiler.md](../../base/debug-and-testing/17B_Profiler.md) - 性能分析器详解

### Wiki 层
- [调试工具指南](../guides/debugging-tools-guide.md) - 调试工具集

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
