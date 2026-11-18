extends GutTest
## n11 it14: Rivet's one-row strips cut at RivetWalk.RES x the 110 px figure (RivetRes.X15).

const PISTOL: String = RivetStrips.DIR + "p70/rivet_eq_pistol.png"


func test_an_x15_strip_reads_its_tables_at_res() -> void:
	assert_eq(RivetRes.of(PISTOL), RivetWalk.RES)
	assert_eq(RivetRes.of(RivetStrips.DIR + "p55/rivet_eq_katana.png"), 1.0, "p55 katana: 110")
	assert_eq(RivetStrips.foot_px(PISTOL), float(RivetFrames.PAD_PX), "the cut pads PAD px")


func test_an_x15_strip_is_its_110_cut_times_res() -> void:
	var tex: Texture2D = load(PISTOL) as Texture2D
	assert_almost_eq(tex.get_height() / RivetWalk.RES, 121.0, 2.0, "the 110 cut's cell was 121 px")


func test_a_card_on_an_x15_strip_divides_its_scale_by_res() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	card.vframes = 1
	card.set_meta(RivetFrames.ON, PISTOL)
	assert_eq(RivetWalk.res_of(card), RivetWalk.RES)
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p55/rivet_eq_katana.png")
	assert_eq(RivetWalk.res_of(card), 1.0, "a strip outside X15 stays 1:1")


func test_base_strip_preserves_cell_size_and_boot_anchor_at_both_pitches() -> void:
	var was: ViewMode = ViewMode._shared
	for view: String in ["tilt70", "tilt"]:
		ViewMode._shared = ViewMode.of(view)
		var art: String = ViewMode.shared().art
		var rig: CutRig = add_child_autofree(CutRig.new())
		rig.plan = RivetPlan.build()
		rig.body = Node2D.new()
		rig.head = Node2D.new()
		rig.add_child(rig.body)
		rig.add_child(rig.head)
		var card: Sprite2D = Sprite2D.new()
		rig.head.add_child(card)
		rig.head_card = card
		RivetFrames.step(rig)
		var path: String = str(card.get_meta(RivetFrames.ON))
		assert_eq(path, RivetStrips.DIR + art + "/" + RivetStrips.BASE)
		var cell: Vector2 = card.texture.get_size() / Vector2(card.hframes, card.vframes)
		var old: Vector2 = Vector2(164, 124) if art == "p70" else Vector2(101, 117)
		assert_almost_eq(cell, old * 1.5, Vector2.ONE * 0.51)
		var metres: float = 1.65 if art == "p70" else 1.95
		var old_scale: float = metres * PlayerScale.k() * CharacterRigs.PX_PER_M / 110.0
		assert_almost_eq(card.global_scale * cell, old * old_scale, Vector2.ONE * 0.5)
		assert_eq(card.offset.y + cell.y, RivetFrames.PAD_PX)
	ViewMode._shared = was


func test_base_profile_boot_rows_allow_for_gpu_block_padding() -> void:
	# D3D12 pads the old 117 px p55 strip to 120. Its on-screen boot sat 4 px higher
	# than the uncompressed canvas predicted at 64 px/m (the same-tick city film).
	for art: String in ["p70", "p55"]:
		var rel: String = RivetStrips.DIR + art + "/" + RivetStrips.BASE
		var path: String = ProjectSettings.globalize_path(rel)
		var img: Image = Image.load_from_file(path)
		@warning_ignore("integer_division")
		var w: int = img.get_width() / RivetFrames.BASE_CELLS
		var cell: Image = img.get_region(Rect2i(w * 2, 0, w, img.get_height()))
		assert_eq(cell.get_height() - cell.get_used_rect().end.y, 0 if art == "p70" else 6)


func test_the_katana_strip_is_its_110_cut_times_res() -> void:
	var path: String = RivetStrips.DIR + "p70/rivet_eq_katana.png"
	assert_eq(RivetRes.of(path), RivetWalk.RES)
	var tex: Texture2D = load(path) as Texture2D
	assert_almost_eq(tex.get_height() / RivetWalk.RES, 172.0, 2.0, "the 110 cut's cell was 172 px")


func test_the_chainsaw_strip_is_its_110_cut_times_res() -> void:
	var path: String = RivetStrips.DIR + "p70/rivet_eq_chainsaw.png"
	assert_eq(RivetRes.of(path), RivetWalk.RES)
	var tex: Texture2D = load(path) as Texture2D
	assert_almost_eq(tex.get_height() / RivetWalk.RES, 145.0, 2.0, "the 110 cut's cell was 145 px")


## n15 hero it16: the p70 reload strips (and their drawn left strips) cut at x1.5, each from its
## own row's fig_h (the pistol reload's 116.4 -> 174.6): the cell height over RES is the 110 cut's.
func test_the_p70_reload_strips_are_their_110_cuts_times_res() -> void:
	var cells: Dictionary[String, float] = {
		"rivet_reload_pistol": 122.0,
		"rivet_reload_pistol_left": 115.0,
		"rivet_reload_plasma_rifle": 115.0,
		"rivet_reload_plasma_rifle_left": 114.0,
		"rivet_reload_gatling": 117.0,
		"rivet_reload_gatling_left": 115.0,
	}
	for name: String in cells:
		var path: String = RivetStrips.DIR + "p70/" + name + ".png"
		assert_eq(RivetRes.of(path), RivetWalk.RES, name)
		var tex: Texture2D = load(path) as Texture2D
		assert_almost_eq(tex.get_height() / RivetWalk.RES, cells[name], 2.5, name)


func test_the_p55_reload_strips_are_their_110_cuts_times_res() -> void:
	var cells: Dictionary[String, float] = {
		"rivet_reload_pistol": 108.0,
		"rivet_reload_pistol_left": 116.0,
		"rivet_reload_plasma_rifle": 103.0,
		"rivet_reload_plasma_rifle_left": 116.0,
		"rivet_reload_gatling": 116.0,
		"rivet_reload_gatling_left": 111.0,
	}
	for name: String in cells:
		var path: String = RivetStrips.DIR + "p55/" + name + ".png"
		assert_eq(RivetRes.of(path), RivetWalk.RES, name)
		var tex: Texture2D = load(path) as Texture2D
		assert_almost_eq(tex.get_height() / RivetWalk.RES, cells[name], 2.5, name)
