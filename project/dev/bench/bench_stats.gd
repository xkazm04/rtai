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
var rig_ms: PackedFloat64Array = PackedFloat64Array()
## perf-city: draw calls and the render server's CPU ms per frame (windowed runs only; a draw
## call count does not move with the machine's load, so it A/Bs on a busy machine).
var draws: PackedInt32Array = PackedInt32Array()
var render_cpu_ms: PackedFloat64Array = PackedFloat64Array()
var _rig_us: int = 0
var _rig_ticks: int = 0
var _rigs_max: int = 0
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


## The cutout rigs' frame cost (selection + pose steps) and how many ticks it stepped.
func add_rig(us: int, ticks: int, full: int) -> void:
	if frames <= WARMUP_FRAMES:
		return
	_rig_us += us
	_rig_ticks += ticks
	_rigs_max = maxi(_rigs_max, full)
	@warning_ignore("return_value_discarded")
	rig_ms.append(us / 1000.0)


## One frame's draw calls and render CPU ms (call after add(); skipped in the warm-up).
func add_render(draw_calls: int, cpu_ms: float) -> void:
	if frames <= WARMUP_FRAMES:
		return
	@warning_ignore("return_value_discarded")
	draws.append(draw_calls)
	@warning_ignore("return_value_discarded")
	render_cpu_ms.append(cpu_ms)


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
		"rigMsP50": _pct(rig_ms, 0.5),
		"rigMsP99": _pct(rig_ms, 0.99),
		"rigMsPerTick": _rig_us / 1000.0 / maxi(1, _rig_ticks),
		"fullRigsMax": float(_rigs_max),
		"swapFrames": float(_count(swap)),
		"drawCallsAvg": _mean_i(draws),
		"renderCpuMsAvg": _mean(render_cpu_ms),
		"renderCpuMsP99": _pct(render_cpu_ms, 0.99),
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


static func _pct(a: PackedFloat64Array, q: float) -> float:
	if a.is_empty():
		return 0.0
	var s: PackedFloat64Array = a.duplicate()
	s.sort()
	return s[mini(s.size() - 1, floori(s.size() * q))]


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
