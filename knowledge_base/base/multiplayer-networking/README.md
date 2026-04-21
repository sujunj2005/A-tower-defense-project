# Base 层 - 多人游戏网络

**位置**: `base/multiplayer-networking/`

**来源**: Godot 官方文档  
**最后更新**: 2026-04-07  
**文档数**: 1 份

---

## 📄 文档列表

| 文档 | 描述 | 重要性 |
|------|------|--------|
| [13_Multiplayer_Networking.md](./13_Multiplayer_Networking.md) | **多人联机网络** - ENet 传输、MultiplayerSynchronizer、RPC 完整教程 | 🔴 必读 |

---

## 📊 统计信息

- **文档总数**: 1 份
- **总字数**: ~40,000+
- **适用版本**: Godot 4.x

---

## 🎯 核心内容

### 多人联机框架
- HighLevel API vs LowLevel API
- MultiplayerSynchronizer 自动同步
- RPC（远程过程调用）系统
- 权威模型设计

### ENet 传输
- ENet 服务器搭建
- 客户端连接
- 传输配置优化

### 网络同步
- 属性同步
- RPC 同步
- 网络变量

### 实战案例
- 多人游戏架构
- 网络同步优化
- 常见问题解决

---

## ⚠️ 重要踩坑点

1. **权威模型** - 服务器必须是权威方
2. **RPC 权限** - 注意 RPC 的权限设置
3. **网络延迟** - 考虑延迟补偿
4. **安全性** - 验证所有客户端输入

---

## 🔗 Wiki 层映射

- 指南页面：*待创建* - 多人联机网络实战指南

---

**维护者**: Knowledge Base Administrator
