class_name StreetQuestCards
extends RefCounted
## Lane n8 street: quest 1's dock contractors under a card view. Straight down CastView draws each
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
## The card's drawn width (m): the pudgy contractor's shoulders, about Rivet's width.
const WIDTH_M: float = 1.15
## The feet's height in the cell (from the top): the strip pads 2 px under the boots.
const FOOT_Y: float = 0.985
static var _tex: Dictionary[String, Texture2D] = {}


## Draws the guard's card on `canvas` at `at_px` (canvas px) and returns true; false = no card for
## this view (the caller draws its sprite).
static func draw_guard(
	canvas: CanvasItem, at_px: Vector2, facing: Vector2, px_per_m: float, tint: Color = Color.WHITE
) -> bool:
	var view: ViewMode = ViewMode.shared()
	var path: String = GUARD.get(view.art, "")
	if not view.cards or path.is_empty():
		return false
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	var tex: Texture2D = _tex[path]
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	var f: Vector2i = RigHeadCard.frame_of(facing.angle())
	var w: float = WIDTH_M * px_per_m
	var h: float = w * cell.y / cell.x / view.ground_k()
	var dst: Rect2 = Rect2(-w * 0.5, -h * FOOT_Y, w, h)
	# mirrored frames flip about the feet point (a negative-width rect draws one width aside)
	canvas.draw_set_transform(at_px, 0.0, Vector2(-1.0 if f.y == 1 else 1.0, 1.0))
	canvas.draw_texture_rect_region(tex, dst, Rect2(cell.x * f.x, 0.0, cell.x, cell.y), tint)
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
	var st: Texture2D = _load(stand)
	# the standing contractor's height (m), as draw_guard sizes it, before the ground squash
	var h_m: float = WIDTH_M * st.get_height() * RigHeadCard.FRAMES / float(st.get_width())
	var s: float = h_m * px_per_m / StreetWalkerFall.STILL_PX
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


## The turn for a corpse at `at_px`: a fixed pick from its spot (render only, no RNG stream).
static func spread_of(at_px: Vector2) -> float:
	return float(posmod(floori(at_px.x * 0.37 + at_px.y * 0.61), 3) - 1) * SPREAD


static func _load(path: String) -> Texture2D:
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	return _tex[path]
