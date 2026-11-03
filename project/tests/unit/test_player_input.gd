extends GutTest


func _actions() -> PlayerActions:
	return PlayerActions.shipped()


func test_table_loads_with_bits_for_the_buttons() -> void:
	var a: PlayerActions = _actions()
	assert_eq(a.errors, [] as Array[String])
	for id: StringName in [&"fire", &"melee", &"interact", &"car"]:
		assert_true(a.bit(id) >= 0, "%s has a bit" % id)
	assert_eq(a.bit(&"pause"), -1, "pause is a menu action, not a sim input")
	assert_true(a.aim_shift >= 8 and a.aim_shift + 9 <= 32, "the aim fits in the buttons word")


func test_install_registers_the_input_map() -> void:
	var a: PlayerActions = _actions()
	a.install()
	for id: StringName in [&"move_up", &"move_left", &"fire", &"interact", &"pause", &"aim_right"]:
		assert_true(InputMap.has_action(id), "%s is in the InputMap" % id)
	assert_true(InputMap.action_get_events(&"move_up").size() >= 3, "keys, d-pad and stick")


func test_aim_round_trips_through_the_tick_input() -> void:
	var a: PlayerActions = _actions()
	for deg: float in [0.0, 45.0, 90.0, 181.0, 300.0]:
		var heading: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(deg))
		var bits: int = PlayerCommand.pack_aim(heading, a) | (1 << a.bit(&"fire"))
		var packed: int = TickInput.new(bits, 127, -127).pack()
		var c: PlayerCommand = PlayerCommand.decode(TickInput.unpack(packed), 0, a)
		assert_almost_eq(c.aim.angle_to(heading), 0.0, TAU / a.aim_steps, "aim %s" % deg)
		assert_true(c.is_held(a, &"fire"))
		assert_eq(c.move, Vector2(1.0, -1.0))


func test_no_aim_decodes_to_zero_and_presses_are_edges() -> void:
	var a: PlayerActions = _actions()
	var e: int = 1 << a.bit(&"interact")
	var first: PlayerCommand = PlayerCommand.decode(TickInput.new(e), 0, a)
	var held: PlayerCommand = PlayerCommand.decode(TickInput.new(e), e, a)
	assert_eq(first.aim, Vector2.ZERO)
	assert_true(first.was_pressed(a, &"interact"))
	assert_false(held.was_pressed(a, &"interact"), "holding is not a second press")
	assert_true(held.is_held(a, &"interact"))


func test_mover_accelerates_strafes_slower_and_brakes() -> void:
	var a: PlayerActions = _actions()
	var m: TopDownMover = TopDownMover.new()
	var first: Vector2 = m.step(Vector2.RIGHT, Vector2.ZERO, 4.5, a)
	assert_lt(first.length(), 4.5 * SimClock.TICK_DT, "not full speed on tick 1")
	for i: int in 60:
		@warning_ignore("return_value_discarded")
		m.step(Vector2.RIGHT, Vector2.ZERO, 4.5, a)
	assert_almost_eq(m.velocity.length(), 4.5, 0.01, "top speed after a second")
	var strafe: TopDownMover = TopDownMover.new()
	for i: int in 60:
		@warning_ignore("return_value_discarded")
		strafe.step(Vector2.RIGHT, Vector2.DOWN, 4.5, a)
	assert_lt(strafe.velocity.length(), 4.5 * 0.9, "strafing across the aim is slower")
	for i: int in 30:
		@warning_ignore("return_value_discarded")
		m.step(Vector2.ZERO, Vector2.ZERO, 4.5, a)
	assert_eq(m.velocity, Vector2.ZERO, "brakes to a stop within half a second")


func test_facing_turns_at_a_capped_rate() -> void:
	var a: PlayerActions = _actions()
	var m: TopDownMover = TopDownMover.new()
	m.facing = Vector2.RIGHT
	@warning_ignore("return_value_discarded")
	m.step(Vector2.ZERO, Vector2.LEFT, 4.5, a)
	var max_turn: float = deg_to_rad(a.turn_dps) * SimClock.TICK_DT
	assert_almost_eq(absf(Vector2.RIGHT.angle_to(m.facing)), max_turn, 0.001)


func test_pad_use_stops_the_mouse_aim_and_mouse_motion_restores_it() -> void:
	var live: LiveInput = LiveInput.new(_actions())
	assert_true(live.mouse_aims)
	var tiny: InputEventJoypadMotion = InputEventJoypadMotion.new()
	tiny.axis_value = 0.05
	live.note_event(tiny)
	assert_true(live.mouse_aims, "stick drift does not count as pad use")
	live.note_event(InputEventJoypadButton.new())
	assert_false(live.mouse_aims)
	live.note_event(InputEventMouseMotion.new())
	assert_true(live.mouse_aims)


func test_vehicle_bits_match_the_vehicles_contract() -> void:
	var a: PlayerActions = _actions()
	assert_eq(a.bit(&"car"), 0, "VehicleService.BIT_USE")
	assert_eq(a.bit(&"handbrake"), 1, "VehicleService.BIT_HANDBRAKE")
