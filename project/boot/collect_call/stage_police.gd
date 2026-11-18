class_name StagePolice
extends RefCounted
## The humans that can see Rivet: police patrols walking their loops while he is hot, and any
## dock guard still standing. Rivet in a hide spot is seen by nobody.
## n18 item 6, `--sim-police` (sim_police): on the city the stage's scripted patrols hand over to
## the city's sim cops (heat.json city.quest1_sim_police_cops kept by the city patrol); a sim cop
## with Rivet in sight (CityHeat.cop_sees) is then the patrol that sees him while he is hot.

## Off (the default) = the scripted stage patrols (quest 1's shipped path).
static var sim_police: bool = false


static func step_patrols(stage: CollectCallStage) -> void:
	if sim_police and stage.city_heat != null:
		_hand_over(stage)
		return
	for i: int in stage.layout.patrols.size():
		var p: StageLayout.Patrol = stage.layout.patrols[i]
		var goal: Vector2 = p.route[stage.patrol_leg[i]]
		stage.patrol_pos[i] = stage.patrol_pos[i].move_toward(goal, p.mps * SimClock.TICK_DT)
		if stage.patrol_pos[i].distance_to(goal) < 0.01:
			stage.patrol_leg[i] = (stage.patrol_leg[i] + 1) % p.route.size()


## A human has Rivet in sight this tick.
static func seen(stage: CollectCallStage) -> bool:
	if stage.hidden_in != "":
		return false
	var at: Vector2 = stage.arena.rivet.pos
	var sight: float = stage.heat.sight_m
	if stage.heat.level > 0:
		for p: Vector2 in stage.patrol_pos:
			if p.distance_to(at) <= sight:
				return true
		if sim_police and stage.city_heat != null:
			if CityHeat.cop_sees(stage.city_heat.city.sim, at, sight):
				return true
	for h: Fighter in stage.arena.hostiles:
		if h.alive() and h.pos.distance_to(at) <= sight * 2.0:
			return true
	return false


## The stage's heat this tick: a kill witnessed while hostiles live raises it one level; the
## stage's sighting steps the meter and goes to the city's sim police (n18 item 6, city_heat).
static func step_heat(stage: CollectCallStage) -> void:
	var witnessed: bool = stage.arena.kills_now > 0 and stage.arena.hostiles_alive() > 0
	var saw: bool = seen(stage)
	stage.heat.step(saw)
	if stage.city_heat != null:
		stage.city_heat.stage_seen = saw
	if witnessed:
		stage.heat.raise_by(1)


## --sim-police: the stage's patrols leave (nothing draws or moves them) and the city patrol keeps
## heat.json city.quest1_sim_police_cops instead (once; the count stays after).
static func _hand_over(stage: CollectCallStage) -> void:
	if stage.patrol_pos.is_empty():
		return
	stage.patrol_pos.clear()
	stage.patrol_leg.clear()
	stage.city_heat.patrol.want = stage.city_heat.tune.quest1_sim_police_cops
