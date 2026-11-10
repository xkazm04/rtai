extends GutTest
## n11 it14: Rivet's one-row strips cut at RivetWalk.RES x the 110 px figure (RivetRes.X15).

const PISTOL: String = RivetStrips.DIR + "p70/rivet_eq_pistol.png"


func test_an_x15_strip_reads_its_tables_at_res() -> void:
	assert_eq(RivetRes.of(PISTOL), RivetWalk.RES)
	assert_eq(RivetRes.of(RivetStrips.DIR + "p55/rivet_eq_pistol.png"), 1.0)
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
