extends GutTest
## rivet-motion: sprint and the dodge roll (rivet_motion.json). The held sprint crosses the 5.0 m/s
## tackle line (bodies.json); the roll covers exactly roll_m, is invulnerable only on its window,
## damps the stick in recovery and cannot be chained before the cooldown. Planted faults: an
## i-frame window outside the roll is a table error; a sprint at walk speed misses the line.

const TACKLE_LINE_MPS: float = 5.0
const WALK_MPS: float = 4.5

var actions: PlayerActions
var motion: PlayerMotion
var _drop: Vector2 = Vector2.ZERO


func before_each() -> void:
	actions = PlayerActions.shipped()
	motion = PlayerMotion.shipped()
	assert_true(motion.errors.is_empty(), str(motion.errors))


func test_sprint_crosses_the_tackle_line_walk_does_not() -> void:
	assert_lt(_top_speed(false), TACKLE_LINE_MPS, "the quest walk shoves, never tackles")
	assert_gt(_top_speed(true), TACKLE_LINE_MPS, "a held sprint tackles")


func test_planted_fault_sprint_at_walk_speed_misses_the_line() -> void:
	motion.sprint_mps = WALK_MPS
	assert_lt(_top_speed(true), TACKLE_LINE_MPS, "the fault is caught")


func test_sprint_faces_the_walk_not_the_aim() -> void:
	var run: Array[String] = ["sprint"]
	for _i: int in 90:
		_drop = motion.step(_cmd(Vector2.RIGHT, Vector2.LEFT, run, _bits(run)), WALK_MPS, actions)
	assert_gt(motion.facing().dot(Vector2.RIGHT), 0.99)
	assert_true(motion.sprinting)


func test_roll_covers_roll_m_with_an_iframe_window() -> void:
	var dodge: Array[String] = ["roll"]
	var moved: Vector2 = motion.step(_cmd(Vector2.UP, Vector2.ZERO, dodge, 0), 0.0, actions)
	var invuln: Array[int] = [1 if motion.invulnerable() else 0]
	for _i: int in motion.roll_ticks - 1:
		moved += motion.step(_cmd(Vector2.UP, Vector2.ZERO, dodge, _bits(dodge)), 0.0, actions)
		invuln.append(1 if motion.invulnerable() else 0)
	assert_almost_eq(moved.length(), motion.roll_m, 0.001, "exactly roll_m")
	assert_eq(invuln.find(1), motion.iframe_from)
	assert_eq(invuln.rfind(1), motion.iframe_to)
	assert_eq(motion.phase, PlayerMotion.Phase.RECOVER)


func test_roll_cannot_chain_until_the_cooldown() -> void:
	var dodge: Array[String] = ["roll"]
	var mash: int = motion.roll_ticks + motion.recovery_ticks + motion.cooldown_ticks - 1
	for _i: int in mash:
		_drop = motion.step(_cmd(Vector2.RIGHT, Vector2.ZERO, dodge, 0), WALK_MPS, actions)
	assert_eq(
		motion.rolls, 1, "a press on every tick of the roll, recovery and cooldown is ignored"
	)
	_drop = motion.step(_cmd(Vector2.RIGHT, Vector2.ZERO, dodge, 0), WALK_MPS, actions)
	assert_eq(motion.rolls, 2, "the first press after the cooldown rolls")


func test_planted_fault_iframes_past_the_roll_is_an_error() -> void:
	var t: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var roll: Dictionary = t.object(t.raw, "roll")
	roll["iframe_to"] = roll["roll_ticks"]
	assert_false(PlayerMotion.from_table(t).errors.is_empty(), "the fault is caught")


func _top_speed(sprint: bool) -> float:
	var held: Array[String] = []
	if sprint:
		held.append("sprint")
	for _i: int in 120:
		_drop = motion.step(_cmd(Vector2.DOWN, Vector2.ZERO, held, _bits(held)), WALK_MPS, actions)
	return motion.velocity().length()


func _cmd(move: Vector2, aim: Vector2, held: Array[String], previous: int) -> PlayerCommand:
	var c: PlayerCommand = PlayerCommand.new()
	c.move = move
	c.aim = aim
	c.held = _bits(held)
	c.pressed = c.held & ~previous
	return c


func _bits(names: Array[String]) -> int:
	var out: int = 0
	for n: String in names:
		out |= 1 << actions.bit(StringName(n))
	return out
