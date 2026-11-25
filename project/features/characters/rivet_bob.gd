class_name RivetBob
extends RefCounted
## n11 (the owner's "Rivet jumps too much during the movement"): the walk and run grids are packed
## bottom-aligned, so the helmet's drawn travel is the bounce the game shows. n31 ("the animation
## jumps too much, the shadow below looks like flying"): each row of a grid gets one figure height
## (the row's mean, held inside what every frame can reach); each frame moves toward it by damp with
## a height factor about the feet, which stay planted (`stretch_min`..`stretch_max`: tall frames
## squash, short ones stretch), and only a run frame the stretch cannot carry lifts, by at most
## `lift_max_cell`. Heights are 110-space px (rivet_bob.json, tools/art/rivet_bob.py), the cell's
## too (the native recut's cell / RivetWalk.RES). Render only.

const TABLE: String = "res://data/tables/rivet_bob.json"
const SCHEMA: String = "gtai.rivet-bob/1"

static var enabled: bool = true
static var _grids: Dictionary = {}
static var _damp_walk: float = -1.0
static var _damp_run: float = 0.0
static var _stretch_min: float = 1.0
static var _stretch_max: float = 1.0
static var _lift_max_cell: float = 0.0


## This frame's (height factor about the feet, lift in 110-space px); (1, 0) for a frame the table
## does not know. `cell_h` = the cell's height in 110-space px.
static func fit(key: String, frame: int, cols: int, running: bool, cell_h: float) -> Vector2:
	var row: Array = _row(key, frame, cols)
	if row.is_empty() or not enabled:
		return Vector2(1.0, 0.0)
	var lift_max: float = _lift_max_cell if running else 0.0
	var top: int = row[frame % cols]
	var at: float = cell_h - float(top)
	var aim: float = _aim(row, cell_h, lift_max)
	var goal: float = at + (aim - at) * (_damp_run if running else _damp_walk)
	var k: float = clampf(goal / maxf(at, 1.0), _stretch_min, _stretch_max)
	return Vector2(k, clampf(goal - at * k, 0.0, lift_max))


## The row's one figure height: its mean, inside what every frame reaches (squash..stretch + lift);
## the middle of the gap when no height is reachable by all.
static func _aim(row: Array, cell_h: float, lift_max: float) -> float:
	var lo: float = 0.0
	var hi: float = INF
	var sum: float = 0.0
	for top: int in row:
		var h: float = cell_h - float(top)
		lo = maxf(lo, h * _stretch_min)
		hi = minf(hi, h * _stretch_max + lift_max)
		sum += h
	if lo > hi:
		return (lo + hi) * 0.5
	return clampf(sum / float(row.size()), lo, hi)


## The card's lift this frame in world px: `step_px` (the facing card's small gait lift), plus on a
## drawn walk or run grid what the stretch could not carry (`s` = card scale per 110-space px).
static func up(card: Sprite2D, s: float, step_px: float = 0.0) -> Vector2:
	if not RivetWalk.is_grid(card):
		return Vector2(0.0, step_px)
	return Vector2(0.0, step_px + _fit(card).y * s)


## Places `card` above `rig`'s feet by `up` and publishes that lift (RigCastShadows.CAST_LIFT): the
## contact shadow under him shrinks and fades with it (n31).
static func lift_card(rig: CutRig, card: Sprite2D, s: float, step_px: float) -> void:
	var lift: Vector2 = up(card, s, step_px)
	rig.set_meta(RigCastShadows.CAST_LIFT, lift.y)
	card.global_position = rig.global_position - lift


## The card's height factor this frame, about the feet (the card's origin): 1 off a grid.
static func stretch(card: Sprite2D) -> float:
	if not RivetWalk.is_grid(card):
		return 1.0
	return _fit(card).x


static func _fit(card: Sprite2D) -> Vector2:
	var cell_h: float = card.texture.get_height() / float(card.vframes) / RivetWalk.RES
	var path: String = str(card.get_meta(RivetFrames.ON, ""))
	var key: String = path.get_base_dir().get_file() + "/" + path.get_file()
	return fit(key, card.frame, card.hframes, RivetWalk.is_run(path), cell_h)


## The frame's row of helmet tops in the table, empty when the table does not know it.
static func _row(key: String, frame: int, cols: int) -> Array:
	_load()
	var rows: Array = _grids.get(key, [])
	if rows.is_empty() or cols <= 0 or frame / cols >= rows.size():
		return []
	var row: Array = rows[frame / cols]
	return row


static func _load() -> void:
	if _damp_walk >= 0.0:
		return
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	_damp_walk = t.num(t.raw, "damp_walk")
	_damp_run = t.num(t.raw, "damp_run")
	_stretch_min = t.num(t.raw, "stretch_min")
	_stretch_max = t.num(t.raw, "stretch_max")
	_lift_max_cell = t.num(t.raw, "lift_max_cell")
	_grids = t.object(t.raw, "grids")
