extends GutTest
## n10 perf: while a whole-figure walker card hides the parts, a rig's legs and arms are not posed
## (CutRig.limbs_cold) but everything the card reads steps as before, and warm_limbs() poses them
## to where an always-posed rig has them.

const STEPS: int = 30

var _was: ViewMode = null


func before_each() -> void:
	_was = ViewMode.shared()
	ViewMode.select("top")


func after_each() -> void:
	ViewMode._shared = _was


func _rig() -> CutRig:
	var pool: RigPool = RigPool.new()
	add_child_autoqfree(pool)
	@warning_ignore("return_value_discarded")
	pool.prewarm(BodyPlan.Kind.PED, 1)
	var rig: CutRig = pool.acquire(BodyPlan.Kind.PED, RigVariant.crowd(0), Vector2(32, 32), 0.3)
	rig.actor_id = 7
	rig.vel_in = Vector2(70.0, 20.0)
	rig.face_to = 0.2
	return rig


func _card(rig: CutRig) -> void:
	var card: Sprite2D = Sprite2D.new()
	rig.head.add_child(card)
	card.set_meta(StreetWalkerCards.ON, "x_walk.png")
	rig.head_card = card


func _drive(rig: CutRig, steps: int) -> void:
	for _i: int in steps:
		rig.drive(SimClock.TICK_DT)


func _limbs(rig: CutRig) -> Array[Sprite2D]:
	var out: Array[Sprite2D] = []
	for s: int in 2:
		out.append_array([rig.sides[s].thigh, rig.sides[s].shin, rig.sides[s].foot])
		out.append_array([rig.sides[s].upper, rig.sides[s].fore])
	return out


func test_a_carded_rig_poses_no_limb_but_keeps_what_the_card_reads() -> void:
	var warm: CutRig = _rig()
	var cold: CutRig = _rig()
	_card(cold)
	var before: Transform2D = cold.sides[BodyPlan.L].thigh.transform
	var fore_before: Transform2D = cold.sides[BodyPlan.R].fore.transform
	_drive(warm, STEPS)
	_drive(cold, STEPS)
	assert_true(cold.limbs_cold, "a carded rig stays cold")
	assert_false(warm.limbs_cold)
	assert_eq(cold.sides[BodyPlan.L].thigh.transform, before, "no leg solve ran")
	assert_eq(cold.sides[BodyPlan.R].fore.transform, fore_before, "no arm solve ran")
	assert_eq(cold.phase, warm.phase, "the stride phase the card steps by")
	assert_eq(cold.facing, warm.facing)
	assert_eq(cold.head.transform, warm.head.transform, "the head pose the card's facing reads")
	assert_eq(cold.torso.transform, warm.torso.transform)
	for s: int in 2:
		assert_eq(cold.sides[s].foot_w, warm.sides[s].foot_w, "the planted feet still step")


func test_warm_limbs_poses_them_where_an_always_posed_rig_has_them() -> void:
	var warm: CutRig = _rig()
	var cold: CutRig = _rig()
	_card(cold)
	_drive(warm, STEPS)
	_drive(cold, STEPS)
	RigPose.warm_limbs(cold)
	assert_false(cold.limbs_cold)
	var a: Array[Sprite2D] = _limbs(warm)
	var b: Array[Sprite2D] = _limbs(cold)
	for i: int in a.size():
		assert_almost_eq(a[i].position, b[i].position, Vector2(3.0, 3.0), "part %d" % i)
		assert_almost_eq(a[i].rotation, b[i].rotation, 0.08, "part %d" % i)


func test_a_gone_card_warms_the_rig_on_the_next_step() -> void:
	var rig: CutRig = _rig()
	_card(rig)
	_drive(rig, 2)
	assert_true(rig.limbs_cold)
	rig.head_card.remove_meta(StreetWalkerCards.ON)
	_drive(rig, 1)
	assert_false(rig.limbs_cold, "no walker card: the limbs pose again")


func test_a_kill_cut_warms_a_cold_rig() -> void:
	var rig: CutRig = _rig()
	_card(rig)
	_drive(rig, 2)
	assert_true(rig.limbs_cold)
	var groups: Array[Node2D] = GibCut.cut(rig, false)
	assert_false(rig.limbs_cold, "the copies are posed")
	for g: Node2D in groups:
		g.free()


func test_a_view_change_keeps_a_walkers_halos_hidden() -> void:
	var rig: CutRig = _rig()
	_card(rig)
	RigBuild.on_view(rig, 0.1)
	assert_false(rig.halos.is_empty())
	for h: Sprite2D in rig.halos:
		assert_false(h.visible, "a card's hidden part keeps its rim hidden")
	rig.head_card.remove_meta(StreetWalkerCards.ON)
	RigBuild.on_view(rig, 0.1)
	for h: Sprite2D in rig.halos:
		assert_true(h.visible, "the parts draw again: their rims too")
