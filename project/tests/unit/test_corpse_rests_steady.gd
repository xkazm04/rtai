extends GutTest
## The owner's note (2026-11-09): "Bodies often lag and move across the screen even if they should
## be static". A rig past the full-rate ranks poses on alternate ticks; RigInput puts it back on
## its sim point every tick, so the death's slide (added in the pose step) came and went with the
## pose. Once the fall is over a corpse stays on one world point, posed this tick or not.

const CORPSE_ID: int = 40
const AT: Vector2 = Vector2(96.0, 32.0)
const WALKERS: int = 10
## Past every death family's length: only the rest is measured.
const SETTLE_TICKS: int = 150
const WATCH_TICKS: int = 120

var _rigs: CharacterRigs = null


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_rigs = CharacterRigs.new()
	add_child_autofree(_rigs)
	_rigs.setup(World.build_context(bus, data, 7))
	_rigs.focus = Vector2.ZERO


## Living people nearer the focus than the corpse: it ranks past FULL_RATE (a half-rate pose).
func _crowd() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	for k: int in WALKERS:
		var at: Vector2 = Vector2(float(k) * 2.0, 0.0)
		@warning_ignore("return_value_discarded")
		f.put(k, 100 + k, BodyPlan.Kind.PED, at, Vector2.ZERO)
	@warning_ignore("return_value_discarded")
	f.put(WALKERS, CORPSE_ID, BodyPlan.Kind.PED, AT, Vector2.ZERO)
	f.flags[WALKERS] = RigFeed.Flag.DEAD | RigFeed.Flag.DOWN


func _die(kind: StringName) -> CutRig:
	_crowd()
	_rigs.step_ticks(1)
	var rig: CutRig = _rigs.rig_for(CORPSE_ID)
	assert_not_null(rig, "the corpse has a rig")
	HumanReact.on(rig).play(rig, kind, Vector2.RIGHT, ReactTable.shipped())
	for t: int in SETTLE_TICKS:
		_rigs.step_ticks(1)
	return rig


func _spread(rig: CutRig, steps_per_call: int) -> float:
	var first: Vector2 = rig.global_position
	var worst: float = 0.0
	for t: int in WATCH_TICKS:
		_rigs.step_ticks(steps_per_call)
		worst = maxf(worst, first.distance_to(rig.global_position))
	return worst


func test_the_rank_is_past_full_rate() -> void:
	var rig: CutRig = _die(&"death_bullet")
	assert_not_null(rig)
	var rank: int = _rigs._rank[CORPSE_ID]
	assert_gt(CharacterRigs.rate_of(rank), 1, "the rig under test poses at half rate")


func test_a_half_rate_corpse_stays_on_one_point() -> void:
	var rig: CutRig = _die(&"death_bullet")
	assert_almost_eq(_spread(rig, 1), 0.0, 0.01, "the corpse moved between pose ticks")


func test_a_corpse_stays_on_one_point_through_a_double_step() -> void:
	var rig: CutRig = _die(&"death_blast")
	assert_almost_eq(_spread(rig, 2), 0.0, 0.01, "two steps in a frame doubled the slide")


func test_a_frame_with_no_tick_keeps_the_corpse_where_it_lies() -> void:
	var rig: CutRig = _die(&"death_melee")
	assert_almost_eq(_spread(rig, 0), 0.0, 0.01, "a frame with no tick dropped the slide")


func test_the_slide_still_carries_the_body_off_its_sim_point() -> void:
	var rig: CutRig = _die(&"death_bullet")
	_rigs.step_ticks(1)
	assert_gt(rig.global_position.distance_to(AT), 1.0, "the death's slide is kept")
