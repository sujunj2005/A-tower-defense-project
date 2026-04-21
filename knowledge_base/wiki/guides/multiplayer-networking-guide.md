# 多人游戏网络实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 13_Multiplayer_Networking.md](../../base/multiplayer-networking/13_Multiplayer_Networking.md)  
> **重要性**: 🔴 必读 - 多人联机网络完整教程

---

## 📋 概述

Godot 4.x 提供了强大的多人游戏网络系统，支持 HighLevel API（自动同步）和 LowLevel API（自定义协议）。本指南涵盖从基础到高级的多人游戏开发技术。

---

## 🎯 核心概念

### 1. 网络架构

**权威模型（Authoritative Model）**：
- **服务器（Server/Host）**: 拥有游戏状态的最终决定权
- **客户端（Client）**: 发送输入，接收状态更新
- **主机（Host）**: 既是服务器又是客户端

### 2. 同步方式

**自动同步（HighLevel API）**：
- MultiplayerSynchronizer 节点
- 自动同步属性和动画
- 适合简单同步需求

**手动同步（LowLevel API）**：
- RPC（远程过程调用）
- 自定义同步逻辑
- 适合复杂游戏逻辑

### 3. 传输层

**ENet**（推荐）：
- 可靠 UDP 协议
- 自动重传和排序
- 适合实时游戏

**WebSocket**：
- 基于 TCP
- 适合网页游戏
- 穿透性好

---

## 🔧 使用方法

### 基础网络设置

```gdscript
# 网络管理器（Autoload）
extends Node

var peer: ENetConnection
var is_server: bool = false

func create_server(port: int = 5000):
    peer = ENetConnection.new()
    var error = peer.create_server(port, 32)  # 最多 32 玩家
    if error != OK:
        print("创建服务器失败")
        return
    
    multiplayer.multiplayer_peer = peer
    is_server = true
    print("服务器已创建")

func join_server(ip: String, port: int = 5000):
    peer = ENetConnection.new()
    peer.create_client(ip, port)
    multiplayer.multiplayer_peer = peer
    is_server = false
    print("已加入服务器")

func stop_network():
    multiplayer.multiplayer_peer = null
    if peer:
        peer.close_connection()
        peer = null
```

### MultiplayerSynchronizer（自动同步）

```gdscript
# 玩家节点结构
# Player (CharacterBody2D)
# ├─ MultiplayerSynchronizer
# │  ├─ position (同步位置)
# │  └─ velocity (同步速度)
# ├─ Sprite2D
# └─ CollisionShape2D

# 无需代码，自动同步！
# 配置：
# 1. 添加 MultiplayerSynchronizer
# 2. 添加要同步的属性
# 3. 设置同步间隔（默认 0.1 秒）
```

### RPC（远程过程调用）

```gdscript
extends CharacterBody2D

# 服务器调用，所有客户端执行
@rpc("any_peer", "call_remote", "reliable")
func receive_input(input_data: Vector2):
    velocity = input_data * speed

# 客户端调用，仅服务器执行
@rpc("authority", "call_local", "reliable")
func server_only_function():
    # 处理游戏逻辑
    pass

# 调用示例
if is_instance_valid(player):
    player.receive_input.rpc(Input.get_vector("move_left", "move_right"))
```

---

## 🎨 实战示例

### 1. 简单多人移动

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0
var player_id: int

@rpc("any_peer", "call_remote", "reliable")
func sync_position(pos: Vector2, vel: Vector2):
    position = pos
    velocity = vel

func _physics_process(delta):
    if multiplayer.is_server():
        # 服务器处理逻辑
        var input = Input.get_vector("move_left", "move_right")
        velocity = input * speed
        move_and_slide()
        
        # 同步给所有客户端
        sync_position.rpc(position, velocity)
    else:
        # 客户端接收同步
        pass
```

### 2. 大厅系统

```gdscript
extends Node

var players = {}

@rpc("any_peer", "call_remote", "reliable")
func player_joined(player_id: int, player_name: String):
    players[player_id] = player_name
    print("%s 加入了游戏" % player_name)

@rpc("any_peer", "call_remote", "reliable")
func player_left(player_id: int):
    if players.has(player_id):
        print("%s 离开了游戏" % players[player_id])
        players.erase(player_id)

func _on_connected_to_server():
    var my_id = multiplayer.get_unique_id()
    var my_name = "Player_%d" % my_id
    player_joined.rpc(my_id, my_name)
```

---

## ⚠️ 常见踩坑

### 1. 客户端预测

**问题**：客户端输入到服务器响应有延迟

**解决方案**：
```gdscript
# 客户端立即执行本地操作
func handle_input():
    move_local()  # 立即移动
    send_input_to_server()  # 同时发送给服务器

# 服务器校正
func server_correction():
    if client_position != server_position:
        smooth_correction()  # 平滑校正
```

### 2. 网络抖动

**问题**：网络延迟导致卡顿

**解决方案**：
- 使用插值平滑位置
- 实现客户端预测
- 增加缓冲区

---

## 🔗 相关资源

### Base 层
- [13_Multiplayer_Networking.md](../../base/multiplayer-networking/13_Multiplayer_Networking.md) - 完整网络教程

### Wiki 层
- *待创建* - 网络架构设计

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
