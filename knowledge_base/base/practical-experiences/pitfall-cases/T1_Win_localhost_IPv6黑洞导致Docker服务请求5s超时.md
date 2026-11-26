---
doc_type: pitfall
category: 环境与工具链
---

# T1：Windows 下 localhost 走 IPv6 ::1 黑洞导致 Docker 服务请求固定 5s 超时

> **日期**: 2026-10-16 | **严重性**: 🔴 高 | **来源**: TestMCP Qdrant 重建实战复盘

## 现象

- Qdrant 全量重灌速率仅 ~71 points/min（按此推算需 8 小时+）
- 宿主机 `Invoke-WebRequest http://localhost:6333` 超时，但容器日志显示 Qdrant 已正常监听 6333
- 每次数据库写请求耗时**恒定 5.02s**（不是随机慢，是精确的超时值）

## 排查过程（排除法）

1. **排除模型性能**：独立基准 `model.encode` 达 329 chunks/s（bge-small-zh, 24 线程）→ 嵌入无辜
2. **排除算力**：基准与灌入并行运行互不影响
3. **锁定网络路径**：单测 `qdrant_client` upsert，`localhost` 每次恒定 5.02s；换 `127.0.0.1` 同一请求 **0.009s**

## 根因

`localhost` 在 Windows 上优先解析为 IPv6 `::1`。Docker Desktop 的端口转发只监听 IPv4（`0.0.0.0`），`::1:6333` 无进程接收且被静默丢弃（非 RST），每次请求都等满 TCP 超时（~5s）才回落 IPv4 成功。**每请求 5s × 海量小请求 = 吞吐崩溃**。

同场叠加因素：系统代理 `127.0.0.1:10808` 未设本地绕过，`Invoke-WebRequest` 的 localhost 请求被代理拦截（与 IPv6 问题独立，需分别排除）。

## 修复

```python
# ❌ QDRANT_URL = "http://localhost:6333"
QDRANT_URL = "http://127.0.0.1:6333"
```

修复后灌入提速 ~100 倍（8h → 12min）。

## 确定性结论

1. **Windows 上连接 Docker 暴露的端口，永远写 `127.0.0.1` 不写 `localhost`**
2. 恒定整秒的请求耗时 = 超时重试特征，优先怀疑 DNS 解析/网络栈，而不是被测服务本身
3. 排查顺序：先隔离各环节做独立基准（模型/单请求），再用对照实验（localhost vs 127.0.0.1）定位
4. 系统代理开启时，诊断脚本用 `curl.exe --noproxy "*"`，Python 进程设 `NO_PROXY=localhost,127.0.0.1`
