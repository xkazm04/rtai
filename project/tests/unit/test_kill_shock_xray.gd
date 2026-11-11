extends GutTest
## n16 kills-polish: the electro X-ray skeleton stands on the body's feet (DEFECTS ranking #2),
## not lying along the shot beside him. `--shock-xray=lie` (the before) is unset under tests.


func test_the_skeleton_is_upright_by_default() -> void:
	assert_false(KillXray.lies())


func test_the_skeleton_centre_is_half_its_height_above_the_feet() -> void:
	var feet: Vector2 = Vector2(100.0, 200.0)
	var mid: Vector2 = KillXray.mid(feet, KillShockFx.XRAY_M, 32.0)
	assert_eq(mid.x, feet.x)
	var want: float = feet.y - (KillShockFx.XRAY_M * 0.5 - KillXray.FOOT_M) * 32.0
	assert_almost_eq(mid.y, want, 0.001)


func test_the_skeleton_rises_with_the_zoom() -> void:
	var rise64: float = -KillXray.mid(Vector2.ZERO, KillShockFx.XRAY_M, 64.0).y
	var rise32: float = -KillXray.mid(Vector2.ZERO, KillShockFx.XRAY_M, 32.0).y
	assert_almost_eq(rise64, rise32 * 2.0, 0.001)
	assert_gt(rise32, 0.0)


## n16 item 3 (asset lane A3): each street kind flashes its own drawn skeleton.
func test_each_street_row_maps_to_its_drawn_set() -> void:
	assert_eq(KillXray.kind_of_row("cop/head_cap"), "cop_patrol")
	assert_eq(KillXray.kind_of_row("cop/head_helmet"), "cop_riot")
	assert_eq(KillXray.kind_of_row("cop/head_swat"), "swat")
	assert_eq(KillXray.kind_of_row("ped/head_hood"), "ped_hood")
	assert_eq(KillXray.kind_of_row("ped/head_hair"), "ped_suit")
	assert_eq(KillXray.kind_of_row("ped/head_punk"), "ped_generic")
	assert_eq(KillXray.kind_of_row("thug"), "ped_generic")
	assert_eq(KillXray.kind_of_row(""), "")


func test_every_drawn_set_is_loaded_and_two_frames_wide() -> void:
	for kind: String in KillXray.BY_ROW.values():
		assert_true(KillXray.ART.has(kind), kind)
	for kind: String in KillXray.ART:
		var tex: Texture2D = KillXray.ART[kind]
		assert_not_null(tex, kind)
		assert_eq(tex.get_width() % 2, 0, kind)


func test_an_untagged_body_keeps_the_plain_skeleton() -> void:
	var body: Node2D = autofree(Node2D.new())
	assert_null(KillXray.art_of(body))
	body.set_meta(KillXray.KIND, "cop_riot")
	assert_eq(KillXray.art_of(body), KillXray.ART["cop_riot"])


func test_the_drawn_set_stands_on_the_feet_within_its_height_and_width() -> void:
	var feet: Vector2 = Vector2(50.0, 300.0)
	for kind: String in KillXray.ART:
		var r: Rect2 = KillXray.rect(KillXray.ART[kind], feet, KillShockFx.XRAY_M, 32.0)
		assert_almost_eq(r.end.y, feet.y + KillXray.FOOT_M * 32.0, 0.01, kind)
		assert_almost_eq(r.get_center().x, feet.x, 0.01, kind)
		assert_lte(r.size.y, KillShockFx.XRAY_M * 32.0 + 0.01, kind)
		assert_lte(r.size.x, KillXray.WIDE_M * 32.0 + 0.01, kind)


func test_the_p55_view_flashes_the_p55_set_of_every_kind() -> void:
	assert_eq(KillXray.ART_55.keys(), KillXray.ART.keys())
	for kind: String in KillXray.ART_55:
		var tex: Texture2D = KillXray.ART_55[kind]
		assert_not_null(tex, kind)
		assert_eq(tex.get_width() % 2, 0, kind)
		assert_ne(tex, KillXray.ART[kind], kind)
	var view: ViewMode = ViewMode.shared()
	var was: String = view.art
	var body: Node2D = autofree(Node2D.new())
	body.set_meta(KillXray.KIND, "swat")
	view.art = "p55"
	var p55: Texture2D = KillXray.art_of(body)
	view.art = "p70"
	var p70: Texture2D = KillXray.art_of(body)
	view.art = was
	assert_eq(p55, KillXray.ART_55["swat"])
	assert_eq(p70, KillXray.ART["swat"])
