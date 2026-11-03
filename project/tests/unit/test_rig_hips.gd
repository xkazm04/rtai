extends GutTest
## rivet-motion: twin-stick hips. The hips turn toward the walk (clamped), fold on a backpedal,
## settle when standing, and a strafe walks on a real track gauge instead of scissoring the feet
## along one line (the planted fault: hip_follow 0, the day rig, must measure narrower).


func test_target_follows_walk_and_folds_backpedal() -> void:
	var p: BodyPlan = RivetPlan.build()
	var up: float = -PI * 0.5
	var lim: float = p.hip_twist_max
	assert_almost_eq(RigHips.target(Vector2(0, -60), up, p), 0.0, 0.001, "forward")
	assert_almost_eq(RigHips.target(Vector2(60, 0), up, p), lim, 0.001, "strafe right, clamped")
	assert_almost_eq(RigHips.target(Vector2(-60, 0), up, p), -lim, 0.001, "strafe left")
	assert_almost_eq(RigHips.target(Vector2(0, 60), up, p), 0.0, 0.001, "backpedal keeps the hips")
	var back_right: float = RigHips.target(Vector2(60, 60), up, p)
	assert_almost_eq(back_right, -PI * 0.25, 0.001, "back-right folds to a 45 degree hip turn")
	assert_eq(RigHips.target(Vector2.ZERO, up, p), 0.0, "standing")
	assert_eq(RigHips.target(Vector2(60, 0), up, HumanPlan.cop()), 0.0, "cops keep their hips")


func test_strafe_walks_on_a_track_gauge() -> void:
	var twin: float = _gauge(1.0)
	var locked: float = _gauge(0.0)
	gut.p("strafe foot gauge (part px): twin-stick %.1f, locked %.1f" % [twin, locked])
	assert_gt(twin, locked * 1.5, "the hips turn so the feet stop scissoring")


func test_hips_settle_when_standing() -> void:
	var rig: CutRig = _rig(1.0)
	_walk(rig, Vector2(64, 0), 60)
	assert_gt(absf(rig.hip_yaw), 0.8, "turned while strafing")
	_walk(rig, Vector2.ZERO, 60)
	assert_lt(absf(rig.hip_yaw), 0.02, "back on the aim after a second")


func _rig(follow: float) -> CutRig:
	var p: BodyPlan = RivetPlan.build()
	p.hip_follow = follow
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(p, RigVariant.rivet())
	rig.snap_facing(-PI * 0.5)
	return rig


func _walk(rig: CutRig, vel: Vector2, ticks: int) -> void:
	for _k: int in ticks:
		rig.position += vel * SimClock.TICK_DT
		rig.vel_in = vel
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)


## Mean distance between the feet across the walk direction over a strafe's second second.
func _gauge(follow: float) -> float:
	var rig: CutRig = _rig(follow)
	_walk(rig, Vector2(64, 0), 60)
	var sum: float = 0.0
	for _k: int in 60:
		_walk(rig, Vector2(64, 0), 1)
		var a: Vector2 = rig.sides[0].foot_w
		var b: Vector2 = rig.sides[1].foot_w
		sum += absf((a - b).y) / rig.global_transform.get_scale().x
	return sum / 60.0
