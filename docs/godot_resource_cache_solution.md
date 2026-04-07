# Godot 4.x 资源缓存问题完整解决方案

## 问题描述

当你在 Godot 编辑器外部修改 `.tres` 资源文件（或使用代码修改）后，Godot 编辑器仍然显示旧的资源值。这是因为 Godot 的资源缓存机制导致的。

**核心问题**：
- Godot 在内存中缓存已加载的资源
- 当资源文件被外部修改时，Godot 不会自动检测到变化
- 即使使用 `ResourceLoader.CACHE_MODE_IGNORE`，子资源仍然使用缓存

## 根本原因

根据 GitHub Issue #115677，Godot 资源缓存系统有以下行为：

1. **资源路径匹配**：Godot 使用 `resource_path` 来识别资源
2. **子资源缓存**：即使主资源重新加载，子资源仍然使用缓存
3. **外部变化检测缺失**：Godot 不检测编辑器外部的文件变化

## 完整解决方案

### 方案 1：强制重新导入（推荐用于开发环境）

**步骤**：

1. **删除 `.godot` 缓存文件夹**
   ```bash
   # Windows PowerShell
   Remove-Item -Path ".godot" -Recurse -Force
   
   # Linux/Mac
   rm -rf .godot
   ```

2. **在 Godot 编辑器中重新扫描文件系统**
   - 点击菜单栏：`场景 (Scene)` → `重新扫描文件系统 (Rescan Filesystem)`
   - 或使用快捷键：`Ctrl+Shift+R` (Windows/Linux) / `Cmd+Shift+R` (Mac)

3. **重启 Godot 编辑器**
   - 完全关闭 Godot
   - 重新打开项目

### 方案 2：使用 ResourceLoader 强制刷新（用于运行时）

如果你需要在代码中动态加载最新资源，使用以下方法：

```gdscript
func load_fresh_resource(path: String) -> Resource:
    """
    强制加载最新资源，忽略缓存
    """
    # 使用 CACHE_MODE_IGNORE 忽略缓存
    var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
    
    # 如果资源已经存在缓存中，需要强制刷新
    if resource == null:
        # 尝试使用 CACHE_MODE_REPLACE_DEEP
        resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
    
    return resource
```

### 方案 3：手动刷新资源（最彻底的方法）

如果上述方法都不起作用，使用这个终极方案：

```gdscript
func force_reload_resource(path: String) -> Resource:
    """
    强制重新加载资源，包括所有子资源
    通过复制文件、加载、然后接管路径的方式
    """
    var file = FileAccess.open(path, FileAccess.READ)
    var content = file.get_as_text()
    file.close()
    
    # 创建临时文件
    var temp_path = path + ".tmp_%d" % Time.get_unix_time_from_system()
    var temp_file = FileAccess.open(temp_path, FileAccess.WRITE)
    temp_file.store_string(content)
    temp_file.close()
    
    # 从临时文件加载资源
    var resource = ResourceLoader.load(temp_path, "", ResourceLoader.CACHE_MODE_IGNORE)
    
    if resource:
        # 接管原始路径
        resource.take_over_path(path)
        
        # 删除临时文件
        DirAccess.remove_absolute(temp_path)
        
        # 强制重新保存以刷新缓存
        ResourceSaver.save(resource, path)
    
    return resource
```

### 方案 4：在 Godot 编辑器中手动刷新

**步骤**：

1. **在 Godot 文件系统中找到资源文件**
   - 双击打开 `.tres` 文件

2. **不做任何修改，直接按 Ctrl+S 保存**
   - 这会强制 Godot 重新读取并刷新缓存

3. **对每个需要刷新的资源重复此操作**

## 预防措施

### 1. 使用版本控制时

如果你使用 Git 或其他 VCS：

```bash
# 切换分支后，强制重新导入所有资源
rm -rf .godot/import  # 删除导入缓存
# 然后在 Godot 中重新扫描文件系统
```

### 2. 在开发工具脚本中

创建一个编辑器工具脚本，自动处理资源刷新：

```gdscript
@tool
extends EditorScript

func _run():
    # 刷新所有 TowerConfig 资源
    refresh_all_tower_configs()

func refresh_all_tower_configs():
    var tower_types = ["basic", "archer", "magic"]
    for tower_type in tower_types:
        var path = "res://resources/towers/%s_tower.tres" % tower_type
        var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
        if resource:
            ResourceSaver.save(resource, path)
            print("刷新了：%s" % path)
```

### 3. 项目启动时自动检查

在项目的 `_ready()` 或 autoload 中添加：

```gdscript
func check_and_refresh_resources():
    """
    检查资源文件是否有外部变化，如果有则强制刷新
    """
    var tower_paths = [
        "res://resources/towers/basic_tower.tres",
        "res://resources/towers/archer_tower.tres",
        "res://resources/towers/magic_tower.tres"
    ]
    
    for path in tower_paths:
        if ResourceLoader.has_cached(path):
            # 如果资源在缓存中，强制重新加载
            var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
            print("[资源刷新] 已刷新：%s" % path)
```

## 最佳实践

### 1. 资源修改流程

**推荐流程**：
1. 在 Godot 编辑器中打开资源文件
2. 使用 Godot 的Inspector修改属性
3. 按 Ctrl+S 保存
4. 不要手动编辑 `.tres` 文件（除非必要）

### 2. 使用导出变量

在资源类中使用 `@export` 让 Godot 自动跟踪变化：

```gdscript
class_name TowerConfig
extends Resource

@export var damage: float = 10.0
@export var attack_mode: int = 0  # 使用 @export 让 Inspector 可见
```

### 3. 添加资源版本标记

在资源中添加版本号，方便调试：

```gdscript
@export var config_version: String = "1.0.1"
```

## 已知限制

根据 Godot GitHub Issues：

- **Issue #115677**: 资源缓存不关心外部文件变化
  - 状态：已确认问题
  - 影响：使用外部工具修改 `.tres` 文件时，Godot 不会自动更新
  
- **Issue #110468**: 即使使用 CACHE_MODE_IGNORE，某些资源类型也不会重新加载
  - 影响：Shader、Texture 等资源类型需要重新导入

## 快速诊断清单

当遇到资源不更新问题时，按以下顺序检查：

- [ ] 1. 删除 `.godot` 文件夹
- [ ] 2. 在 Godot 中重新扫描文件系统 (Ctrl+Shift+R)
- [ ] 3. 重启 Godot 编辑器
- [ ] 4. 手动打开并保存 `.tres` 文件
- [ ] 5. 检查代码中是否正确读取了资源属性
- [ ] 6. 使用调试输出确认资源值

## 总结

**最可靠的解决方案**：
1. 删除 `.godot` 缓存文件夹
2. 重启 Godot 编辑器
3. 在 Godot Inspector 中修改资源，而不是手动编辑 `.tres` 文件

**运行时解决方案**：
- 使用 `ResourceLoader.CACHE_MODE_REPLACE_DEEP`
- 或使用 `force_reload_resource()` 函数

**预防胜于治疗**：
- 尽量在 Godot Inspector 中修改资源
- 使用 `@export` 变量
- 添加版本号便于调试
