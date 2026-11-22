extends GutTest


func after_each() -> void:
	LaunchArgs.parse()


func _stage(args: PackedStringArray, pistol: bool = true) -> CollectCallStage:
	LaunchArgs.parse(args)
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(bus, data, 22)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	if pistol:
		stage.arena.rivet.weapon = &"pistol"
		stage.arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", ctx.rng.stream(&"gun"))
		stage.arena.gun.trigger.ammo = 2
	return stage


func _bytes(writer: Callable) -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	@warning_ignore("return_value_discarded")
	writer.call(out)
	return out.data_array


func test_absent_and_explicit_hands_start_identically_with_a_stage_gun() -> void:
	var absent: CollectCallStage = _stage([])
	var hands: CollectCallStage = _stage(["--controls=wheel", "--wheel-start=hands"])
	for stage: CollectCallStage in [absent, hands]:
		stage.step(0, TickInput.new())
		assert_eq(stage.pilot.wheel.selected(), &"hands")
		assert_eq(stage.pilot.wheel.order(), [&"hands", &"pistol"])
		assert_eq(_bytes(stage.pilot.wheel.write_state).size(), 0)
		assert_null(stage.arena.gun)
	assert_eq(_bytes(absent.pilot.write_state), _bytes(hands.pilot.write_state))


func test_drawn_adopts_the_stage_pistol_silently_and_prev_reaches_hands() -> void:
	var legacy: CollectCallStage = _stage(["--controls=legacy"])
	var stage: CollectCallStage = _stage(["--controls=wheel", "--wheel-start=drawn"])
	var hand: GunHand = stage.arena.gun
	var wheel: RivetWheel = stage.pilot.wheel
	for tick: int in 2:
		stage.step(tick, TickInput.new())
		legacy.step(tick, TickInput.new())
		assert_eq(wheel.selected(), &"pistol")
		assert_eq(wheel.order(), [&"hands", &"pistol"])
		assert_same(stage.arena.gun, hand)
		assert_eq(hand.trigger.ammo, 2)
		assert_eq(stage.pilot.carry.switches, 0)
		assert_eq(wheel.switched_tick, -1)
		assert_eq(_bytes(wheel.write_state).size(), 0)
		assert_eq(_bytes(stage.pilot.write_state), _bytes(legacy.pilot.write_state))
	stage.step(2, TickInput.new(1 << stage.pilot.actions.bit(&"weapon_prev")))
	assert_eq(wheel.selected(), &"hands")
	assert_eq(wheel.switched_tick, 2)
	assert_eq(stage.pilot.carry.switches, 1)
	assert_null(stage.arena.gun)


func test_drawing_the_arena_sidearm_keeps_its_builtin_trigger() -> void:
	var stage: CollectCallStage = _stage(["--controls=wheel"], false)
	stage.arena.rivet.weapon = &"gloria"
	stage.step(0, TickInput.new())
	assert_eq(stage.pilot.wheel.selected(), &"hands")
	stage.step(1, TickInput.new(1 << stage.pilot.actions.bit(&"weapon_slot_1")))
	assert_eq(stage.arena.rivet.weapon, &"gloria")
	assert_null(stage.arena.gun, "the original sidearm uses the arena's held-fire cooldown")


func test_first_tick_scroll_from_an_armed_loadout_counts_just_the_scroll() -> void:
	var stage: CollectCallStage = _stage(["--controls=wheel", "--wheel-start=drawn"])
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), stage.arena._rng, stage.arena.gun
	)
	carry.select(carry.add(&"pistol"), stage.arena)
	stage.pilot.carry = carry
	var switches: int = carry.switches
	stage.step(0, TickInput.new(1 << stage.pilot.actions.bit(&"weapon_prev")))
	assert_eq(stage.pilot.wheel.selected(), &"hands")
	assert_eq(stage.pilot.wheel.switched_tick, 0)
	assert_eq(carry.switches, switches + 1)


func test_drawn_with_empty_hands_opens_silently_and_legacy_ignores_either_value() -> void:
	var empty: CollectCallStage = _stage(["--controls=wheel", "--wheel-start=drawn"], false)
	empty.step(0, TickInput.new())
	assert_eq(empty.pilot.wheel.selected(), &"hands")
	assert_eq(empty.pilot.wheel.order(), [&"hands"])
	assert_eq(empty.pilot.wheel.switched_tick, -1)
	assert_eq(_bytes(empty.pilot.wheel.write_state).size(), 0)
	var before: CollectCallStage = _stage(["--controls=legacy"])
	var flagged: CollectCallStage = _stage(["--controls=legacy", "--wheel-start=drawn"])
	for stage: CollectCallStage in [before, flagged]:
		stage.step(0, TickInput.new())
		assert_null(stage.pilot.wheel)
		assert_eq(stage.arena.rivet.weapon, &"pistol")
	assert_eq(_bytes(before.pilot.write_state), _bytes(flagged.pilot.write_state))
