extends GutTest
## d9-seams: a bay's apron mark drops under the bodies while a fighter's body box meets its number.


func test_body_in_front_of_the_number_meets_it() -> void:
	var r: Rect2 = ServoDepotDraw.number_m(Vector2.ZERO)
	var people: Array[Vector3] = [Vector3(0.0, 4.5, 0.45)]  # feet south, head drawn over it
	assert_true(ServoDepotDraw.meets(r, people))


func test_body_far_south_or_aside_does_not() -> void:
	var r: Rect2 = ServoDepotDraw.number_m(Vector2.ZERO)
	var people: Array[Vector3] = [Vector3(0.0, 7.0, 0.45), Vector3(4.0, 1.5, 0.45)]
	assert_false(ServoDepotDraw.meets(r, people))


func test_wide_boss_reaches_further() -> void:
	var r: Rect2 = ServoDepotDraw.number_m(Vector2.ZERO)
	assert_false(ServoDepotDraw.meets(r, [Vector3(2.6, 1.5, 0.45)] as Array[Vector3]))
	assert_true(ServoDepotDraw.meets(r, [Vector3(2.6, 1.5, 2.5)] as Array[Vector3]))


func test_cover_flags_only_the_met_bay() -> void:
	var d: ServoDepotDraw = ServoDepotDraw.new()
	var t: ServoTuning = ServoTuning.new()
	t.bays = [Vector2(0.0, 0.0), Vector2(10.0, 0.0)] as Array[Vector2]
	t.bay_w_m = 3.0
	d.cover(t, Vector2.ZERO, [Vector3(10.0, 3.0, 0.45)] as Array[Vector3])
	assert_eq(d.under, [false, true] as Array[bool])
