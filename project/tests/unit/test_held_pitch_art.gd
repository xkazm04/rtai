extends GutTest
## d8-weapons: HeldPitchArt, the held weapon drawn for a raised camera.


func _shipped() -> HeldPitchArt:
	return HeldPitchArt.shipped()


func test_table_reads_clean() -> void:
	assert_true(_shipped().errors.is_empty(), str(_shipped().errors))
	assert_false(_shipped().pitches.is_empty())


func test_top_view_never_gets_pitch_art() -> void:
	assert_eq(HeldPitchArt.key_of(90.0), "")
	assert_null(_shipped().row(&"pistol", 90.0))
	assert_null(_shipped().make(&"pistol", 90.0, WeaponArt.new()))


func test_tilt_pitch_has_the_pistol() -> void:
	assert_eq(HeldPitchArt.key_of(55.0), "55")
	var s: Sprite2D = _shipped().make(&"pistol", 55.0, WeaponArt.new())
	assert_not_null(s)
	assert_true(s.texture.get_size().y > 0.0)
	s.free()


func test_every_row_points_at_real_art_with_grip_and_muzzle_inside() -> void:
	for key: String in _shipped().pitches:
		for id: StringName in _shipped().pitches[key]:
			var r: HeldPitchRow = _shipped().pitches[key][id]
			assert_true(ResourceLoader.exists(r.art), r.art)
			var size: Vector2 = (load(r.art) as Texture2D).get_size()
			assert_true(Rect2(Vector2.ZERO, size).has_point(r.grip), "%s grip" % id)
			assert_true(Rect2(Vector2.ZERO, size).has_point(r.muzzle), "%s muzzle" % id)
			assert_gt(r.muzzle.x, r.grip.x, "%s: the barrel runs +x from the grip" % id)


func test_left_aim_mirrors_about_the_barrel_and_keeps_the_grip_on_the_origin() -> void:
	var s: Sprite2D = _shipped().make(&"pistol", 55.0, WeaponArt.new())
	add_child_autofree(s)
	var r: HeldPitchRow = s.get_meta(&"pitch_row")
	var h: float = s.texture.get_size().y
	s.global_rotation = 0.0
	HeldPitchArt.face(s)
	assert_false(s.flip_v)
	assert_eq(HeldPitchArt.muzzle_local(s, Vector2.ZERO), r.muzzle - r.grip)
	s.global_rotation = PI
	HeldPitchArt.face(s)
	assert_true(s.flip_v, "the grip hangs down while the barrel points left")
	assert_eq(s.offset.y, -(h - r.grip.y))
	var mirrored: Vector2 = Vector2(r.muzzle.x - r.grip.x, r.grip.y - r.muzzle.y)
	assert_eq(HeldPitchArt.muzzle_local(s, Vector2.ZERO), mirrored)


func test_a_top_down_sprite_is_left_alone() -> void:
	var s: Sprite2D = Sprite2D.new()
	s.offset = Vector2(-3, -4)
	HeldPitchArt.face(s)
	assert_false(s.flip_v)
	assert_eq(HeldPitchArt.muzzle_local(s, Vector2(10, 4)), Vector2(7, 0))
	s.free()


