class_name StreetQuestCards
extends RefCounted
## Lane n8 street: quest 1's dock contractors (and patrol cops: PATROL) under a card view.
## Straight down CastView draws each
## as the flat `dock_guard` sprite turned to its facing; seen from a raised camera that reads as a
## disc on the ground. Under a view row with `cards` and a strip for its art (GUARD), the guard
## draws as one standing whole-figure card instead: the library's contractor sheet (hard hat, hi-vis
## vest, rifle), 5 facings drawn and the left 3 mirrored (RigHeadCard.frame_of), upright, the
## camera's ground squash undone so the art keeps its drawn aspect, feet on the guard's ground
## point. Render only; straight down, or under art with no strip, the sprite draws (top unchanged).

const P55: String = "res://features/characters/art/view/p55/"
const P70: String = "res://features/characters/art/view/p70/"
## Cut by street_head.py (band 1.0: the whole figure) from keyed contractor_55 / contractor_70 (A).
const GUARD: Dictionary[String, String] = {
	"p55": P55 + "contractor_card.png",
	"p70": P70 + "contractor_card.png",
}
## Quest 1's patrol cops (CastView draws them while Rivet is hot): the library's cop_patrol sheet's
## top row, the same recipe and width, `navy` as the cop head cards (the cop-tone call's default).
const PATROL: Dictionary[String, String] = {
	"p55": P55 + "cop_patrol_card.png",
	"p70": P70 + "cop_patrol_card.png",
}
## A walking patrol cop's grid (street_walk.py from keyed cop_patrol_walk_70 / _55 B, row 4 as
## frames 1-2-1-4, then street_tone.py: the strip's blue matched to PATROL's navy): 5 facings x 4
## stride frames, stepping by the distance walked (one cycle = STRIDE_M).
## {} = the standing card glides.
const PATROL_WALK: Dictionary[String, String] = {
	"p55": P55 + "cop_patrol_walk.png",
	"p70": P70 + "cop_patrol_walk.png",
}
const STRIDE_M: float = 1.4
## A step shorter than this (px per frame) is standing: the standing card draws.
const MOVING_PX: float = 0.2
## A downed guard's drawn lying frame (street_fall.py from keyed contractor_fall_55 / _70 B:
## the grid's last row, feet at the cell centre), fallen forward along its facing, mirrored as
## the standing card, opaque; art with no grid draws StreetWalkerFall.FALLBACK's. {} = the flat
## sprite (before).
const DOWN: Dictionary[String, String] = {
	"p55": P55 + "contractor_fall.png",
	"p70": P70 + "contractor_fall.png",
}
## The corpse's turn off the facing (rad), picked per ground spot (-1, 0, +1 x SPREAD): guards
## charging one way fall one way, a heap of clones; 0 = all along their facing.
const SPREAD: float = PI * 0.25
## A patrol cop's facing follows its walk (CastView passes a fixed one): the last frame's cop
## nearest the drawn point (within MATCH_M) gives the step; standing, the last facing holds.
const FOLLOW_WALK: bool = true
const MATCH_M: float = 1.5
## The card's drawn width (m): the pudgy contractor's shoulders, about Rivet's width.
const WIDTH_M: float = 1.15
## The feet's height in the cell (from the top): the strip pads 2 px under the boots.
const FOOT_Y: float = 0.985
static var _tex: Dictionary[String, Texture2D] = {}
## Render-only walk memory: last frame's / this frame's drawn patrol points (px) and facings.
static var _frame: int = -1
static var _was: Array[Vector4] = []
static var _now: Array[Vector4] = []
static var _was_d: Array[float] = []
static var _now_d: Array[float] = []
## The last walk_facing call's cop: walked px so far and whether it stepped this frame; the stride
## row _card draws (-1 = a one-row strip).
static var _walked: float = 0.0
static var _moving: bool = false
static var _stride: int = -1


## Draws the guard's card on `canvas` at `at_px` (canvas px) and returns true; false = no card for
## this view (the caller draws its sprite).
static func draw_guard(
	canvas: CanvasItem, at_px: Vector2, facing: Vector2, px_per_m: float, tint: Color = Color.WHITE
) -> bool:
	return _card(canvas, GUARD, at_px, facing, px_per_m, tint)


## Draws a quest 1 patrol cop's standing card (as draw_guard); false = the caller draws its sprite.
static func draw_patrol(
	canvas: CanvasItem, at_px: Vector2, facing: Vector2, px_per_m: float, tint: Color = Color.WHITE
) -> bool:
	if not ViewMode.shared().cards:
		return false
	_moving = false
	var face: Vector2 = walk_facing(at_px, facing, px_per_m) if FOLLOW_WALK else facing
	if not _moving or not PATROL_WALK.has(ViewMode.shared().art):
		return _card(canvas, PATROL, at_px, face, px_per_m, tint)
	_stride = posmod(floori(_walked / (STRIDE_M * px_per_m) * 4.0), 4)
	var drawn: bool = _card(canvas, PATROL_WALK, at_px, face, px_per_m, tint)
	_stride = -1
	return drawn


