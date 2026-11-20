extends GutTest

var _view_id: StringName
var _stage: CollectCallStage
var _k: KerfStage
var _rig: KerfRig
var _rivet: Fighter


func before_each() -> void:
	_view_id = ViewMode.shared().id
	GhostLook.override_for_test(&"spectral")
	ViewMode.select("top")
	_stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage.setup(World.build_context(bus, data, 1))
	_stage.pilot = StagePilot.new(PlayerActions.shipped())
	_k = _stage.pilot.kerf
	_stage.pilot.ghosts.forms.from_id = KerfStage.GHOST
	_stage.pilot.ghosts.forms.to_id = KerfStage.GHOST
	@warning_ignore("return_value_discarded")
	_k.powers.try_activate(KerfStage.ID)
	_rivet = _stage.arena.rivet
	_rivet.pos = Vector2(200, 200)
	_rig = KerfRig.new()
	_rig.stage = _stage
	_rig.position = _rivet.pos * SimConst.PX_PER_M
	add_child_autofree(_rig)


func after_each() -> void:
	ViewMode.select(_view_id)
	GhostLook.reset_for_test()


func _press(dir: Vector2) -> void:
	_stage.tick += 1
	@warning_ignore("return_value_discarded")
	_k.drive(_stage, false, true, dir, Vector2.ZERO)
	_rig.position = _rivet.pos * SimConst.PX_PER_M
	_rig.rotation = _rivet.facing.angle()
	_rig.pose()


func _target(dir: Vector2) -> Fighter:
	var f: Fighter = _stage.arena.spawn_guard(_rivet.pos)
	f.pos = _rivet.pos + dir * 5.0
	_k.sight_aim = dir
	return f


func test_one_tilted_departure_holds_the_previous_cell_scale_and_facing() -> void:
	ViewMode.select("tilt70")
	var victim: Fighter = _target(Vector2.LEFT)
	_rig.scale = Vector2.ONE * 1.4
	_rig.pose()
	var body: KerfSpectral = _rig._spectral
	var texture: Texture2D = body._tilted.texture
	var scale_before: Vector2 = body._tilted.global_scale
	var cell: Vector2i = body._tilted.frame_coords
	var at: Vector2 = _rivet.pos * SimConst.PX_PER_M
	assert_eq(body.current, KerfRoninDrawn.Pose.COCK)
	assert_true(body._tilted.flip_h)
	_press(Vector2.LEFT)
	assert_false(victim.alive())
	assert_eq(body._tilted.frame_coords.x, 1)
	assert_eq(body.current, KerfRoninDrawn.Pose.CUT)
	assert_eq(body._echoes._pool.size(), 1)
	var echo: KerfEcho.Pose = body._echoes._pool[0]
	var copy: Sprite2D = echo.sprites[body._echoes._sources.find(body._tilted)]
	assert_almost_eq(echo.global_position, at, Vector2.ONE * 0.002)
	assert_almost_eq(echo.modulate.a, 0.35, 0.001)
	assert_lt(echo.modulate.a, 0.45)
	assert_eq(body.modulate.a, 1.0)
	assert_eq(body._tilted.modulate.a, 1.0)
	var wash: ShaderMaterial = copy.material
	assert_true(is_same(wash.get_shader_parameter(&"wash"), Color(Color("#2ec4b6"), 0.6)))
	assert_true(copy.visible and copy.flip_h)
	assert_false(copy.centered)
	assert_ne(copy.offset, Vector2.ZERO)
	assert_same(copy.texture, texture)
	assert_eq(copy.frame_coords, cell)
	assert_true(copy.scale.is_equal_approx(scale_before))
	assert_almost_eq(echo.global_scale, Vector2(1.12, 1), Vector2.ONE * 0.0001)
	_rig.pose()
	assert_eq(body._echoes._pool.size(), 1)
	_stage.tick += 3
	_rig.pose()
	assert_almost_eq(echo.global_scale, Vector2.ONE, Vector2.ONE * 0.0001)
	assert_almost_eq(echo.modulate.a, 0.35 * KerfSlot.remaining(3, _k.num(&"cut_hang_s")), 0.001)
	assert_eq(copy.frame_coords, cell)


func test_top_sight_yaws_to_the_target_over_four_ticks_with_a_limit() -> void:
	var target: Fighter = _target(Vector2.DOWN)
	var body: KerfSpectral = _rig._spectral
	for tick: int in range(1, 5):
		_stage.tick = tick
		_rig.pose()
		var want: float = deg_to_rad(25.0) * smoothstep(0, 4, tick)
		assert_almost_eq(body._top.global_rotation, want, 0.0001)
		assert_eq(body.current, KerfRoninDrawn.Pose.COCK)
		_rig.pose()
		assert_almost_eq(body._top.global_rotation, want, 0.0001)
	target.pos += Vector2.DOWN * 100
	for i: int in 4:
		_stage.tick += 1
		_rig.pose()
	assert_almost_eq(body._top.global_rotation, 0.0, 0.0001)
	assert_eq(body.current, KerfRoninDrawn.Pose.HOVER)


