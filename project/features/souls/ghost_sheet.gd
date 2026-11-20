class_name GhostSheet
extends RefCounted
## Five facing rows with optional drawn left facings. A missing left cell mirrors the right one.

const LEFT_ROWS: int = 3
## The left sheet's row per screen octant (RigHeadCard's octants; -1 = drawn on the right sheet).
const LEFT_ROW: PackedInt32Array = [-1, -1, -1, 0, 1, 2, -1, -1]
const LEFT: bool = true

var tex: Texture2D = null
var cols: int = 8
var poses: bool = false
var left: Texture2D = null
var left_cols: int = 0
var hitback: GhostSheet = null  # optional one-column alternate on an act grid
var _profile_mid: GhostSheet = null
var _intervals: Dictionary[int, GhostWalkPages] = {}
var _mid_windows: Array[Vector2] = []


func _init(p_tex: Texture2D, p_cols: int, p_left: Texture2D = null, p_left_cols: int = 0) -> void:
	tex = p_tex
	cols = p_cols
	left = p_left
	left_cols = p_left_cols if p_left != null else 0


## Load both facings. Zero columns selects a pose sheet with square cells in five rows.
static func of(path: String, p_cols: int, p_left_cols: int = -1) -> GhostSheet:
	if not ResourceLoader.exists(path):
		return null
	var main: Texture2D = load(path) as Texture2D
	if main == null:
		return null
	var infer_pose: bool = p_cols == 0
	if infer_pose:
		var cell: int = floori(main.get_height() / float(GhostDrawn.ROWS))
		if cell < 1 or main.get_height() != cell * GhostDrawn.ROWS or main.get_width() % cell != 0:
			Log.warn("ghost_sheet", "%s needs five rows of square pose cells" % path)
			return null
		p_cols = floori(main.get_width() / float(cell))
	var lp: String = path.get_basename() + "_left.png"
	var lt: Texture2D = null
	if ResourceLoader.exists(lp):
		lt = load(lp) as Texture2D
		if lt == null:
			Log.warn("ghost_sheet", "could not read %s, mirroring right-facing cells" % lp)
	var sheet: GhostSheet = GhostSheet.new(
		main, p_cols, lt, p_cols if p_left_cols < 0 else p_left_cols
	)
	sheet.poses = infer_pose
	return sheet


## The two measured profiles share timing and each has its own pad drawings.
static func walk_of(
	path: String, steps: PackedFloat32Array, standing_only: bool = false
) -> GhostSheet:
	if standing_only:
		var pose_sheet: GhostSheet = of(path.trim_suffix("walk8.png") + "spec_hover.png", 0)
		if pose_sheet != null:
			return pose_sheet
	var sheet: GhostSheet = of(path, GhostStride.cols_of(steps))
	if sheet == null or standing_only:
		return sheet
	if steps.size() == 16 and path.ends_with("/p70/tonnage_walk8.png"):
		sheet._mid_windows = GhostStride.tonnage_windows(steps)
		sheet._profile_mid = of(path.get_basename() + "_mid.png", sheet._mid_windows.size())
		sheet._load_detail(path, steps, [1, 3, 5, 7], ["_diag"], GhostStride.DIAGONAL_DIVISIONS)
		sheet._load_detail(
			path, steps, [2, 6], ["_fill_a", "_fill_b"], GhostStride.DIAGONAL_DIVISIONS
		)
	elif steps.size() == 8 and path.ends_with("/p55/tonnage_walk8.png"):
		sheet._load_detail(path, steps, [0, 4], ["_detail"], GhostStride.PROFILE55_DIVISIONS)
		sheet._load_detail(
			path, steps, [1, 2, 3, 5, 6, 7], ["_fill_a", "_fill_b"], GhostStride.OTHER55_DIVISIONS
		)
	return sheet


func _load_detail(
	path: String,
	steps: PackedFloat32Array,
	octants: Array[int],
	suffixes: Array[String],
	divisions: Array[int]
) -> void:
	var bank: GhostWalkPages = GhostWalkPages.new()
	bank.windows = GhostStride.interval_windows(steps, divisions)
	@warning_ignore("integer_division")
	var page_cols: int = bank.windows.size() / suffixes.size()
	for suffix: String in suffixes:
		var page: GhostSheet = of(path.get_basename() + suffix + ".png", page_cols)
		if page == null:
			return
		bank.pages.append(page)
	for oct: int in octants:
		_intervals[oct] = bank


## An act grid (`key` "<name>/<pitch>"): its columns and its left sheet's, with Dent's jab columns
## where GhostDrawn.JAB_COLS / JAB_LEFT_COLS name the key.
static func act_of(path: String, key: String, spectral: bool = false) -> GhostSheet:
	if spectral:
		var acts_sheet: GhostSheet = of(
			path.trim_suffix("act.png") + "spec_act.png", GhostDrawn.ACT_COLS
		)
		if acts_sheet != null:
			return acts_sheet
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
	show(spr, 2, 0 if poses else GhostDrawn.STAND_COL)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	GhostSoulLine.attach(spr)
	return spr


## Keep the live cell's name stable when the view or look changes in the middle of a frame.
static func replace_sprite(
	host: Node2D, old: Sprite2D, sheet: GhostSheet, parts: Array[Sprite2D] = []
) -> Sprite2D:
	for part: Sprite2D in parts:
		part.visible = sheet == null
	if old != null:
		old.get_parent().remove_child(old)
		old.queue_free()
	if sheet == null:
		return null
	var spr: Sprite2D = sheet.make_sprite()
	host.add_child(spr)
	return spr


## True when octant `oct` at column `col` draws from the left sheet.
func drawn_left(oct: int, col: int) -> bool:
	return LEFT and left != null and LEFT_ROW[oct] >= 0 and col < left_cols


## Puts cell `col` of octant `oct` on `spr`: texture, grid, feet offset, frame and mirror.
func show(spr: Sprite2D, oct: int, col: int, phase: float = -1.0, rear: bool = false) -> void:
	if rear and hitback != null and col == GhostDrawn.HIT_COL:
		hitback.show(spr, oct, 0)
		return
	if _profile_mid != null and (oct == 0 or (oct == 4 and _profile_mid.drawn_left(oct, 0))):
		var mid: int = _profile_col(col, phase)
		if mid >= 0:
			_profile_mid.show(spr, oct, mid)
			return
	if _intervals.has(oct) and _intervals[oct].show(spr, oct, phase):
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


## Both profile drawings use the same two neighbouring dwells and half-open interval.
func _profile_col(col: int, phase: float) -> int:
	for i: int in _mid_windows.size():
		var step: int = GhostStride.MID_STEPS[i]
		var w: Vector2 = _mid_windows[i]
		if (col == step or col == step + 1) and phase >= w.x and phase < w.y:
			return i
	return -1


## The screen octant a shown cell faces (a drawn left row, or a right row and its mirror).
static func oct_of(spr: Sprite2D) -> int:
	var row: int = spr.frame / spr.hframes
	if spr.vframes == LEFT_ROWS:
		return LEFT_ROW.find(row)
	for o: int in 8:
		if RigHeadCard.OCT_FRAME[o] == row and RigHeadCard.OCT_FLIP[o] == int(spr.flip_h):
			return o
	return -1
