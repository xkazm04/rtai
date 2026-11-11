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
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetStrips.BASE)
	assert_eq(RivetWalk.res_of(card), 1.0, "a strip outside X15 stays 1:1")


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
