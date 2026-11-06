extends GutTest
## Lane d8-view70: the King's court strips (KingArt) keyed by the card folder under combo.

const COURT_55: String = "res://features/bosses/king/art/p55/king_bust_card.png"


func test_a_folder_stands_for_its_pitch() -> void:
	assert_eq(ViewPitchCourt.pitch_of("p55"), 55.0)
	assert_eq(ViewPitchCourt.pitch_of("p70"), 70.0)
	assert_eq(ViewPitchCourt.pitch_of(""), 90.0, "no folder: straight down, no court strip")
	assert_eq(ViewPitchCourt.pitch_of("pxx"), 90.0)


func test_the_p55_rows_draw_the_court_bust_at_its_width() -> void:
	var row: Array = ViewPitchCourt.court_row("king", "p55")
	assert_eq(str(row[0]), COURT_55)
	var anchor: float = KingArt.STRIPS["king"][1]
	var base_k: float = RigHeadCard.rows_of("p55")["king"][2]
	var court_k: float = KingArt.STRIPS["king"][2]
	var got_anchor: float = row[1]
	var got_k: float = row[2]
	assert_eq(got_anchor, anchor)
	assert_almost_eq(got_k, base_k * court_k, 0.0001, "the shared width times the court factor")
	assert_eq(str(ViewPitchCourt.rows_of("p55")["king"][0]), COURT_55)


func test_p70_has_no_court_strip_so_its_own_row_stays() -> void:
	assert_true(ViewPitchCourt.court_row("king", "p70").is_empty())
	var own: Array = RigHeadCard.rows_of("p70")["king"]
	assert_eq(ViewPitchCourt.rows_of("p70")["king"], own)
	var shared: String = RigHeadCard.rows_of("p55")["king"][0]
	assert_ne(shared, COURT_55, "rows_of itself is untouched")


func test_a_card_rebuilt_under_p55_takes_the_court_strip_once() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	card.hframes = RigHeadCard.FRAMES
	card.texture = load(str(RigHeadCard.rows_of("p55")["king"][0])) as Texture2D
	card.set_meta(&"art", "p55")
	card.set_meta(KingArt.META, 1.0)
	add_child_autofree(card)
	var old_w: float = card.texture.get_width()
	ViewPitchCourt.dress(card)
	assert_eq(card.texture.resource_path, COURT_55)
	var court_k: float = KingArt.STRIPS["king"][2]
	var got_k: float = card.get_meta(KingArt.META)
	assert_eq(got_k, court_k)
	var want: float = old_w / card.texture.get_width() * court_k
	assert_almost_eq(card.scale.x, want, 0.0001, "this frame drawn as wide as KingArt draws it")
	ViewPitchCourt.dress(card)
	assert_almost_eq(card.scale.x, want, 0.0001, "a second dress changes nothing")


func test_a_p70_card_is_left_alone() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	var path: String = str(RigHeadCard.rows_of("p70")["king"][0])
	card.texture = load(path) as Texture2D
	card.set_meta(&"art", "p70")
	add_child_autofree(card)
	ViewPitchCourt.dress(card)
	assert_eq(card.texture.resource_path, path)
	assert_eq(card.scale, Vector2.ONE)
