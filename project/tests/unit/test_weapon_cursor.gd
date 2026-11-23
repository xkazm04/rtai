extends GutTest
## Guns and ghost forms use their class cursor. Melee uses the system arrow.


func test_a_gun_id_has_its_class() -> void:
	assert_eq(WeaponCursor.style_of(&"pistol", &"base"), &"small_arm")
	assert_eq(WeaponCursor.style_of(&"gatling", &"base"), &"auto")
	assert_eq(WeaponCursor.style_of(&"rocket_launcher", &"base"), &"blast")


func test_a_quest_rifle_reads_as_a_rifle() -> void:
	assert_eq(WeaponCursor.style_of(&"assault-rifle", &"base"), &"rifle")


func test_switching_from_a_gun_to_any_melee_selection_restores_the_arrow() -> void:
	var cursor: WeaponCursor = WeaponCursor.new()
	var melee: Array[StringName] = [&"", &"hands", &"claw"]
	melee.append_array(MeleeTable.weapon_ids())
	for id: StringName in melee:
		cursor.show_for(&"pistol", &"base")
		assert_not_null(WeaponCursor.texture_for(cursor._shown))
		cursor.show_for(id, &"base")
		assert_eq(cursor._shown, WeaponCursor.SYSTEM_ARROW)
		assert_null(WeaponCursor.texture_for(cursor._shown), "null restores the native pointer")
	cursor.clear()


func test_the_alternate_dot_has_a_visible_center_and_transparent_margin() -> void:
	var dot: Texture2D = WeaponCursor.texture_for(WeaponCursor.PLAIN_DOT)
	assert_eq(dot.get_size(), Vector2(9, 9))
	var img: Image = dot.get_image()
	assert_eq(img.get_pixel(4, 4), Color.WHITE)
	assert_eq(img.get_pixel(4, 1), Color.BLACK)
	assert_eq(img.get_pixel(0, 0).a, 0.0)


func test_a_ghost_form_wins_over_the_weapon() -> void:
	assert_eq(WeaponCursor.style_of(&"pistol", &"kerf"), &"ghost_kerf")
	assert_eq(WeaponCursor.style_of(&"katana", &"kerf"), &"ghost_kerf")


func test_every_class_has_a_cursor_the_right_size_with_a_clear_edge() -> void:
	var styles: Array[StringName] = [&"rifle"]
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
