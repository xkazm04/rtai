extends GutTest
## Owner note 2026-11-09: "Cursor icon should be styled per weapon equipped".


func test_a_gun_id_has_its_class() -> void:
	assert_eq(WeaponCursor.style_of(&"pistol", &"base"), &"small_arm")
	assert_eq(WeaponCursor.style_of(&"gatling", &"base"), &"auto")
	assert_eq(WeaponCursor.style_of(&"rocket_launcher", &"base"), &"blast")


func test_a_quest_rifle_reads_as_a_rifle() -> void:
	assert_eq(WeaponCursor.style_of(&"assault-rifle", &"base"), &"rifle")


func test_no_weapon_and_a_blade_read_as_melee() -> void:
	assert_eq(WeaponCursor.style_of(&"", &"base"), &"melee")
	var melee: Array[StringName] = MeleeTable.weapon_ids()
	assert_false(melee.is_empty(), "the table has blades")
	assert_eq(WeaponCursor.style_of(melee[0], &"base"), &"melee")


func test_a_ghost_form_wins_over_the_weapon() -> void:
	assert_eq(WeaponCursor.style_of(&"pistol", &"kerf"), &"ghost_kerf")


func test_every_class_has_a_cursor_the_right_size_with_a_clear_edge() -> void:
	var styles: Array[StringName] = [&"melee", &"rifle"]
	styles.append_array(WeaponCursor.GUNS.values())
	styles.append_array(WeaponCursor.FORMS.values())
	for style: StringName in styles:
		var tex: Texture2D = load(WeaponCursor.DIR + String(style) + ".png") as Texture2D
		assert_not_null(tex, "%s has a cursor" % style)
		if tex == null:
			continue
		assert_eq(tex.get_size(), Vector2(48.0, 48.0), "%s: cursors are cut at 48 px" % style)
		var img: Image = tex.get_image()
		assert_lt(img.get_pixel(0, 0).a, 0.05, "%s: the corner is clear" % style)
