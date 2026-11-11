class_name GibCardPieces
extends RefCounted
## n15 combat (DEFECTS "Rocket lone kill" (b): GibCardCut's six regions cut straight across the
## card read as paper cut-outs): a kind with the asset lane's drawn gib pieces (it359/it363, the
## patrol cop v2 and the riot cop, filmed as cut cards: head,
## torso, two arms, two legs with torn sooty edges, no blood; tools/art/gib_pieces.py packs them
## six across, the torso TORSO_PX tall) flies those instead. Each region copy keeps its place, flip,
## z and material and takes its drawn piece at one scale per kind: the drawn torso as tall as the
## card's torso band. Render only, no RNG. `--gib-pieces=cut` = the straight cut (the before).

const GRIDS: Dictionary[String, String] = {
	"cop/head_cap": "res://features/characters/art/view/p70/cop_patrol_gib.png",
	"cop/head_helmet": "res://features/characters/art/view/p70/cop_riot_gib.png",
}
## tools/art/gib_pieces.py: CELL and TORSO_PX (64: drawn at about the card's own downscale).
const CELL: float = 96.0
const TORSO_PX: float = 64.0

static var _cut: int = -1


## True unless `--gib-pieces=cut`.
static func enabled() -> bool:
	if _cut < 0:
		_cut = 1 if ArenaArgs.parse().text("--gib-pieces") == "cut" else 0
	return _cut == 0


## The drawn grid for `row`, or null (no pieces for this kind, or switched off).
static func grid_of(row: String) -> Texture2D:
	if not enabled() or not GRIDS.has(row) or not ResourceLoader.exists(GRIDS[row]):
		return null
	return load(GRIDS[row]) as Texture2D


## Dresses GibCardCut.split's [piece index, Sprite2D] pairs in `row`'s drawn pieces; `cell_h` is
## the card cell's height in texture px. False (left as the cut) when the kind has none.
static func dress(row: String, pieces: Array, cell_h: float) -> bool:
	var tex: Texture2D = grid_of(row)
	if tex == null:
		return false
	var m: float = (GibCardCut.LEG_V - GibCardCut.HEAD_V) * cell_h / TORSO_PX
	for kp: Array in pieces:
		var k: int = kp[0]
		var piece: Sprite2D = kp[1]
		piece.texture = tex
		piece.region_enabled = true
		piece.region_rect = Rect2(CELL * k, 0.0, CELL, CELL)
		piece.transform = piece.transform * Transform2D(0.0, Vector2(m, m), 0.0, Vector2.ZERO)
	return true
