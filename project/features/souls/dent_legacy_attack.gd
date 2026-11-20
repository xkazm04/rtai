class_name DentLegacyAttack
extends RefCounted
## The ground rig retains its original tether, heat halo and blast.

const SEGMENTS: int = 14
const SAG_M: float = 0.6
const WARM: Color = Color("#C9822E")


func held(view: DentView) -> void:
	var rivet: Fighter = view.stage.arena.rivet
	var hands: Vector2 = (rivet.pos + rivet.facing.normalized() * DentView.HANDS_M) * view.ppm
	var car: Vector2 = view.dent.car.pos * view.ppm
	_halo(view, car, view.dent.heat)
	_tether(view, hands, car)


func _tether(view: DentView, a: Vector2, b: Vector2) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var side: Vector2 = (b - a).orthogonal().normalized()
	for i: int in SEGMENTS + 1:
		var t: float = float(i) / SEGMENTS
		var sag: float = sin(t * PI) * SAG_M * view.ppm * 0.4
		var shake: float = (
			0.0 if view.reduced_motion else sin(view.stage.tick * 0.9 + i * 1.7) * 2.0
		)
		@warning_ignore("return_value_discarded")
		pts.push_back(a.lerp(b, t) + side * (sag + shake))
	view.draw_polyline(pts, Color(DentView.INK, 0.7), 5.0)
	view.draw_polyline(pts, DentView.TEAL, 2.0)
	view.draw_circle(b, 4.0, DentView.TEAL)


func _halo(view: DentView, c: Vector2, heat: float) -> void:
	var armed: bool = heat >= view.dent.num(&"arm_k")
	var rate: float = 0.5 if armed else 0.2
	var pulse: float = 0.5 + 0.5 * sin(view.stage.tick * rate) if not view.reduced_motion else 0.6
	var col: Color = WARM.lerp(DentView.HOT, heat)
	var r: float = (1.6 + 0.4 * heat) * view.ppm
	view.draw_circle(c, r, Color(col, (0.1 + 0.3 * heat) * (0.6 + 0.4 * pulse)))
	view.draw_arc(c, r, 0.0, TAU, 40, Color(col, 0.4 + 0.5 * heat), 2.0 + 2.0 * heat)


func blast(view: DentView, c: Vector2, k: float) -> void:
	var r: float = view.dent.num(&"blast_radius_m") * view.ppm * (1.0 - pow(1.0 - k, 3.0))
	if not view.reduced_motion:
		view._fireball(c, r * 0.7, k)
	view.draw_arc(c, r, 0.0, TAU, 48, Color(DentView.INK, 1.0 - k), lerpf(10.0, 2.0, k))
