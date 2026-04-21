# Steam 平台集成实战指南

> **来源**: [12_Steam_Platform_Integration.md](../base/steam-integration/12_Steam_Platform_Integration.md)  
> **适用版本**: Godot 4.x / GodotSteam 4.18 / Steamworks SDK 1.64  
> **最后更新**: 2026-04-07

---

## 📋 概述

本指南介绍如何使用 GodotSteam 插件在 Godot 4.x 项目中集成 Steam 平台功能，包括成就系统、排行榜、大厅系统、P2P 通信、语音聊天等核心功能。

---

## 🏗️ 环境搭建

### 安装 GodotSteam

**推荐方式：GDExtension 通用版（适用于 Godot 4.4+）**

1. 从 Codeberg Releases 下载 `godotsteam-4.18-gdextension-plugin-4.4.zip`
2. 解压到项目根目录（`addons/godotsteam/`）
3. 插件自动加载，无需额外配置

**项目配置**：

```gdscript
# project.godot
[application]
config/name="My Steam Game"
config/features=PackedStringArray("4.6")

[autoload]
SteamManager="*res://src/global.gd"
```

### Steamworks 后端配置

1. 在 [Steamworks Partner](https://partner.steamgames.com/) 注册应用
2. 配置成就、统计、排行榜等
3. 下载 `steam_appid.txt` 文件放入项目根目录
4. 导出时在导出预设中配置 Steam App ID

> ⚠️ **踩坑点**：开发时需要 Steam 客户端运行。如果没有 Steam 客户端，`Steam.steamInit()` 会失败。确保 `steam_appid.txt` 中的 App ID 与 Steamworks 后台一致。

---

## 🚀 Steam 初始化

### 全局管理脚本（Autoload）

```gdscript
extends Node

var IS_ON_STEAM: bool = false
var IS_ONLINE: bool = false
var STEAM_ID: int = 0
var STEAM_USERNAME: String = "No one"


func _ready() -> void:
	_initialize_Steam()


func _initialize_Steam() -> void:
	if Engine.has_singleton("Steam"):
		var INIT: Dictionary = Steam.steamInit(false)
		if INIT['status'] != 1:
			print("[STEAM] Failed to initialize: " + str(INIT['verbal']))
			get_tree().quit()

		IS_ON_STEAM = true
		IS_ONLINE = Steam.loggedOn()
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()


func _process(_delta: float) -> void:
	if IS_ON_STEAM:
		Steam.run_callbacks()
```

> ⚠️ **关键**：`Steam.run_callbacks()` 必须在 `_process()` 中每帧调用，否则所有 Steam 回调（信号）都不会触发。这是最常见的遗漏。

### GodotSteam 4.14+ 自动初始化

从 4.14 开始，支持通过 Project Settings 自动初始化：

```gdscript
# 在 Project Settings > Steam 中配置：
# - steam_app_id: 你的应用 ID
# - auto_init: true
# - run_callbacks: true（自动在 _process 中调用）
```

---

## 🏆 成就与统计系统

### 定义数据结构

```gdscript
var ACHIEVEMENTS: Dictionary = {
	"ACH_WIN_ONE_GAME": false,
	"ACH_WIN_100_GAMES": false,
}

var STATISTICS: Dictionary = {
	"NumGames": 0,
	"NumWins": 0,
}
```

> ⚠️ **注意**：成就名称必须与 Steamworks 后台配置的 API 名称完全一致（区分大小写）。

### 请求用户数据

```gdscript
func _ready() -> void:
	Steam.user_stats_received.connect(_on_Stats_Ready)
	if not Steam.requestCurrentStats():
		print("[STEAM] Failed to request current stats!")


func _on_Stats_Ready(_game: int, result: bool, _user: int) -> void:
	if not result:
		return
	
	for ACHIEVEMENT in ACHIEVEMENTS.keys():
		var ACHIEVE: Dictionary = Steam.getAchievement(ACHIEVEMENT)
		if ACHIEVE['ret']:
			ACHIEVEMENTS[ACHIEVEMENT] = ACHIEVE['achieved']
```

> ⚠️ **注意**：`current_stats_received` 信号在 4.12 中已被移除，只使用 `user_stats_received`。

### 解锁成就

```gdscript
func unlock_achievement(achievement_name: String) -> void:
	if ACHIEVEMENTS.get(achievement_name, true):
		return

	var SET_ACHIEVE: bool = Steam.setAchievement(achievement_name)
	if SET_ACHIEVE:
		ACHIEVEMENTS[achievement_name] = true
		Steam.storeStats()  # 必须调用！
```

> ⚠️ **踩坑点**：`setAchievement()` 只在本地设置，必须调用 `storeStats()` 才会同步到 Steam 服务器。从 4.15 开始，`storeStats()` 不再自动调用。

---

## 📊 排行榜系统

### 查找排行榜

```gdscript
var LEADERBOARD_HANDLE: int = 0

func _ready() -> void:
	Steam.leaderboard_find_result.connect(_on_Leaderboard_Find_Result)
	Steam.leaderboard_scores_downloaded.connect(_on_Scores_Downloaded)


func find_leaderboard(name: String) -> void:
	Steam.findLeaderboard(name)


func _on_Leaderboard_Find_Result(handle: int, found: int) -> void:
	if found == 1:
		LEADERBOARD_HANDLE = handle
```

### 上传分数

```gdscript
func upload_score(score: int) -> void:
	if LEADERBOARD_HANDLE == 0:
		return
	Steam.uploadLeaderboardScore(
		Steam.LEADERBOARD_UPLOAD_SCORE_METHOD_KEEP_BEST,
		LEADERBOARD_HANDLE,
		score,
		[]
	)
```

### 下载排行榜数据

```gdscript
func download_leaderboard_entries(start: int, end: int) -> void:
	Steam.downloadLeaderboardEntries(
		start, end,
		Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
		LEADERBOARD_HANDLE
	)


func _on_Scores_Downloaded(message: String, this_handle: int, result: Array) -> void:
	for ENTRY in result:
		print("Rank: " + str(ENTRY['rank']) + " | Name: " + str(ENTRY['persona_name']) + " | Score: " + str(ENTRY['score']))
```

> ⚠️ **踩坑点**：从 4.16 开始，`getLeaderboardSortMethod()` 直接返回枚举整数值，不再返回字典。

---

## 🏠 大厅系统与多人联机

### 创建大厅

```gdscript
var LOBBY_ID: int = 0

func create_lobby(is_public: bool = true) -> void:
	if LOBBY_ID == 0:
		var lobby_type = Steam.LOBBY_TYPE_PUBLIC if is_public else Steam.LOBBY_TYPE_INVITE_ONLY
		Steam.createLobby(lobby_type, 10)


func _on_Lobby_Created(connect_result: int, lobby_id: int) -> void:
	if connect_result == 1:
		LOBBY_ID = lobby_id
		Steam.setLobbyJoinable(LOBBY_ID, true)
		Steam.setLobbyData(LOBBY_ID, "name", "My Lobby")
```

### 加入大厅

```gdscript
func join_lobby(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)


func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		_get_Lobby_Members()
	else:
		print("[STEAM] Failed to join lobby")


func _get_Lobby_Members() -> void:
	var MEMBERS: int = Steam.getNumLobbyMembers(LOBBY_ID)
	for INDEX in range(MEMBERS):
		var MEMBER_ID: int = Steam.getLobbyMemberByIndex(LOBBY_ID, INDEX)
		var MEMBER_NAME: String = Steam.getFriendPersonaName(MEMBER_ID)
```

### 大厅聊天

```gdscript
func send_lobby_message(message: String) -> void:
	Steam.sendLobbyChatMsg(LOBBY_ID, message)


func _on_Lobby_Message(_result: int, user: int, message: String, type: int) -> void:
	if type == 1:
		var SENDER: String = Steam.getFriendPersonaName(user)
		print(SENDER + ": " + message)
```

---

## 🌐 P2P 网络通信

### P2P 握手

```gdscript
func _make_P2P_Handshake() -> void:
	_send_P2P_Packet(0, {"message": "handshake", "from": Global.STEAM_ID})


func _on_P2P_Session_Request(remote_id: int) -> void:
	Steam.acceptP2PSessionWithUser(remote_id)
	_make_P2P_Handshake()
```

### 发送 P2P 数据包

```gdscript
func _send_P2P_Packet(target: int, packet_data: Dictionary) -> void:
	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	var CHANNEL: int = 0
	var PACKET_DATA: PackedByteArray = var_to_bytes(packet_data)

	if target == 0:
		# 发送给所有大厅成员
		for MEMBER in LOBBY_MEMBERS:
			if MEMBER['steam_id'] != Global.STEAM_ID:
				Steam.sendP2PPacket(MEMBER['steam_id'], PACKET_DATA, SEND_TYPE, CHANNEL)
	else:
		Steam.sendP2PPacket(target, PACKET_DATA, SEND_TYPE, CHANNEL)
```

### 接收 P2P 数据包

```gdscript
func _process(_delta: float) -> void:
	if LOBBY_ID > 0:
		_read_P2P_Packet()


func _read_P2P_Packet() -> void:
	var PACKET_SIZE: int = Steam.getAvailableP2PPacketSize(0)
	if PACKET_SIZE > 0:
		var PACKET: Dictionary = Steam.readP2PPacket(PACKET_SIZE, 0)
		var READABLE: Dictionary = bytes_to_var(PACKET['data'])
		
		match READABLE.get('message', ''):
			"handshake":
				print("[STEAM] Handshake received")
			"start":
				_start_Game()
```

> ⚠️ **踩坑点**：P2P 数据包使用 `var_to_bytes()` 和 `bytes_to_var()` 序列化。确保所有发送的数据都是可序列化的类型（Dictionary、Array、基本类型）。不要发送 Object 引用或 Resource。

### 发送类型选择

```gdscript
# 可靠传输（TCP 模式）- 适用于重要数据
var RELIABLE: int = Steam.P2P_SEND_RELIABLE

# 不可靠传输（UDP 模式）- 适用于频繁更新的位置数据
var UNRELIABLE: int = Steam.P2P_SEND_UNRELIABLE

# 启用 Steam 中继备份
Steam.allowP2PPacketRelay(true)
```

---

## 🎤 语音聊天系统

### 语音控制

```gdscript
var IS_VOICE_TOGGLED: bool = false

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

### GodotSteam 4.17+ 简化语音处理

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

> ⚠️ **踩坑点**：从 4.16 开始，`getAvailableVoice()` 已被移除。旧代码中先检查 `getAvailableVoice()` 再调用 `getVoice()` 的模式需要更新为直接调用 `getVoice()` 或 `getDecompressedVoice()`。

---

## 🎮 身份验证系统

### 获取认证票据

```gdscript
var TICKET: Dictionary

func _ready() -> void:
	Steam.get_auth_session_ticket_response.connect(_on_Auth_Ticket_Response)


func request_auth_ticket() -> void:
	TICKET = Steam.getAuthSessionTicket()
```

### 验证认证票据

```gdscript
func begin_auth_session() -> void:
	var RESPONSE: int = Steam.beginAuthSession(
		TICKET['buffer'],
		TICKET['size'],
		Global.STEAM_ID
	)
	match RESPONSE:
		0:
			print("[STEAM] Ticket is valid")
		1:
			print("[STEAM] Ticket is invalid")
		5:
			print("[STEAM] Ticket has expired")
```

---

## 🖼️ 头像与用户信息

### 获取用户头像

```gdscript
func _ready() -> void:
	Steam.avatar_loaded.connect(_on_Avatar_Loaded)


func load_avatar(steam_id: int, size: int = Steam.AVATAR_MEDIUM) -> void:
	Steam.getPlayerAvatar(size, steam_id)


func _on_Avatar_Loaded(id: int, avatar_size: int, buffer: PackedByteArray) -> void:
	if buffer.is_empty():
		return

	var AVATAR: Image = Image.create_from_data(
		avatar_size, avatar_size,
		false,
		Image.FORMAT_RGBA8,
		buffer
	)
	var TEXTURE: ImageTexture = ImageTexture.create_from_image(AVATAR)
	$AvatarTexture.set_texture(TEXTURE)
```

### 头像尺寸常量

```gdscript
Steam.AVATAR_SMALL    # 32x32
Steam.AVATAR_MEDIUM   # 64x64
Steam.AVATAR_LARGE    # 128x128
```

---

## 🎮 输入与手柄支持

### 初始化 Steam Input

```gdscript
var STEAM_CONTROLLERS: Array = []

func init_steam_input() -> void:
	if Steam.inputInit():
		print("[STEAM] Input initialized")
		Steam.runFrame()


func get_controllers() -> void:
	STEAM_CONTROLLERS = Steam.getConnectedControllers()
```

### 触觉反馈

```gdscript
func trigger_haptic(controller_handle: int) -> void:
	Steam.triggerHapticPulse(controller_handle, 0, 500000)


func trigger_vibration(controller_handle: int, left_speed: int = 5000, right_speed: int = 5000) -> void:
	Steam.triggerVibration(controller_handle, left_speed, right_speed)
```

> ⚠️ **踩坑点**：从 4.5.4 开始，`getInputTypeForHandle()` 返回枚举整数而非字符串。旧代码中 `if TYPE == "Xbox360Controller"` 的写法需要改为 `if TYPE == Steam.INPUT_TYPE_XBOX360`。

---

## 🔗 Steam Overlay

### 打开 Overlay 页面

```gdscript
func open_overlay(page: String = "steamid") -> void:
	Steam.activateGameOverlay(page)


func open_overlay_to_user(steam_id: int) -> void:
	Steam.activateGameOverlayToUser("steamid", steam_id)


func open_overlay_web(url: String) -> void:
	Steam.activateGameOverlayToWebPage(url)
```

### 常用 Overlay 页面

```gdscript
Steam.activateGameOverlay("friends")           # 好友列表
Steam.activateGameOverlay("community")         # 社区
Steam.activateGameOverlay("achievements")      # 成就
Steam.activateGameOverlay("stats")             # 统计
Steam.activateGameOverlay("lobby")             # 大厅
```

---

## ⚠️ 常见踩坑与解决方案

### Steam 初始化失败

**排查清单**：
- Steam 客户端是否运行？
- `steam_appid.txt` 是否存在且 App ID 正确？
- 是否在 Steam 中预购/拥有该游戏？
- 防火墙是否阻止了 Steam 连接？

### 回调不触发

**解决方案**：
- 确认 `_process()` 中调用了 `Steam.run_callbacks()`
- 或在 Project Settings 中启用 `run_callbacks` 自动调用（4.14+）
- 确认信号名称拼写正确

### P2P 连接失败

**常见原因**：
- 两台机器运行的不是同一个 App ID
- 用户未拥有该游戏
- 防火墙/NAT 阻止了 P2P 连接

**解决方案**：
```gdscript
Steam.allowP2PPacketRelay(true)  # 启用 Steam 中继
```

### 成就不显示

**解决方案**：
- 确认成就名称与 Steamworks 后台完全一致
- 确认调用了 `storeStats()` 提交到服务器
- 在 Steam 客户端中确认成就已配置

---

## 📚 版本迁移指南

### 必须更新的代码（4.16+）

**1. 移除 `getAvailableVoice()` 调用**

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

**2. 更新排行榜返回值**

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
# 只保留 user_stats_received
Steam.user_stats_received.connect(_on_Stats_Ready)
```

---

## 🔗 相关链接

- **Base 层文档**: [12_Steam_Platform_Integration.md](../base/steam-integration/12_Steam_Platform_Integration.md)
- **GodotSteam Codeberg**: https://codeberg.org/godotsteam/GodotSteam
- **Steamworks 文档**: https://partner.steamgames.com/doc

---

**维护者**: Knowledge Base Administrator  
**知识库版本**: 1.11
