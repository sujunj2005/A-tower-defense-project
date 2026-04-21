# Godot 4.x 导出与发布

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/export/exporting_projects.rst

---

## 目录

1. [导出概述](#1-导出概述)
2. [导出预设](#2-导出预设)
3. [导出模板](#3-导出模板)
4. [平台特定设置](#4-平台特定设置)
5. [代码签名](#5-代码签名)
6. [功能标签](#6-功能标签)

---

## 1. 导出概述

### 1.1 导出流程

1. 安装导出模板
2. 创建导出预设
3. 配置平台设置
4. 导出项目

### 1.2 导出类型

| 类型 | 说明 |
|------|------|
| 桌面 | Windows、macOS、Linux |
| 移动 | Android、iOS |
| Web | HTML5 |
| 控制台 | 需要额外授权 |

---

## 2. 导出预设

### 2.1 创建预设

1. 项目 → 导出
2. 点击"添加"
3. 选择目标平台
4. 配置设置

### 2.2 预设配置

| 设置 | 说明 |
|------|------|
| 可执行文件图标 | 应用图标 |
| 资源选项 | 包含的资源 |
| 脚本选项 | 脚本导出模式 |
| 功能标签 | 平台功能 |

---

## 3. 导出模板

### 3.1 安装模板

1. 编辑器 → 管理导出模板
2. 下载并安装

### 3.2 模板类型

| 类型 | 说明 |
|------|------|
| Release | 发布版本 |
| Debug | 调试版本 |

> **踩坑点**：导出时必须安装对应版本的导出模板，否则导出失败。

---

## 4. 平台特定设置

### 4.1 Windows

| 设置 | 说明 |
|------|------|
| 独立模式 | 单文件或文件夹 |
| 控制台包装器 | 显示控制台窗口 |
| 修改权限 | 管理员权限 |

### 4.2 macOS

| 设置 | 说明 |
|------|------|
| 应用程序包 | .app 格式 |
| 代码签名 | Apple 开发者证书 |
| 公证 | Apple 公证 |

### 4.3 Android

| 设置 | 说明 |
|------|------|
| 架构 | ARM64、ARM32、x86 |
| 最小 SDK | 最低 Android 版本 |
| 权限 | 应用权限 |
| 调试密钥库 | 签名密钥 |

### 4.4 iOS

| 设置 | 说明 |
|------|------|
| Bundle ID | 应用标识符 |
| 团队 ID | Apple 开发者团队 |
| 证书 | 签名证书 |
| Provisioning Profile | 配置文件 |

### 4.5 Web

| 设置 | 说明 |
|------|------|
| 线程支持 | 多线程 |
| VRAM 纹理压缩 | 纹理压缩 |
| 确保 Cross Origin Isolation | 跨域隔离 |

---

## 5. 代码签名

### 5.1 Windows 签名

```powershell
# 使用 signtool
signtool sign /f cert.pfx /p password game.exe
```

### 5.2 macOS 签名

```bash
# 使用 codesign
codesign --deep --force --verify --verbose --sign "Developer ID" Game.app
```

### 5.3 Android 签名

在导出设置中配置密钥库：

```gdscript
# 调试密钥库位置
user://android/debug.keystore
```

---

## 6. 功能标签

### 6.1 内置标签

| 标签 | 说明 |
|------|------|
| `windows` | Windows 平台 |
| `macos` | macOS 平台 |
| `linuxbsd` | Linux 平台 |
| `android` | Android 平台 |
| `ios` | iOS 平台 |
| `web` | Web 平台 |
| `debug` | 调试构建 |
| `release` | 发布构建 |

### 6.2 使用功能标签

```gdscript
func _ready():
    if OS.has_feature("mobile"):
        # 移动平台特定代码
        pass
    
    if OS.has_feature("debug"):
        # 调试模式代码
        pass
```

### 6.3 自定义标签

在导出预设中添加自定义标签：

```
demo, pro, steam
```

```gdscript
func _ready():
    if OS.has_feature("pro"):
        enable_pro_features()
```

---

## 7. 命令行导出

```bash
# Windows
godot4 --headless --export-release "Windows Desktop" game.exe

# Linux
godot4 --headless --export-release "Linux/X11" game.x86_64

# Android
godot4 --headless --export-release "Android" game.apk

# Web
godot4 --headless --export-release "Web" ./web_build
```

---

## 参考资料

本文档内容基于 Godot 官方文档整理：
- 来源文件：`godot-docs-master/tutorials/export/exporting_projects.rst`
