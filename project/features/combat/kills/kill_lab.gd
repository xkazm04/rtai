class_name KillLab
extends RefCounted
## The signature-kill lab (lane brutality, arena arg `--sig-lab`, dev capture only): a line of
## contractors stands in front of Rivet at the hub and he fires his `--sig-gun` at the next one
## every SHOT_EVERY ticks, so each kill plays framed in the camera at any zoom. The guards hold
## their fire (their cooldown is pinned). When the line is down, a new line steps in.

const SHOT_EVERY: int = 110
const FIRST_SHOT: int = 60
## The line, metres from Rivet's start: in front of him and a little to each side.
const LINE: PackedVector2Array = [
	Vector2(2.5, 1.5),
	Vector2(3.0, 3.0),
	Vector2(2.0, 3.5),
	Vector2(3.5, 2.0),
	Vector2(2.2, 2.5),
	Vector2(3.2, 4.2)
]
const HOLD_FIRE: int = 100000

var guards: Array[Fighter] = []
## Each guard's mark (they stand on it: no walk-in, no spawn spread).
var spots: PackedVector2Array = PackedVector2Array()
var shots: int = 0
var _next: int = 0


func setup(stage: ArenaStage) -> void:
	_line(stage)


func step(stage: ArenaStage, tick: int) -> void:
	for n: int in guards.size():
		var g: Fighter = guards[n]
		g.cooldown = HOLD_FIRE
		g.tell_left = 0
		if g.alive():
			g.pos = spots[n]
	if tick < FIRST_SHOT or (tick - FIRST_SHOT) % SHOT_EVERY != 0:
		return
	var target: Fighter = _target()
	if target == null:
		_line(stage)
		return
	if stage.arena.rivet_fire(target.pos):
		shots += 1


func _target() -> Fighter:
	for n: int in guards.size():
		var g: Fighter = guards[(_next + n) % guards.size()]
		if g.alive():
			_next = (_next + n + 1) % guards.size()
			return g
	return null


func _line(stage: ArenaStage) -> void:
	guards.clear()
	spots.clear()
	_next = 0
	for off: Vector2 in LINE:
		var g: Fighter = stage.arena.spawn_guard(stage.plan.rivet_start + off)
		g.pos = stage.plan.rivet_start + off
		g.cooldown = HOLD_FIRE
		@warning_ignore("return_value_discarded")
		spots.append(g.pos)
		guards.append(g)
