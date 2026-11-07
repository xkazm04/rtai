extends GutTest


func test_the_cane_plants_ahead_and_slides_back_a_stride() -> void:
	var plant: float = 1.0 - OhmRig.SWING_K
	assert_almost_eq(OhmRig.cane_tip(0.0).x, OhmRig.CANE_AHEAD_M, 0.0001, "planted ahead")
	var back: float = OhmRig.cane_tip(plant - 0.0001).x
	assert_almost_eq(OhmRig.CANE_AHEAD_M - back, OhmRig.STRIDE_M, 0.001, "left a stride behind")


func test_the_swing_closes_the_cycle_without_a_jump() -> void:
	var end: Vector2 = OhmRig.cane_tip(0.9999)
	assert_almost_eq(end.x, OhmRig.cane_tip(0.0).x, 0.001, "the swing lands where the cycle starts")
	var prev: float = OhmRig.cane_tip(0.0).x
	for i: int in range(1, 200):
		var x: float = OhmRig.cane_tip(float(i) / 200.0).x
		assert_lt(absf(x - prev), 0.06, "no jump at step %d" % i)
		prev = x


func test_the_gait_advances_with_ground_not_time() -> void:
	var rig: OhmRig = OhmRig.new()
	add_child_autofree(rig)
	rig.speed_mps = 0.0
	rig.advance(1.0)
	assert_eq(rig.phase, 0.0, "standing still: the cane stays planted")
	rig.speed_mps = OhmRig.STRIDE_M
	rig.advance(0.5)
	assert_almost_eq(rig.phase, 0.5, 0.0001, "half a stride of ground, half a cycle")


func test_a_bolt_kicks_the_guard_arm_and_holds_the_cane_then_settles() -> void:
	var rig: OhmRig = OhmRig.new()
	add_child_autofree(rig)
	rig.speed_mps = OhmRig.STRIDE_M
	rig.advance(SimClock.TICK_DT)  # the first sight arms the counter
	assert_eq(rig.kick_m(), 0.0, "no kick before a bolt")
	rig.bolts = 1
	rig.advance(SimClock.TICK_DT)
	var held: float = rig.phase
	rig.advance(SimClock.TICK_DT * 2.0)
	assert_gt(rig.kick_m(), OhmRig.KICK_M * 0.5, "the hand is thrown out")
	assert_eq(rig.phase, held, "the cane stays planted through the kick")
	rig.advance(OhmRig.KICK_S)
	assert_eq(rig.kick_m(), 0.0, "and settles inside KICK_S")
	rig.advance(SimClock.TICK_DT)
	assert_gt(rig.phase, held, "the cane walks on")


func test_reduced_motion_halves_the_kick() -> void:
	var full: OhmRig = OhmRig.new()
	var calm: OhmRig = OhmRig.new()
	calm.reduced_motion = true
	for rig: OhmRig in [full, calm]:
		add_child_autofree(rig)
		rig.advance(SimClock.TICK_DT)
		rig.bolts = 1
		rig.advance(SimClock.TICK_DT * 3.0)
	assert_almost_eq(calm.kick_m(), full.kick_m() * 0.5, 0.0001, "halved")


func test_the_shell_carries_the_teal_soul_seams_and_lenses() -> void:
	var rig: OhmRig = OhmRig.new()
	add_child_autofree(rig)
	var seams: Array[Node] = rig.find_children("*", "OhmSeams", true, false)
	assert_eq(seams.size(), 1, "one seam overlay, on the shell")
	var s: OhmSeams = seams[0] as OhmSeams
	assert_true(s.get_parent() is Sprite2D, "a child of the shell: it turns and kicks with it")
	assert_true(s.visible, "shown without the dev flag --no-seams")
	assert_eq(s.GOGGLES.size(), 2, "two lenses")


func test_under_tilt_ohm_draws_its_card_over_the_shell_and_keeps_the_arms() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt")
	var rig: OhmRig = OhmRig.new()
	add_child_autofree(rig)
	rig.pose()
	var want: bool = ResourceLoader.exists(GhostCard.path_of(ViewMode.of("tilt").art, "ohm"))
	assert_eq(rig._card.is_drawn(), want, "a card iff the view's strip exists")
	for p: Sprite2D in rig._hide:
		assert_eq(p.visible, not want, "shell, beard and hose hide under the card")
	for a: Sprite2D in rig._arms:
		assert_true(a.visible, "the cane and guard arms stay rig parts")
	ViewMode._shared = ViewMode.of("top")
	rig.pose()
	assert_false(rig._card.is_drawn(), "straight down: no card")
	for p: Sprite2D in rig._hide:
		assert_true(p.visible)
	ViewMode._shared = saved
