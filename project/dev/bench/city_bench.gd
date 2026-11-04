extends Node
## The city bench (WLD-08): runs the real World + CitySystem + CityView with a BenchDriver and
## logs every frame. Headless (the editor binary with --fixed-fps 60: one tick per frame, CPU
## only) or as an exported build (windowed, vsync off, uncapped). Writes gtai.bench/1 JSON.
## Usage: <godot|exe> [--headless --fixed-fps 60] [--path project] res://dev/bench/city_bench.tscn
##        -- --scenario=drive|riot --secs=60 --zoom=0.4 --out=<json path> [--fx-feed=off]

const KNOWN_FLAGS: PackedStringArray = [
	"--scenario", "--secs", "--zoom", "--out", "--label", "--vsync", "--fx-feed"
]
const VSYNC: Dictionary[String, DisplayServer.VSyncMode] = {
	"disabled": DisplayServer.VSYNC_DISABLED,
	"enabled": DisplayServer.VSYNC_ENABLED,
	"mailbox": DisplayServer.VSYNC_MAILBOX,
	"adaptive": DisplayServer.VSYNC_ADAPTIVE,
}
const MASTER_SEED: int = 777

var _args: Dictionary[String, String] = {
	"--scenario": "drive",
	"--secs": "60",
	"--zoom": "0.4",
	"--out": "user://bench.json",
	"--label": "",
	"--vsync": "disabled",
	"--fx-feed": "on"
}
var _world: World = null
var _city: CitySystem = null
var _view: CityView = null
var _characters: CityCharacters = null
var _rig_ticks: int = 0
var _stats: BenchStats = BenchStats.new()
var _last_us: int = 0
var _moves: int = 0


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("city_bench: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		_args[flag] = arg.substr(flag.length() + 1)
	Engine.max_fps = 0
	if not _headless():
		var mode: DisplayServer.VSyncMode = VSYNC.get(
			_args["--vsync"], DisplayServer.VSYNC_DISABLED
		)
		DisplayServer.window_set_vsync_mode(mode)
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	_city = CitySystem.new(true)
	world.add_system(_city)
	world.add_system(BenchDriver.new(_city, _args["--scenario"]))
	_view = CityView.new()
	_view.zoom = _args["--zoom"].to_float()
	add_child(_view)
	_view.setup(_city)
	if _args["--fx-feed"] == "off":
		_view.fx_feed = null
	_characters = CityCharacters.new(_city, _view, world.context())
	_characters.rivet_on_foot = _args["--scenario"] == "riot"
	_city.body.on = _characters.rivet_on_foot  # in a car Rivet has no body (features/bodies)
	await _characters.bake()
	var prewarm_us: int = await _view.prewarm()
	printerr("city_bench: prewarm %.1f ms" % (prewarm_us / 1000.0))
	add_child(world)
	_world = world
	_last_us = Time.get_ticks_usec()


## Measures wall time itself (never the frame delta, SIM-01).
func _process(_delta: float) -> void:
	if _world == null:
		return
	var now: int = Time.get_ticks_usec()
	var ms: float = (now - _last_us) / 1000.0
	_last_us = now
	var moves: int = _city.residency.stamped + _city.residency.dropped
	var swapped: bool = _view.chunks.frame_swapped or moves != _moves
	_moves = moves
	var counts: PackedInt32Array = _city.sim.get_counters()
	var live: int = counts[0] + counts[1] + counts[2] + counts[3]
	_stats.add(ms, _city.take_stats(), swapped, Vector2i(live, _view.visible_actors))
	var stepped: int = _characters.rigs.ticks_stepped
	_stats.add_rig(_characters.rigs.last_us, stepped - _rig_ticks, _characters.rigs.full_count())
	_rig_ticks = stepped
	if _world.context().clock.tick() >= _args["--secs"].to_float() * SimClock.TICK_RATE:
		_finish()


func _finish() -> void:
	set_process(false)
	var res: Dictionary = {
		"schema": "gtai.bench/1",
		"scenario": _args["--scenario"],
		"mode":
		"headless" if _headless() else ("exported" if OS.has_feature("template") else "editor"),
		"debug_build": OS.is_debug_build(),
		"backend": String(_city.sim.backend_name()),
		"secs": _args["--secs"].to_float(),
		"zoom": _view.zoom,
		"vsync": _args["--vsync"],
		"label": _args["--label"] if _args["--label"] != "" else _args["--scenario"],
		"frames": _stats.frames,
		"metrics": _with_hitches(_stats.metrics()),
		"hitches": _world.hitches().records,
		"cpu": OS.get_processor_name(),
		"processor_count": OS.get_processor_count(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"chunk_failures": _city.source.failures.size(),
		"frame_ms": Array(_stats.frame_ms),
	}
	var f: FileAccess = FileAccess.open(_args["--out"], FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(res))
	if f != null:
		f.close()
	printerr(
		(
			"city_bench: %s %s -> %s"
			% [_args["--scenario"], JSON.stringify(res["metrics"]), _args["--out"]]
		)
	)
	var c: CrowdReact = _characters.crowd  # human-reactions: the riot's crowd reactions
	printerr("city_bench: crowd %d cowers, %d trips, %d deaths" % [c.cowers, c.trips, c.deaths])
	get_tree().quit(0 if ok else 1)


## Adds the TEL-03 hitch counts: over 25 ms, over 50 ms, and over 50 ms by cause.
func _with_hitches(m: Dictionary[String, float]) -> Dictionary[String, float]:
	var over50: Dictionary[String, int] = {}
	var n25: int = 0
	var warm: int = 0
	for rec: Dictionary in _world.hitches().records:
		var frame: int = rec["frame"]
		if frame <= BenchStats.WARMUP_FRAMES:
			warm += 1
			continue
		n25 += 1
		var wall: float = rec["wall_ms"]
		if wall > 50.0:
			var cause: String = rec["cause"]
			over50[cause] = over50.get(cause, 0) + 1
	m["hitches25"] = n25
	m["hitchesWarmup"] = warm
	m["hitchesOver50"] = 0.0
	for cause: String in ["outside", "pipeline", "game", "render", "present", "unexplained"]:
		m["over50." + cause] = over50.get(cause, 0)
		m["hitchesOver50"] += over50.get(cause, 0)
	return m


static func _headless() -> bool:
	return DisplayServer.get_name() == "headless"
