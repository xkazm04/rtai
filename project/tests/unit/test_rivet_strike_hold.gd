extends GutTest
## n16 kills-polish (owner n15 verdict): a blade's strike cell holds RivetWindup.HOLD_TICKS past
## its recovery, so a next swing in a short gap follows on without one upright facing frame;
## --rivet-strike-hold=off ends the clip with its recovery (the before). Other holds never hold.

const W: int = 4
const A: int = 3
const R: int = 8


func after_each() -> void:
	RivetWindup.hold = true


func _rig(weapon: StringName) -> CutRig:
	var rig: CutRig = CutRig.new()
	autofree(rig)
	rig.gun_out = true
	rig.set_meta(RivetFrames.WEAPON, weapon)
	RigInput.strike(rig, int(RigInput.pack_strike(W, A, R, 0, 0)))
	return rig


## Ticks the clip lasts (strike_t >= 0) after RigInput.strike, stepping as the view does.
func _ticks_struck(rig: CutRig) -> int:
	var n: int = 0
	while rig.clips.strike_t >= 0.0 and n < 120:
		rig.clips.sample(rig, SimClock.TICK_DT)
		n += 1
	return n


func test_a_blade_holds_its_strike_past_the_recovery() -> void:
	var plain: int = _ticks_struck(_rig(&"pistol"))
	for w: StringName in RivetWindup.BLADE_LEFT:
		var rig: CutRig = _rig(w)
		assert_almost_eq(rig.clips.strike_hold, RivetWindup.HOLD_TICKS * SimClock.TICK_DT, 1e-6)
		assert_eq(_ticks_struck(rig), plain + RivetWindup.HOLD_TICKS, String(w))
	assert_eq(plain, W + A + R + 1, "a gun's strike ends with its recovery")


func test_the_hold_keeps_the_strike_cell_not_the_wind_up() -> void:
	var rig: CutRig = _rig(&"katana")
	for i: int in W + A + R + 2:
		rig.clips.sample(rig, SimClock.TICK_DT)
	assert_true(rig.clips.strike_t >= 0.0, "still held")
	assert_true(RivetWindup.struck(rig), "the strike cell, past the wind-up")
	assert_false(RivetWindup.winding(rig))
	assert_almost_eq(rig.c_reach, 0.0, 1e-4, "the arm is home: the recovery's last pose")


func test_a_new_swing_in_the_gap_starts_its_wind_up() -> void:
	var rig: CutRig = _rig(&"katana")
	for i: int in W + A + R + 2:
		rig.clips.sample(rig, SimClock.TICK_DT)
	RigInput.strike(rig, int(RigInput.pack_strike(W, A, R, 0, 0)))
	assert_true(RivetWindup.winding(rig), "the next swing winds up from the held strike")


func test_the_flag_off_is_the_before() -> void:
	RivetWindup.hold = false
	var rig: CutRig = _rig(&"katana")
	assert_eq(rig.clips.strike_hold, 0.0)
	assert_eq(_ticks_struck(rig), W + A + R + 1)
