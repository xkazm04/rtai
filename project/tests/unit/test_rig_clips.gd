extends GutTest
## F-09b: the authored clips (Rivet punch, roll, death; cop shoot, hit) drive the rig's envelopes
## over their spike durations, on the fixed tick.

var _rig: CutRig = null


func before_each() -> void:
	_rig = CutRig.new()
	add_child_autofree(_rig)
	_rig.setup(RivetPlan.build(), RigVariant.rivet())


func test_punch_reaches_and_returns() -> void:
	_rig.clips.punch(1)
	var peak: float = 0.0
	for _k: int in ceili(RigClips.PUNCH_S / SimClock.TICK_DT) + 1:
		_rig.drive(SimClock.TICK_DT)
		peak = maxf(peak, _rig.c_reach)
	assert_gt(peak, 0.95, "the melee arm reaches out")
	assert_eq(_rig.c_reach, 0.0, "and comes back")


func test_third_combo_hit_is_longer() -> void:
	_rig.clips.punch(3)
	assert_almost_eq(_rig.clips.punch_len, RigClips.PUNCH3_S, 0.001)


func test_roll_tucks_the_silhouette() -> void:
	_rig.clips.roll()
	_tick(0.2)
	assert_eq(_rig.c_tuck, 1.0, "fully tucked mid-roll")
	assert_true(_rig.clips.rolling())
	_tick(0.3)
	assert_eq(_rig.c_tuck, 0.0)


func test_death_sprawls_and_holds() -> void:
	_rig.clips.die(false)
	_tick(0.21)
	assert_almost_eq(_rig.c_sprawl, 0.5, 0.06, "half way at half the ramp")
	_tick(1.0)
	assert_eq(_rig.c_sprawl, 1.0)
	assert_true(_rig.dead)
	assert_eq(_rig.clips.active(), RigClips.Clip.DEATH)


func test_shoot_recoil_decays() -> void:
	_rig.clips.shoot(1.0)
	_tick(SimClock.TICK_DT)
	assert_gt(_rig.c_recoil, 0.85)
	_tick(0.2)
	assert_eq(_rig.c_recoil, 0.0)


func test_hit_shoves_and_flashes() -> void:
	_rig.clips.hit(_rig, Vector2.LEFT)
	_tick(SimClock.TICK_DT * 2)
	assert_gt(_rig.shove.length(), 0.1, "knocked back")
	assert_eq(_rig.clips.active(), RigClips.Clip.HIT)
	_tick(0.3)
	assert_lt(_rig.shove.length(), 5.0, "the shove springs back")


func _tick(seconds: float) -> void:
	for _k: int in roundi(seconds / SimClock.TICK_DT):
		_rig.drive(SimClock.TICK_DT)
