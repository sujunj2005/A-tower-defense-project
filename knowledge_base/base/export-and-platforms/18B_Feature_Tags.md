# Godot 4.x 功能标签与平台特定

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/export/exporting_projects.rst

---

## 目录

1. [功能标签概述](#1-功能标签概述)
2. [内置标签](#2-内置标签)
3. [自定义标签](#3-自定义标签)
4. [平台特定配置](#4-平台特定配置)

---

## 1. 功能标签概述

功能标签用于条件编译和运行时检测：

```gdscript
if OS.has_feature("mobile"):
    setup_mobile_ui()
```

---

## 2. 内置标签

### 2.1 平台标签

| 标签 | 说明 |
|------|------|
| `windows` | Windows 平台 |
| `macos` | macOS 平台 |
| `linuxbsd` | Linux/BSD 平台 |
| `android` | Android 平台 |
| `ios` | iOS 平台 |
| `web` | Web 平台 |

### 2.2 构建标签

| 标签 | 说明 |
|------|------|
| `debug` | 调试构建 |
| `release` | 发布构建 |
| `editor` | 编辑器中运行 |
| `standalone` | 导出后运行 |
| `template` | 项目模板 |

### 2.3 架构标签

| 标签 | 说明 |
|------|------|
| `x86_64` | 64 位 x86 |
| `arm64-v8a` | ARM64 |
| `x86_32` | 32 位 x86 |
| `arm32` | ARM32 |
| `rv64` | RISC-V 64 |
| `ppc64le` | PowerPC |
| `ppc` | PowerPC 32 |
| `wasm32` | WebAssembly |

---

## 3. 自定义标签

### 3.1 定义自定义标签

在导出预设 → Features 中添加：

```
demo, pro, steam, epic
```

### 3.2 使用自定义标签

```gdscript
if OS.has_feature("pro"):
    enable_pro_features()

if OS.has_feature("steam"):
    steam_api.init()
```

### 3.3 在代码中使用

```gdscript
func _ready():
    if OS.has_feature("debug"):
        debug_mode = true
    
    if OS.has_feature("mobile"):
        touch_controls.visible = true
        keyboard_controls.visible = false
```

---

## 4. 平台特定配置

### 4.1 移动端特有

```gdscript
if OS.has_feature("android") or OS.has_feature("ios"):
    # 移动端优化
    ProjectSettings.set_setting("rendering/textures/default_filters/filter", 0)
    DisplayServer.screen_set_keep_on(true)
```

### 4.2 PC 特有

```gdscript
if OS.has_feature("windows"):
    # Windows 特定设置
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
```

### 4.3 Web 特有

```gdscript
if OS.has_feature("web"):
    JavaScript.eval('console.log("Web mode")')
```

---

## 参考资料
- 来源文件：`godot-docs-master/tutorials/export/exporting_projects.rst`
