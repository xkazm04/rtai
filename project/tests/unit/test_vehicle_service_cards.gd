extends GutTest
## n8 vehicles it22: the delivery truck and the depot van's showcase atlas (vehicle_cards.py
## --set=service) exists for both pitches as five drawn views by two rows, with no FINE rows.

const DIR: String = "res://features/vehicles/art/%s/service_cards.png"


func test_service_atlas_is_five_views_by_two_rows_per_pitch() -> void:
	for art: String in ["p70", "p55"]:
		var tex: Texture2D = load(DIR % art) as Texture2D
		assert_not_null(tex, art)
		if tex == null:
			continue
		var grid: Vector2i = VehicleViews.grid_of(tex, 2)
		assert_eq(grid, Vector2i(VehicleViews.COLS, 2), art)
		assert_eq(VehicleViews.fine_rows(grid.x, art).size(), 0, art)


func test_truck_and_van_cells_hold_art_inside_the_cell() -> void:
	var img: Image = TestArt.rgba(load(DIR % "p70") as Texture2D)
	var c: int = VehicleViews.CELL_PX
	for row: int in 2:
		for col: int in VehicleViews.COLS:
			var top: int = row * c
			var edge: bool = false
			for x: int in range(col * c, (col + 1) * c, 4):
				edge = (
					edge or img.get_pixel(x, top).a > 0.04 or img.get_pixel(x, top + c - 1).a > 0.04
				)
			assert_false(edge, "row %d col %d touches its cell's edge" % [row, col])
