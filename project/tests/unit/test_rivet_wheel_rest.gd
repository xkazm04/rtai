extends GutTest


func after_each() -> void:
	LaunchArgs.parse()
	PlayerActions.shipped().install()


func _state(writer: Callable) -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	@warning_ignore("return_value_discarded")
	writer.call(out)
	return out.data_array


func _stage(mode: String, blade: bool = false) -> CollectCallStage:
	LaunchArgs.parse(["--controls=" + mode])
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(bus, data, 22)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	if blade:
		var c: RivetCarry = RivetCarry.new(
			WeaponTable.shipped(), ArsenalTable.shipped(), ctx.rng.stream(&"quest_blade")
		)
		c.sheathe = true
		assert_gte(c.add(&"katana"), 0)
		stage.pilot.carry = c
		stage.guns = StageGuns.make(ctx.rng.stream(&"quest_guns"))
	return stage


func test_guard_contributes_nothing_until_raised_then_keeps_its_full_payload() -> void:
	var guard: PlayerGuard = PlayerGuard.new()
	guard.step(true, false)
	assert_eq(_state(guard.write_state).size(), 0)
	guard.step(true, true)
	var raised: PackedByteArray = _state(guard.write_state)
	assert_eq(raised.size(), 37)
	for tick: int in CombatTuning.ticks(guard.tuning.refill_delay_s) + 1:
		guard.step(false, true)
	assert_eq(guard.meter(), 1.0)
	assert_false(guard.up())
	var lowered: PackedByteArray = _state(guard.write_state)
	assert_eq(lowered.size(), raised.size())
	assert_ne(lowered, raised)


func test_modified_guard_capacity_is_hashed_before_first_raise() -> void:
	var guard: PlayerGuard = PlayerGuard.new()
	guard.meter_k = 1.0
	assert_eq(_state(guard.write_state).size(), 0)
	guard.meter_k = 1.5
	assert_eq(_state(guard.write_state).size(), 37)
	guard.meter_k = 1.0
	assert_eq(_state(guard.write_state).size(), 37)


func test_unused_wheel_and_implicit_inventory_add_no_bytes_to_a_moving_pilot() -> void:
	var before: CollectCallStage = _stage("legacy")
	var after: CollectCallStage = _stage("wheel")
	assert_eq(_state(before.pilot.write_state), _state(after.pilot.write_state))
	for tick: int in 75:
		var input: TickInput = TickInput.new(0, 100, 0)
		if tick == 5 or tick == 33:
			input.buttons = 1 << before.pilot.actions.bit(&"melee" if tick == 5 else &"roll")
		before.step(tick, input)
		after.step(tick, input)
		assert_eq(
			_state(after.pilot.write_state),
			_state(before.pilot.write_state),
			"pilot bytes at tick %d" % tick
		)
	assert_not_null(after.pilot.carry)
	assert_false(after.pilot.wheel.writes_carry())
	assert_eq(_state(after.pilot.wheel.write_state).size(), 0)


func test_even_an_empty_scroll_or_shortcut_records_state_across_rebind() -> void:
	for key: StringName in [&"weapon_next", &"weapon_prev", &"weapon_slot_4"]:
		var stage: CollectCallStage = _stage("wheel")
		var pilot: StagePilot = stage.pilot
		stage.step(0, TickInput.new())
		assert_eq(_state(pilot.wheel.write_state).size(), 0)
		stage.step(1, TickInput.new(1 << pilot.actions.bit(key)))
		assert_eq(pilot.wheel.selected(), RivetWheel.HANDS)
		assert_true(pilot.wheel.writes_carry())
		var used: PackedByteArray = _state(pilot.wheel.write_state)
		assert_gt(used.size(), 0)
		stage.step(2, TickInput.new())
		assert_eq(_state(pilot.wheel.write_state), used)
		pilot.carry = RivetWheel.carry_for(stage.arena)
		assert_gt(_state(pilot.wheel.write_state).size(), 0)


func test_a_floor_item_and_a_real_pickup_affect_the_implicit_inventory() -> void:
	var stage: CollectCallStage = _stage("wheel")
	stage.step(0, TickInput.new())
	var pilot: StagePilot = stage.pilot
	var empty: PackedByteArray = _state(pilot.write_state)
	pilot.carry.ground.drop(&"pistol", stage.arena.rivet.pos)
	assert_true(pilot.wheel.writes_carry())
	assert_ne(_state(pilot.write_state), empty)
	stage.step(1, TickInput.new())
	assert_true(pilot.carry.ground.items.is_empty())
	assert_true(pilot.wheel.writes_carry())
	assert_gt(_state(pilot.wheel.write_state).size(), 0)
	pilot.carry = RivetWheel.carry_for(stage.arena)
	assert_true(pilot.wheel.writes_carry())


