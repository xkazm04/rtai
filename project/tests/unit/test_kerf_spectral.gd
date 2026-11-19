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
	rig.pose()
	assert_eq(body._lens.texture.resource_path.get_file(), "lens_half.png")
	@warning_ignore("return_value_discarded")
	k.powers.try_activate(KerfStage.ID)
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
