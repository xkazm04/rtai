class_name KingCarStack
extends RefCounted
## View lab (docs/view-lab/PLAN.md): the throne-car's body as a sprite stack under a tilted
## --view. Horizontal slices of the car's outline from the ground to the roof line, each drawn
## lifted by its height (ViewMode.lift_px), so the sides that face the camera read as walls: the
## black body, the gold belt line, the dark glass band with gold pillars, the gold grille and the
## headlamps on the nose, the tyres at the wheel arches. It rotates freely with the car's heading
## (each slice is the same outline, drawn under the car's own transform). The roof, the throne and
## King are then drawn ROOF_M up (KingBodyView). Straight down nothing runs. Render only.

const ROOF_M: float = 1.45
const SLICES: int = 18
## A far-side rig's z under the car's (its parts' own z stay relative, all under 0).
const BEHIND_Z: int = -64
const BELT_K: float = 0.5
const GLASS_FROM_K: float = 0.62
const GLASS_TO_K: float = 0.93
const GLASS: Color = Color("#3A2E3C")
const SIDE: Color = Color("#2E282B")
const SIDE_LOW: Color = Color("#1A1618")
const TYRE: Color = Color("#141213")
const LAMP: Color = Color("#F3E9C8")
## Wheel centres along the car (fractions of its length) and the tyre's size in metres: a
## vertical disc of radius x standing y wide, so each slice cuts it to a chord (round on the wall).
const WHEELS_K: Array[float] = [-0.32, 0.3]
const TYRE_M: Vector2 = Vector2(0.48, 0.42)
const HUB_M: float = 0.2
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.38)
## The throne back's height over the roof under a tilt (m) and its slices.
const THRONE_H_M: float = 0.9
const THRONE_SLICES: int = 7


## Draws the stack about `at` (world px) along `heading`; the caller then lifts the roof by ROOF_M.
static func draw(ci: CanvasItem, at: Vector2, heading: float, l: float, w: float) -> void:
	var view: ViewMode = ViewMode.shared()
	if not view.has_lift():
		return
	var p: float = Ink.PX_PER_M
	ci.draw_set_transform(at, heading, Vector2.ONE)  # the contact shadow on the ground
	ci.draw_rect(Rect2(-l * 0.5, -w * 0.5, l, w).grow(0.35 * p), SHADOW)
	for i: int in SLICES:
		var k: float = float(i) / float(SLICES - 1)
		var z: float = ROOF_M * k
		ci.draw_set_transform(
			at + view.lift_at(ci.get_global_transform() * at, z), heading, Vector2.ONE
		)
		if i == 0 or i == SLICES - 1:  # the ink line at the foot and at the roof line
			ci.draw_rect(Rect2(-l * 0.5, -w * 0.5, l, w).grow(3.0), Ink.INK)
		_slice(ci, k, l, w, p)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _slice(ci: CanvasItem, k: float, l: float, w: float, p: float) -> void:
	var body: Rect2 = Rect2(-l * 0.5, -w * 0.5, l, w)
	var c: Color = SIDE_LOW.lerp(SIDE, k / BELT_K) if k < BELT_K else SIDE
	if k >= GLASS_FROM_K and k <= GLASS_TO_K:
		c = GLASS
	if absf(k - BELT_K) < 0.04 or absf(k - GLASS_FROM_K) < 0.03:
		c = KingBodyView.GOLD  # the gilded belt and sill lines
	ci.draw_rect(body.grow(1.0), c)  # no per-slice ink: a slice shows only a 1-2 px strip
	if k >= GLASS_FROM_K and k <= GLASS_TO_K:  # gold pillars through the glass band
		for f: float in [-0.42, -0.2, 0.02, 0.24]:
			ci.draw_rect(Rect2(l * f, -w * 0.5, 0.18 * p, w), KingBodyView.GOLD_DARK)
	if k > 0.12 and k < 0.6:  # the grille across the nose, the bumper across the tail
		ci.draw_rect(Rect2(l * 0.5 - 0.3 * p, -w * 0.42, 0.34 * p, w * 0.84), KingBodyView.GOLD)
		var tail: Rect2 = Rect2(-l * 0.5 - 0.06 * p, -w * 0.45, 0.22 * p, w * 0.9)
		ci.draw_rect(tail, KingBodyView.GOLD_DARK)
	if absf(k - 0.4) < 0.07:  # the headlamps at the nose's corners
		for sy: float in [-0.32, 0.32]:
			ci.draw_circle(Vector2(l * 0.5 + 0.05 * p, w * sy), 0.2 * p, LAMP)
	_wheels(ci, k * ROOF_M, l, w, p)


## The tyres at height z (m): each wheel a vertical disc, cut to its chord at z, a gold hub disc
## on the outer face; the slices stack them into round wheels on the walls.
static func _wheels(ci: CanvasItem, z: float, l: float, w: float, p: float) -> void:
	var r: float = TYRE_M.x
	var dz: float = z - r
	if absf(dz) >= r:
		return
	var half: float = sqrt(r * r - dz * dz) * p
	var hub: float = sqrt(maxf(HUB_M * HUB_M - dz * dz, 0.0)) * p
	for fx: float in WHEELS_K:
		for sy: float in [-0.5, 0.5]:
			var c_at: Vector2 = Vector2(l * fx, w * sy)
			var depth: float = TYRE_M.y * p * 0.5
			ci.draw_rect(Rect2(c_at.x - half, c_at.y - depth, half * 2.0, depth * 2.0), TYRE)
			if hub > 0.0:
				var face: float = c_at.y + signf(sy) * (depth - 0.06 * p)
				var hub_r: Rect2 = Rect2(c_at.x - hub, face - 0.06 * p, hub * 2.0, 0.12 * p)
				ci.draw_rect(hub_r, KingBodyView.GOLD)


