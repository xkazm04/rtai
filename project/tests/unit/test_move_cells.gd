extends GutTest


func test_plant_lasts_through_apex_and_landing_owns_the_last_third() -> void:
	var vault: PlayerVault = PlayerMotion.shipped().vault
	assert_true(vault.drawn_cells)
	for k: int in vault.ticks:
		vault.frame = k
		var landing: bool = k >= 12  # shipped 18-tick vault
		var pose: StringName = VaultView.vault_cell(vault)
		assert_eq(pose, &"vault_land" if landing else &"vault_plant")
		assert_eq(MoveCells.frame_of(pose, false), 1 if landing else 0)
		assert_eq(MoveCells.frame_of(pose, true), 5 if landing else 4)
	vault.drawn_cells = false
	assert_eq(VaultView.vault_cell(vault), &"")
	vault.drawn_cells = true
	vault.reset_tick()
	assert_eq(VaultView.vault_cell(vault), &"")


func test_only_in_cover_owns_a_drawn_pose_at_either_height() -> void:
	var cover: PlayerCover = PlayerMotion.shipped().cover
	assert_true(cover.drawn_cells)
	assert_eq(CoverView.cover_cell(cover), &"")
	cover.spot = CoverQuery.CoverSpot.new()
	for state: PlayerCover.Phase in PlayerCover.Phase.values():
		cover.phase = state
		for low: bool in [false, true]:
			cover.spot.low = low
			var pose: StringName = CoverView.cover_cell(cover)
			if state != PlayerCover.Phase.IN:
				assert_eq(pose, &"")
				continue
			assert_eq(pose, &"cover_low" if low else &"cover_high")
			assert_eq(MoveCells.frame_of(pose, false), 2 if low else 3)
			assert_eq(MoveCells.frame_of(pose, true), 6 if low else 7)
	cover.phase = PlayerCover.Phase.IN
	cover.drawn_cells = false
	assert_eq(CoverView.cover_cell(cover), &"")


func test_missing_art_and_unlatched_motion_keep_the_original_strip() -> void:
	var rig: Node2D = autofree(Node2D.new())
	assert_eq(MoveCells.path_or(rig, "p70", "original"), "original")
	assert_eq(MotionRigPose.strip_for(&"cover_high", ""), "")
	assert_eq(MotionRigPose.strip_for(&"cover_high", "missing"), "")
	assert_eq(MotionRigPose.strip_for(&"", "p70"), "")
	for art: String in ["p55", "p70"]:
		var base: String = RivetStrips.DIR + art + "/" + RivetStrips.BASE
		var file: String = "rivet_moves_x15.png" if RivetRes.of(base) > 1.0 else "rivet_moves.png"
		var expected: String = MoveCells.DIR + art + "/" + file
		var state: MoveCells = MoveCells.new()
		state.art = art
		state.path = MotionRigPose.strip_for(&"cover_high", art)
		rig.set_meta(MoveCells.ACTIVE, state)
		assert_eq(MoveCells.path_or(rig, art, base), expected)
		assert_eq(MoveCells.path_or(rig, "missing", base), base)
		assert_eq(MoveCells.path_or(rig, art, ""), "")
		assert_not_null(load(expected))
		assert_true(ResourceLoader.exists(MoveCells.DIR + art + "/rivet_moves_x15.png"))


func test_switching_the_data_flag_restores_the_same_rig_on_the_next_feed() -> void:
	var old_view: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = RivetPlan.build()
	@warning_ignore("return_value_discarded")
	rigs.feed.put(0, 17, BodyPlan.Kind.RIVET, Vector2.ZERO, Vector2.LEFT)
	rigs._by_actor[17] = rig
	rigs.feed.face[0] = PI
	var vault: PlayerVault = PlayerMotion.shipped().vault
	vault.frame = 0
	MotionRigPose.publish(rigs, MoveCells.VAULT, VaultView.vault_cell(vault))
	var selected: MoveCells = rig.get_meta(MoveCells.ACTIVE)
	assert_eq(selected.frame, 4, "drawn left plant")
	MotionRigPose.publish(rigs, MoveCells.COVER, &"")
	assert_ne(MoveCells.path_or(rig, "p70", "roll"), "roll")
	vault.drawn_cells = false
	MotionRigPose.publish(rigs, MoveCells.VAULT, VaultView.vault_cell(vault))
	assert_eq(MoveCells.path_or(rig, "p70", "roll"), "roll")
	var cover: PlayerCover = PlayerMotion.shipped().cover
	cover.spot = CoverQuery.CoverSpot.new()
	cover.phase = PlayerCover.Phase.IN
	MotionRigPose.publish(rigs, MoveCells.COVER, CoverView.cover_cell(cover))
	selected = rig.get_meta(MoveCells.ACTIVE)
	assert_eq(selected.frame, 7, "drawn left high cover")
	cover.drawn_cells = false
	MotionRigPose.publish(rigs, MoveCells.COVER, CoverView.cover_cell(cover))
	assert_eq(MoveCells.path_or(rig, "p70", "standing"), "standing")
	rigs.rest.free()
	rigs.pool().free()
	ViewMode._shared = old_view


func test_both_native_resolutions_seat_the_same_frame_at_the_same_height() -> void:
	var rig: Node2D = add_child_autofree(Node2D.new())
	rig.position = Vector2(17, 29)
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	card.centered = false
	card.hframes = 8
	var selected: MoveCells = MoveCells.new()
	rig.set_meta(MoveCells.ACTIVE, selected)
	for density: float in [1.0, 1.5]:
		selected.resolution = density
		selected.foot_y = (RivetFrames.FIG_PX + RivetFrames.PAD_PX) * density
		selected.frame = MoveCells.frame_of(&"cover_high", true)
		card.texture = load(MoveCells.strip("p70", density)) as Texture2D
		assert_true(MoveCells.draw(rig, card, 0.75))
		assert_eq(card.frame, 7)
		assert_false(card.flip_h)
		assert_eq(card.global_position, rig.global_position)
		assert_almost_eq(card.offset.y * card.global_scale.y, -84.0, 0.0001)


func test_the_gait_samples_each_vault_step_before_recovery() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.plan = RivetPlan.build()
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	rig.head_card = card
	card.hframes = 8
	var selected: MoveCells = MoveCells.new()
	selected.art = "p70"
	selected.owner = MoveCells.VAULT
	selected.path = MotionRigPose.strip_for(&"vault_plant", selected.art)
	selected.resolution = RivetRes.of(RivetStrips.DIR + "p70/" + RivetStrips.BASE)
	rig.set_meta(MoveCells.ACTIVE, selected)
	card.texture = load(selected.path) as Texture2D
	for x: int in [10, 23, 41]:
		rig.position.x = x
		assert_true(MotionRigPose.draw(rig, 0.5))
		var sampled: Vector2 = rig.get_meta(RivetWalk.META_AT, Vector2.ZERO)
		assert_eq(sampled, rig.position)
