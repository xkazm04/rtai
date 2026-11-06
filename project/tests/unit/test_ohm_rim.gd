extends GutTest
## n7-melee: Ohm's bolt stops at a struck body's rim (ghost_attacks.json ohm rim_m, view only), so
## the stroke never runs across the body it lands on; rim_m 0 is the old body-to-body stroke.

const BODY_M: float = 0.45


func _view(rim_m: float) -> OhmView:
	var v: OhmView = autofree(OhmView.new())
	v.ppm = 32.0
	v.rim_m = rim_m
	return v


func test_shipped_rim_clears_the_body() -> void:
	var rim_m: float = GhostAttacks.shipped().num(&"ohm", &"rim_m")
	assert_gt(rim_m, BODY_M, "the ring sits outside a 0.45 m body")
	assert_lt(rim_m, 1.0, "and close enough to belong to it")


func test_stroke_ends_at_the_rim_and_leaves_from_the_far_rim() -> void:
	var v: OhmView = _view(0.6)
	var a: Vector2 = Vector2(0.0, 0.0)
	var b: Vector2 = Vector2(3.0, 0.0) * v.ppm
	assert_almost_eq(v.rim(a, b, true).x, (3.0 - 0.6) * v.ppm, 0.01, "stops short of b")
	assert_almost_eq(v.rim(a, b, false).x, 0.6 * v.ppm, 0.01, "leaves a's rim")
	var end: Vector2 = v.rim(a, b, true)
	assert_gt(end.distance_to(b), BODY_M * v.ppm, "the stroke's end is off the body")


func test_a_close_hop_is_drawn_body_to_body() -> void:
	var v: OhmView = _view(0.6)
	var b: Vector2 = Vector2(1.2, 0.0) * v.ppm
	assert_eq(v.rim(Vector2.ZERO, b, true), b, "too short for two rims and a stroke")


func test_rim_off_is_the_old_stroke() -> void:
	var v: OhmView = _view(0.0)
	var b: Vector2 = Vector2(3.0, 0.0) * v.ppm
	assert_eq(v.rim(Vector2.ZERO, b, true), b)
	assert_eq(v.rim(Vector2.ZERO, b, false), Vector2.ZERO)
