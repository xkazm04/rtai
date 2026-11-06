extends GutTest
## Rivet's death beat (owner, d8): a destroyed Rivet stays down for combat.json
## `rivet.death_beat_s` (the rig plays his sprawl from the DEAD flag), his input is ignored, and
## the ink veil rises before the respawn cut and lifts after; 0 s = d8's instant respawn.

var _bus: EventBus
var _data: DataStore


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())


func _stage() -> CollectCallStage:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	stage.setup(World.build_context(_bus, _data, 1))
	return stage


func test_the_shipped_beat_is_one_second() -> void:
	assert_eq(DeathBeat.of(CombatTuning.shipped()).beat_ticks, SimClock.TICK_RATE)


func test_rivet_lies_down_for_the_beat_then_wakes_at_the_toner_room() -> void:
	var stage: CollectCallStage = _stage()
	var died_at: Vector2 = stage.arena.rivet.pos + Vector2(3.0, 0.0)
	stage.arena.rivet.pos = died_at
	stage.arena.rivet.hp = 0.0
	var down: int = 0
	for t: int in 200:
		stage.call("_respawn")
		if stage.arena.rivet.alive():
			break
		down += 1
		assert_eq(stage.arena.rivet.pos, died_at, "he lies where he fell")
	assert_eq(down, stage.death_beat.beat_ticks - 1)
	assert_eq(stage.deaths, 1)
	assert_eq(stage.arena.rivet.pos, stage.layout.marker("The Toner Room").at)


func test_a_dead_rivet_has_no_intent() -> void:
	var stage: CollectCallStage = _stage()
	stage.arena.rivet.hp = 0.0
	stage.intent.move_by = Vector2(1.0, 0.0)
	stage.intent.fire_at = Vector2(5.0, 5.0)
	stage.step(0, TickInput.new())
	assert_false(stage.arena.rivet.alive(), "still in the beat after one tick")
	assert_eq(stage.shots_fired, 0)


func test_the_veil_rises_into_the_cut_and_lifts_after() -> void:
	var b: DeathBeat = DeathBeat.new()
	b.beat_ticks = 60
	assert_eq(b.veil(), 0.0, "no veil before any death")
	for t: int in 30:
		assert_true(b.holding(false))
	assert_eq(b.veil(), 0.0, "half way through the beat the frame is still clear")
	for t: int in 29:
		assert_true(b.holding(false))
	assert_almost_eq(b.veil(), 1.0 - 1.0 / 24.0, 0.001)
	assert_false(b.holding(false), "the beat ends: respawn")
	assert_eq(b.veil(), 1.0, "the cut lands in the ink")
	for t: int in CombatTuning.ticks(DeathBeat.FADE_OUT_S):
		assert_false(b.holding(true))
	assert_eq(b.veil(), 0.0)


func test_a_zero_beat_is_the_instant_respawn() -> void:
	var b: DeathBeat = DeathBeat.new()
	assert_false(b.holding(false))
	assert_eq(b.veil(), 0.0, "no veil without a beat")
