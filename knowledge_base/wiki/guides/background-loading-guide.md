# 资源后台加载指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 15D_Background_Loading.md](../../base/assets-and-io/15D_Background_Loading.md)  
> **重要性**: 🟡 推荐 - 优化加载性能

---

## 📋 概述

后台加载（异步加载）可以避免游戏卡顿，提供流畅的玩家体验。本指南介绍多种后台加载技术。

---

## 🎯 加载方式

### 1. 后台加载场景

```gdscript
# 使用 ResourceLoader
func load_scene_async(path: String):
    var loader = ResourceLoader.load_threaded_request(path)
    
    # 在 _process 中检查进度
    var status = ResourceLoader.load_threaded_get_status(path)
    
    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            var progress = ResourceLoader.load_threaded_get_progress(path)
            print("加载进度：", progress * 100, "%")
        ResourceLoader.THREAD_LOAD_LOADED:
            var scene = ResourceLoader.load_threaded_get(path)
            add_child(scene)
        ResourceLoader.THREAD_LOAD_FAILED:
            print("加载失败")
```

### 2. 后台加载资源

```gdscript
# 批量加载资源
func load_resources_async(paths: Array[String]):
    for path in paths:
        ResourceLoader.load_threaded_request(path)

func check_loading_progress():
    var total = 0
    var loaded = 0
    
    for path in paths:
        var status = ResourceLoader.load_threaded_get_status(path)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            loaded += 1
            var resource = ResourceLoader.load_threaded_get(path)
            cache[path] = resource
        elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            loaded += ResourceLoader.load_threaded_get_progress(path)
        
        total += 1
    
    return float(loaded) / total
```

---

## 🔧 加载界面实现

```gdscript
class_name LoadingScreen
extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

var scenes_to_load: Array[String] = []
var loaded_resources: Dictionary = {}

func start_loading(next_scene: String):
    scenes_to_load.append(next_scene)
    
    # 开始后台加载
    for scene_path in scenes_to_load:
        ResourceLoader.load_threaded_request(scene_path)

func _process(delta):
    var total_progress = 0.0
    
    for scene_path in scenes_to_load:
        var status = ResourceLoader.load_threaded_get_status(scene_path)
        
        match status:
            ResourceLoader.THREAD_LOAD_IN_PROGRESS:
                total_progress += ResourceLoader.load_threaded_get_progress(scene_path)
            ResourceLoader.THREAD_LOAD_LOADED:
                loaded_resources[scene_path] = ResourceLoader.load_threaded_get(scene_path)
                total_progress += 1.0
            ResourceLoader.THREAD_LOAD_FAILED:
                print("加载失败：", scene_path)
                total_progress += 1.0
    
    # 更新进度条
    var progress = total_progress / scenes_to_load.size()
    progress_bar.value = progress * 100
    label.text = "加载中... %d%%" % int(progress * 100)
    
    # 加载完成
    if progress >= 1.0:
        finish_loading()

func finish_loading():
    var next_scene = loaded_resources[scenes_to_load[0]]
    get_tree().change_scene_to_packed(next_scene)
```

---

## 🔗 相关资源

### Base 层
- [15D_Background_Loading.md](../../base/assets-and-io/15D_Background_Loading.md) - 后台加载详解

### Wiki 层
- [文件系统指南](../guides/filesystem-guide.md) - 文件操作基础

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
