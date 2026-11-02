class_name SimLoop
extends RefCounted
## Runs the registered systems on the fixed tick (SIM-01): samples the input once per tick, steps
## every system in registration order, and, while recording, logs the input, a state hash every
## ReplayLog.CHECKPOINT_EVERY ticks and the event timeline (SIM-05).

var _ctx: WorldContext
var _systems: Array[WorldSystem] = []
var _input: InputSource = InputSource.new()
var _recording: ReplayLog = null
var _timeline: EventLog = null


func _init(ctx: WorldContext) -> void:
	_ctx = ctx


func add_system(system: WorldSystem) -> void:
	_systems.append(system)


func set_input(source: InputSource) -> void:
	_input = source


## Starts recording into a fresh log seeded like this world.
func start_recording() -> void:
	_recording = ReplayLog.new(_ctx.rng.master_seed())
	_timeline = EventLog.new()
	_timeline.attach(_ctx.events, _ctx.clock.tick)


func is_recording() -> bool:
	return _recording != null


## Seals and returns the recording (ticks, final hash, timeline) and stops recording.
func finish_recording() -> ReplayLog:
	var log: ReplayLog = _recording
	log.ticks = _ctx.clock.tick()
	log.final_hash = state_hash()
	log.timeline.assign(_timeline.lines())
	_timeline.detach()
	_recording = null
	_timeline = null
	return log


## One rendered frame: the clock turns the clamped delta into 0..4 fixed steps.
func frame(raw_delta: float) -> void:
	for i: int in _ctx.clock.advance(raw_delta):
		step()


func step() -> void:
	var tick: int = _ctx.clock.tick()
	var input: TickInput = _input.sample(tick)
	if _recording != null:
		_recording.record_input(tick, input)
	for system: WorldSystem in _systems:
		system.step(tick, input)
	_ctx.clock.complete_tick()
	if _recording != null and _ctx.clock.tick() % ReplayLog.CHECKPOINT_EVERY == 0:
		_recording.checkpoints.append(state_hash())


## Re-runs `log` from its inputs on this (freshly seeded) world and records the result.
## Compare with log.first_divergence(result). The world must use log.master_seed.
func replay(log: ReplayLog) -> ReplayLog:
	set_input(ReplayInput.new(log))
	start_recording()
	while _ctx.clock.tick() < log.ticks:
		step()
	return finish_recording()


## SHA-256 over the tick, every RNG stream's state and every system's state.
func state_hash() -> String:
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	buf.put_64(_ctx.clock.tick())
	_ctx.rng.write_state(buf)
	for system: WorldSystem in _systems:
		system.write_state(buf)
	var hashing: HashingContext = HashingContext.new()
	var err: int = hashing.start(HashingContext.HASH_SHA256)
	err |= hashing.update(buf.data_array)
	if err != OK:
		Log.error("replay", "state hash failed (%d)" % err)
	return hashing.finish().hex_encode()
