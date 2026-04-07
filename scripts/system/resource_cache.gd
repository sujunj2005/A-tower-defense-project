class_name ResourceCache
extends RefCounted

## 缓存的数据结构
var _cache: Dictionary[String, Resource] = {}
var _cache_order: Array[String] = []  # 用于 LRU 淘汰
var _max_cache_size: int = 100  # 最大缓存数量

## 启用缓存的标志
var _cache_enabled: bool = true

func _init(max_size: int = 100) -> void:
	_max_cache_size = max_size

## 启用缓存
func enable_cache() -> void:
	_cache_enabled = true

## 禁用缓存
func disable_cache() -> void:
	_cache_enabled = false

## 获取缓存的资源
func get(path: String) -> Resource:
	if not _cache_enabled:
		return null
	
	if _cache.has(path):
		# LRU：移动到最近使用
		_cache_order.erase(path)
		_cache_order.push_back(path)
		return _cache[path]
	
	return null

## 缓存资源
func cache(path: String, resource: Resource) -> void:
	if not _cache_enabled:
		return
	
	# 如果已存在，先移除
	if _cache.has(path):
		_cache_order.erase(path)
	
	# 检查是否需要淘汰
	while _cache.size() >= _max_cache_size:
		var oldest_path = _cache_order.pop_front()
		if oldest_path:
			_cache.erase(oldest_path)
	
	# 添加新缓存
	_cache[path] = resource
	_cache_order.push_back(path)

## 预缓存多个资源
func cache_multiple(paths: Dictionary[String, String], resources: Array[Resource]) -> void:
	for i in range(paths.size()):
		if i < resources.size():
			cache(paths.keys()[i], resources[i])

## 移除缓存
func remove(path: String) -> void:
	if _cache.has(path):
		_cache.erase(path)
		_cache_order.erase(path)

## 清空缓存
func clear() -> void:
	_cache.clear()
	_cache_order.clear()

## 获取缓存统计
func get_stats() -> Dictionary:
	return {
		"count": _cache.size(),
		"max_size": _max_cache_size,
		"enabled": _cache_enabled
	}

## 检查是否已缓存
func has_cached(path: String) -> bool:
	return _cache.has(path)