func test_story_grant_keeps_legacy_pilot_bytes_and_the_stages_own_trigger() -> void:
	var before: CollectCallStage = _stage("legacy", true)
	var after: CollectCallStage = _stage("wheel", true)
	for tick: int in 120:
		if tick == 2:
			before.arena.rivet.weapon = &"gloria"
			after.arena.rivet.weapon = &"gloria"
		var b: int = PlayerCommand.pack_aim(Vector2.RIGHT, before.pilot.actions)
		if tick > 10:
			b |= 1 << before.pilot.actions.bit(&"fire")
		before.step(tick, TickInput.new(b))
		after.step(tick, TickInput.new(b))
		assert_eq(
			_state(after.pilot.write_state),
			_state(before.pilot.write_state),
			"story pilot at tick %d" % tick
		)
	assert_gt(before.shots_fired, 1)
	assert_eq(after.shots_fired, before.shots_fired)
	assert_eq(after.pilot.wheel.order(), [&"hands", &"katana", &"gloria"])
	var magazine: GunHand = after.arena.gun
	after.step(120, TickInput.new(1 << after.pilot.actions.bit(&"weapon_slot_1")))
	assert_eq(after.pilot.carry.weapon(), &"gloria")
	assert_eq(after.pilot.carry.current, after.pilot.carry.slot_of(&"gloria"))
	assert_same(after.arena.gun, magazine)
	after.step(121, TickInput.new(1 << after.pilot.actions.bit(&"weapon_slot_2")))
	after.step(122, TickInput.new(1 << after.pilot.actions.bit(&"weapon_slot_1")))
	assert_eq(after.pilot.wheel.selected(), &"gloria")
	assert_same(after.arena.gun, magazine)


func test_quest_grant_without_a_blade_keeps_the_implicit_carry_out_of_the_tape() -> void:
	var before: CollectCallStage = _stage("legacy")
	var after: CollectCallStage = _stage("wheel")
	for stage: CollectCallStage in [before, after]:
		stage.guns = StageGuns.make(RngRegistry.new(7).stream(&"grant"))
		stage.step(0, TickInput.new())
		stage.arena.rivet.weapon = &"gloria"
		stage.step(1, TickInput.new())
	assert_true(after.arena.gun.tap)
	assert_eq(_state(after.pilot.write_state), _state(before.pilot.write_state))
	assert_false(after.pilot.wheel.writes_carry())
	assert_eq(after.pilot.wheel.order(), [&"hands", &"gloria"])


func test_dent_primary_never_also_presses_the_ghosts_melee_action() -> void:
	var stage: CollectCallStage = _stage("wheel")
	var pilot: StagePilot = stage.pilot
	stage.step(0, TickInput.new(1 << pilot.actions.bit(&"power_gearbox")))
	stage.step(1, TickInput.new(1 << pilot.actions.bit(&"power_hauler")))
	for tick: int in pilot.ghosts.forms.table.form(DentStage.GHOST).enter_ticks + 1:
		stage.step(stage.tick + 1, TickInput.new())
	assert_true(pilot.ghosts.settled_in(DentStage.GHOST))
	stage.step(stage.tick + 1, TickInput.new(1 << pilot.actions.bit(&"fire")))
	assert_eq(pilot.ghosts.jab.presses, 0)
	stage.step(stage.tick + 1, TickInput.new(1 << pilot.actions.bit(&"melee")))
	assert_eq(pilot.ghosts.jab.presses, 1)


func test_spent_story_rifle_restores_the_blade_shortcut_until_regranted() -> void:
	for regrant: bool in [false, true]:
		var stage: CollectCallStage = _stage("wheel", true)
		var pilot: StagePilot = stage.pilot
		stage.step(0, TickInput.new())
		stage.arena.rifle_ammo = 1
		stage.arena.rivet.weapon = RivetCarry.RIFLE
		stage.step(1, TickInput.new())
		assert_eq(pilot.wheel.selected(), RivetCarry.RIFLE)
		stage.arena.rifle_ammo = 0
		stage.arena.rivet.weapon = &"gloria"
		stage.step(2, TickInput.new())
		assert_true(pilot.carry.rifle_spent)
		assert_eq(pilot.wheel.order(), [&"hands", &"katana", &"gloria"])
		if regrant:
			stage.arena.rifle_ammo = 1
			stage.arena.rivet.weapon = RivetCarry.RIFLE
			stage.step(3, TickInput.new())
			assert_false(pilot.carry.rifle_spent)
			assert_eq(pilot.wheel.order(), [&"hands", &"katana", RivetCarry.RIFLE, &"gloria"])
		stage.step(4, TickInput.new(1 << pilot.actions.bit(&"weapon_slot_2")))
		assert_eq(pilot.carry.weapon(), RivetCarry.RIFLE if regrant else &"katana")
