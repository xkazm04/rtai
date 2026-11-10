extends GutTest
## n15 hero h-3/h-4: a drawn ghost's left octants draw from its `_left` sheet (unmirrored), the
## right ones and a column past the left sheet's from the right grid; Dent's jab plays act columns
## 4-6.

const P70: String = "p70"
## The p70 left sheets shipped (h-3), one ghost per commit.
const SHIPPED_LEFT: Array[String] = ["dent_walk8", "dent_run8", "dent_act"]


func _sheet(cols: int, left_cols: int) -> GhostSheet:
	var right: ImageTexture = ImageTexture.create_from_image(
		Image.create(cols * 10, GhostDrawn.ROWS * 20, false, Image.FORMAT_RGBA8)
	)
	var left: ImageTexture = ImageTexture.create_from_image(
		Image.create(left_cols * 12, GhostSheet.LEFT_ROWS * 24, false, Image.FORMAT_RGBA8)
	)
	return GhostSheet.new(right, cols, left, left_cols)


func test_each_left_octant_draws_its_own_row_unmirrored() -> void:
	var sheet: GhostSheet = _sheet(8, 8)
	var spr: Sprite2D = autofree(Sprite2D.new())
	for o: int in [3, 4, 5]:
		sheet.show(spr, o, 2)
		assert_eq(spr.texture, sheet.left, "oct %d" % o)
		assert_eq(spr.vframes, GhostSheet.LEFT_ROWS)
		assert_eq(spr.frame, (o - 3) * 8 + 2, "oct %d" % o)
		assert_false(spr.flip_h, "a drawn left row is never mirrored")
		assert_eq(GhostSheet.oct_of(spr), o, "the recorder reads the octant back")


func test_the_right_octants_keep_the_right_grid() -> void:
	var sheet: GhostSheet = _sheet(8, 8)
	var spr: Sprite2D = autofree(Sprite2D.new())
	for o: int in [0, 1, 2, 6, 7]:
		sheet.show(spr, o, 5)
		assert_eq(spr.texture, sheet.tex, "oct %d" % o)
		assert_eq(spr.frame, RigHeadCard.OCT_FRAME[o] * 8 + 5)
		assert_eq(spr.flip_h, RigHeadCard.OCT_FLIP[o] == 1)
		assert_eq(GhostSheet.oct_of(spr), o)


func test_a_column_past_the_left_sheet_mirrors_the_right_row() -> void:
	var sheet: GhostSheet = _sheet(7, GhostDrawn.ACT_COLS)
	var spr: Sprite2D = autofree(Sprite2D.new())
	sheet.show(spr, 4, GhostDrawn.JAB_SHIFT + 1)
	assert_eq(spr.texture, sheet.tex, "the jab has no drawn left row yet")
	assert_true(spr.flip_h)
	assert_eq(spr.frame, RigHeadCard.OCT_FRAME[4] * 7 + GhostDrawn.JAB_SHIFT + 1)
	sheet.show(spr, 4, GhostDrawn.HIT_COL)
	assert_eq(spr.texture, sheet.left, "the hit is drawn left")
	assert_eq(spr.hframes, GhostDrawn.ACT_COLS)


func test_the_feet_sit_on_each_grids_own_cell() -> void:
	var sheet: GhostSheet = _sheet(8, 8)
	var spr: Sprite2D = autofree(Sprite2D.new())
	sheet.show(spr, 0, 0)
	assert_eq(spr.offset, Vector2(-5.0, GhostDrawn.PAD_PX - 20.0))
	sheet.show(spr, 4, 0)
	assert_eq(spr.offset, Vector2(-6.0, GhostDrawn.PAD_PX - 24.0))


func test_without_a_left_sheet_every_left_octant_mirrors() -> void:
	var sheet: GhostSheet = GhostSheet.new(_sheet(8, 8).tex, 8)
	var spr: Sprite2D = autofree(Sprite2D.new())
	sheet.show(spr, 4, 1)
	assert_eq(spr.texture, sheet.tex)
	assert_true(spr.flip_h)


func test_the_shipped_left_sheets_divide_into_three_rows_of_the_right_columns() -> void:
	for key: String in SHIPPED_LEFT:
		_check_left(key)


func _check_left(key: String) -> void:
	var path: String = GhostDrawn.ART_DIR.path_join(P70).path_join(key + "_left.png")
	var tex: Texture2D = load(path) as Texture2D
	assert_not_null(tex, key)
	if tex == null:
		return
	var cols: int = GhostDrawn.ACT_COLS if key.ends_with("_act") else GhostDrawn.COLS
	assert_eq(tex.get_width() % cols, 0, key)
	assert_eq(tex.get_height() % GhostSheet.LEFT_ROWS, 0, key)


func test_dents_jab_plays_the_jab_columns_while_it_winds_up_and_strikes() -> void:
	var jab: DentJab = DentJab.new()
	assert_false(GhostActs.jabbing(jab), "no jab yet")
	jab.due_tick = 3
	assert_true(GhostActs.jabbing(jab), "winding up")
	jab.due_tick = -1
	jab.steps = 10
	jab.swung_step = 10
	assert_true(GhostActs.jabbing(jab), "the strike")
	jab.steps = 10 + GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS
	assert_false(GhostActs.jabbing(jab), "the act phases are over")


func test_dents_p70_act_sheet_carries_the_jab_columns() -> void:
	var tex: Texture2D = load(GhostDrawn.path_of(P70, "dent", "act")) as Texture2D
	var cols: int = GhostDrawn.JAB_COLS["dent/p70"]
	assert_eq(cols, GhostDrawn.JAB_SHIFT + 3, "wind-up, jab, recoil after the 4 phases")
	assert_eq(tex.get_width() % cols, 0)


func test_the_jab_moves_the_strike_phases_but_never_the_hit() -> void:
	var cols: int = GhostDrawn.JAB_SHIFT + 3
	assert_eq(GhostDrawn.jab_col(GhostDrawn.WINDUP_COL, true, cols), GhostDrawn.JAB_SHIFT)
	assert_eq(GhostDrawn.jab_col(GhostDrawn.CUT_COL, true, cols), GhostDrawn.JAB_SHIFT + 1)
	assert_eq(GhostDrawn.jab_col(GhostDrawn.FOLLOW_COL, true, cols), GhostDrawn.JAB_SHIFT + 2)
	assert_eq(GhostDrawn.jab_col(GhostDrawn.HIT_COL, true, cols), GhostDrawn.HIT_COL)
	assert_eq(GhostDrawn.jab_col(-1, true, cols), -1, "the walk")
	assert_eq(GhostDrawn.jab_col(GhostDrawn.CUT_COL, false, cols), GhostDrawn.CUT_COL, "a seize")
	var four: int = GhostDrawn.ACT_COLS
	assert_eq(
		GhostDrawn.jab_col(GhostDrawn.CUT_COL, true, four), GhostDrawn.CUT_COL, "no jab cells"
	)
