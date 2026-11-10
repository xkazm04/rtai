class_name StreetQuestHit
extends RefCounted
## n15 combat item 2 (owner: "character reactions on being shot/killed is poor"): quest 1's dock
## contractors are not rigs (QuestGuardCast keeps them on the cast view), so StreetWalkerHit never
## reached them: a shot contractor stood on as his card and a killed one popped to the lying pose.
## Now a contractor shot within HOLD_TICKS of his last blow (Fighter.hurt_tick, the arena's tick)
## draws the asset lane's thrown-back stagger (it321 v2 A, tools/art/street_hit.py `contractor`:
## 5 facings by 1, the planted boot on the cell's centre line) in place of his standing card, and a
## death opens on the same cell for OPEN_TICKS before StreetQuestDeadPlan's lying pose takes it.
## Faced and mirrored as the standing card (RigHeadCard.frame_of). Stateless, render only.
## ON false (or `--quest-hit=off`) = the standing card through a hit and the lying pose from the
## killing blow (the before).

const ON: bool = true
## Cut from the 70 sheet only; drawn under every card art (as StreetWalkerHit's p70 grids).
const PATH: String = "res://features/characters/art/view/p70/contractor_hit.png"
## StreetWalkerHit.HOLD_S's stagger (0.34 s) in ticks; the death's opening, its fall's first part.
const HOLD_TICKS: int = 20
const OPEN_TICKS: int = 10
## The grid's cell height over the standing card's (StreetQuestCards.body_m): both cut from the
## library's 70 sheets at one drawing scale, the hit cell (256 px) = 347 / 0.96 sheet px (its
## tallest figure fills street_hit.py's FILL), the card cell (192 px) = 340 sheet px.
const CELL_K: float = 1.063
const FRAMES: int = 5
## street_hit.py FOOT_Y: the planted boot's bottom in the cell.
const FOOT_Y: float = 0.985

static var _tex: Texture2D = null
static var _off: int = -1


## Draws the living contractor `h` at `at_px` thrown back while his last blow is fresh, else his
## standing card (StreetQuestCards.draw_guard); false = neither (the caller draws its sprite).
static func or_card(canvas: CanvasItem, at_px: Vector2, h: Fighter, ppm: float, now: int) -> bool:
	if now - h.hurt_tick < HOLD_TICKS and shows():
		draw(canvas, at_px, h, ppm)
		return true
	return StreetQuestCards.draw_guard(canvas, at_px, h.facing, ppm)


## Draws the dead contractor `h` thrown back in his death's opening; false = past it (or no cell).
static func opening(canvas: CanvasItem, at_px: Vector2, h: Fighter, ppm: float, now: int) -> bool:
	if now - h.hurt_tick >= OPEN_TICKS or not shows():
		return false
	draw(canvas, at_px, h, ppm)
	return true


## True when the hit cell draws at all: ON, no `--quest-hit=off`, a card view, the grid present.
static func shows() -> bool:
	if _off < 0:
		_off = 1 if ArenaArgs.parse().text("--quest-hit") == "off" else 0
	return ON and _off == 0 and ViewMode.shared().cards and _grid() != null


## The cell's drawn size (px) at `ppm` before the ground squash is undone: StreetQuestCards.body_m
## x CELL_K tall, the cell's own aspect.
static func size_px(ppm: float) -> Vector2:
	var hgt: float = StreetQuestCards.body_m() * CELL_K * ppm
	return Vector2(hgt * _tex.get_width() / float(FRAMES) / float(_tex.get_height()), hgt)


## Draws the hit cell for `h`'s facing, feet on `at_px`, faced and mirrored as the standing card.
static func draw(canvas: CanvasItem, at_px: Vector2, h: Fighter, ppm: float) -> void:
	var size: Vector2 = size_px(ppm)
	size.y /= ViewMode.shared().ground_k()
	var cell: Vector2 = Vector2(_tex.get_width() / float(FRAMES), float(_tex.get_height()))
	var f: Vector2i = RigHeadCard.frame_of(h.facing.angle())
	canvas.draw_set_transform(at_px, 0.0, Vector2(-1.0 if f.y == 1 else 1.0, 1.0))
	var dst: Rect2 = Rect2(-size.x * 0.5, -size.y * FOOT_Y, size.x, size.y)
	canvas.draw_texture_rect_region(_tex, dst, Rect2(cell.x * f.x, 0.0, cell.x, cell.y))
	canvas.draw_set_transform(Vector2.ZERO)


static func _grid() -> Texture2D:
	if _tex == null and ResourceLoader.exists(PATH):
		_tex = load(PATH) as Texture2D
	return _tex
