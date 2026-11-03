extends GutTest
## rivet-motion: the tackle chain end to end on data. PlayerMotion (rivet_motion.json) gives the
## closing speed, and the collisions lane's bodies.json rivet_base -> human rule decides the
## contact. A sprint from a standstill knocks a human down within MAX_RUN_UP_M; a walk into the
## same human never does. Planted faults: a run_mps above the sprint top (bodies.json) and a
## run-up shorter than the acceleration both miss the knockdown.

const WALK_MPS: float = 4.5
## The reel's run-up is 4.6 m; a sprint must tackle well inside an arena lane.
const MAX_RUN_UP_M: float = 3.0
const TICKS: int = 240

var actions: PlayerActions
var motion: PlayerMotion
var bodies: BodyTable


func before_each() -> void:
	actions = PlayerActions.shipped()
	motion = PlayerMotion.shipped()
	bodies = BodyTable.load_default()
	assert_true(bodies.ok(), str(bodies.errors()))


func test_a_sprint_from_a_stand_tackles_within_the_run_up() -> void:
	var run_up: float = _run_up_to_line(true)
	gut.p("rivet-motion: a sprint from a stand crosses run_mps after %.2f m" % run_up)
	assert_lt(run_up, MAX_RUN_UP_M, "the sprint crosses run_mps after %.2f m" % run_up)
	assert_eq(_contact(true, 4.6), &"knockdown", "the reel's 4.6 m run-up knocks down")


func test_a_walk_never_tackles() -> void:
	assert_eq(_run_up_to_line(false), INF, "the quest walk never crosses run_mps")
	assert_ne(_contact(false, 4.6), &"knockdown")


func test_planted_fault_run_mps_above_the_sprint_misses() -> void:
	var t: DataTable = DataTable.open(BodyTable.PATH, BodyTable.SCHEMA)
	for row: Variant in t.array(t.raw, "classes"):
		var c: Dictionary = row if row is Dictionary else {}
		if c.get("id", "") == "rivet_base":
			c["run_mps"] = motion.sprint_mps + 0.5
	bodies = BodyTable.from_table(t)
	assert_ne(_contact(true, 4.6), &"knockdown", "the fault is caught")


func test_planted_fault_a_short_run_up_misses() -> void:
	assert_ne(_contact(true, 0.5), &"knockdown", "half a metre is not enough to accelerate")


## Metres from a standstill until the speed crosses rivet_base's run_mps (INF: never).
func _run_up_to_line(sprint: bool) -> float:
	var line: float = bodies.run_mps(&"rivet_base")
	var travelled: float = 0.0
	for i: int in TICKS:
		travelled += motion.step(_cmd(sprint, i), WALK_MPS, actions).length()
		if motion.velocity().length() > line:
			return travelled
	return INF


## The rule's result when Rivet reaches a human `gap_m` ahead of his standstill.
func _contact(sprint: bool, gap_m: float) -> StringName:
	var travelled: float = 0.0
	var i: int = 0
	while travelled < gap_m and i < TICKS:
		travelled += motion.step(_cmd(sprint, i), WALK_MPS, actions).length()
		i += 1
	var closing: float = motion.velocity().dot(Vector2.RIGHT)
	var rule: BodyRule = bodies.rule(&"rivet_base", &"human")
	return rule.result(closing, bodies.run_mps(&"rivet_base"))


func _cmd(sprint: bool, i: int) -> PlayerCommand:
	var c: PlayerCommand = PlayerCommand.new()
	c.move = Vector2.RIGHT
	c.aim = Vector2.ZERO
	c.held = (1 << actions.bit(&"sprint")) if sprint else 0
	c.pressed = c.held if i == 0 else 0
	return c
