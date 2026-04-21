# Godot 4.x 游戏开发概述

> **适用版本**: Godot 4.x  
> **知识领域**: 游戏开发全栈  
> **前置知识**: 编程基础、GDScript 基础

---

## 🎯 Godot 游戏开发知识体系

### 1. 引擎架构

#### 1.1 场景树（Scene Tree）
```
SceneTree (根)
└── Window (窗口)
    └── Viewport (视口)
        └── Node2D/Node3D (游戏内容根节点)
            ├── Player (玩家)
            ├── Enemies (敌人)
            ├── Level (关卡)
            └── UI (用户界面)
```

**核心概念**:
- **节点（Node）**: 游戏对象的基本单元
- **场景（Scene）**: 节点的集合，可复用
- **场景树（SceneTree）**: 所有场景的层级结构

**参考**:
- [场景树](../concepts/scene-tree.md)

---

### 2. 脚本系统

#### 2.1 GDScript 2.0 特性
- **静态类型**: `var health: int = 100`
- **类型推断**: `var health = 100  # 自动推断为 int`
- **导出属性**: `@export var speed: float = 5.0`
- **信号**: `signal health_changed(new_value)`
- **协程**: `await get_tree().create_timer(1.0).timeout`

**参考**:
- [GDScript 基础语法](../concepts/gdscript-basics.md)
- [GDScript 类型系统](../concepts/gdscript-types.md)
- [GDScript 代码规范](../concepts/gdscript-standards.md)

---

### 3. 核心系统

#### 3.1 节点生命周期
```gdscript
func _enter_tree():
    # 节点进入场景树时调用
    pass

func _ready():
    # 节点准备就绪时调用（只执行一次）
    pass

func _process(delta):
    # 每帧调用（与帧率相关）
    pass

func _physics_process(delta):
    # 每物理帧调用（固定频率，默认 60Hz）
    pass

func _exit_tree():
    # 节点离开场景树时调用
    pass
```

#### 3.2 场景管理
```gdscript
# 实例化场景
var enemy = enemy_scene.instantiate()
add_child(enemy)

# 切换场景
get_tree().change_scene_to_file("res://scenes/level_2.tscn")

# 重新加载当前场景
get_tree().reload_current_scene()
```

**参考**:
- [节点操作指南](../guides/node-operations-guide.md)

---

### 4. 游戏开发领域

#### 4.1 2D 游戏开发
| 主题 | 核心内容 | Wiki 页面 |
|------|---------|----------|
| **坐标系** | 2D 变换、Canvas 坐标 | [2D 变换概念](../concepts/2d-transforms.md) |
| **移动控制** | 8 方向、旋转 + 移动、点击移动 | [2D 移动指南](../guides/2d-movement-guide.md) |
| **动画** | AnimatedSprite2D、AnimationPlayer | [Sprite 动画指南](../guides/sprite-animation-guide.md) |
| **物理** | CharacterBody2D、RigidBody2D | [物理系统介绍](../concepts/physics-intro.md) |
| **TileMap** | 瓦片地图、地形系统 | [TileMap 概念](../concepts/tilemaps-concept.md) |
| **光照** | PointLight2D、DirectionalLight2D | [2D 灯光和阴影概念](../concepts/2d-lights-shadows.md) |
| **粒子** | GPUParticles2D | [2D 粒子系统指南](../guides/particles-2d-guide.md) |
| **视差** | Parallax2D、多层背景 | [视差滚动指南](../guides/parallax-guide.md) |

**完整概述**: [2D 游戏开发概述](./2d-game-development-overview.md)

#### 4.2 3D 游戏开发
| 主题 | 核心内容 | Wiki 页面 |
|------|---------|----------|
| **坐标系** | 3D 变换、Transform3D | [3D 变换概念](../concepts/3d-transforms-concept.md) |
| **移动控制** | CharacterBody3D、物理移动 | [CharacterBody2D 概念](../concepts/characterbody2d-concept.md)（原理相同） |
| **材质** | StandardMaterial3D、PBR | [标准材质 3D](../guides/standard-material-guide.md) |
| **光照** | DirectionalLight3D、OmniLight3D | [3D 光照指南](../guides/3d-lights-guide.md) |
| **粒子** | GPUParticles3D | [3D 粒子指南](../guides/particles-3d-guide.md) |
| **摄像机** | 第一人称、第三人称 | [3D 开发介绍](../concepts/3d-intro.md) |
| **着色器** | Spatial Shader | [Spatial 着色器指南](../guides/spatial-shader-guide.md) |

**完整概述**: [3D 游戏开发概述](./3d-game-development-overview.md)

