extends Scenario
## Lane human-reactions: the crowd's reactions to a death on a scripted street, stepped on the
## 60 Hz tick (CrowdReact over CharacterRigs, the path the city and the arena city use). A grid of
## walkers; two of them die (a round's travel names the fall), a fleeing runner crosses the first
## body. Pass: every living walker within STARTLE_M of a death cowers, once, away from the body
## (and nobody further out does); the cower clears on the table's length; the runner trips over
## the body exactly once; two runs give the same poses. Planted faults (TST-05): the startle
## radius 0 (the startle check must fail) and the trip radius 0 (the trip check must fail).

const COLS: int = 5
const ROWS: int = 3
const GAP_M: float = 1.2
const FIRST_ID: int = 100
const RUNNER_ID: int = 200
const RUNNER_MPS: float = 3.0
const RUNNER_X0_M: float = -6.0
## (tick, grid index) of each death: the centre walker, then the far corner after the first
## startle has cleared.
const DEATHS: Array[Vector2i] = [Vector2i(30, 7), Vector2i(300, 14)]
const TICKS: int = 420
const ROUND_VEL: Vector2 = Vector2(60.0, 0.0)


func run(_tree: SceneTree) -> String:
	var table: ReactTable = ReactTable.shipped()
	var ok: Dictionary = _street(table, CrowdReact.STARTLE_M, CrowdReact.TRIP_M)
	var again: Dictionary = _street(table, CrowdReact.STARTLE_M, CrowdReact.TRIP_M)
	var deaf: Dictionary = _street(table, 0.0, CrowdReact.TRIP_M)
	var sure: Dictionary = _street(table, CrowdReact.STARTLE_M, 0.0)
	var out: Dictionary = {
		"run": ok,
		"digest_again": again["digest"],
		"planted_no_startle": deaf,
		"planted_no_trip": sure,
		"cower_ticks_table": ceili(table.length(CrowdReact.COWER) / SimClock.TICK_DT),
	}
	Log.info("scenario", "crowd_react: %s" % out)
	var err: String = write_evidence("crowd-react.json", out)
	if err != "":
		return err
	var want_ticks: int = out["cower_ticks_table"]
	var bad: Array[String] = []
	_add(bad, _judge(ok, want_ticks))
	if ok["digest"] != again["digest"]:
		bad.append("two runs differ: %d vs %d" % [ok["digest"], again["digest"]])
	if _judge(deaf, want_ticks) == "":
		bad.append("planted fault (startle radius 0) not caught")
	if _judge(sure, want_ticks) == "":
		bad.append("planted fault (trip radius 0) not caught")
	return "; ".join(PackedStringArray(bad))


func _add(bad: Array[String], why: String) -> void:
	if why != "":
		bad.append(why)


func _judge(o: Dictionary, cower_ticks: int) -> String:
	var bad: Array[String] = []
	if o["startles"] != o["startles_want"] or o["startles_want"] < 4:
		bad.append("%d startles, want %d (>= 4)" % [o["startles"], o["startles_want"]])
	if o["away_dot_min"] < 0.95:
		bad.append("a startle cowers toward the body (min dot %.2f)" % o["away_dot_min"])
	if o["far_cowers"] > 0:
		bad.append("%d walkers beyond STARTLE_M cowered" % o["far_cowers"])
	var got_ticks: int = o["cower_ticks"]
	if o["startles"] > 0 and absi(got_ticks - cower_ticks) > 1:
		bad.append(
			"a cower cleared after %d ticks, the table says %d" % [o["cower_ticks"], cower_ticks]
		)
	if o["trips"] != 1 or o["deaths"] != DEATHS.size():
		bad.append(
			"%d trips (want 1), %d deaths (want %d)" % [o["trips"], o["deaths"], DEATHS.size()]
		)
	return "; ".join(PackedStringArray(bad))


func _walker_at(i: int) -> Vector2:
	return Vector2(i % COLS, floorf(float(i) / COLS)) * GAP_M * SimConst.PX_PER_M


func _runner_at(tick: int) -> Vector2:
	var x: float = RUNNER_X0_M + RUNNER_MPS * tick * SimClock.TICK_DT
	return Vector2(x, GAP_M) * SimConst.PX_PER_M


