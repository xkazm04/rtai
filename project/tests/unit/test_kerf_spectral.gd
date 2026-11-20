extends GutTest


func after_each() -> void:
	GhostLook.reset_for_test()


func test_mood_boundaries_and_blink_priority() -> void:
	for charges: int in [0, 1, 3]:
		assert_eq(KerfSpectral.mood(0.0, -1, charges), KerfSpectral.Mood.POISED)
		assert_eq(KerfSpectral.mood(3.0, 8, charges), KerfSpectral.Mood.POISED)
		assert_eq(KerfSpectral.mood(3.01, 8, charges), KerfSpectral.Mood.CRUISE)
		assert_eq(KerfSpectral.mood(12.0, 0, charges), KerfSpectral.Mood.LUNGE)
		assert_eq(KerfSpectral.mood(0.0, 7, charges), KerfSpectral.Mood.LUNGE)


func test_each_charge_lights_one_beam_and_only_the_next_regrows() -> void:
	var beams: KerfBeams = autofree(KerfBeams.new())
	assert_eq(KerfBeams.COUNT, 3)
	for fast: float in [0.0, 1.0]:
		beams.fast = fast
		var full: float = 0.9 if fast == 0.0 else 3.2
		for charges: int in 4:
			beams.charges = charges
			for recharge: float in [0.0, 0.25, 0.75]:
				beams.recharge = recharge
				for i: int in 3:
					var k: float = 1.0 if i < charges else (recharge if i == charges else 0.0)
					assert_almost_eq(beams.length_m(i), full * k, 0.0001)


func test_legacy_and_spectral_build_only_their_own_bodies() -> void:
	GhostLook.override_for_test(&"legacy")
	var legacy: KerfRig = add_child_autofree(KerfRig.new())
	assert_eq(legacy._limbs.size(), 8)
	assert_not_null(legacy._hull)
	assert_null(legacy._spectral)
	GhostLook.override_for_test(&"spectral")
	var spectral: KerfRig = add_child_autofree(KerfRig.new())
	assert_not_null(spectral._spectral)
	assert_eq(spectral._limbs.size(), 0)
	assert_null(spectral._body)
	assert_null(spectral._card)
	assert_null(spectral._hull)
	assert_null(spectral._cables)


func test_stage_drives_the_eye_blink_and_regrowing_beam() -> void:
	var previous: String = ViewMode.shared().id
	ViewMode.select("top")
	GhostLook.override_for_test(&"spectral")
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 1))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	var k: KerfStage = stage.pilot.kerf
	var rig: KerfRig = KerfRig.new()
	rig.stage = stage
	add_child_autofree(rig)
	var body: KerfSpectral = rig._spectral
	stage.arena.rivet.pos = Vector2(200, 200)
	assert_eq(k.recharge_k(), 0.0)
	assert_eq(body._lens.texture.resource_path.get_file(), "lens_open.png")
	var guard: Fighter = stage.arena.spawn_guard(stage.arena.rivet.pos)
	guard.pos = stage.arena.rivet.pos + Vector2.RIGHT * 3.0
	k.sight_aim = Vector2.RIGHT
	stage.pilot.ghosts.forms.from_id = KerfStage.GHOST
	stage.pilot.ghosts.forms.to_id = KerfStage.GHOST
	@warning_ignore("return_value_discarded")
	k.powers.try_activate(KerfStage.ID)
	rig.pose()
	assert_eq(body._lens.texture.resource_path.get_file(), "lens_half.png")
	@warning_ignore("return_value_discarded")
	k.drive(stage, false, true, Vector2.RIGHT, Vector2.ZERO)
	rig.pose()
	assert_eq(body.beams.charges, 2)
	assert_eq(body._lens.texture.resource_path.get_file(), "lens_slit.png")
	for i: int in 8:
		stage.tick += 1
		@warning_ignore("return_value_discarded")
		k.drive(stage, false, false, Vector2.RIGHT, Vector2.ZERO)
	rig.pose()
	var fraction: float = 8.0 / PowerDef.ticks(k.num(&"recharge_s"))
	assert_almost_eq(body.beams.length_m(2), 0.9 * fraction, 0.0001)
	ViewMode.select(previous)