func test_slot_retracts_and_thins_from_departure_and_marks_only_from_tick_three() -> void:
	var victim: Fighter = _target(Vector2.RIGHT)
	var at: Vector2 = _rivet.pos
	_press(Vector2.RIGHT)
	var slot: KerfSlot = KerfSlot.new()
	var hang_ticks: float = _k.num(&"cut_hang_s") / SimClock.TICK_DT
	for t: int in [0, 1, 2, 3, 5, 6, 15, ceili(hang_ticks)]:
		var fade: float = maxf(0, 1.0 - t / hang_ticks)
		var extra: float = 0.5 * pow(maxf(0, 1.0 - t / 6.0), 3)
		var end: Vector2 = _rivet.pos + Vector2.RIGHT * extra
		var start: Vector2 = end.lerp(at, fade)
		slot.place(_k, 0, t, 32.0)
		assert_true(slot.start.is_equal_approx(start * 32))
		assert_true(slot.end.is_equal_approx(end * 32))
		assert_almost_eq(slot.fade, fade, 0.0001)
		assert_almost_eq(slot.core_width, 0.04 * 32 * fade, 0.0001)
		assert_almost_eq(slot.glow_width, 0.12 * 32 * fade, 0.0001)
		assert_almost_eq(slot.mark_width, 0.035 * 32 * fade if t >= 3 else 0.0, 0.0001)
		if t >= 3:
			assert_eq(slot.mark_centre, victim.pos * 32)
			var tip: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(55)) * 0.95 * 32 * fade
			assert_true(slot.mark_tip.is_equal_approx(tip))
		_stage.tick = _k.trail_tick[0] + t
		_rig.pose()
		assert_true(_rig._spectral.global_position.is_equal_approx(end * 32))


func test_live_mount_clears_the_flight_lag_and_leaves_the_top_pose_on_its_mark() -> void:
	var v: GhostFormView = add_child_autofree(GhostFormView.make(_stage, null, null))
	var live: KerfRig = v._bodies.kerf
	assert_same(live.stage, _stage)
	_stage.arena.tick = 0
	v._process(0.0)
	@warning_ignore("return_value_discarded")
	_target(Vector2.RIGHT)
	_stage.tick = 1
	_stage.arena.tick = 1
	v._process(0.0)
	var at: Vector2 = _rivet.pos * 32
	var lens: Sprite2D = live._spectral._top._head
	var lens_at: Vector2 = lens.global_position - at
	var tex: Texture2D = lens.texture
	_press(Vector2.RIGHT)
	_stage.arena.tick = _stage.tick
	v._process(0.0)
	assert_gt(live.drawn.flight.hover.lag_px.length(), 16.0)
	var body: KerfSpectral = live._spectral
	assert_almost_eq(body.global_position, _rivet.pos * 32 + Vector2(16, 0), Vector2.ONE * 0.01)
	var echo: KerfEcho.Pose = body._echoes._pool[0]
	var copied_lens: Sprite2D = echo.sprites[body._echoes._sources.find(lens)]
	assert_true(copied_lens.visible)
	assert_same(copied_lens.texture, tex)
	assert_almost_eq(copied_lens.position, lens_at, Vector2.ONE * 0.002)
	assert_almost_eq(echo.global_position, at, Vector2.ONE * 0.002)


func test_plain_dash_has_no_overshoot_or_mark_and_reduced_motion_has_no_echo() -> void:
	_rig._spectral.reduced_motion = true
	_press(Vector2.DOWN)
	assert_null(_rig._spectral._echoes)
	assert_true(_rig._spectral.global_position.is_equal_approx(_rivet.pos * 32))
	var slot: KerfSlot = KerfSlot.new()
	slot.place(_k, 0, 3, 32.0)
	assert_true(slot.end.is_equal_approx(_rivet.pos * 32))
	assert_eq(slot.mark_width, 0.0)
	assert_eq(KerfSlot.overshoot(-1), 0.0)
	assert_eq(KerfSlot.remaining(0, 0.0), 1.0)
	assert_eq(KerfSlot.remaining(1, 0.0), 0.0)


func test_chain_reuses_three_departures_and_each_expires_on_its_own_tick() -> void:
	var body: KerfSpectral = _rig._spectral
	for n: int in 4:
		_k.charges = 3
		_k._gap = 0
		_press(Vector2.RIGHT)
		assert_eq(body._echoes._pool.size(), mini(n + 1, 3))
		var p: KerfEcho.Pose = body._echoes._pool[n % 3]
		assert_eq(p.global_position, _k.trail_from[-1] * 32)
	_stage.tick += ceili(_k.num(&"cut_hang_s") / SimClock.TICK_DT) - 1
	_rig.pose()
	assert_true(body._echoes._pool[0].visible)
	assert_false(body._echoes._pool[1].visible)
	_stage.tick += 1
	_rig.pose()
	assert_false(body._echoes._pool[0].visible)
