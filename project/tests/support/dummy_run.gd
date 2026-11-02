class_name DummyRun
extends RefCounted
## A World with the dummy systems on throwaway nodes, shared by the replay scenario and tests.
## record() drives it with jittery frame deltas (render decoupling); replay() re-runs a log.

var world: World
var _bus: EventBus
var _data: DataStore


func _init(master_seed: int) -> void:
	world = World.new()
	_bus = EventBus.new()
	_data = DataStore.new()
	world.start(_bus, _data, master_seed)
	world.add_system(DummyWalkers.new())
	world.add_system(DummyEconomy.new())


## Records exactly `seconds` of sim, rendered at a random 20-250 fps per frame (the last few
## ticks are stepped singly so every pacing ends on the same tick).
static func record(seconds: int, master_seed: int, jitter_seed: int) -> ReplayLog:
	var run: DummyRun = DummyRun.new(master_seed)
	var loop: SimLoop = run.world.loop()
	loop.set_input(DummyBot.new(master_seed + 1))
	loop.start_recording()
	var jitter: RandomNumberGenerator = RngRegistry.new(jitter_seed).stream(&"frame_jitter")
	var target: int = seconds * SimClock.TICK_RATE
	var clock: SimClock = run.world.context().clock
	while clock.tick() < target - SimClock.MAX_STEPS_PER_FRAME:
		loop.frame(jitter.randf_range(0.004, 0.05))
	while clock.tick() < target:
		loop.step()
	var log: ReplayLog = loop.finish_recording()
	run.free_nodes()
	return log


## Replays `log` on a fresh world; "" when bit-identical, else the first divergence.
static func replay(log: ReplayLog) -> String:
	var run: DummyRun = DummyRun.new(log.master_seed)
	var divergence: String = run.world.verify_replay(log)
	run.free_nodes()
	return divergence


func free_nodes() -> void:
	world.free()
	_bus.free()
	_data.free()
