extends GutTest

var _previous_view: StringName
var _stage: CollectCallStage
var _rig: KerfRig


func before_each() -> void:
	_previous_view = ViewMode.shared().id
	GhostLook.override_for_test(&"spectral")
	_stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage.setup(World.build_context(bus, data, 1))
	_stage.pilot = StagePilot.new(PlayerActions.shipped())
	_rig = KerfRig.new()
	_rig.stage = _stage
	_rig.position = Vector2(133, 27)
	add_child_autofree(_rig)


func after_each() -> void:
	ViewMode.select(_previous_view)
	GhostLook.reset_for_test()


func test_blow_tips_both_views_in_screen_space_and_flashes_the_rim() -> void:
	var body: KerfSpectral = _rig._spectral
	_stage.arena.tick = 40
	_stage.arena.hit_dir = Vector2.RIGHT
	_stage.arena.damage(_stage.arena.rivet, 0.5, 1, &"rifle")
	for view: String in ["top", "tilt70", "tilt"]:
		ViewMode.select(view)
		var flat: bool = ViewMode.shared().is_flat()
		var sprite: Node2D = body._top if flat else body._tilted
		var projection: Vector2 = Vector2(1.0, ViewMode.shared().ground_k())
		for age: int in [-1, 0, 3, 5, 6, 8, 10, 15]:
			_stage.arena.tick = 40 + age
			_rig.pose()
			_rig.pose()  # Hitstop can render the same tick twice.
			var k: float = 1.0 - age / 10.0
			var angle: float = deg_to_rad(12.0) * k * k if age >= 0 and age < 10 else 0.0
			assert_almost_eq((sprite.global_transform.x * projection).angle(), angle, 0.0001)
			assert_almost_eq(sprite.global_position, _rig.global_position, Vector2.ONE * 0.001)
			var hurt: bool = age >= 0 and age < 10
			assert_eq(body.current, KerfRoninDrawn.Pose.HIT if hurt else KerfRoninDrawn.Pose.HOVER)
			if flat:
				var head_m: float = 0.34 if hurt and age < 6 else 0.46
				assert_almost_eq(
					body._top._head.position.x,
					head_m * SimConst.PX_PER_M * KerfRoninDrawn.SIZE_K,
					0.001
				)
				assert_eq(body._top._crest.position, body._top._head.position)
			else:
				assert_eq(body._tilted.frame_coords.x, 3 if hurt else 0)
				assert_eq(body._tilted._rim.visible, hurt and age < 6)


func test_body_follows_unfold_in_both_directions() -> void:
	var body: KerfSpectral = _rig._spectral
	for k: float in [0.0, 0.25, 1.0, 0.5, 0.0]:
		_rig.unfold = k
		_rig.pose()
		assert_almost_eq(body.modulate.a, k, 0.0001)


func test_overhead_helmet_and_crest_meet_without_overlap_through_the_flinch() -> void:
	ViewMode.select("top")
	var top: KerfRoninTop = _rig._spectral._top
	var crest: AtlasTexture = top._crest.texture as AtlasTexture
	var helmet: AtlasTexture = top._head.texture as AtlasTexture
	assert_same(crest.atlas, helmet.atlas)
	assert_eq(crest.region.end.y, helmet.region.position.y)
	_stage.arena.tick = 40
	_stage.arena.hit_dir = Vector2.RIGHT
	_stage.arena.damage(_stage.arena.rivet, 0.5, 1, &"rifle")
	for age: int in [0, 3, 8, 15]:
		_stage.arena.tick = 40 + age
		_rig.pose()
		var seam: Vector2 = top._crest.offset + Vector2.DOWN * crest.region.size.y
		assert_true(
			top._crest.to_global(seam).is_equal_approx(top._head.to_global(top._head.offset))
		)


