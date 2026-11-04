class_name WeaponFxElectro
extends RefCounted
## weapon-art's electro cells for gunplay's chain arcs and stunned humans (FightAreasArt asks these
## first; false = not drawn, so gunplay's procedural zigzags draw instead). Render-only: reads the
## sim's arc ends and stun state, no RNG, no delta. `--weapon-fx=shapes` turns them off.

## The spark where a chain arc lands, and the daze sparks, in cell scale.
const SPARK_K: float = 1.6
const STUN_SPARK_K: float = 1.3
## Two sparks circle a stunned head this far out (m), this high above the body centre (m).
const STUN_RING_M: float = 0.4
const STUN_LIFT_M: float = 0.55
## The arc's paper stroke read thinnest of the energy rounds on cream paving at 32 px/m (call 3):
## the same arc frame is drawn first in ink at ARC_INK_DIRS offsets ARC_INK_M out (the held rim's
## method), so its ink outline thickens around the paper. 0 (or `--arc-ink=off`) = the before.
## (Scaling the ink silhouette taller was tried first: its peaks missed the paper's, a smudge.)
const ARC_INK_M: float = 0.06
const ARC_INK_DIRS: int = 8

static var arc_ink: bool = not OS.get_cmdline_user_args().has("--arc-ink=off")


## The jagged paper arc from `a` to `b` (m) with a spark where it lands; frame by `phase`.
static func chain(ci: CanvasItem, a: Vector2, b: Vector2, phase: int) -> bool:
	if not WeaponFxArt.enabled or a.distance_to(b) < 0.05:
		return false
	var span_m: float = a.distance_to(b)
	var k: float = WeaponFxArt.cell_scale()
	var span: float = span_m * Ink.PX_PER_M / (WeaponFxArt.ARC_SPAN_PX * k)
	var ang: float = (b - a).angle()
	ink_under(ci, phase % 3, a, ang, span)
	WeaponFxArt.draw_cell(ci, &"arc", phase % 3, a, ang, Vector2(span, 1.0))
	WeaponFxArt.draw_cell(
		ci, &"spark", (phase + 1) % 3, b, float(phase) * 0.7, Vector2.ONE * SPARK_K
	)
	return true


## Two sparks circling a stunned human's head (the cartoon daze), `tick` turns them.
static func stun(ci: CanvasItem, at: Vector2, tick: int) -> bool:
	if not WeaponFxArt.enabled:
		return false
	var head: Vector2 = at + Vector2(0.0, -STUN_LIFT_M)
	for i: int in 2:
		var ang: float = float(tick) * 0.25 + PI * float(i)
		var p: Vector2 = head + Vector2.from_angle(ang) * STUN_RING_M
		WeaponFxArt.draw_cell(ci, &"spark", (tick / 3 + i) % 3, p, ang, Vector2.ONE * STUN_SPARK_K)
	return true


## Arc frame `frame` at `at` (m) along `ang`, `span` long (cell scale), in ink at ARC_INK_DIRS
## offsets ARC_INK_M out: drawn just before the paper arc, it thickens the stroke's ink outline.
static func ink_under(ci: CanvasItem, frame: int, at: Vector2, ang: float, span: float) -> void:
	if not arc_ink or ARC_INK_M <= 0.0:
		return
	var frames: Array[Texture2D] = WeaponFxArt.art().fx_frames(&"arc")
	if frames.is_empty():
		return
	var tex: Texture2D = frames[frame % frames.size()]
	var anchor: Vector2 = WeaponFxArt.art().fx_anchor(StringName("arc_%d" % (frame % 3)))
	var scale: Vector2 = Vector2(span, 1.0) * WeaponFxArt.cell_scale()
	for i: int in ARC_INK_DIRS:
		var off: Vector2 = Vector2.from_angle(TAU * float(i) / float(ARC_INK_DIRS)) * ARC_INK_M
		ci.draw_set_transform(Ink.px(at + off), ang, scale)
		ci.draw_texture(tex, -anchor, Color(WeaponArt.INK, 1.0))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
