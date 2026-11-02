class_name BenchStats
extends RefCounted
## Per-frame bench samples and the STANDARDS section 20 metrics over them: p99 CPU frame, 1% low
## fps (1000 / mean of the worst 1% of frames), the worst frame in any 3-frame window that starts
## at a frame with streaming work (a chunk stamped, dropped, drawn or released), the worst frame.

const WARMUP_FRAMES: int = 120
const SWAP_WINDOW: int = 3

var frame_ms: PackedFloat64Array = PackedFloat64Array()
var sim_ms: PackedFloat64Array = PackedFloat64Array()
var stream_ms: PackedFloat64Array = PackedFloat64Array()
var swap: PackedByteArray = PackedByteArray()
var actors: PackedInt32Array = PackedInt32Array()
var visible: PackedInt32Array = PackedInt32Array()
var frames: int = 0
var _ticks: int = 0
var _sim_us: int = 0
var _stream_us: int = 0


func add(ms: float, city_us: PackedInt64Array, swapped: bool, counts: Vector2i) -> void:
	frames += 1
	if frames <= WARMUP_FRAMES:
		return
	_ticks += city_us[3]
	_sim_us += city_us[2]
	_stream_us += city_us[0] + city_us[1]
	@warning_ignore_start("return_value_discarded")
	frame_ms.append(ms)
	sim_ms.append(city_us[2] / 1000.0)
	stream_ms.append((city_us[0] + city_us[1]) / 1000.0)
	swap.append(1 if swapped else 0)
	actors.append(counts.x)
	visible.append(counts.y)
	@warning_ignore_restore("return_value_discarded")


func metrics() -> Dictionary[String, float]:
	var n: int = frame_ms.size()
	if n == 0:
		return {}
	var sorted: PackedFloat64Array = frame_ms.duplicate()
	sorted.sort()
	var worst_n: int = maxi(1, ceili(n * 0.01))
	var worst_sum: float = 0.0
	for k: int in worst_n:
		worst_sum += sorted[n - 1 - k]
	return {
		"p99CpuMs": sorted[mini(n - 1, floori(n * 0.99))],
		"low1Fps": 1000.0 / (worst_sum / worst_n),
		"worstSwapMs": _worst_swap(),
		"worstFrameMs": sorted[n - 1],
		"avgFrameMs": _mean(frame_ms),
		"simStepMsPerTick": _sim_us / 1000.0 / maxi(1, _ticks),
		"streamSpawnMsPerTick": _stream_us / 1000.0 / maxi(1, _ticks),
		"simStepMsMax": _max(sim_ms),
		"actorsAvg": _mean_i(actors),
		"visibleAvg": _mean_i(visible),
		"visibleMax": float(_max_i(visible)),
		"framesMeasured": float(n),
		"swapFrames": float(_count(swap)),
	}


func _worst_swap() -> float:
	var worst: float = 0.0
	for i: int in frame_ms.size():
		if swap[i] == 0:
			continue
		for k: int in range(i, mini(i + SWAP_WINDOW, frame_ms.size())):
			worst = maxf(worst, frame_ms[k])
	return worst


static func _mean(a: PackedFloat64Array) -> float:
	var s: float = 0.0
	for v: float in a:
		s += v
	return s / maxi(1, a.size())


static func _max(a: PackedFloat64Array) -> float:
	var m: float = 0.0
	for v: float in a:
		m = maxf(m, v)
	return m


static func _mean_i(a: PackedInt32Array) -> float:
	var s: float = 0.0
	for v: int in a:
		s += v
	return s / maxi(1, a.size())


static func _max_i(a: PackedInt32Array) -> int:
	var m: int = 0
	for v: int in a:
		m = maxi(m, v)
	return m


static func _count(a: PackedByteArray) -> int:
	var c: int = 0
	for v: int in a:
		c += v
	return c
