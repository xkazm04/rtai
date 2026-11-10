class_name GroundRifle
extends RefCounted
## n11: a dead guard's rifle on the ground (CombatArena.rifle_drops, a pickup), view only: an
## inked side-view rifle mesh turned by where it lies, or (it14, DRAWN) the asset lane's rifle
## drawn lying at 70 degrees in 8 headings (ground_rifle_70.png), y un-squashed for the tilt.
const DRAWN: bool = true
const SHEET: String = "res://features/combat/weapons/art/ground_rifle_70.png"
const HEADINGS: int = 8
## The drawn gun's butt-to-muzzle px in the heading-0 cell (the sheet's one scale).
const DRAWN_LEN_PX: float = 256.0

## The gun's length on the ground (m): a pickup reads larger than life, as PickupsView's do.
const LENGTH_M: float = 1.05
## It lies this far to the side of where its owner fell (m): beside the body, not under the boots.
const BESIDE_M: float = 0.55
## it19: the body falls away from the shot and lies from its feet along that line, so a gun beside
## the feet lay under the legs (every film). It lies TOWARD_M back toward the shooter (Rivet where
## the drop was first drawn, remembered per drop) and SIDE_M to one side. AWAY false = BESIDE_M.
const AWAY: bool = true
const TOWARD_M: float = 0.5
const SIDE_M: float = 0.25
## Drops remembered at most (a cleared memory only re-reads the side from where Rivet is).
const MEMO: int = 64
## it20: a drop shows LAND_TICKS after first drawn, as its owner lands (chest down, +8). 0 = now.
const LAND_TICKS: int = 8
## Past this far from Rivet (m) a drop is off screen at every play zoom: not drawn.
const DRAW_M: float = 24.0
const INK_PX: float = 1.6
const STEEL: Color = Color(0.33, 0.32, 0.34)
const FURNITURE: Color = Color(0.46, 0.39, 0.3)
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.32)
const SHADOW_OFF: Vector2 = Vector2(2.0, 3.0)
## Convex pieces in gun lengths (x -0.5 butt .. 0.5 muzzle, y down), each with its fill.
const STOCK: PackedVector2Array = [
	Vector2(-0.5, -0.03), Vector2(-0.27, -0.045), Vector2(-0.27, 0.04), Vector2(-0.5, 0.085)
]
const BODY: PackedVector2Array = [
	Vector2(-0.27, -0.055), Vector2(0.11, -0.055), Vector2(0.11, 0.035), Vector2(-0.27, 0.045)
]
const GRIP: PackedVector2Array = [
	Vector2(-0.13, 0.035), Vector2(-0.05, 0.035), Vector2(-0.09, 0.135), Vector2(-0.18, 0.125)
]
const MAG: PackedVector2Array = [
	Vector2(0.0, 0.035), Vector2(0.09, 0.035), Vector2(0.07, 0.175), Vector2(-0.03, 0.165)
]
const GUARD: PackedVector2Array = [
	Vector2(0.11, -0.04), Vector2(0.31, -0.035), Vector2(0.31, 0.025), Vector2(0.11, 0.03)
]
const BARREL: PackedVector2Array = [
	Vector2(0.31, -0.014), Vector2(0.5, -0.014), Vector2(0.5, 0.014), Vector2(0.31, 0.014)
]
const SIGHT: PackedVector2Array = [
	Vector2(0.42, -0.06), Vector2(0.45, -0.06), Vector2(0.45, -0.014), Vector2(0.42, -0.014)
]
const SHINE: PackedVector2Array = [
	Vector2(-0.24, -0.04), Vector2(0.09, -0.04), Vector2(0.09, -0.022), Vector2(-0.24, -0.022)
]
const RIM_DIRS: int = 8

static var _mesh: ArrayMesh = null
static var _sheet: Texture2D = null
static var _away: Dictionary[Vector2, Vector2] = {}
static var _seen: Dictionary[Vector2, int] = {}


## Draws the rifle lying at `at` (m), unless it is too far from `focus` (m) to be seen or, at sim
## tick `tick` (-1 = any), not landed yet.
static func draw(ci: CanvasItem, at: Vector2, focus: Vector2, tick: int = -1) -> void:
	if not visible_from(at, focus) or (tick >= 0 and not landed(at, tick)):
		return
	if DRAWN and sheet() != null:
		_draw_cell(ci, at, lies_at_from(at, focus), ViewMode.shared().ground_k())
		return
	var xf: Transform2D = Transform2D(turn(at), Ink.px(lies_at_from(at, focus)))
	ci.draw_set_transform_matrix(Transform2D(0.0, SHADOW_OFF) * xf)
	ci.draw_mesh(mesh(), null, Transform2D.IDENTITY, Color(0.0, 0.0, 0.0, SHADOW.a))
	ci.draw_set_transform_matrix(xf)
	ci.draw_mesh(mesh(), null)
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)


