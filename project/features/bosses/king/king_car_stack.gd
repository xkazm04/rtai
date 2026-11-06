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
## a rig standing on the car's far side (smaller ground y) draws behind KingBodyView's car
## (a relative z BEHIND_Z under it: the rigs are KingRigs' children, so show_behind_parent
## would only put them behind KingRigs), the rest over it. King himself (on the roof) is never
## behind. Tilt only.
static func sort_rigs(rigs: Dictionary, king_id: int, f: BossFight) -> void:
	var car: Vector2 = f.body.pos
	var km: KingMoves = f.moves as KingMoves
	if f.phase >= 2:
		car = km.car_at if km != null else Vector2.INF
	for id: int in rigs:
		var rig: CutRig = rigs[id]
		var behind: bool = car != Vector2.INF and id != king_id
		var back: bool = behind and rig.position.y < Ink.px(car).y
		rig.z_index = BEHIND_Z if back else 0
