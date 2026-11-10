extends GutTest
## n11 hero (the owner's "melee attack follows always only one direction"): a strike only draws its
## one baked cell where that art points the aim's way; elsewhere the game's arc goes along the aim.


func after_each() -> void:
	RivetSwipe.enabled = true


func _rig(o: int, weapon: StringName) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.plan = RivetPlan.build()
	for n: StringName in [&"head", &"body"]:
		var node: Node2D = Node2D.new()
		rig.add_child(node)
		rig.set(n, node)
	var card: Sprite2D = Sprite2D.new()
	rig.head.add_child(card)
	rig.head_card = card
	rig.head.rotation = o * PI * 0.25
	rig.face_to = o * PI * 0.25
	rig.gun_out = weapon != &""
	rig.aiming = weapon != &""
	rig.set_meta(RivetFrames.WEAPON, weapon)
	rig.clips.strike_t = 0.05
	rig.clips.strike_ph = Vector3(0.1, 0.05, 0.1)
	return rig


func test_the_claw_cell_is_only_for_the_octants_it_is_drawn_for() -> void:
	for o: int in 8:
		var cell: Vector2i = RivetFrames.cell_of(_rig(o, &""), RivetFrames.BASE_CELLS)
		var want: int = RivetFrames.Cell.CLAW if o in [1, 2, 3] else RivetFrames.BASE_OCT[o]
		assert_eq(cell.x, want, "octant %d" % o)


func test_a_blade_draws_its_strike_cell_along_the_side_and_camera_only() -> void:
	for o: int in 8:
		var rig: CutRig = _rig(o, &"katana")
		var cell: Vector2i = RivetFrames.cell_of(rig, RivetFrames.EQ_CELLS)
		if o in [0, 2, 4]:
			assert_true(
				cell.x in [RivetFrames.Eq.FIRE_SIDE, RivetFrames.Eq.FIRE_CAM], "octant %d fires" % o
			)
		else:
			assert_false(
				cell.x in [RivetFrames.Eq.FIRE_SIDE, RivetFrames.Eq.FIRE_CAM], "octant %d faces" % o
			)


func test_off_is_the_old_single_cell_everywhere() -> void:
	RivetSwipe.enabled = false
	for o: int in 8:
		var cell: Vector2i = RivetFrames.cell_of(_rig(o, &""), RivetFrames.BASE_CELLS)
		assert_eq(cell.x, RivetFrames.Cell.CLAW, "octant %d" % o)


func test_an_arc_is_only_asked_for_where_no_cell_shows_one() -> void:
	var rig: CutRig = _rig(6, &"")
	assert_false(RivetSwipe.needs_arc(rig, 6), "no drawn card yet")
	var away: CutRig = _rig(6, &"")
	away.head_card.set_meta(RivetFrames.ON, "res://x.png")
	assert_true(RivetSwipe.needs_arc(away, 6))
	assert_false(RivetSwipe.needs_arc(away, 2), "toward: the cell draws its own")
	away.clips.strike_t = -1.0
	assert_false(RivetSwipe.needs_arc(away, 6), "no strike")