func test_a_blink_echo_disappears_on_the_first_frame_of_exit() -> void:
	var forms: GhostForms = _stage.pilot.ghosts.forms
	forms.selected = KerfStage.ID
	assert_eq(forms.press_transform(), SoulPowers.OK)
	for tick: int in forms.table.form(KerfStage.ID).enter_ticks:
		forms.tick()
	_rig.pose()
	_press(Vector2.DOWN)
	var echo: KerfEcho.Pose = _rig._spectral._echoes._pool[0]
	assert_true(echo.is_visible_in_tree())
	assert_eq(forms.press_transform(), SoulPowers.OK)
	_rig.pose()
	assert_false(echo.is_visible_in_tree(), "exit is drawn before queued nodes are freed")


func _press(dir: Vector2) -> void:
	var k: KerfStage = _stage.pilot.kerf
	@warning_ignore("return_value_discarded")
	k.powers.try_activate(KerfStage.ID)
	_stage.tick += 1
	@warning_ignore("return_value_discarded")
	k.drive(_stage, false, true, dir, Vector2.ZERO)
	_rig.position = _stage.arena.rivet.pos * SimConst.PX_PER_M
	_rig.rotation = _stage.arena.rivet.facing.angle()
	_rig.pose()


func test_cut_and_recovery_face_along_the_trail_in_all_three_views() -> void:
	var dir: Vector2 = Vector2(-1, -1).normalized()
	var victim: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos + dir * 5.0)
	victim.pos = _stage.arena.rivet.pos + dir * 5.0
	_press(dir)
	assert_false(victim.alive())
	assert_almost_eq(_stage.pilot.kerf.trail_radius[-1], victim.radius_m, 0.0001)
	assert_lt(_stage.arena.rivet.facing.dot(dir), -0.99)
	var body: KerfSpectral = _rig._spectral
	for age: int in [0, 7, 8, 15, 16]:
		_stage.tick = _stage.pilot.kerf.trail_tick[-1] + age
		for id: String in ["tilt70", "tilt", "top"]:
			ViewMode.select(id)
			_rig.pose()
			assert_eq(body.current, KerfSpectral.blink_pose(age, true))
			if id == "top":
				var forward: Vector2 = body._top.global_transform.x.normalized()
				assert_gt(forward.dot(dir if age < 16 else -dir), 0.99)
			else:
				assert_eq(body._tilted.flip_h, age < 16)
				assert_eq(body._tilted.frame_coords.y, 3 if age < 16 else 1)


func test_plain_blink_arrives_in_blink_with_the_departing_cell_and_one_spent_charge() -> void:
	ViewMode.select("tilt70")
	_rig.pose()
	var body: KerfSpectral = _rig._spectral
	var before: int = body._tilted.frame
	var fly: Texture2D = body._tilted.texture
	_press(Vector2.DOWN)
	assert_eq(_stage.pilot.kerf.trail_cut[-1], Vector2.INF)
	assert_eq(_stage.pilot.kerf.charges, 2)
	assert_eq(body.current, KerfRoninDrawn.Pose.BLINK)
	assert_eq(body._tilted.frame_coords, Vector2i(3, 0))
	var copy: Sprite2D = body._echoes._pool[0].sprites[body._echoes._sources.find(body._tilted)]
	assert_same(copy.texture, fly)
	assert_eq(copy.frame, before)


func test_an_overlapping_recoil_keeps_the_overhead_cutting_edge_on_course() -> void:
	ViewMode.select("top")
	var dir: Vector2 = Vector2(1, 1).normalized()
	var arena: CombatArena = _stage.arena
	var victim: Fighter = arena.spawn_guard(arena.rivet.pos + dir * 5)
	victim.pos = arena.rivet.pos + dir * 5
	arena.tick = 1
	arena.hit_dir = Vector2.RIGHT
	arena.damage(arena.rivet, 0.5, 1, &"rifle")
	_press(dir)
	var body: KerfSpectral = _rig._spectral
	assert_eq(body.current, KerfRoninDrawn.Pose.CUT)
	assert_gt(absf(body._hit.lean), 0.01)
	var blade: Sprite2D = body._top._blade[1]
	var tip: Vector2 = blade.to_global(body._top._parts.pivots_b["blade"] + blade.offset)
	assert_gt(blade.global_position.direction_to(tip).dot(dir), 0.99999)
