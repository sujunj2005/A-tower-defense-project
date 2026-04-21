# Base 层 - Steam 平台集成

**位置**: `base/steam-integration/`

**来源**: GodotSteam 官方文档 + 实战经验  
**最后更新**: 2026-04-07  
**文档数**: 1 份

---

## 📄 文档列表

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [12_Steam_Platform_Integration.md](./12_Steam_Platform_Integration.md) | **GodotSteam Steam 平台对接完全指南** - 环境搭建、初始化、成就系统、排行榜、大厅系统、P2P 通信、语音聊天、身份验证等 | 🔴 必读 |

---

## 📊 统计信息

- **文档总数**: 1 份
- **总字数**: ~45,000+
- **适用版本**: Godot 4.x / GodotSteam 4.18 / Steamworks SDK 1.64

---

## 🎯 核心内容

### 环境搭建
- GodotSteam 4.18 安装（GDExtension 通用版/版本专用版）
- 项目配置与 Steamworks 后端设置
- steam_appid.txt 配置

### Steam 初始化
- 全局管理脚本（Autoload）
- Steam.run_callbacks() 每帧调用
- 自动初始化（4.14+）

### 成就与统计系统
- 成就数据结构定义
- 请求/解锁成就
- 设置统计数据
- 成就图标获取

### 排行榜系统
- 查找/创建排行榜
- 上传分数
- 下载排行榜数据

### 大厅系统与多人联机
- 创建/加入/离开大厅
- 大厅成员管理
- 大厅聊天消息
- 大厅浏览器

### P2P 网络通信
- P2P 握手与会话管理
- 发送/接收 P2P 数据包
- 可靠 vs 不可靠传输

### 语音聊天系统
- 语音控制
- 捕获和发送语音
- 播放语音数据
- getDecompressedVoice() 简化处理（4.17+）

### 身份验证系统
- 获取认证票据
- 验证认证票据
- 结束认证会话

### 头像与用户信息
- 获取用户头像
- 好友信息获取

### 输入与手柄支持
- Steam Input 初始化
- 触觉反馈
- 混合使用 Godot 和 Steam 输入

### Steam Overlay 与商店
- 打开 Overlay 页面
- 常用 Overlay 功能

### 版本迁移指南
- 从旧版迁移到 4.18
- 必须更新的代码
- GDExtension 通用版 vs 版本专用版

### 常见踩坑与解决方案
- Steam 初始化失败排查
- 回调不触发
- P2P 连接失败
- 成就不显示
- 语音杂音/卡顿

---

## ⚠️ 重要踩坑点

1. **Steam.run_callbacks() 必须每帧调用** - 否则所有 Steam 回调都不会触发
2. **storeStats() 必须手动调用** - 从 4.15 开始不再自动调用
3. **成就名称必须与 Steamworks 后台完全一致** - 区分大小写
4. **P2P 数据包序列化限制** - 不要发送 Object 引用或 Resource
5. **getAvailableVoice() 已移除** - 4.16+ 直接使用 getVoice()

---

## 🔗 Wiki 层映射

- 指南页面：*待创建* - Steam 平台集成实战指南

---

**维护者**: Knowledge Base Administrator
