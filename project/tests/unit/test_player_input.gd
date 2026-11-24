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


func test_action_numbers_and_wire_bits_are_stable() -> void:
	var ids: PackedStringArray = [
		"car",
		"handbrake",
		"fire",
		"melee",
		"interact",
		"sprint",
		"roll",
		"power_hauler",
		"power_gearbox",
		"weapon_next",
		"weapon_prev",
		"weapon_slot_1",
		"weapon_slot_2",
		"weapon_slot_3",
		"weapon_slot_4",
		"reload",
		"cover",
		"guard",
		"dash",
		"ghost_deploy",
		"ghost_deploy_1",
		"ghost_deploy_2",
		"ghost_deploy_3",
		"ghost_deploy_4"
	]
	var a: PlayerActions = _actions()
	assert_eq(a.bits.size(), ids.size())
	for row: Dictionary in a.rows:
		var id: String = row["id"]
		var logical: int = ids.find(id)
		var stored_bit: float = row["bit"]
		assert_eq(int(stored_bit), logical, id)
		var wire: int = logical if logical < 16 else logical + 13
		assert_eq(a.bit(StringName(id)), wire, id)


func test_keyboard_mouse_and_pad_bindings() -> void:
	var keys: Dictionary = {
		"sprint": ["Space"],
		"handbrake": ["Space"],
		"melee": ["F"],
		"dash": ["Shift"],
		"car": ["1"],
		"ghost_deploy": [],
		"power_gearbox": [],
		"weapon_next": ["Tab"]
	}
	var pad: Dictionary = {
		"car": [3.0], "melee": [2.0], "ghost_deploy": [9.0], "power_gearbox": [10.0]
	}
	for i: int in range(1, 5):
		keys["ghost_deploy_%d" % i] = [str(i)]
		keys["weapon_slot_%d" % i] = []
		pad["ghost_deploy_%d" % i] = []
	for row: Dictionary in _actions().rows:
		var id: String = row["id"]
		var bound: Array = row["keys"]
		assert_false(bound.has("Q") or bound.has("G"), id)
		if keys.has(id):
			var expected: Array = keys[id]
			assert_eq(bound, expected, id)
		if pad.has(id):
			var buttons: Array = row["joy_buttons"]
			var expected: Array = pad[id]
			assert_eq(buttons, expected, id)
		if id == "melee":
			var mouse: Array = row["mouse"]
			assert_eq(mouse, [2.0], id)
