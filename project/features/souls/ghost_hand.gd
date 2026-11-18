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
	"ohm/p55":
	[Vector2(-44, -59), Vector2(14, -63), Vector2(71, -61), Vector2(80, -105), Vector2(44, -152)],
}

## Raised prong tips in wind-up column zero, relative to the foot point. Five right rows
## followed by the three independently drawn left rows.
const WINDUP: Dictionary[String, Array] = {
	"ohm/p70":
	[
		Vector2(-60, -211),
		Vector2(-104, -162),
		Vector2(-78, -152),
		Vector2(-5, -181),
		Vector2(-15, -125),
		Vector2(87, -178),
		Vector2(84, -134),
		Vector2(84, -165)
	],
	"ohm/p55":
	[
		Vector2(-64, -216),
		Vector2(-99, -179),
		Vector2(-88, -151),
		Vector2(-53, -183),
		Vector2(-7, -146),
		Vector2(108, -198),
		Vector2(105, -180),
		Vector2(88, -186)
	],
}

static var enabled: bool = true
static var _at: Dictionary[String, Vector2] = {}


## Records the casting hand on each drawn cast frame, including its raised wind-up.
static func note(name: String, art: String, spr: Sprite2D, oct: int, striking: bool) -> void:
	var key: String = name + "/" + art
	if not enabled or not striking or not CELLS.has(key):
		@warning_ignore("return_value_discarded")
		_at.erase(name)
		return
	var cell: Vector2 = CELLS[key][RigHeadCard.OCT_FRAME[oct]]
	if RigHeadCard.OCT_FLIP[oct] == 1:
		cell.x = -cell.x
	if spr.hframes == GhostDrawn.ACT_COLS and spr.frame_coords.x == GhostDrawn.WINDUP_COL:
		var left: bool = spr.vframes == GhostSheet.LEFT_ROWS
		cell = WINDUP[key][spr.frame_coords.y + (GhostDrawn.ROWS if left else 0)]
		if spr.flip_h:
			cell.x = -cell.x
	_at[name] = spr.get_global_transform_with_canvas() * cell


## The hand of `name` in `node`'s local space, or Vector2.INF when none is noted.
static func local_to(name: String, node: CanvasItem) -> Vector2:
	if not _at.has(name):
		return Vector2.INF
	return node.get_global_transform_with_canvas().affine_inverse() * _at[name]
