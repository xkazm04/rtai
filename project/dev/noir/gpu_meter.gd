class_name NoirGpuMeter
extends RefCounted
## Dev only (lane noir): the mean GPU and CPU render time of each added viewport over the frames
## stepped, from the RenderingServer's viewport measure (needs a GPU; headless reads 0).

var frames: int = 0
var _labels: PackedStringArray = PackedStringArray()
var _vps: Array[RID] = []
var _gpu: PackedFloat64Array = PackedFloat64Array()
var _cpu: PackedFloat64Array = PackedFloat64Array()


func add(label: String, vp: RID) -> void:
	RenderingServer.viewport_set_measure_render_time(vp, true)
	@warning_ignore("return_value_discarded")
	_labels.append(label)
	_vps.append(vp)
	@warning_ignore("return_value_discarded")
	_gpu.append(0.0)
	@warning_ignore("return_value_discarded")
	_cpu.append(0.0)


func step() -> void:
	frames += 1
	for i: int in _vps.size():
		_gpu[i] += RenderingServer.viewport_get_measured_render_time_gpu(_vps[i])
		_cpu[i] += RenderingServer.viewport_get_measured_render_time_cpu(_vps[i])


func report() -> String:
	var n: float = maxf(frames, 1)
	var out: String = "frames %d" % frames
	for i: int in _vps.size():
		out += " | %s gpu_ms %.3f cpu_ms %.3f" % [_labels[i], _gpu[i] / n, _cpu[i] / n]
	return out
