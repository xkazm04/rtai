extends GutTest
## combat-notes: the electro stun's spits reach out past the body's silhouette (about 0.25 m at
## the shoulders), so a 20 px body at 32 px/m reads as live, and they re-aim as the arcs crawl.

const SILHOUETTE_M: float = 0.25
const PPM: float = 32.0


func _reach(pts: PackedVector2Array) -> float:
	return pts[pts.size() - 1].length() / PPM


func test_each_spit_starts_on_the_body_and_ends_past_it() -> void:
	for n: int in 30:
		for j: int in ShockJolt.SPITS:
			var pts: PackedVector2Array = ShockJolt.spit(Vector2.ZERO, PPM, n, j)
			assert_lt(pts[0].length() / PPM, SILHOUETTE_M, "starts inside the body")
			assert_gt(_reach(pts), SILHOUETTE_M + 0.15, "ends well past the silhouette")


func test_the_spits_re_aim_with_the_arc_frame() -> void:
	var moved: int = 0
	for n: int in 30:
		var a: Vector2 = ShockJolt.spit(Vector2.ZERO, PPM, n, 0)[ShockJolt.KINKS]
		var b: Vector2 = ShockJolt.spit(Vector2.ZERO, PPM, n + 1, 0)[ShockJolt.KINKS]
		moved += 1 if a.distance_to(b) > 4.0 else 0
	assert_gt(moved, 20, "a new direction on most arc frames")


func test_planted_inner_arc_is_caught() -> void:
	# the crawling arcs alone (iteration 1): BODY_M + ARC_M from the centre at most
	var inner: float = ShockJolt.BODY_M * sqrt(2.0) * 0.5 + ShockJolt.ARC_M * 0.5
	assert_lt(inner, SILHOUETTE_M + 0.15, "an arc that stays on the body fails the reach check")
