extends Scenario
## From the arena hub, vault the first pit crate and fire from its far corner.
## Only the input tape is recorded. The second arena starts from its normal spawn.


class PilotTape:
	extends InputSource
	var session: ArenaSession
	var aligned: bool = false
	var roll_tick: int = -1
	var snap_tick: int = -1

	func sample(tick: int) -> TickInput:
		var body: Fighter = session.stage.arena.rivet
		var motion: PlayerMotion = session.pilot.motion
		var move: Vector2 = Vector2.ZERO
		var aim: Vector2 = Vector2.ZERO
		var action: StringName = &""
		if not aligned:
			aligned = body.pos.x >= 3.45
			move = Vector2.RIGHT
		elif roll_tick < 0:
			move = Vector2.DOWN
			if body.pos.y >= 11.6:
				action = &"roll"
				roll_tick = tick
		elif snap_tick < 0 and motion.can_roll():
			action = &"cover"
			snap_tick = tick
		elif motion.cover.spot != null and tick > snap_tick + motion.cover.snap_ticks:
			if session.stage.shots_fired > 0:
				move = Vector2.DOWN
			else:
				move = Vector2.RIGHT
				aim = Vector2.RIGHT
				action = &"fire"
		var bits: int = PlayerCommand.pack_aim(aim, session.actions)
		if action != &"":
			bits |= 1 << session.actions.bit(action)
		var axes: Vector2 = move * TickInput.AXIS_MAX
		return TickInput.new(bits, roundi(axes.x), roundi(axes.y))


func run(_tree: SceneTree) -> String:
	var session: ArenaSession = ArenaSession.open(Events, Data)
	var tape: PilotTape = PilotTape.new()
	tape.session = session
	_enable(session)
	session.world.loop().set_input(tape)
	session.world.loop().start_recording()
	var beats: Dictionary[String, int] = {}
	while session.tick() < 420:
		var tick: int = session.tick()
		session.step()
		var motion: PlayerMotion = session.pilot.motion
		if motion.vault.frame == 0 and motion.vault.hit.kind == "cover_low":
			beats["vault"] = tick
		if motion.cover.phase == PlayerCover.Phase.IN and not beats.has("snap"):
			beats["snap"] = tick
		if motion.cover.phase == PlayerCover.Phase.PEEK and not motion.cover.blocks_fire():
			if not beats.has("peek"):
				beats["peek"] = tick
			if session.stage.shots_fired > 0 and not beats.has("fire"):
				beats["fire"] = tick
		if beats.has("fire") and motion.cover.phase == PlayerCover.Phase.OFF:
			beats["leave"] = tick
			break
	var log: ReplayLog = session.world.loop().finish_recording()
	var pos: Vector2 = session.stage.arena.rivet.pos
	tape.session = null
	session.world.free()
	if beats.keys() != ["vault", "snap", "peek", "fire", "leave"]:
		return (
			"move replay ended at %s with %s, roll/snap %d/%d"
			% [pos, beats, tape.roll_tick, tape.snap_tick]
		)
	Log.info("move-replay", "%s, %d ticks, %s" % [beats, log.ticks, log.final_hash])
	return _round_trip(log)


func _round_trip(log: ReplayLog) -> String:
	var path: String = TestTmp.dir("replay").path_join("arena-moves.json")
	if log.save(path) != OK:
		return "could not save the move replay"
	var loaded: ReplayLog = ReplayLog.load_file(path)
	if loaded == null:
		return "could not reopen the move replay"
	var divergence: String = _replay(loaded, true)
	if divergence != "":
		return "arena replay: " + divergence
	var off: String = _replay(loaded, false)
	if off == "":
		return "move flags off reproduced the move-on tape"
	Log.info("move-replay", "off control: " + off)
	return write_evidence("arena-moves.replay.json", loaded.to_dict())


func _enable(session: ArenaSession, enabled: bool = true) -> void:
	session.pilot.motion.cover.enabled = enabled
	session.pilot.motion.vault.enabled = enabled
	session.actions.enable_cover_input(enabled)


func _replay(log: ReplayLog, enabled: bool) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data, log.master_seed)
	_enable(again, enabled)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return divergence
