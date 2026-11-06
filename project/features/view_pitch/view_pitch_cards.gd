class_name ViewPitchCards
extends RefCounted
## Lane d8-view70: which art folder the facing cards (RigHeadCard) draw from, by the live pitch.
## Until RigHeadCard resolves a view row's `art` itself (REQUEST to lane chars, JOURNAL), this
## seeds RigHeadCard's texture cache with the folder's strip under the base path, so every card
## built from now on draws it, and re-textures the cards already standing (the combined view
## crossing swap_deg), keeping each card's anchor fraction. Render only; straight down nothing
## here runs (no card is ever built).

static var _folder: String = "?"


## Draw every card from the art folder `folder` ("" = the base cards); `root` holds the live
## cards to re-texture (null = only the cache, before any card is built).
static func apply(root: Node, folder: String) -> void:
	if folder == _folder:
		return
	_folder = folder
	var swap: Dictionary[Texture2D, Texture2D] = {}
	for key: String in RigHeadCard.CARDS:
		var base: String = RigHeadCard.CARDS[key][0]
		var tex: Texture2D = load(ViewPitch.card_path(base, folder)) as Texture2D
		var old: Texture2D = RigHeadCard._tex.get(base, null)
		if old != null and old != tex:
			swap[old] = tex
		RigHeadCard._tex[base] = tex
	if root == null or swap.is_empty():
		return
	for n: Node in root.find_children("head_card", "Sprite2D", true, false):
		var card: Sprite2D = n as Sprite2D
		if swap.has(card.texture):
			retexture(card, swap[card.texture])


## `card` drawn from `tex` (another strip of the same frames), its anchor kept at the same
## fraction of the cell height.
static func retexture(card: Sprite2D, tex: Texture2D) -> void:
	var frac: float = -card.offset.y / maxf(card.texture.get_height(), 1.0)
	card.texture = tex
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	card.offset = Vector2(-cell.x * 0.5, -cell.y * frac)


## The folder the cards draw from now ("?" before the first apply).
static func current() -> String:
	return _folder
