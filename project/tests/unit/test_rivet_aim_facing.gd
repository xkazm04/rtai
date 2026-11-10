extends GutTest
## n11 hero (the owner's "direction of player should follow cursor"): the drawn octant reads the
## look the feed hands the rig, without the facing spring's lag, and a held boundary does not flip;
## the sim heading is the aim even in a sprint; the mouse aim leaves from gun height.


func _rig(look: float) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.head = Node2D.new()
	rig.add_child(rig.head)
	rig.face_to = look
	return rig


func test_the_drawn_octant_is_the_look_not_the_spring() -> void:
	var rig: CutRig = _rig(PI * 0.5)  # the spring's head still points the old way
	rig.head.rotation = 0.0
	assert_eq(RivetFrames.oct_of(rig), 2)


func test_a_look_resting_on_a_boundary_keeps_its_octant() -> void:
	var rig: CutRig = _rig(deg_to_rad(20.0))
	assert_eq(RivetFrames.oct_of(rig), 0)
	rig.face_to = deg_to_rad(25.0)  # past the 22.5 boundary, inside the hold
	assert_eq(RivetFrames.oct_of(rig), 0, "held")
	rig.face_to = deg_to_rad(29.0)  # past the hold
	assert_eq(RivetFrames.oct_of(rig), 1)
	rig.face_to = deg_to_rad(20.0)  # and back inside the new octant's hold
	assert_eq(RivetFrames.oct_of(rig), 1, "held the other way")


func test_a_sprint_faces_the_aim_not_the_walk() -> void:
	var m: PlayerMotion = PlayerMotion.new()
	m.mover.facing = Vector2.RIGHT
	assert_almost_eq(m.heading(Vector2.DOWN).angle(), PI * 0.5, 0.001)


func test_a_roll_and_a_released_aim_keep_the_turned_facing() -> void:
	var m: PlayerMotion = PlayerMotion.new()
	m.mover.facing = Vector2.RIGHT
	assert_almost_eq(m.heading(Vector2.ZERO).angle(), 0.0, 0.001, "no aim: the walk")
	m.phase = PlayerMotion.Phase.ROLL
	assert_almost_eq(m.heading(Vector2.DOWN).angle(), 0.0, 0.001, "a roll faces its roll")


func test_the_aim_leaves_from_gun_height_under_a_tilt() -> void:
	var was: String = String(ViewMode.shared().id)
	ViewMode.select("combo")
	var up: Vector2 = LiveInput.aim_lift_px(64.0)
	assert_lt(up.y, -1.0, "under the combo tilt the aim origin rises")
	assert_almost_eq(up.x, 0.0, 0.001)
	ViewMode.select("top")
	assert_eq(LiveInput.aim_lift_px(64.0), Vector2.ZERO, "straight down: the feet")
	ViewMode.select(was)
