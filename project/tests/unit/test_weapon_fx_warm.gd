extends GutTest
## n12: every weapon fx cell is loaded before the first draw asks for it, into the very cache the
## draw reads (no pixel can move); the warm walks each fx id once, frame sets folded to their base.


func test_fx_ids_fold_frame_sets_to_their_base() -> void:
	var ids: Array[StringName] = WeaponFxArt.art().fx_cells.ids()
	assert_true(ids.has(&"blast"), "blast_0..3 -> blast")
	assert_false(ids.has(&"blast_0"))
	assert_true(ids.has(&"scorch"), "a single cell keeps its id")
	assert_true(ids.has(&"gore_stump_round"), "a name with an underscore is not a frame")
	assert_eq(ids.count(&"smoke"), 1)


func test_fx_warm_fills_the_cache_the_draw_reads() -> void:
	WeaponFxWarm.warm()
	for id: StringName in WeaponFxArt.art().fx_cells.ids():
		var want: int = WeaponFxArt.art().fx_cells.frame_paths(id).size()
		assert_eq(WeaponFxWarm.frames_of(id).size(), want, String(id))
	assert_eq(WeaponFxWarm.frames_of(&"blast").size(), 4)
	var first: Texture2D = WeaponFxWarm.frames_of(&"blast")[0]
	var again: Texture2D = WeaponFxWarm.frames_of(&"blast")[0]
	assert_same(again, first, "kept, not reloaded")
