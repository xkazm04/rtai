extends GutTest


func test_a_solid_rect_is_stamped_as_prop_cells_in_its_chunk() -> void:
	var n: int = SimConst.CHUNK_CELLS
	var cells: PackedByteArray = CityChunk.zeros(n * n)
	var key: Vector2i = Vector2i(1, 0)
	var rects: Array[Rect2] = [Rect2(Vector2(n + 2.0, 3.0), Vector2(4.0, 0.5))]
	var out: PackedByteArray = CityResidency.with_solids(key, cells, rects)
	assert_eq(int(out[3 * n + 2]), SimConst.C_PROP, "the rect's first cell")
	assert_eq(int(out[3 * n + 5]), SimConst.C_PROP, "the rect's last cell")
	assert_eq(int(out[3 * n + 6]), 0, "past the rect")
	assert_eq(int(out[4 * n + 2]), 0, "below the rect")
	assert_eq(int(cells[3 * n + 2]), 0, "the chunk's own cells are not written")


func test_a_rect_in_another_chunk_stamps_nothing() -> void:
	var n: int = SimConst.CHUNK_CELLS
	var cells: PackedByteArray = CityChunk.zeros(n * n)
	var rects: Array[Rect2] = [Rect2(Vector2(n + 2.0, 3.0), Vector2(4.0, 1.0))]
	var out: PackedByteArray = CityResidency.with_solids(Vector2i(0, 0), cells, rects)
	assert_eq(out.count(SimConst.C_PROP), 0)


func test_the_arena_hands_its_walls_to_the_sim() -> void:
	assert_true(ArenaSession.SOLID_TO_SIM)
