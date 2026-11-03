extends Scenario
## features/bodies, the other direction: a human RUNNING into Rivet (4.5 m/s, faster than the
## tackle speed) is `blocked` by the table (human -> rivet_base run), so the human takes the whole
## overlap and steps aside: Rivet, standing still, is not moved and never overlapped. Planted fault
## (TST-05): the run-in rule off in the spec, so the mass split shoves Rivet back.

const RUN_MPS: float = 4.5
const TOL: float = 0.02
## Glancing contacts after the runner steps aside are walk shoves (the mass split): a few cm.
const MAX_PUSH_M: float = 0.15


func run(_tree: SceneTree) -> String:
	var ok_run: Dictionary = _run_in(false)
	if ok_run.has("error"):
		return ok_run["error"]
	var planted: Dictionary = _run_in(true)
	Log.info("scenario", "run-in: %s; planted (rule off): %s" % [ok_run, planted])
	var err: String = write_evidence("bodies-runin.json", {"run_in": ok_run, "planted": planted})
	if err != "":
		return err
	if ok_run["rivet_pushed_m"] > MAX_PUSH_M or ok_run["worst_rivet"] > TOL:
		return "a running human moved Rivet or overlapped him: %s" % ok_run
	if not ok_run["met"]:
		return "the runner never reached Rivet: %s" % ok_run
	if planted["rivet_pushed_m"] <= MAX_PUSH_M:
		return "planted fault (run-in rule off) was not caught: %s" % planted
	return ""


func _run_in(plant: bool) -> Dictionary:
	var st: BodiesStage = BodiesStage.new()
	var err: String = st.setup(20.0)
	if err != "":
		return {"error": err}
	st.plant_no_run_in = plant
	var home: Vector2 = st.band + Vector2(10.0, 0.0)
	st.body.pos = home
	var slot: int = st.walker(home + Vector2(6.0, 0.05), Vector2.LEFT, RUN_MPS)
	var met: bool = false
	for t: int in 3 * SimClock.TICK_RATE:
		st.tick(Vector2.ZERO)
		var p: PackedFloat64Array = st.person(slot)
		if not p.is_empty() and Vector2(p[2], p[3]).distance_to(st.body.pos) < 0.8:
			met = true
	return {
		"met": met,
		"rivet_pushed_m": st.body.pos.distance_to(home),
		"worst_rivet": st.worst_rivet,
		"knocks": st.knocks.size(),
	}
