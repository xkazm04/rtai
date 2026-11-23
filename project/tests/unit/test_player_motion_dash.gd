extends GutTest

const WALK: float = 6.75

var motion: PlayerMotion
var actions: PlayerActions
var previous: int
var _step_taken: Vector2


func before_each() -> void:
	motion = PlayerMotion.shipped()
	actions = PlayerActions.shipped()
	previous = 0


func _press(move: Vector2, action: StringName = &"") -> Vector2:
	var bits: int = (1 << actions.bit(action)) if action != &"" else 0
	var raw: TickInput = TickInput.new(bits, roundi(move.x * 127), roundi(move.y * 127))
	var cmd: PlayerCommand = PlayerCommand.decode(raw, previous, actions)
	previous = bits
	return motion.step(cmd, WALK, actions)


func test_cardinal_diagonal_and_facing_use_exact_eased_distance() -> void:
	for stick: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2(-1, 1), Vector2.ZERO]:
		motion = PlayerMotion.shipped()
		motion.mover.facing = Vector2.LEFT
		var heading: Vector2 = stick.normalized() if stick != Vector2.ZERO else Vector2.LEFT
		var total: Vector2 = _press(stick, &"dash")
		var last: float = total.length()
		assert_eq(motion.dashes, 1)
		for i: int in range(1, motion.dash.ticks):
			var ds: Vector2 = _press(-heading, &"roll" if i == 1 else &"")
			assert_lt(ds.length(), last)
			assert_false(motion.invulnerable())
			assert_false(motion.blocks_fire())
			last = ds.length()
			total += ds
		assert_eq(motion.rolls, 0)
		assert_almost_eq(total.distance_to(heading * motion.dash.distance_m), 0.0, 0.00001)
		assert_eq(motion.phase, PlayerMotion.Phase.FREE)
		assert_almost_eq(motion.velocity().distance_to(heading * WALK), 0.0, 0.00001)


func test_all_cooldown_ticks_reject_an_edge_then_the_next_edge_works() -> void:
	var burst: PlayerMotionDash = motion.dash
	for i: int in burst.ticks:
		_step_taken = _press(Vector2.DOWN, &"dash" if i == 0 else &"")
	assert_eq(motion.dash.cooldown, motion.dash.cooldown_ticks)
	for i: int in motion.dash.cooldown_ticks:
		previous = 0  # present a fresh edge on every tick, including the final cooldown tick
		_step_taken = _press(Vector2.DOWN, &"dash")
		assert_eq(motion.dashes, 1)
	previous = 0
	_step_taken = _press(Vector2.DOWN, &"dash")
	assert_eq(motion.dashes, 2)


func test_holding_shift_sprints_only_when_enabled_and_never_repeats_the_dash() -> void:
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var row: Dictionary = table.object(table.raw, "dash")
	for hold: bool in [true, false]:
		row["hold_sprints"] = hold
		motion = PlayerMotion.from_table(table)
		previous = 0
		for i: int in 100:
			_step_taken = _press(Vector2.DOWN, &"dash")
		assert_eq(motion.dashes, 1)
		assert_eq(motion.sprinting, hold)
		assert_almost_eq(motion.velocity().length(), motion.sprint_mps if hold else WALK, 0.0001)
		_step_taken = _press(Vector2.ZERO, &"dash")
		assert_false(motion.sprinting)


func test_zero_configured_ticks_still_gives_one_tick_for_the_burst() -> void:
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var row: Dictionary = table.object(table.raw, "dash")
	row["ticks"] = 0
	motion = PlayerMotion.from_table(table)
	assert_eq(motion.dash.ticks, 1)


func test_disabled_dash_is_an_ordinary_walk_and_pad_sprint_still_works() -> void:
	motion.dash.enabled = false
	for i: int in 80:
		_step_taken = _press(Vector2.DOWN, &"dash")
	assert_eq(motion.dashes, 0)
	assert_false(motion.sprinting)
	assert_almost_eq(motion.velocity().length(), WALK, 0.0001)
	for i: int in 30:
		_step_taken = _press(Vector2.DOWN, &"sprint")
	assert_almost_eq(motion.velocity().length(), motion.sprint_mps, 0.0001)


func test_roll_and_recovery_consume_dash_presses() -> void:
	_step_taken = _press(Vector2.DOWN, &"roll")
	for i: int in motion.roll_ticks + motion.recovery_ticks - 1:
		previous = 0
		_step_taken = _press(Vector2.DOWN, &"dash")
	assert_eq(motion.dashes, 0)
	assert_eq(motion.rolls, 1)
