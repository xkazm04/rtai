extends GutTest
## Lane gunplay (rivet-arsenal REQUEST 12): the mouse cursor's distance rides in 4 bits above the
## aim heading, so a thrown weapon lands where the cursor is; an input without them (old replays,
## the pad) decodes to no distance and keeps the fixed aim_range_m lob.

var _actions: PlayerActions


func before_all() -> void:
	_actions = PlayerActions.shipped()


func _decode(buttons: int) -> PlayerCommand:
	return PlayerCommand.decode(TickInput.new(buttons), 0, _actions)


func test_the_reach_round_trips_in_steps() -> void:
	assert_gt(_actions.aim_reach_step_m, 0.0)
	var c: PlayerCommand = _decode(PlayerCommand.pack_aim(Vector2.RIGHT, _actions, 5.0))
	assert_almost_eq(c.aim_m, 4.8, 0.001, "5 m -> 4 steps of 1.2 m")
	assert_almost_eq(c.aim.angle(), 0.0, 0.03)


func test_no_reach_decodes_to_zero_and_the_heading_is_unchanged() -> void:
	var with: PlayerCommand = _decode(PlayerCommand.pack_aim(Vector2.DOWN, _actions, 9.0))
	var without: PlayerCommand = _decode(PlayerCommand.pack_aim(Vector2.DOWN, _actions))
	assert_eq(without.aim_m, 0.0, "an old replay's aim word carries no distance")
	assert_eq(with.aim, without.aim, "the heading bits are untouched by the reach")


func test_the_reach_clamps_and_leaves_the_buttons_alone() -> void:
	var word: int = PlayerCommand.pack_aim(Vector2.LEFT, _actions, 400.0)
	var c: PlayerCommand = _decode(word | 0b11)
	assert_almost_eq(c.aim_m, PlayerCommand.REACH_MAX * _actions.aim_reach_step_m, 0.001)
	assert_eq(c.held, 0b11, "buttons below the aim word survive")
	assert_lt(word, 1 << 32, "fits TickInput's 32-bit buttons")
