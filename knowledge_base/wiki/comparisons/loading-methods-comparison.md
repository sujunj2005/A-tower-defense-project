# 不同加载方式对比分析

> **适用版本**: Godot 4.x  
> **对比主题**: 资源加载方式  
> **前置知识**: 资源系统、GDScript 基础

---

## 📊 加载方式对比总览

| 加载方式 | 加载时机 | 阻塞 | 适用场景 | 性能 |
|---------|---------|------|---------|------|
| **preload()** | 编译时 | ❌ | 频繁使用的资源 | ⭐⭐⭐⭐⭐ |
| **load()** | 运行时 | ✅ | 动态加载资源 | ⭐⭐⭐ |
| **ResourceLoader.load()** | 运行时 | ✅ | 需要错误处理 | ⭐⭐⭐ |
| **ResourceLoader.load_threaded_request()** | 后台线程 | ❌ | 大型资源/场景 | ⭐⭐⭐⭐⭐ |
| **ResourceLoader.load_threaded_get()** | 主线程检查 | ❌ | 后台加载完成检查 | ⭐⭐⭐⭐⭐ |

---

## 1. preload() - 预加载

### 1.1 基本用法
```gdscript
# 编译时加载（脚本解析时）
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var player_texture: Texture2D = preload("res://assets/player.png")

# 只能在脚本顶部或@export 中使用
# 不能用于变量赋值（运行时）
```

### 1.2 优点
- ✅ **零运行时开销**: 编译时已加载
- ✅ **类型安全**: 可以指定类型（`PackedScene`、`Texture2D`）
- ✅ **自动补全**: IDE 提供代码补全
- ✅ **无阻塞**: 不阻塞游戏运行

### 1.3 缺点
- ❌ **内存占用**: 始终占用内存（即使不使用）
- ❌ **灵活性低**: 无法动态选择资源
- ❌ **循环依赖**: 可能导致循环引用问题

### 1.4 适用场景
- 频繁使用的资源（玩家纹理、子弹场景）
- 核心游戏资源（UI 元素、音效）
- 小型资源（脚本、配置）

### 1.5 不适用场景
- 大型资源（长视频、高分辨率纹理集）
- 条件加载资源（根据玩家选择加载）
- DLC 内容（可能不存在）

**参考**:
- [资源系统](../concepts/resources-system.md)

---

## 2. load() - 动态加载

### 2.1 基本用法
```gdscript
# 运行时加载
var scene = load("res://scenes/level_1.tscn")
var instance = scene.instantiate()
add_child(instance)

# 带路径拼接
var level_name = "level_1"
var scene = load("res://scenes/levels/%s.tscn" % level_name)
```

### 2.2 优点
- ✅ **灵活性高**: 可以动态选择资源
- ✅ **按需加载**: 只在需要时占用内存
- ✅ **简单直接**: 语法简单

### 2.3 缺点
- ❌ **阻塞**: 加载时游戏暂停
- ❌ **无类型检查**: 返回 `Resource`，需要手动转换
- ❌ **错误处理**: 资源不存在时返回 `null`

### 2.4 适用场景
- 动态关卡加载
- 可切换的资源（皮肤、服装）
- 小型到中型资源

### 2.5 最佳实践
```gdscript
# 检查资源是否存在
var scene = load("res://scenes/level.tscn")
if scene:
    var instance = scene.instantiate()
    add_child(instance)
else:
    push_error("Failed to load scene!")
```

**参考**:
- [后台加载](../../base/assets-and-io/15D_Background_Loading.md)

---

## 3. ResourceLoader.load() - 资源加载器

### 3.1 基本用法
```gdscript
# 基本加载
var resource = ResourceLoader.load("res://assets/texture.png")

# 带类型检查
var texture = ResourceLoader.load("res://assets/texture.png", "Texture2D")

# 带缓存选项
var resource = ResourceLoader.load(
    "res://scenes/level.tscn",
    "PackedScene",
    ResourceLoader.CACHE_MODE_REUSE  # 使用缓存
)
```

### 3.2 缓存模式
| 模式 | 描述 | 适用场景 |
|------|------|---------|
| `CACHE_MODE_REUSE` | 使用缓存（默认） | 大多数情况 |
| `CACHE_MODE_IGNORE` | 忽略缓存，强制重新加载 | 资源已更新 |
| `CACHE_MODE_REPLACE` | 替换现有缓存 | 资源已修改 |

### 3.3 优点
- ✅ **类型安全**: 可以指定预期类型
- ✅ **缓存控制**: 灵活管理缓存
- ✅ **错误处理**: 失败返回 `null`

### 3.4 缺点
- ❌ **阻塞**: 加载时游戏暂停
- ❌ **代码冗长**: 比 `load()` 更复杂

### 3.5 适用场景
- 需要类型检查的加载
- 需要控制缓存的行为
- 资源可能已更新的情况

**参考**:
- [资源系统](../concepts/resources-system.md)

---

