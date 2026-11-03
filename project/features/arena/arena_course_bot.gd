class_name ArenaCourseBot
extends InputSource
## The course station's scripted player (deterministic: it reads only the sim): from the hub,
## weave the slalom cones (passing each on the side away from it), then run the narrow corridor
## end to end at full stick. `finished_tick` is when the last waypoint was reached (the course
## time); its TickInputs go through the same InputTape as live play, so a run replays.

const REACH_M: float = 0.6
## Hub-relative waypoints: the slalom (cones at x -8..-28, y 0 / 2.5), round the corridor's
## lower wall (the walls collide), then the corridor (y 9.7).
const PATH: Array[Vector2] = [
	Vector2(-4.0, 1.2),
	Vector2(-8.0, -1.2),
	Vector2(-12.0, 3.7),
	Vector2(-16.0, -1.2),
	Vector2(-20.0, 3.7),
	Vector2(-24.0, -1.2),
	Vector2(-28.0, 3.7),
	Vector2(-10.5, 6.5),
	Vector2(-10.5, 9.7),
	Vector2(-21.0, 9.7),
]

var stage: ArenaStage
## 1.0 drives; 0.0 plants the scenario's fault (the stick never moves).
var stick_scale: float = 1.0
var next: int = 0
var finished_tick: int = -1


func _init(p_stage: ArenaStage) -> void:
	stage = p_stage


func sample(tick: int) -> TickInput:
	if next >= PATH.size():
		return TickInput.new()
	var goal: Vector2 = stage.plan.base + PATH[next]
	var to: Vector2 = goal - stage.arena.rivet.pos
	if to.length() <= REACH_M:
		next += 1
		if next >= PATH.size():
			finished_tick = tick
			return TickInput.new()
		goal = stage.plan.base + PATH[next]
		to = goal - stage.arena.rivet.pos
	var m: Vector2 = to.normalized() * stick_scale * TickInput.AXIS_MAX
	return TickInput.new(0, roundi(m.x), roundi(m.y))
