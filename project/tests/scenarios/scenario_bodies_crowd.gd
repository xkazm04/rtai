extends Scenario
## features/bodies, the owner's rule (2026-11-03): Rivet in his base form never goes through a
## character. He walks (1.4 m/s) east along a sidewalk through a standing crowd of 15 peds; on
## EVERY tick no live person may be closer to him than the sum of the table radii minus TOL.
## A walk shoves (no knockdowns), the crowd parts, and Rivet still gets through. Two planted
## faults must fail the same check (TST-05): his radius 0 in the sim spec, and the body switched
## off (the pre-bodies behaviour: Rivet walked through everyone; its overlap is "before").

const TOL: float = 0.02
const WALK: Vector2 = Vector2(1.4, 0.0)
const TICKS: int = 14 * SimClock.TICK_RATE
const MIN_PROGRESS: float = 0.6
## Rivet's top walk in quest 1 (combat.json rivet walk_mps): still a walk, so still no knockdown.
const QUEST_WALK_MPS: float = 6.75


func run(_tree: SceneTree) -> String:
	var ok_run: Dictionary = _walk(false, false)
	if ok_run.has("error"):
		return ok_run["error"]
	var zero_r: Dictionary = _walk(true, false)
	var off: Dictionary = _walk(false, true)
	var quest: Dictionary = _walk(false, false, QUEST_WALK_MPS)
	if quest["knocks"] != 0 or quest["worst_rivet"] > TOL:
		return "the quest walk (%.1f m/s) tackled or overlapped: %s" % [QUEST_WALK_MPS, quest]
	var summary: String = (
		(
			"crowd walk: worst Rivet overlap %.4f m (tol %.2f), people-people %.3f m, "
			% [ok_run["worst_rivet"], TOL, ok_run["worst_people"]]
		)
		+ (
			"progress %.1f/%.1f m, knockdowns %d; planted r=0 %.3f m, body off (before) %.3f m"
			% [
				ok_run["progress"],
				_free(),
				ok_run["knocks"],
				zero_r["worst_rivet"],
				off["worst_rivet"],
			]
		)
	)
	Log.info("scenario", summary)
	var err: String = write_evidence(
		"bodies-crowd.json",
		{
			"after": ok_run,
			"planted_radius_zero": zero_r,
			"before_body_off": off,
			"quest_walk_4_5": quest,
		}
	)
	return err if err != "" else _judge(ok_run, zero_r, off, summary)


static func _judge(
	ok_run: Dictionary, zero_r: Dictionary, off: Dictionary, summary: String
) -> String:
	if ok_run["worst_rivet"] > TOL:
		return "Rivet overlapped a person: %s" % summary
	if ok_run["knocks"] != 0:
		return "a walk knocked someone down: %s" % summary
	if ok_run["progress"] < MIN_PROGRESS * _free():
		return "the crowd did not part: %s" % summary
	if zero_r["worst_rivet"] <= TOL or off["worst_rivet"] <= TOL:
		return "a planted fault was not caught: %s" % summary
	return ""


## The distance Rivet walks with nobody in the way, metres.
static func _free() -> float:
	return WALK.x * TICKS / SimClock.TICK_RATE


func _walk(radius_zero: bool, body_off: bool, mps: float = WALK.x) -> Dictionary:
	var st: BodiesStage = BodiesStage.new()
	var err: String = st.setup(26.0)
	if err != "":
		return {"error": err}
	st.plant_radius_zero = radius_zero
	st.plant_body_off = body_off
	for col: int in 5:
		for row: int in range(-1, 2):
			@warning_ignore("return_value_discarded")
			st.stand(st.band + Vector2(6.0 + col * 2.5, row * 0.9))
	var x0: float = st.body.pos.x
	for t: int in TICKS:
		st.tick(Vector2(mps, 0.0))
	return {
		"backend": String(st.sim.backend_name()),
		"worst_rivet": st.worst_rivet,
		"worst_people": st.worst_people,
		"progress": st.body.pos.x - x0,
		"knocks": st.knocks.size(),
		"band": [st.band.x, st.band.y],
	}
