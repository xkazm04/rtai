extends GutTest
## n12 C2: a blast knocks the print's off-register plates a few px along the blow and they settle
## back; one shock in flight, a cooldown after it, nothing at rest. Shipped off (data 0).


func before_each() -> void:
	PlateShock.reset()


func after_each() -> void:
	PlateShock.reset()


func test_nothing_at_rest() -> void:
	assert_eq(PlateShock.offset(), Vector2.ZERO)
	assert_false(PlateShock.kick(0.0, 10, Vector2.RIGHT, 5), "a row of 0 px asks for none")
	assert_eq(PlateShock.offset_at(5), Vector2.ZERO)


func test_full_on_the_kick_then_settled_by_its_length() -> void:
	assert_true(PlateShock.kick(3.0, 10, Vector2(2.0, 0.0), 100))
	assert_almost_eq(PlateShock.offset_at(100).x, 3.0, 0.001, "3 px along the blow")
	assert_lt(PlateShock.offset_at(105).length(), 1.0, "most of it gone by half way")
	assert_eq(PlateShock.offset_at(110), Vector2.ZERO, "settled")
	assert_eq(PlateShock.offset_at(99), Vector2.ZERO, "nothing before")


func test_one_in_flight_and_a_cooldown() -> void:
	assert_true(PlateShock.kick(3.0, 10, Vector2.RIGHT, 100))
	assert_false(PlateShock.kick(3.0, 10, Vector2.LEFT, 104), "one in flight")
	assert_false(PlateShock.kick(3.0, 10, Vector2.LEFT, 115), "cooling down")
	assert_true(PlateShock.kick(3.0, 10, Vector2.LEFT, 100 + 10 + PlateShock.COOLDOWN_TICKS))


func test_the_blast_rows_carry_a_length_and_ship_at_zero_px() -> void:
	var feel: HitFeel = HitFeel.shipped()
	for cls: StringName in [&"blast", &"slam", &"ram"]:
		var s: Vector2 = feel.camera_row(&"", cls, false)["plate_shock"]
		assert_gt(s.y, 0.0, "%s settles over some ticks" % cls)
		assert_eq(s.x, 0.0, "%s ships off (a call for the owner)" % cls)
	var light: Vector2 = feel.camera_row(&"pistol", &"light", false)["plate_shock"]
	assert_eq(light, Vector2.ZERO)


func test_a_feel_cam_blast_kicks_the_plates_when_the_row_asks() -> void:
	var cam: FeelCam = FeelCam.attach(null, SimClock.new())
	cam.feel._rows[&"blast"]["plate_shock"] = Vector2(3.0, 10.0)
	@warning_ignore("return_value_discarded")
	cam.hit(&"rocket_launcher", &"blast", Vector2.UP, false, 50)
	assert_almost_eq(PlateShock.offset_at(50).length(), 3.0, 0.001)
	PlateShock.reset()
	cam.reduced_motion = true
	@warning_ignore("return_value_discarded")
	cam.hit(&"rocket_launcher", &"blast", Vector2.UP, false, 200)
	assert_eq(PlateShock.offset_at(200), Vector2.ZERO, "off under reduced motion")
