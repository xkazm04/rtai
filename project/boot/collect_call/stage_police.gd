class_name StagePolice
extends RefCounted
## The humans that can see Rivet: police patrols walking their loops while he is hot, and any
## dock guard still standing. Rivet in a hide spot is seen by nobody.


static func step_patrols(stage: CollectCallStage) -> void:
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
	for h: Fighter in stage.arena.hostiles:
		if h.alive() and h.pos.distance_to(at) <= sight * 2.0:
			return true
	return false
