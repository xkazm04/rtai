extends GutTest
## Lane kills-new (n16): a death's own drawn cells (KillDeathCells). The row names its grid per view
## art and card row; every grid it names exists and holds 5 facings across and one row per frame
## start; frames step on their start ticks; a kind without cells (and a row without any) keeps
## the fall grid.


func test_the_pistol_row_names_a_grid_for_the_four_street_kinds() -> void:
	var e: KillTrackRows.Extra = KillTrackRows.of(&"pistol_snap")
	assert_eq(KillDeathCells.path_of(e, "p70", "cop/head_cap"), "p70/cop_patrol_pistol_snap.png")
	assert_eq(KillDeathCells.path_of(e, "p70", "cop/head_helmet"), "p70/cop_riot_pistol_snap.png")
	assert_eq(KillDeathCells.path_of(e, "p70", "cop/head_swat"), "p70/swat_pistol_snap.png")
	assert_eq(KillDeathCells.path_of(e, "p70", "ped/head_hair"), "p70/ped_suit_pistol_snap.png")
	assert_eq(KillDeathCells.path_of(e, "p55", "cop/head_cap"), "p55/cop_patrol_pistol_snap.png")
	assert_eq(
		KillDeathCells.path_of(e, "p55", "ped/head_hair"),
		"p70/ped_suit_pistol_snap.png",
		"an art without its own cells draws the fallback art's"
	)
	assert_eq(KillDeathCells.path_of(e, "p70", "thug"), "", "a kind without cells keeps its fall")


func test_a_row_without_cells_names_none() -> void:
	var e: KillTrackRows.Extra = KillTrackRows.of(&"gatling_shred")
	assert_eq(KillDeathCells.path_of(e, "p70", "cop/head_cap"), "")
	assert_eq(KillDeathCells.frame_at(e, 50), -1)


func test_frames_step_on_their_start_ticks() -> void:
	var e: KillTrackRows.Extra = KillTrackRows.Extra.new()
	e.cells_at = PackedInt32Array([0, 8, 14, 21])
	var got: Array[int] = []
	for age: int in [0, 7, 8, 13, 14, 20, 21, 400]:
		got.append(KillDeathCells.frame_at(e, age))
	assert_eq(got, [0, 0, 1, 1, 2, 2, 3, 3] as Array[int])
	e.cells_at = PackedInt32Array([4])
	assert_eq(KillDeathCells.frame_at(e, 3), -1, "nothing drawn before the first frame's tick")


func test_every_named_grid_exists_with_a_row_per_frame() -> void:
	var t: DataTable = DataTable.open(SignatureKillTable.PATH, SignatureKillTable.SCHEMA)
	assert_true(t.ok())
	var named: int = 0
	for v: Variant in t.array(t.raw, "kills"):
		var d: Dictionary = v
		var id: StringName = StringName(str(d.get("id", "")))
		var e: KillTrackRows.Extra = KillTrackRows.of(id)
		for art: Variant in e.grids:
			var rows: Dictionary = e.grids[art]
			for card_row: Variant in rows:
				var path: String = StreetWalkerCards.DIR + str(art) + "/" + str(rows[card_row])
				assert_true(ResourceLoader.exists(path), "%s: %s exists" % [id, path])
				var tex: Texture2D = load(path)
				var cell: Vector2 = Vector2(tex.get_width() / 5.0, tex.get_height())
				cell.y /= float(e.cells_at.size())
				assert_eq(fmod(float(tex.get_height()), float(e.cells_at.size())), 0.0, path)
				assert_almost_eq(cell.x, roundf(cell.x), 0.001, "%s: 5 whole columns" % path)
				named += 1
	assert_gte(named, 4, "the pistol's four kinds at least")


func test_the_pistol_throws_the_drawn_cap_or_helmet_of_the_three_cops() -> void:
	var e: KillTrackRows.Extra = KillTrackRows.of(&"pistol_snap")
	assert_eq(
		KillDeathCells.path_in(e.loose, "p70", "cop/head_cap"), "p70/cop_patrol_headgear_tumble.png"
	)
	assert_eq(
		KillDeathCells.path_in(e.loose, "p70", "cop/head_swat"), "p70/swat_headgear_tumble.png"
	)
	assert_eq(
		KillDeathCells.path_in(e.loose, "p70", "ped/head_hair"), "", "a bare head throws none"
	)
	for art: Variant in e.loose:
		var rows: Dictionary = e.loose[art]
		for card_row: Variant in rows:
			var path: String = StreetWalkerCards.DIR + str(art) + "/" + str(rows[card_row])
			assert_true(ResourceLoader.exists(path), "%s exists" % path)


func test_the_loose_cap_arcs_from_over_his_head_to_the_street_behind_him() -> void:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.extra = KillTrackRows.of(&"pistol_snap")
	d.dir = Vector2.RIGHT
	d.feet_px = Vector2(100.0, 200.0)
	d.height = 64.0
	var at: int = roundi(d.extra.num("loose_at", 0.0))
	var lands: int = at + roundi(d.extra.num("loose_ticks", 0.0))
	var start: Vector2 = KillLooseArt.where(d, at, 32.0)
	assert_lt(start.y, d.feet_px.y - d.height, "it leaves from above his head")
	var rest: Vector2 = KillLooseArt.where(d, lands, 32.0)
	assert_almost_eq(rest.y, d.feet_px.y, 0.01, "it lands on the street")
	assert_almost_eq(rest.x, d.feet_px.x + d.extra.num("loose_m", 0.0) * 32.0, 0.01, "behind him")
	assert_eq(KillLooseArt.where(d, lands + 300, 32.0), rest, "and stays there")


func test_the_stitch_plays_five_drawn_frames_for_the_four_street_kinds() -> void:
	var e: KillTrackRows.Extra = KillTrackRows.of(&"smg_stitch")
	assert_eq(KillDeathCells.path_of(e, "p70", "cop/head_cap"), "p70/cop_patrol_smg_stitch.png")
	assert_eq(KillDeathCells.path_of(e, "p70", "ped/head_hair"), "p70/ped_suit_smg_stitch.png")
	assert_eq(KillDeathCells.path_of(e, "p55", "cop/head_swat"), "p70/swat_smg_stitch.png")
	assert_eq(e.cells_at.size(), 5, "hip, belly, chest, the spin, on his side")
	var spin: int = roundi(e.num("whirl_from", 0.0))
	assert_eq(KillDeathCells.frame_at(e, spin), 3, "the drawn spin starts with the whirl")


func test_own_cells_keep_the_lean_only_where_the_row_says() -> void:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.extra = KillTrackRows.of(&"smg_stitch")
	assert_eq(KillDeathCells.lean_of(d), 1.0, "a fall grid (or none) keeps the whole lean")
	var own: Sprite2D = autofree(Sprite2D.new())
	own.set_meta(KillDeathCells.META, true)
	d.cells = own
	assert_eq(KillDeathCells.lean_of(d), 1.0, "the stitch jerks its drawn frames (cells_lean 1)")
	d.extra = KillTrackRows.of(&"pistol_snap")
	assert_eq(KillDeathCells.lean_of(d), 0.0, "the pistol's drawing holds the pose")