## 4. ResourceLoader.load_threaded_request() - 后台线程加载

### 4.1 基本用法
```gdscript
# 发起后台加载请求
ResourceLoader.load_threaded_request("res://scenes/level_2.tscn", "PackedScene")

# 在 _process 中检查进度
func _process(delta):
    var status = ResourceLoader.load_threaded_get_status("res://scenes/level_2.tscn")
    
    match status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            print("无效资源路径")
        
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            var progress = ResourceLoader.load_threaded_get_progress("res://scenes/level_2.tscn")
            print("加载进度：%.2f%%" % (progress * 100))
        
        ResourceLoader.THREAD_LOAD_FAILED:
            push_error("加载失败！")
        
        ResourceLoader.THREAD_LOAD_LOADED:
            var scene = ResourceLoader.load_threaded_get("res://scenes/level_2.tscn")
            var instance = scene.instantiate()
            add_child(instance)
            print("加载完成！")
```

### 4.2 加载状态
| 状态 | 值 | 描述 |
|------|-----|------|
| `THREAD_LOAD_INVALID_RESOURCE` | 0 | 无效资源路径 |
| `THREAD_LOAD_IN_PROGRESS` | 1 | 正在加载 |
| `THREAD_LOAD_FAILED` | 2 | 加载失败 |
| `THREAD_LOAD_LOADED` | 3 | 加载完成 |

### 4.3 优点
- ✅ **无阻塞**: 后台线程加载，不卡顿
- ✅ **进度显示**: 可以获取加载进度
- ✅ **适合大型资源**: 场景、高清纹理

### 4.4 缺点
- ❌ **代码复杂**: 需要状态管理
- ❌ **延迟**: 加载完成前无法使用
- ❌ **线程安全**: 注意主线程访问

### 4.5 适用场景
- 大型场景加载（关卡切换）
- 高分辨率纹理集
- 需要显示加载进度的情况

### 4.6 完整示例：关卡切换
```gdscript
extends Node

var next_level_path: String
var is_loading = false

func change_level(level_path: String):
    next_level_path = level_path
    is_loading = true
    
    # 显示加载界面
    $LoadingScreen.visible = true
    
    # 发起后台加载
    ResourceLoader.load_threaded_request(level_path, "PackedScene")

func _process(delta):
    if not is_loading:
        return
    
    var status = ResourceLoader.load_threaded_get_status(next_level_path)
    
    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            var progress = ResourceLoader.load_threaded_get_progress(next_level_path)
            $LoadingScreen/ProgressBar.value = progress * 100
        
        ResourceLoader.THREAD_LOAD_LOADED:
            var scene = ResourceLoader.load_threaded_get(next_level_path)
            
            # 切换场景
            get_tree().change_scene_to_packed(scene)
            
            is_loading = false
            $LoadingScreen.visible = false
        
        ResourceLoader.THREAD_LOAD_FAILED:
            push_error("关卡加载失败！")
            is_loading = false
            $LoadingScreen.visible = false
```

**参考**:
- [后台加载](../../base/assets-and-io/15D_Background_Loading.md)
- [项目导出实战指南](../guides/exporting-projects-guide.md)

---

## 📊 性能对比

### 5.1 加载时间对比（示例：100MB 场景）

| 加载方式 | 加载时间 | 帧率影响 | 用户体验 |
|---------|---------|---------|---------|
| `preload()` | 0ms（已预加载） | 无 | ⭐⭐⭐⭐⭐ |
| `load()` | 2000ms | 卡顿 2 秒 | ⭐ |
| `ResourceLoader.load()` | 2000ms | 卡顿 2 秒 | ⭐ |
| `load_threaded_request()` | 2000ms（后台） | 无卡顿 | ⭐⭐⭐⭐⭐ |

### 5.2 内存占用对比

| 加载方式 | 内存占用 | 释放时机 |
|---------|---------|---------|
| `preload()` | 始终占用 | 场景卸载时 |
| `load()` | 按需占用 | 手动释放或场景卸载 |
| `load_threaded_request()` | 按需占用 | 手动释放或场景卸载 |

### 5.3 最佳实践建议

```
┌─────────────────────────────────────────┐
│  资源是否频繁使用？                      │
│    ├─ 是 → 使用 preload()               │
│    └─ 否 → 资源是否大型（>10MB）？       │
│         ├─ 是 → 使用 load_threaded_request() │
│         └─ 否 → 使用 load()              │
└─────────────────────────────────────────┘
```

---

## 🔗 相关资源

### Base 层来源
- [资源系统](../../base/core-systems/02C_Resources.md) - 资源系统原始文档
- [后台加载](../../base/assets-and-io/15D_Background_Loading.md) - 后台加载完整教程
- [保存游戏](../../base/assets-and-io/15C_Saving_Games.md) - 数据持久化

### Wiki 层相关
- [资源系统](../concepts/resources-system.md) - 资源核心概念
- [数据结构偏好指南](../guides/data-preferences-guide.md) - 数据管理最佳实践

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
