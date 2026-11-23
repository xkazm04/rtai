extends GutTest
## n11 hero: a bare-claw strike plays the drawn eight-direction grid (the owner's "melee attack
## follows always only one direction").


func after_each() -> void:
	RivetSwipe.enabled = true


func _rig(o: int, weapon: StringName = &"") -> CutRig:
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
	rig.set_meta(RivetFrames.WEAPON, weapon)
	rig.clips.strike_t = 0.05
	rig.clips.strike_ph = Vector3(0.1, 0.05, 0.1)
	return rig


func _grid_path() -> String:
	return RivetStrips.DIR + "p70/" + RivetStrike.STRIP


func test_the_grid_ships_with_a_whole_number_of_cells() -> void:
	for art: String in ["p70", "p55"]:
		var tex: Texture2D = load(RivetStrips.DIR + art + "/" + RivetStrike.STRIP) as Texture2D
		assert_not_null(tex, art)
		assert_eq(tex.get_width() % RivetStrike.COLS, 0, art)
		assert_eq(tex.get_height() % RivetStrike.ROWS, 0, art)


func test_native_grid_preserves_draw_size_and_boot_line() -> void:
	var was: ViewMode = ViewMode._shared
	for view: String in ["tilt70", "tilt"]:
		ViewMode._shared = ViewMode.of(view)
		var art: String = ViewMode.shared().art
		var rig: CutRig = _rig(0)
		var card: Sprite2D = rig.head_card
		var path: String = RivetStrips.DIR + art + "/" + RivetStrike.STRIP
		card.texture = load(path) as Texture2D
		card.set_meta(RivetFrames.ON, path)
		assert_true(RivetStrike.placed(rig, card, 1.0, 110.0))
		var cell: Vector2 = card.texture.get_size() / Vector2(card.hframes, card.vframes)
		var old: Vector2 = Vector2(163, 154) if art == "p70" else Vector2(170, 139)
		assert_almost_eq(cell, old * 1.5, Vector2.ONE * 0.51)
		assert_almost_eq(cell * card.global_scale, old, Vector2.ONE * 0.34)
		assert_eq(card.offset.x + cell.x * 0.5, 0.0, "collar axis on the rig origin")
		assert_eq(card.global_position, rig.global_position)
		var boot: float = (cell.y + card.offset.y) * card.global_scale.y
		assert_almost_eq(boot, 26.0 if art == "p70" else 14.0, 0.001)
	ViewMode._shared = was


func test_the_sim_keeps_the_base_radius_and_claw_reach() -> void:
	assert_eq(BodyTable.load_default().radius(&"rivet_base"), 0.42)
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(1).stream(&"combat")
	)
	assert_eq(arena.rivet.radius_m, 0.6)
	var claw: MeleeTable = MeleeTable.shipped()
	assert_eq(claw.hits[0].reach_m, 1.4)
	assert_eq(claw.hits.size(), 1)
	claw.single_swing = false
	assert_eq(claw.hits[1].reach_m, 1.4)
	assert_eq(claw.hits[2].reach_m, 1.6)


func test_a_bare_claw_strike_takes_the_grid() -> void:
	assert_eq(RivetStrike.path_or(_rig(0), "p70", &"", "x.png"), _grid_path())


func test_a_weapon_keeps_its_own_strip() -> void:
	assert_eq(RivetStrike.path_or(_rig(0, &"pistol"), "p70", &"pistol", "x.png"), "x.png")


func test_no_strike_and_a_roll_keep_the_strip() -> void:
	var idle: CutRig = _rig(0)
	idle.clips.strike_t = -1.0
	assert_eq(RivetStrike.path_or(idle, "p70", &"", "x.png"), "x.png")
	var rolling: CutRig = _rig(0)
	rolling.clips.roll(0.3)
	assert_eq(RivetStrike.path_or(rolling, "p70", &"", "x.png"), "x.png")


func test_the_old_flag_keeps_the_strip() -> void:
	RivetSwipe.enabled = false
	assert_eq(RivetStrike.path_or(_rig(0), "p70", &"", "x.png"), "x.png")


func test_the_column_steps_through_the_phases() -> void:
	var clips: RigClips = RigClips.new()
	clips.strike_ph = Vector3(0.1, 0.05, 0.1)
	clips.strike_t = 0.05
	assert_eq(RivetStrike.col_of(clips), 0, "wind-up")
	clips.strike_t = 0.12
	assert_eq(RivetStrike.col_of(clips), 1, "strike")
	clips.strike_t = 0.2
	assert_eq(RivetStrike.col_of(clips), 2, "follow-through")


func test_the_punch_clip_has_all_three_columns() -> void:
	var clips: RigClips = RigClips.new()
	clips.punch(1)
	assert_eq(RivetStrike.col_of(clips), 0, "just begun")
	clips.punch_t = clips.punch_len * 0.5
	assert_eq(RivetStrike.col_of(clips), 1, "mid clip")
	clips.punch_t = clips.punch_len * 0.1
	assert_eq(RivetStrike.col_of(clips), 2, "last tenth")


func test_every_octant_draws_its_own_row_unmirrored() -> void:
	var seen: Dictionary[int, bool] = {}
	for o: int in 8:
		var rig: CutRig = _rig(o)
		rig.head_card.texture = load(_grid_path()) as Texture2D
		rig.head_card.set_meta(RivetFrames.ON, _grid_path())
		assert_true(RivetStrike.placed(rig, rig.head_card, 1.0, 100.0), "octant %d placed" % o)
		assert_false(rig.head_card.flip_h, "octant %d is drawn, never mirrored" % o)
		seen[rig.head_card.frame] = true
		assert_eq(rig.head_card.frame / RivetStrike.COLS, RivetFrames.BASE_OCT[o], "octant %d" % o)
	assert_eq(seen.size(), 8, "eight different rows")


func test_any_other_strip_is_left_to_the_caller() -> void:
	var rig: CutRig = _rig(0)
	rig.head_card.set_meta(RivetFrames.ON, "res://x/rivet_frames.png")
	assert_false(RivetStrike.placed(rig, rig.head_card, 1.0, 100.0))


func test_the_grid_asks_for_the_arc_in_every_octant() -> void:
	for o: int in 8:
		var rig: CutRig = _rig(o)
		rig.head_card.set_meta(RivetFrames.ON, _grid_path())
		assert_true(RivetSwipe.needs_arc(rig, o), "octant %d" % o)
