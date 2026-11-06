extends GutTest


func test_top_view_has_no_form() -> void:
	assert_eq(WeaponShowcase.form_of(ViewMode.of("top")), "", "top keeps today's art")


func test_tilt_views_take_the_rows_art_key() -> void:
	assert_eq(WeaponShowcase.form_of(ViewMode.of("tilt")), "p55")
	assert_eq(WeaponShowcase.form_of(ViewMode.of("tilt70")), "p70")


func test_path_is_keyed_by_form() -> void:
	assert_eq(
		WeaponShowcase.path_of(&"pistol", "p70"),
		"res://features/combat/weapons/art/showcase/p70/pistol.png"
	)


func test_missing_drawing_is_a_stand_in_not_art() -> void:
	var s: WeaponShowcase = WeaponShowcase.new()
	assert_null(s.texture(&"no_such_gun", "p70"))
	assert_null(s.texture(&"pistol", ""), "no form, no showcase")
	var ids: Array[StringName] = [&"no_such_gun"]
	assert_eq(s.stand_ins(ids, "p70"), ids)


func test_hud_icon_falls_back_to_the_shipped_icon() -> void:
	var feed: HudFeed = HudFeed.new()
	assert_not_null(feed.icon_of(&"pistol"), "pistol has a shipped icon part")
	assert_null(feed.icon_of(&""), "unarmed: no icon")


func test_all_seventeen_weapons_have_every_form() -> void:
	var s: WeaponShowcase = WeaponShowcase.new()
	var ids: Array[StringName] = [
		&"pistol",
		&"machine_pistol",
		&"hand_cannon",
		&"gloria",
		&"plasma_rifle",
		&"gatling",
		&"rocket_launcher",
		&"flamethrower",
		&"molotov",
		&"katana",
		&"electro_baton",
		&"chainsaw",
		&"electro_gun",
		&"homing_shard",
		&"ray_gun",
		&"mini_nuke",
		&"plasma_sword",
	]
	for form: String in ["p70", "p55", WeaponShowcase.ICON]:
		assert_eq(s.stand_ins(ids, form), [] as Array[StringName], form)


func test_the_rack_hangs_icons_under_a_form_and_parts_in_top() -> void:
	var rack: WeaponRackView = WeaponRackView.new()
	add_child_autofree(rack)
	rack._form = ""
	rack._hang()
	assert_not_null(rack._sprites[0].material, "top: the shipped part print")
	rack._form = "p70"
	rack._hang()
	var pistol: Sprite2D = rack._sprites[0]
	assert_eq(pistol.texture, rack.showcase.texture(&"pistol", WeaponShowcase.ICON))
	assert_null(pistol.material, "the showcase icon is already inked")
