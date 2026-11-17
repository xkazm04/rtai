extends GutTest
## Half-height walls show fewer storeys at the elevation's own aspect (FacadeStoreys), the upper
## counts the three styles fall on at the game's wall heights.

const TENEMENT_GROUND: float = 90.0 * 124.0 / 256.0
const TENEMENT_UPPER: float = 90.0 * 132.0 / 256.0
const TALL_GROUND: float = 102.0 * 128.0 / 256.0
const TALL_UPPER: float = 102.0 * 72.0 / 256.0


func test_a_tenement_wall_is_two_storeys_at_half_height() -> void:
	for lift: float in [76.0, 81.0, 93.0]:
		assert_eq(FacadeStoreys.upper_count(lift, TENEMENT_GROUND, TENEMENT_UPPER), 1, "%f" % lift)


func test_a_tall_wall_gets_more_storeys_as_it_rises() -> void:
	var low: int = FacadeStoreys.upper_count(98.0, TALL_GROUND, TALL_UPPER)
	var high: int = FacadeStoreys.upper_count(180.0, TALL_GROUND, TALL_UPPER)
	assert_true(high > low, "%d -> %d" % [low, high])


func test_a_short_wall_keeps_the_ground_storey_alone() -> void:
	assert_eq(FacadeStoreys.upper_count(30.0, 60.0, 40.0), 0)


func test_no_upper_row_means_ground_only() -> void:
	assert_eq(FacadeStoreys.upper_count(200.0, 60.0, 0.0), 0)


func test_the_table_names_a_storey_sheet_per_p70_style() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ChunkLift.TABLE))
	var styles: Dictionary = d["styles"]
	for style: String in ["tenement", "shop", "tall", "dock", "glass"]:
		var row: Dictionary = styles[style]
		var storeys: Dictionary = row["storeys"]
		assert_true(storeys.has("p70"), style)
		var p70: Dictionary = storeys["p70"]
		var art: String = p70["art"]
		assert_true(ResourceLoader.exists(art), art)


func test_the_zone_roofs_draw_their_zone_walls() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ChunkLift.TABLE))
	var by_name: Dictionary = d["by_name"]
	for roof: String in ["roof_dock_warehouse", "roof_dock_warehouse_b", "roof_dock_shed"]:
		assert_eq(str(by_name[roof]["style"]), "dock", roof)
	for roof: String in ["roof_down_tower", "roof_down_tower_b"]:
		assert_eq(str(by_name[roof]["style"]), "glass", roof)


func test_a_storey_sheet_cuts_into_its_own_bays() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ChunkLift.TABLE))
	var styles: Dictionary = d["styles"]
	for style: String in ["dock", "glass"]:
		var p70: Dictionary = styles[style]["storeys"]["p70"]
		var sheet: Texture2D = load(str(p70["art"]))
		var bays: int = p70["bays"]
		assert_eq(bays, 4, style)
		assert_eq(sheet.get_width() % bays, 0, style)
		var rows: float = p70["ground_h"] + p70["upper_h"]
		assert_eq(int(rows), sheet.get_height(), style)
