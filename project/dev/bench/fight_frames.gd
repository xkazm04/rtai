class_name FightFrames
extends Node
## perf-city: the live fight's frame log (dev arena `--frames=<json>`). Every rendered frame: the
## wall time since the last frame, the World's sim loop share, the render server's CPU / GPU time,
## draw calls, pipeline compiles and the sim tick. On exit (window close or --quit-after) it writes
## the series plus a summary: p50 / p99 / 1 % low / worst, the worst after the first second, and
## every frame over 33 ms. Real time only: under --fixed-fps the wall times are the machine's,
## the sim's delta is not.

const HITCH_MS: float = 33.0
## The target's "after the first second": frames inside the first SETTLE_MS of wall time are
## left out of the settled stats (vsync off, that is hundreds of frames, not 60).
const SETTLE_MS: float = 1000.0

var out_path: String = ""
## Quit once the sim reaches this tick (0: run until --quit-after or the window closes), so a
## vsync-off run covers the same stretch of the fight as a 60 fps one.
var quit_tick: int = 0
var world: World = null
var _wall: PackedFloat32Array = PackedFloat32Array()
var _loop: PackedFloat32Array = PackedFloat32Array()
var _rcpu: PackedFloat32Array = PackedFloat32Array()
var _rgpu: PackedFloat32Array = PackedFloat32Array()
var _draws: PackedInt32Array = PackedInt32Array()
var _pipes: PackedInt32Array = PackedInt32Array()
var _ticks: PackedInt32Array = PackedInt32Array()
var _proc: PackedFloat32Array = PackedFloat32Array()
## The rest of the frame, split at the draw: flush = probe end -> frame_pre_draw (deferred calls),
## draw = pre -> post draw, pump = post draw -> the next frame's first _process (the OS event pump
## and the physics step), physics = the physics frames' own _physics_process span.
var _flush: PackedFloat32Array = PackedFloat32Array()
var _draw: PackedFloat32Array = PackedFloat32Array()
var _pump: PackedFloat32Array = PackedFloat32Array()
var _phys: PackedFloat32Array = PackedFloat32Array()
var _pre_us: int = 0
var _post_us: int = 0
var _phys_us: int = 0
var _last_us: int = 0
var _first: FirstMark = FirstMark.new()
var _last_pipes: int = 0
var _written: bool = false


## The dev arena's hook: with --frames=<json> (and --frames-ticks=<n>) a probe joins `parent`.
static func attach(parent: Node, args: ArenaArgs, on: World) -> void:
	NodeSpans.attach(parent, args)  # --spans=<json>: per-node _process cost
	if not args.has("--frames"):
		return
	var probe: FightFrames = FightFrames.new()
	probe.out_path = args.text("--frames")
	probe.quit_tick = int(args.number("--frames-ticks", 0.0))
	probe.world = on
	parent.add_child(probe)


func _ready() -> void:
	process_priority = 4096  # after every other node: the frame's work is in
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	_first.process_priority = -4096  # before every other node: the frame's script work starts
	add_child(_first)
	process_physics_priority = 4096
	_first.process_physics_priority = -4096
	@warning_ignore_start("return_value_discarded")
	RenderingServer.frame_pre_draw.connect(func() -> void: _pre_us = Time.get_ticks_usec())
	RenderingServer.frame_post_draw.connect(func() -> void: _post_us = Time.get_ticks_usec())
	@warning_ignore_restore("return_value_discarded")


func _physics_process(_delta: float) -> void:
	_phys_us += Time.get_ticks_usec() - _first.phys_us


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	if _last_us > 0:
		_sample((now - _last_us) / 1000.0)
		if _wall[_wall.size() - 1] > HITCH_MS:  # live, so a --verbose log shows what came before
			var at: Array = [_wall[-1], _proc[-1], _flush[-1], _draw[-1], _pump[-1], _ticks[-1]]
			Log.info(
				"bench", "HITCH %.1f ms (process %.1f flush %.1f draw %.1f pump %.1f) tick %d" % at
			)
	_last_us = now
	if quit_tick > 0 and world != null and world.context().clock.tick() >= quit_tick:
		write()
		get_tree().quit(0)


