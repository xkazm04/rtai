class_name RivetBob
extends RefCounted
## n11 (the owner's "Rivet jumps too much during the movement"): the walk and run grids are packed
## bottom-aligned, so the helmet's drawn travel (up to 29 px of a 110 px figure on the run's flight
## frames) is the bounce the game shows. Each frame is lifted by (its helmet top - the row's highest
## top) x damp, from the measured table (rivet_bob.json, tools/art/rivet_bob.py). Render only.

const TABLE: String = "res://data/tables/rivet_bob.json"
const SCHEMA: String = "gtai.rivet-bob/1"

static var _grids: Dictionary = {}
static var _damp_walk: float = -1.0
static var _damp_run: float = 0.0


## The frame's lift in cell px (0 for a frame the table does not know).
static func lift_cell(key: String, frame: int, cols: int, running: bool) -> float:
	_load()
	var rows: Array = _grids.get(key, [])
	var row: int = frame / cols
	if rows.is_empty() or cols <= 0 or row >= rows.size():
		return 0.0
	var tops: Array = rows[row]
	var high: int = tops.min()
	var top: int = tops[frame % cols]
	return float(top - high) * (_damp_run if running else _damp_walk)


## The card's lift this frame in world px: `step_px` (the facing card's small gait lift), plus on a
## drawn walk or run grid the measured damp (`s` = the card's scale).
static func up(card: Sprite2D, s: float, step_px: float = 0.0) -> Vector2:
	if not RivetWalk.is_grid(card):
		return Vector2(0.0, step_px)
	var path: String = str(card.get_meta(RivetFrames.ON, ""))
	var key: String = path.get_base_dir().get_file() + "/" + path.get_file()
	return Vector2(
		0.0, step_px + lift_cell(key, card.frame, card.hframes, RivetWalk.is_run(path)) * s
	)


static func _load() -> void:
	if _damp_walk >= 0.0:
		return
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	_damp_walk = t.num(t.raw, "damp_walk")
	_damp_run = t.num(t.raw, "damp_run")
	_grids = t.object(t.raw, "grids")
