extends GutTest
## n7-melee (the audit: the claw's jab wind-up barely reads at 32 px/m): the bare claw cocks
## back deeper before the jab (melee_marks.json swing.pullback; with a gun in hand too), the hit
## tick is unchanged, and the blades keep the night's 0.35. Planted fault: no rows (the before)
## leaves the claw's wind-up at the night's shallow depth.

const W: float = 5.0 * SimClock.TICK_DT
const A: float = 4.0 * SimClock.TICK_DT
const R: float = 9.0 * SimClock.TICK_DT


func after_each() -> void:
	StrikeDepth.reset()


func test_table_cocks_the_bare_claw_deeper() -> void:
	StrikeDepth.reset()
	var claw: float = StrikeDepth.depth(&"")
	gut.p("claw pullback %.2f, blade %.2f" % [claw, StrikeDepth.depth(&"blade")])
	assert_gt(claw, StrikeDepth.BEFORE, "the bare claw cocks back past the night's depth")
	assert_eq(StrikeDepth.depth(&"sidearm"), claw, "a gun in hand: the strike is the claw's jab")
	assert_eq(StrikeDepth.depth(&"blade"), StrikeDepth.BEFORE, "the blades keep the night's swing")


func test_windup_deeper_hit_tick_unchanged() -> void:
	StrikeDepth.use({&"claw": 0.7})
	var deep: PackedFloat32Array = _reach_curve()
	StrikeDepth.use({})
	var night: PackedFloat32Array = _reach_curve()
	var cock: int = 2  # the last cock tick before the jab starts (JAB_TICKS 2 of 5)
	gut.p("cocked reach %.2f (night %.2f)" % [deep[cock], night[cock]])
	assert_lt(deep[cock], night[cock] - 0.15, "cocked further back")
	for k: int in range(4, 9):
		assert_almost_eq(deep[k], night[k], 0.001, "every jab frame as the night's (tick %d)" % k)
	var hit: int = 5  # the first active tick
	assert_almost_eq(deep[hit], 1.0, 0.001, "out at full reach on the hit tick")
	assert_almost_eq(night[hit], deep[hit], 0.001, "the hit tick is the same at any depth")


func test_planted_no_rows_keeps_the_shallow_windup() -> void:
	StrikeDepth.use({})
	var night: PackedFloat32Array = _reach_curve()
	assert_gt(night[2], -StrikeDepth.BEFORE - 0.001, "planted: the night's shallow cock")
	assert_gt(night[2], -0.5, "planted: never as deep as the shipped claw")


## c_reach per tick of one bare-claw strike (index 0 = the strike's first tick).
func _reach_curve() -> PackedFloat32Array:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.drive(SimClock.TICK_DT)
	rig.clips.strike(rig, W, A, R, BodyPlan.R)
	var out: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	out.resize(18)
	for k: int in 18:
		rig.drive(SimClock.TICK_DT)
		out[k] = rig.c_reach
	return out


## The view sees a claw strike `late` ticks into the sim's windup (the arena measured 2): the rig
## starts that far in, so it is out at full reach when the sim's hit lands (the hit-stop holds
## that pose). Planted fault: late 0 (the before) leaves it cocked on that drive.
func test_late_strike_is_out_on_the_sim_hit() -> void:
	StrikeDepth.use({&"claw": 0.7}, {&"claw": 1.0})
	assert_almost_eq(_reach_at_sim_hit(2), 1.0, 0.001, "out at full reach on the sim's hit")
	assert_lt(_reach_at_sim_hit(0), 0.0, "planted: from 0 it is still cocked there")


func _reach_at_sim_hit(late: int) -> float:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.drive(SimClock.TICK_DT)
	RigInput.strike(rig, int(RigInput.pack_strike(5, 4, 9, BodyPlan.R, late)))
	for _k: int in 4:  # the sim's hit is 3 ticks after the view sees a 5-tick windup
		rig.drive(SimClock.TICK_DT)
	return rig.c_reach