#### 4.3 UI 系统
| 主题 | 核心内容 | Wiki 页面 |
|------|---------|----------|
| **容器** | 10 种布局容器 | [UI 容器概念](../concepts/ui-containers.md) |
| **尺寸** | 锚点、偏移、响应式 | [UI 尺寸和锚点概念](../concepts/ui-size-anchors.md) |
| **输入** | _gui_input、焦点控制 | [UI 输入处理指南](../guides/ui-input-handling.md) |

#### 4.4 音频系统
| 主题 | 核心内容 | Wiki 页面 |
|------|---------|----------|
| **音频总线** | 混音器、音量控制 | [音频总线概念](../concepts/audio-buses-concept.md) |
| **音频流** | 播放音乐/音效 | [音频流指南](../guides/audio-streams-guide.md) |
| **音频效果** | 均衡器、混响、压缩 | [音频效果指南](../guides/audio-effects-guide.md) |

#### 4.5 动画系统
| 主题 | 核心内容 | Wiki 页面 |
|------|---------|----------|
| **AnimationPlayer** | 关键帧、轨道系统 | [AnimationPlayer](../concepts/animation-player.md) |
| **AnimationTree** | 状态机、混合树 | [AnimationTree](../concepts/animation-tree.md) |
| **2D 骨骼** | Skeleton2D、骨骼绑定 | [2D 骨骼](../../base/animation-system/11C_2D_Skeletons.md) |

#### 4.6 多人游戏网络
| 主题 | 核心内容 | Wiki 页面 |
|------|---------|----------|
| **HighLevel API** | MultiplayerSynchronizer 自动同步 | [多人游戏网络指南](../guides/multiplayer-networking-guide.md) |
| **LowLevel API** | 自定义协议、ENet 传输 | [多人游戏网络指南](../guides/multiplayer-networking-guide.md) |
| **RPC** | 远程过程调用 | [多人游戏网络指南](../guides/multiplayer-networking-guide.md) |

---

### 5. 游戏架构模式

#### 5.1 常见设计模式
| 模式 | 用途 | 示例 |
|------|------|------|
| **单例模式** | 全局管理器 | Autoload 单例（GameManager、AudioManager） |
| **状态模式** | 角色状态机 | AnimationTree 状态机、AI 状态 |
| **观察者模式** | 事件系统 | Signal 信号系统 |
| **组件模式** | 组合式架构 | 节点系统本身就是组件模式 |
| **对象池** | 性能优化 | 子弹/粒子复用 |

**参考**:
- [常用模式指南](../guides/common-patterns-guide.md)
- [单例模式](../concepts/autoload-singletons.md)
- [信号系统](../concepts/signals-events.md)

#### 5.2 塔防游戏架构案例
```
GameManager (Autoload)
├── 游戏状态管理
├── 波次管理
└── 经济系统

Level
├── SpawnPoint (生成点)
├── Path2D/Path3D (敌人行进路径)
├── TowerSpawn (塔生成点)
└── EnemySpawner (敌人生成器)

Tower (场景)
├── 攻击逻辑
├── 目标检测
└── 投射物生成

Enemy (场景)
├── 移动逻辑
├── 生命值
└── 死亡处理
```

**参考**:
- [塔防游戏架构设计](../guides/tower-defense-architecture.md)
- [攻击系统设计](../concepts/attack-system.md)

---

### 6. 输入系统

#### 6.1 InputMap 配置
```gdscript
# 检查输入动作
if Input.is_action_pressed("move_right"):
    velocity.x += 1

if Input.is_action_just_pressed("jump"):
    velocity.y = jump_velocity

# 获取输入强度
var strength = Input.get_action_strength("move_right")  # 0.0-1.0

# 获取输入向量
var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
```

**参考**:
- [输入事件概念](../concepts/input-events.md)
- [输入映射指南](../guides/input-map-guide.md)

---

### 7. 数据管理

#### 7.1 资源系统
```gdscript
# 预加载（编译时加载）
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

# 动态加载（运行时加载）
var texture = load("res://assets/player.png")

# 异步加载
var resource_loader = ResourceLoader.load("res://scenes/level.tscn", "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
```

**参考**:
- [资源系统](../concepts/resources-system.md)

#### 7.2 存档系统
```gdscript
# 保存游戏
var save_data = {
    "player_health": 100,
    "player_position": player.global_position,
    "enemies_defeated": 15
}
var file = FileAccess.open("user://savegame.sav", FileAccess.WRITE)
file.store_var(save_data)
file.close()

# 加载游戏
var file = FileAccess.open("user://savegame.sav", FileAccess.READ)
var save_data = file.get_var()
file.close()
```

