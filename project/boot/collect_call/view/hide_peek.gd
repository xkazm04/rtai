class_name HidePeek
extends RefCounted
## n15 hero it14: quest 1's hide bin with Rivet tucked in, under a tilt: the asset lane's peek card
## (the ribbed bin, its lid propped on his helmet, the amber visor in the gap; art id
## `rivet_hide_<pitch>`) drawn in place of the standing bin card at the spot he hides in, as wide
## as that card, on its foot. CastView then skips its round peek token. A flat view or a pitch with
## no card returns false and the bin and token draw as before. PEEK false = the before. Render only.

const PEEK: bool = true
const SIZE_M: Vector2 = Vector2(2.4, 1.6)


## The card's rect (ci-local px) at hide spot `at`, empty when no peek card stands there.
static func rect(at: Vector2) -> Rect2:
	var tex: Texture2D = _tex()
	if tex == null:
		return Rect2()
	var ground: Rect2 = Rect2(Ink.px(at - SIZE_M * 0.5), SIZE_M * Ink.PX_PER_M)
	var card: Rect2 = PropCards.stand_rect("dumpster", ground)
	if card.size.x <= 0.0:
		return Rect2()
	var h: float = card.size.x * tex.get_height() / tex.get_width()
	return Rect2(card.position.x, card.end.y - h, card.size.x, h)


## True when the spot Rivet hides in draws as the peek card (CastView skips its token).
static func stands(stage: CollectCallStage) -> bool:
	if not stage.layout.hide_at.has(stage.hidden_in):
		return false
	return rect(stage.layout.hide_at[stage.hidden_in]).size.x > 0.0


## Draws the peek card for `spot` on `ci` (its _draw) when Rivet hides there; false otherwise.
static func draw(ci: CanvasItem, stage: CollectCallStage, spot: String) -> bool:
	if spot != stage.hidden_in:
		return false
	var r: Rect2 = rect(stage.layout.hide_at[spot])
	if r.size.x <= 0.0:
		return false
	ci.draw_texture_rect(_tex(), r, false)
	return true


static func _tex() -> Texture2D:
	var id: StringName = StringName("rivet_hide_" + ViewMode.shared().art)
	return QuestArt.shared().texture(id) if PEEK and QuestArt.shared().has(id) else null
