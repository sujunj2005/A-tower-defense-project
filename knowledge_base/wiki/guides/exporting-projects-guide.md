# 项目导出实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 18A_Exporting_Projects.md](../../base/export-and-platforms/18A_Exporting_Projects.md)  
> **重要性**: 🔴 必读 - 多平台发布完整流程

---

## 📋 概述

Godot 支持导出到多个平台，包括 Windows、macOS、Linux、Android、iOS 和 Web。本指南介绍项目导出的完整流程。

---

## 🎯 导出流程

### 1. 导出模板

**下载模板**：
1. 编辑器 → 管理导出模板
2. 点击 "下载并安装"
3. 选择与编辑器版本匹配的模板

**模板作用**：
- 提供运行时引擎
- 包含平台特定的库
- 必须与编辑器版本完全匹配

### 2. 导出预设

**配置导出预设**：
1. 项目 → 导出
2. 添加平台（如 Windows Desktop）
3. 配置预设名称和路径
4. 设置平台特定选项

### 3. 导出选项

**通用选项**：
- **导出模式**: 调试/发布
- **包含调试器**: 调试版本启用
- **加密密钥**: 保护脚本

**平台特定选项**：
- **Windows**: 图标、文件版本
- **Android**: 包名、权限、签名
- **Web**: 启用线程、Canvas 模式

---

## 🔧 实战技巧

### 1. 多平台导出脚本

```gdscript
# 批量导出脚本
# 在命令行运行：godot --script export_all.gd

extends SceneTree

func _init():
    var presets = ["Windows", "Linux", "Web"]
    
    for preset_name in presets:
        print("导出到 %s..." % preset_name)
        Error err = EditorExportPlatform.export_project(
            preset_name,
            "builds/%s/game.exe" % preset_name
        )
        
        if err == OK:
            print("导出成功")
        else:
            print("导出失败：%d" % err)
    
    quit()
```

### 2. 版本管理

```gdscript
# 自动版本号
const VERSION = "1.0.0"
const BUILD_NUMBER = 42

func get_version_string() -> String:
    return "v%s (build %d)" % [VERSION, BUILD_NUMBER]
```

### 3. 导出检查清单

```
导出前检查:
□ 测试所有功能
□ 检查性能
□ 验证输入映射
□ 测试音频
□ 检查 UI 适配
□ 验证存档系统
□ 测试多人游戏
□ 检查第三方库
```

---

## 🔗 相关资源

### Base 层
- [18A_Exporting_Projects.md](../../base/export-and-platforms/18A_Exporting_Projects.md) - 项目导出详解
- [18B_Feature_Tags.md](../../base/export-and-platforms/18B_Feature_Tags.md) - 功能标签

### Wiki 层
- [功能标签指南](../guides/feature-tags-guide.md) - 平台特定功能

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
