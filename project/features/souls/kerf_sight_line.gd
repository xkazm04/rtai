class_name KerfSightLine
extends Node2D
## n31 ghost 21: through Kerf's drop wind-up, the ghost's own thin teal beam (ink under-stroke)
## from Kerf to the locked target, growing over the wind-up (KerfDropBeats.sight_k) and
## following the target, plus KerfView's white lock brackets on it from the arrival's end.

const LINE_ALPHA: float = 0.6
const START_M: float = 0.3
const GAP_M: float = 0.15

var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _radius: float = 0.0
var _k: float = 0.0
var _locked: bool = false


## Read the deploy this tick; nothing shows outside a Kerf drop's wind-up with a live lock.
func show_for(ghost: GhostDeploy, age: int) -> void:
	var foe: Fighter = ghost.dump.kerf.target
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy.get(ghost.form)
	_k = 0.0
	if ghost.form == KerfStage.GHOST and row != null and row.drops() and foe != null:
		if ghost.dump.pending() and foe.alive():
			_k = KerfDropBeats.sight_k(age, row.charge_ticks)
			_from = KerfDropBeats.at(ghost, age, -1)
			_to = foe.pos
			_radius = foe.radius_m
			_locked = age >= KerfDropBeats.ARRIVE_TICKS
	visible = _k > 0.0
	queue_redraw()


func _draw() -> void:
	if _k <= 0.0:
		return
	var ppm: float = SimConst.PX_PER_M
	var dir: Vector2 = _from.direction_to(_to)
	var end: float = _from.distance_to(_to) - _radius - GAP_M
	if end > START_M:
		var a_px: Vector2 = (_from + dir * START_M) * ppm
		var b_px: Vector2 = (_from + dir * lerpf(START_M, end, _k)) * ppm
		draw_line(a_px, b_px, Color(KerfView.INK, 0.5), 4.0, true)
		draw_line(a_px, b_px, Color(KerfView.TEAL, LINE_ALPHA), 2.0, true)
	if not _locked:
		return
	var c: Vector2 = _to * ppm
	var r: float = (_radius + KerfView.SIGHT_LOCK_M) * ppm
	var at: float = dir.rotated(deg_to_rad(KerfView.CUT_DEG)).angle()
	for side: float in [at, at + PI]:  # the lock: two brackets at the cut line's ends
		var span: Vector2 = Vector2(side - KerfView.SIGHT_ARC, side + KerfView.SIGHT_ARC)
		draw_arc(c, r, span.x, span.y, 8, Color(KerfView.INK, 0.6), 4.0, true)
		draw_arc(c, r, span.x, span.y, 8, Color(KerfView.WHITE, 1.0), 1.8, true)
