class_name GhostSheet
extends RefCounted
## n15 hero h-3 (the owner's Call): one of a drawn ghost's grids (walk8, run8 or act) with its drawn
## left rows. The grid draws 5 facings (toward, 3/4 toward right, right profile, 3/4 away right,
## away); the screen-left octants mirror rows 2-4 unless `<name>_<sheet>_left.png` exists: 3 rows
## (3/4 toward left, left profile, 3/4 away left), packed by tools/art/ghost_pack.py at the right
## grid's scale, so the one-sided details (Dent's pouch) sit where they belong. A left sheet keeps
## the right one's columns, except an act sheet, whose left rows draw the 4 phases only: a column
## past them (Dent's jab) mirrors the right row. LEFT false = every left octant mirrored (the
## before; so is a ghost or pitch with no left sheet yet). Render only.

const LEFT_ROWS: int = 3
## The left sheet's row per screen octant (RigHeadCard's octants; -1 = drawn on the right sheet).
const LEFT_ROW: PackedInt32Array = [-1, -1, -1, 0, 1, 2, -1, -1]
const LEFT: bool = true
const TONNAGE_MID_STEP: int = 5

var tex: Texture2D = null
var cols: int = 8
var left: Texture2D = null
var left_cols: int = 0
var hitback: GhostSheet = null  # optional one-column alternate on an act grid
var _profile_mid: GhostSheet = null
var _mid_window: Vector2 = Vector2.ZERO


func _init(p_tex: Texture2D, p_cols: int, p_left: Texture2D = null, p_left_cols: int = 0) -> void:
	tex = p_tex
	cols = p_cols
	left = p_left
	left_cols = p_left_cols if p_left != null else 0


## The grid at `path` (null when it is not there) and its left sheet when one is.
static func of(path: String, p_cols: int, p_left_cols: int = -1) -> GhostSheet:
	if not ResourceLoader.exists(path):
		return null
	var lp: String = path.get_basename() + "_left.png"
	var lt: Texture2D = load(lp) as Texture2D if ResourceLoader.exists(lp) else null
	return GhostSheet.new(
		load(path) as Texture2D, p_cols, lt, p_cols if p_left_cols < 0 else p_left_cols
	)


## Tonnage's p70 right profile has one extra drawing between C6 and C7.
## Use the middle half of the capped step, centred on the usual cell change.
static func walk_of(path: String, steps: PackedFloat32Array) -> GhostSheet:
	var sheet: GhostSheet = of(path, GhostStride.cols_of(steps))
	if (
		sheet != null
		and steps.size() > TONNAGE_MID_STEP
		and path.ends_with("/p70/tonnage_walk8.png")
	):
		sheet._profile_mid = of(path.get_basename() + "_mid.png", 1)
		var dwell: PackedFloat32Array = GhostStride.dwell_of(steps)
		var boundary: float = 0.0
		var total: float = 0.0
		for i: int in dwell.size():
			total += dwell[i]
			if i <= TONNAGE_MID_STEP:
				boundary += dwell[i]
		var quarter: float = steps[TONNAGE_MID_STEP] * 0.25
		sheet._mid_window = Vector2(boundary - quarter, boundary + quarter) / total
	return sheet


## An act grid (`key` "<name>/<pitch>"): its columns and its left sheet's, with Dent's jab columns
## where GhostDrawn.JAB_COLS / JAB_LEFT_COLS name the key.
static func act_of(path: String, key: String) -> GhostSheet:
	var acts: int = GhostDrawn.JAB_COLS.get(key, GhostDrawn.ACT_COLS)
	var lefts: int = GhostDrawn.JAB_LEFT_COLS.get(key, GhostDrawn.ACT_COLS)
	var sheet: GhostSheet = of(path, acts, lefts)
	var rear: String = path.get_basename() + "_hitback.png"
	if sheet != null and ResourceLoader.exists(rear):
		sheet.hitback = GhostSheet.new(load(rear) as Texture2D, 1)
	return sheet


## Creates the ghost sprite standing on this walk sheet, with its outline attached.
func make_sprite() -> Sprite2D:
	var spr: Sprite2D = Sprite2D.new()
	spr.name = &"ghost_drawn"
	spr.centered = false
	show(spr, 2, GhostDrawn.STAND_COL)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	GhostSoulLine.attach(spr)
	return spr


## True when octant `oct` at column `col` draws from the left sheet.
func drawn_left(oct: int, col: int) -> bool:
	return LEFT and left != null and LEFT_ROW[oct] >= 0 and col < left_cols


## Puts cell `col` of octant `oct` on `spr`: texture, grid, feet offset, frame and mirror.
func show(spr: Sprite2D, oct: int, col: int, phase: float = -1.0) -> void:
	if (
		_profile_mid != null
		and oct == 0
		and (col == TONNAGE_MID_STEP or col == TONNAGE_MID_STEP + 1)
	):
		if phase >= _mid_window.x and phase < _mid_window.y:
			_profile_mid.show(spr, oct, 0)
			return
	var on_left: bool = drawn_left(oct, col)
	var t: Texture2D = left if on_left else tex
	var c: int = left_cols if on_left else cols
	var rows: int = LEFT_ROWS if on_left else GhostDrawn.ROWS
	if spr.texture != t or spr.hframes != c or spr.vframes != rows:
		spr.frame = 0  # the grids differ in size: never out of range mid-swap
		spr.texture = t
		spr.hframes = c
		spr.vframes = rows
		var cell: Vector2 = t.get_size() / Vector2(c, rows)
		spr.offset = Vector2(-cell.x * 0.5, GhostDrawn.PAD_PX - cell.y)
	var row: int = LEFT_ROW[oct] if on_left else RigHeadCard.OCT_FRAME[oct]
	spr.frame = row * c + col
	spr.flip_h = not on_left and RigHeadCard.OCT_FLIP[oct] == 1
	GhostSoulLine.sync(spr)


## The screen octant a shown cell faces (a drawn left row, or a right row and its mirror).
static func oct_of(spr: Sprite2D) -> int:
	var row: int = spr.frame / spr.hframes
	if spr.vframes == LEFT_ROWS:
		return LEFT_ROW.find(row)
	for o: int in 8:
		if RigHeadCard.OCT_FRAME[o] == row and RigHeadCard.OCT_FLIP[o] == int(spr.flip_h):
			return o
	return -1
