class_name StreetQuestCards
extends RefCounted
## Upright quest guards and patrols under a pitched camera.

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
## The four-drawing quest fallback keeps its original unarmed sheet.
const PATROL_WALK: Dictionary[String, String] = {
	"p55": P55 + "cop_patrol_walk.png",
	"p70": P70 + "cop_patrol_walk.png",
}
const STRIDE_M: float = 1.4
## A step shorter than this (px per frame) is no step; HOLD_FRAMES frames with no step stand (the
## standing card): a frame drawn between two sim ticks (a display over 60 Hz) keeps the stride.
const MOVING_PX: float = 0.2
const HOLD_FRAMES: int = 4
## Directional death cards use the pitch fallback when necessary.
const DOWN: Dictionary[String, String] = {
	"p55": P55 + "contractor_fall.png",
	"p70": P70 + "contractor_fall.png",
}
## The corpse's turn off the facing (rad), picked per ground spot (-1, 0, +1 x SPREAD): guards
## charging one way fall one way, a heap of clones; 0 = all along their facing.
const SPREAD: float = PI * 0.25
## The nearest previous patrol point gives the step and keeps the facing when stopped.
const FOLLOW_WALK: bool = true
const MATCH_M: float = 1.5
## The card's drawn width (m): the pudgy contractor's shoulders, about Rivet's width.
const WIDTH_M: float = 1.15
## The feet's height in the cell (from the top): the strip pads 2 px under the boots.
const FOOT_Y: float = 0.985
static var _tex: Dictionary[String, Texture2D] = {}
## Last and current render-frame positions, walked distances and support contacts.
static var _frame: int = -1
static var _was: Array[Vector4] = []
static var _now: Array[Vector4] = []
static var _was_d: Array[float] = []
static var _now_d: Array[float] = []
static var _was_contact: Array[StreetQuestPatrol] = []
static var _now_contact: Array[StreetQuestPatrol] = []
static var _contact: StreetQuestPatrol
static var _walked: float = 0.0
static var _moving: bool = false


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
	return _contact.draw(canvas, at_px, face, px_per_m, tint)


## The facing of the patrol cop drawn at `at_px` this frame: its step since the nearest cop drawn
## last frame, else that cop's facing, else `fallback` (a new cop).
static func walk_facing(at_px: Vector2, fallback: Vector2, px_per_m: float) -> Vector2:
	var frame: int = Engine.get_process_frames()
	if frame != _frame:
		_frame = frame
		_was = _now
		_now = []
		_was_contact = _now_contact
		_now_contact = []
		_was_d = _now_d
		_now_d = []
	var face: Vector2 = fallback
	var best: float = MATCH_M * px_per_m
	var still: float = float(HOLD_FRAMES)
	_walked = 0.0
	_contact = null
	for i: int in _was.size():
		var w: Vector4 = _was[i]
		var d: float = at_px.distance_to(Vector2(w.x, w.y))
		if d <= best:
			best = d
			_contact = _was_contact[i]
			var step: Vector2 = at_px - Vector2(w.x, w.y)
			face = step.normalized() if step.length() > 0.01 else Vector2.from_angle(w.z)
			_walked = _was_d[i] + step.length()
			still = 0.0 if step.length() > MOVING_PX else w.w + 1.0
	_moving = still < HOLD_FRAMES
	_now.append(Vector4(at_px.x, at_px.y, face.angle(), still))
	if _contact == null:
		_contact = StreetQuestPatrol.new()
	if best < MATCH_M * px_per_m:
		_contact.sample_speed(best, px_per_m)
	if not _moving:
		_contact.reset()
	_now_contact.append(_contact)
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
	var cell: Vector2 = tex.get_size() / Vector2(RigHeadCard.FRAMES, 1)
	var f: Vector2i = RigHeadCard.frame_of(facing.angle())
	var w: float = WIDTH_M * px_per_m
	var h: float = w * cell.y / cell.x / view.ground_k()
	var dst: Rect2 = Rect2(-w * 0.5, -h * FOOT_Y, w, h)
	# mirrored frames flip about the feet point (a negative-width rect draws one width aside)
	canvas.draw_set_transform(at_px, 0.0, Vector2(-1.0 if f.y == 1 else 1.0, 1.0))
	var src: Rect2 = Rect2(cell.x * f.x, 0.0, cell.x, cell.y)
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
	if tint.a <= 0.0:
		return true  # decayed away (StreetQuestCorpses): nothing to draw, no sprite either
	canvas.draw_set_transform(at_px, 0.0, Vector2(-1.0 if f.y == 1 else 1.0, 1.0))
	canvas.draw_texture_rect_region(tex, dst, src, tint)
	canvas.draw_set_transform(Vector2.ZERO)
	return true


## The p70 standing height before ground squash sizes corpses at both pitches.
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