## Ground-depth order against the car (registry measured-draw-order: the depth is the ground y):
## a rig standing on the car's far side (smaller ground y, inside far_box) draws behind the car
## (a relative z BEHIND_Z under it: the rigs are KingRigs' children, so show_behind_parent
## would only put them behind KingRigs), the rest over it. King himself (on the roof) is never
## behind. RigDepthSort.far_box carries it to the cast's rigs near the car (Rivet). Tilt only.
static func sort_rigs(rigs: Dictionary, king_id: int, f: BossFight) -> void:
	var car: Vector2 = f.body.pos
	var km: KingMoves = f.moves as KingMoves
	if f.phase >= 2:
		car = km.car_at if km != null else Vector2.INF
	RigDepthSort.far_box = Rect2()
	for id: int in rigs:
		var rig: CutRig = rigs[id]
		if car != Vector2.INF and not RigDepthSort.far_box.has_area():  # the cast's rigs too
			var dir: Vector2 = km.car_facing if f.phase >= 2 and km != null else f.body.facing
			RigDepthSort.far_box = far_box(rig.get_parent() as Node2D, car, dir)
		var behind: bool = car != Vector2.INF and id != king_id
		var back: bool = behind and RigDepthSort.far_box.has_point(rig.global_position)
		rig.depth_base = BEHIND_Z if back else 0  # RigDepthSort adds its level on top
		rig.z_index = rig.depth_base


## The screen box (global px) north of the car's ground centre where a cast rig draws behind it:
## the car's footprint on screen widened by a body, from its centre line up past its roof.
static func far_box(host: Node2D, car: Vector2, dir: Vector2) -> Rect2:
	var k: float = host.get_global_transform().get_scale().x
	var p: float = Ink.PX_PER_M * k
	var c: Vector2 = host.to_global(Ink.px(car))
	var ex: float = (
		(absf(dir.x) * KingBodyView.CAR_LEN_M + absf(dir.y) * KingBodyView.CAR_W_M) * 0.5
	)
	var ey: float = (
		(absf(dir.y) * KingBodyView.CAR_LEN_M + absf(dir.x) * KingBodyView.CAR_W_M) * 0.5
	)
	var up: float = absf(ViewMode.shared().lift_px(ROOF_M + 1.8).y) * k
	var half_x: float = (ex + 0.9) * p
	return Rect2(c.x - half_x, c.y - ey * p - up, half_x * 2.0, ey * p + up)


## Under a tilt: KingCarTrim's throne back standing THRONE_H_M tall behind King's seat `at` (car
## px), `up` = the car-local lift per metre: the arch stacked in slices (ink silhouette, then gold
## from dark at the seat to bright at the top), the light line, ball finials and crest on top.
static func throne(ci: CanvasItem, at: Vector2, p: float, up: Vector2) -> void:
	var r: float = KingCarTrim.THRONE_HW_M * p
	var w: float = 0.16 * p
	var a0: float = PI - KingCarTrim.THRONE_ARC
	var a1: float = PI + KingCarTrim.THRONE_ARC
	for i: int in THRONE_SLICES:
		ci.draw_arc(at + up * _throne_h(i), r, a0, a1, 24, KingCarTrim.INK, w + 4.0)
	for i: int in THRONE_SLICES:
		var k: float = float(i) / float(THRONE_SLICES - 1)
		var col: Color = KingCarTrim.GOLD_DARK.lerp(KingCarTrim.GOLD, k)
		ci.draw_arc(at + up * _throne_h(i), r, a0, a1, 24, col, w)
	var top: Vector2 = at + up * THRONE_H_M
	ci.draw_arc(
		top, r + w * 0.2, PI - KingCarTrim.THRONE_ARC * 0.9, a1 - 0.1, 24, KingCarTrim.GOLD_HI, 1.5
	)
	for s: float in [-1.0, 1.0]:
		var fin: Vector2 = top + Vector2.from_angle(PI + s * KingCarTrim.THRONE_ARC) * r
		ci.draw_circle(fin, 0.15 * p + 2.0, KingCarTrim.INK)
		ci.draw_circle(fin, 0.15 * p, KingCarTrim.GOLD)
		ci.draw_circle(fin - Vector2(0.05, 0.05) * p, 0.055 * p, KingCarTrim.GOLD_HI)
	var c: Vector2 = top + Vector2(-r, 0.0) + up * KingCarTrim.CREST_M * 1.2
	ci.draw_circle(c, KingCarTrim.CREST_M * p + 2.0, KingCarTrim.INK)
	ci.draw_circle(c, KingCarTrim.CREST_M * p, KingCarTrim.GOLD)
	ci.draw_circle(c, KingCarTrim.CREST_M * p * 0.45, KingCarTrim.PLUM_DARK)


static func _throne_h(i: int) -> float:
	return THRONE_H_M * float(i) / float(THRONE_SLICES - 1)
