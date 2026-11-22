extends GutTest
## Exercises the pilot and the stage's final body collision, including the landing tick.

var stage: ArenaStage
var motion: PlayerMotion
var pilot: StagePilot
var body: Fighter
var origin: Vector2
var radius: float


func _course(kind: String, thickness: float = 0.8, blocked: bool = false) -> void:
	var stations: ArenaStations = ArenaStations.new()
	var station: ArenaStation = ArenaStation.new()
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = kind
	prop.size = Vector2(6.0, thickness)
	station.props.append(prop)
	if blocked:
		var wall: ArenaStation.Prop = ArenaStation.Prop.new()
		wall.kind = "wall_high"
		wall.size = Vector2(6.0, 1.0)
		wall.at = Vector2.DOWN * (thickness * 0.5 + 0.55)
		station.props.append(wall)
	stations.stations.append(station)
	stage = ArenaStage.new(ArenaPlan.shipped(), stations)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 19))
	pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot = pilot
	motion = pilot.motion
	body = stage.arena.rivet
	radius = stage.arena.tuning.rivet["radius_m"]
	origin = stage.plan.base - Vector2.DOWN * (radius + thickness * 0.5 + 0.25)
	body.pos = origin
	motion.mover.velocity = Vector2.DOWN * 8.0
	motion.vault.enabled = true


func _command(press: bool) -> TickInput:
	var bits: int = 1 << pilot.actions.bit(&"fire")
	if press:
		bits |= 1 << pilot.actions.bit(&"roll")
	bits |= PlayerCommand.pack_aim(Vector2.DOWN, pilot.actions)
	return TickInput.new(bits, 0, TickInput.AXIS_MAX)


func test_low_cover_commits_until_landing_with_iframes_and_no_shots() -> void:
	_course("cover_low")
	pilot.hold.held = body.weapon
	pilot.hold.state = WeaponHold.State.READY
	var previous: Vector2 = body.pos
	for i: int in 18:
		var command: TickInput = _command(i == 0)
		command.buttons |= pilot.actions.draw_sidearm(i)
		stage.step(i, command)
		if i == 0:
			assert_eq(motion.phase, PlayerMotion.Phase.VAULT, "vault starts on the roll edge")
		assert_eq(body.exposed, not (i >= 3 and i <= 12))
		assert_eq(stage.shots_fired, 0)
		var box: Rect2 = stage.walls.boxes[0]
		var over: bool = body.pos.distance_to(body.pos.clamp(box.position, box.end)) < radius
		assert_eq(motion.vault.airborne(), over)
		var mean: float = origin.distance_to(motion.vault.hit.landing) / motion.vault.ticks
		assert_gt(body.pos.y, previous.y)
		assert_lte(body.pos.distance_to(previous), 2.0 * mean)
		previous = body.pos
		assert_almost_eq(motion.vault.lift(), 1.0 - pow((i + 1) / 9.0 - 1.0, 2), 1e-6)
	assert_eq(motion.phase, PlayerMotion.Phase.RECOVER)
	assert_gt(body.pos.y, stage.walls.boxes[0].end.y + radius)
	stage.step(18, _command(false))
	assert_gt(stage.shots_fired, 0, "the same held shot is available after landing")


func test_high_and_deep_cover_cannot_be_crossed() -> void:
	for kind: String in ["wall_high", "cover_high", "cover_low"]:
		_course(kind, 3.0 if kind == "cover_low" else 0.8)
		for i: int in 24:
			stage.step(i, _command(i == 0))
			assert_ne(motion.phase, PlayerMotion.Phase.VAULT)
			assert_lt(body.pos.y, stage.walls.boxes[0].position.y)


func test_blocked_landing_stops_without_rolling() -> void:
	_course("cover_low", 0.8, true)
	stage.step(0, _command(true))
	assert_eq(motion.phase, PlayerMotion.Phase.FREE)
	assert_eq(motion.velocity(), Vector2.ZERO)
	assert_eq(body.pos, origin)


func test_slow_and_glancing_approaches_do_not_vault() -> void:
	for velocity: Vector2 in [Vector2.DOWN, Vector2(7.0, 4.0)]:
		_course("cover_low")
		motion.mover.velocity = velocity
		stage.step(0, _command(true))
		assert_ne(motion.phase, PlayerMotion.Phase.VAULT)


