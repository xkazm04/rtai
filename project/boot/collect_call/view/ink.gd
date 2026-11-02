class_name Ink
extends RefCounted
## The Trivet inks (art-direction/trivet DESIGN.md: cream paper, violet-black ink, vermilion,
## teal only for robot eyes and the torch tip) and the flat placeholder shapes quest 1 draws
## with until the cutout parts land. Everything is in metres; PX_PER_M is gameplay zoom.

const PX_PER_M: float = 48.0
const CREAM: Color = Color("#F2E8D5")
const INK: Color = Color("#17131B")
const VERMILION: Color = Color("#E8502A")
const TEAL: Color = Color("#1FB5A8")
const WASH: Color = Color(0.090, 0.075, 0.106, 0.12)
const LINE_PX: float = 3.0


static func px(m: Vector2) -> Vector2:
	return m * PX_PER_M


## A filled disc with an ink rim and an optional initial on its body.
static func disc(ci: CanvasItem, at: Vector2, r: float, fill: Color, letter: String = "") -> void:
	ci.draw_circle(px(at), r * PX_PER_M, fill)
	ci.draw_arc(px(at), r * PX_PER_M, 0.0, TAU, 40, INK, LINE_PX, true)
	if letter != "":
		initial(ci, at, letter, INK if fill != INK else CREAM, r)


## A filled rectangle (centre, size in m) with an ink rim.
static func box(ci: CanvasItem, at: Vector2, size: Vector2, fill: Color) -> void:
	var r: Rect2 = Rect2(px(at - size * 0.5), size * PX_PER_M)
	ci.draw_rect(r, fill, true)
	ci.draw_rect(r, INK, false, LINE_PX)


## The character's initial, centred on its body.
static func initial(ci: CanvasItem, at: Vector2, letter: String, color: Color, r: float) -> void:
	var size: int = maxi(roundi(r * PX_PER_M * 1.1), 14)
	var font: Font = ThemeDB.fallback_font
	var w: float = font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var base: Vector2 = px(at) + Vector2(-w * 0.5, size * 0.36)
	ci.draw_string(font, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## A text label in metres-space (props, stencils).
static func label(ci: CanvasItem, at: Vector2, text: String, size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	ci.draw_string(font, px(at) + Vector2(-w * 0.5, size * 0.35), text, 0, -1, size, color)


## A jagged arc line between two points (tethers, chained arcs, prong sparks).
## `phase` varies the kinks (a tick count makes them crackle).
static func zigzag(
	ci: CanvasItem, a: Vector2, b: Vector2, kinks: int, phase: int, color: Color
) -> void:
	var normal: Vector2 = (b - a).orthogonal().normalized()
	var out: Array[Vector2] = []
	for i: int in kinks + 1:
		var t: float = float(i) / kinks
		var wobble: float = 0.0 if i == 0 or i == kinks else sin(float(phase * 7 + i * 13)) * 0.35
		out.append(px(a.lerp(b, t) + normal * wobble))
	ci.draw_polyline(PackedVector2Array(out), color, LINE_PX, true)
