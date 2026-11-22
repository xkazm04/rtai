extends GutTest

var stage: ArenaStage
var motion: PlayerMotion
var body: Fighter
var actions: PlayerActions


func before_each() -> void:
	stage = VaultTrial.stage_for(false, null, false)
	motion = stage.pilot.motion
	body = stage.arena.rivet
	actions = stage.pilot.actions
	body.pos = Vector2(-20, -20)


func _tick(move: Vector2, action: StringName = &"") -> void:
	var bits: int = 1 << actions.bit(action) if action != &"" else 0
	stage.step(stage.tick + 1, TickInput.new(bits, roundi(move.x * 127), roundi(move.y * 127)))


func test_first_cut_step_ends_at_the_near_face_even_for_a_thin_wall() -> void:
	var top: float = body.pos.y + body.radius_m + 0.2
	stage.walls.boxes.append(Rect2(body.pos.x - 2.0, top, 4.0, 0.02))
	_tick(Vector2.DOWN, &"dash")
	assert_eq(motion.dashes, 1)
	assert_almost_eq(body.pos.y, top - body.radius_m, 0.0001)
	assert_eq(motion.phase, PlayerMotion.Phase.FREE)
	assert_eq(motion.dash.cooldown, motion.dash.cooldown_ticks)
	assert_eq(body.pos, stage.collide_preview(body.pos))
	assert_eq(motion.velocity(), Vector2.ZERO)


func test_body_contacts_use_the_existing_tackle_rules() -> void:
	for cls: StringName in [&"human", &"robot", &"boss"]:
		before_each()
		var table: BodyTable = ArenaBodies.table()
		var separation: float = table.radius(RivetBody.CLASS) + table.radius(cls)
		var start_pos: Vector2 = body.pos + Vector2.DOWN * (separation + 0.05)
		var target: Fighter = Fighter.make(Fighter.Kind.GUARD, 94, start_pos, 5.0)
		target.body_class = cls
		target.brain_owned = true
		stage.arena.hostiles.append(target)
		_tick(Vector2.DOWN, &"dash")
		assert_lt(body.pos.y, target.pos.y)
		assert_gte(body.pos.distance_to(target.pos), separation - 0.0001)
		if cls == &"human":
			assert_gt(target.pos.y - start_pos.y, table.rule(RivetBody.CLASS, cls).knockback_m)
			assert_eq(target.hp, 5.0)
		else:
			assert_eq(target.pos, start_pos)
			assert_eq(motion.dash.cooldown, motion.dash.cooldown_ticks)


func test_cover_vault_and_death_own_movement() -> void:
	body.pos = Vector2(4, 11.65)
	_tick(Vector2.ZERO, &"cover")
	_tick(Vector2.RIGHT, &"dash")
	assert_ne(motion.cover.phase, PlayerCover.Phase.OFF)
	assert_eq(motion.dashes, 0)
	before_each()
	VaultTrial.approach_crate(stage)
	_tick(Vector2.DOWN, &"roll")
	_tick(Vector2.DOWN, &"dash")
	assert_eq(motion.phase, PlayerMotion.Phase.VAULT)
	assert_eq(motion.dashes, 0)
	before_each()
	_tick(Vector2.RIGHT, &"dash")
	body.hp = 0.0
	_tick(Vector2.RIGHT)
	_tick(Vector2.RIGHT, &"dash")
	assert_ne(motion.phase, PlayerMotion.Phase.DASH)
	assert_eq(motion.dashes, 1)


func test_unused_dash_preserves_exact_legacy_motion_bytes() -> void:
	_tick(Vector2.RIGHT)
	var old: StreamPeerBuffer = StreamPeerBuffer.new()
	motion.mover.write_state(old)
	old.put_32(PlayerMotion.Phase.FREE)
	old.put_32(0)  # roll frame
	old.put_32(0)  # roll cooldown
	old.put_float(0.0)
	old.put_float(0.0)
	var actual: StreamPeerBuffer = StreamPeerBuffer.new()
	motion.write_state(actual)
	assert_eq(actual.data_array, old.data_array)


func test_cooldown_advances_once_on_ground_in_cover_on_roll_exit_and_in_vault() -> void:
	for vaulting: bool in [false, true]:
		before_each()
		_tick(Vector2.DOWN, &"dash")
		for i: int in motion.dash.ticks - 1:
			_tick(Vector2.ZERO)
		var start: int = motion.dash.cooldown
		assert_eq(start, motion.dash.cooldown_ticks)
		_tick(Vector2.ZERO)
		assert_eq(motion.dash.cooldown, start - 1, "free ground")
		if vaulting:
			VaultTrial.approach_crate(stage)
			_tick(Vector2.DOWN, &"roll")
			assert_eq(motion.phase, PlayerMotion.Phase.VAULT)
			assert_eq(motion.dash.cooldown, start - 2, "takeoff")
			_tick(Vector2.DOWN)
			assert_eq(motion.dash.cooldown, start - 3, "airborne")
		else:
			body.pos = Vector2(4, 11.65)
			_tick(Vector2.ZERO, &"cover")
			for i: int in motion.cover.snap_ticks:
				assert_eq(motion.dash.cooldown, start - 2 - i, "cover")
				_tick(Vector2.ZERO)
			assert_eq(motion.cover.phase, PlayerCover.Phase.IN)
			var before_exit: int = motion.dash.cooldown
			_tick(Vector2.RIGHT, &"roll")
			assert_eq(motion.phase, PlayerMotion.Phase.ROLL)
			assert_eq(motion.dash.cooldown, before_exit - 1, "roll out of cover")


func test_recorded_dash_stream_replays_the_stage_digest_twice() -> void:
	var recording: ReplayLog = ReplayLog.new(1918)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	for i: int in 75:
		var bits: int = 1 << actions.bit(&"dash") if i in [0, 52] else 0
		var raw: TickInput = TickInput.new(bits, 127, 0)
		recording.record_input(i, raw)
		stage.step(i, raw)
		stage.write_state(out)
	assert_eq(motion.dashes, 2)
	var digest: String = out.data_array.hex_encode().sha256_text()
	var path: String = TestTmp.dir("dash_replay").path_join("dash.json")
	assert_eq(recording.save(path), OK)
	for run: int in 2:
		before_each()
		var tape: ReplayLog = ReplayLog.load_file(path)
		var replay: StreamPeerBuffer = StreamPeerBuffer.new()
		for i: int in 75:
			stage.step(i, tape.input_at(i))
			stage.write_state(replay)
		assert_eq(motion.dashes, 2)
		assert_eq(replay.data_array.hex_encode().sha256_text(), digest)
