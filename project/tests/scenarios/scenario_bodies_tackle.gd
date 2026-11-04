extends Scenario
## features/bodies, the tackle: Rivet sprints (6 m/s) into a standing human. The table's
## rivet_base -> human run result is a knockdown: the human slides back, lies down_s, gets up
## and flees; Rivet keeps most of his speed and never overlaps him. Then a sprint into a
## `robot` (BodyContact, outside the city sim) is `blocked`: no overlap, Rivet stopped short.
## Planted faults (TST-05): the tackle disabled in the spec (no knockdown must be seen), and a
## table without the rivet_base -> robot row (load error and Rivet passes into the robot).

const SPRINT: Vector2 = Vector2(9.0, 0.0)  # under the 9.3 m/s sprint top, over the 7.5 line
const TOL: float = 0.02


func run(_tree: SceneTree) -> String:
	var human: Dictionary = _sprint_human(false)
	if human.has("error"):
		return human["error"]
	var planted: Dictionary = _sprint_human(true)
	var robot: Dictionary = _sprint_robot(BodyTable.load_default())
	var no_row: Dictionary = _sprint_robot(_table_without(&"rivet_base", &"robot"))
	Log.info(
		"scenario", "tackle: human %s; robot %s; planted %s / %s" % [human, robot, planted, no_row]
	)
	var err: String = write_evidence(
		"bodies-tackle.json",
		{
			"human": human,
			"robot": robot,
			"planted_no_tackle": planted,
			"planted_no_robot_row": no_row
		}
	)
	if err != "":
		return err
	return _judge_human(human, planted) + _judge_robot(robot, no_row)


func _judge_human(h: Dictionary, planted: Dictionary) -> String:
	if h["knocks"] != 1 or not h["went_down"]:
		return "the sprint did not knock the human down: %s" % h
	if h["slide_m"] < 1.0 or not h["got_up"] or not h["fled"]:
		return "no slide, get-up or flee: %s" % h
	if h["worst_rivet"] > TOL or h["keep"] < 0.6:
		return "Rivet overlapped or lost his speed: %s" % h
	if planted["knocks"] != 0:
		return "planted fault (tackle off) still knocked down: %s" % planted
	return ""


func _judge_robot(r: Dictionary, no_row: Dictionary) -> String:
	var through: bool = r["rivet_x_max"] > r["stop_x"] - r["rs"] + TOL or r["robot_moved_m"] > TOL
	if r["result"] != "blocked" or r["worst"] > TOL or through:
		return "the robot did not block Rivet: %s" % r
	if no_row["table_ok"] or no_row["worst"] <= TOL:
		return "planted fault (no rivet_base -> robot row) was not caught: %s" % no_row
	return ""


func _sprint_human(plant: bool) -> Dictionary:
	var st: BodiesStage = BodiesStage.new()
	var err: String = st.setup(20.0)
	if err != "":
		return {"error": err}
	var at: Vector2 = st.band + Vector2(6.0, 0.13)
	var slot: int = st.stand(at)
	var x0: float = st.body.pos.x
	var rule: BodyRule = st.table.rule(RivetBody.CLASS, RivetBody.PERSON)
	st.plant_no_tackle = plant
	var flags: PackedInt32Array = PackedInt32Array([0, 0, 0])  # went down, got up, fled
	var slide: float = 0.0
	var keep: float = 0.0
	for t: int in int((2.0 + rule.down_s + 1.5) * SimClock.TICK_RATE):
		st.tick(SPRINT if t < 2 * SimClock.TICK_RATE else Vector2.ZERO)
		if t == SimClock.TICK_RATE:
			keep = (st.body.pos.x - x0) / (SPRINT.x * 61.0 / SimClock.TICK_RATE)
		var p: PackedFloat64Array = st.person(slot)
		if p.is_empty():
			continue
		var mode: int = int(p[1])
		if mode == SimConst.M_DOWN:
			flags[0] = 1
			slide = Vector2(p[2], p[3]).distance_to(at)
		if flags[0] == 1 and mode == SimConst.M_FLEE:
			flags[1] = 1
			flags[2] = flags[2] | (1 if p[4] > 1.0 else 0)
	return {
		"knocks": st.knocks.size(),
		"went_down": flags[0] == 1,
		"got_up": flags[1] == 1,
		"fled": flags[2] == 1,
		"slide_m": slide,
		"keep": keep,
		"worst_rivet": st.worst_rivet,
	}


## Rivet sprints 2 s east (holding the stick) into a robot standing dead ahead 5 m away.
func _sprint_robot(table: BodyTable) -> Dictionary:
	var rivet: Vector2 = Vector2.ZERO
	var robot: Vector2 = Vector2(5.0, 0.0)
	var rs: float = table.radius(RivetBody.CLASS) + table.radius(&"robot")
	var result: String = ""
	var worst: float = -INF
	var x_max: float = -INF
	for t: int in 2 * SimClock.TICK_RATE:
		var want: Vector2 = rivet + SPRINT * SimClock.TICK_DT
		var c: BodyContact = BodyContact.resolve(
			table, RivetBody.CLASS, &"robot", PackedVector2Array([want, robot]), SPRINT
		)
		rivet = c.a_pos
		robot = c.b_pos
		if c.result != &"":
			result = String(c.result)
		worst = maxf(worst, rs - rivet.distance_to(robot))
		x_max = maxf(x_max, rivet.x)
	return {
		"result": result,
		"worst": worst,
		"rivet_x_max": x_max,
		"stop_x": robot.x,
		"rs": rs,
		"robot_moved_m": robot.distance_to(Vector2(5.0, 0.0)),
		"table_ok": table.ok(),
	}


## The shipped table with one rule removed (a planted fault).
static func _table_without(a: StringName, d: StringName) -> BodyTable:
	var t: DataTable = DataTable.open(BodyTable.PATH, BodyTable.SCHEMA)
	var raw: Dictionary = t.raw.duplicate(true)
	var keep: Array = []
	for r: Variant in raw["rules"]:
		var row: Dictionary = r
		if not (row["attacker"] == String(a) and row["defender"] == String(d)):
			keep.append(row)
	raw["rules"] = keep
	return BodyTable.from_table(DataTable.parse(JSON.stringify(raw), BodyTable.SCHEMA, "planted"))