**参考**:
- [数据结构偏好指南](../guides/data-preferences-guide.md)
- [保存游戏](../../base/assets-and-io/15C_Saving_Games.md)

---

### 8. 调试与测试

#### 8.1 调试工具
- **调试器**: 断点、单步执行、监视变量
- **打印调试**: `print()`, `print_rich()`, `push_error()`
- **性能分析**: Profiler、Monitor 面板

**参考**:
- [调试工具实战指南](../guides/debugging-tools-guide.md)
- [性能分析器实战指南](../guides/profiler-guide.md)

#### 8.2 常见踩坑
- **负向缩放翻转**: 使用 `Sprite2D.flip_h` 代替 `scale.x = -1`
- **资源文件注释**: `.tres` 文件不支持注释
- **TileMap Shader 边框**: 调整 UV 坐标避免采样相邻瓦片

**参考**:
- [常见踩坑避雷](../guides/common-pitfalls.md)

---

### 9. 性能优化

#### 9.1 CPU 优化
| 方向 | 措施 |
|------|------|
| **脚本** | 减少 `_process` 调用、使用 `_physics_process` |
| **信号** | 及时断开连接、避免频繁连接/断开 |
| **物理** | 合理配置碰撞层、使用简单碰撞体 |
| **AI** | 距离检测、状态机代替复杂行为树 |

#### 9.2 GPU 优化
| 方向 | 措施 |
|------|------|
| **合批** | 减少材质切换、使用纹理集 |
| **LOD** | 远距离使用低模 |
| **剔除** | 视口外节点自动剔除 |
| **粒子** | 优先使用 GPUParticles |

**参考**:
- [性能优化实战指南](../guides/performance-optimization-guide.md)

---

### 10. 导出与发布

#### 10.1 多平台导出
| 平台 | 导出预设 | 注意事项 |
|------|---------|---------|
| **Windows** | Windows Desktop | .exe 可执行文件 |
| **Linux** | Linux/X11 | .x86_64 可执行文件 |
| **macOS** | macOS | .app 应用包 |
| **Android** | Android | .apk 需要签名 |
| **iOS** | iOS | .ipa 需要开发者账号 |
| **Web** | Web | HTML5 + WASM |

**参考**:
- [项目导出实战指南](../guides/exporting-projects-guide.md)
- [功能标签实战指南](../guides/feature-tags-guide.md)
- [Steam 平台集成实战指南](../guides/steam-platform-integration-guide.md) - Steam 平台发布

---

## 📚 推荐学习路径

### 零基础入门
```
1. [GDScript 基础语法](../concepts/gdscript-basics.md)
   ↓
2. [场景树](../concepts/scene-tree.md)
   ↓
3. [节点操作指南](../guides/node-operations-guide.md)
   ↓
4. [常见踩坑避雷](../guides/common-pitfalls.md)
```

### 2D 开发者路径
```
1. [2D 游戏开发概述](./2d-game-development-overview.md)
   ↓
2. [2D 移动指南](../guides/2d-movement-guide.md)
   ↓
3. [Sprite 动画指南](../guides/sprite-animation-guide.md)
   ↓
4. [物理系统介绍](../concepts/physics-intro.md)
   ↓
5. [塔防游戏架构设计](../guides/tower-defense-architecture.md)
```

### 3D 开发者路径
```
1. [3D 游戏开发概述](./3d-game-development-overview.md)
   ↓
2. [标准材质 3D](../guides/standard-material-guide.md)
   ↓
3. [3D 光照指南](../guides/3d-lights-guide.md)
   ↓
4. [Spatial 着色器指南](../guides/spatial-shader-guide.md)
```

### 进阶开发者路径
```
1. [攻击系统设计](../concepts/attack-system.md)
   ↓
2. [常用模式指南](../guides/common-patterns-guide.md)
   ↓
3. [性能优化实战指南](../guides/performance-optimization-guide.md)
   ↓
4. [调试工具实战指南](../guides/debugging-tools-guide.md)
```

---

## 🔗 相关资源

### Base 层核心文档
- [GDScript 语言参考](../../base/gdscript-reference/) - 8 份完整文档
- [核心系统](../../base/core-systems/) - 4 份核心文档
- [实战经验汇编](../../base/practical-experiences/) - 踩坑案例 + 代码规范 + 优化技巧

### Wiki 层核心页面
- [GDScript 代码规范](../concepts/gdscript-standards.md)
- [信号系统](../concepts/signals-events.md)
- [向量数学](../concepts/vector-math.md)
- [矩阵与变换](../concepts/matrices-transforms.md)

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
