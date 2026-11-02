extends GutTest
## SIM-05 in the unit-test layer (the 60 s run is scenarios/scenario_replay_60s.gd): a 5 s run of
## the dummy sim replays bit-identically, is independent of frame pacing, and a planted mutation
## is caught (TST-05).

const SECONDS: int = 5
const MASTER_SEED: int = 7


func test_replay_is_bit_identical() -> void:
	var recorded: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED, 1)
	assert_gte(recorded.ticks, SECONDS * SimClock.TICK_RATE)
	assert_gt(recorded.timeline.size(), 0, "events were emitted")
	assert_eq(DummyRun.replay(recorded), "")


func test_frame_pacing_does_not_change_the_sim() -> void:
	var a: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED, 1)
	var b: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED, 99)
	assert_eq(a.first_divergence(b), "")


func test_a_different_seed_gives_a_different_run() -> void:
	var a: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED, 1)
	var b: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED + 1, 1)
	assert_ne(a.final_hash, b.final_hash)


func test_planted_input_mutation_is_localised() -> void:
	var recorded: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED, 1)
	recorded.tamper_input(150, TickInput.new(7, TickInput.AXIS_MAX, TickInput.AXIS_MAX))
	assert_eq(DummyRun.replay(recorded), "state hash differs at tick 180")
