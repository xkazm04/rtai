extends GutTest

var stage: ArenaStage
var body: Fighter
var actions: PlayerActions


func before_each() -> void:
	_setup(ControlsMode.wheel())


func _setup(use_wheel: bool) -> void:
	stage = VaultTrial.stage_for(false, null, use_wheel)
	stage.pilot.motion.vault.enabled = false
	actions = stage.pilot.actions
	body = stage.arena.rivet
	body.pos = Vector2(4, 11.65)
	stage.pilot.hold.held = body.weapon
	stage.pilot.hold.state = WeaponHold.State.READY


func test_disabled_script_matches_pre_cover_stage_bytes() -> void:
	_setup(false)  # This stage-byte fixture predates the wheel.
	stage.pilot.motion.cover.enabled = false
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	for i: int in 70:
		var heading: Vector2 = Vector2.RIGHT.rotated(TAU * (i + 1) / 256.0)
		var bits: int = PlayerCommand.pack_aim(heading, actions, 4.8)
		if i in [0, 12, 35]:
			bits |= 1 << 29
		if i == 40:
			bits |= 1 << actions.bit(&"roll")
		stage.step(i, TickInput.new(bits, 90, 15))
		stage.write_state(out)
	# Re-pinned n31 melee 02p3 (2026-11-26): --melee-sweep on by default adds the sweep state.
	assert_eq(
		out.data_array.hex_encode().sha256_text(),
		"9f6382561997c479c6af0ea0543ab9a7a1bb994e5b59f01420ebd97c8f245116"
	)


func _enable() -> PlayerCover:
	var cover: PlayerCover = stage.pilot.motion.cover
	cover.enabled = true
	return cover


func _tick(move: Vector2, action: StringName = &"", aim: Vector2 = Vector2.ZERO) -> void:
	var b: int = PlayerCommand.pack_aim(aim, actions)
	if action != &"":
		b |= 1 << actions.bit(action)
	var axes: Vector2 = move * TickInput.AXIS_MAX
	stage.step(stage.tick + 1, TickInput.new(b, roundi(axes.x), roundi(axes.y)))
	assert_true(stage.pilot.motion.vault.probe.clear_at(body.pos, body.radius_m))
	assert_eq(body.pos, stage.collide_preview(body.pos))


func _snap() -> PlayerCover:
	var cover: PlayerCover = _enable()
	_tick(Vector2.ZERO, &"cover")
	assert_eq(cover.phase, PlayerCover.Phase.SNAP)
	for i: int in cover.snap_ticks - 1:
		_tick(Vector2.ZERO)
	assert_eq(cover.phase, PlayerCover.Phase.IN)
	assert_eq(body.facing, Vector2.UP)
	assert_almost_eq(body.pos.y, 12.0, 0.00001)
	return cover


func test_slide_clamps_at_both_ends_and_peek_retracts() -> void:
	var cover: PlayerCover = _snap()
	var start: Vector2 = body.pos
	_tick(Vector2.RIGHT)
	assert_almost_eq(body.pos.x - start.x, cover.move_mps * SimClock.TICK_DT, 0.00001)
	for i: int in 40:
		_tick(Vector2.LEFT)
	assert_eq(body.pos.x, cover.spot.box.position.x)
	var left: Vector2 = body.pos
	for i: int in cover.peek_ticks:
		_tick(Vector2.ZERO, &"", Vector2.LEFT)
	assert_eq(body.pos, cover.spot.edge_a)
	for i: int in cover.peek_ticks:
		_tick(Vector2.ZERO)
	assert_eq(body.pos, left)
	assert_eq(cover.phase, PlayerCover.Phase.IN)
	for i: int in 65:
		_tick(Vector2.RIGHT)
	assert_eq(body.pos.x, cover.spot.box.end.x)


func _hostile_shot(at: Vector2) -> void:
	var shot: Shot = Shot.new()
	shot.pos = Vector2(6.0, 16.0)
	shot.vel = shot.pos.direction_to(at) * 30.0
	shot.from_rivet = false
	shot.damage = 7.0
	shot.weapon = &"assault-rifle"
	stage.arena.shots.append(shot)


