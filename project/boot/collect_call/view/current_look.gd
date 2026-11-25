class_name CurrentLook
extends RefCounted
## Quest 1's electric draws in amber current, never vermilion (colour law: vermilion is danger,
## objectives and Rivet's collar). The tazer prongs and the burst arcs are ElectricArc live current
## (the same shape and strokes WeaponFxElectro.chain_plan uses, without its star); the tazer
## stripe and the TUCK-IN bolt glyph are flat amber.

const STRIPE: Color = Ink.AMBER
const BOLT: Color = Ink.AMBER
const BOLT_PX: float = 3.0
const STRIPE_PX: float = 4.0


## One polyline pass: view-px points, colour, width (screen px).
class Pass:
	extends RefCounted
	var points: PackedVector2Array
	var color: Color
	var width: float

	func _init(p: PackedVector2Array, s: ElectricArc.Stroke) -> void:
		points = p
		color = s.color
		width = s.width


## The live-current strokes from `a` to `b` (m) as view-px polylines; `phase` re-jags them on
## ElectricArc's cell. `k` = 1 / screen scale. No RNG: the kinks hash the ends and the phase.
static func plan(a: Vector2, b: Vector2, phase: int, k: float = 1.0) -> Array[Pass]:
	var pts: PackedVector2Array = ElectricArc.shape(
		PackedVector2Array([a, b]), _serial(a, b), phase * 2, false
	)
	var px: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in pts:
		@warning_ignore("return_value_discarded")
		px.append(Ink.px(p))
	var out: Array[Pass] = []
	for s: ElectricArc.Stroke in ElectricArc.strokes(k):
		out.append(Pass.new(px, s))
	return out


## Draws the current on `ci` at its screen scale.
static func draw(ci: CanvasItem, a: Vector2, b: Vector2, phase: int) -> void:
	var scale: float = 1.0
	if ci.is_inside_tree():
		scale = ci.get_global_transform_with_canvas().get_scale().x
	for l: Pass in plan(a, b, phase, 1.0 / maxf(0.01, scale)):
		ci.draw_polyline(l.points, l.color, l.width, true)


static func _serial(a: Vector2, b: Vector2) -> int:
	var q: Vector2i = Vector2i((a * 4.0).floor()) * 31 + Vector2i((b * 4.0).floor())
	return posmod(q.x * 7 + q.y * 13, 997)
