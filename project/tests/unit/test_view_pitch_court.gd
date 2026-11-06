extends GutTest
## Lane d8-view70: the King's court strips (KingArt) keyed by the card folder under combo.

const COURT_55: String = "res://features/bosses/king/art/p55/king_bust_card.png"
const COURT_70: String = "res://features/bosses/king/art/p70/king_bust_card.png"


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


func test_the_p70_court_strip_draws_the_bust_as_wide_as_its_own_row() -> void:
	# view70 cut the p70 bust into KingArt's p70 slot, each cell padded to the court's width factor,
	# so KingArt's factor over the p70 row (already the bust's width) draws the same bust.
	var row: Array = ViewPitchCourt.court_row("king", "p70")
	assert_eq(str(row[0]), COURT_70)
	var own: Array = RigHeadCard.rows_of("p70")["king"]
	var own_tex: Texture2D = load(str(own[0])) as Texture2D
	var court_tex: Texture2D = load(COURT_70) as Texture2D
	var court_k: float = KingArt.STRIPS["king"][2]
	assert_eq(court_tex.get_height(), own_tex.get_height(), "the same cell height")
	assert_almost_eq(
		float(court_tex.get_width()),
		own_tex.get_width() * court_k,
		1.0,
		"cells padded by the factor"
	)
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


func test_a_p70_card_takes_the_padded_court_strip_at_the_same_drawn_scale() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	var path: String = str(RigHeadCard.rows_of("p70")["king"][0])
	card.texture = load(path) as Texture2D
	card.set_meta(&"art", "p70")
	card.set_meta(KingArt.META, 1.0)
	add_child_autofree(card)
	ViewPitchCourt.dress(card)
	assert_eq(card.texture.resource_path, COURT_70)
	var k: float = card.get_meta(KingArt.META)
	assert_almost_eq(card.scale.x, 1.0, 0.01, "the bust's pixels draw as large as before")
	assert_eq(k, KingArt.STRIPS["king"][2])


func test_only_a_folder_with_an_own_horn_strip_needs_dressing_unblended() -> void:
	assert_true(ViewPitchCourt.dresses("p70"), "the p70 King bust draws its own bell")
	assert_false(ViewPitchCourt.dresses("p55"), "tilt: KingArt hides the horn itself")
	assert_false(ViewPitchCourt.dresses(""))


func test_the_p70_slot_holds_the_court_set_so_70_compares_the_pitch_alone() -> void:
	# view70: at 70 the King's and the gang's cards and limbs and the throne-car are the court's
	# (the limbs top-down parts, the car a lifted stack: the p55 art), so 55 vs 70 differ by pitch.
	assert_false(KingArt.strip_path("gang", 70.0).is_empty(), "the gang's card")
	for wall: String in ["car_side", "car_front", "car_rear", "car_roof", "throne_front", "cannon"]:
		assert_true(ResourceLoader.exists(KingCarWalls.DIR % [70, wall]), wall)
	for set_dir: String in ["parts", "gang_parts"]:
		var p: String = KingArt.PARTS_DIR % [70, set_dir, "l_foot"]
		assert_true(ResourceLoader.exists(p), p)
	assert_true(KingArt.strip_path("king", 90.0).is_empty(), "straight down: no court art")
