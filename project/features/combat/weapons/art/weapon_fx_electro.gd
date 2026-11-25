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

## Live current (the halo look of `ElectricArc`): a star of FORKS_MIN..FORKS_MAX short forks where
## the arc lands (FORK_M long), STUN_FORK_M long on a daze mark; forks run at FORK_K of the width.
const FORKS_MIN: int = 3
const FORKS_MAX: int = 4
const STUN_FORK_M: float = 0.3
const FORK_K: float = 1.0
const STUN_UNDER_ALPHA: float = 0.3
## The one width of live current (screen px at k = 1) for the bolt, the chain hop and the stun:
## an opaque amber body (the print dissolves the translucent halo) under a cream core.
const BODY_PX: float = 10.0
const CORE_PX: float = 4.0
## The ink outline under the body (screen px wider than it): amber alone does not separate from
## the pale floor in the print, the cells' zigzag read through its ink rim (not on the daze stars).
const INK_EXTRA_PX: float = 3.0


## One polyline pass of the live look: points (view px), colour, width (screen px).
class Line:
	extends RefCounted
	var points: PackedVector2Array
	var color: Color
	var width: float

	func _init(p_points: PackedVector2Array, p_stroke: ElectricArc.Stroke) -> void:
		points = p_points
		color = p_stroke.color
		width = p_stroke.width


static var arc_ink: bool = not OS.get_cmdline_user_args().has("--arc-ink=off")
## true (`--electro-cells`) = the before: the arc/spark PNG cells instead of live current.
static var cells: bool = OS.get_cmdline_user_args().has("--electro-cells")


## The jagged arc from `a` to `b` (m) with a star at `b` (view px); `k` = 1 / screen scale. No
## RNG: kinks hash the ends (to 0.25 m) and `phase`. Empty under `cells` (the before).
static func chain_plan(a: Vector2, b: Vector2, phase: int, k: float = 1.0) -> Array[Line]:
	var plan: Array[Line] = []
	if cells:
		return plan
	var serial: int = _serial(a, b)
	var path: PackedVector2Array = WeaponFxBolt.amplify(
		ElectricArc.shape(PackedVector2Array([a, b]), serial, phase * 2, false)
	)
	add_path(plan, to_px(path), k)
	plan.append_array(star_plan(b, ElectricArc.FORK_M, serial, phase * 2, k))
	return plan


## `forks` short forks radiating `reach` m from `at` (m), turned and counted by a hash of
## `serial` and the 3-tick jag cell of `tick`; the same strokes as the arc, at FORK_K width.
static func star_plan(
	at: Vector2, reach: float, serial: int, tick: int, k: float = 1.0, under: bool = false
) -> Array[Line]:
	var plan: Array[Line] = []
	var jag: int = ElectricArc.cell(tick, false)
	var n: int = FORKS_MIN + int(ElectricArc.hash01(serial, jag, 3) * 1.99)
	var turn: float = ElectricArc.hash01(serial, jag, 4) * TAU
	for i: int in n:
		var d: Vector2 = Vector2.from_angle(turn + TAU * float(i) / float(n))
		var bend: float = (ElectricArc.hash01(serial, jag, 10 + i) - 0.5) * 1.2
		var mid: Vector2 = at + d * reach * 0.5
		var tip: Vector2 = mid + d.rotated(bend) * reach * 0.5
		var pts: PackedVector2Array = to_px(PackedVector2Array([at, mid, tip]))
		if under:
			var rim: Color = Color(Ink.INK, STUN_UNDER_ALPHA)
			plan.append(
				Line.new(pts, ElectricArc.Stroke.new(rim, ElectricArc.HALO_PX * k * FORK_K))
			)
		add_path(plan, pts, k * FORK_K, not under)
	return plan


## The jagged paper arc from `a` to `b` (m) with a spark where it lands; frame by `phase`.
static func chain(ci: CanvasItem, a: Vector2, b: Vector2, phase: int) -> bool:
	if not WeaponFxArt.enabled or a.distance_to(b) < 0.05:
		return false
	if not cells:
		draw_lines(ci, chain_plan(a, b, phase, screen_k(ci)))
		return true
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


