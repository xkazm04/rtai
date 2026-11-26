extends GutTest
## n31 ghost 12: Ohm's hover sheet is an authored 2 x 8 grid (ohm_spec_cells.json); loading his
## standing walk sheet never probes it as a five-row pose sheet, so no "five rows" warning.

const WALK: String = "res://features/souls/art/view/p70/ohm_walk8.png"
const WARNING: String = "ohm_spec_hover.png needs five rows of square pose cells"


func _warnings() -> int:
	var n: int = 0
	for line: String in Log.recent():
		if line.contains(WARNING):
			n += 1
	return n


func test_ohm_standing_sheet_loads_without_the_pose_probe_warning() -> void:
	var before: int = _warnings()
	var steps: PackedFloat32Array = PackedFloat32Array([0.0, 0.25, 0.5, 0.75])
	var sheet: GhostSheet = GhostSheet.walk_of(WALK, steps, true)
	assert_not_null(sheet, "falls through to the walk sheet OhmDrawn replaces")
	assert_false(sheet.poses, "not a pose sheet")
	assert_eq(_warnings(), before)


func test_the_hover_sheet_is_not_a_five_row_pose_sheet() -> void:
	var hover: Texture2D = load(WALK.trim_suffix("walk8.png") + "spec_hover.png") as Texture2D
	assert_ne(hover.get_height() % GhostDrawn.ROWS, 0, "2184 px = 8 rows of 273, not 5 squares")
