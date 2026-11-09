extends GutTest
## n10 rivet: a one-hander fired 45-67 deg (octant 1) draws the camera fire cell, whose gun is
## within GUN_TOL of the aim, instead of the 3/4 facing whose gun is at image left with no muzzle.

const ONE_HANDERS: Array[StringName] = [
	&"pistol", &"machine_pistol", &"hand_cannon", &"ray_gun", &"homing_shard"
]

var _was: ViewMode = null


func before_each() -> void:
	_was = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	RivetFireCam.on = true


func after_each() -> void:
	ViewMode._shared = _was
	RivetFireCam.on = true
	HeldMuzzle.reset()


## A drawn p70 Rivet firing `weapon` with the aim and the look at `deg`, posed once.
func _firing(deg: float, weapon: StringName) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.plan = RivetPlan.build()
	for n: StringName in [&"head", &"body"]:
		var node: Node2D = Node2D.new()
		rig.add_child(node)
		rig.set(n, node)
	var card: Sprite2D = Sprite2D.new()
	rig.head.add_child(card)
	rig.head_card = card
	rig.head.rotation = deg_to_rad(deg)
	rig.gun_out = true
	rig.aiming = true
	rig.aim_at = rig.global_position + Vector2.from_angle(deg_to_rad(deg)) * 128.0
	rig.set_meta(RivetFrames.WEAPON, weapon)
	rig.set_meta(RivetFrames.FIRE, true)
	RivetFrames.step(rig)
	return rig


func _aim(rig: CutRig, deg: float) -> void:
	rig.aim_at = rig.global_position + Vector2.from_angle(deg_to_rad(deg)) * 128.0


func test_a_steep_shot_draws_the_camera_cell_for_every_one_hander() -> void:
	for w: StringName in ONE_HANDERS:
		var rig: CutRig = _firing(60.0, w)
		assert_eq(rig.head_card.frame, RivetFrames.Eq.FIRE_CAM, "%s at 60 deg" % w)
		assert_false(rig.head_card.flip_h, "the camera cell is not mirrored at octant 1")
		RivetMuzzle.publish(rig)
		assert_true(HeldMuzzle.fresh(), "%s: the flash is on the drawn gun" % w)
		HeldMuzzle.reset()


func test_the_old_facing_cell_is_one_flag_away() -> void:
	RivetFireCam.on = false
	var rig: CutRig = _firing(60.0, &"pistol")
	assert_eq(rig.head_card.frame, 1, "the facing cell of the before")


func test_a_shallow_shot_keeps_the_side_cell() -> void:
	assert_eq(_firing(30.0, &"pistol").head_card.frame, RivetFrames.Eq.FIRE_SIDE)


func test_a_gun_with_a_facing_muzzle_is_untouched() -> void:
	var rig: CutRig = _firing(60.0, &"gloria")
	assert_eq(rig.head_card.frame, 1, "gloria's 3/4 facing draws its gun and has a muzzle point")


func test_a_burst_on_the_edge_keeps_its_cell() -> void:
	var rig: CutRig = _firing(44.9, &"pistol")
	assert_false(RivetFireCam.drawn(rig), "starts under 45: the side cell")
	_aim(rig, 45.3)
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true))
	assert_false(RivetFireCam.drawn(rig), "noise past 45 keeps it")
	_aim(rig, 52.0)
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true))
	assert_true(RivetFireCam.drawn(rig), "past the hold: the camera cell")
	_aim(rig, 44.0)
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true))
	assert_true(RivetFireCam.drawn(rig), "back under 45 keeps it inside the hold")
	_aim(rig, 38.0)
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true))
	assert_false(RivetFireCam.drawn(rig), "past the hold back: the side cell")
