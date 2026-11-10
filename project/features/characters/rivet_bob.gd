class_name RivetBob
extends RefCounted
## n11 (the owner's "Rivet jumps too much during the movement"): the walk and run grids are packed
## bottom-aligned, so the helmet's drawn travel (up to 29 px of a 110 px figure on the run's flight
## frames) is the bounce the game shows. Each frame takes back (its helmet top - the row's highest
## top) x damp, from the measured table (rivet_bob.json, tools/art/rivet_bob.py). Up to
## `stretch_cell` of that is a stretch from the feet, which stay planted; only what is left over
## (the run's flight frames, legs tucked and packed down to the floor) lifts him. Render only.

const TABLE: String = "res://data/tables/rivet_bob.json"
const SCHEMA: String = "gtai.rivet-bob/1"

static var enabled: bool = true
static var _grids: Dictionary = {}
static var _damp_walk: float = -1.0
static var _damp_run: float = 0.0
static var _stretch_cell: float = 0.0


## The helmet travel this frame takes back, in cell px (0 for a frame the table does not know).
static func taken_cell(key: String, frame: int, cols: int, running: bool) -> float:
	_load()
	var top: int = _top(key, frame, cols)
	if top < 0 or not enabled:
		return 0.0
	var tops: Array = _grids[key][frame / cols]
	var high: int = tops.min()
	return float(top - high) * (_damp_run if running else _damp_walk)


## What lifts the whole figure, feet included, in cell px: the part past the stretch's share.
static func lift_cell(key: String, frame: int, cols: int, running: bool) -> float:
	return maxf(0.0, taken_cell(key, frame, cols, running) - _stretch_cell)


## What the stretch from the feet takes back, in cell px.
static func stretch_cell(key: String, frame: int, cols: int, running: bool) -> float:
	return minf(taken_cell(key, frame, cols, running), _stretch_cell)


## The card's lift this frame in world px: `step_px` (the facing card's small gait lift), plus on a
## drawn walk or run grid what the stretch could not take (`s` = the card's scale).
static func up(card: Sprite2D, s: float, step_px: float = 0.0) -> Vector2:
	if not RivetWalk.is_grid(card):
		return Vector2(0.0, step_px)
	var cell: float = lift_cell(_key(card), card.frame, card.hframes, _running(card))
	return Vector2(0.0, step_px + cell * s)


## The card's height factor this frame, about the feet (the card's origin): 1 off a grid.
static func stretch(card: Sprite2D) -> float:
	if not RivetWalk.is_grid(card):
		return 1.0
	var key: String = _key(card)
	var top: int = _top(key, card.frame, card.hframes)
	var cell_h: float = card.texture.get_height() / float(card.vframes)
	var figure: float = cell_h - float(maxi(top, 0))
	var extra: float = stretch_cell(key, card.frame, card.hframes, _running(card))
	return 1.0 + extra / maxf(figure, 1.0)


## The frame's helmet top in the table, -1 when the table does not know it.
static func _top(key: String, frame: int, cols: int) -> int:
	_load()
	var rows: Array = _grids.get(key, [])
	if rows.is_empty() or cols <= 0 or frame / cols >= rows.size():
		return -1
	var row: Array = rows[frame / cols]
	var top: int = row[frame % cols]
	return top


static func _key(card: Sprite2D) -> String:
	var path: String = str(card.get_meta(RivetFrames.ON, ""))
	return path.get_base_dir().get_file() + "/" + path.get_file()


static func _running(card: Sprite2D) -> bool:
	return RivetWalk.is_run(str(card.get_meta(RivetFrames.ON, "")))


static func _load() -> void:
	if _damp_walk >= 0.0:
		return
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	_damp_walk = t.num(t.raw, "damp_walk")
	_damp_run = t.num(t.raw, "damp_run")
	_stretch_cell = t.num(t.raw, "stretch_cell")
	_grids = t.object(t.raw, "grids")
