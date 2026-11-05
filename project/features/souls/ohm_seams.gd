class_name OhmSeams
extends Node2D
## ghost-forms: Ohm's soul seams at game zoom (TARGETS.md: "teal soul seams and glow marking it as
## possessed"). The shell art carries hairline teal seams that a 0.8 m dome loses at 32 px/m (it
## read as an olive blob on asphalt), so this draws the shell's three main plate seams and the two
## goggle lenses as bold teal strokes over it. A child of the shell sprite, so it draws in the
## shell texture's pixels (centred, goggles toward +x) and turns, kicks and morphs with it. Teal
## belongs to the souls. The dev flag `--no-seams` hides it (the A/B before).

const TEAL: Color = GhostMorphFx.TEAL
const TEAL_HI: Color = GhostMorphFx.TEAL_HI
## Stroke width in shell texture px (the 393 px shell is 0.8 m: 23 px = about 1.5 screen px at 32).
const SEAM_W: float = 22.0
const SEAM_ALPHA: float = 0.85
## The goggles in shell texture px from the centre, and the lens radius.
const GOGGLES: Array[Vector2] = [Vector2(152.0, -56.0), Vector2(157.0, 38.0)]
const LENS_R: float = 27.0
## The two plate rows' seams (y, texture px) and the spine seam (x), each bowed with the dome.
const ROW_Y: Array[float] = [-62.0, 56.0]
const SPINE_X: float = -28.0
const HALF_W: float = 176.0
const BOW: float = 0.18
const POINTS: int = 9


func _ready() -> void:
	visible = not OS.get_cmdline_user_args().has("--no-seams")


func _draw() -> void:
	var c: Color = Color(TEAL, SEAM_ALPHA)
	for y: float in ROW_Y:
		draw_polyline(_row(y), c, SEAM_W, true)
	draw_polyline(_spine(), c, SEAM_W, true)
	for g: Vector2 in GOGGLES:
		draw_circle(g, LENS_R, Color(TEAL, 0.95))
		draw_circle(g, LENS_R * 0.5, TEAL_HI)


## A row seam across the dome, bowed toward its pole, stopping short of the goggles.
func _row(y: float) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	var x0: float = -HALF_W * 0.92
	var x1: float = 112.0
	for i: int in POINTS:
		var x: float = lerpf(x0, x1, float(i) / float(POINTS - 1))
		var u: float = x / HALF_W
		@warning_ignore("return_value_discarded")
		pts.append(Vector2(x, y * (1.0 + BOW * (1.0 - u * u))))
	return pts


## The spine seam front to back over the dome's crown (bowed toward the back).
func _spine() -> PackedVector2Array:
	var pts: PackedVector2Array = []
	for i: int in POINTS:
		var v: float = lerpf(-0.9, 0.9, float(i) / float(POINTS - 1))
		@warning_ignore("return_value_discarded")
		pts.append(Vector2(SPINE_X - BOW * HALF_W * (1.0 - v * v) * 0.5, v * HALF_W))
	return pts
