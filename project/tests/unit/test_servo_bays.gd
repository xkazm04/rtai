extends GutTest
## ServoBays (render only): the docked drones sit on the rack art's bay centres, mirrored across
## the spine, at the art's pitch, never far from the sim's launch cells; a bays object with no
## rack yet says it is off the art instead of failing (the it16 first-frame error).


func _bays() -> ServoBays:
	var t: ServoTuning = ServoTuning.shipped()
	var r: ServoRack = ServoRack.new()
	r.setup(t)
	var b: ServoBays = ServoBays.new()
	b.rack = r
	b.wing_c_m = 1.305 + r.spine_m() * 0.5
	return b


func test_no_rack_is_off_the_art() -> void:
	assert_false(ServoBays.new().on_art())


func test_bays_mirror_at_the_art_pitch_near_the_cells() -> void:
	var b: ServoBays = _bays()
	var pts: Array[Vector2] = b.points(Vector2.ZERO, Vector2.RIGHT, 1.0, Vector2.ZERO, true)
	assert_eq(pts.size(), 18)
	assert_almost_eq(pts[0].y, -pts[5].y, 0.001, "the wings mirror across the spine")
	assert_almost_eq(pts[0].x - pts[6].x, 62.6 / 96.0, 0.01, "the art's row pitch")
	assert_almost_eq(absf(pts[1].y - pts[0].y), 69.8 / 96.0, 0.01, "the art's bay pitch")
	for i: int in pts.size():
		assert_lt(pts[i].distance_to(b.rack.cell_pos(i)), 0.45, "bay %d near its cell" % i)


func test_off_draws_on_the_sim_cells() -> void:
	var b: ServoBays = _bays()
	var pts: Array[Vector2] = b.points(Vector2.ZERO, Vector2.RIGHT, 1.0, Vector2.ONE, false)
	assert_eq(pts[4], b.rack.cell_pos(4))
