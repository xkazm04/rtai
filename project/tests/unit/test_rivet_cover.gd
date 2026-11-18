extends GutTest

var stage: ArenaStage
var body: Fighter
var actions: PlayerActions


func before_each() -> void:
	stage = VaultTrial.stage_for(false)
	stage.pilot.motion.vault.enabled = false
	actions = stage.pilot.actions
	body = stage.arena.rivet
	body.pos = Vector2(4, 11.65)
	stage.pilot.hold.held = body.weapon
	stage.pilot.hold.state = WeaponHold.State.READY


func test_disabled_script_matches_pre_cover_stage_bytes() -> void:
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
	assert_eq(
		out.data_array.hex_encode().sha256_text(),
		"2333f2285413fa8af3924424f7322c96bd1d1a905898dee4230efbd6739241a8"
	)


func _enable() -> PlayerCover:
	var cover: PlayerCover = stage.pilot.motion.cover
	cover.enabled = true
	actions.bits[&"cover"] = 14
	cover.snap_reach_m = 0.85
	cover.snap_ticks = 5
	cover.move_mps = 3.0
	cover.peek_m = 0.8
	cover.peek_ticks = 6
	cover.edge_m = 0.2
	cover.leave_dot = 0.65
	cover.leave_ticks = 4
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
