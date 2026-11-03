class_name World
extends Node
## Composition root (ARC-04): builds the WorldContext once (events, data, the 60 Hz clock and the
## per-system RNG registry) and hands it down to every system through setup(). Nothing below this
## node reaches up the tree or into /root. _process() is the one place a raw frame delta enters
## the game, and it goes straight into SimClock.advance() (SIM-01).
## `-- --seed=<n>` sets the master seed; `-- --replay=<file>` re-runs a recorded log headless,
## compares it (SIM-05) and quits 0 when identical, 1 when it diverged; `-- --record=<file>`
## records this run and writes the log when the world leaves the tree. `-- --reduced-motion`
## turns off the camera shake / hit-stop and the marker pulse (the settings menu owns it later).

const DEFAULT_SEED: int = 1

## The player's cars (features/vehicles): try_enter / exit for missions and the slice.
var vehicles: VehicleService = null
var _ctx: WorldContext = null
var _loop: SimLoop = null
var _hitches: HitchRecorder = null
var _frame_probes: Array[Callable] = []
var _last_us: int = 0
var _loop_ms: float = 0.0
var _prewarming: bool = false


## The one place a WorldContext is assembled. Tests call it with fresh instances or fakes.
static func build_context(events: EventBus, data: DataStore, master_seed: int) -> WorldContext:
	return WorldContext.new(events, data, SimClock.new(), RngRegistry.new(master_seed))


func _ready() -> void:
	if _ctx != null:
		return
	var replay: ReplayLog = null
	if LaunchArgs.has("--replay"):
		replay = ReplayLog.load_file(LaunchArgs.value("--replay"))
		if replay == null:
			get_tree().quit(2)
			return
	start(Events, Data, replay.master_seed if replay != null else _seed_from_args())
	_register_features(replay == null)
	if LaunchArgs.has("--record") and replay == null:
		_loop.start_recording()
	if replay != null:
		var divergence: String = verify_replay(replay)
		Log.info("replay", divergence if divergence != "" else "identical")
		get_tree().quit(0 if divergence == "" else 1)


## Every feature system, in a fixed order, before any replay runs. Views only when drawing.
func _register_features(with_views: bool) -> void:
	var city: CitySystem = CitySystem.new()
	add_system(city)
	vehicles = VehicleService.new()
	add_system(vehicles)
	var vworld: CityVehicleWorld = CityVehicleWorld.new(city)
	vehicles.world = vworld
	if with_views and DisplayServer.get_name() != "headless":
		var view: CityView = CityView.new()
		if LaunchArgs.has("--look"):
			view.look_id = StringName(LaunchArgs.value("--look"))
		view.rig = CameraRig.new()
		view.rig.snap(&"car")
		view.rig.reduced_motion = LaunchArgs.has("--reduced-motion")
		view.markers.reduced_motion = view.rig.reduced_motion
		view.rig.listen(Events, _ctx.clock)
		add_child(view)
		view.setup(city)
		var rivet_px: Callable = func() -> Vector2: return city.target * SimConst.PX_PER_M
		view.fx_triggers.player_id = CityCharacters.RIVET_ID
		view.fx_triggers.listen(Events, _ctx.clock, rivet_px)
		@warning_ignore("return_value_discarded")
		WorldAudio.attach(self, _ctx, view, city)
		var characters: CityCharacters = CityCharacters.new(city, view, _ctx)
		vworld.characters = characters
		view.actor_layer().add_child(CityVehicleWorld.make_view(vehicles, view))
		add_frame_probe(func() -> float: return view.chunks.frame_us / 1000.0)
		add_frame_probe(func() -> float: return characters.rigs.last_us / 1000.0)
		_prewarm(view, characters)


func _exit_tree() -> void:
	if _hitches != null:
		_hitches.stop()
	if LaunchArgs.has("--record") and _loop != null and _loop.is_recording():
		var log: ReplayLog = _loop.finish_recording()
		var err: Error = log.save(LaunchArgs.value("--record"))
		Log.info(
			"replay",
			"recorded %d ticks to %s (%d)" % [log.ticks, LaunchArgs.value("--record"), err]
		)


## TEL-03: the hitch recorder runs whenever a World is in the tree (every build).
func _enter_tree() -> void:
	_hitches = HitchRecorder.new()
	_hitches.start(get_viewport().get_viewport_rid(), _current_tick)


## The single raw-delta choke point (SIM-01): consumers read ctx.clock, never `delta`.
## Also times each frame for the hitch log (wall time between frames, our work in it).
func _process(delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	if _hitches != null and _last_us > 0:
		_hitches.frame((now - _last_us) / 1000.0, _loop_ms + _probe_ms())
	_last_us = now
	if _loop != null and not _prewarming:
		_loop.frame(delta)
	_loop_ms = (Time.get_ticks_usec() - now) / 1000.0


## A per-frame cost (ms) of a view or another node, added to the hitch log's game time.
func add_frame_probe(probe: Callable) -> void:
	_frame_probes.append(probe)


func hitches() -> HitchRecorder:
	return _hitches


## Builds the context (the autoloads in the game, fakes in tests) and an empty sim loop.
func start(events: EventBus, data: DataStore, master_seed: int) -> void:
	_ctx = build_context(events, data, master_seed)
	_loop = SimLoop.new(_ctx)
	events.set_tick_source(_ctx.clock.tick)


## Registers a system: calls down into it with the context (ARC-05), then steps it every tick.
func add_system(system: WorldSystem) -> void:
	system.setup(_ctx)
	_loop.add_system(system)


func context() -> WorldContext:
	return _ctx


func loop() -> SimLoop:
	return _loop


## Replays `log` on this freshly started world; "" when bit-identical, else the divergence.
func verify_replay(log: ReplayLog) -> String:
	return log.first_divergence(_loop.replay(log))


func _seed_from_args() -> int:
	var raw: String = LaunchArgs.value("--seed")
	return raw.to_int() if raw.is_valid_int() else DEFAULT_SEED


func _current_tick() -> int:
	return _ctx.clock.tick() if _ctx != null else -1


func _probe_ms() -> float:
	var ms: float = 0.0
	for probe: Callable in _frame_probes:
		var v: float = probe.call()
		ms += v
	return ms


## The loading screen (WLD-07): the sim waits while the view compiles its pipelines and uploads
## every texture, so the first gameplay frames carry no first-use cost.
func _prewarm(view: CityView, characters: CityCharacters) -> void:
	_prewarming = true
	await characters.bake()
	var us: int = await view.prewarm()
	_prewarming = false
	Log.info("world", "prewarm %.1f ms" % (us / 1000.0))
