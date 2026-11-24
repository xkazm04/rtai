extends "res://dev/cast/cast_feet.gd"
## The contractor's body jump through a stop, a turn and a reversal (aim one way, step the other).
## Takes are stored in cast_feet's tracks file; tools/art/cast_contractor_transitions.py reads them.

const SPEED: float = 3.0
const LEAD: int = 30


func _portrait(subject: Fighter, id: String) -> bool:
	if id != "contractor":
		return true
	for other: Fighter in _arena.hostiles:
		other.pos = PARK
	_arena.rivet.pos = MARK + Vector2.RIGHT * 10.0
	var host: ArenaRigs
	for child: Node in _scene.get_children():
		if child is ArenaRigs:
			host = child
	if host == null:
		return false
	for kind: String in ["stop", "turn", "reversal"]:
		for facing: String in ["right", "down_right"]:
			var take: Dictionary = {
				"archetype": id,
				"pitch": _pitch,
				"ppm": _ppm,
				"gait": kind,
				"speed_mps": SPEED,
				"facing": facing,
				"host": "near",
				"frames": []
			}
			if not await _run(subject, host, take):
				return false
			_takes.append(take)
	subject.pos = PARK
	return true


func _run(h: Fighter, host: ArenaRigs, take: Dictionary) -> bool:
	var dir: Vector2 = Vector2.RIGHT if take.facing == "right" else Vector2(1, 1).normalized()
	h.pos = MARK
	h.facing = dir
	for tick: int in 24:
		await _advance()
	var mark: Vector2 = get_viewport().get_canvas_transform() * (MARK * SimConst.PX_PER_M)
	take.ground_mark = [mark.x, mark.y]
	var frames: Array = take.frames
	for tick: int in LEAD * 4:
		var step: Vector2 = dir * SPEED * SimClock.TICK_DT
		match take.gait:
			"stop":
				step = step if tick < LEAD else Vector2.ZERO
			"turn":
				var swing: float = clampf(float(tick - LEAD) / 20.0, 0.0, 1.0) * PI * 0.5
				h.facing = dir.rotated(swing)
				step = h.facing * SPEED * SimClock.TICK_DT
			"reversal":
				step = -step if tick >= LEAD else step
		h.pos += step
		await _advance()
		frames.append(CastFeetFrame.sample(host, h))
	return true