## The facing of the patrol cop drawn at `at_px` this frame: its step since the nearest cop drawn
## last frame, else that cop's facing, else `fallback` (a new cop).
static func walk_facing(at_px: Vector2, fallback: Vector2, px_per_m: float) -> Vector2:
	var frame: int = Engine.get_process_frames()
	if frame != _frame:
		_frame = frame
		_was = _now
		_now = []
		_was_d = _now_d
		_now_d = []
	var face: Vector2 = fallback
	var best: float = MATCH_M * px_per_m
	_walked = 0.0
	for i: int in _was.size():
		var w: Vector4 = _was[i]
		var d: float = at_px.distance_to(Vector2(w.x, w.y))
		if d <= best:
			best = d
			var step: Vector2 = at_px - Vector2(w.x, w.y)
			face = step.normalized() if step.length() > 0.01 else Vector2(w.z, w.w)
			_walked = _was_d[i] + step.length()
			_moving = step.length() > MOVING_PX
	_now.append(Vector4(at_px.x, at_px.y, face.x, face.y))
	_now_d.append(_walked)
	return face


static func _card(
	canvas: CanvasItem,
	strips: Dictionary[String, String],
	at_px: Vector2,
	facing: Vector2,
	px_per_m: float,
	tint: Color
) -> bool:
	var view: ViewMode = ViewMode.shared()
	var path: String = strips.get(view.art, "")
	if not view.cards or path.is_empty():
		return false
	var tex: Texture2D = _load(path)
	var rows: int = 4 if _stride >= 0 else 1
	var cell: Vector2 = Vector2(
		tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height() / float(rows)
	)
	var f: Vector2i = RigHeadCard.frame_of(facing.angle())
	var w: float = WIDTH_M * px_per_m
	var h: float = w * cell.y / cell.x / view.ground_k()
	if _stride >= 0:  # the standing card's height, the walk cell's own aspect
		var st: Texture2D = _load(PATROL[view.art])
		h = w * st.get_height() * RigHeadCard.FRAMES / st.get_width() / view.ground_k()
		w = h * view.ground_k() * cell.x / cell.y
	var dst: Rect2 = Rect2(-w * 0.5, -h * FOOT_Y, w, h)
	# mirrored frames flip about the feet point (a negative-width rect draws one width aside)
	canvas.draw_set_transform(at_px, 0.0, Vector2(-1.0 if f.y == 1 else 1.0, 1.0))
	var src: Rect2 = Rect2(cell.x * f.x, cell.y * maxi(_stride, 0), cell.x, cell.y)
	canvas.draw_texture_rect_region(tex, dst, src, tint)
	canvas.draw_set_transform(Vector2.ZERO)
	return true


## Draws a downed guard as the drawn corpse on `canvas` at `at_px` and returns true; false = no
## grid for this view (the caller draws its guard_down sprite).
static func draw_down(
	canvas: CanvasItem, at_px: Vector2, facing: Vector2, px_per_m: float, tint: Color = Color.WHITE
) -> bool:
	var view: ViewMode = ViewMode.shared()
	var stand: String = GUARD.get(view.art, "")
	var path: String = DOWN.get(view.art, DOWN.get(StreetWalkerFall.FALLBACK, ""))
	if not view.cards or stand.is_empty() or path.is_empty():
		return false
	var tex: Texture2D = _load(path)
	var s: float = body_m() * px_per_m / StreetWalkerFall.STILL_PX
	var rows: int = StreetWalkerFall.FALL_FRAMES
	var cell: Vector2 = Vector2(
		tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height() / float(rows)
	)
	var f: Vector2i = RigHeadCard.frame_of(facing.angle() + spread_of(at_px))
	var dst: Rect2 = Rect2(-cell * s * 0.5, cell * s)
	var src: Rect2 = Rect2(cell.x * f.x, cell.y * (rows - 1), cell.x, cell.y)
	canvas.draw_set_transform(at_px, 0.0, Vector2(-1.0 if f.y == 1 else 1.0, 1.0))
	canvas.draw_texture_rect_region(tex, dst, src, tint)
	canvas.draw_set_transform(Vector2.ZERO)
	return true


## The corpse's body length (m): the FALLBACK (p70) standing card's height, as draw_guard sizes
## it before the ground squash, for every pitch. The 55 contractor is a longer-legged drawing, so
## sizing a 55 corpse by its own card laid it ~1.2x the 70 one, longer than the cop beside it.
static func body_m() -> float:
	var st: Texture2D = _load(GUARD[StreetWalkerFall.FALLBACK])
	return WIDTH_M * st.get_height() * RigHeadCard.FRAMES / float(st.get_width())


## The turn for a corpse at `at_px`: a fixed pick from its spot (render only, no RNG stream).
static func spread_of(at_px: Vector2) -> float:
	return float(posmod(floori(at_px.x * 0.37 + at_px.y * 0.61), 3) - 1) * SPREAD


static func _load(path: String) -> Texture2D:
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	return _tex[path]
