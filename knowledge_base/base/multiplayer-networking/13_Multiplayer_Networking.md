# Godot 4.x 多人联机网络编程

> 来源项目：`Simple Multiplayer` | 适用版本：Godot 4.x（已更新至 4.6.1）| 最后更新：2026-04-01

---

## 目录

1. [多人联机架构概览](#1-多人联机架构概览)
2. [ENet 连接管理（服务器/客户端）](#2-enet-连接管理服务器客户端)
3. [游戏状态管理（Autoload 单例）](#3-游戏状态管理autoload-单例)
4. [玩家生成与销毁](#4-玩家生成与销毁)
5. [MultiplayerSynchronizer 与属性同步](#5-multiplayersynchronizer-与属性同步)
6. [SceneReplicationConfig 配置详解](#6-scenereplicationconfig-配置详解)
7. [权限控制：set_multiplayer_authority](#7-权限控制set_multiplayer_authority)
8. [输入处理与本地预测](#8-输入处理与本地预测)
9. [RPC 远程过程调用](#9-rpc-远程过程调用)
10. [Steam P2P 集成（替代 ENet）](#10-steam-p2p-集成替代-enet)
11. [多人联机踩坑记录](#11-多人联机踩坑记录)

---

## 1. 多人联机架构概览

### 1.1 Godot 多人联机核心组件

```
┌─────────────────────────────────────────────────────┐
│                   MultiplayerAPI                     │
│  (全局多人联机 API，管理连接、RPC、同步)              │
├─────────────────────────────────────────────────────┤
│              MultiplayerPeer (传输层)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ ENetMulti-   │  │ SteamMulti-  │  │ WebSocket │ │
│  │ playerPeer   │  │ playerPeer   │  │ Multi-    │ │
│  │ (LAN/互联网) │  │ (Steam P2P)  │  │ playerPeer│ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
├─────────────────────────────────────────────────────┤
│  MultiplayerSynchronizer  (节点级属性同步)            │
│  SceneReplicationConfig   (同步配置)                 │
│  @rpc 注解                 (远程过程调用)             │
└─────────────────────────────────────────────────────┘
```

### 1.2 常用传输层对比

| 传输层 | 适用场景 | 优点 | 缺点 |
|--------|---------|------|------|
| `ENetMultiplayerPeer` | LAN/互联网 | 内置、简单、支持 NAT 穿透 | 需要端口转发 |
| `SteamMultiplayerPeer` | Steam 平台 | 无需端口转发、Steam 好友集成 | 需要 Steam 运行 |
| `WebSocketMultiplayerPeer` | Web/移动端 | 穿透防火墙 | 需要 WebSocket 服务器 |

### 1.3 服务器-客户端模型

Godot 4.x 的多人联机基于**服务器-客户端模型**（也称为 Listen Server 模式）：

- **服务器（Host）**：既是服务器也是客户端，运行游戏逻辑 + 网络转发
- **客户端（Client）**：连接到服务器，发送输入、接收状态

```
Host (Server + Client)          Client
┌──────────────────┐           ┌──────────────┐
│  Game Logic      │◄────────►│  Game Logic  │
│  Network Relay   │           │  Input Send  │
│  Authority       │           │  State Recv  │
└──────────────────┘           └──────────────┘
```

> **踩坑点**：Godot 4.x 的默认多人联机模型是**权威服务器**（Authoritative Server）。服务器拥有所有游戏状态的最终决定权，客户端只发送输入。不要让客户端直接修改共享游戏状态。

---

## 2. ENet 连接管理（服务器/客户端）

> 来源项目：`Simple Multiplayer` / `menu.gd`

### 2.1 创建服务器

```gdscript
func _on_create_pressed() -> void:
    var peer := ENetMultiplayerPeer.new()
    var result: int = peer.create_server(PORT, MAX_CLIENTS)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        print("Server created on port %d" % PORT)
        Game.load_map()
    else:
        push_error("Failed to create server: error %d" % result)
```

### 2.2 创建客户端

```gdscript
func _on_connect_pressed() -> void:
    var peer := ENetMultiplayerPeer.new()
    var result: int = peer.create_client(SERVER_IP, PORT)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        print("Connecting to %s:%d" % [SERVER_IP, PORT])
        Game.load_map()
    else:
        push_error("Failed to connect: error %d" % result)
```

### 2.3 完整的连接管理器

```gdscript
extends Node

const PORT: int = 1337
const MAX_CLIENTS: int = 32

var is_host: bool = false

func host_game() -> void:
    var peer := ENetMultiplayerPeer.new()
    var result := peer.create_server(PORT, MAX_CLIENTS)
    if result != OK:
        push_error("Failed to create server")
        return
    multiplayer.multiplayer_peer = peer
    is_host = true
    _setup_signals()
    print("Server started. ID: %d" % multiplayer.get_unique_id())

func join_game(ip: String) -> void:
    var peer := ENetMultiplayerPeer.new()
    var result := peer.create_client(ip, PORT)
    if result != OK:
        push_error("Failed to connect to %s:%d" % [ip, PORT])
        return
    multiplayer.multiplayer_peer = peer
    is_host = false
    _setup_signals()
    print("Connecting... ID: %d" % multiplayer.get_unique_id())

func _setup_signals() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
    multiplayer.connection_failed.connect(_on_connection_failed)

func _on_peer_connected(id: int) -> void:
    print("Peer connected: %d" % id)

func _on_peer_disconnected(id: int) -> void:
    print("Peer disconnected: %d" % id)

func _on_server_disconnected() -> void:
    print("Disconnected from server")
    multiplayer.multiplayer_peer = null

func _on_connection_failed() -> void:
    print("Connection failed")
    multiplayer.multiplayer_peer = null
```

> **踩坑点**：`multiplayer.get_unique_id()` 返回 1 表示服务器（Host），客户端从 2 开始递增。在判断是否为服务器时使用 `multiplayer.is_server()` 而不是硬编码 ID。

> **踩坑点**：`ENetMultiplayerPeer.create_server()` 的第二个参数是最大客户端数（不包括服务器自身）。如果设置为 0，则不限制连接数。

> **踩坑点**：连接失败后必须将 `multiplayer.multiplayer_peer` 设为 `null`，否则后续连接会失败。

---

## 3. 游戏状态管理（Autoload 单例）

> 来源项目：`Simple Multiplayer` / `game.gd`

### 3.1 Autoload 单例架构

将游戏管理器注册为 Autoload 单例，确保所有场景都能访问：

```
project.godot 配置：
[autoload]
Game="*res://scenes/game.gd"
```

```gdscript
extends Node

const PORT: int = 1337

@onready var main: Node = get_tree().root.get_node("Main")
@onready var players: Node = main.get_node("Players")

var menu: Control = null
var map: Node = null

func _ready() -> void:
    menu = preload("res://scenes/menu.tscn").instantiate()
    main.add_child(menu)

    multiplayer.peer_connected.connect(spawn_player)
    multiplayer.peer_disconnected.connect(remove_player)

func load_map() -> void:
    if map != null:
        map.queue_free()
    if menu != null:
        menu.queue_free()

    map = preload("res://scenes/map.tscn").instantiate()
    main.add_child(map)

    spawn_player(multiplayer.get_unique_id())
```

### 3.2 场景树结构

```
Root
├── Main (Node) ← main.tscn
│   ├── Players (Node) ← 所有玩家实例的容器
│   │   ├── 1 (CharacterBody3D) ← 服务器玩家
│   │   ├── 2 (CharacterBody3D) ← 客户端玩家
│   │   └── ...
│   └── Menu (Control) ← 主菜单（加载地图后销毁）
│       └── Map (Node) ← 游戏地图（加载后添加）
```

> **踩坑点**：Autoload 单例在 `_ready()` 时场景树可能尚未完全初始化。使用 `get_tree().root.get_node("Main")` 而不是 `$Main`，因为 Autoload 的 `_ready()` 在 Main 场景加载之前执行。

> **踩坑点**：`peer_connected` 信号在服务器端触发。当新客户端连接时，**只有服务器**会收到这个信号。服务器负责生成所有玩家的实例，然后通过 MultiplayerSynchronizer 同步给其他客户端。

---

## 4. 玩家生成与销毁

> 来源项目：`Simple Multiplayer` / `game.gd`

### 4.1 生成玩家

```gdscript
func spawn_player(id: int) -> void:
    var player := preload("res://scenes/player.tscn").instantiate()
    player.peer_id = id
    players.add_child(player, true)
```

> **踩坑点**：`add_child(player, true)` 的第二个参数 `true` 表示**强制可读名称**。这确保节点名称与 `peer_id` 一致（通过 `name = str(peer_id)` 设置），便于后续通过 `players.get_node(str(id))` 查找玩家。

### 4.2 销毁玩家

```gdscript
func remove_player(id: int) -> void:
    if not players.has_node(str(id)):
        return
    players.get_node(str(id)).queue_free()
```

### 4.3 玩家节点初始化

```gdscript
extends CharacterBody3D

@export var peer_id: int:
    set(value):
        peer_id = value
        name = str(peer_id)
        $Label3D.text = str(peer_id)
        set_multiplayer_authority(peer_id)

func _ready() -> void:
    $Camera3D.current = peer_id == multiplayer.get_unique_id()
    var is_local := is_multiplayer_authority()
    set_process_input(is_local)
    set_physics_process(is_local)
    set_process(is_local)
```

> **踩坑点**：`set_multiplayer_authority(peer_id)` 将该节点的控制权交给对应的客户端。只有拥有权限的客户端才能修改该节点的同步属性。这是 Godot 多人联机的核心权限机制。

> **踩坑点**：每个客户端只应处理自己的输入。通过 `is_multiplayer_authority()` 判断当前客户端是否拥有该节点的权限，只有拥有权限时才启用 `_process_input` 和 `_physics_process`。

---

## 5. MultiplayerSynchronizer 与属性同步

> 来源项目：`Simple Multiplayer` / `player.tscn

### 5.1 什么是 MultiplayerSynchronizer

`MultiplayerSynchronizer` 是 Godot 4.x 中用于自动同步节点属性的节点。它附加到需要同步的节点上，根据 `SceneReplicationConfig` 的配置，自动将属性从权威方（服务器或有权限的客户端）同步到其他客户端。

### 5.2 场景中的配置

```
Player (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── Camera3D
├── Label3D
└── Synchronizer (MultiplayerSynchronizer) ← 属性同步器
    └── replication_config: SceneReplicationConfig
```

### 5.3 同步的工作流程

```
拥有权限的客户端              服务器                其他客户端
      │                        │                      │
      │  修改 position/rotation │                      │
      │ ──────────────────────►│                      │
      │                        │  同步属性变更         │
      │                        │ ────────────────────►│
      │                        │                      │  更新节点属性
      │                        │                      │
```

> **踩坑点**：`MultiplayerSynchronizer` 默认从**权威方**同步到**所有其他客户端**。如果使用权威服务器模型，服务器是权威方；如果使用权限委托（`set_multiplayer_authority`），拥有权限的客户端是权威方。

> **踩坑点**：`MultiplayerSynchronizer` 只同步在 `SceneReplicationConfig` 中显式配置的属性。未配置的属性不会自动同步。

---

## 6. SceneReplicationConfig 配置详解

> 来源项目：`Simple Multiplayer` / `player.tscn

### 6.1 配置结构

```
SceneReplicationConfig:
  properties/0:
    path: NodePath(".:peer_id")
    spawn: true    ← 新玩家加入时发送此属性的初始值
    sync: false    ← 不持续同步（只在生成时发送一次）
    watch: false   ← 不监视变更
  properties/1:
    path: NodePath(".:position")
    spawn: true    ← 新玩家加入时发送初始位置
    sync: true     ← 持续同步位置
    watch: false
  properties/2:
    path: NodePath(".:rotation")
    spawn: true    ← 新玩家加入时发送初始旋转
    sync: true     ← 持续同步旋转
    watch: false
```

### 6.2 配置参数说明

| 参数 | 类型 | 说明 |
|------|------|------|
| `path` | NodePath | 要同步的属性路径，格式 `NodePath(".:property_name")` |
| `spawn` | bool | 新客户端连接时是否发送此属性的当前值 |
| `sync` | bool | 是否在属性变更时持续同步 |
| `watch` | bool | 是否监视属性变更（用于触发回调） |

### 6.3 在代码中创建 SceneReplicationConfig

```gdscript
func _ready() -> void:
    var config := SceneReplicationConfig.new()
    config.add_property(NodePath(".:peer_id"), true, false, false)
    config.add_property(NodePath(".:position"), true, true, false)
    config.add_property(NodePath(".:rotation"), true, true, false)

    var synchronizer := MultiplayerSynchronizer.new()
    synchronizer.replication_config = config
    add_child(synchronizer)
```

> **踩坑点**：`sync: true` 的属性会频繁发送网络数据包。只同步必要的属性（如 `position`、`rotation`），避免同步大量数据（如完整的 `velocity` 向量），以减少网络带宽消耗。

> **踩坑点**：`spawn: true` 确保新加入的客户端能收到现有实体的初始状态。如果设为 `false`，新客户端看到的玩家位置可能是默认值（Vector3.ZERO）。

---

## 7. 权限控制：set_multiplayer_authority

### 7.1 权限委托模式

```gdscript
@export var peer_id: int:
    set(value):
        peer_id = value
        name = str(peer_id)
        set_multiplayer_authority(peer_id)
```

### 7.2 权限检查

```gdscript
func _ready() -> void:
    var is_local := is_multiplayer_authority()
    set_process_input(is_local)
    set_physics_process(is_local)
    set_process(is_local)
```

### 7.3 常用权限 API

```gdscript
multiplayer.get_unique_id()           # 获取当前客户端的唯一 ID
is_multiplayer_authority()            # 当前客户端是否拥有此节点的权限
get_multiplayer_authority()           # 获取拥有此节点权限的客户端 ID
set_multiplayer_authority(id: int)    # 设置拥有此节点权限的客户端 ID
multiplayer.is_server()               # 当前客户端是否为服务器
```

### 7.4 权限委托 vs 权威服务器

| 模式 | 权限方 | 优点 | 缺点 |
|------|--------|------|------|
| 权威服务器 | 服务器 | 防作弊、一致性好 | 服务器负载高、输入延迟 |
| 权限委托 | 拥有节点的客户端 | 低延迟、服务器负载低 | 可能被作弊 |

本项目使用**权限委托模式**：每个玩家拥有自己角色的权限，直接在本地处理物理和输入，通过 `MultiplayerSynchronizer` 同步位置和旋转给其他客户端。

> **踩坑点**：权限委托模式下，客户端可以伪造位置数据。如果需要防作弊，应使用权威服务器模式，客户端只发送输入，服务器计算物理后同步结果。

---

## 8. 输入处理与本地预测

> 来源项目：`Simple Multiplayer` / `player.gd`

### 8.1 本地输入处理

```gdscript
extends CharacterBody3D

const GRAVITY := 30.0
const SPEED := 15.0
const JUMP_VELOCITY := 10.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    if Input.is_action_just_pressed("move_jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
```

### 8.2 鼠标视角控制

```gdscript
func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        Input.mouse_mode = (
            Input.MOUSE_MODE_CAPTURED
            if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
            else Input.MOUSE_MODE_VISIBLE
        )

func _input(event: InputEvent) -> void:
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        return
    if event is InputEventMouseMotion:
        rotation.y += event.relative.x * -0.001
```

### 8.3 相机本地化

```gdscript
func _ready() -> void:
    $Camera3D.current = peer_id == multiplayer.get_unique_id()
```

> **踩坑点**：每个客户端只应激活自己的相机（`$Camera3D.current = true`）。如果多个相机同时激活，渲染会出现问题。

> **踩坑点**：鼠标捕获状态（`Input.mouse_mode`）是**本地状态**，不需要同步。每个客户端独立管理自己的鼠标状态。

> **踩坑点**：在权限委托模式下，`_physics_process` 只在拥有权限的客户端上执行。其他客户端的玩家角色通过 `MultiplayerSynchronizer` 接收同步的位置和旋转，不需要本地物理模拟。

---

## 9. RPC 远程过程调用

### 9.1 RPC 基础

`@rpc` 注解用于标记可通过网络调用的函数：

```gdscript
extends Node

@rpc("any_peer", "call_local", "reliable")
func chat_message(sender_id: int, text: String) -> void:
    print("[%d] %s" % [sender_id, text])

func _ready() -> void:
    chat_message.rpc(multiplayer.get_unique_id(), "Hello!")
```

### 9.2 RPC 属性

| 属性 | 说明 |
|------|------|
| `"authority"` | 只有权威方可以调用（默认） |
| `"any_peer"` | 任何客户端都可以调用 |
| `"call_local"` | 在本地也执行（默认不执行） |
| `"reliable"` | 可靠传输（TCP 风格，保证到达） |
| `"unreliable"` | 不可靠传输（UDP 风格，可能丢失） |
| `"unreliable_ordered"` | 不可靠但有序传输 |
| `"channel"` | 指定传输通道（0-255） |
| `"transfer_mode"` | 传输模式（替代 reliable/unreliable） |
| `"transfer_channel"` | 传输通道（替代 channel） |

### 9.3 RPC 调用方式

```gdscript
func do_something() -> void:
    pass

func _ready() -> void:
    do_something.rpc()                              # 发送给所有客户端
    do_something.rpc_id(1)                          # 只发送给 ID 为 1 的客户端
    do_something.rpc_id(multiplayer.get_unique_id()) # 只在本地执行
```

### 9.4 实用 RPC 示例

```gdscript
extends Node

@rpc("any_peer", "call_local", "reliable")
func player_died(killer_id: int, victim_id: int) -> void:
    print("Player %d killed Player %d" % [killer_id, victim_id])

@rpc("authority", "call_local", "unreliable")
func update_score(scores: Dictionary) -> void:
    for id: int in scores:
        var label := get_node("ScoreBoard/" + str(id))
        if label:
            label.text = str(scores[id])

@rpc("any_peer", "reliable")
func request_spawn() -> void:
    if multiplayer.is_server():
        spawn_player(multiplayer.get_remote_sender_id())
```

> **踩坑点**：`@rpc` 函数的参数必须是可序列化的类型（int、float、String、Vector2/3、Array、Dictionary 等）。不能传递 Object 引用或 Resource。

> **踩坑点**：`multiplayer.get_remote_sender_id()` 只能在 `@rpc("any_peer")` 函数内部调用，返回发起 RPC 调用的客户端 ID。在非 RPC 函数中调用会返回 0。

> **踩坑点**：Godot 4.x 中 `@rpc` 注解是必需的。Godot 3.x 的 `remote`、`master`、`puppet`、`remotesync` 关键字已全部废弃。

---

## 10. Steam P2P 集成（替代 ENet）

### 10.1 为什么使用 Steam P2P

| 对比项 | ENet | Steam P2P |
|--------|------|-----------|
| NAT 穿透 | 需要端口转发 | 自动（Steam 中继） |
| 好友系统集成 | 无 | 内置 |
| 成就/排行榜 | 无 | 内置 |
| 需要 Steam | 不需要 | 需要 |
| 延迟 | 取决于网络 | 通常更优（Steam 服务器优化） |

### 10.2 使用 SteamMultiplayerPeer 替代 ENet

```gdscript
extends Node

func host_game_via_steam() -> void:
    var peer := SteamMultiplayerPeer.new()
    var result := peer.create_host(0)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        print("Steam host created. ID: %d" % multiplayer.get_unique_id())
    else:
        push_error("Failed to create Steam host")

func join_game_via_steam(lobby_id: uint64) -> void:
    var peer := SteamMultiplayerPeer.new()
    var result := peer.create_client(lobby_id, 0)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        print("Connecting to Steam lobby...")
    else:
        push_error("Failed to connect to Steam lobby")
```

### 10.3 ENet 与 Steam P2P 代码对比

```gdscript
# ENet 版本
func host_enet() -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_server(PORT)
    multiplayer.multiplayer_peer = peer

# Steam 版本
func host_steam() -> void:
    var peer := SteamMultiplayerPeer.new()
    peer.create_host(0)
    multiplayer.multiplayer_peer = peer
```

> **关键点**：一旦设置了 `multiplayer.multiplayer_peer`，后续的所有多人联机代码（`spawn_player`、`MultiplayerSynchronizer`、`@rpc` 等）完全相同，与传输层无关。这就是 Godot 多人联机架构的优势——传输层可插拔。

> **踩坑点**：`SteamMultiplayerPeer` 需要 GodotSteam 插件。确保在项目设置中启用了 Steam 插件，并且 Steam 客户端正在运行。

> **踩坑点**：`SteamMultiplayerPeer.create_host(0)` 的参数是通道 ID，不是端口号。`create_client(lobby_id, 0)` 的第一个参数是 Steam Lobby ID，不是 IP 地址。

---

## 11. 多人联机踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 新客户端看不到已有玩家 | `SceneReplicationConfig` 中 `spawn` 未设为 `true` | 将 `position`、`rotation` 等属性的 `spawn` 设为 `true` |
| 玩家位置不同步 | 未添加 `MultiplayerSynchronizer` | 在玩家场景中添加 `MultiplayerSynchronizer` 节点 |
| 所有玩家同时移动 | 未设置 `set_multiplayer_authority` | 在 `peer_id` setter 中调用 `set_multiplayer_authority(peer_id)` |
| RPC 函数未执行 | 缺少 `@rpc` 注解 | 在函数定义前添加 `@rpc` 注解 |
| 连接后场景未加载 | `peer_connected` 信号连接时机不对 | 在设置 `multiplayer_peer` 之前连接信号 |
| 服务器断开后客户端卡死 | 未处理 `server_disconnected` 信号 | 连接 `server_disconnected` 信号，清理 `multiplayer_peer` |
| `add_child` 报错 | 节点名称冲突 | 使用 `add_child(node, true)` 强制可读名称 |
| 多个相机同时激活 | 未本地化相机 | 只在 `peer_id == multiplayer.get_unique_id()` 时设置 `current = true` |
| 输入被其他客户端处理 | 未禁用非本地玩家的输入处理 | 使用 `is_multiplayer_authority()` 控制处理开关 |
| Steam P2P 连接失败 | Steam 客户端未运行 | 检查 `Steam.isSteamRunning()` |
| `get_remote_sender_id()` 返回 0 | 在非 RPC 函数中调用 | 只在 `@rpc("any_peer")` 函数内使用 |
| 网络延迟导致卡顿 | 同步频率过高或属性过多 | 减少 `sync: true` 的属性数量，使用插值平滑 |

### 11.1 Godot 3.x → 4.x 多人联机迁移

| Godot 3.x | Godot 4.x |
|-----------|-----------|
| `NetworkedMultiplayerENet` | `ENetMultiplayerPeer` |
| `remote` / `master` / `puppet` | `@rpc` 注解 |
| `get_tree().network_peer` | `multiplayer.multiplayer_peer` |
| `get_tree().get_network_unique_id()` | `multiplayer.get_unique_id()` |
| `get_tree().is_network_server()` | `multiplayer.is_server()` |
| `get_tree().set_network_peer()` | `multiplayer.multiplayer_peer = peer` |
| `rset()` / `rset_unreliable()` | `MultiplayerSynchronizer` |
| `set_network_master(id)` | `set_multiplayer_authority(id)` |
| `get_network_master()` | `get_multiplayer_authority()` |
| `is_network_master()` | `is_multiplayer_authority()` |

### 11.2 Godot 4.6 网络相关变更

Godot 4.6 对网络模块的变更较小，主要是内部重构：

| 变更 | 影响 | 兼容性 |
|------|------|--------|
| `StreamPeerTCP` 方法移至 `StreamPeerSocket` 基类 | GDScript 无需修改 | 完全兼容 |
| `TCPServer` 方法移至 `SocketServer` 基类 | GDScript 无需修改 | 完全兼容 |
| `MultiplayerSynchronizer` / `SceneReplicationConfig` | 无变更 | 完全兼容 |
| `ENetMultiplayerPeer` | 无变更 | 完全兼容 |

> **结论**：从 Godot 4.1 到 4.6.1，多人联机 API 没有破坏性变更，本项目代码可以直接在最新版本中使用。
