extends Node2D

var frame_count: int = 0
var start_time: float = 0
var fps_sum: float = 0
var max_fps: float = 0
var min_fps: float = 1000

func _ready():
	print("\n========== 防御塔攻击系统 V2.1 性能测试 ==========\n")
	print("[测试] 开始性能测试...")
	
	# 开始计时
	start_time = Time.get_unix_time_from_system()
	
	# 直接测试帧率，不生成弹道
	print("[测试] 开始帧率测试...")

func _process(delta):
	# 计算帧率
	var fps = 1.0 / delta
	fps_sum += fps
	frame_count += 1
	
	# 更新最大和最小帧率
	if fps > max_fps:
		max_fps = fps
	if fps < min_fps:
		min_fps = fps
	
	# 每10帧打印一次帧率
	if frame_count % 10 == 0:
		var avg_fps = fps_sum / frame_count
		print("[测试] 帧率统计 - 平均: %.1f, 最大: %.1f, 最小: %.1f" % [avg_fps, max_fps, min_fps])
	
	# 测试持续5秒后停止
	var current_time = Time.get_unix_time_from_system()
	var elapsed_time = current_time - start_time
	if elapsed_time >= 5:
		var avg_fps = fps_sum / frame_count
		print("[测试] 性能测试完成")
		print("[测试] 最终帧率统计 - 平均: %.1f, 最大: %.1f, 最小: %.1f" % [avg_fps, max_fps, min_fps])
		
		if avg_fps >= 55:
			print("[测试] 性能测试通过: 平均帧率 >= 55fps")
		else:
			print("[测试] 性能测试失败: 平均帧率低于 55fps")
		
		get_tree().quit()
