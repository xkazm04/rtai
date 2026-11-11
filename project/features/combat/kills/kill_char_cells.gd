class_name KillCharCells
extends RefCounted
## n15 combat (brief item 2, n11 REPORT "a fire death is still brutality's charred silhouette"):
## a burn kill of a kind with the asset lane's drawn charred man (it272 the patrol cop, B;
## it359 the thug, the hooded pedestrian and the riot cop, A, no smoke: charcoal bodies, ember
## cracks; tools/art/street_hit.py CHARS) stands as that
## drawing instead of its card under KillCharFx's char print. KillStyles tags the body group with
## the victim's card row when the parts are cut, and swaps its whole-figure card after the char
## print: the drawn cell for the card's facing, upright, sized as StreetWalkerCards sizes the
## kind's burning figure (the char cells are packed at the burn cells' scale), feet on the card's
## point, its own colours (no char shader). The embers, smoke and crumble stay KillCharFx's.
## Render only. `--char-cells=off` = the char-printed card (the before).

const GRIDS: Dictionary[String, String] = {
	"cop/head_cap": "res://features/characters/art/view/p70/cop_patrol_char_hit.png",
	"cop/head_helmet": "res://features/characters/art/view/p70/cop_riot_char_hit.png",
	"thug": "res://features/characters/art/view/p70/thug_char_hit.png",
	"ped/head_hood": "res://features/characters/art/view/p70/ped_hood_char_hit.png",
}
## The burning figure's FILL (StreetWalkerHit.FILL) per grid: the char cells share its scale.
const FILL_OF: Dictionary[String, String] = {
	"cop/head_cap": "cop_patrol_burn_hit.png",
	"cop/head_helmet": "cop_riot_burn_hit.png",
	"thug": "thug_burn_hit.png",
	"ped/head_hood": "ped_hood_burn_hit.png",
}
const META: StringName = &"kill_char_row"
const CARD: StringName = &"head_card"

static var _off: int = -1


## True unless `--char-cells=off`.
static func enabled() -> bool:
	if _off < 0:
		_off = 1 if ArenaArgs.parse().text("--char-cells") == "off" else 0
	return _off == 0


## Marks `body` (the burn kill's BODY group) with `rig`'s card row when that row has a char grid.
static func tag(body: Node2D, rig: CutRig) -> void:
	if body == null or rig == null or not enabled():
		return
	var row: String = StreetWalkerCards.row_of(rig)
	if GRIDS.has(row) and ResourceLoader.exists(GRIDS[row]):
		body.set_meta(META, row)


## Swaps the tagged group's card copy to the drawn char cell; returns it (null = not swapped).
static func swap(body: Node2D) -> Sprite2D:
	if body == null or not body.has_meta(META):
		return null
	var card: Sprite2D = body.get_node_or_null(NodePath(String(CARD))) as Sprite2D
	if card == null:
		return null
	var row: String = str(body.get_meta(META))
	var col: int = card.frame % RigHeadCard.FRAMES if card.hframes == RigHeadCard.FRAMES else 0
	var tex: Texture2D = load(GRIDS[row]) as Texture2D
	card.texture = tex
	card.region_enabled = false
	card.hframes = RigHeadCard.FRAMES
	card.vframes = 1
	card.frame = col
	card.material = null
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	card.centered = false
	card.offset = Vector2(-cell.x * 0.5, -cell.y * StreetWalkerCards.FOOT_Y)
	var s: float = scale_of(row, tex.get_height())
	card.transform = Transform2D(0.0, Vector2(s, s), 0.0, card.position)
	return card


## The cell's scale in rig px: the kind's standing height x the burning figure's FILL over the
## cell height (StreetWalkerCards.place for a hit grid, without the per-person size jitter).
static func scale_of(row: String, tex_h: int) -> float:
	var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(
		ViewMode.shared().art, StreetWalkerCards.HEIGHT_M
	)
	var fill: float = StreetWalkerHit.FILL.get(FILL_OF.get(row, ""), 1.0)
	return h * CharacterRigs.PX_PER_M * fill / float(tex_h)
