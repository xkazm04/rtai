class_name GhostHand
extends RefCounted
## n15 hero (combat feel): where a drawn ghost's striking hand is on screen, so a strike's effect
## leaves from the drawn hand and not from the old rig's anchor (Ohm's bolt left from
## OhmStage's electrodes, a hand's length short of the x1.5 figure's fingertips). GhostDrawn notes
## the hand each frame its strike cell shows; OhmView moves the bolt's prongs there. The hand spot
## is measured per drawn facing row in the CUT cell (`evidence/s15/tools/ohm_hand.py`: the
## fingertips, cell px from the feet point); a screen-left octant mirrors its row's x (the drawn
## left rows are near enough). Render only. `enabled` false (`--ghost-ohm-hand=sim`) = the rig's
## electrodes (the before).

## "<name>/<art>" -> per drawn row (toward, 3/4 toward, profile, 3/4 away, away) the fingertips.
const CELLS: Dictionary[String, Array] = {
	"ohm/p70":
	[Vector2(-52, -60), Vector2(22, -44), Vector2(77, -61), Vector2(79, -108), Vector2(72, -130)],
}

static var enabled: bool = true
static var _at: Dictionary[String, Vector2] = {}


## GhostDrawn, each frame: `spr` shows octant `oct`; `striking` while its cut or follow-through
## cell shows. Notes the hand's canvas position, or forgets it.
static func note(name: String, art: String, spr: Sprite2D, oct: int, striking: bool) -> void:
	var key: String = name + "/" + art
	if not enabled or not striking or not CELLS.has(key):
		@warning_ignore("return_value_discarded")
		_at.erase(name)
		return
	var cell: Vector2 = CELLS[key][RigHeadCard.OCT_FRAME[oct]]
	if RigHeadCard.OCT_FLIP[oct] == 1:
		cell.x = -cell.x
	_at[name] = spr.get_global_transform_with_canvas() * cell


## The hand of `name` in `node`'s local space, or Vector2.INF when none is noted.
static func local_to(name: String, node: CanvasItem) -> Vector2:
	if not _at.has(name):
		return Vector2.INF
	return node.get_global_transform_with_canvas().affine_inverse() * _at[name]
