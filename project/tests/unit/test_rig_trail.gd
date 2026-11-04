extends GutTest
## rivet-arsenal: Rivet's planted foot never trails its hip far (RigGait._cap_trail). In the live
## arena (aiming down, slowing from a run into a strafe left) the old long-stride foot stayed out
## behind (54 px at 32 px/m, read as a flung arm at 64 px/m); the arena measured p95 43.7 -> 27.6.
## Planted fault: a plan without twin-stick hips (no cap) leaves a stranded foot out.

const CAP_PX: float = 40.0


func test_a_stranded_stance_foot_slides_in_under_the_cap() -> void:
	var capped: float = _stranded(1.0)
	var free: float = _stranded(0.0)
	gut.p(
		"stance foot 60 px out, one tick later: capped %.1f px, uncapped %.1f px" % [capped, free]
	)
	assert_lt(capped, CAP_PX, "Rivet's trailing foot is pulled in under the cap")
	assert_gt(free, 55.0, "planted fault: a plan without the cap leaves it out")


func test_backpedal_shortens_the_stride() -> void:
	var rig: CutRig = _rig(1.0)
	rig.vel_in = Vector2(0, -70)  # facing down, walking up: a backpedal
	assert_almost_eq(RigGait.backpedal_scale(rig), RigGait.BACKPEDAL_STRIDE, 0.001)
	rig.vel_in = Vector2(0, 70)
	assert_eq(RigGait.backpedal_scale(rig), 1.0, "walking forward keeps the stride")


func _rig(hip_follow: float) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	var plan: BodyPlan = RivetPlan.build()
	plan.hip_follow = hip_follow
	rig.setup(plan, RigVariant.rivet())
	rig.position = Vector2(500, 500)
	rig.reset_state(PI * 0.5)
	return rig


## The live case: a strafe left at walk speed (73 px/s, facing down) with the left foot planted
## 60 px out behind its hip (left over from a faster run); returns its distance one tick later.
func _stranded(hip_follow: float) -> float:
	var rig: CutRig = _rig(hip_follow)
	rig.vel_in = Vector2(-73, 2)
	for _k: int in 20:
		rig.position += rig.vel_in * SimClock.TICK_DT
		rig.drive(SimClock.TICK_DT)
	rig.phase = 0.8  # the left foot in its stance (swing_frac <= 0.62)
	var side: RigLimbs = rig.sides[BodyPlan.L]
	side.foot_w = rig.hip_world(BodyPlan.L) + Vector2(60, 0)
	rig.drive(SimClock.TICK_DT)
	return side.foot_w.distance_to(rig.hip_world(BodyPlan.L))
