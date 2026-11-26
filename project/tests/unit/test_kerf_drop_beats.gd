extends GutTest
## n31 ghost 21: Kerf's drop deploy beats (KerfDropBeats): HOVER P..P+3, COCK in the wind-up
## pulled back from the live target, CUT/RECOVER at the rear spot from C, the sighting line.

var ghost: GhostDeploy
var foe: Fighter


func before_each() -> void:
	ghost = GhostDeploy.new(GhostAttacks.shipped(), null)
	ghost.form = KerfStage.GHOST
	ghost.origin = Vector2(0.0, -0.5)
	ghost.spot = Vector2(5.0, 1.0)
	ghost.facing = Vector2.RIGHT
	foe = Fighter.new()
	foe.pos = Vector2(6.0, -0.5)
	ghost.dump.kerf.target = foe


func test_poses_per_beat() -> void:
	assert_eq(KerfDropBeats.pose(0, -12), KerfRoninDrawn.Pose.HOVER, "arrival")
	assert_eq(KerfDropBeats.pose(3, -9), KerfRoninDrawn.Pose.HOVER)
	assert_eq(KerfDropBeats.pose(4, -8), KerfRoninDrawn.Pose.COCK, "the wind-up aims")
	assert_eq(KerfDropBeats.pose(11, -1), KerfRoninDrawn.Pose.COCK)
	assert_eq(KerfDropBeats.pose(12, 0), KerfRoninDrawn.Pose.CUT, "the cut on C")
	assert_eq(KerfDropBeats.pose(19, 7), KerfRoninDrawn.Pose.CUT)
	assert_eq(KerfDropBeats.pose(20, 8), KerfRoninDrawn.Pose.RECOVER)
	assert_eq(KerfDropBeats.pose(28, 16), KerfRoninDrawn.Pose.HOVER, "stands to the fade")
	assert_eq(
		KerfDropBeats.cell(false, 30, 18, -1), KerfRoninDrawn.Pose.HOVER, "hold: before its strike"
	)
	assert_eq(KerfDropBeats.cell(false, 30, 18, 2), KerfRoninDrawn.Pose.CUT, "hold: its strike age")


func test_wind_up_pulls_back_from_the_live_target_then_stands_at_the_rear() -> void:
	assert_eq(KerfDropBeats.at(ghost, 0, -12), ghost.origin, "arrives on the origin")
	var back: Vector2 = KerfDropBeats.at(ghost, 10, -2)
	assert_almost_eq(back, ghost.origin + Vector2.LEFT * KerfDropBeats.RECOIL_M, Vector2.ONE * 1e-4)
	foe.pos = Vector2(0.0, 5.5)  # the lock follows: the recoil turns with it
	back = KerfDropBeats.at(ghost, 10, -2)
	assert_almost_eq(back, ghost.origin + Vector2.UP * KerfDropBeats.RECOIL_M, Vector2.ONE * 1e-4)
	assert_almost_eq(KerfDropBeats.yaw(ghost, -2), PI * 0.5, 1e-4, "faces the target")
	assert_eq(KerfDropBeats.at(ghost, 12, 0), ghost.spot, "blinked to the rear on C")
	assert_eq(KerfDropBeats.yaw(ghost, 0), ghost.facing.angle())


func test_sighting_line_grows_to_full_by_c_minus_3_and_is_gone_on_c() -> void:
	assert_eq(KerfDropBeats.sight_k(0, 12), 0.0)
	assert_gt(KerfDropBeats.sight_k(4, 12), 0.5, "ease-out: most of it early")
	assert_eq(KerfDropBeats.sight_k(9, 12), 1.0)
	assert_eq(KerfDropBeats.sight_k(11, 12), 1.0)
	assert_eq(KerfDropBeats.sight_k(12, 12), 0.0)
