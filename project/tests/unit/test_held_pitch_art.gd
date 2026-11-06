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
			var r: HeldPitchArt.Row = _shipped().pitches[key][id]
			assert_true(ResourceLoader.exists(r.art), r.art)
			var size: Vector2 = (load(r.art) as Texture2D).get_size()
			assert_true(Rect2(Vector2.ZERO, size).has_point(r.grip), "%s grip" % id)
			assert_true(Rect2(Vector2.ZERO, size).has_point(r.muzzle), "%s muzzle" % id)
			assert_gt(r.muzzle.x, r.grip.x, "%s: the barrel runs +x from the grip" % id)


func test_left_aim_mirrors_about_the_barrel_and_keeps_the_grip_on_the_origin() -> void:
	var s: Sprite2D = _shipped().make(&"pistol", 55.0, WeaponArt.new())
	add_child_autofree(s)
	var r: HeldPitchArt.Row = s.get_meta(&"pitch_row")
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