func test_disabled_motion_matches_pre_vault_bytes() -> void:
	_course("cover_low")
	motion.vault.enabled = false
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	for i: int in 50:
		stage.step(i, _command(i == 2))
		motion.write_state(stream)
		if i == 2:
			assert_eq(motion.phase, PlayerMotion.Phase.ROLL)
	assert_eq(
		stream.data_array.hex_encode().sha256_text(),
		"ba881cbfbf42b7de3fceff89acef6f7c99c23038e48bacbfa1997ee015ca875c"
	)


func test_city_building_and_generated_low_prop() -> void:
	_course("cover_low")
	stage.cells = StageCells.shipped()
	# The street bollard at (5.30, 46.23) stamps one metre of sidewalk.
	assert_eq(stage.cells.code_at(5, 46), SimConst.C_PROP)
	body.pos = Vector2(5.5, 45.15)
	stage.step(0, _command(true))
	assert_eq(motion.phase, PlayerMotion.Phase.VAULT)
	for i: int in range(1, 18):
		stage.step(i, _command(false))
		assert_eq(motion.vault.airborne(), not stage.cells.clear(body.pos, radius))
	assert_gt(body.pos.y, 47.0 + radius)
	_course("cover_low")
	stage.cells = StageCells.shipped()
	# Find the first building face on this block with open ground to its north.
	for y: int in range(200, 265):
		if stage.cells.code_at(292, y) == SimConst.C_BUILD:
			var approach: Vector2 = Vector2(292.5, y - radius - 0.2)
			if stage.cells.clear(approach, radius):
				body.pos = approach
				stage.step(0, _command(true))
				assert_ne(motion.phase, PlayerMotion.Phase.VAULT)
				assert_lt(body.pos.y, float(y))
				return
	fail_test("expected a clear approach to a building on the block")


func test_clear_ground_roll_is_identical_in_both_modes() -> void:
	var samples: Array[PackedByteArray] = []
	for enabled: bool in [false, true]:
		_course("cover_low")
		body.pos = Vector2(-12, -12)
		motion.vault.enabled = enabled
		var out: StreamPeerBuffer = StreamPeerBuffer.new()
		for i: int in 42:
			stage.step(i, _command(i == 1))
			motion.write_state(out)
			out.put_float(body.pos.x)
			out.put_float(body.pos.y)
		assert_eq(motion.rolls, 1)
		samples.append(out.data_array)
	assert_eq(samples[0], samples[1])


func test_committed_ticks_own_the_intent_even_with_a_melee_lunge() -> void:
	_course("cover_low")
	pilot.melee.combo.press()
	for i: int in motion.vault.ticks:
		stage.intent.clear()
		var command: TickInput = _command(i == 0)
		command.buttons |= 1 << pilot.actions.bit(&"power_hauler")
		pilot.drive(stage, command)
		assert_eq(motion.vault.frame, i)
		assert_eq(stage.intent.move_by, Vector2.ZERO)
		assert_eq(stage.intent.move_to, Vector2.INF)
		assert_eq(body.pos, motion.vault.position)
	assert_eq(pilot.ghosts.transforms, 0)


func test_city_bollard_blocks_an_arena_cover_landing() -> void:
	_course("cover_low")
	stage.cells = StageCells.shipped()
	var vault: PlayerVault = motion.vault
	vault.prepare(stage)
	vault.probe.boxes.clear()
	vault.probe.boxes[Rect2(4.5, 44.2, 2.0, 0.8)] = "cover_low"
	var p: Vector2 = Vector2(5.5, 43.4)
	var hit: VaultProbe.Hit = vault.probe.find(p, radius, Vector2.DOWN * 8, Vector2.DOWN)
	assert_eq(hit.reason, &"landing_blocked")
	assert_false(vault.probe.clear_at(hit.landing, radius))


func test_clearance_distinguishes_rounded_contact_from_penetration() -> void:
	_course("cover_low")
	var probe: VaultProbe = motion.vault.probe
	probe.boxes[Rect2(-34, 7.7, 8, 0.6)] = "wall_high"
	assert_true(probe.clear_at(Vector2(-30, 7.1), radius))
	assert_false(probe.clear_at(Vector2(-30, 7.100001), radius))
