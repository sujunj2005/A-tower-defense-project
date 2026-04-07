# AssetsManager 使用指南

## 快速开始

### 1. 加载单个资源

```gdscript
# 加载图片
var texture = AssetsManager.instance.load_image(AssetPaths.Images.ARROW_PROJECTILE)

# 加载场景
var scene = AssetsManager.instance.load_scene(AssetPaths.Scenes.MAP)

# 加载配置
var config = AssetsManager.instance.load_config(AssetPaths.Resources.ARCHER_TOWER)
```

### 2. 异步加载

```gdscript
# 异步加载单个资源
AssetsManager.instance.load_resource_async(AssetPaths.Images.MAGIC_PROJECTILE)

# 批量异步加载
var paths = [
	AssetPaths.Images.ARROW_PROJECTILE,
	AssetPaths.Images.MAGIC_PROJECTILE
]
AssetsManager.instance.load_batch_async(paths)
```

### 3. 预加载

```gdscript
# 预加载常用资源
var common_assets = [
	AssetPaths.Images.ENEMY_MARBLE_0_0,
	AssetPaths.Images.ENEMY_MARBLE_0_1,
	AssetPaths.Resources.ARCHER_TOWER
]
AssetsManager.instance.preload_async(common_assets)
```

### 4. 热替换素材

```gdscript
# 注册素材包
var fantasy_pack = {
	AssetPaths.Images.ENEMY_MARBLE_0_0: "res://assets/fantasy/enemy_1.png",
	AssetPaths.Images.ENEMY_MARBLE_0_1: "res://assets/fantasy/enemy_2.png"
}
AssetsManager.instance.register_asset_pack("fantasy", fantasy_pack)

# 激活素材包
AssetsManager.instance.set_active_asset_pack("fantasy")

# 重置为默认
AssetsManager.instance.reset_to_default()
```

### 5. 缓存管理

```gdscript
# 获取缓存统计
var stats = AssetsManager.instance.get_cache_stats()
print("缓存数量：%d / %d" % [stats.count, stats.max_size])

# 清空缓存
AssetsManager.instance.clear_cache()

# 禁用缓存 (用于调试)
AssetsManager.instance.disable_cache()
```

## 最佳实践

1. **预加载常用资源**: 在游戏启动时预加载常用资源
2. **使用异步加载**: 大资源使用异步加载避免卡顿
3. **合理使用缓存**: 常用资源缓存，一次性资源不缓存
4. **热替换前清空缓存**: 切换素材包前自动清空缓存

## 架构说明

### 三层架构

```
AssetsManager (单例)
├── AssetPaths (路径常量)
│   ├── Images - 图片路径
│   ├── Scenes - 场景路径
│   ├── Resources - 配置文件路径
│   └── Audio - 音频路径 (预留)
├── ResourceCache (缓存层)
│   ├── LRU 淘汰机制
│   ├── 最大缓存数限制
│   └── 缓存统计
└── AsyncLoader (异步加载层)
    ├── 线程加载
    ├── 批量加载
    └── 进度信号
```

### 核心功能

- ✅ **集中管理**: 所有资源路径统一管理
- ✅ **缓存优化**: LRU 缓存机制，自动淘汰最少使用资源
- ✅ **异步加载**: 支持线程加载，避免游戏卡顿
- ✅ **热替换**: 运行时动态切换素材包
- ✅ **类型安全**: 所有资源使用静态类型声明

## 实际重构示例

### Tower.gd 重构前后对比

**重构前（使用 load）：**
```gdscript
var texture: Texture2D = load(config.texture_path) as Texture2D
```

**重构后（使用 AssetsManager）：**
```gdscript
var texture: Texture2D = AssetsManager.load_image(config.texture_path) as Texture2D
```

### Enemy.gd 重构前后对比

**重构前（使用 load + ResourceLoader.exists）：**
```gdscript
if not ResourceLoader.exists(config.texture_path):
    push_error("[Enemy] 纹理文件不存在：%s" % config.texture_path)
else:
    var texture = load(config.texture_path) as Texture2D
```

**重构后（使用 AssetsManager）：**
```gdscript
var texture = AssetsManager.load_image(config.texture_path) as Texture2D
if not texture:
    push_error("[Enemy] 加载纹理失败：%s" % config.texture_path)
```

### MapManager.gd 重构前后对比

**重构前（使用 preload）：**
```gdscript
shader_mat.shader = preload("res://shaders/grid_overlay.gdshader")
```

**重构后（使用 AssetsManager）：**
```gdscript
shader_mat.shader = AssetsManager.load_resource("res://shaders/grid_overlay.gdshader") as Shader
```

## 示例场景

### 游戏启动时预加载

```gdscript
extends Node

func _ready() -> void:
	# 预加载所有常用资源
	var common_assets = [
		AssetPaths.Images.ENEMY_MARBLE_0_0,
		AssetPaths.Images.ENEMY_MARBLE_0_1,
		AssetPaths.Images.ENEMY_MARBLE_0_2,
		AssetPaths.Resources.ARCHER_TOWER,
		AssetPaths.Resources.BASIC_TOWER,
		AssetPaths.Resources.MAGIC_TOWER
	]
	
	AssetsManager.instance.preload_async(common_assets)
```

### 防御塔加载纹理

```gdscript
extends Node2D

var tower_texture: Texture2D

func _ready() -> void:
	if config and config.tower_type:
		var texture_path = _get_texture_path_for_tower(config.tower_type)
		tower_texture = AssetsManager.instance.load_image(texture_path)
		
		if $Sprite2D and tower_texture:
			$Sprite2D.texture = tower_texture

func _get_texture_path_for_tower(tower_type: String) -> String:
	match tower_type:
		"archer":
			return AssetPaths.Images.ENEMY_MARBLE_0_0
		"magic":
			return AssetPaths.Images.ENEMY_MARBLE_0_1
		_:
			return AssetPaths.Images.ENEMY_MARBLE_0_0
```

### 切换素材包

```gdscript
# 创建 DLC 素材包
var dlcpack: Dictionary = {
	AssetPaths.Images.ENEMY_MARBLE_0_0: "res://dlc/fantasy/enemy_1.png",
	AssetPaths.Images.ENEMY_MARBLE_0_1: "res://dlc/fantasy/enemy_2.png",
	AssetPaths.Images.ARROW_PROJECTILE: "res://dlc/fantasy/arrow.png"
}

# 注册并激活
AssetsManager.instance.register_asset_pack("fantasy_dlc", dlcpack)
AssetsManager.instance.set_active_asset_pack("fantasy_dlc")
```