func test_both_sides_shoot_past_the_end_and_mid_face_fire_is_refused() -> void:
	_tick(Vector2.ZERO, &"weapon_slot_1")
	var cover: PlayerCover = _snap()
	var hp: float = body.hp
	_hostile_shot(body.pos)
	for i: int in 15:
		_tick(Vector2.ZERO, &"fire", Vector2.DOWN)
	assert_eq(stage.dodges.blocked, 1)
	assert_eq(body.hp, hp)
	assert_eq(stage.shots_fired, 0)
	for i: int in 32:
		_tick(Vector2.RIGHT)
	var target: Fighter = Fighter.make(
		Fighter.Kind.GUARD, 290, cover.spot.edge_b + Vector2.DOWN * 3, 5
	)
	target.brain_owned = true
	stage.arena.hostiles.append(target)
	for i: int in cover.peek_ticks:
		_tick(Vector2.ZERO, &"fire", Vector2.DOWN)
		assert_eq(stage.shots_fired, int(i + 1 == cover.peek_ticks))
	assert_eq(body.pos, cover.spot.edge_b)
	assert_true(body.exposed)
	_hostile_shot(body.pos)
	for i: int in 12:
		_tick(Vector2.ZERO, &"", Vector2.RIGHT)
	assert_lt(target.hp, target.max_hp)
	assert_eq(body.hp, hp - 7.0)
	assert_eq(stage.dodges.blocked, 1)


func test_proving_block_station_offers_cover_on_clear_city_ground() -> void:
	var plan: ArenaPlan = ArenaPlan.shipped(stage.plan.city_base)
	stage = ArenaStage.new(plan, stage.stations)
	stage.cells = StageCells.shipped()
	stage.setup(World.build_context(Events, Data, 1903))
	stage.pilot = StagePilot.new(actions)
	body = stage.arena.rivet
	var cover: PlayerCover = _enable()
	for box: Rect2 in stage.walls.boxes:
		var face: Vector2 = Vector2(box.get_center().x, box.position.y)
		var foot: Vector2 = face + Vector2.UP * body.radius_m
		var start: Vector2 = foot + Vector2.UP * 0.25
		if stage.collide_preview(start) != start or stage.collide_preview(foot) != foot:
			continue
		body.pos = start
		_tick(Vector2.ZERO, &"cover")
		for i: int in cover.snap_ticks - 1:
			_tick(Vector2.ZERO)
		assert_eq(cover.phase, PlayerCover.Phase.IN)
		assert_eq(body.pos, foot)
		assert_true(stage.walls.blocks(box.get_center(), body.pos))
		return
	fail_test("expected a reachable station on the proving block")


func test_city_prop_reports_its_face_but_cannot_start_cover() -> void:
	var cover: PlayerCover = _enable()
	stage.cells = StageCells.shipped()
	body.pos = Vector2(5.5, 45.15)
	_tick(Vector2.ZERO, &"cover")
	assert_eq(cover.phase, PlayerCover.Phase.OFF)
	var city: VaultCity = stage.pilot.motion.vault.probe.city
	var solids: Dictionary[Rect2, String] = {}
	city.collect(Rect2(5, 46, 1, 1), solids)
	var faces: Array[CoverQuery.CoverSpot] = CoverQuery.near(body.pos, 1.0, solids)
	assert_false(faces.is_empty())
	assert_false(faces[0].protects_shots)


func test_leave_counts_consecutive_outward_ticks_and_can_cancel() -> void:
	var cover: PlayerCover = _snap()
	for i: int in cover.leave_ticks - 1:
		_tick(Vector2.UP)
	assert_eq(cover.phase, PlayerCover.Phase.LEAVE)
	_tick(Vector2.ZERO)
	assert_eq(cover.phase, PlayerCover.Phase.IN)
	for i: int in cover.leave_ticks:
		_tick(Vector2.UP)
	assert_eq(cover.phase, PlayerCover.Phase.OFF)


func test_press_again_and_roll_both_release_cover() -> void:
	var cover: PlayerCover = _snap()
	_tick(Vector2.ZERO, &"cover")
	assert_eq(cover.phase, PlayerCover.Phase.OFF)
	_tick(Vector2.ZERO)
	_tick(Vector2.ZERO, &"cover")
	stage.pilot.motion.vault.enabled = true
	_tick(Vector2.UP, &"roll")
	assert_eq(cover.phase, PlayerCover.Phase.OFF)
	assert_eq(stage.pilot.motion.phase, PlayerMotion.Phase.ROLL)