func _sample(wall_ms: float) -> void:
	var vp: RID = get_viewport().get_viewport_rid()
	var pipes: int = HitchRecorder._pipelines()
	@warning_ignore_start("return_value_discarded")
	_wall.append(wall_ms)
	_proc.append((Time.get_ticks_usec() - _first.us) / 1000.0)
	_flush.append(maxi(0, _pre_us - _last_us) / 1000.0)
	_draw.append(maxi(0, _post_us - _pre_us) / 1000.0)
	_pump.append(maxi(0, _first.us - _post_us) / 1000.0)
	_phys.append(_phys_us / 1000.0)
	_phys_us = 0
	_loop.append(world.frame_loop_ms() if world != null else 0.0)
	_rcpu.append(
		(
			RenderingServer.viewport_get_measured_render_time_cpu(vp)
			+ RenderingServer.get_frame_setup_time_cpu()
		)
	)
	_rgpu.append(RenderingServer.viewport_get_measured_render_time_gpu(vp))
	_draws.append(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	_pipes.append(maxi(0, pipes - _last_pipes))
	_ticks.append(world.context().clock.tick() if world != null else -1)
	@warning_ignore_restore("return_value_discarded")
	_last_pipes = pipes


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		write()


func write() -> void:
	if _written or out_path == "" or _wall.is_empty():
		return
	_written = true
	var doc: Dictionary = {
		"schema": "gtai.fight-frames/1",
		"summary": summary(),
		"hitches": _hitches(),
		"wall_ms": Array(_wall),
		"loop_ms": Array(_loop),
		"process_ms": Array(_proc),
		"flush_ms": Array(_flush),
		"draw_ms": Array(_draw),
		"pump_ms": Array(_pump),
		"physics_ms": Array(_phys),
		"render_cpu_ms": Array(_rcpu),
		"render_gpu_ms": Array(_rgpu),
		"draw_calls": Array(_draws),
		"pipelines": Array(_pipes),
		"tick": Array(_ticks),
	}
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		Log.warn("bench", "fight frames: cannot write %s" % out_path)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(doc))
	f.close()
	Log.info("bench", "fight frames -> %s %s" % [out_path, JSON.stringify(doc["summary"])])


func summary() -> Dictionary:
	var settled: PackedFloat32Array = _wall.slice(mini(_settle_index(), _wall.size() - 1))
	var s: PackedFloat32Array = settled.duplicate()
	s.sort()
	var n: int = s.size()
	var worst_n: int = maxi(1, ceili(n * 0.01))
	var worst_sum: float = 0.0
	for k: int in worst_n:
		worst_sum += s[n - 1 - k]
	return {
		"frames": _wall.size(),
		"p50_ms": s[floori(n * 0.5)],
		"p99_ms": s[mini(n - 1, floori(n * 0.99))],
		"low1_fps": 1000.0 / (worst_sum / worst_n),
		"worst_ms": _max(_wall),
		"worst_settled_ms": s[n - 1],
		"over33_settled": _count_over(settled, HITCH_MS),
		"over50_settled": _count_over(settled, 50.0),
		"ticks": _ticks[_ticks.size() - 1] - _ticks[0],
	}


func _hitches() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i: int in _wall.size():
		if _wall[i] > HITCH_MS:
			(
				out
				. append(
					{
						"frame": i,
						"tick": _ticks[i],
						"wall_ms": snappedf(_wall[i], 0.01),
						"loop_ms": snappedf(_loop[i], 0.01),
						"process_ms": snappedf(_proc[i], 0.01),
						"flush_ms": snappedf(_flush[i], 0.01),
						"draw_ms": snappedf(_draw[i], 0.01),
						"pump_ms": snappedf(_pump[i], 0.01),
						"physics_ms": snappedf(_phys[i], 0.01),
						"render_cpu_ms": snappedf(_rcpu[i], 0.01),
						"render_gpu_ms": snappedf(_rgpu[i], 0.01),
						"pipelines": _pipes[i],
					}
				)
			)
	return out


func _settle_index() -> int:
	var t: float = 0.0
	for i: int in _wall.size():
		t += _wall[i]
		if t >= SETTLE_MS:
			return i + 1
	return _wall.size()


static func _max(a: PackedFloat32Array) -> float:
	var m: float = 0.0
	for v: float in a:
		m = maxf(m, v)
	return m


static func _count_over(a: PackedFloat32Array, ms: float) -> int:
	var c: int = 0
	for v: float in a:
		if v > ms:
			c += 1
	return c


## Stamps the start of the frame's _process pass (the lowest priority runs first).
class FirstMark:
	extends Node
	var us: int = 0
	var phys_us: int = 0

	func _process(_delta: float) -> void:
		us = Time.get_ticks_usec()

	func _physics_process(_delta: float) -> void:
		phys_us = Time.get_ticks_usec()
