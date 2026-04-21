# GodotSteam Steam 平台对接完全指南

> 适用版本：Godot 4.x（已更新至 4.6.1）/ GodotSteam 4.18 / Steamworks SDK 1.64 | 最后更新：2026-04-01

---

## 目录

1. [GodotSteam 概述与环境搭建](#1-godotsteam-概述与环境搭建)
2. [Steam 初始化与全局管理](#2-steam-初始化与全局管理)
3. [成就与统计系统](#3-成就与统计系统)
4. [排行榜系统](#4-排行榜系统)
5. [大厅系统与多人联机](#5-大厅系统与多人联机)
6. [P2P 网络通信](#6-p2p-网络通信)
7. [语音聊天系统](#7-语音聊天系统)
8. [身份验证系统](#8-身份验证系统)
9. [头像与用户信息](#9-头像与用户信息)
10. [输入与手柄支持](#10-输入与手柄支持)
11. [Steam Overlay 与商店](#11-steam-overlay-与商店)
12. [场景加载管理器](#12-场景加载管理器)
13. [GodotSteam 版本迁移指南](#13-godotsteam-版本迁移指南)
14. [常见踩坑与解决方案](#14-常见踩坑与解决方案)

---

## 1. GodotSteam 概述与环境搭建

### 1.1 什么是 GodotSteam

GodotSteam 是 Godot 的 Steamworks SDK 封装插件，通过 GDExtension 提供 Steam 平台功能。项目已从 GitHub 迁移至 Codeberg。

- **当前最新版本**：GodotSteam 4.18（Steamworks SDK 1.64）
- **支持 Godot 版本**：4.4+（GDExtension 通用版）/ 4.5.2 / 4.6.1（专用版）
- **支持平台**：Windows（32/64 位）、Linux（64/ARM64）、macOS、Android ARM64
- **项目地址**：https://codeberg.org/godotsteam/GodotSteam

### 1.2 安装步骤

**方式一：GDExtension 通用版（推荐，适用于 Godot 4.4+）**

1. 从 Codeberg Releases 下载 `godotsteam-4.18-gdextension-plugin-4.4.zip`
2. 解压到项目根目录（`addons/godotsteam/`）
3. 在 `project.godot` 中无需额外配置，插件自动加载

**方式二：版本专用版（适用于 Godot 4.5.2 / 4.6.1）**

1. 下载对应版本的压缩包，如 `win64-g461-s164-gs418-editor.tar.xz`
2. 解压到项目根目录
3. 同时下载模板包 `godotsteam-g461-s164-gs418-templates.tar.xz` 用于导出

### 1.3 项目配置

```ini
# project.godot
[application]
config/name="My Steam Game"
config/features=PackedStringArray("4.6")

[autoload]
SteamManager="*res://src/global.gd"
```

### 1.4 Steamworks 后端配置

1. 在 [Steamworks Partner](https://partner.steamgames.com/) 注册应用
2. 配置成就、统计、排行榜等
3. 下载 `steam_appid.txt` 文件放入项目根目录
4. 导出时在导出预设中配置 Steam App ID

> **踩坑点**：开发时需要 Steam 客户端运行。如果没有 Steam 客户端，`Steam.steamInit()` 会失败。确保 `steam_appid.txt` 中的 App ID 与 Steamworks 后台一致。

---

## 2. Steam 初始化与全局管理

### 2.1 全局初始化脚本（Autoload）

这是所有 Steam 功能的基础，必须作为 Autoload 加载：

```gdscript
extends Node

var IS_ON_STEAM: bool = false
var IS_ON_STEAM_DECK: bool = false
var IS_ONLINE: bool = false
var IS_OWNED: bool = false
var STEAM_ID: int = 0
var STEAM_USERNAME: String = "No one"


func _ready() -> void:
	_initialize_Steam()

	if IS_ON_STEAM_DECK:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _initialize_Steam() -> void:
	if Engine.has_singleton("Steam"):
		var INIT: Dictionary = Steam.steamInit(false)
		if INIT['status'] != 1:
			print("[STEAM] Failed to initialize: " + str(INIT['verbal']))
			get_tree().quit()

		IS_ON_STEAM = true
		IS_ON_STEAM_DECK = Steam.isSteamRunningOnSteamDeck()
		IS_ONLINE = Steam.loggedOn()
		IS_OWNED = Steam.isSubscribed()
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()

		if not IS_OWNED:
			print("[STEAM] User does not own this game")


func _process(_delta: float) -> void:
	if IS_ON_STEAM:
		Steam.run_callbacks()
```

> **踩坑点**：`Steam.run_callbacks()` 必须在 `_process()` 中每帧调用，否则所有 Steam 回调（信号）都不会触发。这是最常见的遗漏。

### 2.2 GodotSteam 4.14+ 自动初始化

从 GodotSteam 4.14 开始，支持通过 Project Settings 自动初始化：

```gdscript
# 无需手动调用 steamInit()，插件会自动完成
# 在 Project Settings > Steam 中配置：
# - steam_app_id: 你的应用 ID
# - auto_init: true
# - run_callbacks: true（自动在 _process 中调用）
```

### 2.3 steamInitEx() 详细初始化（4.4+）

```gdscript
func _initialize_Steam_Advanced() -> void:
	if Engine.has_singleton("Steam"):
		var INIT: Dictionary = Steam.steamInitEx(true, 0)
		# steamInitEx 返回更详细的状态信息
		if INIT['status'] != 1:
			match INIT['status']:
				Steam.INIT_FAILED_SHUTDOWN:
					print("[STEAM] Steam is shutting down")
				Steam.INIT_FAILED_NO_STEAM_CLIENT:
					print("[STEAM] Steam client is not running")
				Steam.INIT_FAILED_NO_CONNECTION:
					print("[STEAM] Cannot connect to Steam")
				_
					print("[STEAM] Unknown error: " + str(INIT['verbal']))
```

### 2.4 Steam 信号连接辅助函数

项目中所有示例都使用统一的信号连接辅助函数：

```gdscript
func _connect_Steam_Signals(this_signal: String, this_function: String) -> void:
	var SIGNAL_CONNECT: int = Steam.connect(this_signal, Callable(self, this_function))
	if SIGNAL_CONNECT > OK:
		print("[STEAM] Connecting " + str(this_signal) + " to " + str(this_function) + " failed: " + str(SIGNAL_CONNECT))
```

> **踩坑点**：GodotSteam 的信号连接返回值大于 `OK`（0）表示失败，这与 Godot 内置信号的返回值约定不同。`OK` 表示成功，非零值表示错误码。

---

## 3. 成就与统计系统

### 3.1 定义成就和统计数据结构

```gdscript
extends Node

var ACHIEVEMENTS: Dictionary = {
	"ACH_WIN_ONE_GAME": false,
	"ACH_WIN_100_GAMES": false,
	"ACH_TRAVEL_FAR_ACCUM": false,
	"ACH_TRAVEL_FAR_SINGLE": false,
}

var STATISTICS: Dictionary = {
	"NumGames": 0,
	"NumWins": 0,
	"NumLosses": 0,
	"FeetTraveled": 0.0,
	"MaxFeetTraveled": 0.0,
}
```

> **注意**：成就名称必须与 Steamworks 后台配置的 API 名称完全一致（区分大小写）。

### 3.2 请求当前用户数据

```gdscript
func _ready() -> void:
	Steam.current_stats_received.connect(_on_Stats_Ready)
	Steam.user_stats_received.connect(_on_Stats_Ready)

	if not Steam.requestCurrentStats():
		print("[STEAM] Failed to request current stats!")


func _on_Stats_Ready(_game: int, result: bool, _user: int) -> void:
	if not result:
		print("[STEAM] Failed to receive stats")
		return

	for ACHIEVEMENT in ACHIEVEMENTS.keys():
		var ACHIEVE: Dictionary = Steam.getAchievement(ACHIEVEMENT)
		if ACHIEVE['ret']:
			ACHIEVEMENTS[ACHIEVEMENT] = ACHIEVE['achieved']

	STATISTICS["NumGames"] = Steam.getStatInt("NumGames")
	STATISTICS["NumWins"] = Steam.getStatInt("NumWins")
	STATISTICS["FeetTraveled"] = Steam.getStatFloat("FeetTraveled")
```

> **踩坑点**：`current_stats_received` 信号在 GodotSteam 4.12 中已被移除（冗余），请只使用 `user_stats_received`。

### 3.3 解锁成就

```gdscript
func unlock_achievement(achievement_name: String) -> void:
	if ACHIEVEMENTS.get(achievement_name, true):
		return

	var SET_ACHIEVE: bool = Steam.setAchievement(achievement_name)
	if SET_ACHIEVE:
		ACHIEVEMENTS[achievement_name] = true
		print("[STEAM] Achievement unlocked: " + achievement_name)

	var STORE_STATS: bool = Steam.storeStats()
	if not STORE_STATS:
		print("[STEAM] Failed to store stats!")
```

> **踩坑点**：`setAchievement()` 只在本地设置，必须调用 `storeStats()` 才会同步到 Steam 服务器。从 GodotSteam 4.15 开始，`storeStats()` 不再在析构函数中自动调用。

### 3.4 设置统计数据

```gdscript
func set_stat_int(stat_name: String, value: int) -> void:
	var IS_SET: bool = Steam.setStatInt(stat_name, value)
	if IS_SET:
		STATISTICS[stat_name] = value
		Steam.storeStats()


func set_stat_float(stat_name: String, value: float) -> void:
	var IS_SET: bool = Steam.setStatFloat(stat_name, value)
	if IS_SET:
		STATISTICS[stat_name] = value
		Steam.storeStats()
```

### 3.5 获取成就图标

```gdscript
func get_achievement_icon(achievement_name: String, texture_rect: TextureRect) -> void:
	var HANDLE: int = Steam.getAchievementIcon(achievement_name)
	var BUFFER: Dictionary = Steam.getImageRGBA(HANDLE)

	if BUFFER['success']:
		var ICON: Image = Image.create_from_data(64, 64, false, Image.FORMAT_RGBA8, BUFFER['buffer'])
		texture_rect.set_texture(ImageTexture.create_from_image(ICON))
```

### 3.6 重置所有统计

```gdscript
func reset_all_stats(reset_achievements: bool = false) -> void:
	var IS_RESET: bool = Steam.resetAllStats(reset_achievements)
	if IS_RESET:
		Steam.requestCurrentStats()
```

> **警告**：`resetAllStats(true)` 会同时重置成就，此操作不可逆。仅用于开发调试。

---

## 4. 排行榜系统

### 4.1 查找排行榜

```gdscript
extends Node

var LEADERBOARD_HANDLE: int = 0

func _ready() -> void:
	Steam.leaderboard_find_result.connect(_on_Leaderboard_Find_Result)
	Steam.leaderboard_scores_downloaded.connect(_on_Scores_Downloaded)


func find_leaderboard(name: String) -> void:
	Steam.findLeaderboard(name)


func find_or_create_leaderboard(name: String) -> void:
	Steam.findOrCreateLeaderboard(
		name,
		Steam.LEADERBOARD_SORT_METHOD_ASCENDING,
		Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC
	)


func _on_Leaderboard_Find_Result(handle: int, found: int) -> void:
	if found == 1:
		LEADERBOARD_HANDLE = handle
		print("[STEAM] Leaderboard found, handle: " + str(handle))
	else:
		print("[STEAM] Leaderboard not found")
```

### 4.2 上传分数

```gdscript
func upload_score(score: int) -> void:
	if LEADERBOARD_HANDLE == 0:
		print("[STEAM] No leaderboard handle set")
		return
	Steam.uploadLeaderboardScore(Steam.LEADERBOARD_UPLOAD_SCORE_METHOD_KEEP_BEST, LEADERBOARD_HANDLE, score, [])


func upload_score_force_update(score: int) -> void:
	Steam.uploadLeaderboardScore(Steam.LEADERBOARD_UPLOAD_SCORE_METHOD_FORCE_UPDATE, LEADERBOARD_HANDLE, score, [])
```

### 4.3 下载排行榜数据

```gdscript
func download_leaderboard_entries(start: int, end: int) -> void:
	Steam.downloadLeaderboardEntries(
		start, end,
		Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
		LEADERBOARD_HANDLE
	)


func download_friends_entries() -> void:
	Steam.downloadLeaderboardEntries(
		1, 10,
		Steam.LEADERBOARD_DATA_REQUEST_FRIENDS,
		LEADERBOARD_HANDLE
	)


func download_user_entries(user_ids: Array) -> void:
	Steam.downloadLeaderboardEntriesForUsers(user_ids, LEADERBOARD_HANDLE)


func _on_Scores_Downloaded(message: String, this_handle: int, result: Array) -> void:
	for ENTRY in result:
		print("[STEAM] Rank: " + str(ENTRY['rank']) +
			" | Name: " + str(ENTRY['persona_name']) +
			" | Score: " + str(ENTRY['score']))
```

### 4.4 获取排行榜信息

```gdscript
func get_leaderboard_info() -> void:
	var NAME: String = Steam.getLeaderboardName(LEADERBOARD_HANDLE)
	var SORT: int = Steam.getLeaderboardSortMethod(LEADERBOARD_HANDLE)
	var DISPLAY: int = Steam.getLeaderboardDisplayType(LEADERBOARD_HANDLE)
	var COUNT: int = Steam.getLeaderboardEntryCount(LEADERBOARD_HANDLE)

	print("Name: " + NAME + " | Entries: " + str(COUNT))
```

> **踩坑点**：从 GodotSteam 4.16 开始，`getLeaderboardSortMethod()` 和 `getLeaderboardDisplayType()` 直接返回枚举整数值，不再返回字典。旧代码中 `result['verbal']` 和 `result['result']` 的写法需要更新。

---

## 5. 大厅系统与多人联机

### 5.1 创建和加入大厅

```gdscript
extends Node

var LOBBY_ID: int = 0
var LOBBY_MEMBERS: Array = []
var LOBBY_MAX_MEMBERS: int = 10

func _ready() -> void:
	Steam.lobby_created.connect(_on_Lobby_Created)
	Steam.lobby_joined.connect(_on_Lobby_Joined)
	Steam.lobby_chat_update.connect(_on_Lobby_Chat_Update)
	Steam.lobby_message.connect(_on_Lobby_Message)
	Steam.lobby_data_update.connect(_on_Lobby_Data_Update)
	Steam.lobby_invite.connect(_on_Lobby_Invite)
	Steam.join_requested.connect(_on_Join_Requested)
	Steam.persona_state_change.connect(_on_Persona_Change)
	Steam.p2p_session_request.connect(_on_P2P_Session_Request)
	Steam.p2p_session_connect_fail.connect(_on_P2P_Session_Connect_Fail)


func create_lobby(is_public: bool = true) -> void:
	if LOBBY_ID == 0:
		var lobby_type = Steam.LOBBY_TYPE_PUBLIC if is_public else Steam.LOBBY_TYPE_INVITE_ONLY
		Steam.createLobby(lobby_type, LOBBY_MAX_MEMBERS)


func join_lobby(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)


func leave_lobby() -> void:
	if LOBBY_ID != 0:
		Steam.leaveLobby(LOBBY_ID)
		LOBBY_ID = 0
		for MEMBER in LOBBY_MEMBERS:
			Steam.closeP2PSessionWithUser(MEMBER['steam_id'])
		LOBBY_MEMBERS.clear()
```

### 5.2 大厅创建回调

```gdscript
func _on_Lobby_Created(connect_result: int, lobby_id: int) -> void:
	if connect_result == 1:
		LOBBY_ID = lobby_id
		Steam.setLobbyJoinable(LOBBY_ID, true)
		Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s Lobby")
		Steam.setLobbyData(lobby_id, "mode", "deathmatch")
		Steam.allowP2PPacketRelay(true)
	else:
		print("[STEAM] Failed to create lobby")
```

### 5.3 大厅加入回调

```gdscript
func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		_get_Lobby_Members()
		_make_P2P_Handshake()
	else:
		var REASONS: Dictionary = {
			2: "Lobby no longer exists",
			3: "No permission to join",
			4: "Lobby is full",
			6: "Banned from lobby",
			7: "Limited account",
			8: "Lobby is locked",
		}
		print("[STEAM] Failed to join: " + REASONS.get(response, "Unknown error"))
```

### 5.4 大厅成员管理

```gdscript
func _get_Lobby_Members() -> void:
	LOBBY_MEMBERS.clear()
	var MEMBERS: int = Steam.getNumLobbyMembers(LOBBY_ID)
	for INDEX in range(MEMBERS):
		var MEMBER_ID: int = Steam.getLobbyMemberByIndex(LOBBY_ID, INDEX)
		var MEMBER_NAME: String = Steam.getFriendPersonaName(MEMBER_ID)
		LOBBY_MEMBERS.append({"steam_id": MEMBER_ID, "steam_name": MEMBER_NAME})


func _on_Lobby_Chat_Update(lobby_id: int, changed_id: int, _making_change_id: int, chat_state: int) -> void:
	var CHANGER: String = Steam.getFriendPersonaName(changed_id)
	match chat_state:
		1:
			print("[STEAM] " + CHANGER + " joined the lobby")
		2:
			print("[STEAM] " + CHANGER + " left the lobby")
		8:
			print("[STEAM] " + CHANGER + " was kicked")
		16:
			print("[STEAM] " + CHANGER + " was banned")
	_get_Lobby_Members()
```

### 5.5 大厅聊天消息

```gdscript
func send_lobby_message(message: String) -> void:
	Steam.sendLobbyChatMsg(LOBBY_ID, message)


func _on_Lobby_Message(_result: int, user: int, message: String, type: int) -> void:
	if type == 1:
		var SENDER: String = Steam.getFriendPersonaName(user)
		if user == Steam.getLobbyOwner(LOBBY_ID) and message.begins_with("/"):
			_handle_Host_Command(message)
		else:
			print(SENDER + ": " + message)


func _handle_Host_Command(message: String) -> void:
	if message.begins_with("/kick"):
		var COMMANDS: PackedStringArray = message.split(":", true)
		if COMMANDS.size() > 1 and Global.STEAM_ID == int(COMMANDS[1]):
			leave_lobby()
```

### 5.6 大厅浏览器

```gdscript
func search_lobbies() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("mode", "deathmatch", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.addRequestLobbyListResultCountFilter(20)
	Steam.requestLobbyList()


func _on_Lobby_Match_List(lobbies: Array) -> void:
	for LOBBY in lobbies:
		var NAME: String = Steam.getLobbyData(LOBBY, "name")
		var MODE: String = Steam.getLobbyData(LOBBY, "mode")
		var NUMS: int = Steam.getNumLobbyMembers(LOBBY)
		print("Lobby " + str(LOBBY) + ": " + NAME + " [" + MODE + "] - " + str(NUMS) + " players")
```

---

## 6. P2P 网络通信

> **相关模块**：[13_Multiplayer_Networking.md](../11_Multiplayer_Networking/13_Multiplayer_Networking.md) — Godot 原生多人联机框架（ENet/MultiplayerSynchronizer/RPC）完整教程。本节介绍的是 GodotSteam 原生 P2P 数据包通信，与 Godot 内置的 `MultiplayerAPI` 是独立的两套网络系统。

### 6.1 网络全局脚本

```gdscript
extends Node

var CONNECTION_HANDLE: int = 0
var CLIENT_CHANNEL: int = 1
var HOST_CHANNEL: int = 0
var VOICE_CHANNEL: int = 2


func _send_Message(message_contents) -> void:
	if CONNECTION_HANDLE > 0:
		var RESPONSE: Dictionary = Steam.sendMessageToConnection(CONNECTION_HANDLE, message_contents, 0)
		print("Send result: " + str(RESPONSE['result']))
```

### 6.2 P2P 握手与会话管理

```gdscript
func _make_P2P_Handshake() -> void:
	_send_P2P_Packet(0, {"message": "handshake", "from": Global.STEAM_ID})


func _on_P2P_Session_Request(remote_id: int) -> void:
	var REQUESTER: String = Steam.getFriendPersonaName(remote_id)
	print("[STEAM] P2P request from " + REQUESTER)
	Steam.acceptP2PSessionWithUser(remote_id)
	_make_P2P_Handshake()


func _on_P2P_Session_Connect_Fail(lobby_id: int, session_error: int) -> void:
	var ERRORS: Dictionary = {
		0: "No error",
		1: "Target not running same game",
		2: "Local user doesn't own app",
		3: "Target not connected to Steam",
		4: "Connection timed out",
	}
	print("[STEAM] P2P fail with " + str(lobby_id) + ": " + ERRORS.get(session_error, "Unknown"))
```

### 6.3 发送 P2P 数据包

```gdscript
func _send_P2P_Packet(target: int, packet_data: Dictionary) -> void:
	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	var CHANNEL: int = 0
	var PACKET_DATA: PackedByteArray = var_to_bytes(packet_data)

	var SEND_RESPONSE: bool
	if target == 0:
		for MEMBER in LOBBY_MEMBERS:
			if MEMBER['steam_id'] != Global.STEAM_ID:
				SEND_RESPONSE = Steam.sendP2PPacket(MEMBER['steam_id'], PACKET_DATA, SEND_TYPE, CHANNEL)
	else:
		SEND_RESPONSE = Steam.sendP2PPacket(target, PACKET_DATA, SEND_TYPE, CHANNEL)
```

### 6.4 接收 P2P 数据包

```gdscript
func _process(_delta: float) -> void:
	if LOBBY_ID > 0:
		_read_P2P_Packet()


func _read_P2P_Packet() -> void:
	var PACKET_SIZE: int = Steam.getAvailableP2PPacketSize(0)
	if PACKET_SIZE > 0:
		var PACKET: Dictionary = Steam.readP2PPacket(PACKET_SIZE, 0)
		if PACKET.is_empty():
			return

		var SENDER_ID: int = PACKET['steam_id_remote']
		var PACKET_DATA: PackedByteArray = PACKET['data']
		var READABLE: Dictionary = bytes_to_var(PACKET_DATA)

		match READABLE.get('message', ''):
			"handshake":
				print("[STEAM] Handshake from " + str(SENDER_ID))
			"start":
				_start_Game()
			_:
				_handle_Custom_Packet(SENDER_ID, READABLE)
```

> **踩坑点**：P2P 数据包使用 `var_to_bytes()` 和 `bytes_to_var()` 序列化/反序列化。确保所有发送的数据都是可序列化的类型（Dictionary、Array、基本类型）。不要发送 Object 引用或 Resource。

### 6.5 发送类型选择

```gdscript
# 可靠传输（TCP 模式）- 适用于重要数据
var RELIABLE: int = Steam.P2P_SEND_RELIABLE

# 不可靠传输（UDP 模式）- 适用于频繁更新的位置数据
var UNRELIABLE: int = Steam.P2P_SEND_UNRELIABLE

# 不可靠但无延迟 - 适用于语音数据
var NO_DELAY: int = Steam.P2P_SEND_UNRELIABLE_NO_DELAY

# 启用 Steam 中继备份
Steam.allowP2PPacketRelay(true)
```

---

## 7. 语音聊天系统

### 7.1 语音控制

```gdscript
extends Node

var IS_VOICE_TOGGLED: bool = false
var CURRENT_SAMPLE_RATE: int = 48000
var HAS_LOOPBACK: bool = false


func toggle_voice() -> void:
	IS_VOICE_TOGGLED = !IS_VOICE_TOGGLED
	_change_Voice_Status()


func _change_Voice_Status() -> void:
	Steam.setInGameVoiceSpeaking(Global.STEAM_ID, IS_VOICE_TOGGLED)
	if IS_VOICE_TOGGLED:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()
```

### 7.2 捕获和发送语音

```gdscript
func _process(_delta: float) -> void:
	_check_For_Voice()


func _check_For_Voice() -> void:
	var VOICE_DATA: Dictionary = Steam.getVoice()
	if VOICE_DATA['result'] == Steam.VOICE_RESULT_OK and VOICE_DATA['written']:
		Networking._send_Message(VOICE_DATA['buffer'])
		if HAS_LOOPBACK:
			_process_Voice_Data(VOICE_DATA, "local")
```

> **踩坑点**：GodotSteam 4.17 修复了 `VOICE_RESULT_NO_DATA` 的拼写错误（之前为 `VOICE_RESULT_NO_DATE`）。旧版本中使用此常量时需要注意。

### 7.3 播放语音数据

```gdscript
func _process_Voice_Data(voice_data: Dictionary, voice_source: String) -> void:
	var SAMPLE_RATE: int = Steam.getVoiceOptimalSampleRate()
	var DECOMPRESSED: Dictionary = Steam.decompressVoice(
		voice_data['buffer'],
		voice_data['written'],
		SAMPLE_RATE
	)

	if DECOMPRESSED['result'] == Steam.VOICE_RESULT_OK and DECOMPRESSED['size'] > 0:
		var VOICE_BUFFER: PackedByteArray = DECOMPRESSED['uncompressed']
		VOICE_BUFFER.resize(DECOMPRESSED['size'])

		var AUDIO: AudioStreamWAV = AudioStreamWAV.new()
		AUDIO.mix_rate = SAMPLE_RATE
		AUDIO.data = VOICE_BUFFER
		AUDIO.format = AudioStreamWAV.FORMAT_16_BITS

		if voice_source == "local":
			$LocalPlayer.stream = AUDIO
			$LocalPlayer.play()
		else:
			$RemotePlayer.stream = AUDIO
			$RemotePlayer.play()
```

> **踩坑点**：从 GodotSteam 4.16 开始，`getAvailableVoice()` 已被移除（功能已合并到 `getVoice()` 中）。旧代码中先检查 `getAvailableVoice()` 再调用 `getVoice()` 的模式需要更新为直接调用 `getVoice()`。

### 7.4 GodotSteam 4.17+ 简化语音处理

GodotSteam 4.17 新增了 `getDecompressedVoice()` 函数，将 `getVoice()` 和 `decompressVoice()` 合并：

```gdscript
func _check_For_Voice_Simplified() -> void:
	var RESULT: Dictionary = Steam.getDecompressedVoice()
	if RESULT['result'] == Steam.VOICE_RESULT_OK and RESULT['size'] > 0:
		var AUDIO: AudioStreamWAV = AudioStreamWAV.new()
		AUDIO.mix_rate = RESULT['sample_rate']
		AUDIO.data = RESULT['buffer']
		AUDIO.format = AudioStreamWAV.FORMAT_16_BITS
		$VoicePlayer.stream = AUDIO
		$VoicePlayer.play()
```

---

## 8. 身份验证系统

### 8.1 获取认证票据

```gdscript
extends Node

var TICKET: Dictionary
var CLIENT_TICKETS: Array = []


func _ready() -> void:
	Steam.get_auth_session_ticket_response.connect(_on_Auth_Ticket_Response)
	Steam.validate_auth_ticket_response.connect(_on_Validate_Ticket_Response)


func request_auth_ticket() -> void:
	TICKET = Steam.getAuthSessionTicket()
	print("[STEAM] Ticket: " + str(TICKET))
```

### 8.2 验证认证票据

```gdscript
func begin_auth_session() -> void:
	var RESPONSE: int = Steam.beginAuthSession(TICKET['buffer'], TICKET['size'], Global.STEAM_ID)
	match RESPONSE:
		0:
			print("[STEAM] Ticket is valid")
			CLIENT_TICKETS.append({"id": Global.STEAM_ID, "ticket": TICKET['id']})
		1:
			print("[STEAM] Ticket is invalid")
		2:
			print("[STEAM] Ticket already submitted")
		5:
			print("[STEAM] Ticket has expired")


func _on_Validate_Ticket_Response(auth_id: int, response: int, owner_id: int) -> void:
	var RESPONSES: Dictionary = {
		0: "User verified, ticket valid",
		1: "User not connected to Steam",
		2: "No license / ticket expired",
		3: "User is VAC banned",
		7: "Ticket already used",
	}
	print("[STEAM] Auth response: " + RESPONSES.get(response, "Unknown"))
```

### 8.3 结束认证会话

```gdscript
func cancel_auth_ticket() -> void:
	Steam.cancelAuthTicket(TICKET['id'])


func end_all_auth_sessions() -> void:
	for CLIENT in CLIENT_TICKETS:
		Steam.endAuthSession(CLIENT['id'])
	CLIENT_TICKETS.clear()
```

---

## 9. 头像与用户信息

### 9.1 获取用户头像

```gdscript
extends Node

func _ready() -> void:
	Steam.avatar_loaded.connect(_on_Avatar_Loaded)


func load_avatar(steam_id: int, size: int = Steam.AVATAR_MEDIUM) -> void:
	Steam.getPlayerAvatar(size, steam_id)


func _on_Avatar_Loaded(id: int, avatar_size: int, buffer: PackedByteArray) -> void:
	if buffer.is_empty():
		return

	var AVATAR: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, buffer)
	var TEXTURE: ImageTexture = ImageTexture.create_from_image(AVATAR)

	match avatar_size:
		32:
			$SmallAvatar.set_texture(TEXTURE)
		64:
			$MediumAvatar.set_texture(TEXTURE)
		128:
			$LargeAvatar.set_texture(TEXTURE)
```

### 9.2 头像尺寸常量

```gdscript
Steam.AVATAR_SMALL    # 32x32
Steam.AVATAR_MEDIUM   # 64x64
Steam.AVATAR_LARGE    # 128x128
```

### 9.3 获取好友信息

```gdscript
func get_friend_info(steam_id: int) -> void:
	var NAME: String = Steam.getFriendPersonaName(steam_id)
	var STATE: int = Steam.getFriendPersonaState(steam_id)
	var GAME: Dictionary = Steam.getFriendGamePlayed(steam_id)

	print("Name: " + NAME)
	print("State: " + str(STATE))
	if not GAME.is_empty():
		print("Playing: " + str(GAME.get('game_id', 'unknown')))
```

---

## 10. 输入与手柄支持

### 10.1 初始化 Steam Input

```gdscript
extends Node

var STEAM_CONTROLLERS: Array = []


func init_steam_input() -> void:
	if Steam.inputInit():
		print("[STEAM] Input initialized")
		Steam.runFrame()
	else:
		print("[STEAM] Input init failed")


func get_controllers() -> void:
	STEAM_CONTROLLERS = Steam.getConnectedControllers()
	print("[STEAM] Found " + str(STEAM_CONTROLLERS.size()) + " controllers")

	for CONTROLLER in STEAM_CONTROLLERS.size():
		var TYPE: int = Steam.getInputTypeForHandle(STEAM_CONTROLLERS[CONTROLLER])
		print("Controller " + str(CONTROLLER) + ": type " + str(TYPE))
```

> **踩坑点**：从 GodotSteam 4.5.4 开始，`getInputTypeForHandle()` 返回枚举整数而非字符串。旧代码中 `if TYPE == "Xbox360Controller"` 的写法需要改为 `if TYPE == Steam.INPUT_TYPE_XBOX360`。

### 10.2 触觉反馈

```gdscript
func trigger_haptic(controller_handle: int) -> void:
	Steam.triggerHapticPulse(controller_handle, 0, 500000)


func trigger_vibration(controller_handle: int, left_speed: int = 5000, right_speed: int = 5000) -> void:
	Steam.triggerVibration(controller_handle, left_speed, right_speed)


func trigger_repeated_haptic(controller_handle: int) -> void:
	Steam.triggerRepeatedHapticPulse(controller_handle, 0, 50000, 500000, 10, 0)


func shutdown_steam_input() -> void:
	Steam.inputShutdown()
```

### 10.3 混合使用 Godot 和 Steam 输入

```gdscript
func _ready() -> void:
	Input.joy_connection_changed.connect(_on_Joy_Connection_Changed)


func _on_Joy_Connection_Changed(device_id: int, connected: bool) -> void:
	if connected:
		print("Godot detected: " + Input.get_joy_name(device_id))
```

> **建议**：Steam Input 在某些情况下不太可靠。建议以 Godot 的输入系统为主，Steam Input 作为辅助（用于触觉反馈、手柄类型检测等）。

---

## 11. Steam Overlay 与商店

### 11.1 打开 Steam Overlay

```gdscript
func open_overlay(page: String = "steamid") -> void:
	Steam.activateGameOverlay(page)


func open_overlay_to_user(steam_id: int) -> void:
	Steam.activateGameOverlayToUser("steamid", steam_id)


func open_overlay_web(url: String) -> void:
	Steam.activateGameOverlayToWebPage(url)
```

### 11.2 常用 Overlay 页面

```gdscript
Steam.activateGameOverlay("friends")           # 好友列表
Steam.activateGameOverlay("community")         # 社区
Steam.activateGameOverlay("players")           # 当前玩家
Steam.activateGameOverlay("achievements")      # 成就
Steam.activateGameOverlay("stats")             # 统计
Steam.activateGameOverlay("lobby")             # 大厅
```

> **踩坑点**：从 GodotSteam 4.17 开始，`activateGameOverlayInviteDialog()` 的参数名从 `steam_id` 改为 `lobby_id`，使用时请注意传参含义。

---

## 12. 场景加载管理器

### 12.1 异步场景加载系统

项目中使用了一个通用的场景加载管理器，支持加载动画和退出确认：

```gdscript
extends CanvasLayer

var IS_LOADING: bool = false
var IS_QUIT_OPEN: bool = false
var SCENE_PATH: String


func _ready() -> void:
	set_process_input(true)


func _process(_delta: float) -> void:
	if IS_LOADING:
		var PROGRESS: Array = []
		var STATUS: int = ResourceLoader.load_threaded_get_status(SCENE_PATH, PROGRESS)
		match STATUS:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
			ResourceLoader.THREAD_LOAD_LOADED:
				get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(SCENE_PATH))
				IS_LOADING = false
			ResourceLoader.THREAD_LOAD_FAILED:
				print("[LOADER] Failed to load scene")
				IS_LOADING = false


func load_scene(path: String) -> void:
	if IS_LOADING:
		return
	IS_LOADING = true
	if path == "main":
		SCENE_PATH = "res://src/main.tscn"
	else:
		SCENE_PATH = "res://src/examples/" + str(path) + ".tscn"
	ResourceLoader.load_threaded_request(SCENE_PATH)


func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and event.is_action("ui_cancel"):
		if IS_QUIT_OPEN:
			_resume()
		else:
			_show_Quit_Confirm()
```

> **踩坑点**：`ResourceLoader.load_threaded_get_status()` 的第二个参数 `PROGRESS` 必须是外部传入的数组，函数会将进度值写入此数组。

---

## 13. GodotSteam 版本迁移指南

### 13.1 从旧版（Godot 4.1）迁移到 4.18

**关键变更汇总**：

| 版本 | 变更内容 |
|------|---------|
| 4.18 | Steamworks SDK 1.64 |
| 4.17 | 移除 GameSearch、Music Remote 类；修复 VOICE_RESULT_NO_DATA 拼写；新增 `getDecompressedVoice()` |
| 4.16 | 移除 `getAvailableVoice()`、`getFriendMessage()`、`getClanChatMessage()`；大量返回值从字典改为枚举 |
| 4.15 | `storeStats()` 不再自动调用；新增 `checkFileSignature()` |
| 4.14 | `steamInit()` 第一个参数移除；新增 Project Settings 自动初始化 |
| 4.12 | 移除 `current_stats_received` 回调；移除 `SetPersonaName` |
| 4.10 | 切换到 Steam Flat API |

### 13.2 必须更新的代码

**1. 移除 `getAvailableVoice()` 调用（4.16+）**

```gdscript
# 旧代码（不再工作）
var AVAILABLE: Dictionary = Steam.getAvailableVoice()
if AVAILABLE['result'] == Steam.VOICE_RESULT_OK:
    var VOICE: Dictionary = Steam.getVoice()

# 新代码
var VOICE: Dictionary = Steam.getVoice()
if VOICE['result'] == Steam.VOICE_RESULT_OK and VOICE['written']:
    # 处理语音数据
```

**2. 更新排行榜返回值（4.16+）**

```gdscript
# 旧代码
var SORT: Dictionary = Steam.getLeaderboardSortMethod(HANDLE)
print(SORT['verbal'])

# 新代码
var SORT: int = Steam.getLeaderboardSortMethod(HANDLE)
print(SORT)  # 直接是枚举值
```

**3. 移除 `current_stats_received` 信号（4.12+）**

```gdscript
# 旧代码
Steam.current_stats_received.connect(_on_Stats_Ready)
Steam.user_stats_received.connect(_on_Stats_Ready)

# 新代码（只保留 user_stats_received）
Steam.user_stats_received.connect(_on_Stats_Ready)
```

**4. 更新 `steamInit()` 调用（4.14+）**

```gdscript
# 旧代码
var INIT: Dictionary = Steam.steamInit(true, 480)

# 新代码（第一个参数已移除）
var INIT: Dictionary = Steam.steamInit(false)
```

**5. 更新 `getInputTypeForHandle()` 返回值（4.5.4+）**

```gdscript
# 旧代码
var TYPE: String = Steam.getInputTypeForHandle(HANDLE)

# 新代码
var TYPE: int = Steam.getInputTypeForHandle(HANDLE)
```

### 13.3 GDExtension 通用版 vs 版本专用版

| 特性 | GDExtension 通用版 | 版本专用版 |
|------|-------------------|-----------|
| 兼容性 | Godot 4.4+ 全系列 | 特定 Godot 版本 |
| 安装方式 | 解压到 addons/ | 解压到项目根目录 |
| 大小 | 较小（~26 MiB） | 较大（~63 MiB） |
| 推荐场景 | 快速开发、多版本兼容 | 正式发布、最佳性能 |

---

## 14. 常见踩坑与解决方案

### 14.1 Steam 初始化失败

**问题**：`steamInit()` 返回非 1 状态。

**排查清单**：
- Steam 客户端是否运行？
- `steam_appid.txt` 是否存在且 App ID 正确？
- 是否在 Steam 中预购/拥有该游戏？
- 防火墙是否阻止了 Steam 连接？

### 14.2 回调不触发

**问题**：连接了 Steam 信号但回调函数不执行。

**解决方案**：
- 确认 `_process()` 中调用了 `Steam.run_callbacks()`
- 或在 Project Settings 中启用 `run_callbacks` 自动调用（4.14+）
- 确认信号名称拼写正确

### 14.3 P2P 连接失败

**问题**：`p2p_session_connect_fail` 信号触发。

**常见原因**：
- 两台机器运行的不是同一个 App ID
- 用户未拥有该游戏
- 目标用户未连接到 Steam
- 防火墙/NAT 阻止了 P2P 连接

**解决方案**：
```gdscript
Steam.allowP2PPacketRelay(true)  # 启用 Steam 中继
```

### 14.4 成就不显示

**问题**：调用 `setAchievement()` 后成就未解锁。

**解决方案**：
- 确认成就名称与 Steamworks 后台完全一致
- 确认调用了 `storeStats()` 提交到服务器
- 在 Steam 客户端中确认成就已配置（需要先发布一次）

### 14.5 语音有杂音/卡顿

**问题**：语音播放不流畅。

**解决方案**：
- 使用 `Steam.getVoiceOptimalSampleRate()` 获取最佳采样率
- 考虑使用 GodotSteam 4.17+ 的 `getDecompressedVoice()` 简化处理
- 检查音频播放节点是否正确配置

### 14.6 GodotSteam GitHub 仓库已归档

**问题**：GitHub 上的 GodotSteam 仓库已归档为只读。

**解决方案**：
- 项目已迁移至 Codeberg：https://codeberg.org/godotsteam/GodotSteam
- 所有新版本发布和更新都在 Codeberg 上进行
- GDExtension 通用版（4.4+）是最推荐的安装方式

### 14.7 导出时 Steam DLL 缺失

**问题**：导出游戏后 Steam 功能不可用。

**解决方案**：
- 确保导出模板中包含 `steam_api64.dll`（Windows 64 位）
- 使用版本专用版时，下载对应的 templates 包
- 在导出预设中确认 Steam App ID 已填写

### 14.8 Steam Deck 兼容性

```gdscript
func _ready() -> void:
	if Steam.isSteamRunningOnSteamDeck():
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		# 调整 UI 缩放
		get_viewport().content_scale_factor = 1.2
		# 简化图形设置
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
```
