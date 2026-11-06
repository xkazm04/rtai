extends GutTest
## n8-hud: a floor gun's showcase drawing lies in an open crate under a tilt (ShowcaseCrate): one
## crate cut per pitch keyed by the view's art, none straight down, and the weapon's bottom edge
## rests on the straw (inside the crate's box), never over the front wall.


func test_one_crate_cut_per_pitch_and_none_straight_down() -> void:
	var c: ShowcaseCrate = ShowcaseCrate.new()
	assert_not_null(c.texture("p70"), "play pitch")
	assert_not_null(c.texture("p55"), "boss pitch")
	assert_null(c.texture(""), "top: no crate, the flat path")


func test_the_weapon_never_outgrows_the_straw() -> void:
	assert_eq(ShowcaseCrate.fill_m(1.7), ShowcaseCrate.FILL_M, "the Gatling is cut to the straw")
	assert_eq(ShowcaseCrate.fill_m(1.05), 1.05, "a short gun keeps its span")
	assert_eq(ShowcaseCrate.fill_m(1.05, true), ShowcaseCrate.STAND_M, "the standing bottle")
	assert_lt(ShowcaseCrate.FILL_M, ShowcaseCrate.LONG_M, "the gun fits inside the crate")


func test_the_weapon_rests_on_the_straw_inside_the_crate() -> void:
	for form: String in ["p70", "p55"]:
		var crate: Sprite2D = _crate(form)
		var half: Vector2 = crate.texture.get_size() * crate.scale * 0.5
		var h: float = 40.0
		var at: Vector2 = ShowcaseCrate.lie_px(crate, form, h)
		var bottom: float = at.y + h * 0.5
		assert_between(bottom, -half.y * 0.2, half.y * 0.4, "%s: bottom on the straw" % form)
		assert_almost_eq(at.x, 0.0, 0.5, "%s: centred along the crate" % form)
		crate.free()


func test_the_crate_is_stood_up_for_its_camera() -> void:
	var crate: Sprite2D = _crate("p70")
	var gk: float = ViewMode.of("tilt70").ground_k()
	ShowcaseCrate.size_crate(crate, gk)
	assert_almost_eq(
		crate.texture.get_width() * crate.scale.x,
		ShowcaseCrate.LONG_M * SimConst.PX_PER_M,
		0.01,
		"LONG_M long"
	)
	assert_almost_eq(crate.scale.y, crate.scale.x / gk, 0.0001, "y undone by the camera's zoom")
	crate.free()


func _crate(form: String) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = ShowcaseCrate.new().texture(form)
	ShowcaseCrate.size_crate(s, 1.0)
	return s


func test_the_hover_stays_the_default() -> void:
	assert_false(ShowcaseCrate.on(), "the crate is the owner's call: --pickup-crate=on")
