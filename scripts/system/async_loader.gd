class_name AsyncLoader
extends RefCounted

signal load_started(path: String)
signal load_completed(path: String, resource: Resource)
signal load_failed(path: String, error: String)
signal load_progress(current: int, total: int)
signal batch_completed(successful: int, failed: int)

## 当前加载任务数
var _active_loads: int = 0
var _max_concurrent_loads: int = 5

## 加载队列
var _load_queue: Array[Dictionary] = []

## 加载单个资源 (异步)
func load_async(path: String, cache: ResourceCache = null) -> Resource:
	load_started.emit(path)
	_active_loads += 1
	
	# 使用 ResourceLoader 的 load_threaded_request
	var err = ResourceLoader.load_threaded_request(path, "", false, ResourceLoader.CACHE_MODE_REUSE)
	
	if err != OK:
		load_failed.emit(path, "Failed to start async load: %s" % error_string(err))
		_active_loads -= 1
		return null
	
	# 等待加载完成 (在实际使用中应该轮询)
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# 仍在加载中
			return null
		ResourceLoader.THREAD_LOAD_FAILED:
			load_failed.emit(path, "Thread load failed")
			_active_loads -= 1
			return null
		ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(path)
			if cache and resource:
				cache.cache(path, resource)
			load_completed.emit(path, resource)
			_active_loads -= 1
			return resource
		_:
			load_failed.emit(path, "Unknown status")
			_active_loads -= 1
			return null
	
	return null

## 批量加载资源
func load_batch(paths: Array[String], cache: ResourceCache = null) -> void:
	var total = paths.size()
	var successful = 0
	var failed = 0
	
	for i in range(paths.size()):
		var path = paths[i]
		var resource = load_async(path, cache)
		
		if resource:
			successful += 1
		else:
			failed += 1
		
		load_progress.emit(i + 1, total)
	
	batch_completed.emit(successful, failed)

## 预加载并缓存
func preload_and_cache(paths: Array[String], cache: ResourceCache) -> void:
	load_batch(paths, cache)

## 获取活跃加载数
func get_active_loads() -> int:
	return _active_loads

## 设置最大并发加载数
func set_max_concurrent_loads(max: int) -> void:
	_max_concurrent_loads = max
