class_name RivetGridStride
extends RefCounted
## Packed grid calibrations shared by every Rivet rig. Cycle lengths use the 110-pixel
## standing-height space. Profile travel uses packed texels for each of the two support feet.

static var _shared: RivetGridStride

## Per sheet row, each component is a full-cycle length for one support foot.
var bare_run: Dictionary[String, PackedVector2Array] = {}
var bare_walk: Dictionary[String, PackedVector2Array] = {}
var bare_max_cycles_s: float
var run_cycle_cell: Dictionary[String, float] = {}
var cycle_cell: Dictionary[String, float] = {}
var armed_cycle_cell: Dictionary[String, float] = {}
var run_row_k: Dictionary[String, float] = {}
var walk_profile_travel: Dictionary[String, Vector2] = {}


static func shared() -> RivetGridStride:
	if _shared == null:
		var t: DataTable = DataTable.open(
			"res://data/tables/rivet_motion.json", "gtai.rivet-motion/1"
		)
		var block: Dictionary = t.object(t.raw, "grid_stride")
		var grid: RivetGridStride = RivetGridStride.new()
		grid.run_cycle_cell = _numbers(t, t.object(block, "run_cycle_cell"))
		grid.cycle_cell = _numbers(t, t.object(block, "cycle_cell"))
		grid.armed_cycle_cell = _numbers(t, t.object(block, "armed_cycle_cell"))
		grid.run_row_k = _numbers(t, t.object(block, "run_row_k"))
		grid.bare_run = _rows(t, t.object(block, "bare_run"))
		grid.bare_walk = _rows(t, t.object(block, "bare_walk"))
		grid.bare_max_cycles_s = t.num(block, "bare_max_cycles_s")
		var pairs: Dictionary = t.object(block, "walk_profile_travel")
		for path: String in pairs:
			grid.walk_profile_travel[StrideMatch.ROOT + path] = t.vec(pairs, path)
		assert(t.ok(), ", ".join(t.errors()))
		_shared = grid if t.ok() else RivetGridStride.new()
	return _shared


static func _numbers(t: DataTable, row: Dictionary) -> Dictionary[String, float]:
	var values: Dictionary[String, float] = {}
	for key: String in row:
		values[key] = t.num(row, key)
	return values


static func _rows(t: DataTable, pitches: Dictionary) -> Dictionary[String, PackedVector2Array]:
	var out: Dictionary[String, PackedVector2Array] = {}
	for pitch: String in pitches:
		var rows: Array = t.array(pitches, pitch)
		var cycles: PackedVector2Array = PackedVector2Array()
		for pair: Variant in rows:
			@warning_ignore("return_value_discarded")
			cycles.append(t.vec({"cycles": pair}, "cycles"))
		out[pitch] = cycles
	return out
