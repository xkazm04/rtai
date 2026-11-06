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
