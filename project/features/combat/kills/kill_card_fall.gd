class_name KillCardFall
extends RefCounted
## n30 combat (owner, decisions 1598: "a killed card foe falls on his own fall sheet when the kill
## style has none"). A whole-body kill's hidden fall grid (KillFallCells) for a card foe
## (CastCardPose) is his own `sheets.fall`, the sheet his living death draws
## (CastCardPose.path_for): 5 facings across, StreetFallBetween.rows_of rows down (buckle,
## mid-fall, lying), the feet at the cell centre, sized as StreetWalkerFall.draw sizes it (the
## art's height at STILL_PX, times his card scale). So the generic grid's geometry holds and only
## the drawing changes. A style's own cells for the street row of his pooled rig draw another
## kind, so he keeps only cells drawn for any victim ("*"). A row whose sheet is missing or does
## not split into that grid keeps the generic grid. `--kill-card-fall=grid` = the generic grid
## and the street row's cells for every card foe (the before).

const FLAG: String = "--kill-card-fall"
const GRID: String = "grid"
## The cells key a death draws for any victim (KillDeathCells.path_in).
const ANY: String = "*"

## -1 = not read yet (reads FLAG once); 1 = his own fall sheet; 0 = the generic grid.
static var _on: int = -1


## His own fall sheet as "<art>/<file>" under StreetWalkerCards.DIR, as the generic grids are
## named ("" = none: not a card foe, the flag off, or no usable sheet).
static func path_of(rig: CutRig) -> String:
	if not on() or rig == null:
		return ""
	var pose: CastCardPose = CastCardPose.of(rig)
	if pose == null or pose.sheets == null:
		return ""
	return usable(pose.sheets.fall)


## `full` (a res:// fall sheet) as "<art>/<file>" when it exists under StreetWalkerCards.DIR and
## splits into the living death's grid (RigHeadCard.FRAMES across, rows_of down); else "".
static func usable(full: String) -> String:
	var dir: String = StreetWalkerCards.DIR
	if not full.begins_with(dir) or not full.ends_with("_fall.png"):
		return ""
	if not ResourceLoader.exists(full):
		return ""
	var tex: Texture2D = StreetStrips.get_tex(full)
	if tex == null:
		return ""
	var path: String = full.trim_prefix(dir)
	var rows: int = StreetFallBetween.rows_of(path)
	if not splits(Vector2i(tex.get_size()), rows):
		return ""
	return path


## True when a sheet of `size` splits into RigHeadCard.FRAMES columns and `rows` rows.
static func splits(size: Vector2i, rows: int) -> bool:
	return size.x % RigHeadCard.FRAMES == 0 and size.y % rows == 0


## The card row a death's own cells are looked up by (KillDeathCells.path_of): a card foe's
## (`card` his sheet, non-empty) is ANY, so only cells drawn for any victim are his; the street
## row of his pooled rig (cop/head_swat) names another kind's drawn death. Else `row`.
static func cells_row(card: String, row: String) -> String:
	return row if card.is_empty() else ANY


## The fall grid with no own death cells: his sheet `card`, else the row's generic grid.
static func grid(card: String, art: String, row: String) -> String:
	return card if not card.is_empty() else StreetWalkerFall.path_of(art, row)


## True when a card foe falls on his own sheet (FLAG not "grid").
static func on() -> bool:
	if _on < 0:
		_on = 0 if LaunchArgs.value(FLAG) == GRID else 1
	return _on == 1


## Sets the toggle (tests; -1 = read FLAG again).
static func set_on(value: int) -> void:
	_on = value
