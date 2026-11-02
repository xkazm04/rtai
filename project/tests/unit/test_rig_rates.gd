extends GutTest
## LOD 0c: rigs past the nearest HALF_RATE pose every 4th tick with a 4-tick step. The springs
## sub-step (RigSprings), so a quarter-rate rig stays stable and tracks a full-rate twin.

const QUARTER: int = 4
const PX: float = 32.0


func _ped() -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(HumanPlan.ped(), RigVariant.crowd(0))
	return rig


func test_rates_by_rank() -> void:
	assert_eq(CharacterRigs.rate_of(0), 1)
	assert_eq(CharacterRigs.rate_of(CharacterRigs.FULL_RATE - 1), 1)
	assert_eq(CharacterRigs.rate_of(CharacterRigs.FULL_RATE), 2)
	assert_eq(CharacterRigs.rate_of(CharacterRigs.HALF_RATE), QUARTER)
	assert_eq(CharacterRigs.rate_of(CharacterRigs.MAX_FULL - 1), QUARTER)
	assert_eq(CharacterRigs.rate_of(CharacterRigs.MAX_FULL - 1, 1.5), QUARTER, "48 px/m (car)")
	assert_eq(
		CharacterRigs.rate_of(CharacterRigs.MAX_FULL - 1, 2.0), 2, "64 px/m arena: no quarter"
	)


func test_quarter_rate_turn_is_stable() -> void:
	var rig: CutRig = _ped()
	rig.face_to = PI - 0.1
	var peak_w: float = 0.0
	for _k: int in 30:
		rig.drive(SimClock.TICK_DT * QUARTER)
		peak_w = maxf(peak_w, absf(rig.face_w))
	assert_lt(absf(wrapf(rig.facing - rig.face_to, -PI, PI)), 0.01, "settles on the target")
	assert_lt(peak_w, 30.0, "no blow-up (plain Euler at 4 ticks diverges for k 260)")


func test_quarter_rate_tracks_a_full_rate_twin() -> void:
	var full: CutRig = _ped()
	var quarter: CutRig = _ped()
	var worst_face: float = 0.0
	var worst_foot: float = 0.0
	for t: int in 240:
		var turn: float = 0.0 if t < 120 else 1.2
		for rig: CutRig in [full, quarter]:
			rig.global_position = Vector2(t * 1.0, 0.0)
			rig.vel_in = Vector2(60.0, 0.0)
			rig.face_to = turn
		full.drive(SimClock.TICK_DT)
		if (t + 1) % QUARTER == 0:
			quarter.drive(SimClock.TICK_DT * QUARTER)
			worst_face = maxf(worst_face, absf(wrapf(full.facing - quarter.facing, -PI, PI)))
			for s: int in 2:
				var d: float = full.sides[s].foot_w.distance_to(quarter.sides[s].foot_w)
				worst_foot = maxf(worst_foot, d)
	gut.p("quarter vs full: facing %.3f rad, foot %.1f px" % [worst_face, worst_foot])
	assert_lt(worst_face, 0.35, "the turn lags by less than 20 degrees")
	assert_lt(worst_foot, 0.5 * PX, "planted feet stay within half a metre")
