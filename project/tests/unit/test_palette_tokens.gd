extends GutTest
## The colour doctrine as data: tokens, accent gates and the per-layer allow list.

var _pal: PaletteTokens


func before_all() -> void:
	_pal = PaletteTokens.shared()


func test_the_tokens_match_the_print_shaders() -> void:
	assert_true(_pal.color(&"paper").is_equal_approx(Color8(0xF2, 0xE8, 0xD5)))
	assert_true(_pal.color(&"ink").is_equal_approx(Color8(0x17, 0x13, 0x1B)))
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
