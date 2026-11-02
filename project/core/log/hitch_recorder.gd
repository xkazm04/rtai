class_name HitchRecorder
extends RefCounted
## TEL-03: every frame over THRESHOLD_MS is recorded to user://logs/hitches.jsonl with the
## engine's own timings and the game's, and attributed: `outside` (the whole process stalled: the
## FrameCanary woke late too), `pipeline` (a shader/pipeline compile happened), `game` (our sim,
## streaming and draw work), `render` (render-server CPU/GPU), `present` (the draw phase, which
## ends in the swap, waited far longer than the render server worked: the driver / compositor
## held the swap chain), else `unexplained`.

const THRESHOLD_MS: float = 25.0
const LOG_PATH: String = "user://logs/hitches.jsonl"
const KEEP: int = 256
const PIPELINE_MONITORS: Array[Performance.Monitor] = [
	Performance.PIPELINE_COMPILATIONS_CANVAS,
	Performance.PIPELINE_COMPILATIONS_MESH,
	Performance.PIPELINE_COMPILATIONS_SURFACE,
	Performance.PIPELINE_COMPILATIONS_DRAW,
	Performance.PIPELINE_COMPILATIONS_SPECIALIZATION,
]

var records: Array[Dictionary] = []
var frames: int = 0
var log_path: String = LOG_PATH
var _canary: FrameCanary = FrameCanary.new()
var _file: FileAccess = null
var _viewport: RID
var _last_pipelines: int = 0
var _tick_source: Callable
var _pre_draw_us: int = 0
var _draw_us: int = 0


func start(viewport: RID, tick_source: Callable) -> void:
	_viewport = viewport
	_tick_source = tick_source
	RenderingServer.viewport_set_measure_render_time(viewport, true)
	_last_pipelines = _pipelines()
	_canary.start()
	var err: int = RenderingServer.frame_pre_draw.connect(_on_pre_draw)
	err |= RenderingServer.frame_post_draw.connect(_on_post_draw)
	if err != OK:
		Log.warn("hitch", "draw timing unavailable (%d)" % err)


func stop() -> void:
	_canary.stop()
	if RenderingServer.frame_pre_draw.is_connected(_on_pre_draw):
		RenderingServer.frame_pre_draw.disconnect(_on_pre_draw)
		RenderingServer.frame_post_draw.disconnect(_on_post_draw)
	if _file != null:
		_file.close()
		_file = null


## Called once per frame with the wall time of the previous frame and our own work in it.
func frame(wall_ms: float, game_ms: float) -> void:
	frames += 1
	var pipes: int = _pipelines()
	var compiled: int = pipes - _last_pipelines if pipes >= _last_pipelines else pipes
	_last_pipelines = pipes
	var gap_ms: float = _canary.take_max_gap_ms()
	if wall_ms <= THRESHOLD_MS:
		return
	var rec: Dictionary = {
		"frame": frames,
		"tick": _tick_source.call() if _tick_source.is_valid() else -1,
		"wall_ms": snappedf(wall_ms, 0.01),
		"game_ms": snappedf(game_ms, 0.01),
		"process_ms": snappedf(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, 0.01),
		"render_cpu_ms": snappedf(_render_cpu_ms(), 0.01),
		"render_gpu_ms":
		snappedf(RenderingServer.viewport_get_measured_render_time_gpu(_viewport), 0.01),
		"pipelines": compiled,
		"canary_gap_ms": snappedf(gap_ms, 0.01),
		"draw_ms": snappedf(_draw_us / 1000.0, 0.01),
	}
	rec["cause"] = attribute(rec)
	records.append(rec)
	if records.size() > KEEP:
		records.remove_at(0)
	_write(rec)


## The cause of one hitch record (see the class doc). Pure, so tests pin the rule.
static func attribute(rec: Dictionary) -> String:
	var wall: float = rec["wall_ms"]
	var canary: float = rec["canary_gap_ms"]
	var pipelines: int = rec["pipelines"]
	var game: float = rec["game_ms"]
	var render_cpu: float = rec["render_cpu_ms"]
	var render_gpu: float = rec["render_gpu_ms"]
	var render: float = render_cpu + render_gpu
	if canary >= wall * 0.5:
		return "outside"
	if pipelines > 0:
		return "pipeline"
	if game >= wall * 0.5:
		return "game"
	if render >= wall * 0.5:
		return "render"
	var draw: float = rec.get("draw_ms", 0.0)
	if draw - render_cpu >= wall * 0.5:
		return "present"
	return "unexplained"


func _on_pre_draw() -> void:
	_pre_draw_us = Time.get_ticks_usec()


func _on_post_draw() -> void:
	_draw_us = Time.get_ticks_usec() - _pre_draw_us


func _render_cpu_ms() -> float:
	var vp: float = RenderingServer.viewport_get_measured_render_time_cpu(_viewport)
	return vp + RenderingServer.get_frame_setup_time_cpu()


static func _pipelines() -> int:
	var n: int = 0
	for m: Performance.Monitor in PIPELINE_MONITORS:
		n += int(Performance.get_monitor(m))
	return n


func _write(rec: Dictionary) -> void:
	if _file == null:
		if DirAccess.make_dir_recursive_absolute(log_path.get_base_dir()) != OK:
			return
		var exists: bool = FileAccess.file_exists(log_path)
		_file = FileAccess.open(log_path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
		if _file == null:
			return
		_file.seek_end()
	var ok: bool = _file.store_line(JSON.stringify(rec, "", true))
	_file.flush()
	if not ok:
		Log.warn("hitch", "could not write %s" % log_path)
