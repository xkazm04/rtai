class_name RivetFramesGrids
extends RefCounted
## Shared movement art data. Resolve each gameplay grip once, independently of rig state.

const BARE: StringName = &"bare_claw"
static var _grid: Dictionary[StringName, StringName] = {}
static var _borrowed: StringName
static var _palms: Dictionary = {}


static func grid_for(weapon: StringName) -> StringName:
	if weapon == &"":
		return BARE
	if _grid.is_empty():
		_load()
	return _grid.get(weapon, _borrowed)


static func _load() -> void:
	var table: DataTable = DataTable.open(
		"res://data/tables/rivet_motion.json", "gtai.rivet-motion/1"
	)
	var row: Dictionary = table.object(table.raw, "walk_grid")
	var defaults: Dictionary = table.object(row, "by_grip")
	var overrides: Dictionary = table.object(row, "by_weapon")
	_borrowed = StringName(table.text(row, "borrowed_grid"))
	_palms = table.object(row, "palm_percent")
	var arsenal: DataTable = DataTable.open(
		"res://data/tables/rivet_arsenal.json", "gtai.rivet-arsenal/1"
	)
	var weapons: Dictionary = arsenal.object(arsenal.raw, "weapons")
	for id: StringName in weapons:
		var family: StringName = overrides.get(id, defaults.get(weapons[id], BARE))
		_grid[id] = id if family == id else _borrowed


## walk4 is walk8's contact and passing drawings (even columns). Coordinates are fractions of
## the packed cell, so placement follows the card's foot offset, bob, stretch and player scale.
static func palm(pitch: String, running: bool, frame: Vector2i, cols: int) -> Vector2:
	if _palms.is_empty():
		_load()
	var poses: Dictionary = _palms[pitch]
	var rows: Array = poses["run" if running else "walk"]
	var row: Array = rows[frame.y]
	var x: int = frame.x * 2 if cols == 4 else frame.x
	var px: float = row[2 * x]
	var py: float = row[2 * x + 1]
	return Vector2(px, py) * 0.01
