extends Scenario
## features/bodies: a tackled cop is still a cop. Rivet sprints (6 m/s) into a cop standing 6 m
## ahead (inside the cop's 7 m stand-and-shoot range): the cop is knocked down (M_DOWN, one
## knockdown), lies down_s, then resumes as a cop (M_WALK, chasing and shooting), never flees.
## Rivet never overlaps him. Planted fault (TST-05): the knockdown time 0 in the spec must fail
## the same verdict (no lying; he is re-tackled every tick instead).

const SPRINT: Vector2 = Vector2(9.0, 0.0)  # under the 9.3 m/s sprint top, over the 7.5 line
const TOL: float = 0.02


func run(_tree: SceneTree) -> String:
	var ok_run: Dictionary = _sprint(false)
	if ok_run.has("error"):
		return ok_run["error"]
	var planted: Dictionary = _sprint(true)
	Log.info("scenario", "cop tackle: %s; planted down_s 0: %s" % [ok_run, planted])
	var err: String = write_evidence("bodies-cop.json", {"cop": ok_run, "planted": planted})
	if err != "":
		return err
	var bad: String = _bad(ok_run)
	if bad != "":
		return bad
	if _bad(planted) == "":
		return "planted fault (down_s 0) was not caught: %s" % planted
	return ""


static func _bad(r: Dictionary) -> String:
	if r["knocks"] != 1 or r["down_ticks"] < 60 or not r["resumed"]:
		return "the cop was not knocked down once for down_s and back up: %s" % r
	if r["fled"] or r["worst_rivet"] > TOL:
		return "the cop fled or Rivet overlapped him: %s" % r
	return ""


func _sprint(plant: bool) -> Dictionary:
	var st: BodiesStage = BodiesStage.new()
	var err: String = st.setup(20.0)
	if err != "":
		return {"error": err}
	var slot: int = st.stand(st.band + Vector2(6.0, 0.1), SimConst.K_COP)
	var down: int = 0
	var flags: PackedInt32Array = PackedInt32Array([0, 0])  # resumed, fled
	st.plant_down_zero = plant
	for t: int in 5 * SimClock.TICK_RATE:
		st.tick(SPRINT if t < 90 else Vector2.ZERO)
		var p: PackedFloat64Array = st.person(slot)
		if p.is_empty():
			continue
		var mode: int = int(p[1])
		down += 1 if mode == SimConst.M_DOWN else 0
		if down > 0 and mode == SimConst.M_WALK:
			flags[0] = 1
		if mode == SimConst.M_FLEE:
			flags[1] = 1
	return {
		"knocks": st.knocks.size(),
		"down_ticks": down,
		"resumed": flags[0] == 1,
		"fled": flags[1] == 1,
		"worst_rivet": st.worst_rivet,
	}
