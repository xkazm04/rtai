class_name ServoSpine
extends RefCounted
## The target's central spine (docs/bosses/servo.md section 1): from straight above, a cream
## column splits the two rack wings from their back edge down to the hub, capped at the back by
## a panel box whose two copper hose loops arc out past the rack (the head part's art reused,
## smaller). Before, the wings met in the middle and the hub sat in front of them, so the top view
## lost the sheet's three-block read (wing | spine | wing). Render only: drawn by ServoRig over
## the wings' inner edges (their striped side panels) and under the torso; the rack's cells and
## the fight are untouched. Colours are sampled from the part art.

## Metres along the facing: the wings' back edge with the 3-row rack, and the spine's front end
## (under the torso).
const BACK_M: float = 2.15
const FRONT_M: float = 0.2
const WIDTH_M: float = 0.56
const BAND_M: float = 0.09
const RIM_M: float = 0.05
const RIVET_STEP_M: float = 0.32
## The back cap: the head art at this width (metres), its centre this far in from the back edge
## (negative: out past it, so the hose loops break the rack's back edge like the sheet's).
const CAP_W_M: float = 0.74
const CAP_IN_M: float = -0.08
const ART_PPM: float = 96.0
const CREAM: Color = Color8(234, 197, 149)
const SHADE: Color = Color8(192, 159, 126)
const INK: Color = Color8(27, 22, 26)
## The wide spine (gap_m over PLATED_FROM_M) reads as the sheet's armoured body: plate seams
## across it every PLATE_M, a raised centre plate, and a copper hose down each side.
const PLATED_FROM_M: float = 0.2
const PLATE_M: float = 0.48
const PLATE: Color = Color8(247, 224, 190)
const COPPER: Color = Color8(178, 92, 48)

var px: float = 32.0
## The wings' extra gap (servo.json rack.spine_m): the column widens by it to fill the gap.
var gap_m: float = 0.0
## The cap art (ServoRig's head part).
var cap: Texture2D = null
var _tint: Color = Color.WHITE


func draw(c: CanvasItem, o: Vector2, fwd: Vector2, k: float, tint: Color) -> void:
	var side: Vector2 = fwd.orthogonal()
	var back: Vector2 = o - fwd * BACK_M * k
	var front: Vector2 = o + fwd * FRONT_M * k
	var w: float = WIDTH_M + gap_m
	var half: Vector2 = side * w * 0.5 * k
	var grow: Vector2 = side * RIM_M * k
	c.draw_colored_polygon(_quad(back, front, half + grow, fwd * RIM_M * k), INK * tint)
	c.draw_colored_polygon(_quad(back, front, half, Vector2.ZERO), SHADE * tint)
	var inner: Vector2 = half - side * BAND_M * k
	c.draw_colored_polygon(_quad(back, front, inner, Vector2.ZERO), CREAM * tint)
	c.draw_line(back * px, front * px, SHADE * tint, 0.05 * k * px)
	var n: int = floori((BACK_M + FRONT_M) / RIVET_STEP_M)
	for i: int in range(2, n):
		var p: Vector2 = back + fwd * RIVET_STEP_M * i * k
		for s: float in [-1.0, 1.0]:
			var at: Vector2 = p + side * s * (w * 0.5 - BAND_M * 0.5) * k
			c.draw_circle(at * px, 0.028 * k * px, INK * tint)
	if gap_m > PLATED_FROM_M:
		_tint = tint
		_plates(c, back, front, inner, k)
	if cap != null:
		var ck: float = (CAP_W_M + gap_m * 0.6) / (cap.get_width() / ART_PPM) * k
		c.draw_set_transform(
			(back + fwd * CAP_IN_M * k) * px, fwd.angle() - PI / 2, Vector2(ck, ck) * px / ART_PPM
		)
		c.draw_texture(cap, -cap.get_size() * 0.5, tint)
		c.draw_set_transform(Vector2.ZERO)


## The wide spine's plating (gap_m over PLATED_FROM_M), over the cream fill; `_tint` is draw's.
func _plates(c: CanvasItem, back: Vector2, front: Vector2, inner: Vector2, k: float) -> void:
	var fwd: Vector2 = (front - back).normalized()
	var tint: Color = _tint
	var len_m: float = (BACK_M + FRONT_M) * k
	var seam: float = 0.035 * k * px
	for i: int in range(1, floori(len_m / (PLATE_M * k)) + 1):
		var p: Vector2 = back + fwd * PLATE_M * i * k
		c.draw_line((p - inner * 0.82) * px, (p + inner * 0.82) * px, SHADE * tint, seam)
	var a: Vector2 = back + fwd * 0.35 * k
	var b: Vector2 = front - fwd * 0.2 * k
	c.draw_colored_polygon(_quad(a, b, inner * 0.5, fwd * 0.03 * k), INK * tint)
	c.draw_colored_polygon(_quad(a, b, inner * 0.44, Vector2.ZERO), PLATE * tint)
	var side: Vector2 = inner.normalized()
	for s: float in [-1.0, 1.0]:
		var pts: PackedVector2Array = PackedVector2Array()
		@warning_ignore("return_value_discarded")
		pts.resize(9)
		for j: int in 9:
			var t: float = j / 8.0
			var at: Vector2 = back.lerp(front, 0.12 + 0.6 * t)
			at += side * s * (inner.length() * 0.72 + sin(t * PI) * 0.1 * k)
			pts[j] = at * px
		c.draw_polyline(pts, INK * tint, 0.1 * k * px)
		c.draw_polyline(pts, COPPER * tint, 0.06 * k * px)


func _quad(a: Vector2, b: Vector2, half: Vector2, grow: Vector2) -> PackedVector2Array:
	return PackedVector2Array(
		[
			(a - half - grow) * px,
			(a + half - grow) * px,
			(b + half + grow) * px,
			(b - half + grow) * px
		]
	)