func test_pitch_changes_keep_the_hover_grid_centred_and_the_left_profile_mirrored() -> void:
	var previous: String = ViewMode.shared().id
	var body: KerfSpectral = add_child_autofree(KerfSpectral.new(KerfRig.HULL_M * 1.1))
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		body.pose(12.0, -1, false, PI, 4)
		var sprite: Sprite2D = body._tilted
		assert_same(sprite.get_parent(), body)
		var sx: float = SimConst.PX_PER_M / (165.0 / 1.8)
		assert_almost_eq(
			sprite.global_scale,
			Vector2(sx, sx / ViewMode.shared().ground_k()),
			Vector2.ONE * 0.0001
		)
		assert_true(sprite.visible)
		assert_false(body._top.visible)
		assert_eq(sprite.hframes, 3)
		assert_eq(sprite.vframes, 5)
		assert_eq(sprite.frame_coords, Vector2i(1, 2))
		assert_true(sprite.flip_h)
		assert_true(sprite.centered)
		assert_eq(sprite.offset, Vector2.ZERO)
		assert_true(sprite.texture.resource_path.contains("/%s/" % ViewMode.shared().art))
		body.pose(12.0, 0, false, 0.0, 0)
		assert_eq(sprite.frame_coords, Vector2i(2, 2))
		assert_false(sprite.flip_h)
	ViewMode.select("top")
	body.pose(12.0, -1, false, 0.0, 0)
	assert_false(body._tilted.visible)
	assert_true(body._top.visible)
	assert_almost_eq(body._top.scale, Vector2(1.08, 0.86), Vector2.ONE * 0.0001)
	assert_eq(body._lens.texture.resource_path.get_file(), "lens_half.png")
	body.beams.charges = 0
	body.pose(0.0, -1, false, 0.0, 0)
	assert_eq(body._lens.texture.resource_path.get_file(), "lens_slit.png")
	ViewMode.select(previous)


func test_plate_mounts_scale_and_tail_follow_the_body() -> void:
	var previous: String = ViewMode.shared().id
	ViewMode.select("top")
	var hull_m: float = 1.5
	var body: KerfSpectral = add_child_autofree(KerfSpectral.new(hull_m))
	body.scale = Vector2.ONE * 1.4
	body.position = Vector2(123, 67)
	body.pose(6.0, -1, false, 0.43, 0)
	assert_same(body._top.get_parent(), body)
	assert_same(body.beams.get_parent(), body)
	assert_eq(body._top.get_child_count(), 5)
	var hull: Sprite2D = body._top.get_child(0)
	assert_eq(hull.texture.resource_path.get_file(), "hull.png")
	assert_almost_eq(hull.scale.x * hull.texture.get_width(), hull_m * 32, 0.0001)
	assert_same(body._top.get_child(1), body._arch)
	assert_almost_eq(body._arch.rotation, -PI / 2, 0.0001)
	assert_almost_eq(body._arch.position, Vector2(-6.4, 0), Vector2.ONE * 0.0001)
	assert_same(body._top.get_child(4), body._lens)
	assert_almost_eq(
		body._lens.position, Vector2(93.5, -2.5) * hull_m * 32 / 375, Vector2.ONE * 0.0001
	)
	assert_almost_eq(
		body._lens.scale.x * body._lens.texture.get_width(), hull_m * 32 * 62 / 375, 0.0001
	)
	for arm: Sprite2D in body._arms:
		assert_same(arm.get_parent(), body._top)
		assert_almost_eq(arm.offset.x / arm.texture.get_width(), 0.42, 0.0001)
	assert_almost_eq(body.beams.tail_x, -0.55 * 32 * 1.4, 0.0001)
	assert_almost_eq(body.beams.global_rotation, 0.43, 0.0001)
	assert_eq(body.beams.global_position, body.position)
	assert_almost_eq(body.beams.length_m(2), 2.05, 0.0001)
	ViewMode.select(previous)


func test_arch_and_needles_ease_over_four_distinct_ticks_and_snap_to_lunge() -> void:
	var body: KerfSpectral = add_child_autofree(KerfSpectral.new(1.5))
	for tick: int in 5:
		body.beams.tick = tick
		var speed: float = 0.0 if tick == 0 else 12.0
		body.pose(speed, -1, false, 0.0, 0)
		body.pose(speed, -1, false, 0.0, 0)
		_assert_fold(body, float(tick) / 4.0)
	for tick: int in range(5, 9):
		body.beams.tick = tick
		body.pose(0.0, -1, false, 0.0, 0)
		_assert_fold(body, float(8 - tick) / 4.0)
	body.pose(0.0, 0, false, 0.0, 0)
	_assert_fold(body, 1.0)


func _assert_fold(body: KerfSpectral, tuck: float) -> void:
	var base: float = 0.62 * 32.0 / body._arch.texture.get_height()
	var want: Vector2 = Vector2(lerpf(1, 0.9, tuck), lerpf(1.15, 0.85, tuck))
	assert_almost_eq(body._arch.scale / base, want, Vector2.ONE * 0.0001)
	for i: int in 2:
		var tip: Vector2 = Vector2.RIGHT.rotated(body._arms[i].rotation)
		var spread: float = lerpf(14.0, 3.0, tuck) * (1 if i == 0 else -1)
		assert_almost_eq(tip, Vector2.LEFT.rotated(deg_to_rad(spread)), Vector2.ONE * 0.0001)
