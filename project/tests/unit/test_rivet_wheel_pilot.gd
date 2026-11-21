extends GutTest

var stage: CollectCallStage
var pilot: StagePilot
var actions: PlayerActions


func after_each() -> void:
	LaunchArgs.parse()
	PlayerActions.shipped().install()


func _start(mode: String = "wheel") -> void:
	LaunchArgs.parse(["--controls=" + mode, "--no-cover", "--no-vault"])
	actions = PlayerActions.shipped()
	actions.install()
	stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 22))
	pilot = StagePilot.new(actions)
	stage.pilot = pilot


func _tick(ids: Array[StringName] = []) -> void:
	var b: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions)
	for id: StringName in ids:
		b |= 1 << actions.bit(id)
	stage.step(stage.tick + 1, TickInput.new(b))


func _ready_weapon(id: StringName, slot: StringName) -> void:
	_tick()
	pilot.carry.take(id, stage.arena)
	_tick([slot])
	for tick: int in pilot.hold.switch_ticks(&"", id):
		_tick()


func test_held_primary_chains_the_bare_claw_without_a_shot() -> void:
	_start()
	assert_not_null(pilot.wheel)
	for i: int in 80:
		_tick([&"fire"])
	assert_eq(pilot.wheel.selected(), &"hands")
	assert_eq(pilot.melee.weapon_id, MeleeTable.CLAW)
	assert_gt(pilot.melee.combo.starts, 1)
	assert_eq(stage.shots_fired, 0)


func test_primary_fires_only_after_draw_and_space_keeps_the_pistol() -> void:
	_start()
	_tick()
	pilot.carry.take(&"pistol", stage.arena)
	_tick([&"weapon_slot_1", &"fire"])
	assert_eq(pilot.hold.state, WeaponHold.State.DRAWING)
	assert_eq(stage.shots_fired, 0)
	for i: int in pilot.hold.switch_ticks(&"", &"pistol"):
		_tick([&"fire"])
	var hand: GunHand = stage.arena.gun
	assert_eq(hand.shots_fired, 1)
	assert_eq(pilot.melee_swings, 0)
	_tick([&"fire", &"melee"])
	assert_eq(pilot.melee.weapon_id, MeleeTable.CLAW)
	assert_eq(pilot.melee.combo.starts, 1)
	assert_eq(pilot.wheel.selected(), &"pistol")
	assert_same(stage.arena.gun, hand)
	assert_eq(stage.shots_fired, 1)


func test_space_over_a_drawn_blade_strikes_with_the_claw_then_returns_to_the_blade() -> void:
	_start()
	_ready_weapon(&"katana", &"weapon_slot_2")
	_tick([&"fire"])
	assert_eq(pilot.melee.weapon_id, &"katana")
	assert_true(pilot.melee.busy())
	_tick([&"melee"])
	assert_eq(pilot.wheel.selected(), &"katana")
	assert_eq(pilot.hold.held, &"katana")
	assert_false(pilot.wielding(), "the rig poses the quick claw")
	assert_eq(pilot.melee.weapon_id, MeleeTable.CLAW)
	assert_true(pilot.melee.busy())
	for tick: int in 60:
		_tick()
	_tick([&"fire"])
	assert_eq(pilot.melee.weapon_id, &"katana")
	assert_true(pilot.melee.busy())
	assert_eq(stage.shots_fired, 0)


func test_primary_waits_for_stow_before_starting_the_bare_combo() -> void:
	_start()
	_ready_weapon(&"pistol", &"weapon_slot_1")
	_tick([&"weapon_next", &"fire"])
	assert_eq(pilot.wheel.selected(), &"hands")
	assert_null(stage.arena.gun)
	assert_eq(pilot.hold.state, WeaponHold.State.STOWING)
	assert_eq(pilot.melee.combo.starts, 0)
	for tick: int in pilot.hold.switch_ticks(&"pistol", &""):
		_tick([&"fire"])
	assert_eq(pilot.hold.held, &"")
	assert_eq(pilot.melee.weapon_id, MeleeTable.CLAW)
	assert_eq(pilot.melee.combo.starts, 1)
	assert_eq(stage.shots_fired, 0)


func test_right_mouse_decodes_only_to_guard_and_blocks_the_primary() -> void:
	_start()
	var mouse: InputEventMouseButton = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	mouse.pressed = true
	var ids: Array[StringName] = []
	for id: StringName in actions.bits:
		if mouse.is_action_pressed(id):
			ids.append(id)
	assert_eq(ids, [&"guard"])
	_tick(ids)
	assert_true(pilot.guard.up())
	assert_eq(pilot.melee_swings, 0)
	_tick([&"guard", &"fire"])
	assert_eq(pilot.melee_swings, 0)
	assert_eq(stage.shots_fired, 0)


func test_armed_loadout_is_in_first_seen_order_and_begins_with_hands() -> void:
	_start()
	var arena_stage: ArenaStage = VaultTrial.stage_for(false)
	stage = arena_stage
	pilot = arena_stage.pilot
	actions = pilot.actions
	var arsenal: ArenaArsenal = ArenaArsenal.new()
	var ctx: WorldContext = World.build_context(stage.events(), Data, 22)
	arsenal.setup(arena_stage, ctx)
	var ids: Array[StringName] = [
		&"rocket_launcher", &"katana", &"pistol", &"chainsaw", &"plasma_rifle"
	]
	assert_same(arsenal.arm(ids, false), pilot.carry)
	assert_eq(
		pilot.wheel.order(),
		[&"hands", &"katana", &"chainsaw", &"rocket_launcher", &"pistol", &"plasma_rifle"]
	)
	_tick()
	assert_eq(pilot.wheel.selected(), &"hands")
	assert_eq(stage.arena.rivet.weapon, &"")
	assert_null(stage.arena.gun)


func test_hud_readout_fades_and_expires_one_second_after_the_switch() -> void:
	_start()
	_tick()
	var layer: Node2D = autofree(Node2D.new())
	var hud: HudView = HudView.new()
	add_child(layer)
	layer.add_child(hud)
	WheelReadoutView.attach(hud, stage)
	var view: WheelReadoutView = layer.get_child(1) as WheelReadoutView
	assert_not_null(view)
	view._process(0.0)
	assert_false(view.visible)
	pilot.carry.take(&"pistol", stage.arena)
	_tick([&"weapon_next"])
	var start: int = pilot.wheel.switched_tick
	assert_eq(start, stage.arena.tick)
	view._process(0.0)
	assert_true(view.visible)
	assert_eq(view.modulate.a, 1.0)
	stage.arena.tick += roundi(0.5 * SimClock.TICK_RATE)
	view._process(0.0)
	assert_almost_eq(view.modulate.a, 1.0, 0.00001)
	stage.arena.tick = start + SimClock.TICK_RATE
	view._process(0.0)
	assert_false(view.visible)


func test_legacy_pilot_bytes_match_the_pre_wheel_reference() -> void:
	_start("legacy")
	assert_null(pilot.wheel)
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
	# Same pre-interface byte reference as test_player_guard_pilot, captured at e3d5799e8.
	assert_eq(
		tape.data_array.hex_encode().sha256_text(),
		"e49fc269dbf052c6223a735e1d2fd8371a29b600c8ee8fa5289f7251d1467299"
	)
