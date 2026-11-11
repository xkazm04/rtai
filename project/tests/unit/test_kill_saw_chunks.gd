extends GutTest
## n16 kills-polish item 3 (asset lane A5): the chainsaw grind throws its row's drawn chunks, which
## land and lie on the street; no other row throws any.


func test_only_the_chainsaw_row_throws_chunks() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_eq(table.for_weapon(&"chainsaw").saw_chunks, 8)
	for w: StringName in table.weapons():
		if w != &"chainsaw":
			assert_eq(table.for_weapon(w).saw_chunks, 0, String(w))


func test_the_sheet_holds_every_thrown_cell() -> void:
	var cells: int = KillSawChunks.ART.get_width() / KillSawChunks.ART.get_height()
	assert_eq(cells, 10)
	for k: int in KillSawChunks.ORDER:
		assert_lt(k, cells)


func test_chunks_are_on_by_default() -> void:
	assert_false(KillSawChunks.off())

