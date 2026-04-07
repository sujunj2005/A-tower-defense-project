class_name AssetsManagerClass
extends Node

## 单例实例
static var instance: AssetsManagerClass

## 缓存系统
var _cache: ResourceCache
var _async_loader: AsyncLoader

## 当前素材包路径 (用于热替换)
var _current_asset_pack: String = "default"
var _asset_pack_overrides: Dictionary[String, String] = {}

## 已加载的资源包
var _loaded_packs: Dictionary[String, Dictionary] = {}

func _enter_tree() -> void:
	# 确保单例
	if instance == null:
		instance = self
	elif instance != self:
		push_error("AssetsManager: 检测到多个实例!")
		queue_free()
		return
	
	# 初始化缓存系统 (最多缓存 100 个资源)
	_cache = ResourceCache.new(100)
	
	# 初始化异步加载器
	_async_loader = AsyncLoader.new()
	
	# 连接信号
	_async_loader.load_completed.connect(_on_resource_loaded)
	_async_loader.load_failed.connect(_on_resource_load_failed)
	
	print("[AssetsManager] 初始化完成")

## ====================
## 同步加载接口
## ====================

## 加载资源 (带缓存)
func load_resource(path: String) -> Resource:
	# 检查是否有热替换路径
	var actual_path = _get_actual_path(path)
	
	# 检查缓存
	var cached = _cache.get(actual_path)
	if cached:
		return cached
	
	# 加载资源
	var resource = load(actual_path)
	if resource:
		_cache.cache(actual_path, resource)
	
	return resource

## 加载图片
func load_image(path: String) -> Texture2D:
	return load_resource(path) as Texture2D

## 加载场景
func load_scene(path: String) -> PackedScene:
	return load_resource(path) as PackedScene

## 加载配置
func load_config(path: String) -> Resource:
	return load_resource(path)

## 预加载多个资源
func preload_resources(paths: Array[String]) -> void:
	for path in paths:
		load_resource(path)

## ====================
## 异步加载接口
## ====================

## 异步加载资源
func load_resource_async(path: String) -> void:
	var actual_path = _get_actual_path(path)
	_async_loader.load_async(actual_path, _cache)

## 异步批量加载
func load_batch_async(paths: Array[String]) -> void:
	_async_loader.load_batch(paths, _cache)

## 预加载并缓存 (异步)
func preload_async(paths: Array[String]) -> void:
	_async_loader.preload_and_cache(paths, _cache)

## ====================
## 热替换接口
## ====================

## 注册素材包
func register_asset_pack(pack_name: String, overrides: Dictionary[String, String]) -> void:
	_loaded_packs[pack_name] = overrides
	print("[AssetsManager] 注册素材包：%s" % pack_name)

## 激活素材包
func set_active_asset_pack(pack_name: String) -> void:
	if not _loaded_packs.has(pack_name):
		push_error("[AssetsManager] 素材包不存在：%s" % pack_name)
		return
	
	_current_asset_pack = pack_name
	_asset_pack_overrides = _loaded_packs[pack_name]
	
	# 清空缓存，强制重新加载
	_cache.clear()
	
	print("[AssetsManager] 激活素材包：%s" % pack_name)

## 重置为默认素材
func reset_to_default() -> void:
	_current_asset_pack = "default"
	_asset_pack_overrides.clear()
	_cache.clear()
	print("[AssetsManager] 重置为默认素材")

## 获取当前素材包
func get_current_asset_pack() -> String:
	return _current_asset_pack

## ====================
## 缓存管理
## ====================

## 清空缓存
func clear_cache() -> void:
	_cache.clear()
	print("[AssetsManager] 缓存已清空")

## 启用缓存
func enable_cache() -> void:
	_cache.enable_cache()

## 禁用缓存
func disable_cache() -> void:
	_cache.disable_cache()

## 从缓存中移除
func remove_from_cache(path: String) -> void:
	var actual_path = _get_actual_path(path)
	_cache.remove(actual_path)

## 获取缓存统计
func get_cache_stats() -> Dictionary:
	return _cache.get_stats()

## ====================
## 内部方法
## ====================

## 获取实际路径 (考虑热替换)
func _get_actual_path(original_path: String) -> String:
	if _asset_pack_overrides.has(original_path):
		return _asset_pack_overrides[original_path]
	return original_path

## 信号回调
func _on_resource_loaded(path: String, resource: Resource) -> void:
	print("[AssetsManager] 异步加载完成：%s" % path)

func _on_resource_load_failed(path: String, error: String) -> void:
	push_error("[AssetsManager] 异步加载失败：%s - %s" % [path, error])
