extends GutTest

var stage: CollectCallStage
var pilot: StagePilot
var actions: PlayerActions


func after_each() -> void:
	LaunchArgs.parse()


func _start(mode: String) -> void:
	LaunchArgs.parse(["--controls=" + mode, "--no-cover", "--no-vault"])
	actions = PlayerActions.shipped()
	stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 22))
	pilot = StagePilot.new(actions)
	stage.pilot = pilot


func test_legacy_pilot_state_matches_the_pre_guard_tape() -> void:
	_start("legacy")
	pilot.melee.combo.table.single_swing = false
	assert_null(pilot.guard)
	var tape: StreamPeerBuffer = StreamPeerBuffer.new()
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions)
	for tick: int in 64:
		var buttons: int = aim
		if tick < 10:
			buttons |= 1 << actions.bit(&"fire")
		if tick == 14 or tick == 21:
			buttons |= 1 << actions.bit(&"melee")
		if tick == 36:
			buttons |= 1 << actions.bit(&"roll")
		stage.step(tick, TickInput.new(buttons, 127, 0))
		pilot.write_state(tape)
	assert_null(stage.arena.guard)
	# Captured from e3d5799e8, before the pilot had a guard.
	# Re-pinned n31 melee 02p3 (2026-11-26): --melee-sweep on by default adds the sweep state.
	assert_eq(
		tape.data_array.hex_encode().sha256_text(),
		"24ca6e8e0b057f4f3b7720e4a8aed05380b134f4bc2dd5cacdc5d650b3af9f1e"
	)


func _drive(ids: Array[StringName], aim: Vector2 = Vector2.RIGHT) -> void:
	var bits: int = PlayerCommand.pack_aim(aim, actions)
	for id: StringName in ids:
		bits |= 1 << actions.bit(id)
	stage.intent.clear()
	pilot.drive(stage, TickInput.new(bits, 127, 0))


func test_held_primary_counts_only_one_swing_in_the_first_ten_ticks() -> void:
	_start("wheel")
	for tick: int in 10:
		stage.step(tick, TickInput.new(1 << actions.bit(&"fire")))
		assert_eq(pilot.melee_swings, 1, "held tick %d" % tick)


func test_second_press_during_the_claw_swing_is_discarded() -> void:
	_start("wheel")
	stage.step(0, TickInput.new(1 << actions.bit(&"fire")))
	stage.step(1, TickInput.new())
	stage.step(2, TickInput.new(1 << actions.bit(&"fire")))
	assert_false(pilot.melee.combo.buffered)
	assert_eq(pilot.melee_swings, 1)
	for tick: int in pilot.melee.combo.current().length():
		stage.step(3 + tick, TickInput.new())
	assert_eq(pilot.melee.combo.starts, 1)
	assert_eq(pilot.melee_swings, 1)


func test_guard_walk_facing_attacks_and_roll_exit() -> void:
	_start("wheel")
	var walk: float = stage.arena.tuning.rivet["walk_mps"]
	_drive([&"guard"], Vector2.UP)
	assert_true(pilot.guard.up())
	assert_same(pilot.guard, stage.arena.guard)
	for tick: int in 80:
		_drive([&"guard", &"sprint", &"melee", &"fire"], Vector2.ZERO)
	assert_almost_eq(stage.arena.rivet.facing, Vector2.UP, Vector2.ONE * 0.00001)
	assert_false(pilot.motion.sprinting)
	assert_lte(pilot.motion.velocity().length(), walk * pilot.guard.tuning.move_k + 0.0001)
	assert_eq(pilot.melee_swings, 0)
	assert_eq(pilot.shock.shock.charge, 0)
	assert_eq(stage.intent.fire_at, Vector2.INF)
	_drive([&"guard", &"roll"])
	assert_false(pilot.guard.up())
	assert_eq(pilot.motion.phase, PlayerMotion.Phase.ROLL)


func test_interrupting_a_charge_throw_and_swing_cannot_release_them() -> void:
	_start("wheel")
	pilot.shock.shock.held = true
	pilot.shock.shock.charge = pilot.shock.shock.charge_full
	pilot.throw.wound = 3
	pilot.melee.combo.press()
	_drive([&"guard", &"fire", &"melee"])
	assert_false(pilot.shock.busy())
	assert_eq(pilot.shock.discharges, 0)
	assert_false(pilot.throw.winding())
	assert_false(pilot.melee.busy())
	assert_eq(stage.intent.fire_at, Vector2.INF)


func test_transform_drops_guard_on_entry_and_keeps_it_down_in_form() -> void:
	_start("wheel")
	pilot.ghosts.transform_unlocked = true
	_drive([&"guard"])
	_drive([&"guard", &"power_hauler"])
	assert_false(pilot.ghosts.forms.settled())
	assert_false(pilot.guard.up())
	for tick: int in pilot.ghosts.forms.table.form(&"tonnage").enter_ticks:
		_drive([&"guard"])
		assert_false(pilot.guard.up())
	assert_eq(pilot.ghosts.forms.current(), &"tonnage")


func test_cover_and_death_lower_guard() -> void:
	LaunchArgs.parse(["--controls=wheel"])
	stage = VaultTrial.stage_for(false)
	pilot = stage.pilot
	actions = pilot.actions
	stage.arena.rivet.pos = Vector2(4, 11.65)
	pilot.motion.cover.enabled = true
	_drive([&"guard", &"cover"])
	assert_not_null(pilot.motion.cover.spot)
	assert_false(pilot.guard.up())
	_drive([&"guard"])
	assert_false(pilot.guard.up())
	pilot.motion.cover.interrupt()
	stage.arena.rivet.hp = 0.0
	_drive([&"guard"])
	assert_false(pilot.guard.up())


func test_stagger_blocks_attacks_and_sprint_but_allows_walk() -> void:
	_start("wheel")
	stage.arena.rivet.weapon = &"gloria"
	for tick: int in 90:
		_drive([&"guard"])
	var foe: Fighter = stage.arena.spawn_guard(stage.arena.rivet.pos)
	foe.pos = stage.arena.rivet.pos + Vector2.RIGHT
	for hit: int in 5:
		stage.arena.damage(stage.arena.rivet, 10.0, foe.id, &"baton", &"melee")
	assert_true(pilot.guard.broken())
	for tick: int in 30:
		_drive([&"sprint", &"melee", &"fire"])
		assert_eq(stage.intent.fire_at, Vector2.INF)
		assert_false(pilot.motion.sprinting)
		assert_false(pilot.guard.up())
	assert_eq(pilot.melee_swings, 0)
	assert_eq(pilot.shock.shock.charge, 0)
	assert_almost_eq(pilot.motion.velocity().length(), stage.arena.tuning.rivet["walk_mps"], 0.001)
