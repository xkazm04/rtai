class_name World
extends Node
## Composition root (ARC-04): builds the WorldContext once (events, data, the 60 Hz clock and the
## per-system RNG registry) and hands it down to every system through setup(). Nothing below this
## node reaches up the tree or into /root. _process() is the one place a raw frame delta enters
## the game, and it goes straight into SimClock.advance() (SIM-01).
## `-- --seed=<n>` sets the master seed; `-- --replay=<file>` re-runs a recorded log headless,
## compares it (SIM-05) and quits 0 when identical, 1 when it diverged; `-- --record=<file>`
## records this run and writes the log when the world leaves the tree.

const DEFAULT_SEED: int = 1

var _ctx: WorldContext = null
var _loop: SimLoop = null


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
	if with_views and DisplayServer.get_name() != "headless":
		var view: CityView = CityView.new()
		add_child(view)
		view.setup(city)


func _exit_tree() -> void:
	if LaunchArgs.has("--record") and _loop != null and _loop.is_recording():
		var log: ReplayLog = _loop.finish_recording()
		var err: Error = log.save(LaunchArgs.value("--record"))
		Log.info(
			"replay",
			"recorded %d ticks to %s (%d)" % [log.ticks, LaunchArgs.value("--record"), err]
		)


## The single raw-delta choke point (SIM-01): consumers read ctx.clock, never `delta`.
func _process(delta: float) -> void:
	if _loop != null:
		_loop.frame(delta)


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
