# TestMCP（人生塔防）

一款 Godot 2D 游戏。玩家通过人生事件做出选择、积累资源，再进入塔防战斗。

## Windows 开发与测试

安装 PowerShell 7.2 或更新版本以及可通过 `python` 启动的 Python 3.9 或更新版本。从仓库根目录运行以下命令。

```powershell
pwsh -NoProfile -File tools/bootstrap.ps1
pwsh -NoProfile -File tools/godot.ps1 --editor
pwsh -NoProfile -File tools/test.ps1
```

初始化脚本根据[版本清单](tools/godot-toolchain.json)下载并校验 Godot 4.7.2 和 GUT 9.6.0，并为缺失的图片生成开发占位图。正式美术应使用具备相应授权的素材。

测试脚本运行单元与集成测试，并把日志和 JUnit XML 写入 `.godot/test-results/`。[GitHub Actions](.github/workflows/godot-tests.yml) 使用相同的初始化与测试入口。

## Windows 导出

```powershell
pwsh -NoProfile -File tools/export-windows.ps1
```

导出脚本安装经过校验的 Windows 模板，生成 EXE 和 PCK，并将 JSON 配置部署到同级 `data/`。使用 Excel 更新配置时，从 [依赖清单](tools/config-requirements.txt) 安装 Python 依赖，再使用 `config_tool.py`。

## 知识库

从 [项目知识库索引](knowledge_base/index.md) 查找测试、事件、存档和地图资料。历史案例的版本与适用范围见各篇说明。