## Two stars of current circling a stunned human's head (the cartoon daze), `tick` turns them.
static func stun(ci: CanvasItem, at: Vector2, tick: int, sparks: int = 2) -> bool:
	if not WeaponFxArt.enabled:
		return false
	var head: Vector2 = at + Vector2(0.0, -STUN_LIFT_M)
	for i: int in mini(sparks, 2):
		var ang: float = float(tick) * 0.25 + PI * float(i)
		var p: Vector2 = head + Vector2.from_angle(ang) * STUN_RING_M
		if cells:
			WeaponFxArt.draw_cell(
				ci, &"spark", (tick / 3 + i) % 3, p, ang, Vector2.ONE * STUN_SPARK_K
			)
		else:
			draw_lines(ci, stun_plan(p, tick, i, screen_k(ci)))
	return true


## One daze star at `p` (m): each fork gets a faint ink under-halo (never a solid rim).
static func stun_plan(p: Vector2, tick: int, i: int, k: float = 1.0) -> Array[Line]:
	return star_plan(p, STUN_FORK_M, 7 + i, tick, k, true)


static func add_path(
	plan: Array[Line], pts: PackedVector2Array, k: float, outline: bool = true
) -> void:
	var halo: Array[ElectricArc.Stroke] = ElectricArc.strokes(k)
	plan.append(Line.new(pts, halo[0]))
	plan.append(Line.new(pts, halo[1]))
	if outline:
		var ink: Color = Color(Ink.INK, 1.0)
		plan.append(Line.new(pts, ElectricArc.Stroke.new(ink, (BODY_PX + INK_EXTRA_PX) * k)))
	plan.append(Line.new(pts, ElectricArc.Stroke.new(ElectricArc.HALO, BODY_PX * k)))
	plan.append(Line.new(pts, ElectricArc.Stroke.new(ElectricArc.CORE, CORE_PX * k)))


static func to_px(pts: PackedVector2Array) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in pts:
		@warning_ignore("return_value_discarded")
		out.append(Ink.px(p))
	return out


static func _serial(a: Vector2, b: Vector2) -> int:
	var q: Vector2i = Vector2i((a * 4.0).floor()) * 31 + Vector2i((b * 4.0).floor())
	return posmod(q.x * 7 + q.y * 13, 997)


## Screen px -> canvas units: the widths stay thin at every zoom.
static func screen_k(ci: CanvasItem) -> float:
	if not ci.is_inside_tree():
		return 1.0
	return 1.0 / maxf(0.01, ci.get_global_transform_with_canvas().get_scale().x)


static func draw_lines(ci: CanvasItem, plan: Array[Line]) -> void:
	for l: Line in plan:
		if l.points.size() > 1:
			ci.draw_polyline(l.points, l.color, l.width, true)


## Arc frame `frame` at `at` (m) along `ang`, `span` long (cell scale), in ink at ARC_INK_DIRS
## offsets ARC_INK_M out: drawn just before the paper arc, it thickens the stroke's ink outline.
static func ink_under(ci: CanvasItem, frame: int, at: Vector2, ang: float, span: float) -> void:
	if not arc_ink:
		return
	var scale: Vector2 = Vector2(span, 1.0) * WeaponFxArt.cell_scale()
	ink_cell(ci, &"arc", frame, Transform2D(ang, scale, 0.0, Ink.px(at)), Vector2(ARC_INK_M, 1.0))


## FX cell `id` (frame `frame`) placed by `xf` (view px, cell scale applied) in ink at ARC_INK_DIRS
## offsets `ink.x` m out, `ink.y` opaque: under the paper cell it thickens the cell's ink outline.
static func ink_cell(
	ci: CanvasItem, id: StringName, frame: int, xf: Transform2D, ink: Vector2
) -> void:
	var frames: Array[Texture2D] = WeaponFxArt.art().fx_frames(id)
	if frames.is_empty() or ink.x <= 0.0:
		return
	var key: StringName = StringName("%s_%d" % [id, frame % frames.size()])
	var anchor: Vector2 = WeaponFxArt.art().fx_anchor(key)
	var tex: Texture2D = frames[frame % frames.size()]
	for i: int in ARC_INK_DIRS:
		var off: Vector2 = Vector2.from_angle(TAU * float(i) / float(ARC_INK_DIRS)) * ink.x
		ci.draw_set_transform_matrix(
			Transform2D(xf.x, xf.y, xf.origin + Ink.px(off) - Ink.px(Vector2.ZERO))
		)
		ci.draw_texture(tex, -anchor, Color(WeaponArt.INK, ink.y))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