func test_stand_undoes_the_camera_squash_and_keeps_the_barrel_on_the_ground() -> void:
	var s: Sprite2D = Sprite2D.new()
	s.scale = Vector2(0.5, 0.5)
	s.rotation = 0.6
	var g: float = sin(deg_to_rad(55.0))
	var barrel: Vector2 = s.transform.x
	HeldPitchArt.stand(s, g)
	assert_eq(s.transform.x, barrel, "the barrel axis stays on the ground")
	var x_screen: Vector2 = Vector2(s.transform.x.x, s.transform.x.y * g)
	var y_screen: Vector2 = Vector2(s.transform.y.x, s.transform.y.y * g)
	assert_almost_eq(x_screen.dot(y_screen), 0.0, 1e-5, "height is upright on screen")
	var k: float = lerpf(HeldPitchArt.EDGE_ON_K, 1.0, absf(x_screen.normalized().x))
	assert_almost_eq(y_screen.length(), 0.5 * k, 1e-5, "at the art's scale, edge-on as it turns")
	assert_gt(x_screen.cross(y_screen), 0.0, "not mirrored")
	s.rotation = 0.6
	HeldPitchArt.stand(s, g)
	assert_almost_eq(Vector2(s.transform.y.x, s.transform.y.y * g).length(), 0.5 * k, 1e-5)
	s.rotation = 0.0
	HeldPitchArt.stand(s, g)
	assert_almost_eq(s.transform.y.length(), 0.5 / g, 1e-5, "across the screen: the full side")
	s.rotation = PI / 2.0
	HeldPitchArt.stand(s, g)
	assert_almost_eq(
		s.transform.y.length(), 0.5 * HeldPitchArt.EDGE_ON_K, 1e-5, "nose-down: edge-on"
	)
	s.free()


func test_half_thickness_is_the_top_down_barrel_for_a_pitch_part() -> void:
	var art: WeaponArt = WeaponArt.new()
	var s: Sprite2D = _shipped().make(&"plasma_rifle", 55.0, art)
	add_child_autofree(s)
	var td: float = (
		art.held_texture(&"plasma_rifle").get_height() * art.world_scale(&"plasma_rifle")
	)
	assert_almost_eq(HeldPitchArt.half_thickness(s), td * 0.5, 1e-3)
	assert_lt(HeldPitchArt.half_thickness(s), s.texture.get_height() * s.scale.y * 0.5)
	var flat: Sprite2D = art.make_held(&"plasma_rifle")
	add_child_autofree(flat)
	var want: float = flat.texture.get_height() * absf(flat.global_scale.y) * 0.5
	assert_eq(HeldPitchArt.half_thickness(flat), want, "a top-down part: as before")


func test_a_row_with_small_art_draws_it_below_the_lod_zoom_on_the_same_canvas() -> void:
	var art: WeaponArt = WeaponArt.new()
	art.held_small_below_ppm = 56.0
	var s: Sprite2D = _shipped().make(&"plasma_rifle", 55.0, art)
	assert_true(s is HeldLod, "a pitch row with `small` is a HeldLod")
	var lod: HeldLod = s as HeldLod
	assert_eq(lod.small.get_size(), lod.full.get_size(), "same canvas: grip and muzzle stay valid")
	assert_true(s.get_node_or_null(^"Rim0") != null or not WeaponArt.rim, "the rim swaps with it")
	s.free()
	art.held_small_below_ppm = 0.0
	var plain: Sprite2D = _shipped().make(&"plasma_rifle", 55.0, art)
	assert_false(plain is HeldLod, "no LOD zoom: the full part only")
	plain.free()


func test_a_pitch_tube_goes_empty_with_its_own_part_and_back() -> void:
	var art: WeaponArt = WeaponArt.new()
	var s: Sprite2D = _shipped().make(&"rocket_launcher", 55.0, art)
	assert_not_null(s)
	var r: HeldPitchRow = HeldPitchArt.row_of(s)
	assert_ne(r.empty, "", "the 55 rocket tube has an empty part")
	var full: Texture2D = s.texture
	HeldTube.apply(s, art, &"rocket_launcher", true)
	assert_eq(s.texture.resource_path, r.empty, "the pitch row's empty part, not the top-down one")
	assert_eq(s.texture.get_size(), full.get_size(), "same canvas")
	HeldTube.apply(s, art, &"rocket_launcher", false)
	assert_eq(s.texture, full)
	s.free()


func test_a_disabled_row_keeps_the_top_down_part() -> void:
	var r: HeldPitchRow = _shipped().pitches["55"].get(&"gatling", null)
	assert_not_null(r, "the 55 Gatling art stays in the table")
	assert_false(r.enabled, "judged worse than the top-down part at 48 px/m")
	assert_null(_shipped().row(&"gatling", 55.0))
	assert_null(_shipped().make(&"gatling", 55.0, WeaponArt.new()))