## The drawn heading for a drop at `at` lying at `lies` (m), its shadow first; `gk` the view's
## ground squash.
static func _draw_cell(ci: CanvasItem, at: Vector2, lies: Vector2, gk: float) -> void:
	var tex: Texture2D = sheet()
	var cell: float = float(tex.get_height())
	var src: Rect2 = Rect2(cell * heading(turn(at)), 0.0, cell, cell)
	var k: float = LENGTH_M * Ink.PX_PER_M / DRAWN_LEN_PX
	var size: Vector2 = Vector2(cell * k, cell * k / maxf(gk, 0.1))
	var rect: Rect2 = Rect2(Ink.px(lies) - size * 0.5, size)
	ci.draw_texture_rect_region(
		tex, Rect2(rect.position + SHADOW_OFF, size), src, Color(0.0, 0.0, 0.0, SHADOW.a)
	)
	ci.draw_texture_rect_region(tex, rect, src)


## The drawn sheet (null when DRAWN is off or the sheet is missing).
static func sheet() -> Texture2D:
	if _sheet == null and DRAWN and ResourceLoader.exists(SHEET):
		_sheet = load(SHEET) as Texture2D
	return _sheet


## The sheet's cell for a turn (rad, clockwise on screen from muzzle right): the nearest heading.
static func heading(rad: float) -> int:
	return posmod(roundi(fposmod(rad, TAU) / (TAU / HEADINGS)), HEADINGS)


static func visible_from(at: Vector2, focus: Vector2) -> bool:
	return at.distance_squared_to(focus) <= DRAW_M * DRAW_M


## Where the gun is drawn for a drop at `at` (m): to the side of the point its owner fell on.
static func lies_at(at: Vector2) -> Vector2:
	return at + Vector2.from_angle(turn(at) + PI * 0.5) * BESIDE_M


## Where the gun is drawn for a drop at `at` (m) with Rivet at `focus`: by the feet on the side the
## shot came from, that side fixed the first time the drop is asked about.
static func lies_at_from(at: Vector2, focus: Vector2) -> Vector2:
	if not AWAY:
		return lies_at(at)
	var away: Vector2 = _away.get(at, Vector2.ZERO)
	if away == Vector2.ZERO:
		if _away.size() >= MEMO:
			_away.clear()
		away = (at - focus).normalized()
		away = Vector2.RIGHT if away == Vector2.ZERO else away
		_away[at] = away
	return at - away * TOWARD_M + away.orthogonal() * SIDE_M


## True once the drop at `at` has lain LAND_TICKS since it was first asked about at `tick`.
static func landed(at: Vector2, tick: int) -> bool:
	if not _seen.has(at):
		if _seen.size() >= MEMO:
			_seen.clear()
		_seen[at] = tick
	return tick - _seen[at] >= LAND_TICKS


## Forgets every drop's side and landing (a new fight, a test).
static func forget() -> void:
	_away.clear()
	_seen.clear()


## How the gun lies (rad): from where it fell, so drops do not all point one way.
static func turn(at: Vector2) -> float:
	return fposmod(at.x * 37.13 + at.y * 91.71, TAU)


## The rifle as one mesh in world px, its middle at the origin (ink rim, fills, the shine).
static func mesh() -> ArrayMesh:
	if _mesh != null:
		return _mesh
	var pts: PackedVector2Array = PackedVector2Array()
	var cols: PackedColorArray = PackedColorArray()
	var pieces: Array[Array] = [
		[STOCK, FURNITURE],
		[GRIP, FURNITURE],
		[BODY, STEEL],
		[MAG, STEEL],
		[GUARD, FURNITURE],
		[BARREL, STEEL],
		[SIGHT, STEEL]
	]
	for piece: Array in pieces:
		var q: PackedVector2Array = piece[0]
		for d: int in RIM_DIRS:
			_quad(pts, cols, q, Vector2.from_angle(TAU * d / RIM_DIRS) * INK_PX, Ink.INK)
	for piece: Array in pieces:
		var q: PackedVector2Array = piece[0]
		var tone: Color = piece[1]
		_quad(pts, cols, q, Vector2.ZERO, tone)
	_quad(pts, cols, SHINE, Vector2.ZERO, Ink.CREAM)
	var arrays: Array = []
	@warning_ignore("return_value_discarded")
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = pts
	arrays[Mesh.ARRAY_COLOR] = cols
	_mesh = ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return _mesh


## Two triangles of a four-corner piece, moved `off` px, in `tone`.
static func _quad(
	pts: PackedVector2Array,
	cols: PackedColorArray,
	q: PackedVector2Array,
	off: Vector2,
	tone: Color
) -> void:
	var k: float = LENGTH_M * Ink.PX_PER_M
	for i: int in [0, 1, 2, 0, 2, 3]:
		@warning_ignore("return_value_discarded")
		pts.append(q[i] * k + off)
		@warning_ignore("return_value_discarded")
		cols.append(tone)
