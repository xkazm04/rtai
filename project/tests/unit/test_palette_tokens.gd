extends GutTest
## The colour doctrine as data: tokens, accent gates and the per-layer allow list.

var _pal: PaletteTokens


func before_all() -> void:
	_pal = PaletteTokens.shared()


func test_the_tokens_match_the_print_shaders() -> void:
	assert_true(_pal.color(&"paper").is_equal_approx(Color8(0xF2, 0xE8, 0xD5)))
	# ink / wash reach the print as uniforms (look_profiles tones, test_look_profiles); pinned
	# here so a re-tone is a deliberate edit: the target frame's warm charcoal (2026-11-03)
	assert_true(_pal.color(&"ink").is_equal_approx(Color8(0x1B, 0x15, 0x17)))
	assert_true(_pal.color(&"wash").is_equal_approx(Color8(0x6C, 0x61, 0x61)))
	assert_eq(_pal.classify(_pal.color(&"ink_2")), 0)
	assert_true(_pal.color(&"vermilion").is_equal_approx(Color8(0xE8, 0x50, 0x2A)))
	assert_true(_pal.color(&"teal").is_equal_approx(Color8(0x1F, 0xB5, 0xA8)))


func test_the_accent_inks_classify_and_the_base_tones_do_not() -> void:
	assert_eq(_pal.classify(_pal.color(&"vermilion")), 1)
	assert_eq(_pal.classify(_pal.color(&"teal")), 2)
	for id: StringName in [&"paper", &"paper_2", &"ink", &"ink_2", &"wash", &"steel"]:
		assert_eq(_pal.classify(_pal.color(id)), 0, String(id))


func test_accents_are_allowed_only_on_their_layers() -> void:
	assert_true(_pal.allowed(&"vermilion", &"actors"))
	assert_false(_pal.allowed(&"vermilion", &"ground"))
	assert_false(_pal.allowed(&"teal", &"vehicles"))
	assert_false(_pal.allowed(&"pink", &"actors"))


func test_count_accents_counts_pixels() -> void:
	var img: Image = Image.create_empty(10, 10, false, Image.FORMAT_RGB8)
	img.fill(_pal.color(&"paper"))
	img.fill_rect(Rect2i(0, 0, 4, 5), _pal.color(&"vermilion"))
	img.fill_rect(Rect2i(6, 6, 2, 2), _pal.color(&"teal"))
	assert_eq(_pal.count_accents(img), Vector2i(20, 4))


func test_blood_and_cop_blue_classify_apart_from_vermilion() -> void:
	# blood also passes the vermilion gate: it is tested first (look_noir blood_mask's split)
	assert_eq(_pal.classify(_pal.color(&"blood")), 3)
	assert_eq(_pal.classify(_pal.color(&"blood_dark")), 3)
	assert_eq(_pal.classify(_pal.color(&"cop_blue")), 4)
	assert_eq(_pal.classify(_pal.color(&"cop_blue_hi")), 4)
	assert_eq(_pal.classify(_pal.color(&"vermilion")), 1)
	assert_eq(_pal.classify(_pal.color(&"teal")), 2)


func test_cop_blue_keeps_the_charcoal_value() -> void:
	# an ink navy, not a bright blue: the black-and-white read survives (luma within 0.04)
	var a: Color = _pal.color(&"cop_blue")
	var b: Color = _pal.color(&"ink_2")
	var la: float = 0.299 * a.r + 0.587 * a.g + 0.114 * a.b
	var lb: float = 0.299 * b.r + 0.587 * b.g + 0.114 * b.b
	assert_lt(absf(la - lb), 0.04)


func test_the_2026_11_03_doctrine_layers() -> void:
	assert_true(_pal.allowed(&"blood", &"world"), "pools and splats lie on the street")
	assert_true(_pal.allowed(&"blood", &"actors"))
	assert_true(_pal.allowed(&"cop_blue", &"vehicles"))
	assert_false(_pal.allowed(&"cop_blue", &"world"))
	assert_false(_pal.allowed(&"vermilion", &"vehicles"), "no vermilion on cruisers")
	assert_false(_pal.accent_uses[&"vermilion"].has("cop"), "no vermilion on cops")
	assert_true(_pal.accent_uses[&"vermilion"].has("rivet_collar"))


func test_count_inks_counts_every_accent() -> void:
	var img: Image = Image.create_empty(10, 10, false, Image.FORMAT_RGB8)
	img.fill(_pal.color(&"paper"))
	img.fill_rect(Rect2i(0, 0, 4, 5), _pal.color(&"vermilion"))
	img.fill_rect(Rect2i(6, 6, 2, 2), _pal.color(&"teal"))
	img.fill_rect(Rect2i(0, 8, 3, 2), _pal.color(&"blood"))
	img.fill_rect(Rect2i(9, 0, 1, 7), _pal.color(&"cop_blue"))
	assert_eq(_pal.count_inks(img), PackedInt32Array([63, 20, 4, 6, 7]))
	assert_eq(_pal.count_accents(img), Vector2i(20, 4), "blood is not vermilion")
