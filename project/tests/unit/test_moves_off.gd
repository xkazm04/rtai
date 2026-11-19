extends GutTest
## Compare every stage byte with the locomotion path before vault and cover (9060b8a10^).

var saved: PackedStringArray


class LegacyMotion:
	extends PlayerMotion

	func drive(stage: CollectCallStage, pilot: StagePilot, c: PlayerCommand, walk: float) -> void:
		_cooldown = maxi(_cooldown - 1, 0)
		_roll_tick = -1
		if c.was_pressed(pilot.actions, &"roll") and can_roll():
			_start_roll(c.move)
		match phase:
			Phase.ROLL:
				stage.intent.move_by = _roll_step(walk)
			Phase.RECOVER:
				stage.intent.move_by = _recover_step(c, walk, pilot.actions)
			_:
				stage.intent.move_by = _free_step(c, walk, pilot.actions)

	func write_state(out: StreamPeerBuffer) -> void:
		mover.write_state(out)
		out.put_32(phase)
		out.put_32(_phase_tick)
		out.put_32(_cooldown)
		out.put_float(roll_dir.x)
		out.put_float(roll_dir.y)


func before_each() -> void:
	saved = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])
	LaunchArgs.parse(PackedStringArray(["--no-vault", "--no-cover"]))


func after_each() -> void:
	LaunchArgs.parse(saved)


func _stage(arena: bool, legacy: bool) -> CollectCallStage:
	var stage: CollectCallStage
	if arena:
		var stations: ArenaStations = ArenaStations.new()
		stations.add_file(ArenaStations.DIR + "/arena.json")
		stage = ArenaStage.new(ArenaPlan.shipped(), stations)
	else:
		stage = CollectCallStage.new(StageLayout.shipped(true))
		stage.cells = StageCells.shipped()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 1918))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	var motion: PlayerMotion = stage.pilot.motion
	if legacy:
		motion = LegacyMotion.new()
		stage.pilot.motion = motion
	assert_false(motion.vault.enabled)
	assert_false(motion.cover.enabled)
	stage.pilot.actions.install()
	stage.arena.rivet.pos = Vector2(4, 11.75) if arena else Vector2(5.5, 45.15)
	motion.mover.velocity = Vector2.DOWN * 8.0
	return stage


func test_off_arena_keeps_legacy_stage_bytes_at_the_pit_crate() -> void:
	_compare_stage_bytes(true)


func test_off_quest_keeps_legacy_stage_bytes_at_the_city_bollard() -> void:
	_compare_stage_bytes(false)


func _compare_stage_bytes(arena: bool) -> void:
	var now: CollectCallStage = _stage(arena, false)
	var old: CollectCallStage = _stage(arena, true)
	var live: LiveInput = LiveInput.new(now.pilot.actions)
	var bit: int = 1 << now.pilot.actions.bit(&"cover")
	Input.action_press(&"cover")
	var sampled: int = live.sample(0).buttons
	Input.action_release(&"cover")
	assert_eq(sampled & bit, 0)
	for tick: int in 52:
		var buttons: int = (1 << now.pilot.actions.bit(&"roll")) if tick == 0 else 0
		var input: TickInput = TickInput.new(buttons | sampled, 0, TickInput.AXIS_MAX)
		now.step(tick, input)
		old.step(tick, TickInput.new(buttons, 0, TickInput.AXIS_MAX))
		var a: StreamPeerBuffer = StreamPeerBuffer.new()
		var b: StreamPeerBuffer = StreamPeerBuffer.new()
		now.write_state(a)
		old.write_state(b)
		if a.data_array != b.data_array:
			fail_test("stage bytes first differ at tick %d" % tick)
			return
		if tick == 0:
			assert_eq(now.pilot.motion.phase, PlayerMotion.Phase.ROLL)
			assert_null(now.pilot.motion.vault.hit)
		var moves: StreamPeerBuffer = StreamPeerBuffer.new()
		now.pilot.motion.cover.write_state(moves)
		now.pilot.motion.vault.write_state(moves, now.pilot.motion.phase)
		assert_eq(moves.get_size(), 0)