## One street run with the given radii; returns the counts the judge reads.
func _street(table: ReactTable, startle_m: float, trip_m: float) -> Dictionary:
	var c: CrowdReact = CrowdReact.make(table)
	c.startle_m = startle_m
	c.trip_m = trip_m
	var rigs: CharacterRigs = CharacterRigs.new()
	for i: int in COLS * ROWS:
		rigs._by_actor[FIRST_ID + i] = _rig(FIRST_ID + i)
	rigs._by_actor[RUNNER_ID] = _rig(RUNNER_ID)
	var o: Dictionary = {"startles_want": 0, "away_dot_min": 1.0, "far_cowers": 0}
	o["cower_ticks"] = 0
	var acc: PackedFloat32Array = PackedFloat32Array()
	var dead: Dictionary[int, bool] = {}
	for tick: int in TICKS:
		var dying: int = _dying_at(tick)
		if dying >= 0:
			dead[dying] = true
		rigs.feed = _feed(tick, dead, dying)
		c.observe(rigs)
		if dying >= 0:
			_read_startle(rigs, dead, dying, o)
		for id: int in rigs._by_actor:
			_step(rigs._by_actor[id], acc)
		_time_cower(rigs, o, tick)
	o["startles"] = c.startles
	o["trips"] = c.trips
	o["deaths"] = c.deaths
	o["digest"] = hash(acc.to_byte_array())
	for id: int in rigs._by_actor:
		rigs._by_actor[id].free()
	rigs.free()
	return o


func _rig(id: int) -> CutRig:
	var rig: CutRig = CutRig.new()
	rig.actor_id = id
	return rig


func _dying_at(tick: int) -> int:
	for d: Vector2i in DEATHS:
		if d.x == tick:
			return d.y
	return -1


## The street at `tick`: the walkers (the dead flagged, the one dying this tick carried along the
## round), the runner fleeing east through the first body's row.
func _feed(tick: int, dead: Dictionary[int, bool], dying: int) -> RigFeed:
	var f: RigFeed = RigFeed.new()
	for i: int in COLS * ROWS:
		var vel: Vector2 = ROUND_VEL if i == dying else Vector2.ZERO
		@warning_ignore("return_value_discarded")
		f.put(i, FIRST_ID + i, BodyPlan.Kind.PED, _walker_at(i), vel)
		f.flags[i] = RigFeed.Flag.DEAD if dead.has(i) else 0
	var run_vel: Vector2 = Vector2(RUNNER_MPS * SimConst.PX_PER_M, 0.0)
	var r: int = f.put(COLS * ROWS, RUNNER_ID, BodyPlan.Kind.PED, _runner_at(tick), run_vel)
	f.flags[r] = RigFeed.Flag.FLEE
	return f


## Right after a death: who should have cowered, did they, and away from the body?
func _read_startle(
	rigs: CharacterRigs, dead: Dictionary[int, bool], body: int, o: Dictionary
) -> void:
	var at: Vector2 = _walker_at(body)
	var reach: float = CrowdReact.STARTLE_M * SimConst.PX_PER_M
	for i: int in COLS * ROWS:
		if dead.has(i):
			continue
		var away: Vector2 = _walker_at(i) - at
		var r: HumanReact = rigs.rig_for(FIRST_ID + i).react
		var cowering: bool = r != null and r.kind == CrowdReact.COWER and r.t == 0.0
		if away.length() >= reach:
			o["far_cowers"] += 1 if cowering else 0
			continue
		o["startles_want"] += 1
		if cowering:
			var worst: float = o["away_dot_min"]
			o["away_dot_min"] = minf(worst, r.dir.dot(away.normalized()))


func _step(rig: CutRig, acc: PackedFloat32Array) -> void:
	var r: HumanReact = rig.react
	if r == null:
		acc.append_array([0.0, 0.0, 0.0])
		return
	r.pre(rig, SimClock.TICK_DT)
	acc.append_array([r.off.x, r.off.y, r.rot])


## Ticks the first death's east neighbour stays in its cower (it starts on the death tick; it is
## startled again by the second death, which is not counted).
func _time_cower(rigs: CharacterRigs, o: Dictionary, tick: int) -> void:
	var r: HumanReact = rigs.rig_for(FIRST_ID + DEATHS[0].y + 1).react
	var first: bool = tick >= DEATHS[0].x and tick < DEATHS[1].x
	if first and r != null and r.kind == CrowdReact.COWER and r.active():
		o["cower_ticks"] += 1
